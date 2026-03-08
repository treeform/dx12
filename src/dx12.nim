import 
  std/dynlib,
  windy/platforms/win32/windefs

# --- Basic Win32 / DirectX types ---
type
  HRESULT* = int32
  UINT64* = uint64
  FLOAT* = float32
  BOOL32* = int32
  DXGI_FEATURE* = uint32
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
  IDXGIFactory5* = ptr object
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

  D3D12_GPU_DESCRIPTOR_HANDLE* = object
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

  D3D12_DEPTH_STENCIL_VALUE* = object
    Depth*: FLOAT
    Stencil*: uint8

  D3D12_CLEAR_VALUE_UNION* {.union.} = object
    Color*: array[4, FLOAT]
    DepthStencil*: D3D12_DEPTH_STENCIL_VALUE

  D3D12_CLEAR_VALUE* = object
    Format*: DXGI_FORMAT
    data*: D3D12_CLEAR_VALUE_UNION

  D3D12_RESOURCE_BARRIER* = object
    typ*: D3D12_RESOURCE_BARRIER_TYPE
    Flags*: D3D12_RESOURCE_BARRIER_FLAGS
    Transition*: D3D12_RESOURCE_TRANSITION_BARRIER

  D3D12_TEXTURE_COPY_LOCATION_UNION* {.union.} = object
    PlacedFootprint*: D3D12_PLACED_SUBRESOURCE_FOOTPRINT
    SubresourceIndex*: uint32

  D3D12_TEXTURE_COPY_LOCATION* = object
    pResource*: ID3D12Resource
    typ*: uint32
    data*: D3D12_TEXTURE_COPY_LOCATION_UNION

  D3D12_BOX* = object
    left*, top*, front*: UINT
    right*, bottom*, back*: UINT

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

  D3D12_SUBRESOURCE_FOOTPRINT* = object
    Format*: DXGI_FORMAT
    Width*: UINT
    Height*: UINT
    Depth*: UINT
    RowPitch*: UINT

  D3D12_PLACED_SUBRESOURCE_FOOTPRINT* = object
    Offset*: UINT64
    Footprint*: D3D12_SUBRESOURCE_FOOTPRINT

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

  D3D12_DESCRIPTOR_RANGE* = object
    RangeType*: uint32
    NumDescriptors*: uint32
    BaseShaderRegister*: uint32
    RegisterSpace*: uint32
    OffsetInDescriptorsFromTableStart*: uint32

  D3D12_ROOT_DESCRIPTOR_TABLE* = object
    NumDescriptorRanges*: uint32
    pDescriptorRanges*: ptr D3D12_DESCRIPTOR_RANGE

  D3D12_ROOT_DESCRIPTOR* = object
    ShaderRegister*: uint32
    RegisterSpace*: uint32

  D3D12_ROOT_CONSTANTS* = object
    ShaderRegister*: uint32
    RegisterSpace*: uint32
    Num32BitValues*: uint32

  D3D12_ROOT_PARAMETER_UNION* {.union.} = object
    DescriptorTable*: D3D12_ROOT_DESCRIPTOR_TABLE
    Constants*: D3D12_ROOT_CONSTANTS
    Descriptor*: D3D12_ROOT_DESCRIPTOR

  D3D12_ROOT_PARAMETER* = object
    ParameterType*: uint32
    data*: D3D12_ROOT_PARAMETER_UNION
    ShaderVisibility*: uint32

  D3D12_STATIC_SAMPLER_DESC* = object
    Filter*: uint32
    AddressU*: uint32
    AddressV*: uint32
    AddressW*: uint32
    MipLODBias*: FLOAT
    MaxAnisotropy*: uint32
    ComparisonFunc*: uint32
    BorderColor*: uint32
    MinLOD*: FLOAT
    MaxLOD*: FLOAT
    ShaderRegister*: uint32
    RegisterSpace*: uint32
    ShaderVisibility*: uint32

  D3D12_STREAM_OUTPUT_DESC* = object
    pSODeclaration*: pointer
    NumEntries*: UINT
    pBufferStrides*: pointer
    NumStrides*: UINT
    RasterizedStream*: UINT

  D3D12_TEX2D_SRV* = object
    MostDetailedMip*: uint32
    MipLevels*: uint32
    PlaneSlice*: uint32
    ResourceMinLODClamp*: FLOAT

  D3D12_BUFFER_SRV* = object
    FirstElement*: UINT64
    NumElements*: UINT
    StructureByteStride*: UINT
    Flags*: uint32

  D3D12_TEX2D_ARRAY_SRV* = object
    MostDetailedMip*: uint32
    MipLevels*: uint32
    FirstArraySlice*: uint32
    ArraySize*: uint32
    PlaneSlice*: uint32
    ResourceMinLODClamp*: FLOAT

  D3D12_SHADER_RESOURCE_VIEW_DESC_UNION* {.union.} = object
    Buffer*: D3D12_BUFFER_SRV
    Texture2D*: D3D12_TEX2D_SRV
    Texture2DArray*: D3D12_TEX2D_ARRAY_SRV

  D3D12_SHADER_RESOURCE_VIEW_DESC* = object
    Format*: DXGI_FORMAT
    ViewDimension*: uint32
    Shader4ComponentMapping*: uint32
    data*: D3D12_SHADER_RESOURCE_VIEW_DESC_UNION

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
  DXGI_FORMAT_D32_FLOAT* = 40'u32
  DXGI_FORMAT_R32G32B32_FLOAT* = 6'u32
  DXGI_FORMAT_R32G32_FLOAT* = 16'u32
  DXGI_FORMAT_UNKNOWN* = 0'u32
  DXGI_USAGE_RENDER_TARGET_OUTPUT* = 0x20'u32
  DXGI_SCALING_STRETCH* = 0'u32
  DXGI_SWAP_EFFECT_FLIP_DISCARD* = 4'u32
  DXGI_SWAP_CHAIN_FLAG_ALLOW_TEARING* = 0x800'u32
  DXGI_PRESENT_ALLOW_TEARING* = 0x200'u32
  DXGI_FEATURE_PRESENT_ALLOW_TEARING* = 0'u32
  DXGI_ALPHA_MODE_UNSPECIFIED* = 0'u32
  DXGI_MWA_NO_ALT_ENTER* = 0x2'u32

  D3D_FEATURE_LEVEL_11_0* = 0xb000'u32
  D3D12_COMMAND_LIST_TYPE_DIRECT* = 0'u32
  D3D12_COMMAND_QUEUE_FLAG_NONE* = 0'u32
  D3D12_COMMAND_QUEUE_PRIORITY_NORMAL* = 0
  D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV* = 0'u32
  D3D12_DESCRIPTOR_HEAP_TYPE_RTV* = 2'u32
  D3D12_DESCRIPTOR_HEAP_TYPE_DSV* = 3'u32
  D3D12_DESCRIPTOR_HEAP_FLAG_NONE* = 0'u32
  D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE* = 0x1'u32
  D3D12_HEAP_TYPE_DEFAULT* = 1'u32
  D3D12_HEAP_TYPE_UPLOAD* = 2'u32
  D3D12_HEAP_FLAG_NONE* = 0'u32
  D3D12_RESOURCE_DIMENSION_BUFFER* = 1'u32
  D3D12_RESOURCE_DIMENSION_TEXTURE2D* = 3'u32
  D3D12_TEXTURE_LAYOUT_ROW_MAJOR* = 1'u32
  D3D12_TEXTURE_LAYOUT_UNKNOWN* = 0'u32
  D3D12_RESOURCE_FLAG_NONE* = 0'u32
  D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET* = 0x1'u32
  D3D12_RESOURCE_FLAG_ALLOW_DEPTH_STENCIL* = 0x2'u32
  D3D12_RESOURCE_STATE_PRESENT* = 0'u32
  D3D12_RESOURCE_STATE_RENDER_TARGET* = 0x4'u32
  D3D12_RESOURCE_STATE_DEPTH_WRITE* = 0x10'u32
  D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER* = 0x1'u32
  D3D12_RESOURCE_STATE_GENERIC_READ* = 0x1'u32 or 0x2'u32 or
    0x40'u32 or 0x80'u32 or 0x200'u32 or 0x800'u32
  D3D12_RESOURCE_STATE_COPY_DEST* = 0x400'u32
  D3D12_RESOURCE_STATE_RESOLVE_DEST* = 0x1000'u32
  D3D12_RESOURCE_STATE_RESOLVE_SOURCE* = 0x2000'u32
  D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE* = 0x80'u32
  D3D12_RESOURCE_BARRIER_TYPE_TRANSITION* = 0'u32
  D3D12_RESOURCE_BARRIER_FLAG_NONE* = 0'u32
  D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES* = 0xffffffff'u32
  D3D12_FENCE_FLAG_NONE* = 0'u32
  D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA* = 0'u32
  D3D12_FILL_MODE_SOLID* = 3'u32
  D3D12_CULL_MODE_NONE* = 1'u32
  D3D12_CULL_MODE_BACK* = 3'u32
  D3D12_BLEND_ZERO* = 1'u32
  D3D12_BLEND_ONE* = 2'u32
  D3D12_BLEND_SRC_ALPHA* = 5'u32
  D3D12_BLEND_INV_SRC_ALPHA* = 6'u32
  D3D12_BLEND_OP_ADD* = 1'u32
  D3D12_COLOR_WRITE_ENABLE_ALL* = 0x0f'u32
  D3D12_DEPTH_WRITE_MASK_ALL* = 1'u32
  D3D12_COMPARISON_FUNC_LESS* = 2'u32
  D3D12_COMPARISON_FUNC_ALWAYS* = 8'u32
  D3D12_STENCIL_OP_KEEP* = 1'u32
  D3D12_CONSERVATIVE_RASTERIZATION_MODE_OFF* = 0'u32
  D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE* = 3'u32
  D3D12_DESCRIPTOR_RANGE_TYPE_SRV* = 0'u32
  D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS* = 1'u32
  D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE* = 0'u32
  D3D12_ROOT_PARAMETER_TYPE_CBV* = 2'u32
  D3D12_ROOT_PARAMETER_TYPE_SRV* = 3'u32
  D3D12_ROOT_PARAMETER_TYPE_UAV* = 4'u32
  D3D12_SHADER_VISIBILITY_ALL* = 0'u32
  D3D12_SHADER_VISIBILITY_PIXEL* = 5'u32
  D3D12_STATIC_BORDER_COLOR_TRANSPARENT_BLACK* = 0'u32
  D3D12_STATIC_BORDER_COLOR_OPAQUE_BLACK* = 1'u32
  D3D12_STATIC_BORDER_COLOR_OPAQUE_WHITE* = 2'u32
  D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND* = 0xffffffff'u32
  D3D12_FILTER_ANISOTROPIC* = 0x55'u32
  D3D12_FILTER_MIN_MAG_MIP_LINEAR* = 0x15'u32
  D3D12_TEXTURE_ADDRESS_MODE_CLAMP* = 3'u32
  D3D12_TEXTURE_ADDRESS_MODE_WRAP* = 1'u32
  D3D12_CLEAR_FLAG_DEPTH* = 0x1'u32
  D3D12_SRV_DIMENSION_TEXTURE2D* = 4'u32
  D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX* = 0'u32
  D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT* = 1'u32
  D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING* = 0x1688'u32
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

