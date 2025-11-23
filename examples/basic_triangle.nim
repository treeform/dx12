import 
  windy, windy/platforms/win32/windefs,
  dx12, dx12/context

template triangleLog(msg: string) =
  echo "[basic_triangle] " & msg

type
  TriangleRenderer = object
    rootSignature: ID3D12RootSignature
    pipelineState: ID3D12PipelineState
    positionBuffer: ID3D12Resource
    colorBuffer: ID3D12Resource
    positionBufferView: D3D12_VERTEX_BUFFER_VIEW
    colorBufferView: D3D12_VERTEX_BUFFER_VIEW

proc createUploadBuffer(
    ctx: var D3D12Context,
    name: string,
    src: openArray[FLOAT],
    stride: UINT,
    outResource: var ID3D12Resource,
    outView: var D3D12_VERTEX_BUFFER_VIEW
  ) =
  loadNativeSymbols()
  let dataBytes = UINT64(src.len * sizeof(FLOAT))
  let cpuBytes = csize_t(src.len * sizeof(FLOAT))
  triangleLog("Allocating " & name & " buffer (" & $dataBytes & " bytes)")
  triangleLog("Heap struct size=" & $sizeof(D3D12_HEAP_PROPERTIES) & " desc size=" & $sizeof(D3D12_RESOURCE_DESC))

  var bufferDesc: D3D12_RESOURCE_DESC
  zeroMem(addr bufferDesc, sizeof(bufferDesc))
  bufferDesc.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER
  bufferDesc.Alignment = 0
  bufferDesc.Width = dataBytes
  bufferDesc.Height = 1
  bufferDesc.DepthOrArraySize = 1
  bufferDesc.MipLevels = 1
  bufferDesc.Format = DXGI_FORMAT_UNKNOWN
  bufferDesc.SampleDesc = DXGI_SAMPLE_DESC(Count: 1, Quality: 0)
  bufferDesc.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR
  bufferDesc.Flags = D3D12_RESOURCE_FLAG_NONE

  var heapProps: D3D12_HEAP_PROPERTIES
  zeroMem(addr heapProps, sizeof(heapProps))
  heapProps.typ = D3D12_HEAP_TYPE_UPLOAD
  heapProps.CreationNodeMask = 1
  heapProps.VisibleNodeMask = 1

  let heapAddr = cast[uint](addr heapProps)
  let descAddr = cast[uint](addr bufferDesc)
  triangleLog("heapAddr mod8=" & $(heapAddr mod 8) & " descAddr mod8=" & $(descAddr mod 8))
  triangleLog("Heap type=" & $heapProps.typ & " CPUPageProperty=" & $heapProps.CPUPageProperty & " MemoryPool=" & $heapProps.MemoryPoolPreference)
  triangleLog("Heap offsets type=" & $(cast[uint](addr heapProps.typ) - heapAddr) &
    " cpu=" & $(cast[uint](addr heapProps.CPUPageProperty) - heapAddr) &
    " pool=" & $(cast[uint](addr heapProps.MemoryPoolPreference) - heapAddr) &
    " createMask=" & $(cast[uint](addr heapProps.CreationNodeMask) - heapAddr) &
    " visibleMask=" & $(cast[uint](addr heapProps.VisibleNodeMask) - heapAddr))
  triangleLog("Desc dim=" & $bufferDesc.Dimension & " width=" & $bufferDesc.Width & " height=" & $bufferDesc.Height & " layout=" & $bufferDesc.Layout)
  triangleLog("Offsets dim=" & $(cast[uint](addr bufferDesc.Dimension) - descAddr) &
    " align=" & $(cast[uint](addr bufferDesc.Alignment) - descAddr) &
    " width=" & $(cast[uint](addr bufferDesc.Width) - descAddr) &
    " height=" & $(cast[uint](addr bufferDesc.Height) - descAddr) &
    " depth=" & $(cast[uint](addr bufferDesc.DepthOrArraySize) - descAddr) &
    " mip=" & $(cast[uint](addr bufferDesc.MipLevels) - descAddr) &
    " format=" & $(cast[uint](addr bufferDesc.Format) - descAddr) &
    " sample=" & $(cast[uint](addr bufferDesc.SampleDesc) - descAddr) &
    " layoutOff=" & $(cast[uint](addr bufferDesc.Layout) - descAddr) &
    " flags=" & $(cast[uint](addr bufferDesc.Flags) - descAddr))

  outResource = ctx.device.createCommittedResource(
    addr heapProps,
    D3D12_HEAP_FLAG_NONE,
    addr bufferDesc,
    D3D12_RESOURCE_STATE_GENERIC_READ,
    nil
  )

  var mapped: pointer
  outResource.map(0, nil, addr mapped)
  if src.len > 0:
    copyMem(mapped, unsafeAddr src[0], cpuBytes)
  outResource.unmap(0, nil)

  outView = D3D12_VERTEX_BUFFER_VIEW(
    BufferLocation: outResource.getGPUVirtualAddress(),
    SizeInBytes: UINT(dataBytes),
    StrideInBytes: stride
  )
  triangleLog(name & " buffer uploaded")

