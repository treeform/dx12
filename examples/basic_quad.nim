import
  std/[os, syncio],
  pixie, pixie/fileformats/png,
  windy, windy/platforms/win32/windefs,
  dx12, dx12/context

type
  QuadVertex = object
    position: array[3, float32]
    color: array[3, float32]
    uv: array[2, float32]

  QuadRenderer = object
    rootSignature: ID3D12RootSignature
    pipelineState: ID3D12PipelineState
    vertexBuffer: ID3D12Resource
    vertexBufferView: D3D12_VERTEX_BUFFER_VIEW
    texture: ID3D12Resource
    srvHeap: ID3D12DescriptorHeap
    srvHandleGpu: D3D12_GPU_DESCRIPTOR_HANDLE

const
  TexturePath = "examples/testTexture.png"
  TextureSize = 128
  QuadVertices = [
    QuadVertex(
      position: [-0.5'f, 0.5'f, 0.0'f],
      color: [1.0'f, 0.0'f, 0.0'f],
      uv: [0.0'f, 0.0'f]
    ),
    QuadVertex(
      position: [0.5'f, 0.5'f, 0.0'f],
      color: [0.0'f, 1.0'f, 0.0'f],
      uv: [1.0'f, 0.0'f]
    ),
    QuadVertex(
      position: [0.5'f, -0.5'f, 0.0'f],
      color: [0.0'f, 0.0'f, 1.0'f],
      uv: [1.0'f, 1.0'f]
    ),
    QuadVertex(
      position: [-0.5'f, 0.5'f, 0.0'f],
      color: [1.0'f, 0.0'f, 0.0'f],
      uv: [0.0'f, 0.0'f]
    ),
    QuadVertex(
      position: [0.5'f, -0.5'f, 0.0'f],
      color: [0.0'f, 0.0'f, 1.0'f],
      uv: [1.0'f, 1.0'f]
    ),
    QuadVertex(
      position: [-0.5'f, -0.5'f, 0.0'f],
      color: [1.0'f, 1.0'f, 0.0'f],
      uv: [0.0'f, 1.0'f]
    )
  ]

proc createVertexBuffer(ctx: var D3D12Context, renderer: var QuadRenderer) =
  let vertexBufferSize = UINT64(sizeof(QuadVertices))

  var bufferDesc: D3D12_RESOURCE_DESC
  zeroMem(addr bufferDesc, sizeof(bufferDesc))
  bufferDesc.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER
  bufferDesc.Alignment = 0
  bufferDesc.Width = vertexBufferSize
  bufferDesc.Height = 1
  bufferDesc.DepthOrArraySize = 1
  bufferDesc.MipLevels = 1
  bufferDesc.Format = DXGI_FORMAT_UNKNOWN
  bufferDesc.SampleDesc = DXGI_SAMPLE_DESC(Count: 1, Quality: 0)
  bufferDesc.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR
  bufferDesc.Flags = D3D12_RESOURCE_FLAG_NONE

  var defaultHeap: D3D12_HEAP_PROPERTIES
  zeroMem(addr defaultHeap, sizeof(defaultHeap))
  defaultHeap.typ = D3D12_HEAP_TYPE_DEFAULT
  defaultHeap.CPUPageProperty = 0
  defaultHeap.MemoryPoolPreference = 0
  defaultHeap.CreationNodeMask = 1
  defaultHeap.VisibleNodeMask = 1

  var uploadHeap: D3D12_HEAP_PROPERTIES
  zeroMem(addr uploadHeap, sizeof(uploadHeap))
  uploadHeap.typ = D3D12_HEAP_TYPE_UPLOAD
  uploadHeap.CPUPageProperty = 0
  uploadHeap.MemoryPoolPreference = 0
  uploadHeap.CreationNodeMask = 1
  uploadHeap.VisibleNodeMask = 1

  renderer.vertexBuffer = ctx.device.createCommittedResource(
    addr defaultHeap,
    D3D12_HEAP_FLAG_NONE,
    addr bufferDesc,
    D3D12_RESOURCE_STATE_COPY_DEST,
    nil
  )

  let uploadBuffer = ctx.device.createCommittedResource(
    addr uploadHeap,
    D3D12_HEAP_FLAG_NONE,
    addr bufferDesc,
    D3D12_RESOURCE_STATE_GENERIC_READ,
    nil
  )

  var uploadPtr: pointer
  uploadBuffer.map(0, nil, addr uploadPtr)
  copyMem(uploadPtr, unsafeAddr QuadVertices[0], sizeof(QuadVertices))
  uploadBuffer.unmap(0, nil)

  ctx.commandAllocator.reset()
  ctx.commandList.reset(ctx.commandAllocator, nil)
  ctx.commandList.copyBufferRegion(
    renderer.vertexBuffer,
    0,
    uploadBuffer,
    0,
    vertexBufferSize
  )

  var barrier = D3D12_RESOURCE_BARRIER(
    typ: D3D12_RESOURCE_BARRIER_TYPE_TRANSITION,
    Flags: D3D12_RESOURCE_BARRIER_FLAG_NONE,
    data: D3D12_RESOURCE_BARRIER_union(
      Transition: D3D12_RESOURCE_TRANSITION_BARRIER(
        pResource: renderer.vertexBuffer,
        Subresource: D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
        StateBefore: D3D12_RESOURCE_STATE_COPY_DEST,
        StateAfter: D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER
      )
    )
  )
  ctx.commandList.resourceBarrier(1, addr barrier)
  ctx.commandList.close()

  var cmdList = cast[ID3D12CommandList](ctx.commandList)
  ctx.commandQueue.executeCommandLists(1, addr cmdList)
  ctx.waitForGpu()
  uploadBuffer.release()

  renderer.vertexBufferView = D3D12_VERTEX_BUFFER_VIEW(
    BufferLocation: renderer.vertexBuffer.getGPUVirtualAddress(),
    SizeInBytes: UINT(vertexBufferSize),
    StrideInBytes: UINT(sizeof(QuadVertex))
  )

proc ensureTextureFile() =
  if fileExists(TexturePath):
    return

  var pixels = newSeq[uint8](TextureSize * TextureSize * 4)
  for y in 0 ..< TextureSize:
    for x in 0 ..< TextureSize:
      let
        pixelIndex = (y * TextureSize + x) * 4
        tileColor =
          if ((x div 16) + (y div 16)) mod 2 == 0:
            [255'u8, 255'u8, 255'u8]
          else:
            [32'u8, 128'u8, 255'u8]
      pixels[pixelIndex + 0] = tileColor[0]
      pixels[pixelIndex + 1] = tileColor[1]
      pixels[pixelIndex + 2] = tileColor[2]
      pixels[pixelIndex + 3] = 255

  let encoded = encodePng(
    TextureSize,
    TextureSize,
    4,
    addr pixels[0],
    pixels.len
  )
  writeFile(TexturePath, encoded)

proc uploadTexture(ctx: var D3D12Context, renderer: var QuadRenderer) =
  ensureTextureFile()

  var image: Image
  try:
    image = readImage(TexturePath)
  except PixieError as e:
    raise newException(Exception, "Failed to load texture: " & e.msg)

  let
    texWidth = image.width
    texHeight = image.height
    bytesPerPixel = 4
    rowSize = texWidth * bytesPerPixel

  var texDesc: D3D12_RESOURCE_DESC
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

  renderer.texture = ctx.device.createCommittedResource(
    addr defaultHeap,
    D3D12_HEAP_FLAG_NONE,
    addr texDesc,
    D3D12_RESOURCE_STATE_COPY_DEST,
    nil
  )

  var
    footprint: D3D12_PLACED_SUBRESOURCE_FOOTPRINT
    numRows: UINT
    rowSizeInBytes: UINT64
    totalBytes: UINT64
  ctx.device.getCopyableFootprints(
    addr texDesc,
    UINT(0),
    UINT(1),
    0'u64,
    addr footprint,
    addr numRows,
    addr rowSizeInBytes,
    addr totalBytes
  )
  let rowPitch = int(footprint.Footprint.RowPitch)

  var uploadDesc: D3D12_RESOURCE_DESC
  zeroMem(addr uploadDesc, sizeof(uploadDesc))
  uploadDesc.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER
  uploadDesc.Alignment = 0
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
      zeroMem(
        cast[pointer](cast[uint](dst) + uint(rowSize)),
        rowPitch - rowSize
      )
    dst = cast[ptr uint8](cast[uint](dst) + uint(rowPitch))
  uploadBuffer.unmap(0, nil)

  var dstLocation = D3D12_TEXTURE_COPY_LOCATION(
    pResource: renderer.texture,
    typ: D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX,
    data: D3D12_TEXTURE_COPY_LOCATION_union(
      SubresourceIndex: 0
    )
  )
  var srcLocation = D3D12_TEXTURE_COPY_LOCATION(
    pResource: uploadBuffer,
    typ: D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT,
    data: D3D12_TEXTURE_COPY_LOCATION_union(
      PlacedFootprint: footprint
    )
  )

  ctx.commandAllocator.reset()
  ctx.commandList.reset(ctx.commandAllocator, nil)
  ctx.commandList.copyTextureRegion(
    addr dstLocation,
    0,
    0,
    0,
    addr srcLocation,
    nil
  )

  var barrier = D3D12_RESOURCE_BARRIER(
    typ: D3D12_RESOURCE_BARRIER_TYPE_TRANSITION,
    Flags: D3D12_RESOURCE_BARRIER_FLAG_NONE,
    data: D3D12_RESOURCE_BARRIER_union(
      Transition: D3D12_RESOURCE_TRANSITION_BARRIER(
        pResource: renderer.texture,
        Subresource: D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
        StateBefore: D3D12_RESOURCE_STATE_COPY_DEST,
        StateAfter: D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE
      )
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
    data: D3D12_SHADER_RESOURCE_VIEW_DESC_UNION(
      Texture2D: D3D12_TEX2D_SRV(
        MostDetailedMip: 0,
        MipLevels: 1,
        PlaneSlice: 0,
        ResourceMinLODClamp: 0.0
      )
    )
  )
  ctx.device.createShaderResourceView(renderer.texture, addr srvDesc, srvCpuHandle)

proc initRenderer(ctx: var D3D12Context, renderer: var QuadRenderer) =
  const vertexShaderSrc = """
struct VSInput {
  float3 pos : POSITION;
  float3 col : COLOR;
  float2 uv : TEXCOORD0;
};

struct VSOutput {
  float4 pos : SV_POSITION;
  float2 uv : TEXCOORD0;
};

VSOutput VSMain(VSInput input) {
  VSOutput output;
  output.pos = float4(input.pos, 1.0f);
  output.uv = input.uv;
  return output;
}
"""

  const pixelShaderSrc = """
Texture2D tex0 : register(t0);
SamplerState samp0 : register(s0);

struct PSInput {
  float4 pos : SV_POSITION;
  float2 uv : TEXCOORD0;
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
  renderer.rootSignature = ctx.device.createRootSignature(
    0,
    getBufferPointer(rootBlob),
    getBufferSize(rootBlob)
  )
  release(rootBlob)

  var inputElements = [
    D3D12_INPUT_ELEMENT_DESC(
      SemanticName: "POSITION",
      SemanticIndex: 0,
      Format: DXGI_FORMAT_R32G32B32_FLOAT,
      InputSlot: 0,
      AlignedByteOffset: 0,
      InputSlotClass: D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA,
      InstanceDataStepRate: 0
    ),
    D3D12_INPUT_ELEMENT_DESC(
      SemanticName: "COLOR",
      SemanticIndex: 0,
      Format: DXGI_FORMAT_R32G32B32_FLOAT,
      InputSlot: 0,
      AlignedByteOffset: 12,
      InputSlotClass: D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA,
      InstanceDataStepRate: 0
    ),
    D3D12_INPUT_ELEMENT_DESC(
      SemanticName: "TEXCOORD",
      SemanticIndex: 0,
      Format: DXGI_FORMAT_R32G32_FLOAT,
      InputSlot: 0,
      AlignedByteOffset: 24,
      InputSlotClass: D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA,
      InstanceDataStepRate: 0
    )
  ]

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
    InputLayout: D3D12_INPUT_LAYOUT_DESC(
      pInputElementDescs: addr inputElements[0],
      NumElements: uint32(inputElements.len)
    ),
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
  createVertexBuffer(ctx, renderer)
  uploadTexture(ctx, renderer)

proc recordQuad(
    ctx: var D3D12Context,
    renderer: QuadRenderer,
    clearColor: array[4, FLOAT]
  ) =
  ctx.commandAllocator.reset()
  ctx.commandList.reset(ctx.commandAllocator, renderer.pipelineState)
  ctx.commandList.setGraphicsRootSignature(renderer.rootSignature)
  ctx.commandList.setPipelineState(renderer.pipelineState)

  var barrier = D3D12_RESOURCE_BARRIER(
    typ: D3D12_RESOURCE_BARRIER_TYPE_TRANSITION,
    Flags: D3D12_RESOURCE_BARRIER_FLAG_NONE,
    data: D3D12_RESOURCE_BARRIER_union(
      Transition: D3D12_RESOURCE_TRANSITION_BARRIER(
        pResource: ctx.renderTargets[ctx.currentFrame],
        Subresource: D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
        StateBefore: D3D12_RESOURCE_STATE_PRESENT,
        StateAfter: D3D12_RESOURCE_STATE_RENDER_TARGET
      )
    )
  )
  ctx.commandList.resourceBarrier(1, addr barrier)
  ctx.commandList.rsSetViewports(1, addr ctx.viewport)
  ctx.commandList.rsSetScissorRects(1, addr ctx.scissor)
  ctx.commandList.omSetRenderTargets(
    1,
    addr ctx.rtvHandles[ctx.currentFrame],
    1,
    nil
  )
  ctx.commandList.clearRenderTargetView(
    ctx.rtvHandles[ctx.currentFrame],
    unsafeAddr clearColor[0],
    0,
    nil
  )

  var heaps = [renderer.srvHeap]
  ctx.commandList.setDescriptorHeaps(1, addr heaps[0])
  ctx.commandList.setGraphicsRootDescriptorTable(0, renderer.srvHandleGpu)
  ctx.commandList.iaSetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST)
  ctx.commandList.iaSetVertexBuffers(0, 1, unsafeAddr renderer.vertexBufferView)
  ctx.commandList.drawInstanced(UINT(QuadVertices.len), 1, 0, 0)

  barrier.data.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET
  barrier.data.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT
  ctx.commandList.resourceBarrier(1, addr barrier)

  ctx.commandList.close()

proc shutdown(renderer: var QuadRenderer) =
  if renderer.texture != nil:
    renderer.texture.release()
    renderer.texture = nil
  if renderer.srvHeap != nil:
    renderer.srvHeap.release()
    renderer.srvHeap = nil
  if renderer.vertexBuffer != nil:
    renderer.vertexBuffer.release()
    renderer.vertexBuffer = nil
  if renderer.pipelineState != nil:
    renderer.pipelineState.release()
    renderer.pipelineState = nil
  if renderer.rootSignature != nil:
    renderer.rootSignature.release()
    renderer.rootSignature = nil

const
  Width = 1280
  Height = 800

when isMainModule:
  let window = newWindow(
    "DirectX 12 Textured Quad",
    ivec2(Width.int32, Height.int32)
  )

  var hwnd: HWND = window.getHWND()
  if hwnd == 0:
    raise newException(Exception, "Failed to acquire HWND from window")

  var ctx: D3D12Context
  ctx.initDevice(hwnd, Width, Height)

  var renderer: QuadRenderer
  initRenderer(ctx, renderer)

  let clearColor = [0.05.FLOAT, 0.05.FLOAT, 0.1.FLOAT, 1.0.FLOAT]

  try:
    while not window.closeRequested:
      pollEvents()
      recordQuad(ctx, renderer, clearColor)
      ctx.executeFrame()
  finally:
    renderer.shutdown()
    ctx.cleanup()
