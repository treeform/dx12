import
  std/[math, os, strutils],
  vmath,
  windy, windy/platforms/win32/windefs,
  dx12, dx12/context

const
  Width = 1280
  Height = 800
  RotateScale = 0.01'f32
  ZoomScale = 0.2'f32
  MinDistance = 1.0'f32
  MaxDistance = 8.0'f32
  MinPitch = -1.45'f32
  MaxPitch = 1.45'f32

type
  ViewerObjError = object of CatchableError

  ObjVertex = object
    position: array[3, float32]
    normal: array[3, float32]

  ObjMesh = object
    vertices: seq[ObjVertex]

  CameraState = object
    yaw: float32
    pitch: float32
    distance: float32

  ObjRenderer = object
    rootSignature: ID3D12RootSignature
    pipelineState: ID3D12PipelineState
    vertexBuffer: ID3D12Resource
    vertexBufferView: D3D12_VERTEX_BUFFER_VIEW
    depthBuffer: ID3D12Resource
    dsvHeap: ID3D12DescriptorHeap
    dsvHandle: D3D12_CPU_DESCRIPTOR_HANDLE
    transform: array[32, float32]
    vertexCount: UINT

proc objPath(): string =
  ## Returns the Stanford bunny path beside this example.
  currentSourcePath().parentDir / "bunny.obj"

proc identityMatrix(): Mat4 =
  ## Returns an identity matrix.
  gmat4[float32](
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
  )

proc perspectiveDx(
    fovY,
    aspect,
    nearPlane,
    farPlane: float32
  ): Mat4 =
  ## Returns a DirectX clip-space projection matrix.
  let
    h = 1.0'f32 / tan(fovY * 0.5'f32)
    w = h / aspect
    depth = farPlane - nearPlane
  result[0, 0] = w
  result[0, 1] = 0
  result[0, 2] = 0
  result[0, 3] = 0
  result[1, 0] = 0
  result[1, 1] = h
  result[1, 2] = 0
  result[1, 3] = 0
  result[2, 0] = 0
  result[2, 1] = 0
  result[2, 2] = farPlane / depth
  result[2, 3] = 1
  result[3, 0] = 0
  result[3, 1] = 0
  result[3, 2] = -(nearPlane * farPlane) / depth
  result[3, 3] = 0

proc mat4ToArray(matrix: Mat4): array[16, float32] =
  ## Flattens a matrix in vmath's column-major order.
  var index = 0
  for i in 0 ..< 4:
    for j in 0 ..< 4:
      result[index] = matrix[i, j]
      inc index

proc packTransforms(mvp, model: Mat4): array[32, float32] =
  ## Packs the matrices for the root constants.
  let
    mvpValues = mat4ToArray(mvp)
    modelValues = mat4ToArray(model)
  for i in 0 ..< 16:
    result[i] = mvpValues[i]
    result[i + 16] = modelValues[i]

proc toFloatArray(v: Vec3): array[3, float32] =
  ## Converts a vector into a plain float array.
  [v.x, v.y, v.z]

proc parseFloat32(value: string): float32 =
  ## Parses a float32 from text.
  try:
    parseFloat(value).float32
  except ValueError:
    raise newException(ViewerObjError, "Invalid float in OBJ: " & value)

proc parseObjIndex(value: string, vertexCount: int): int =
  ## Parses a 1-based OBJ vertex index into a 0-based index.
  if value.len == 0:
    raise newException(ViewerObjError, "OBJ face is missing a vertex index")

  let rawIndex =
    try:
      parseInt(value)
    except ValueError:
      raise newException(ViewerObjError, "Invalid OBJ face index: " & value)

  result =
    if rawIndex > 0:
      rawIndex - 1
    elif rawIndex < 0:
      vertexCount + rawIndex
    else:
      raise newException(ViewerObjError, "OBJ indices cannot be zero")

  if result < 0 or result >= vertexCount:
    raise newException(
      ViewerObjError,
      "OBJ face index is out of range: " & value
    )

proc parseFaceVertex(token: string, vertexCount: int): int =
  ## Parses the position index from an OBJ face vertex token.
  let slash = token.find('/')
  let indexToken =
    if slash >= 0:
      token[0 ..< slash]
    else:
      token
  parseObjIndex(indexToken, vertexCount)

proc normalizeSafe(v, fallback: Vec3): Vec3 =
  ## Normalizes a vector or returns a fallback when degenerate.
  if v.length() <= 0.000001'f32:
    fallback
  else:
    v.normalize()