proc initRenderer(ctx: var D3D12Context, renderer: var TriangleRenderer) =
  triangleLog("Initializing renderer with dedicated vertex buffers")

  const vertexShaderSrc = """
struct VSInput { float3 pos : POSITION; float3 col : COLOR; };
struct VSOutput { float4 pos : SV_POSITION; float3 col : COLOR; };
VSOutput VSMain(VSInput input) {
  VSOutput output;
  output.pos = float4(input.pos, 1.0f);
  output.col = input.col;
  return output;
}
"""

  const pixelShaderSrc = """
struct PSInput { float4 pos : SV_POSITION; float3 col : COLOR; };
float4 PSMain(PSInput input) : SV_TARGET {
  return float4(input.col, 1.0);
}
"""

  triangleLog("Compiling shaders")
  let vsBlob = compileShader(vertexShaderSrc, "VSMain", "vs_5_0")
  let psBlob = compileShader(pixelShaderSrc, "PSMain", "ps_5_0")
  triangleLog("Shaders compiled successfully")

  var rootDesc = D3D12_ROOT_SIGNATURE_DESC(
    NumParameters: 0,
    pParameters: nil,
    NumStaticSamplers: 0,
    pStaticSamplers: nil,
    Flags: D3D12_ROOT_SIGNATURE_FLAG_ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT
  )
  triangleLog("Serializing root signature")
  let rootBlob = serializeRootSignature(addr rootDesc)
  renderer.rootSignature = ctx.device.createRootSignature(0, getBufferPointer(rootBlob), getBufferSize(rootBlob))
  triangleLog("Root signature created")
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

  var inputElements = [
    D3D12_INPUT_ELEMENT_DESC(
      SemanticName: cstring"POSITION",
      SemanticIndex: 0,
      Format: DXGI_FORMAT_R32G32B32_FLOAT,
      InputSlot: 0,
      AlignedByteOffset: 0,
      InputSlotClass: D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA,
      InstanceDataStepRate: 0
    ),
    D3D12_INPUT_ELEMENT_DESC(
      SemanticName: cstring"COLOR",
      SemanticIndex: 0,
      Format: DXGI_FORMAT_R32G32B32_FLOAT,
      InputSlot: 1,
      AlignedByteOffset: 0,
      InputSlotClass: D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA,
      InstanceDataStepRate: 0
    )
  ]

  var inputLayout = D3D12_INPUT_LAYOUT_DESC(
    pInputElementDescs: addr inputElements[0],
    NumElements: inputElements.len.uint32
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
    InputLayout: inputLayout,
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

  triangleLog("Creating pipeline state object")
  renderer.pipelineState = ctx.device.createGraphicsPipelineState(addr psoDesc)
  triangleLog("Pipeline state created")

  let positions = [
    0.0f32, 0.5f32, 0.0f32,
    0.5f32, -0.5f32, 0.0f32,
    -0.5f32, -0.5f32, 0.0f32
  ]
  let colors = [
    1.0f32, 0.0f32, 0.0f32,
    0.0f32, 1.0f32, 0.0f32,
    0.0f32, 0.0f32, 1.0f32
  ]
  let strideBytes = UINT(3 * sizeof(FLOAT))
  createUploadBuffer(ctx, "position", positions, strideBytes, renderer.positionBuffer, renderer.positionBufferView)
  createUploadBuffer(ctx, "color", colors, strideBytes, renderer.colorBuffer, renderer.colorBufferView)
  triangleLog("Vertex buffers ready")

  release(vsBlob)
  release(psBlob)

proc recordTriangle(ctx: var D3D12Context, renderer: TriangleRenderer, clearColor: array[4, FLOAT]) =
  triangleLog("Recording triangle command list for frame " & $ctx.currentFrame)
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

  var vertexViews = [renderer.positionBufferView, renderer.colorBufferView]
  ctx.commandList.iaSetVertexBuffers(0, UINT(vertexViews.len), addr vertexViews[0])
  triangleLog("Vertex buffers bound to pipeline")

  ctx.commandList.iaSetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST)
  ctx.commandList.drawInstanced(3, 1, 0, 0)
  triangleLog("Draw call encoded")

  barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET
  barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT
  ctx.commandList.resourceBarrier(1, addr barrier)

  ctx.commandList.close()
  triangleLog("Command list closed")

proc shutdown(renderer: var TriangleRenderer) =
  if renderer.positionBuffer != nil:
    triangleLog("Releasing position buffer")
    renderer.positionBuffer.release()
    renderer.positionBuffer = nil
  if renderer.colorBuffer != nil:
    triangleLog("Releasing color buffer")
    renderer.colorBuffer.release()
    renderer.colorBuffer = nil
  if renderer.pipelineState != nil:
    triangleLog("Releasing pipeline state")
    renderer.pipelineState.release()
    renderer.pipelineState = nil
  if renderer.rootSignature != nil:
    triangleLog("Releasing root signature")
    renderer.rootSignature.release()
    renderer.rootSignature = nil

const
  width = 1280
  height = 800

when isMainModule:
  triangleLog("Launching DirectX 12 Basic Triangle demo")
  let window = newWindow("DirectX 12 Basic Triangle", ivec2(width.int32, height.int32))
  triangleLog("Window created, waiting for HWND")

  var hwnd: HWND = window.getHWND()
  if hwnd == 0:
    raise newException(Exception, "Failed to acquire HWND from window")
  triangleLog("Received HWND: " & $hwnd)

  var ctx: D3D12Context
  ctx.initDevice(hwnd, width, height)
  triangleLog("D3D12 context initialized")

  var renderer: TriangleRenderer
  initRenderer(ctx, renderer)
  triangleLog("Renderer initialized")

  let clearColor = [0.05.FLOAT, 0.05.FLOAT, 0.1.FLOAT, 1.0.FLOAT]
  triangleLog("Entering render loop")

  try:
    while not window.closeRequested:
      pollEvents()
      recordTriangle(ctx, renderer, clearColor)
      ctx.executeFrame()
    triangleLog("Render loop exited normally")
  finally:
    triangleLog("Beginning shutdown sequence")
    renderer.shutdown()
    ctx.cleanup()
    triangleLog("Shutdown complete")