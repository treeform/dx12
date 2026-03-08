import
  std/os,
  pixie,
  vmath,
  windy, windy/platforms/win32/windefs,
  dx12, dx12/context

const
  InitialWidth = 1280
  InitialHeight = 800
  SheetCells = 8
  SpriteDrawSize = 24.0'f32
  SpriteDensity = 850.0'f32
  MinSpriteCount = 96
  TextureMaxAnisotropy = 8'u32

type
  SpriteSheetError = object of CatchableError

  SpriteVertex = object
    position: array[2, float32]
    uv: array[2, float32]

  SpriteRenderer = object
    rootSignature: ID3D12RootSignature
    pipelineState: ID3D12PipelineState
    texture: ID3D12Resource
    srvHeap: ID3D12DescriptorHeap
    srvHandleGpu: D3D12_GPU_DESCRIPTOR_HANDLE
    vertexBuffer: ID3D12Resource
    vertexBufferView: D3D12_VERTEX_BUFFER_VIEW
    vertexBufferPtr: pointer
    maxVertexCount: int

  SpriteDrawer = object
    vertices: seq[SpriteVertex]
    viewportSize: IVec2

proc texturePath(): string =
  ## Returns the sprite sheet path beside this example.
  currentSourcePath().parentDir / "testSpriteSheet.png"

proc clampWindowSize(size: IVec2): IVec2 =
  ## Clamps the window size to valid swap chain dimensions.
  ivec2(max(1'i32, size.x), max(1'i32, size.y))

proc spriteCountForSize(size: IVec2): int =
  ## Returns a sprite count scaled by the window area.
  let area = size.x.float32 * size.y.float32
  max(MinSpriteCount, int(area / SpriteDensity))

proc maxVertexCountForSize(size: IVec2): int =
  ## Returns the vertex capacity needed for the current window.
  spriteCountForSize(size) * 6

proc hash32(value: uint32): uint32 =
  ## Returns a small deterministic hash for pseudo-random placement.
  result = value
  result = result xor (result shr 16)
  result *= 0x7feb352d'u32
  result = result xor (result shr 15)
  result *= 0x846ca68b'u32
  result = result xor (result shr 16)