proc createDepthStencilView*(
    self: ID3D12Device,
    resource: ID3D12Resource,
    desc: pointer,
    handle: D3D12_CPU_DESCRIPTOR_HANDLE
  ) =
  type F = proc(
    this: ID3D12Device,
    resource: ID3D12Resource,
    desc: pointer,
    handle: D3D12_CPU_DESCRIPTOR_HANDLE
  ) {.stdcall.}
  callVtbl(self, 21, F, resource, desc, handle)

proc createShaderResourceView*(
    self: ID3D12Device,
    resource: ID3D12Resource,
    desc: ptr D3D12_SHADER_RESOURCE_VIEW_DESC,
    handle: D3D12_CPU_DESCRIPTOR_HANDLE
  ) =
  type F = proc(
    this: ID3D12Device,
    resource: ID3D12Resource,
    desc: ptr D3D12_SHADER_RESOURCE_VIEW_DESC,
    handle: D3D12_CPU_DESCRIPTOR_HANDLE
  ) {.stdcall.}
  callVtbl(self, 18, F, resource, desc, handle)

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

proc getCopyableFootprints*(self: ID3D12Device, desc: ptr D3D12_RESOURCE_DESC, firstSubresource: UINT, numSubresources: UINT, baseOffset: UINT64, layouts: ptr D3D12_PLACED_SUBRESOURCE_FOOTPRINT, numRows: ptr UINT, rowSizeInBytes: ptr UINT64, totalBytes: ptr UINT64) =
  type F = proc(
    this: ID3D12Device,
    desc: ptr D3D12_RESOURCE_DESC,
    firstSubresource: UINT,
    numSubresources: UINT,
    baseOffset: UINT64,
    layouts: ptr D3D12_PLACED_SUBRESOURCE_FOOTPRINT,
    numRows: ptr UINT,
    rowSizeInBytes: ptr UINT64,
    totalBytes: ptr UINT64
  ) {.stdcall.}
  callVtbl(self, 38, F, desc, firstSubresource, numSubresources, baseOffset, layouts, numRows, rowSizeInBytes, totalBytes)

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

