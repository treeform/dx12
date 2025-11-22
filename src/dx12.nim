import dynlib
import windy/platforms/win32/windefs

# --- Basic Win32 / DirectX types ---
type
  HRESULT* = int32
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

  D3D12_RESOURCE_TRANSITION_BARRIER* = object
    pResource*: ID3D12Resource
    Subresource*: UINT
    StateBefore*: D3D12_RESOURCE_STATES
    StateAfter*: D3D12_RESOURCE_STATES

  D3D12_RESOURCE_BARRIER* = object
    typ*: D3D12_RESOURCE_BARRIER_TYPE
    Flags*: D3D12_RESOURCE_BARRIER_FLAGS
    Transition*: D3D12_RESOURCE_TRANSITION_BARRIER

# --- Constants ---
const
  FRAME_COUNT* = 2
  DXGI_FORMAT_R8G8B8A8_UNORM* = 28'u32
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
  D3D12_RESOURCE_STATE_PRESENT* = 0'u32
  D3D12_RESOURCE_STATE_RENDER_TARGET* = 0x4'u32
  D3D12_RESOURCE_BARRIER_TYPE_TRANSITION* = 0'u32
  D3D12_RESOURCE_BARRIER_FLAG_NONE* = 0'u32
  D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES* = 0xffffffff'u32
  D3D12_FENCE_FLAG_NONE* = 0'u32
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

var
  d3d12Lib: LibHandle
  dxgiLib: LibHandle
  D3D12CreateDevice_Ptr: D3D12CreateDevice_t
  CreateDXGIFactory2_Ptr: CreateDXGIFactory2_t

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

proc getDescriptorHandleIncrementSize*(self: ID3D12Device, heapType: D3D12_DESCRIPTOR_HEAP_TYPE): UINT =
  type F = proc(this: ID3D12Device, heapType: D3D12_DESCRIPTOR_HEAP_TYPE): UINT {.stdcall.}
  let hr = callVtbl(self, 15, F, heapType)
  if hr < 0:
    raise newException(Exception, "GetDescriptorHandleIncrementSize failed with HRESULT " & $hr)
  result = UINT(hr)

proc createRenderTargetView*(self: ID3D12Device, resource: ID3D12Resource, desc: pointer, handle: D3D12_CPU_DESCRIPTOR_HANDLE) =
  type F = proc(this: ID3D12Device, resource: ID3D12Resource, desc: pointer, handle: D3D12_CPU_DESCRIPTOR_HANDLE) {.stdcall.}
  callVtbl(self, 20, F, resource, desc, handle)

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
