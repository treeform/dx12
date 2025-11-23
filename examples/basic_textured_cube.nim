import pixie
import vmath
import windy
import windy/platforms/win32/windefs

import dx12

const
  width = 1280
  height = 800
  texturePath = "examples/testTexture.png"
  vertexCount = 36

type
  CubeRenderer = object
    rootSignature: ID3D12RootSignature
    pipelineState: ID3D12PipelineState
    params: array[4, float32]
    texture: ID3D12Resource
    srvHeap: ID3D12DescriptorHeap
    srvHandleGpu: D3D12_GPU_DESCRIPTOR_HANDLE

proc updateConstants(renderer: var CubeRenderer, aspect, time: float32) =
  renderer.params[0] = aspect
  renderer.params[1] = time
  renderer.params[2] = 0
  renderer.params[3] = 0

proc uploadTexture(ctx: var D3D12Context, renderer: var CubeRenderer) =
  var image: Image
  try:
    image = readImage(texturePath)
  except PixieError as e:
    raise newException(Exception, "Failed to load texture: " & e.msg)

  let
    texWidth = image.width
    texHeight = image.height
    bytesPerPixel = 4
    rowSize = texWidth * bytesPerPixel

  var texDesc: D3D12_RESOURCE_DESC
  echo "sizeof(D3D12_RESOURCE_DESC)=", sizeof(D3D12_RESOURCE_DESC)
  zeroMem(addr texDesc, sizeof(texDesc))
  texDesc.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D
  texDesc.Alignment = 0
  texDesc.Width = uint64(texWidth)
  texDesc.Height = uint32(texHeight)
  texDesc.DepthOrArraySize = 1
  texDesc.MipLevels = 1
  texDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM
  texDesc.SampleDesc = DXGI_SAMPLE_DESC(Count: 1, Quality: 0)
  texDesc.Layout = D3D12_TEXTURE_LAYOUT_UNKNOWN
  texDesc.Flags = D3D12_RESOURCE_FLAG_NONE

  var defaultHeap: D3D12_HEAP_PROPERTIES
  zeroMem(addr defaultHeap, sizeof(defaultHeap))
  defaultHeap.typ = D3D12_HEAP_TYPE_DEFAULT
  defaultHeap.CPUPageProperty = 0
  defaultHeap.MemoryPoolPreference = 0
  defaultHeap.CreationNodeMask = 1
  defaultHeap.VisibleNodeMask = 1
  echo "heap struct size=", sizeof(D3D12_HEAP_PROPERTIES)
  echo "creating default texture resource, alignment=", texDesc.Alignment
  renderer.texture = ctx.device.createCommittedResource(
    addr defaultHeap,
    D3D12_HEAP_FLAG_NONE,
    addr texDesc,
    D3D12_RESOURCE_STATE_COPY_DEST,
    nil
  )

  var footprint: D3D12_PLACED_SUBRESOURCE_FOOTPRINT
  var numRows: dx12.UINT
  var rowSizeInBytes: UINT64
  var totalBytes: UINT64
  ctx.device.getCopyableFootprints(addr texDesc, dx12.UINT(0), dx12.UINT(1), 0'u64, addr footprint, addr numRows, addr rowSizeInBytes, addr totalBytes)
  let rowPitch = int(footprint.Footprint.RowPitch)

  var uploadDesc: D3D12_RESOURCE_DESC
  zeroMem(addr uploadDesc, sizeof(uploadDesc))
  uploadDesc.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER
  uploadDesc.Alignment = 64 * 1024
  uploadDesc.Width = totalBytes
  uploadDesc.Height = 1
  uploadDesc.DepthOrArraySize = 1
  uploadDesc.MipLevels = 1
  uploadDesc.Format = DXGI_FORMAT_UNKNOWN
  uploadDesc.SampleDesc = DXGI_SAMPLE_DESC(Count: 1, Quality: 0)
  uploadDesc.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR
  uploadDesc.Flags = D3D12_RESOURCE_FLAG_NONE

  var uploadHeap: D3D12_HEAP_PROPERTIES
  zeroMem(addr uploadHeap, sizeof(uploadHeap))
  uploadHeap.typ = D3D12_HEAP_TYPE_UPLOAD
  uploadHeap.CPUPageProperty = 0
  uploadHeap.MemoryPoolPreference = 0
  uploadHeap.CreationNodeMask = 1
  uploadHeap.VisibleNodeMask = 1
  echo "creating upload buffer resource, width=", uploadDesc.Width, " heapType=", uploadHeap.typ
  let uploadBuffer = ctx.device.createCommittedResource(
    addr uploadHeap,
    D3D12_HEAP_FLAG_NONE,
    addr uploadDesc,
    D3D12_RESOURCE_STATE_GENERIC_READ,
    nil
  )

  var uploadPtr: pointer
  uploadBuffer.map(0, nil, addr uploadPtr)
  var dst = cast[ptr uint8](uploadPtr)
  for y in 0 ..< texHeight:
    let srcIdx = image.dataIndex(0, y)
    let srcPtr = cast[ptr uint8](image.data[srcIdx].addr)
    copyMem(dst, srcPtr, rowSize)
    if rowPitch > rowSize:
      zeroMem(cast[pointer](cast[uint](dst) + uint(rowSize)), rowPitch - rowSize)
    dst = cast[ptr uint8](cast[uint](dst) + uint(rowPitch))
  uploadBuffer.unmap(0, nil)

  var dstLocation = D3D12_TEXTURE_COPY_LOCATION(
    pResource: renderer.texture,
    typ: D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX,
    SubresourceIndex: 0
  )
  var srcLocation = D3D12_TEXTURE_COPY_LOCATION(
    pResource: uploadBuffer,
    typ: D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT,
    PlacedFootprint: footprint
  )

  ctx.commandAllocator.reset()
  ctx.commandList.reset(ctx.commandAllocator, nil)
  ctx.commandList.copyTextureRegion(addr dstLocation, 0, 0, 0, addr srcLocation, nil)
  var barrier = D3D12_RESOURCE_BARRIER(
    typ: D3D12_RESOURCE_BARRIER_TYPE_TRANSITION,
    Flags: D3D12_RESOURCE_BARRIER_FLAG_NONE,
    Transition: D3D12_RESOURCE_TRANSITION_BARRIER(
      pResource: renderer.texture,
      Subresource: D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
      StateBefore: D3D12_RESOURCE_STATE_COPY_DEST,
      StateAfter: D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE
    )
  )
  ctx.commandList.resourceBarrier(1, addr barrier)
  ctx.commandList.close()
  var cmdList = cast[ID3D12CommandList](ctx.commandList)
  ctx.commandQueue.executeCommandLists(1, addr cmdList)
  ctx.waitForGpu()
  uploadBuffer.release()

  var srvHeapDesc = D3D12_DESCRIPTOR_HEAP_DESC(
    typ: D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV,
    NumDescriptors: 1,
    Flags: D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE,
    NodeMask: 0
  )
  renderer.srvHeap = ctx.device.createDescriptorHeap(addr srvHeapDesc)
  let srvCpuHandle = renderer.srvHeap.getCPUDescriptorHandleForHeapStart()
  renderer.srvHandleGpu = renderer.srvHeap.getGPUDescriptorHandleForHeapStart()

  var srvDesc = D3D12_SHADER_RESOURCE_VIEW_DESC(
    Format: DXGI_FORMAT_R8G8B8A8_UNORM,
    ViewDimension: D3D12_SRV_DIMENSION_TEXTURE2D,
    Shader4ComponentMapping: D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING,
    Texture2D: D3D12_TEX2D_SRV(
      MostDetailedMip: 0,
      MipLevels: 1,
      PlaneSlice: 0,
      ResourceMinLODClamp: 0.0
    )
  )
  ctx.device.createShaderResourceView(renderer.texture, addr srvDesc, srvCpuHandle)

proc initRenderer(ctx: var D3D12Context, renderer: var CubeRenderer) =
  const vertexShaderSrc = """
cbuffer Transform : register(b0)
{
  float4 params;
}

static const float3 positions[36] = {
  float3(-1.0f,  1.0f,  1.0f),
  float3( 1.0f,  1.0f,  1.0f),
  float3( 1.0f, -1.0f,  1.0f),
  float3(-1.0f,  1.0f,  1.0f),
  float3( 1.0f, -1.0f,  1.0f),
  float3(-1.0f, -1.0f,  1.0f),

  float3( 1.0f,  1.0f, -1.0f),
  float3(-1.0f,  1.0f, -1.0f),
  float3(-1.0f, -1.0f, -1.0f),
  float3( 1.0f,  1.0f, -1.0f),
  float3(-1.0f, -1.0f, -1.0f),
  float3( 1.0f, -1.0f, -1.0f),

  float3(-1.0f,  1.0f, -1.0f),
  float3(-1.0f,  1.0f,  1.0f),
  float3(-1.0f, -1.0f,  1.0f),
  float3(-1.0f,  1.0f, -1.0f),
  float3(-1.0f, -1.0f,  1.0f),
  float3(-1.0f, -1.0f, -1.0f),

  float3( 1.0f,  1.0f,  1.0f),
  float3( 1.0f,  1.0f, -1.0f),
  float3( 1.0f, -1.0f, -1.0f),
  float3( 1.0f,  1.0f,  1.0f),
  float3( 1.0f, -1.0f, -1.0f),
  float3( 1.0f, -1.0f,  1.0f),

  float3(-1.0f,  1.0f, -1.0f),
  float3( 1.0f,  1.0f, -1.0f),
  float3( 1.0f,  1.0f,  1.0f),
  float3(-1.0f,  1.0f, -1.0f),
  float3( 1.0f,  1.0f,  1.0f),
  float3(-1.0f,  1.0f,  1.0f),

  float3(-1.0f, -1.0f,  1.0f),
  float3( 1.0f, -1.0f,  1.0f),
  float3( 1.0f, -1.0f, -1.0f),
  float3(-1.0f, -1.0f,  1.0f),
  float3( 1.0f, -1.0f, -1.0f),
  float3(-1.0f, -1.0f, -1.0f)
};

static const float2 texcoords[36] = {
  float2(0.0f, 0.0f), float2(1.0f, 0.0f), float2(1.0f, 1.0f),
  float2(0.0f, 0.0f), float2(1.0f, 1.0f), float2(0.0f, 1.0f),

  float2(0.0f, 0.0f), float2(1.0f, 0.0f), float2(1.0f, 1.0f),
  float2(0.0f, 0.0f), float2(1.0f, 1.0f), float2(0.0f, 1.0f),

  float2(0.0f, 0.0f), float2(1.0f, 0.0f), float2(1.0f, 1.0f),
  float2(0.0f, 0.0f), float2(1.0f, 1.0f), float2(0.0f, 1.0f),

  float2(0.0f, 0.0f), float2(1.0f, 0.0f), float2(1.0f, 1.0f),
  float2(0.0f, 0.0f), float2(1.0f, 1.0f), float2(0.0f, 1.0f),

  float2(0.0f, 0.0f), float2(1.0f, 0.0f), float2(1.0f, 1.0f),
  float2(0.0f, 0.0f), float2(1.0f, 1.0f), float2(0.0f, 1.0f),

  float2(0.0f, 0.0f), float2(1.0f, 0.0f), float2(1.0f, 1.0f),
  float2(0.0f, 0.0f), float2(1.0f, 1.0f), float2(0.0f, 1.0f)
};

struct PSInput {
  float4 pos : SV_POSITION;
  float2 uv  : TEXCOORD0;
};

float4x4 rotationX(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return float4x4(
    1.0f, 0.0f, 0.0f, 0.0f,
    0.0f, c,    s,    0.0f,
    0.0f,-s,    c,    0.0f,
    0.0f, 0.0f, 0.0f, 1.0f
  );
}

float4x4 rotationY(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return float4x4(
    c,    0.0f, -s,   0.0f,
    0.0f, 1.0f, 0.0f, 0.0f,
    s,    0.0f, c,    0.0f,
    0.0f, 0.0f, 0.0f, 1.0f
  );
}

float4x4 translation(float x, float y, float z) {
  return float4x4(
    1.0f, 0.0f, 0.0f, 0.0f,
    0.0f, 1.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 1.0f, 0.0f,
    x,    y,    z,    1.0f
  );
}

float4x4 perspective(float fov, float aspect, float zn, float zf) {
  float h = 1.0f / tan(fov * 0.5f);
  float w = h / aspect;
  return float4x4(
    w,    0.0f, 0.0f, 0.0f,
    0.0f, h,    0.0f, 0.0f,
    0.0f, 0.0f, zf / (zf - zn), 1.0f,
    0.0f, 0.0f, (-zn * zf) / (zf - zn), 0.0f
  );
}

PSInput VSMain(uint vid : SV_VertexID) {
  float aspect = params.x;
  float time = params.y;
  float4x4 rot = mul(rotationY(time * 0.7f), rotationX(time * 0.3f));
  float4x4 world = mul(translation(0.0f, 0.0f, 4.0f), rot);
  float4x4 proj = perspective(radians(60.0f), aspect, 0.1f, 100.0f);
  float4x4 mvp = mul(proj, world);

  PSInput output;
  output.pos = mul(mvp, float4(positions[vid], 1.0f));
  output.uv = texcoords[vid];
  return output;
}
"""

  const pixelShaderSrc = """
Texture2D tex0 : register(t0);
SamplerState samp0 : register(s0);

struct PSInput {
  float4 pos : SV_POSITION;
  float2 uv  : TEXCOORD0;
};

float4 PSMain(PSInput input) : SV_TARGET {
  return tex0.Sample(samp0, input.uv);
}
"""

  let vsBlob = compileShader(vertexShaderSrc, "VSMain", "vs_5_0")
  let psBlob = compileShader(pixelShaderSrc, "PSMain", "ps_5_0")

  var range = D3D12_DESCRIPTOR_RANGE(
    RangeType: D3D12_DESCRIPTOR_RANGE_TYPE_SRV,
    NumDescriptors: 1,
    BaseShaderRegister: 0,
    RegisterSpace: 0,
    OffsetInDescriptorsFromTableStart: D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND
  )

  var rootParams = [
    D3D12_ROOT_PARAMETER(
      ParameterType: D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS,
      data: D3D12_ROOT_PARAMETER_UNION(
        Constants: D3D12_ROOT_CONSTANTS(
          ShaderRegister: 0,
          RegisterSpace: 0,
          Num32BitValues: 4
        )
      ),
      ShaderVisibility: D3D12_SHADER_VISIBILITY_ALL
    ),
    D3D12_ROOT_PARAMETER(
      ParameterType: D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE,
      data: D3D12_ROOT_PARAMETER_UNION(
        DescriptorTable: D3D12_ROOT_DESCRIPTOR_TABLE(
          NumDescriptorRanges: 1,
          pDescriptorRanges: addr range
        )
      ),
      ShaderVisibility: D3D12_SHADER_VISIBILITY_PIXEL
    )
  ]

  var sampler = D3D12_STATIC_SAMPLER_DESC(
    Filter: D3D12_FILTER_MIN_MAG_MIP_LINEAR,
    AddressU: D3D12_TEXTURE_ADDRESS_MODE_WRAP,
    AddressV: D3D12_TEXTURE_ADDRESS_MODE_WRAP,
    AddressW: D3D12_TEXTURE_ADDRESS_MODE_WRAP,
    MipLODBias: 0.0,
    MaxAnisotropy: 0,
    ComparisonFunc: D3D12_COMPARISON_FUNC_ALWAYS,
    BorderColor: D3D12_STATIC_BORDER_COLOR_OPAQUE_BLACK,
    MinLOD: 0.0,
    MaxLOD: 1000.0,
    ShaderRegister: 0,
    RegisterSpace: 0,
    ShaderVisibility: D3D12_SHADER_VISIBILITY_PIXEL
  )

  var rootDesc = D3D12_ROOT_SIGNATURE_DESC(
    NumParameters: uint32(rootParams.len),
    pParameters: addr rootParams[0],
    NumStaticSamplers: 1,
    pStaticSamplers: addr sampler,
    Flags: D3D12_ROOT_SIGNATURE_FLAG_ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT
  )

  let rootBlob = serializeRootSignature(addr rootDesc)
  renderer.rootSignature = ctx.device.createRootSignature(0, getBufferPointer(rootBlob), getBufferSize(rootBlob))
  release(rootBlob)

  var blendDesc: D3D12_BLEND_DESC
  blendDesc.AlphaToCoverageEnable = 0
  blendDesc.IndependentBlendEnable = 0
  blendDesc.RenderTarget[0] = D3D12_RENDER_TARGET_BLEND_DESC(
    BlendEnable: 0,
    LogicOpEnable: 0,
    SrcBlend: D3D12_BLEND_ONE,
    DestBlend: D3D12_BLEND_ZERO,
    BlendOp: D3D12_BLEND_OP_ADD,
    SrcBlendAlpha: D3D12_BLEND_ONE,
    DestBlendAlpha: D3D12_BLEND_ZERO,
    BlendOpAlpha: D3D12_BLEND_OP_ADD,
    LogicOp: 0,
    RenderTargetWriteMask: uint8(D3D12_COLOR_WRITE_ENABLE_ALL)
  )

  let depthOp = D3D12_DEPTH_STENCILOP_DESC(
    StencilFailOp: D3D12_STENCIL_OP_KEEP,
    StencilDepthFailOp: D3D12_STENCIL_OP_KEEP,
    StencilPassOp: D3D12_STENCIL_OP_KEEP,
    StencilFunc: D3D12_COMPARISON_FUNC_ALWAYS
  )

  var psoDesc = D3D12_GRAPHICS_PIPELINE_STATE_DESC(
    pRootSignature: renderer.rootSignature,
    VS: shaderBytecode(vsBlob),
    PS: shaderBytecode(psBlob),
    StreamOutput: D3D12_STREAM_OUTPUT_DESC(),
    BlendState: blendDesc,
    SampleMask: D3D12_DEFAULT_SAMPLE_MASK,
    RasterizerState: D3D12_RASTERIZER_DESC(
      FillMode: D3D12_FILL_MODE_SOLID,
      CullMode: D3D12_CULL_MODE_BACK,
      FrontCounterClockwise: 0,
      DepthBias: 0,
      DepthBiasClamp: 0.0,
      SlopeScaledDepthBias: 0.0,
      DepthClipEnable: 1,
      MultisampleEnable: 0,
      AntialiasedLineEnable: 0,
      ForcedSampleCount: 0,
      ConservativeRaster: D3D12_CONSERVATIVE_RASTERIZATION_MODE_OFF
    ),
    DepthStencilState: D3D12_DEPTH_STENCIL_DESC(
      DepthEnable: 0,
      DepthWriteMask: D3D12_DEPTH_WRITE_MASK_ALL,
      DepthFunc: D3D12_COMPARISON_FUNC_ALWAYS,
      StencilEnable: 0,
      StencilReadMask: 0xff'u8,
      StencilWriteMask: 0xff'u8,
      FrontFace: depthOp,
      BackFace: depthOp
    ),
    InputLayout: D3D12_INPUT_LAYOUT_DESC(pInputElementDescs: nil, NumElements: 0),
    IBStripCutValue: 0,
    PrimitiveTopologyType: D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE,
    NumRenderTargets: 1,
    DSVFormat: DXGI_FORMAT_UNKNOWN,
    SampleDesc: DXGI_SAMPLE_DESC(Count: 1, Quality: 0),
    NodeMask: 0,
    CachedPSO: D3D12_CACHED_PIPELINE_STATE(),
    Flags: 0
  )
  psoDesc.RTVFormats[0] = DXGI_FORMAT_R8G8B8A8_UNORM

  renderer.pipelineState = ctx.device.createGraphicsPipelineState(addr psoDesc)

  release(vsBlob)
  release(psBlob)

  uploadTexture(ctx, renderer)

proc recordCube(ctx: var D3D12Context, renderer: CubeRenderer, clearColor: array[4, FLOAT]) =
  ctx.commandAllocator.reset()
  ctx.commandList.reset(ctx.commandAllocator, renderer.pipelineState)
  ctx.commandList.setGraphicsRootSignature(renderer.rootSignature)
  ctx.commandList.setPipelineState(renderer.pipelineState)

  var barrier = D3D12_RESOURCE_BARRIER(
    typ: D3D12_RESOURCE_BARRIER_TYPE_TRANSITION,
    Flags: D3D12_RESOURCE_BARRIER_FLAG_NONE,
    Transition: D3D12_RESOURCE_TRANSITION_BARRIER(
      pResource: ctx.renderTargets[ctx.currentFrame],
      Subresource: D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
      StateBefore: D3D12_RESOURCE_STATE_PRESENT,
      StateAfter: D3D12_RESOURCE_STATE_RENDER_TARGET
    )
  )
  ctx.commandList.resourceBarrier(1, addr barrier)
  ctx.commandList.rsSetViewports(1, addr ctx.viewport)
  ctx.commandList.rsSetScissorRects(1, addr ctx.scissor)
  ctx.commandList.omSetRenderTargets(1, addr ctx.rtvHandles[ctx.currentFrame], 1, nil)
  ctx.commandList.clearRenderTargetView(ctx.rtvHandles[ctx.currentFrame], unsafeAddr clearColor[0], 0, nil)

  var heaps = [renderer.srvHeap]
  ctx.commandList.setDescriptorHeaps(1, addr heaps[0])
  ctx.commandList.setGraphicsRoot32BitConstants(0, 4, addr renderer.params[0], 0)
  ctx.commandList.setGraphicsRootDescriptorTable(1, renderer.srvHandleGpu)
  ctx.commandList.iaSetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST)
  ctx.commandList.drawInstanced(vertexCount, 1, 0, 0)

  barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET
  barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT
  ctx.commandList.resourceBarrier(1, addr barrier)

  ctx.commandList.close()