proc copyBufferRegion*(self: ID3D12GraphicsCommandList, dst: ID3D12Resource, dstOffset: UINT64, src: ID3D12Resource, srcOffset: UINT64, numBytes: UINT64) =
  type F = proc(this: ID3D12GraphicsCommandList, dst: ID3D12Resource, dstOffset: UINT64, src: ID3D12Resource, srcOffset: UINT64, numBytes: UINT64): void {.stdcall.}
  callVtbl(self, 15, F, dst, dstOffset, src, srcOffset, numBytes)

proc copyTextureRegion*(self: ID3D12GraphicsCommandList, dst: ptr D3D12_TEXTURE_COPY_LOCATION, dstX, dstY, dstZ: UINT, src: ptr D3D12_TEXTURE_COPY_LOCATION, srcBox: ptr D3D12_BOX) =
  type F = proc(this: ID3D12GraphicsCommandList, dst: ptr D3D12_TEXTURE_COPY_LOCATION, dstX, dstY, dstZ: UINT, src: ptr D3D12_TEXTURE_COPY_LOCATION, srcBox: ptr D3D12_BOX): void {.stdcall.}
  callVtbl(self, 16, F, dst, dstX, dstY, dstZ, src, srcBox)

proc resolveSubresource*(
    self: ID3D12GraphicsCommandList,
    dstResource: ID3D12Resource,
    dstSubresource: UINT,
    srcResource: ID3D12Resource,
    srcSubresource: UINT,
    format: DXGI_FORMAT
  ) =
  type F = proc(
    this: ID3D12GraphicsCommandList,
    dstResource: ID3D12Resource,
    dstSubresource: UINT,
    srcResource: ID3D12Resource,
    srcSubresource: UINT,
    format: DXGI_FORMAT
  ): void {.stdcall.}
  callVtbl(
    self,
    19,
    F,
    dstResource,
    dstSubresource,
    srcResource,
    srcSubresource,
    format
  )

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