proc random01(seed: uint32): float32 =
  ## Returns a deterministic float in the 0 to 1 range.
  (hash32(seed) and 0x00ff_ffff'u32).float32 / 16_777_215.0'f32

proc randomInt(seed: uint32, limit: int): int =
  ## Returns a deterministic integer in the 0 to limit range.
  if limit <= 0:
    return 0
  int(hash32(seed) mod uint32(limit + 1))

proc uvArray(v: Vec2): array[2, float32] =
  ## Converts a UV vector to a plain array.
  [v.x, v.y]

proc clipArray(p: Vec2): array[2, float32] =
  ## Converts a clip-space vector to a plain array.
  [p.x, p.y]

proc screenToClip(drawer: SpriteDrawer, pos: Vec2): Vec2 =
  ## Converts a pixel-space position into clip space.
  let
    width = max(1.0'f32, drawer.viewportSize.x.float32)
    height = max(1.0'f32, drawer.viewportSize.y.float32)
  vec2(
    (pos.x / width) * 2.0'f32 - 1.0'f32,
    1.0'f32 - (pos.y / height) * 2.0'f32
  )

proc beginDraw(drawer: var SpriteDrawer, viewportSize: IVec2) =
  ## Starts a new sprite batch for the current viewport.
  drawer.viewportSize = clampWindowSize(viewportSize)
  drawer.vertices.setLen(0)

proc pushVertex(drawer: var SpriteDrawer, position, uv: Vec2) =
  ## Appends one sprite vertex to the current batch.
  drawer.vertices.add(
    SpriteVertex(
      position: clipArray(position),
      uv: uvArray(uv)
    )
  )

proc drawQuad(
    drawer: var SpriteDrawer,
    positions: array[4, Vec2],
    uvs: array[4, Vec2]
  ) =
  ## Draws one textured quad into the current batch.
  let clipPositions = [
    drawer.screenToClip(positions[0]),
    drawer.screenToClip(positions[1]),
    drawer.screenToClip(positions[2]),
    drawer.screenToClip(positions[3])
  ]
  drawer.pushVertex(clipPositions[0], uvs[0])
  drawer.pushVertex(clipPositions[1], uvs[1])
  drawer.pushVertex(clipPositions[2], uvs[2])
  drawer.pushVertex(clipPositions[0], uvs[0])
  drawer.pushVertex(clipPositions[2], uvs[2])
  drawer.pushVertex(clipPositions[3], uvs[3])

proc drawIcon(drawer: var SpriteDrawer, icon: IVec2, pos: Vec2) =
  ## Draws one icon from the 8x8 sprite sheet at a pixel position.
  let
    iconSize = vec2(SpriteDrawSize, SpriteDrawSize)
    cellSize = 1.0'f32 / SheetCells.float32
    uvMin = vec2(
      icon.x.float32 * cellSize,
      icon.y.float32 * cellSize
    )
    uvMax = uvMin + vec2(cellSize, cellSize)
    positions = [
      pos,
      pos + vec2(iconSize.x, 0.0'f32),
      pos + iconSize,
      pos + vec2(0.0'f32, iconSize.y)
    ]
    uvs = [
      uvMin,
      vec2(uvMax.x, uvMin.y),
      uvMax,
      vec2(uvMin.x, uvMax.y)
    ]
  drawer.drawQuad(positions, uvs)

proc createVertexBuffer(
    ctx: var D3D12Context,
    renderer: var SpriteRenderer,
    maxVertexCount: int
  ) =
  ## Creates a persistently mapped upload vertex buffer.
  if renderer.vertexBuffer != nil:
    renderer.vertexBuffer.unmap(0, nil)
    renderer.vertexBuffer.release()
    renderer.vertexBuffer = nil
    renderer.vertexBufferPtr = nil

  let vertexBufferSize = UINT64(maxVertexCount * sizeof(SpriteVertex))

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

  var uploadHeap: D3D12_HEAP_PROPERTIES
  zeroMem(addr uploadHeap, sizeof(uploadHeap))
  uploadHeap.typ = D3D12_HEAP_TYPE_UPLOAD
  uploadHeap.CPUPageProperty = 0
  uploadHeap.MemoryPoolPreference = 0
  uploadHeap.CreationNodeMask = 1
  uploadHeap.VisibleNodeMask = 1

  renderer.vertexBuffer = ctx.device.createCommittedResource(
    addr uploadHeap,
    D3D12_HEAP_FLAG_NONE,
    addr bufferDesc,
    D3D12_RESOURCE_STATE_GENERIC_READ,
    nil
  )
  renderer.vertexBuffer.map(0, nil, addr renderer.vertexBufferPtr)
  renderer.maxVertexCount = maxVertexCount
  renderer.vertexBufferView = D3D12_VERTEX_BUFFER_VIEW(
    BufferLocation: renderer.vertexBuffer.getGPUVirtualAddress(),
    SizeInBytes: UINT(vertexBufferSize),
    StrideInBytes: UINT(sizeof(SpriteVertex))
  )

proc buildMipChain(image: Image): seq[Image] =
  ## Builds a full mip chain from the base level down to 1x1.
  result.add(image)
  var current = image
  while current.width > 1 or current.height > 1:
    current = current.minifyBy2()
    result.add(current)

proc uploadTexture(ctx: var D3D12Context, renderer: var SpriteRenderer) =
  ## Loads the sprite sheet PNG and uploads it to a GPU texture.
  if not fileExists(texturePath()):
    raise newException(
      SpriteSheetError,
      "Sprite sheet not found: " & texturePath()
    )

  var image: Image
  try:
    image = readImage(texturePath())
  except PixieError as e:
    raise newException(
      SpriteSheetError,
      "Failed to load sprite sheet: " & e.msg
    )

  let
    mipImages = buildMipChain(image)
    texWidth = mipImages[0].width
    texHeight = mipImages[0].height
    mipCount = mipImages.len
    bytesPerPixel = 4

  var texDesc: D3D12_RESOURCE_DESC
  zeroMem(addr texDesc, sizeof(texDesc))
  texDesc.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D
  texDesc.Alignment = 0
  texDesc.Width = uint64(texWidth)
  texDesc.Height = uint32(texHeight)
  texDesc.DepthOrArraySize = 1
  texDesc.MipLevels = uint16(mipCount)
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

  var footprints = newSeq[D3D12_PLACED_SUBRESOURCE_FOOTPRINT](mipCount)
  var numRows = newSeq[UINT](mipCount)
  var rowSizes = newSeq[UINT64](mipCount)
  var totalBytes: UINT64
  ctx.device.getCopyableFootprints(
    addr texDesc,
    UINT(0),
    UINT(mipCount),
    0'u64,
    addr footprints[0],
    addr numRows[0],
    addr rowSizes[0],
    addr totalBytes
  )

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
  let uploadBase = cast[uint](uploadPtr)
  for i, mipImage in mipImages:
    let
      footprint = footprints[i]
      rowPitch = int(footprint.Footprint.RowPitch)
      rowSize = mipImage.width * bytesPerPixel
    var dst = cast[ptr uint8](uploadBase + uint(footprint.Offset))
    for y in 0 ..< mipImage.height:
      let srcIdx = mipImage.dataIndex(0, y)
      let srcPtr = cast[ptr uint8](mipImage.data[srcIdx].addr)
      copyMem(dst, srcPtr, rowSize)
      if rowPitch > rowSize:
        zeroMem(
          cast[pointer](cast[uint](dst) + uint(rowSize)),
          rowPitch - rowSize
        )
      dst = cast[ptr uint8](cast[uint](dst) + uint(rowPitch))
  uploadBuffer.unmap(0, nil)

  ctx.commandAllocator.reset()
  ctx.commandList.reset(ctx.commandAllocator, nil)
  for i in 0 ..< mipCount:
    var dstLocation = D3D12_TEXTURE_COPY_LOCATION(
      pResource: renderer.texture,
      typ: D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX,
      data: D3D12_TEXTURE_COPY_LOCATION_UNION(
        SubresourceIndex: uint32(i)
      )
    )
    var srcLocation = D3D12_TEXTURE_COPY_LOCATION(
      pResource: uploadBuffer,
      typ: D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT,
      data: D3D12_TEXTURE_COPY_LOCATION_UNION(
        PlacedFootprint: footprints[i]
      )
    )
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
    data: D3D12_SHADER_RESOURCE_VIEW_DESC_UNION(
      Texture2D: D3D12_TEX2D_SRV(
        MostDetailedMip: 0,
        MipLevels: uint32(mipCount),
        PlaneSlice: 0,
        ResourceMinLODClamp: 0.0
      )
    )
  )
  ctx.device.createShaderResourceView(
    renderer.texture,
    addr srvDesc,
    srvCpuHandle
  )

proc initRenderer(
    ctx: var D3D12Context,
    renderer: var SpriteRenderer,
    maxVertexCount: int
  ) =
  ## Creates the sprite pipeline, texture, and dynamic vertex buffer.
  const vertexShaderSrc = """
struct VSInput {
  float2 pos : POSITION;
  float2 uv : TEXCOORD0;
};

struct VSOutput {
  float4 pos : SV_POSITION;
  float2 uv : TEXCOORD0;
};

VSOutput VSMain(VSInput input) {
  VSOutput output;
  output.pos = float4(input.pos, 0.0f, 1.0f);
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

  let
    vsBlob = compileShader(vertexShaderSrc, "VSMain", "vs_5_0")
    psBlob = compileShader(pixelShaderSrc, "PSMain", "ps_5_0")

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
    Filter: D3D12_FILTER_ANISOTROPIC,
    AddressU: D3D12_TEXTURE_ADDRESS_MODE_CLAMP,
    AddressV: D3D12_TEXTURE_ADDRESS_MODE_CLAMP,
    AddressW: D3D12_TEXTURE_ADDRESS_MODE_CLAMP,
    MipLODBias: 0.0,
    MaxAnisotropy: TextureMaxAnisotropy,
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
      Format: DXGI_FORMAT_R32G32_FLOAT,
      InputSlot: 0,
      AlignedByteOffset: 0,
      InputSlotClass: D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA,
      InstanceDataStepRate: 0
    ),
    D3D12_INPUT_ELEMENT_DESC(
      SemanticName: "TEXCOORD",
      SemanticIndex: 0,
      Format: DXGI_FORMAT_R32G32_FLOAT,
      InputSlot: 0,
      AlignedByteOffset: 8,
      InputSlotClass: D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA,
      InstanceDataStepRate: 0
    )
  ]

  var blendDesc: D3D12_BLEND_DESC
  blendDesc.AlphaToCoverageEnable = 0
  blendDesc.IndependentBlendEnable = 0
  blendDesc.RenderTarget[0] = D3D12_RENDER_TARGET_BLEND_DESC(
    BlendEnable: 1,
    LogicOpEnable: 0,
    SrcBlend: D3D12_BLEND_SRC_ALPHA,
    DestBlend: D3D12_BLEND_INV_SRC_ALPHA,
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
      CullMode: D3D12_CULL_MODE_NONE,
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
  createVertexBuffer(ctx, renderer, maxVertexCount)
  uploadTexture(ctx, renderer)

proc recordSprites(
    ctx: var D3D12Context,
    renderer: SpriteRenderer,
    vertexCount: int,
    clearColor: array[4, FLOAT]
  ) =
  ## Records the draw pass for the current sprite batch.
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
  if vertexCount > 0:
    ctx.commandList.drawInstanced(UINT(vertexCount), 1, 0, 0)

  barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET
  barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT
  ctx.commandList.resourceBarrier(1, addr barrier)
  ctx.commandList.close()

proc endDraw(
    drawer: SpriteDrawer,
    ctx: var D3D12Context,
    renderer: SpriteRenderer,
    clearColor: array[4, FLOAT]
  ) =
  ## Uploads the current batch and records the sprite draw.
  if drawer.vertices.len > renderer.maxVertexCount:
    raise newException(
      SpriteSheetError,
      "Sprite batch exceeded dynamic vertex buffer capacity"
    )

  if drawer.vertices.len > 0:
    copyMem(
      renderer.vertexBufferPtr,
      unsafeAddr drawer.vertices[0],
      drawer.vertices.len * sizeof(SpriteVertex)
    )
  recordSprites(ctx, renderer, drawer.vertices.len, clearColor)

proc shutdown(renderer: var SpriteRenderer) =
  ## Releases sprite renderer resources.
  if renderer.vertexBuffer != nil:
    renderer.vertexBuffer.unmap(0, nil)
    renderer.vertexBuffer.release()
    renderer.vertexBuffer = nil
    renderer.vertexBufferPtr = nil
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
  renderer.maxVertexCount = 0

proc ensureVertexCapacity(
    ctx: var D3D12Context,
    renderer: var SpriteRenderer,
    windowSize: IVec2
  ) =
  ## Grows the dynamic sprite buffer when the viewport area increases.
  let size = clampWindowSize(windowSize)
  let requiredVertexCount = maxVertexCountForSize(size)
  if requiredVertexCount > renderer.maxVertexCount:
    createVertexBuffer(ctx, renderer, requiredVertexCount)

when isMainModule:
  let window = newWindow(
    "DirectX 12 Sprite Sheet",
    ivec2(InitialWidth.int32, InitialHeight.int32)
  )

  var hwnd: HWND = window.getHWND()
  if hwnd == 0:
    raise newException(Exception, "Failed to acquire HWND from window")

  var
    ctx: D3D12Context
    renderer: SpriteRenderer
    drawer: SpriteDrawer
    renderSize = clampWindowSize(window.size)
    pendingResize = false
  let clearColor = [0.08.FLOAT, 0.08.FLOAT, 0.1.FLOAT, 1.0.FLOAT]

  window.onResize = proc() =
    pendingResize = true

  ctx.initDevice(hwnd, renderSize.x.int, renderSize.y.int)
  initRenderer(ctx, renderer, maxVertexCountForSize(renderSize))

  try:
    while not window.closeRequested:
      pollEvents()

      let currentSize = clampWindowSize(window.size)
      if pendingResize or currentSize != renderSize:
        renderSize = currentSize
        pendingResize = false
        ctx.resize(renderSize.x.int, renderSize.y.int)
        ensureVertexCapacity(ctx, renderer, renderSize)

      drawer.beginDraw(renderSize)
      let
        spriteCount = spriteCountForSize(renderSize)
        maxX = max(0.0'f32, renderSize.x.float32 - SpriteDrawSize)
        maxY = max(0.0'f32, renderSize.y.float32 - SpriteDrawSize)
        baseSeed =
          uint32(renderSize.x) xor
          (uint32(renderSize.y) shl 16) xor
          0x1357_9bdf'u32

      for i in 0 ..< spriteCount:
        let
          seed = baseSeed + uint32(i) * 0x9e37_79b9'u32
          pos = vec2(
            random01(seed xor 0x68bc_21ebu32) * maxX,
            random01(seed xor 0x02e5_be93u32) * maxY
          )
          icon = ivec2(
            randomInt(seed xor 0xa5a5_1021'u32, SheetCells - 1).int32,
            randomInt(seed xor 0x1f12_4bb5'u32, SheetCells - 1).int32
          )
        drawer.drawIcon(icon, pos)

      drawer.endDraw(ctx, renderer, clearColor)
      let latestSize = clampWindowSize(window.size)
      if pendingResize or latestSize != renderSize:
        renderSize = latestSize
        pendingResize = false
        ctx.resize(renderSize.x.int, renderSize.y.int)
        ensureVertexCapacity(ctx, renderer, renderSize)
        continue

      try:
        ctx.executeFrame()
      except Exception:
        renderSize = clampWindowSize(window.size)
        pendingResize = false
        ctx.resize(renderSize.x.int, renderSize.y.int)
        ensureVertexCapacity(ctx, renderer, renderSize)
        continue
  finally:
    renderer.shutdown()
    ctx.cleanup()
