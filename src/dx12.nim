import dynlib
import windy/platforms/win32/windefs

# --- Basic Win32 / DirectX types ---
type
  HRESULT* = int32
  UINT* = uint32
  UINT64* = uint64
  FLOAT* = float32
  BOOL32* = int32
  DXGI_FORMAT* = uint32
  D3D_FEATURE_LEVEL* = uint32
  D3D12_COMMAND_LIST_TYPE* = uint32
  D3D12_COMMAND_QUEUE_FLAGS* = uint32
  D3D12_DESCRIPTOR_HEAP_TYPE* = uint32
  D3D12_DESCRIPTOR_HEAP_FLAGS* = uint32
  D3D12_RESOURCE_STATES* = uint32
  D3D12_RESOURCE_BARRIER_TYPE* = uint32
  D3D12_RESOURCE_BARRIER_FLAGS* = uint32
  DXGuid* {.pure, packed.} = object
    Data1*: uint32
    Data2*: uint16
    Data3*: uint16
    Data4*: array[8, uint8]

# --- COM interface stubs (opaque pointers) ---
type
  IDXGIFactory4* = ptr object
  IDXGISwapChain1* = ptr object
  IDXGISwapChain3* = ptr object
  ID3D12Device* = ptr object
  ID3D12Resource* = ptr object
  ID3D12CommandQueue* = ptr object
  ID3D12CommandAllocator* = ptr object
  ID3D12CommandList* = ptr object
  ID3D12GraphicsCommandList* = ptr object
  ID3D12DescriptorHeap* = ptr object
  ID3D12Fence* = ptr object
  IDXGIOutput* = ptr object
  ID3D12RootSignature* = ptr object
  ID3D12PipelineState* = ptr object
  ID3DBlob* = ptr object

# --- Structs we actively use ---
type
  DXGI_SAMPLE_DESC* = object
    Count*: UINT
    Quality*: UINT

  DXGI_SWAP_CHAIN_DESC1* = object
    Width*, Height*: UINT
    Format*: DXGI_FORMAT
    Stereo*: BOOL32
    SampleDesc*: DXGI_SAMPLE_DESC
    BufferUsage*: UINT
    BufferCount*: UINT
    Scaling*: uint32
    SwapEffect*: uint32
    AlphaMode*: uint32
    Flags*: UINT

  D3D12_VIEWPORT* = object
    TopLeftX*, TopLeftY*, Width*, Height*, MinDepth*, MaxDepth*: FLOAT

  D3D12_RECT* = object
    left*, top*, right*, bottom*: int32

  D3D12_CPU_DESCRIPTOR_HANDLE* = object
    ptrValue*: uint64

  D3D12_COMMAND_QUEUE_DESC* = object
    Type*: D3D12_COMMAND_LIST_TYPE
    Priority*: int32
    Flags*: D3D12_COMMAND_QUEUE_FLAGS
    NodeMask*: UINT

  D3D12_DESCRIPTOR_HEAP_DESC* = object
    typ*: D3D12_DESCRIPTOR_HEAP_TYPE
    NumDescriptors*: UINT
    Flags*: D3D12_DESCRIPTOR_HEAP_FLAGS
    NodeMask*: UINT

  D3D12_HEAP_PROPERTIES* = object
    typ*: uint32
    CPUPageProperty*: uint32
    MemoryPoolPreference*: uint32
    CreationNodeMask*: UINT
    VisibleNodeMask*: UINT

  D3D12_RESOURCE_DESC* = object
    Dimension*: uint32
    Alignment*: UINT64
    Width*: UINT64
    Height*: UINT
    DepthOrArraySize*: uint16
    MipLevels*: uint16
    Format*: DXGI_FORMAT
    SampleDesc*: DXGI_SAMPLE_DESC
    Layout*: uint32
    Flags*: uint32

  D3D12_RESOURCE_TRANSITION_BARRIER* = object
    pResource*: ID3D12Resource
    Subresource*: UINT
    StateBefore*: D3D12_RESOURCE_STATES
    StateAfter*: D3D12_RESOURCE_STATES

  D3D12_RESOURCE_BARRIER* = object
    typ*: D3D12_RESOURCE_BARRIER_TYPE
    Flags*: D3D12_RESOURCE_BARRIER_FLAGS
    Transition*: D3D12_RESOURCE_TRANSITION_BARRIER

  D3D12_RANGE* = object
    start*: csize_t
    finish*: csize_t

  D3D12_VERTEX_BUFFER_VIEW* = object
    BufferLocation*: UINT64
    SizeInBytes*: UINT
    StrideInBytes*: UINT

  D3D12_SHADER_BYTECODE* = object
    pShaderBytecode*: pointer
    BytecodeLength*: csize_t

  D3D12_INPUT_ELEMENT_DESC* = object
    SemanticName*: cstring
    SemanticIndex*: UINT
    Format*: DXGI_FORMAT
    InputSlot*: UINT
    AlignedByteOffset*: UINT
    InputSlotClass*: uint32
    InstanceDataStepRate*: UINT

  D3D12_INPUT_LAYOUT_DESC* = object
    pInputElementDescs*: ptr D3D12_INPUT_ELEMENT_DESC
    NumElements*: uint32

  D3D12_STREAM_OUTPUT_DESC* = object
    pSODeclaration*: pointer
    NumEntries*: UINT
    pBufferStrides*: pointer
    NumStrides*: UINT
    RasterizedStream*: UINT

  D3D12_RENDER_TARGET_BLEND_DESC* = object
    BlendEnable*: BOOL32
    LogicOpEnable*: BOOL32
    SrcBlend*: uint32
    DestBlend*: uint32
    BlendOp*: uint32
    SrcBlendAlpha*: uint32
    DestBlendAlpha*: uint32
    BlendOpAlpha*: uint32
    LogicOp*: uint32
    RenderTargetWriteMask*: uint8

  D3D12_BLEND_DESC* = object
    AlphaToCoverageEnable*: BOOL32
    IndependentBlendEnable*: BOOL32
    RenderTarget*: array[8, D3D12_RENDER_TARGET_BLEND_DESC]

  D3D12_RASTERIZER_DESC* = object
    FillMode*: uint32
    CullMode*: uint32
    FrontCounterClockwise*: BOOL32
    DepthBias*: int32
    DepthBiasClamp*: FLOAT
    SlopeScaledDepthBias*: FLOAT
    DepthClipEnable*: BOOL32
    MultisampleEnable*: BOOL32
    AntialiasedLineEnable*: BOOL32
    ForcedSampleCount*: UINT
    ConservativeRaster*: uint32

  D3D12_DEPTH_STENCILOP_DESC* = object
    StencilFailOp*: uint32
    StencilDepthFailOp*: uint32
    StencilPassOp*: uint32
    StencilFunc*: uint32

  D3D12_DEPTH_STENCIL_DESC* = object
    DepthEnable*: BOOL32
    DepthWriteMask*: uint32
    DepthFunc*: uint32
    StencilEnable*: BOOL32
    StencilReadMask*: uint8
    StencilWriteMask*: uint8
    FrontFace*: D3D12_DEPTH_STENCILOP_DESC
    BackFace*: D3D12_DEPTH_STENCILOP_DESC

  D3D12_CACHED_PIPELINE_STATE* = object
    pCachedBlob*: pointer
    CachedBlobSizeInBytes*: UINT64

  D3D12_GRAPHICS_PIPELINE_STATE_DESC* = object
    pRootSignature*: ID3D12RootSignature
    VS*: D3D12_SHADER_BYTECODE
    PS*: D3D12_SHADER_BYTECODE
    DS*: D3D12_SHADER_BYTECODE
    HS*: D3D12_SHADER_BYTECODE
    GS*: D3D12_SHADER_BYTECODE
    StreamOutput*: D3D12_STREAM_OUTPUT_DESC
    BlendState*: D3D12_BLEND_DESC
    SampleMask*: uint32
    RasterizerState*: D3D12_RASTERIZER_DESC
    DepthStencilState*: D3D12_DEPTH_STENCIL_DESC
    InputLayout*: D3D12_INPUT_LAYOUT_DESC
    IBStripCutValue*: uint32
    PrimitiveTopologyType*: uint32
    NumRenderTargets*: uint32
    RTVFormats*: array[8, DXGI_FORMAT]
    DSVFormat*: DXGI_FORMAT
    SampleDesc*: DXGI_SAMPLE_DESC
    NodeMask*: UINT
    CachedPSO*: D3D12_CACHED_PIPELINE_STATE
    Flags*: uint32

  D3D12_ROOT_SIGNATURE_DESC* = object
    NumParameters*: uint32
    pParameters*: pointer
    NumStaticSamplers*: uint32
    pStaticSamplers*: pointer
    Flags*: uint32