proc clearDepthStencilView*(
    self: ID3D12GraphicsCommandList,
    handle: D3D12_CPU_DESCRIPTOR_HANDLE,
    flags: uint32,
    depth: FLOAT,
    stencil: uint8,
    rectCount: UINT,
    rects: pointer
  ) =
  type F = proc(
    this: ID3D12GraphicsCommandList,
    handle: D3D12_CPU_DESCRIPTOR_HANDLE,
    flags: uint32,
    depth: FLOAT,
    stencil: uint8,
    rectCount: UINT,
    rects: pointer
  ): void {.stdcall.}
  callVtbl(self, 47, F, handle, flags, depth, stencil, rectCount, rects)

proc clearRenderTargetView*(self: ID3D12GraphicsCommandList, handle: D3D12_CPU_DESCRIPTOR_HANDLE, color: ptr FLOAT, rectCount: UINT, rects: pointer) =
  type F = proc(this: ID3D12GraphicsCommandList, handle: D3D12_CPU_DESCRIPTOR_HANDLE, color: ptr FLOAT, rectCount: UINT, rects: pointer): void {.stdcall.}
  callVtbl(self, 48, F, handle, color, rectCount, rects)

proc setPipelineState*(self: ID3D12GraphicsCommandList, state: ID3D12PipelineState) =
  type F = proc(this: ID3D12GraphicsCommandList, state: ID3D12PipelineState): void {.stdcall.}
  callVtbl(self, 25, F, state)

proc setDescriptorHeaps*(self: ID3D12GraphicsCommandList, heapCount: UINT, heaps: ptr ID3D12DescriptorHeap) =
  type F = proc(this: ID3D12GraphicsCommandList, heapCount: UINT, heaps: ptr ID3D12DescriptorHeap): void {.stdcall.}
  callVtbl(self, 28, F, heapCount, heaps)

