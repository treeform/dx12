import
  windy,
  dx12, dx12/context

type
  TriangleRenderer = object
    rootSignature: ID3D12RootSignature
    pipelineState: ID3D12PipelineState

proc initRenderer(ctx: var D3D12Context, renderer: var TriangleRenderer) =
  const vertexShaderSrc = """
struct VSOutput { float4 pos : SV_POSITION; float3 col : COLOR; };
VSOutput VSMain(uint vid : SV_VertexID) {
  float3 positions[3] = {
    float3(0.0f, 0.5f, 0.0f),
    float3(0.5f, -0.5f, 0.0f),
    float3(-0.5f, -0.5f, 0.0f)
  };
  float3 colors[3] = {
    float3(1.0f, 0.0f, 0.0f),
    float3(0.0f, 1.0f, 0.0f),
    float3(0.0f, 0.0f, 1.0f)
  };
  VSOutput output;
  output.pos = float4(positions[vid], 1.0f);
  output.col = colors[vid];
  return output;
}
"""

  const pixelShaderSrc = """
struct PSInput { float4 pos : SV_POSITION; float3 col : COLOR; };
float4 PSMain(PSInput input) : SV_TARGET {
  return float4(input.col, 1.0);
}
"""

  let
    vsBlob = compileShader(vertexShaderSrc, "VSMain", "vs_5_0")
    psBlob = compileShader(pixelShaderSrc, "PSMain", "ps_5_0")

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
      pInputElementDescs: nil,
      NumElements: 0
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

proc recordTriangle(ctx: var D3D12Context, renderer: TriangleRenderer, clearColor: array[4, FLOAT]) =
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
  ctx.commandList.omSetRenderTargets(1, addr ctx.rtvHandles[ctx.currentFrame], 1, nil)
  ctx.commandList.clearRenderTargetView(ctx.rtvHandles[ctx.currentFrame], unsafeAddr clearColor[0], 0, nil)

  ctx.commandList.iaSetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST)
  ctx.commandList.drawInstanced(3, 1, 0, 0)

  barrier.data.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET
  barrier.data.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT
  ctx.commandList.resourceBarrier(1, addr barrier)

  ctx.commandList.close()

proc shutdown(renderer: var TriangleRenderer) =
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
  let window = newWindow("DirectX 12 Basic Triangle", ivec2(Width.int32, Height.int32))

  var hwnd: HWND = window.getHWND()
  if hwnd == 0:
    raise newException(Exception, "Failed to acquire HWND from window")

  var ctx: D3D12Context
  ctx.initDevice(hwnd, Width, Height)

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