# --- Constants ---
const
  FRAME_COUNT* = 2
  DXGI_FORMAT_R8G8B8A8_UNORM* = 28'u32
  DXGI_FORMAT_R32G32B32_FLOAT* = 6'u32
  DXGI_FORMAT_R32G32_FLOAT* = 16'u32
  DXGI_FORMAT_UNKNOWN* = 0'u32
  DXGI_USAGE_RENDER_TARGET_OUTPUT* = 0x20'u32
  DXGI_SCALING_STRETCH* = 0'u32
  DXGI_SWAP_EFFECT_FLIP_DISCARD* = 4'u32
  DXGI_ALPHA_MODE_UNSPECIFIED* = 0'u32
  DXGI_MWA_NO_ALT_ENTER* = 0x2'u32

  D3D_FEATURE_LEVEL_11_0* = 0xb000'u32
  D3D12_COMMAND_LIST_TYPE_DIRECT* = 0'u32
  D3D12_COMMAND_QUEUE_FLAG_NONE* = 0'u32
  D3D12_COMMAND_QUEUE_PRIORITY_NORMAL* = 0
  D3D12_DESCRIPTOR_HEAP_TYPE_RTV* = 2'u32
  D3D12_DESCRIPTOR_HEAP_FLAG_NONE* = 0'u32
  D3D12_HEAP_TYPE_DEFAULT* = 1'u32
  D3D12_HEAP_TYPE_UPLOAD* = 2'u32
  D3D12_HEAP_FLAG_NONE* = 0'u32
  D3D12_RESOURCE_DIMENSION_BUFFER* = 1'u32
  D3D12_TEXTURE_LAYOUT_ROW_MAJOR* = 4'u32
  D3D12_RESOURCE_FLAG_NONE* = 0'u32
  D3D12_RESOURCE_STATE_PRESENT* = 0'u32
  D3D12_RESOURCE_STATE_RENDER_TARGET* = 0x4'u32
  D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER* = 0x1'u32
  D3D12_RESOURCE_STATE_GENERIC_READ* = 0x800'u32
  D3D12_RESOURCE_BARRIER_TYPE_TRANSITION* = 0'u32
  D3D12_RESOURCE_BARRIER_FLAG_NONE* = 0'u32
  D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES* = 0xffffffff'u32
  D3D12_FENCE_FLAG_NONE* = 0'u32
  D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA* = 0'u32
  D3D12_FILL_MODE_SOLID* = 3'u32
  D3D12_CULL_MODE_BACK* = 3'u32
  D3D12_BLEND_ZERO* = 1'u32
  D3D12_BLEND_ONE* = 2'u32
  D3D12_BLEND_OP_ADD* = 1'u32
  D3D12_COLOR_WRITE_ENABLE_ALL* = 0x0f'u32
  D3D12_DEPTH_WRITE_MASK_ALL* = 1'u32
  D3D12_COMPARISON_FUNC_ALWAYS* = 8'u32
  D3D12_STENCIL_OP_KEEP* = 1'u32
  D3D12_CONSERVATIVE_RASTERIZATION_MODE_OFF* = 0'u32
  D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE* = 3'u32
  D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST* = 4'u32
  D3D12_DEFAULT_SAMPLE_MASK* = 0xffffffff'u32
  D3D12_ROOT_SIGNATURE_FLAG_ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT* = 0x1'u32
  WAIT_INFINITE* = -1'i32

  S_OK* = 0

