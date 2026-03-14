import
  windy, windy/platforms/win32/windefs,
  dx12, dx12/context

type
  TriangleVertex = object
    position: array[3, float32]
    color: array[3, float32]

  TriangleRenderer = object
    rootSignature: ID3D12RootSignature
    pipelineState: ID3D12PipelineState
    vertexBuffer: ID3D12Resource
    vertexBufferView: D3D12_VERTEX_BUFFER_VIEW

const
  TriangleVertices = [
    TriangleVertex(
      position: [0.0'f32, 0.5'f32, 0.0'f32],
      color: [1.0'f32, 0.0'f32, 0.0'f32]
    ),
    TriangleVertex(
      position: [0.5'f32, -0.5'f32, 0.0'f32],
      color: [0.0'f32, 1.0'f32, 0.0'f32]
    ),
    TriangleVertex(
      position: [-0.5'f32, -0.5'f32, 0.0'f32],
      color: [0.0'f32, 0.0'f32, 1.0'f32]
    )
  ]

proc createVertexBuffer(ctx: var D3D12Context, renderer: var TriangleRenderer) =
  let vertexBufferSize = UINT64(sizeof(TriangleVertices))

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
  copyMem(uploadPtr, unsafeAddr TriangleVertices[0], sizeof(TriangleVertices))
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
    Transition: D3D12_RESOURCE_TRANSITION_BARRIER(
      pResource: renderer.vertexBuffer,
      Subresource: D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
      StateBefore: D3D12_RESOURCE_STATE_COPY_DEST,
      StateAfter: D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER
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
    StrideInBytes: UINT(sizeof(TriangleVertex))
  )

proc initRenderer(ctx: var D3D12Context, renderer: var TriangleRenderer) =
  const vertexShaderSrc = """
struct VSInput {
  float3 pos : POSITION;
  float3 col : COLOR;
};

struct VSOutput {
  float4 pos : SV_POSITION;
  float3 col : COLOR;
};

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
  return float4(input.col, 1.0f);
}
"""

  let vsBlob = compileShader(vertexShaderSrc, "VSMain", "vs_5_0")
  let psBlob = compileShader(pixelShaderSrc, "PSMain", "ps_5_0")

  var rootDesc = D3D12_ROOT_SIGNATURE_DESC(
    NumParameters: 0,
    pParameters: nil,
    NumStaticSamplers: 0,
    pStaticSamplers: nil,
    Flags: D3D12_ROOT_SIGNATURE_FLAG_ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT
  )
  let rootBlob = serializeRootSignature(addr rootDesc)
  renderer.rootSignature = ctx.device.createRootSignature(0, getBufferPointer(rootBlob), getBufferSize(rootBlob))
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

proc recordTriangle(ctx: var D3D12Context, renderer: TriangleRenderer, clearColor: array[4, FLOAT]) =
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

  ctx.commandList.iaSetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST)
  ctx.commandList.iaSetVertexBuffers(0, 1, unsafeAddr renderer.vertexBufferView)
  ctx.commandList.drawInstanced(3, 1, 0, 0)

  barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET
  barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT
  ctx.commandList.resourceBarrier(1, addr barrier)

  ctx.commandList.close()

proc shutdown(renderer: var TriangleRenderer) =
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
  width = 1280
  height = 800

when isMainModule:
  let window = newWindow("DirectX 12 Basic Triangle", ivec2(width.int32, height.int32))

  var hwnd: HWND = window.getHWND()
  if hwnd == 0:
    raise newException(Exception, "Failed to acquire HWND from window")

  var ctx: D3D12Context
  ctx.initDevice(hwnd, width, height)

  var renderer: TriangleRenderer
  initRenderer(ctx, renderer)

  let clearColor = [0.05.FLOAT, 0.05.FLOAT, 0.1.FLOAT, 1.0.FLOAT]

  try:
    while not window.closeRequested:
      pollEvents()
      recordTriangle(ctx, renderer, clearColor)
      ctx.executeFrame()
  finally:
    renderer.shutdown()
    ctx.cleanup()