proc shutdown(renderer: var CubeRenderer) =
  if renderer.texture != nil:
    renderer.texture.release()
    renderer.texture = nil
  if renderer.srvHeap != nil:
    renderer.srvHeap.release()
    renderer.srvHeap = nil
  if renderer.pipelineState != nil:
    renderer.pipelineState.release()
    renderer.pipelineState = nil
  if renderer.rootSignature != nil:
    renderer.rootSignature.release()
    renderer.rootSignature = nil

when isMainModule:
  let window = newWindow("DirectX 12 Textured Cube", ivec2(width.int32, height.int32))

  var hwnd: HWND = window.getHWND()
  if hwnd == 0:
    raise newException(Exception, "Failed to acquire HWND from window")

  var ctx: D3D12Context
  ctx.initDevice(hwnd, width, height)

  var renderer: CubeRenderer
  initRenderer(ctx, renderer)

  let aspect = width.float32 / height.float32
  let clearColor = [0.05.FLOAT, 0.05.FLOAT, 0.1.FLOAT, 1.0.FLOAT]
  var timeAcc = 0'f32

  try:
    while not window.closeRequested:
      pollEvents()
      timeAcc += 0.016'f32
      updateConstants(renderer, aspect, timeAcc)
      recordCube(ctx, renderer, clearColor)
      ctx.executeFrame()
  finally:
    renderer.shutdown()
    ctx.cleanup()