proc newGuid*(
  data1: uint32,
  data2: uint16,
  data3: uint16,
  b0, b1, b2, b3, b4, b5, b6, b7: uint8
): DXGuid =
  ## Creates GUIDs from the canonical IID literal format:
  ## 0xXXXXXXXX, 0xXXXX, 0xXXXX, 0xXX, ... (8 bytes total)
  DXGuid(
    Data1: data1,
    Data2: data2,
    Data3: data3,
    Data4: [b0, b1, b2, b3, b4, b5, b6, b7]
  )

# --- D3D12 / DXGI entry points loaded at runtime ---
type
  D3D12CreateDevice_t = proc(
    pAdapter: pointer,
    MinimumFeatureLevel: D3D_FEATURE_LEVEL,
    riid: ptr DXGuid,
    ppDevice: ptr pointer
  ): HRESULT {.stdcall.}

  CreateDXGIFactory2_t* = proc(
    Flags: UINT,
    riid: ptr DXGuid,
    ppFactory: ptr pointer
  ): HRESULT {.stdcall.}

  D3D12SerializeRootSignature_t = proc(
    desc: ptr D3D12_ROOT_SIGNATURE_DESC,
    version: uint32,
    blob: ptr ID3DBlob,
    errorBlob: ptr ID3DBlob
  ): HRESULT {.stdcall.}

  D3DCompile_t = proc(
    pSrcData: pointer,
    SrcDataSize: csize_t,
    pSourceName: cstring,
    pDefines: pointer,
    pInclude: pointer,
    pEntryPoint: cstring,
    pTarget: cstring,
    Flags1: uint32,
    Flags2: uint32,
    ppCode: ptr ID3DBlob,
    ppErrorMsgs: ptr ID3DBlob
  ): HRESULT {.stdcall.}

var
  d3d12Lib: LibHandle
  dxgiLib: LibHandle
  D3D12CreateDevice_Ptr: D3D12CreateDevice_t
  CreateDXGIFactory2_Ptr: CreateDXGIFactory2_t
  D3D12SerializeRootSignature_Ptr: D3D12SerializeRootSignature_t
  d3dCompilerLib: LibHandle
  D3DCompile_Ptr: D3DCompile_t

template callVtbl0(iface: pointer, index: int, typ: typedesc): untyped =
  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)
  let vtbl = vtblPtr[]
  let funcPtr = vtbl[index]
  let fn = cast[typ](funcPtr)
  fn(iface)

template callVtbl(iface: pointer, index: int, typ: typedesc, args: varargs[untyped]): untyped =
  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)
  let vtbl = vtblPtr[]
  let funcPtr = vtbl[index]
  let fn = cast[typ](funcPtr)
  fn(iface, args)

proc release*(obj: pointer) =
  if obj == nil:
    raise newException(Exception, "COM object is nil")
  type ReleaseProc = proc(this: pointer): uint32 {.stdcall.}
  let hr = callVtbl0(obj, 2, ReleaseProc)
  if hr < 0:
    raise newException(Exception, "COM object release failed with HRESULT " & $hr)