proc loadObjMesh(path: string): ObjMesh =
  ## Loads a simple OBJ mesh and expands it into a triangle list.
  if not fileExists(path):
    raise newException(ViewerObjError, "OBJ file not found: " & path)

  var
    positions: seq[Vec3]
    triangles: seq[array[3, int]]

  for rawLine in readFile(path).splitLines():
    let line = rawLine.strip()
    if line.len == 0 or line[0] == '#':
      continue

    let parts = strutils.splitWhitespace(line)
    case parts[0]
    of "v":
      if parts.len < 4:
        raise newException(ViewerObjError, "OBJ vertex line is incomplete")
      positions.add(
        vec3(
          parseFloat32(parts[1]),
          parseFloat32(parts[2]),
          parseFloat32(parts[3])
        )
      )
    of "f":
      if parts.len < 4:
        raise newException(ViewerObjError, "OBJ face line is incomplete")
      var faceIndices: seq[int]
      for i in 1 ..< parts.len:
        faceIndices.add(parseFaceVertex(parts[i], positions.len))
      for i in 1 ..< faceIndices.len - 1:
        triangles.add([faceIndices[0], faceIndices[i], faceIndices[i + 1]])
    else:
      discard

  if positions.len == 0:
    raise newException(ViewerObjError, "OBJ does not contain any vertices")
  if triangles.len == 0:
    raise newException(ViewerObjError, "OBJ does not contain any faces")

  var
    minPos = positions[0]
    maxPos = positions[0]
  for i in 1 ..< positions.len:
    let p = positions[i]
    minPos.x = min(minPos.x, p.x)
    minPos.y = min(minPos.y, p.y)
    minPos.z = min(minPos.z, p.z)
    maxPos.x = max(maxPos.x, p.x)
    maxPos.y = max(maxPos.y, p.y)
    maxPos.z = max(maxPos.z, p.z)

  let
    center = (minPos + maxPos) * 0.5'f32
    size = maxPos - minPos
    maxExtent = max(size.x, max(size.y, size.z))
  if maxExtent <= 0.0'f32:
    raise newException(ViewerObjError, "OBJ bounds are degenerate")

  let uniformScale = 2.0'f32 / maxExtent
  var normalizedPositions = newSeq[Vec3](positions.len)
  for i, p in positions:
    normalizedPositions[i] = (p - center) * uniformScale

  var smoothedNormals = newSeq[Vec3](normalizedPositions.len)
  for tri in triangles:
    let
      a = normalizedPositions[tri[0]]
      b = normalizedPositions[tri[1]]
      c = normalizedPositions[tri[2]]
      faceNormal = normalizeSafe((b - a).cross(c - a), vec3(0.0'f32, 1.0'f32, 0.0'f32))
    smoothedNormals[tri[0]] += faceNormal
    smoothedNormals[tri[1]] += faceNormal
    smoothedNormals[tri[2]] += faceNormal

  result.vertices = newSeq[ObjVertex](triangles.len * 3)
  var vertexIndex = 0
  for tri in triangles:
    for idx in tri:
      result.vertices[vertexIndex] = ObjVertex(
        position: normalizedPositions[idx].toFloatArray(),
        normal: normalizeSafe(
          smoothedNormals[idx],
          vec3(0.0'f32, 1.0'f32, 0.0'f32)
        ).toFloatArray()
      )
      inc vertexIndex

proc uploadVertexBuffer(
    ctx: var D3D12Context,
    renderer: var ObjRenderer,
    mesh: ObjMesh
  ) =
  ## Uploads the triangle-expanded mesh to GPU memory.
  if mesh.vertices.len == 0:
    raise newException(ViewerObjError, "Mesh is empty")

  let vertexBufferSize = UINT64(mesh.vertices.len * sizeof(ObjVertex))

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
  copyMem(
    uploadPtr,
    unsafeAddr mesh.vertices[0],
    mesh.vertices.len * sizeof(ObjVertex)
  )
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

  renderer.vertexCount = UINT(mesh.vertices.len)
  renderer.vertexBufferView = D3D12_VERTEX_BUFFER_VIEW(
    BufferLocation: renderer.vertexBuffer.getGPUVirtualAddress(),
    SizeInBytes: UINT(vertexBufferSize),
    StrideInBytes: UINT(sizeof(ObjVertex))
  )

proc createDepthBuffer(ctx: var D3D12Context, renderer: var ObjRenderer) =
  ## Creates the depth buffer and its descriptor heap.
  var dsvHeapDesc = D3D12_DESCRIPTOR_HEAP_DESC(
    typ: D3D12_DESCRIPTOR_HEAP_TYPE_DSV,
    NumDescriptors: 1,
    Flags: D3D12_DESCRIPTOR_HEAP_FLAG_NONE,
    NodeMask: 0
  )
  renderer.dsvHeap = ctx.device.createDescriptorHeap(addr dsvHeapDesc)
  renderer.dsvHandle = renderer.dsvHeap.getCPUDescriptorHandleForHeapStart()

  var depthDesc: D3D12_RESOURCE_DESC
  zeroMem(addr depthDesc, sizeof(depthDesc))
  depthDesc.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D
  depthDesc.Alignment = 0
  depthDesc.Width = uint64(Width)
  depthDesc.Height = UINT(Height)
  depthDesc.DepthOrArraySize = 1
  depthDesc.MipLevels = 1
  depthDesc.Format = DXGI_FORMAT_D32_FLOAT
  depthDesc.SampleDesc = DXGI_SAMPLE_DESC(Count: 1, Quality: 0)
  depthDesc.Layout = D3D12_TEXTURE_LAYOUT_UNKNOWN
  depthDesc.Flags = D3D12_RESOURCE_FLAG_ALLOW_DEPTH_STENCIL

  var defaultHeap: D3D12_HEAP_PROPERTIES
  zeroMem(addr defaultHeap, sizeof(defaultHeap))
  defaultHeap.typ = D3D12_HEAP_TYPE_DEFAULT
  defaultHeap.CPUPageProperty = 0
  defaultHeap.MemoryPoolPreference = 0
  defaultHeap.CreationNodeMask = 1
  defaultHeap.VisibleNodeMask = 1

  var clearValue = D3D12_CLEAR_VALUE(
    Format: DXGI_FORMAT_D32_FLOAT,
    data: D3D12_CLEAR_VALUE_UNION(
      DepthStencil: D3D12_DEPTH_STENCIL_VALUE(
        Depth: 1.0'f32,
        Stencil: 0
      )
    )
  )

  renderer.depthBuffer = ctx.device.createCommittedResource(
    addr defaultHeap,
    D3D12_HEAP_FLAG_NONE,
    addr depthDesc,
    D3D12_RESOURCE_STATE_DEPTH_WRITE,
    addr clearValue
  )
  ctx.device.createDepthStencilView(
    renderer.depthBuffer,
    nil,
    renderer.dsvHandle
  )

proc initRenderer(
    ctx: var D3D12Context,
    renderer: var ObjRenderer,
    mesh: ObjMesh
  ) =
  ## Creates the pipeline state and uploads the bunny mesh.
  const vertexShaderSrc = """
cbuffer Transform : register(b0)
{
  column_major float4x4 mvp;
  column_major float4x4 model;
}

struct VSInput {
  float3 pos : POSITION;
  float3 normal : NORMAL;
};

struct PSInput {
  float4 pos : SV_POSITION;
  float3 normal : NORMAL;
};

PSInput VSMain(VSInput input) {
  PSInput output;
  output.pos = mul(mvp, float4(input.pos, 1.0f));
  output.normal = normalize(mul((float3x3)model, input.normal));
  return output;
}
"""

  const pixelShaderSrc = """
struct PSInput {
  float4 pos : SV_POSITION;
  float3 normal : NORMAL;
};

float4 PSMain(PSInput input) : SV_TARGET {
  float3 lightDir = normalize(float3(0.4f, 0.8f, 0.5f));
  float diffuse = abs(dot(normalize(input.normal), lightDir));
  float light = 0.2f + diffuse * 0.8f;
  float3 baseColor = float3(0.88f, 0.84f, 0.78f);
  return float4(baseColor * light, 1.0f);
}
"""

  let
    vsBlob = compileShader(vertexShaderSrc, "VSMain", "vs_5_0")
    psBlob = compileShader(pixelShaderSrc, "PSMain", "ps_5_0")

  var rootParams = [
    D3D12_ROOT_PARAMETER(
      ParameterType: D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS,
      data: D3D12_ROOT_PARAMETER_union(
        Constants: D3D12_ROOT_CONSTANTS(
          ShaderRegister: 0,
          RegisterSpace: 0,
          Num32BitValues: 32
        )
      ),
      ShaderVisibility: D3D12_SHADER_VISIBILITY_ALL
    )
  ]

  var rootDesc = D3D12_ROOT_SIGNATURE_DESC(
    NumParameters: uint32(rootParams.len),
    pParameters: addr rootParams[0],
    NumStaticSamplers: 0,
    pStaticSamplers: nil,
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
      SemanticName: "NORMAL",
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
      DepthEnable: 1,
      DepthWriteMask: D3D12_DEPTH_WRITE_MASK_ALL,
      DepthFunc: D3D12_COMPARISON_FUNC_LESS,
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
    DSVFormat: DXGI_FORMAT_D32_FLOAT,
    SampleDesc: DXGI_SAMPLE_DESC(Count: 1, Quality: 0),
    NodeMask: 0,
    CachedPSO: D3D12_CACHED_PIPELINE_STATE(),
    Flags: 0
  )
  psoDesc.RTVFormats[0] = DXGI_FORMAT_R8G8B8A8_UNORM

  renderer.pipelineState = ctx.device.createGraphicsPipelineState(addr psoDesc)

  release(vsBlob)
  release(psBlob)
  createDepthBuffer(ctx, renderer)
  uploadVertexBuffer(ctx, renderer, mesh)

proc updateCamera(camera: var CameraState, window: Window) =
  ## Updates the orbit camera from mouse drag and scroll wheel input.
  if window.buttonDown[MouseLeft]:
    let delta = window.mouseDelta
    camera.yaw += delta.x.float32 * RotateScale
    camera.pitch = clamp(
      camera.pitch + delta.y.float32 * RotateScale,
      MinPitch,
      MaxPitch
    )

  let scroll = window.scrollDelta
  if scroll.y != 0.0'f32:
    camera.distance = clamp(
      camera.distance - scroll.y.float32 * ZoomScale,
      MinDistance,
      MaxDistance
    )

proc updateTransform(
    renderer: var ObjRenderer,
    camera: CameraState,
    aspect: float32
  ) =
  ## Updates the view and projection constants for the current frame.
  let
    cosPitch = cos(camera.pitch)
    eye = vec3(
      sin(camera.yaw) * cosPitch * camera.distance,
      sin(camera.pitch) * camera.distance,
      cos(camera.yaw) * cosPitch * camera.distance
    )
    target = vec3(0.0'f32, 0.0'f32, 0.0'f32)
    model = identityMatrix()
    cameraAngles = toAngles(eye, target)
    view = inverse(translate(eye) * fromAngles(cameraAngles))
    proj = perspectiveDx(60.0'f32.toRadians, aspect, 0.1'f32, 100.0'f32)
    mvp = proj * view * model
  renderer.transform = packTransforms(mvp, model)

proc recordModel(
    ctx: var D3D12Context,
    renderer: ObjRenderer,
    clearColor: array[4, FLOAT]
  ) =
  ## Records the draw commands for the bunny mesh.
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
    unsafeAddr renderer.dsvHandle
  )
  ctx.commandList.clearRenderTargetView(
    ctx.rtvHandles[ctx.currentFrame],
    unsafeAddr clearColor[0],
    0,
    nil
  )
  ctx.commandList.clearDepthStencilView(
    renderer.dsvHandle,
    D3D12_CLEAR_FLAG_DEPTH,
    1.0'f32,
    0,
    0,
    nil
  )

  ctx.commandList.setGraphicsRoot32BitConstants(
    0,
    32,
    unsafeAddr renderer.transform[0],
    0
  )
  ctx.commandList.iaSetPrimitiveTopology(D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST)
  ctx.commandList.iaSetVertexBuffers(0, 1, unsafeAddr renderer.vertexBufferView)
  ctx.commandList.drawInstanced(renderer.vertexCount, 1, 0, 0)

  barrier.data.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET
  barrier.data.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT
  ctx.commandList.resourceBarrier(1, addr barrier)
  ctx.commandList.close()

proc shutdown(renderer: var ObjRenderer) =
  ## Releases the renderer resources.
  if renderer.depthBuffer != nil:
    renderer.depthBuffer.release()
    renderer.depthBuffer = nil
  if renderer.dsvHeap != nil:
    renderer.dsvHeap.release()
    renderer.dsvHeap = nil
  if renderer.vertexBuffer != nil:
    renderer.vertexBuffer.release()
    renderer.vertexBuffer = nil
  if renderer.pipelineState != nil:
    renderer.pipelineState.release()
    renderer.pipelineState = nil
  if renderer.rootSignature != nil:
    renderer.rootSignature.release()
    renderer.rootSignature = nil

when isMainModule:
  let window = newWindow(
    "DirectX 12 Bunny Viewer",
    ivec2(Width.int32, Height.int32)
  )

  var hwnd: HWND = window.getHWND()
  if hwnd == 0:
    raise newException(Exception, "Failed to acquire HWND from window")

  let mesh = loadObjMesh(objPath())

  var ctx: D3D12Context
  ctx.initDevice(hwnd, Width, Height)

  var renderer: ObjRenderer
  initRenderer(ctx, renderer, mesh)

  let
    aspect = Width.float32 / Height.float32
    clearColor = [0.05.FLOAT, 0.05.FLOAT, 0.08.FLOAT, 1.0.FLOAT]
  var camera = CameraState(
    yaw: 0.0'f32,
    pitch: 0.15'f32,
    distance: 2.8'f32
  )

  try:
    while not window.closeRequested:
      pollEvents()
      updateCamera(camera, window)
      updateTransform(renderer, camera, aspect)
      recordModel(ctx, renderer, clearColor)
      ctx.executeFrame()
  finally:
    renderer.shutdown()
    ctx.cleanup()