proc setGraphicsRootSignature*(self: ID3D12GraphicsCommandList, root: ID3D12RootSignature) =
  type F = proc(this: ID3D12GraphicsCommandList, root: ID3D12RootSignature): void {.stdcall.}
  callVtbl(self, 30, F, root)

proc setGraphicsRootDescriptorTable*(self: ID3D12GraphicsCommandList, parameterIndex: UINT, baseDescriptor: D3D12_GPU_DESCRIPTOR_HANDLE) =
  type F = proc(this: ID3D12GraphicsCommandList, parameterIndex: UINT, baseDescriptor: D3D12_GPU_DESCRIPTOR_HANDLE): void {.stdcall.}
  callVtbl(self, 32, F, parameterIndex, baseDescriptor)

proc setGraphicsRoot32BitConstants*(self: ID3D12GraphicsCommandList, parameterIndex: UINT, numValues: UINT, data: pointer, destOffset: UINT) =
  type F = proc(this: ID3D12GraphicsCommandList, parameterIndex: UINT, numValues: UINT, data: pointer, destOffset: UINT): void {.stdcall.}
  callVtbl(self, 36, F, parameterIndex, numValues, data, destOffset)

proc setGraphicsRootConstantBufferView*(self: ID3D12GraphicsCommandList, parameterIndex: UINT, gpuAddress: UINT64) =
  type F = proc(this: ID3D12GraphicsCommandList, parameterIndex: UINT, gpuAddress: UINT64): void {.stdcall.}
  callVtbl(self, 38, F, parameterIndex, gpuAddress)

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

proc getGPUDescriptorHandleForHeapStart*(self: ID3D12DescriptorHeap): D3D12_GPU_DESCRIPTOR_HANDLE =
  type F = proc(this: ID3D12DescriptorHeap, ret: ptr D3D12_GPU_DESCRIPTOR_HANDLE): ptr D3D12_GPU_DESCRIPTOR_HANDLE {.stdcall.}
  var handle: D3D12_GPU_DESCRIPTOR_HANDLE
  discard callVtbl(self, 10, F, addr handle)
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

proc resizeBuffers*(
    self: IDXGISwapChain3,
    bufferCount,
    width,
    height,
    newFormat,
    swapChainFlags: UINT
  ) =
  ## Resizes the swap-chain back buffers.
  type F = proc(
      this: IDXGISwapChain3,
      bufferCount,
      width,
      height,
      newFormat,
      swapChainFlags: UINT
    ): HRESULT {.stdcall.}
  let hr = callVtbl(
    self,
    13,
    F,
    bufferCount,
    width,
    height,
    newFormat,
    swapChainFlags
  )
  if hr < 0:
    raise newException(
      Exception,
      "IDXGISwapChain3.ResizeBuffers failed with HRESULT " & $hr
    )

proc getCurrentBackBufferIndex*(self: IDXGISwapChain3): UINT =
  ## Returns the current swap-chain back buffer index.
  type F = proc(this: IDXGISwapChain3): UINT {.stdcall.}
  callVtbl0(self, 36, F)

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

proc checkFeatureSupport*(
  factory: IDXGIFactory5,
  feature: DXGI_FEATURE,
  supportData: pointer,
  supportDataSize: UINT
) =
  type F = proc(
    this: IDXGIFactory5,
    feature: DXGI_FEATURE,
    supportData: pointer,
    supportDataSize: UINT
  ): HRESULT {.stdcall.}
  let hr = callVtbl(
    factory,
    28,
    F,
    feature,
    supportData,
    supportDataSize
  )
  if hr < 0:
    raise newException(
      Exception,
      "IDXGIFactory5.CheckFeatureSupport failed with HRESULT " & $hr
    )

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

proc upgradeToFactory5*(factory4: IDXGIFactory4): IDXGIFactory5 =
  const IID_IDXGIFactory5 = newGuid(
    0x7632e1f5'u32,
    0xee65'u16,
    0x4dca'u16,
    0x87'u8,
    0xfd'u8,
    0x84'u8,
    0xcd'u8,
    0x75'u8,
    0xf8'u8,
    0x83'u8,
    0x8d'u8
  )
  queryInterface[IDXGIFactory5](factory4, addr IID_IDXGIFactory5)

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

proc compileShader*(source: string, entryPoint: string, target: string, flags: uint32 = 0): ID3DBlob =
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
    flags,
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