# --- Thin wrappers for the specific methods we need ---
proc createCommandQueue*(self: ID3D12Device, desc: ptr D3D12_COMMAND_QUEUE_DESC): ID3D12CommandQueue =
  const IID_ID3D12CommandQueue = newGuid(0x0ec870a6'u32,0x5d7e'u16,0x4c22'u16,0x8c'u8,0xfc'u8,0x5b'u8,0xaa'u8,0xe0'u8,0x76'u8,0x16'u8,0xed'u8)
  type F = proc(this: ID3D12Device, desc: ptr D3D12_COMMAND_QUEUE_DESC, riid: ptr DXGuid, outQueue: ptr ID3D12CommandQueue): HRESULT {.stdcall.}
  let hr = callVtbl(self, 8, F, desc, addr IID_ID3D12CommandQueue, addr result)
  if hr < 0:
    raise newException(Exception, "CreateCommandQueue failed with HRESULT " & $hr)

proc createCommandAllocator*(self: ID3D12Device, typ: D3D12_COMMAND_LIST_TYPE): ID3D12CommandAllocator =
  const IID_ID3D12CommandAllocator = newGuid(0x6102dee4'u32,0xaf59'u16,0x4b09'u16,0xb9'u8,0x99'u8,0xb4'u8,0x4d'u8,0x73'u8,0xf0'u8,0x9b'u8,0x24'u8)
  type F = proc(this: ID3D12Device, typ: D3D12_COMMAND_LIST_TYPE, riid: ptr DXGuid, outAlloc: ptr pointer): HRESULT {.stdcall.}
  let hr = callVtbl(self, 9, F, typ, addr IID_ID3D12CommandAllocator, cast[ptr pointer](addr result))
  if hr < 0:
    raise newException(Exception, "CreateCommandAllocator failed with HRESULT " & $hr)

proc createCommandList*(self: ID3D12Device, nodeMask: UINT, typ: D3D12_COMMAND_LIST_TYPE, allocator: ID3D12CommandAllocator, initialState: pointer): ID3D12GraphicsCommandList =
  const IID_ID3D12GraphicsCommandList = newGuid(0x5b160d0f'u32,0xac1b'u16,0x4185'u16,0x8b'u8,0xa8'u8,0xb3'u8,0xae'u8,0x42'u8,0xa5'u8,0xa4'u8,0x55'u8)
  type F = proc(this: ID3D12Device, nodeMask: UINT, typ: D3D12_COMMAND_LIST_TYPE, allocator: ID3D12CommandAllocator, initialState: pointer, riid: ptr DXGuid, outList: ptr pointer): HRESULT {.stdcall.}
  let hr = callVtbl(self, 12, F, nodeMask, typ, allocator, initialState, addr IID_ID3D12GraphicsCommandList, cast[ptr pointer](addr result))
  if hr < 0:
    raise newException(Exception, "CreateCommandList failed with HRESULT " & $hr)

proc createDescriptorHeap*(self: ID3D12Device, desc: ptr D3D12_DESCRIPTOR_HEAP_DESC): ID3D12DescriptorHeap =
  const IID_ID3D12DescriptorHeap = newGuid(0x8efb471d'u32,0x616c'u16,0x4f49'u16,0x90'u8,0xf7'u8,0x12'u8,0x7b'u8,0xb7'u8,0x63'u8,0xfa'u8,0x51'u8)
  type F = proc(this: ID3D12Device, desc: ptr D3D12_DESCRIPTOR_HEAP_DESC, riid: ptr DXGuid, outHeap: ptr pointer): HRESULT {.stdcall.}
  let hr = callVtbl(self, 14, F, desc, addr IID_ID3D12DescriptorHeap, cast[ptr pointer](addr result))
  if hr < 0:
    raise newException(Exception, "CreateDescriptorHeap failed with HRESULT " & $hr)

proc createRootSignature*(self: ID3D12Device, nodeMask: UINT, bytecode: pointer, bytecodeLength: csize_t): ID3D12RootSignature =
  const IID_ID3D12RootSignature = newGuid(0xc54a6b66'u32,0x72df'u16,0x4ee8'u16,0x8b'u8,0xe5'u8,0xa9'u8,0x46'u8,0xa1'u8,0x42'u8,0x92'u8,0x14'u8)
  type F = proc(this: ID3D12Device, nodeMask: UINT, bytecode: pointer, bytecodeLength: csize_t, riid: ptr DXGuid, outSignature: ptr pointer): HRESULT {.stdcall.}
  let hr = callVtbl(self, 16, F, nodeMask, bytecode, bytecodeLength, addr IID_ID3D12RootSignature, cast[ptr pointer](addr result))
  if hr < 0:
    raise newException(Exception, "CreateRootSignature failed with HRESULT " & $hr)

proc getDescriptorHandleIncrementSize*(self: ID3D12Device, heapType: D3D12_DESCRIPTOR_HEAP_TYPE): UINT =
  type F = proc(this: ID3D12Device, heapType: D3D12_DESCRIPTOR_HEAP_TYPE): UINT {.stdcall.}
  let hr = callVtbl(self, 15, F, heapType)
  if hr < 0:
    raise newException(Exception, "GetDescriptorHandleIncrementSize failed with HRESULT " & $hr)
  result = UINT(hr)

proc createGraphicsPipelineState*(self: ID3D12Device, desc: ptr D3D12_GRAPHICS_PIPELINE_STATE_DESC): ID3D12PipelineState =
  const IID_ID3D12PipelineState = newGuid(0x765a30f3'u32,0xf624'u16,0x4c6f'u16,0xa8'u8,0x28'u8,0xac'u8,0xe9'u8,0x48'u8,0x62'u8,0x24'u8,0x45'u8)
  type F = proc(this: ID3D12Device, desc: ptr D3D12_GRAPHICS_PIPELINE_STATE_DESC, riid: ptr DXGuid, outState: ptr pointer): HRESULT {.stdcall.}
  let hr = callVtbl(self, 10, F, desc, addr IID_ID3D12PipelineState, cast[ptr pointer](addr result))
  if hr < 0:
    raise newException(Exception, "CreateGraphicsPipelineState failed with HRESULT " & $hr)

proc createRenderTargetView*(self: ID3D12Device, resource: ID3D12Resource, desc: pointer, handle: D3D12_CPU_DESCRIPTOR_HANDLE) =
  type F = proc(this: ID3D12Device, resource: ID3D12Resource, desc: pointer, handle: D3D12_CPU_DESCRIPTOR_HANDLE) {.stdcall.}
  callVtbl(self, 20, F, resource, desc, handle)

proc createCommittedResource*(self: ID3D12Device, heapProps: ptr D3D12_HEAP_PROPERTIES, heapFlags: uint32, desc: ptr D3D12_RESOURCE_DESC, initialState: D3D12_RESOURCE_STATES, clearValue: pointer): ID3D12Resource =
  const IID_ID3D12Resource = newGuid(0x696442be'u32,0xa72e'u16,0x4059'u16,0xbc'u8,0x79'u8,0x5b'u8,0x5c'u8,0x98'u8,0x04'u8,0x0f'u8,0xad'u8)
  type F = proc(this: ID3D12Device, heapProps: ptr D3D12_HEAP_PROPERTIES, heapFlags: uint32, desc: ptr D3D12_RESOURCE_DESC, initialState: D3D12_RESOURCE_STATES, clearValue: pointer, riid: ptr DXGuid, outResource: ptr pointer): HRESULT {.stdcall.}
  let hr = callVtbl(self, 27, F, heapProps, heapFlags, desc, initialState, clearValue, addr IID_ID3D12Resource, cast[ptr pointer](addr result))
  if hr < 0:
    raise newException(Exception, "CreateCommittedResource failed with HRESULT " & $hr)

proc map*(self: ID3D12Resource, subresource: UINT, readRange: ptr D3D12_RANGE, data: ptr pointer) =
  type F = proc(this: ID3D12Resource, subresource: UINT, readRange: ptr D3D12_RANGE, data: ptr pointer): HRESULT {.stdcall.}
  let hr = callVtbl(self, 8, F, subresource, readRange, data)
  if hr < 0:
    raise newException(Exception, "ID3D12Resource.Map failed with HRESULT " & $hr)

proc unmap*(self: ID3D12Resource, subresource: UINT, writtenRange: ptr D3D12_RANGE) =
  type F = proc(this: ID3D12Resource, subresource: UINT, writtenRange: ptr D3D12_RANGE): void {.stdcall.}
  callVtbl(self, 9, F, subresource, writtenRange)

proc getGPUVirtualAddress*(self: ID3D12Resource): UINT64 =
  type F = proc(this: ID3D12Resource): UINT64 {.stdcall.}
  callVtbl0(self, 11, F)

proc createFence*(self: ID3D12Device, initialValue: UINT64, flags: uint32): ID3D12Fence =
  const IID_ID3D12Fence = newGuid(0x0a753dcf'u32,0xc4d8'u16,0x4b91'u16,0xad'u8,0xf6'u8,0xbe'u8,0x5a'u8,0x60'u8,0xd9'u8,0x5a'u8,0x76'u8)
  type F = proc(this: ID3D12Device, initialValue: UINT64, flags: uint32, riid: ptr DXGuid, outFence: ptr pointer): HRESULT {.stdcall.}
  let hr = callVtbl(self, 36, F, initialValue, flags, addr IID_ID3D12Fence, cast[ptr pointer](addr result))
  if hr < 0:
    raise newException(Exception, "CreateFence failed with HRESULT " & $hr)

proc reset*(self: ID3D12CommandAllocator) =
  type F = proc(this: ID3D12CommandAllocator): HRESULT {.stdcall.}
  let hr = callVtbl0(self, 8, F)
  if hr < 0:
    raise newException(Exception, "ID3D12CommandAllocator.Reset failed with HRESULT " & $hr)

proc reset*(self: ID3D12GraphicsCommandList, allocator: ID3D12CommandAllocator, pipelineState: pointer) =
  type F = proc(this: ID3D12GraphicsCommandList, allocator: ID3D12CommandAllocator, pipelineState: pointer): HRESULT {.stdcall.}
  let hr = callVtbl(self, 10, F, allocator, pipelineState)
  if hr < 0:
    raise newException(Exception, "ID3D12GraphicsCommandList.Reset failed with HRESULT " & $hr)

proc close*(self: ID3D12GraphicsCommandList) =
  type F = proc(this: ID3D12GraphicsCommandList): HRESULT {.stdcall.}
  let hr = callVtbl0(self, 9, F)
  if hr < 0:
    raise newException(Exception, "ID3D12GraphicsCommandList.Close failed with HRESULT " & $hr)

proc resourceBarrier*(self: ID3D12GraphicsCommandList, count: UINT, barriers: ptr D3D12_RESOURCE_BARRIER) =
  type F = proc(this: ID3D12GraphicsCommandList, count: UINT, barriers: ptr D3D12_RESOURCE_BARRIER) {.stdcall.}
  callVtbl(self, 26, F, count, barriers)

proc rsSetViewports*(self: ID3D12GraphicsCommandList, count: UINT, viewports: ptr D3D12_VIEWPORT) =
  type F = proc(this: ID3D12GraphicsCommandList, count: UINT, viewports: ptr D3D12_VIEWPORT): void {.stdcall.}
  callVtbl(self, 21, F, count, viewports)

proc rsSetScissorRects*(self: ID3D12GraphicsCommandList, count: UINT, rects: ptr D3D12_RECT) =
  type F = proc(this: ID3D12GraphicsCommandList, count: UINT, rects: ptr D3D12_RECT): void {.stdcall.}
  callVtbl(self, 22, F, count, rects)

proc omSetRenderTargets*(self: ID3D12GraphicsCommandList, numTargets: UINT, handles: ptr D3D12_CPU_DESCRIPTOR_HANDLE, singleHandle: BOOL32, depthStencil: pointer) =
  type F = proc(this: ID3D12GraphicsCommandList, numTargets: UINT, handles: ptr D3D12_CPU_DESCRIPTOR_HANDLE, singleHandle: BOOL32, depthStencil: pointer): void {.stdcall.}
  callVtbl(self, 46, F, numTargets, handles, singleHandle, depthStencil)

proc clearRenderTargetView*(self: ID3D12GraphicsCommandList, handle: D3D12_CPU_DESCRIPTOR_HANDLE, color: ptr FLOAT, rectCount: UINT, rects: pointer) =
  type F = proc(this: ID3D12GraphicsCommandList, handle: D3D12_CPU_DESCRIPTOR_HANDLE, color: ptr FLOAT, rectCount: UINT, rects: pointer): void {.stdcall.}
  callVtbl(self, 48, F, handle, color, rectCount, rects)

proc setPipelineState*(self: ID3D12GraphicsCommandList, state: ID3D12PipelineState) =
  type F = proc(this: ID3D12GraphicsCommandList, state: ID3D12PipelineState): void {.stdcall.}
  callVtbl(self, 25, F, state)

proc setGraphicsRootSignature*(self: ID3D12GraphicsCommandList, root: ID3D12RootSignature) =
  type F = proc(this: ID3D12GraphicsCommandList, root: ID3D12RootSignature): void {.stdcall.}
  callVtbl(self, 30, F, root)

proc iaSetPrimitiveTopology*(self: ID3D12GraphicsCommandList, topology: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, topology: uint32): void {.stdcall.}
  callVtbl(self, 20, F, topology)

proc iaSetVertexBuffers*(self: ID3D12GraphicsCommandList, startSlot: UINT, viewCount: UINT, views: ptr D3D12_VERTEX_BUFFER_VIEW) =
  type F = proc(this: ID3D12GraphicsCommandList, startSlot: UINT, viewCount: UINT, views: ptr D3D12_VERTEX_BUFFER_VIEW): void {.stdcall.}
  callVtbl(self, 44, F, startSlot, viewCount, views)

proc drawInstanced*(self: ID3D12GraphicsCommandList, vertexCount: UINT, instanceCount: UINT, startVertex: UINT, startInstance: UINT) =
  type F = proc(this: ID3D12GraphicsCommandList, vertexCount: UINT, instanceCount: UINT, startVertex: UINT, startInstance: UINT): void {.stdcall.}
  callVtbl(self, 12, F, vertexCount, instanceCount, startVertex, startInstance)

proc executeCommandLists*(self: ID3D12CommandQueue, count: UINT, lists: ptr ID3D12CommandList) =
  type F = proc(this: ID3D12CommandQueue, count: UINT, lists: ptr ID3D12CommandList): void {.stdcall.}
  callVtbl(self, 10, F, count, lists)

proc signal*(self: ID3D12CommandQueue, fence: ID3D12Fence, value: UINT64) =
  type F = proc(this: ID3D12CommandQueue, fence: ID3D12Fence, value: UINT64): HRESULT {.stdcall.}
  let hr = callVtbl(self, 14, F, fence, value)
  if hr < 0:
    raise newException(Exception, "ID3D12CommandQueue.Signal failed with HRESULT " & $hr)

proc getCPUDescriptorHandleForHeapStart*(self: ID3D12DescriptorHeap): D3D12_CPU_DESCRIPTOR_HANDLE =
  type F = proc(this: ID3D12DescriptorHeap, ret: ptr D3D12_CPU_DESCRIPTOR_HANDLE): ptr D3D12_CPU_DESCRIPTOR_HANDLE {.stdcall.}
  var handle: D3D12_CPU_DESCRIPTOR_HANDLE
  discard callVtbl(self, 9, F, addr handle)
  result = handle

proc present*(self: IDXGISwapChain3, syncInterval: UINT, flags: UINT) =
  type F = proc(this: IDXGISwapChain3, syncInterval: UINT, flags: UINT): HRESULT {.stdcall.}
  let hr = callVtbl(self, 8, F, syncInterval, flags)
  if hr < 0:
    raise newException(Exception, "IDXGISwapChain3.Present failed with HRESULT " & $hr)

proc getBuffer*(self: IDXGISwapChain3, index: UINT): ID3D12Resource =
  const IID_ID3D12Resource = newGuid(0x696442be'u32,0xa72e'u16,0x4059'u16,0xbc'u8,0x79'u8,0x5b'u8,0x5c'u8,0x98'u8,0x04'u8,0x0f'u8,0xad'u8)
  type F = proc(this: IDXGISwapChain3, index: UINT, riid: ptr DXGuid, outBuffer: ptr pointer): HRESULT {.stdcall.}
  let hr = callVtbl(self, 9, F, index, addr IID_ID3D12Resource, cast[ptr pointer](addr result))
  if hr < 0:
    raise newException(Exception, "IDXGISwapChain3.GetBuffer failed with HRESULT " & $hr)

proc getCompletedValue*(self: ID3D12Fence): UINT64 =
  type F = proc(this: ID3D12Fence): UINT64 {.stdcall.}
  callVtbl0(self, 8, F)

proc setEventOnCompletion*(self: ID3D12Fence, value: UINT64, evt: HANDLE) =
  type F = proc(this: ID3D12Fence, value: UINT64, evt: HANDLE): HRESULT {.stdcall.}
  let hr = callVtbl(self, 9, F, value, evt)
  if hr < 0:
    raise newException(Exception, "ID3D12Fence.SetEventOnCompletion failed with HRESULT " & $hr)

proc createSwapChainForHwnd*(factory: IDXGIFactory4, device: pointer, hwnd: HWND, desc: ptr DXGI_SWAP_CHAIN_DESC1, fullscreenDesc: pointer, restrictOutput: IDXGIOutput): IDXGISwapChain1 =
  type F = proc(this: IDXGIFactory4, device: pointer, hwnd: HWND, desc: ptr DXGI_SWAP_CHAIN_DESC1, fullscreenDesc: pointer, restrictOutput: IDXGIOutput, outSwapChain: ptr pointer): HRESULT {.stdcall.}
  let hr = callVtbl(factory, 15, F, device, hwnd, desc, fullscreenDesc, restrictOutput, cast[ptr pointer](addr result))
  if hr < 0:
    raise newException(Exception, "CreateSwapChainForHwnd failed with HRESULT " & $hr)

proc makeWindowAssociation*(factory: IDXGIFactory4, hwnd: HWND, flags: UINT) =
  type F = proc(this: IDXGIFactory4, hwnd: HWND, flags: UINT): HRESULT {.stdcall.}
  let hr = callVtbl(factory, 8, F, hwnd, flags)
  if hr < 0:
    raise newException(Exception, "IDXGIFactory4.MakeWindowAssociation failed with HRESULT " & $hr)

proc queryInterface*[T](iface: pointer, riid: ptr DXGuid): T =
  type F = proc(this: pointer, riid: ptr DXGuid, outObj: ptr pointer): HRESULT {.stdcall.}
  var tmp: pointer
  let hr = callVtbl(iface, 0, F, riid, addr tmp)
  if hr < 0:
    raise newException(Exception, "QueryInterface failed with HRESULT " & $hr)
  result = cast[T](tmp)

# Helper functions

proc upgradeToSwapChain3*(swapChain1: IDXGISwapChain1): IDXGISwapChain3 =
  const IID_IDXGISwapChain3 = newGuid(0x94d99bdb'u32,0xf1f8'u16,0x4ab0'u16,0xb2'u8,0x36'u8,0x7d'u8,0xa0'u8,0x17'u8,0x0e'u8,0xda'u8,0xb1'u8)
  queryInterface[IDXGISwapChain3](swapChain1, addr IID_IDXGISwapChain3)

proc createDxgiFactory2*(flags: UINT): IDXGIFactory4 =
  const IID_IDXGIFactory4 = newGuid(0x1bc6ea02'u32,0xef36'u16,0x464f'u16,0xbf'u8,0x0c'u8,0x21'u8,0xca'u8,0x39'u8,0xe5'u8,0x16'u8,0x8a'u8)
  let hrFactory = CreateDXGIFactory2_Ptr(flags, addr IID_IDXGIFactory4, cast[ptr pointer](addr result))
  if hrFactory < 0:
    raise newException(Exception, "CreateDXGIFactory2 failed with HRESULT " & $hrFactory)

proc d3d12CreateDevice*(pAdapter: pointer, MinimumFeatureLevel: D3D_FEATURE_LEVEL): ID3D12Device =
  const IID_ID3D12Device = newGuid(0x189819f1'u32,0x1db6'u16,0x4b57'u16,0xbe'u8,0x54'u8,0x18'u8,0x21'u8,0x33'u8,0x9b'u8,0x85'u8,0xf7'u8)
  let hr = D3D12CreateDevice_Ptr(pAdapter, MinimumFeatureLevel, addr IID_ID3D12Device, cast[ptr pointer](addr result))
  if hr < 0:
    raise newException(Exception, "D3D12CreateDevice failed with HRESULT " & $hr)

proc loadNativeSymbols*() =
  if d3d12Lib == nil:
    d3d12Lib = loadLib("d3d12.dll")
    if d3d12Lib == nil:
      raise newException(Exception, "Could not load d3d12.dll")

  if D3D12CreateDevice_Ptr == nil:
    let sym = d3d12Lib.symAddr("D3D12CreateDevice")
    if sym == nil:
      raise newException(Exception, "Could not find D3D12CreateDevice")
    D3D12CreateDevice_Ptr = cast[D3D12CreateDevice_t](sym)

  if dxgiLib == nil:
    dxgiLib = loadLib("dxgi.dll")
    if dxgiLib == nil:
      raise newException(Exception, "Could not load dxgi.dll")

  if CreateDXGIFactory2_Ptr == nil:
    let sym = dxgiLib.symAddr("CreateDXGIFactory2")
    if sym == nil:
      raise newException(Exception, "Could not find CreateDXGIFactory2")
    CreateDXGIFactory2_Ptr = cast[CreateDXGIFactory2_t](sym)

  if D3D12SerializeRootSignature_Ptr == nil:
    let sym = d3d12Lib.symAddr("D3D12SerializeRootSignature")
    if sym == nil:
      raise newException(Exception, "Could not find D3D12SerializeRootSignature")
    D3D12SerializeRootSignature_Ptr = cast[D3D12SerializeRootSignature_t](sym)

proc loadCompiler() =
  if d3dCompilerLib == nil:
    d3dCompilerLib = loadLib("d3dcompiler_47.dll")
    if d3dCompilerLib == nil:
      raise newException(Exception, "Could not load d3dcompiler_47.dll")

  if D3DCompile_Ptr == nil:
    let sym = d3dCompilerLib.symAddr("D3DCompile")
    if sym == nil:
      raise newException(Exception, "Could not find D3DCompile")
    D3DCompile_Ptr = cast[D3DCompile_t](sym)

proc getBufferPointer*(blob: ID3DBlob): pointer =
  type F = proc(this: ID3DBlob): pointer {.stdcall.}
  callVtbl0(blob, 3, F)

proc getBufferSize*(blob: ID3DBlob): csize_t =
  type F = proc(this: ID3DBlob): csize_t {.stdcall.}
  callVtbl0(blob, 4, F)

proc serializeRootSignature*(desc: ptr D3D12_ROOT_SIGNATURE_DESC): ID3DBlob =
  loadNativeSymbols()
  var blob: ID3DBlob
  var errorBlob: ID3DBlob
  let hr = D3D12SerializeRootSignature_Ptr(desc, 1'u32, addr blob, addr errorBlob)
  if errorBlob != nil:
    let msgPtr = cast[cstring](getBufferPointer(errorBlob))
    var msg = ""
    if msgPtr != nil:
      msg = $msgPtr
    release(errorBlob)
    if hr < 0:
      raise newException(Exception, "D3D12SerializeRootSignature failed: " & msg)
  if hr < 0:
    raise newException(Exception, "D3D12SerializeRootSignature failed with HRESULT " & $hr)
  result = blob

proc compileShader*(source: string, entryPoint: string, target: string): ID3DBlob =
  loadCompiler()
  var blob: ID3DBlob
  var errorBlob: ID3DBlob
  let hr = D3DCompile_Ptr(
    cast[pointer](source.cstring),
    source.len.csize_t,
    nil,
    nil,
    nil,
    entryPoint.cstring,
    target.cstring,
    0,
    0,
    addr blob,
    addr errorBlob
  )
  if errorBlob != nil:
    let msgPtr = cast[cstring](getBufferPointer(errorBlob))
    var msg = ""
    if msgPtr != nil:
      msg = $msgPtr
    release(errorBlob)
    if hr < 0:
      if blob != nil:
        release(blob)
      raise newException(Exception, "D3DCompile failed: " & msg)
  if hr < 0:
    raise newException(Exception, "D3DCompile failed with HRESULT " & $hr)
  result = blob

proc shaderBytecode*(blob: ID3DBlob): D3D12_SHADER_BYTECODE =
  D3D12_SHADER_BYTECODE(
    pShaderBytecode: getBufferPointer(blob),
    BytecodeLength: getBufferSize(blob)
  )

# --- Helper types and context management ---
type
  D3D12Context* = object
    device*: ID3D12Device
    commandQueue*: ID3D12CommandQueue
    swapChain*: IDXGISwapChain3
    descriptorHeap*: ID3D12DescriptorHeap
    renderTargets*: array[FRAME_COUNT, ID3D12Resource]
    rtvHandles*: array[FRAME_COUNT, D3D12_CPU_DESCRIPTOR_HANDLE]
    commandAllocator*: ID3D12CommandAllocator
    commandList*: ID3D12GraphicsCommandList
    fence*: ID3D12Fence
    fenceValue*: UINT64
    fenceEvent*: HANDLE
    rtvDescriptorSize*: UINT
    currentFrame*: int
    viewport*: D3D12_VIEWPORT
    scissor*: D3D12_RECT

proc offsetHandle*(base: D3D12_CPU_DESCRIPTOR_HANDLE, descriptorSize: UINT, index: int): D3D12_CPU_DESCRIPTOR_HANDLE =
  result = base
  result.ptrValue = base.ptrValue + uint64(descriptorSize) * uint64(index)

proc initDevice*(ctx: var D3D12Context, hwnd: HWND, width, height: int) =
  loadNativeSymbols()

  var factory = createDxgiFactory2(0)
  ctx.device = d3d12CreateDevice(nil, D3D_FEATURE_LEVEL_11_0)

  var queueDesc: D3D12_COMMAND_QUEUE_DESC
  queueDesc.Type = D3D12_COMMAND_LIST_TYPE_DIRECT
  queueDesc.Priority = D3D12_COMMAND_QUEUE_PRIORITY_NORMAL
  queueDesc.Flags = D3D12_COMMAND_QUEUE_FLAG_NONE
  queueDesc.NodeMask = 0
  ctx.commandQueue = ctx.device.createCommandQueue(addr queueDesc)

  var swapDesc: DXGI_SWAP_CHAIN_DESC1
  swapDesc.Width = UINT(width)
  swapDesc.Height = UINT(height)
  swapDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM
  swapDesc.Stereo = 0
  swapDesc.SampleDesc = DXGI_SAMPLE_DESC(Count: 1, Quality: 0)
  swapDesc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT
  swapDesc.BufferCount = FRAME_COUNT
  swapDesc.Scaling = DXGI_SCALING_STRETCH
  swapDesc.SwapEffect = DXGI_SWAP_EFFECT_FLIP_DISCARD
  swapDesc.AlphaMode = DXGI_ALPHA_MODE_UNSPECIFIED
  swapDesc.Flags = 0

  var swapChain1 = factory.createSwapChainForHwnd(
    cast[pointer](ctx.commandQueue),
    hwnd,
    addr swapDesc,
    nil,
    nil
  )
  factory.makeWindowAssociation(hwnd, DXGI_MWA_NO_ALT_ENTER)

  ctx.swapChain = swapChain1.upgradeToSwapChain3()
  swapChain1.release()
  factory.release()

  var heapDesc: D3D12_DESCRIPTOR_HEAP_DESC
  heapDesc.typ = D3D12_DESCRIPTOR_HEAP_TYPE_RTV
  heapDesc.NumDescriptors = FRAME_COUNT
  heapDesc.Flags = D3D12_DESCRIPTOR_HEAP_FLAG_NONE
  heapDesc.NodeMask = 0
  ctx.descriptorHeap = ctx.device.createDescriptorHeap(addr heapDesc)
  if ctx.descriptorHeap == nil:
    raise newException(Exception, "Descriptor heap creation returned nil")

  ctx.rtvDescriptorSize = ctx.device.getDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_RTV)
  let baseHandle = ctx.descriptorHeap.getCPUDescriptorHandleForHeapStart()

  for i in 0..<FRAME_COUNT:
    ctx.rtvHandles[i] = offsetHandle(baseHandle, ctx.rtvDescriptorSize, i)
    ctx.renderTargets[i] = ctx.swapChain.getBuffer(UINT(i))
    ctx.device.createRenderTargetView(ctx.renderTargets[i], nil, ctx.rtvHandles[i])

  ctx.commandAllocator = ctx.device.createCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT)
  ctx.commandList = ctx.device.createCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, ctx.commandAllocator, nil)
  ctx.commandList.close()

  ctx.fence = ctx.device.createFence(0, D3D12_FENCE_FLAG_NONE)
  ctx.fenceValue = 1
  ctx.fenceEvent = CreateEventW(nil, 0, 0, nil)
  if ctx.fenceEvent == 0:
    raise newException(Exception, "Failed to create fence event")

  ctx.viewport = D3D12_VIEWPORT(
    TopLeftX: 0.0, TopLeftY: 0.0,
    Width: FLOAT(width), Height: FLOAT(height),
    MinDepth: 0.0, MaxDepth: 1.0
  )
  ctx.scissor = D3D12_RECT(left: 0, top: 0, right: int32(width), bottom: int32(height))

proc waitForGpu*(ctx: var D3D12Context) =
  let fenceToWait = ctx.fenceValue
  ctx.commandQueue.signal(ctx.fence, fenceToWait)
  inc ctx.fenceValue
  if ctx.fence.getCompletedValue() < fenceToWait:
    ctx.fence.setEventOnCompletion(fenceToWait, ctx.fenceEvent)
    discard WaitForSingleObject(ctx.fenceEvent, WAIT_INFINITE)

proc moveToNextFrame*(ctx: var D3D12Context) =
  let currentFence = ctx.fenceValue
  ctx.commandQueue.signal(ctx.fence, currentFence)
  inc ctx.fenceValue
  if ctx.fence.getCompletedValue() < currentFence:
    ctx.fence.setEventOnCompletion(currentFence, ctx.fenceEvent)
    discard WaitForSingleObject(ctx.fenceEvent, WAIT_INFINITE)
  ctx.currentFrame = (ctx.currentFrame + 1) mod FRAME_COUNT

proc recordCommandList*(ctx: var D3D12Context, color: array[4, FLOAT]) =
  ctx.commandAllocator.reset()
  ctx.commandList.reset(ctx.commandAllocator, nil)

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
  ctx.commandList.clearRenderTargetView(ctx.rtvHandles[ctx.currentFrame], unsafeAddr color[0], 0, nil)

  barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET
  barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT
  ctx.commandList.resourceBarrier(1, addr barrier)

  ctx.commandList.close()

proc executeFrame*(ctx: var D3D12Context) =
  var commandListIface = cast[ID3D12CommandList](ctx.commandList)
  ctx.commandQueue.executeCommandLists(1, addr commandListIface)
  ctx.swapChain.present(1, 0)
  ctx.moveToNextFrame()

proc cleanup*(ctx: var D3D12Context) =
  ctx.waitForGpu()
  for i in 0..<FRAME_COUNT:
    if ctx.renderTargets[i] != nil:
      ctx.renderTargets[i].release()
      ctx.renderTargets[i] = nil
  if ctx.commandAllocator != nil:
    ctx.commandAllocator.release()
    ctx.commandAllocator = nil
  if ctx.commandList != nil:
    ctx.commandList.release()
    ctx.commandList = nil
  if ctx.commandQueue != nil:
    ctx.commandQueue.release()
    ctx.commandQueue = nil
  if ctx.descriptorHeap != nil:
    ctx.descriptorHeap.release()
    ctx.descriptorHeap = nil
  if ctx.swapChain != nil:
    ctx.swapChain.release()
    ctx.swapChain = nil
  if ctx.device != nil:
    ctx.device.release()
    ctx.device = nil
  if ctx.fence != nil:
    ctx.fence.release()
    ctx.fence = nil
  if ctx.fenceEvent != 0:
    discard CloseHandle(ctx.fenceEvent)
    ctx.fenceEvent = 0
