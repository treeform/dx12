import dynlib, math
import windy
import windy/platforms/win32/windefs

# import dx12a_factory # reuse GUID helpers + factory IID

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

# --- GUIDs we need ---
var
  IID_IDXGIFactory4* = newGuid(0x1bc6ea02,0xef36,0x464f,0xbf,0x0c,0x21,0xca,0x39,0xe5,0x16,0x8a)
  IID_ID3D12Device* = newGuid(0x189819f1'u32,0x1db6'u16,0x4b57'u16,0xbe'u8,0x54'u8,0x18'u8,0x21'u8,0x33'u8,0x9b'u8,0x85'u8,0xf7'u8)
  IID_ID3D12CommandQueue* = newGuid(0x0ec870a6'u32,0x5d7e'u16,0x4c22'u16,0x8c'u8,0xfc'u8,0x5b'u8,0xaa'u8,0xe0'u8,0x76'u8,0x16'u8,0xed'u8)
  IID_ID3D12CommandAllocator* = newGuid(0x6102dee4'u32,0xaf59'u16,0x4b09'u16,0xb9'u8,0x99'u8,0xb4'u8,0x4d'u8,0x73'u8,0xf0'u8,0x9b'u8,0x24'u8)
  IID_ID3D12GraphicsCommandList* = newGuid(0x5b160d0f'u32,0xac1b'u16,0x4185'u16,0x8b'u8,0xa8'u8,0xb3'u8,0xae'u8,0x42'u8,0xa5'u8,0xa4'u8,0x55'u8)
  IID_ID3D12DescriptorHeap* = newGuid(0x8efb471d'u32,0x616c'u16,0x4f49'u16,0x90'u8,0xf7'u8,0x12'u8,0x7b'u8,0xb7'u8,0x63'u8,0xfa'u8,0x51'u8)
  IID_ID3D12Resource* = newGuid(0x696442be'u32,0xa72e'u16,0x4059'u16,0xbc'u8,0x79'u8,0x5b'u8,0x5c'u8,0x98'u8,0x04'u8,0x0f'u8,0xad'u8)
  IID_ID3D12Fence* = newGuid(0x0a753dcf'u32,0xc4d8'u16,0x4b91'u16,0xad'u8,0xf6'u8,0xbe'u8,0x5a'u8,0x60'u8,0xd9'u8,0x5a'u8,0x76'u8)
  IID_IDXGISwapChain1* = newGuid(0x790a45f7'u32,0x0d42'u16,0x4876'u16,0x98'u8,0x3a'u8,0x0a'u8,0x55'u8,0xcf'u8,0xe6'u8,0xf4'u8,0xaa'u8)
  IID_IDXGISwapChain3* = newGuid(0x94d99bdb'u32,0xf1f8'u16,0x4ab0'u16,0xb2'u8,0x36'u8,0x7d'u8,0xa0'u8,0x17'u8,0x0e'u8,0xda'u8,0xb1'u8)

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

template checkHr(hr: HRESULT, msg: string) =
  if hr != S_OK:
    quit(msg & " failed with HRESULT " & $hr)

proc loadNativeSymbols() =
  if d3d12Lib == nil:
    d3d12Lib = loadLib("d3d12.dll")
    if d3d12Lib == nil:
      quit("Could not load d3d12.dll")

  if D3D12CreateDevice_Ptr == nil:
    let sym = d3d12Lib.symAddr("D3D12CreateDevice")
    if sym == nil:
      quit("Could not find D3D12CreateDevice")
    D3D12CreateDevice_Ptr = cast[D3D12CreateDevice_t](sym)

  if dxgiLib == nil:
    dxgiLib = loadLib("dxgi.dll")
    if dxgiLib == nil:
      quit("Could not load dxgi.dll")

  if CreateDXGIFactory2_Ptr == nil:
    let sym = dxgiLib.symAddr("CreateDXGIFactory2")
    if sym == nil:
      quit("Could not find CreateDXGIFactory2")
    CreateDXGIFactory2_Ptr = cast[CreateDXGIFactory2_t](sym)

proc release(obj: pointer) =
  if obj == nil:
    raise newException(Exception, "COM object is nil")
  type ReleaseProc = proc(this: pointer): uint32 {.stdcall.}
  let hr = callVtbl0(obj, 2, ReleaseProc)
  if hr < 0:
    raise newException(Exception, "COM object release failed with HRESULT " & $hr)

# --- Thin wrappers for the specific methods we need ---
# proc CreateCommandQueue(self: ID3D12Device, desc: ptr D3D12_COMMAND_QUEUE_DESC, riid: ptr DXGuid, outQueue: ptr pointer): HRESULT =
#   type F = proc(this: ID3D12Device, desc: ptr D3D12_COMMAND_QUEUE_DESC, riid: ptr DXGuid, outQueue: ptr pointer): HRESULT {.stdcall.}
#   callVtbl(self, 8, F, desc, riid, outQueue)

proc CreateCommandQueue(self: ID3D12Device, desc: ptr D3D12_COMMAND_QUEUE_DESC, riid: ptr DXGuid): ID3D12CommandQueue =
  type F = proc(this: ID3D12Device, desc: ptr D3D12_COMMAND_QUEUE_DESC, riid: ptr DXGuid, outQueue: ptr ID3D12CommandQueue): HRESULT {.stdcall.}
  let hr = callVtbl(self, 8, F, desc, riid, addr result)
  if hr < 0:
    raise newException(Exception, "CreateCommandQueue failed with HRESULT " & $hr)

proc CreateCommandAllocator(self: ID3D12Device, typ: D3D12_COMMAND_LIST_TYPE, riid: ptr DXGuid, outAlloc: ptr pointer): HRESULT =
  type F = proc(this: ID3D12Device, typ: D3D12_COMMAND_LIST_TYPE, riid: ptr DXGuid, outAlloc: ptr pointer): HRESULT {.stdcall.}
  callVtbl(self, 9, F, typ, riid, outAlloc)

proc CreateCommandList(self: ID3D12Device, nodeMask: UINT, typ: D3D12_COMMAND_LIST_TYPE, allocator: ID3D12CommandAllocator, initialState: pointer, riid: ptr DXGuid, outList: ptr pointer): HRESULT =
  type F = proc(this: ID3D12Device, nodeMask: UINT, typ: D3D12_COMMAND_LIST_TYPE, allocator: ID3D12CommandAllocator, initialState: pointer, riid: ptr DXGuid, outList: ptr pointer): HRESULT {.stdcall.}
  callVtbl(self, 12, F, nodeMask, typ, allocator, initialState, riid, outList)

proc CreateDescriptorHeap(self: ID3D12Device, desc: ptr D3D12_DESCRIPTOR_HEAP_DESC, riid: ptr DXGuid, outHeap: ptr pointer): HRESULT =
  type F = proc(this: ID3D12Device, desc: ptr D3D12_DESCRIPTOR_HEAP_DESC, riid: ptr DXGuid, outHeap: ptr pointer): HRESULT {.stdcall.}
  callVtbl(self, 14, F, desc, riid, outHeap)

proc GetDescriptorHandleIncrementSize(self: ID3D12Device, heapType: D3D12_DESCRIPTOR_HEAP_TYPE): UINT =
  type F = proc(this: ID3D12Device, heapType: D3D12_DESCRIPTOR_HEAP_TYPE): UINT {.stdcall.}
  callVtbl(self, 15, F, heapType)

proc CreateRenderTargetView(self: ID3D12Device, resource: ID3D12Resource, desc: pointer, handle: D3D12_CPU_DESCRIPTOR_HANDLE) =
  type F = proc(this: ID3D12Device, resource: ID3D12Resource, desc: pointer, handle: D3D12_CPU_DESCRIPTOR_HANDLE) {.stdcall.}
  callVtbl(self, 20, F, resource, desc, handle)

proc CreateFence(self: ID3D12Device, initialValue: UINT64, flags: uint32, riid: ptr DXGuid, outFence: ptr pointer): HRESULT =
  type F = proc(this: ID3D12Device, initialValue: UINT64, flags: uint32, riid: ptr DXGuid, outFence: ptr pointer): HRESULT {.stdcall.}
  callVtbl(self, 36, F, initialValue, flags, riid, outFence)

proc Reset(self: ID3D12CommandAllocator): HRESULT =
  type F = proc(this: ID3D12CommandAllocator): HRESULT {.stdcall.}
  callVtbl0(self, 8, F)

proc Reset(self: ID3D12GraphicsCommandList, allocator: ID3D12CommandAllocator, pipelineState: pointer): HRESULT =
  type F = proc(this: ID3D12GraphicsCommandList, allocator: ID3D12CommandAllocator, pipelineState: pointer): HRESULT {.stdcall.}
  callVtbl(self, 10, F, allocator, pipelineState)

proc Close(self: ID3D12GraphicsCommandList): HRESULT =
  type F = proc(this: ID3D12GraphicsCommandList): HRESULT {.stdcall.}
  callVtbl0(self, 9, F)

proc ResourceBarrier(self: ID3D12GraphicsCommandList, count: UINT, barriers: ptr D3D12_RESOURCE_BARRIER) =
  type F = proc(this: ID3D12GraphicsCommandList, count: UINT, barriers: ptr D3D12_RESOURCE_BARRIER) {.stdcall.}
  callVtbl(self, 26, F, count, barriers)

proc RSSetViewports(self: ID3D12GraphicsCommandList, count: UINT, viewports: ptr D3D12_VIEWPORT) =
  type F = proc(this: ID3D12GraphicsCommandList, count: UINT, viewports: ptr D3D12_VIEWPORT): void {.stdcall.}
  callVtbl(self, 21, F, count, viewports)

proc RSSetScissorRects(self: ID3D12GraphicsCommandList, count: UINT, rects: ptr D3D12_RECT) =
  type F = proc(this: ID3D12GraphicsCommandList, count: UINT, rects: ptr D3D12_RECT): void {.stdcall.}
  callVtbl(self, 22, F, count, rects)

proc OMSetRenderTargets(self: ID3D12GraphicsCommandList, numTargets: UINT, handles: ptr D3D12_CPU_DESCRIPTOR_HANDLE, singleHandle: BOOL32, depthStencil: pointer) =
  type F = proc(this: ID3D12GraphicsCommandList, numTargets: UINT, handles: ptr D3D12_CPU_DESCRIPTOR_HANDLE, singleHandle: BOOL32, depthStencil: pointer): void {.stdcall.}
  callVtbl(self, 46, F, numTargets, handles, singleHandle, depthStencil)

proc ClearRenderTargetView(self: ID3D12GraphicsCommandList, handle: D3D12_CPU_DESCRIPTOR_HANDLE, color: ptr FLOAT, rectCount: UINT, rects: pointer) =
  type F = proc(this: ID3D12GraphicsCommandList, handle: D3D12_CPU_DESCRIPTOR_HANDLE, color: ptr FLOAT, rectCount: UINT, rects: pointer): void {.stdcall.}
  callVtbl(self, 48, F, handle, color, rectCount, rects)

proc ExecuteCommandLists(self: ID3D12CommandQueue, count: UINT, lists: ptr ID3D12CommandList) =
  type F = proc(this: ID3D12CommandQueue, count: UINT, lists: ptr ID3D12CommandList): void {.stdcall.}
  callVtbl(self, 10, F, count, lists)

proc Signal(self: ID3D12CommandQueue, fence: ID3D12Fence, value: UINT64): HRESULT =
  type F = proc(this: ID3D12CommandQueue, fence: ID3D12Fence, value: UINT64): HRESULT {.stdcall.}
  callVtbl(self, 14, F, fence, value)

proc GetCPUDescriptorHandleForHeapStart(self: ID3D12DescriptorHeap): D3D12_CPU_DESCRIPTOR_HANDLE =
  when defined(vcc):
    type F = proc(this: ID3D12DescriptorHeap): D3D12_CPU_DESCRIPTOR_HANDLE {.stdcall.}
    result = callVtbl0(self, 9, F)
  else:
    type F = proc(this: ID3D12DescriptorHeap, ret: ptr D3D12_CPU_DESCRIPTOR_HANDLE): ptr D3D12_CPU_DESCRIPTOR_HANDLE {.stdcall.}
    var handle: D3D12_CPU_DESCRIPTOR_HANDLE
    discard callVtbl(self, 9, F, addr handle)
    result = handle

proc Present(self: IDXGISwapChain3, syncInterval: UINT, flags: UINT): HRESULT =
  type F = proc(this: IDXGISwapChain3, syncInterval: UINT, flags: UINT): HRESULT {.stdcall.}
  callVtbl(self, 8, F, syncInterval, flags)

proc GetBuffer(self: IDXGISwapChain3, index: UINT, riid: ptr DXGuid, outBuffer: ptr pointer): HRESULT =
  type F = proc(this: IDXGISwapChain3, index: UINT, riid: ptr DXGuid, outBuffer: ptr pointer): HRESULT {.stdcall.}
  callVtbl(self, 9, F, index, riid, outBuffer)

proc GetCompletedValue(self: ID3D12Fence): UINT64 =
  type F = proc(this: ID3D12Fence): UINT64 {.stdcall.}
  callVtbl0(self, 8, F)

proc SetEventOnCompletion(self: ID3D12Fence, value: UINT64, evt: HANDLE): HRESULT =
  type F = proc(this: ID3D12Fence, value: UINT64, evt: HANDLE): HRESULT {.stdcall.}
  callVtbl(self, 9, F, value, evt)

proc CreateSwapChainForHwnd(factory: IDXGIFactory4, device: pointer, hwnd: HWND, desc: ptr DXGI_SWAP_CHAIN_DESC1, fullscreenDesc: pointer, restrictOutput: IDXGIOutput, outSwapChain: ptr pointer): HRESULT =
  type F = proc(this: IDXGIFactory4, device: pointer, hwnd: HWND, desc: ptr DXGI_SWAP_CHAIN_DESC1, fullscreenDesc: pointer, restrictOutput: IDXGIOutput, outSwapChain: ptr pointer): HRESULT {.stdcall.}
  callVtbl(factory, 15, F, device, hwnd, desc, fullscreenDesc, restrictOutput, outSwapChain)

proc MakeWindowAssociation(factory: IDXGIFactory4, hwnd: HWND, flags: UINT): HRESULT =
  type F = proc(this: IDXGIFactory4, hwnd: HWND, flags: UINT): HRESULT {.stdcall.}
  callVtbl(factory, 8, F, hwnd, flags)

proc QueryInterface(iface: pointer, riid: ptr DXGuid, outObj: ptr pointer): HRESULT =
  type F = proc(this: pointer, riid: ptr DXGuid, outObj: ptr pointer): HRESULT {.stdcall.}
  callVtbl(iface, 0, F, riid, outObj)

# --- Helper types ---
type
  D3D12Context* = object
    device: ID3D12Device
    commandQueue: ID3D12CommandQueue
    swapChain: IDXGISwapChain3
    descriptorHeap: ID3D12DescriptorHeap
    renderTargets: array[FRAME_COUNT, ID3D12Resource]
    rtvHandles: array[FRAME_COUNT, D3D12_CPU_DESCRIPTOR_HANDLE]
    commandAllocator: ID3D12CommandAllocator
    commandList: ID3D12GraphicsCommandList
    fence: ID3D12Fence
    fenceValue: UINT64
    fenceEvent: HANDLE
    rtvDescriptorSize: UINT
    currentFrame: int
    viewport: D3D12_VIEWPORT
    scissor: D3D12_RECT

proc offsetHandle(base: D3D12_CPU_DESCRIPTOR_HANDLE, descriptorSize: UINT, index: int): D3D12_CPU_DESCRIPTOR_HANDLE =
  result = base
  result.ptrValue = base.ptrValue + uint64(descriptorSize) * uint64(index)

proc initDevice(ctx: var D3D12Context, hwnd: HWND, width, height: int) =
  loadNativeSymbols()

  # Create DXGI factory 4
  var factory: IDXGIFactory4
  checkHr(CreateDXGIFactory2_Ptr(0, addr IID_IDXGIFactory4, cast[ptr pointer](addr factory)), "CreateDXGIFactory2")
  # var factory = CreateDXGIFactory2_Ptr(0, addr IID_IDXGIFactory4)

  # Create D3D12 device
  checkHr(D3D12CreateDevice_Ptr(nil, D3D_FEATURE_LEVEL_11_0, addr IID_ID3D12Device, cast[ptr pointer](addr ctx.device)), "D3D12CreateDevice")

  # Create command queue
  var queueDesc: D3D12_COMMAND_QUEUE_DESC
  queueDesc.Type = D3D12_COMMAND_LIST_TYPE_DIRECT
  queueDesc.Priority = D3D12_COMMAND_QUEUE_PRIORITY_NORMAL
  queueDesc.Flags = D3D12_COMMAND_QUEUE_FLAG_NONE
  queueDesc.NodeMask = 0
  #checkHr(ctx.device.CreateCommandQueue(addr queueDesc, addr IID_ID3D12CommandQueue, cast[ptr pointer](addr ctx.commandQueue)), "CreateCommandQueue")
  ctx.commandQueue = ctx.device.CreateCommandQueue(addr queueDesc, addr IID_ID3D12CommandQueue)


  # Create swap chain
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

  var swapChain1: IDXGISwapChain1
  checkHr(factory.CreateSwapChainForHwnd(
    cast[pointer](ctx.commandQueue),
    hwnd,
    addr swapDesc,
    nil,
    nil,
    cast[ptr pointer](addr swapChain1)
  ), "CreateSwapChainForHwnd")

  discard factory.MakeWindowAssociation(hwnd, DXGI_MWA_NO_ALT_ENTER)

  # Upgrade to IDXGISwapChain3
  checkHr(QueryInterface(swapChain1, addr IID_IDXGISwapChain3, cast[ptr pointer](addr ctx.swapChain)), "IDXGISwapChain1 -> IDXGISwapChain3")
  swapChain1.release()
  factory.release()

  # Descriptor heap for render targets
  var heapDesc: D3D12_DESCRIPTOR_HEAP_DESC
  heapDesc.typ = D3D12_DESCRIPTOR_HEAP_TYPE_RTV
  heapDesc.NumDescriptors = FRAME_COUNT
  heapDesc.Flags = D3D12_DESCRIPTOR_HEAP_FLAG_NONE
  heapDesc.NodeMask = 0
  checkHr(ctx.device.CreateDescriptorHeap(addr heapDesc, addr IID_ID3D12DescriptorHeap, cast[ptr pointer](addr ctx.descriptorHeap)), "CreateDescriptorHeap")
  if ctx.descriptorHeap == nil:
    quit("Descriptor heap creation returned nil")

  ctx.rtvDescriptorSize = ctx.device.GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_RTV)
  let baseHandle = ctx.descriptorHeap.GetCPUDescriptorHandleForHeapStart()

  # Create render target views for each swap chain buffer
  for i in 0..<FRAME_COUNT:
    ctx.rtvHandles[i] = offsetHandle(baseHandle, ctx.rtvDescriptorSize, i)
    checkHr(ctx.swapChain.GetBuffer(UINT(i), addr IID_ID3D12Resource, cast[ptr pointer](addr ctx.renderTargets[i])), "SwapChain.GetBuffer")
    ctx.device.CreateRenderTargetView(ctx.renderTargets[i], nil, ctx.rtvHandles[i])

  # Command allocator + list
  checkHr(ctx.device.CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, addr IID_ID3D12CommandAllocator, cast[ptr pointer](addr ctx.commandAllocator)), "CreateCommandAllocator")
  checkHr(ctx.device.CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, ctx.commandAllocator, nil, addr IID_ID3D12GraphicsCommandList, cast[ptr pointer](addr ctx.commandList)), "CreateCommandList")
  discard ctx.commandList.Close()

  # Fence + event
  checkHr(ctx.device.CreateFence(0, D3D12_FENCE_FLAG_NONE, addr IID_ID3D12Fence, cast[ptr pointer](addr ctx.fence)), "CreateFence")
  ctx.fenceValue = 1
  ctx.fenceEvent = CreateEventW(nil, 0, 0, nil)
  if ctx.fenceEvent == 0:
    quit("Failed to create fence event")

  ctx.viewport = D3D12_VIEWPORT(
    TopLeftX: 0.0, TopLeftY: 0.0,
    Width: FLOAT(width), Height: FLOAT(height),
    MinDepth: 0.0, MaxDepth: 1.0
  )
  ctx.scissor = D3D12_RECT(left: 0, top: 0, right: int32(width), bottom: int32(height))

proc waitForGpu(ctx: var D3D12Context) =
  let fenceToWait = ctx.fenceValue
  checkHr(ctx.commandQueue.Signal(ctx.fence, fenceToWait), "Signal fence")
  inc ctx.fenceValue
  if ctx.fence.GetCompletedValue() < fenceToWait:
    checkHr(ctx.fence.SetEventOnCompletion(fenceToWait, ctx.fenceEvent), "Fence.SetEventOnCompletion")
    discard WaitForSingleObject(ctx.fenceEvent, WAIT_INFINITE)

proc moveToNextFrame(ctx: var D3D12Context) =
  let currentFence = ctx.fenceValue
  checkHr(ctx.commandQueue.Signal(ctx.fence, currentFence), "Signal fence")
  inc ctx.fenceValue
  if ctx.fence.GetCompletedValue() < currentFence:
    checkHr(ctx.fence.SetEventOnCompletion(currentFence, ctx.fenceEvent), "Fence.SetEventOnCompletion")
    discard WaitForSingleObject(ctx.fenceEvent, WAIT_INFINITE)
  ctx.currentFrame = (ctx.currentFrame + 1) mod FRAME_COUNT

proc recordCommandList(ctx: var D3D12Context, color: array[4, FLOAT]) =
  checkHr(ctx.commandAllocator.Reset(), "CommandAllocator.Reset")
  checkHr(ctx.commandList.Reset(ctx.commandAllocator, nil), "CommandList.Reset")

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
  ctx.commandList.ResourceBarrier(1, addr barrier)
  ctx.commandList.RSSetViewports(1, addr ctx.viewport)
  ctx.commandList.RSSetScissorRects(1, addr ctx.scissor)
  ctx.commandList.OMSetRenderTargets(1, addr ctx.rtvHandles[ctx.currentFrame], 1, nil)
  ctx.commandList.ClearRenderTargetView(ctx.rtvHandles[ctx.currentFrame], unsafeAddr color[0], 0, nil)

  barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET
  barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT
  ctx.commandList.ResourceBarrier(1, addr barrier)

  checkHr(ctx.commandList.Close(), "CommandList.Close")

proc executeFrame(ctx: var D3D12Context) =
  var commandListIface = cast[ID3D12CommandList](ctx.commandList)
  ctx.commandQueue.ExecuteCommandLists(1, addr commandListIface)
  checkHr(ctx.swapChain.Present(1, 0), "SwapChain.Present")
  ctx.moveToNextFrame()

proc cleanup(ctx: var D3D12Context) =
  ctx.waitForGpu()
  for i in 0..<FRAME_COUNT:
    ctx.renderTargets[i].release()
  ctx.commandAllocator.release()
  ctx.commandList.release()
  ctx.commandQueue.release()
  ctx.descriptorHeap.release()
  ctx.swapChain.release()
  ctx.device.release()
  ctx.fence.release()
  if ctx.fenceEvent != 0:
    discard CloseHandle(ctx.fenceEvent)
    ctx.fenceEvent = 0

when isMainModule:
  loadNativeSymbols()

  let width = 1280
  let height = 800
  let window = newWindow("DirectX 12 Color Cycle", ivec2(width.int32, height.int32))

  var hwnd: HWND = window.getHWND()
  if hwnd == 0:
    quit("Failed to acquire HWND from window")

  var ctx: D3D12Context
  ctx.initDevice(hwnd, width, height)

  try:
    var timeAcc = 0.0
    while not window.closeRequested:
      pollEvents()
      timeAcc += 0.016
      let r = (sin(timeAcc * 0.6) * 0.5 + 0.5).FLOAT
      let g = (sin(timeAcc * 0.6 + 2.094) * 0.5 + 0.5).FLOAT
      let b = (sin(timeAcc * 0.6 + 4.188) * 0.5 + 0.5).FLOAT
      let color = [r, g, b, 1.0.FLOAT]

      ctx.recordCommandList(color)
      ctx.executeFrame()
  finally:
    ctx.cleanup()

