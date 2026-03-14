import dynlib, math
import windy
import windy/platforms/win32/windefs
import std/winlean

import dx12a_factory # reuse GUID helpers + factory IID

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
  DXGuid* = dx12a_factory.GUID

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

# --- GUIDs we need ---
var
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

var
  d3d12Lib: LibHandle
  dxgiLib: LibHandle
  D3D12CreateDevice_Ptr: D3D12CreateDevice_t
  CreateDXGIFactory2_Ptr: CreateDXGIFactory2_t

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

type
  ComVTable = ptr UncheckedArray[pointer]
  ReleaseProc = proc(this: pointer): uint32 {.stdcall.}
  QueryInterfaceProc = proc(this: pointer, riid: ptr DXGuid, outObj: ptr pointer): HRESULT {.stdcall.}

proc getComVTable(iface: pointer): ComVTable =
  if iface == nil:
    return nil
  cast[ComVTable](cast[ptr pointer](iface)[])

proc getComMethod[T](iface: pointer, index: int): T =
  cast[T](getComVTable(iface)[index])

proc queryInterface(iface: pointer, riid: ptr DXGuid, outObj: ptr pointer): HRESULT =
  let fn = getComMethod[QueryInterfaceProc](iface, 0)
  fn(iface, riid, outObj)

proc releaseComPtr[T](obj: var T) =
  when compiles(obj != nil):
    if obj != nil:
      let fn = getComMethod[ReleaseProc](obj, 2)
      discard fn(obj)
      obj = nil

# --- COM dispatch helpers ---
type
  CreateCommandQueueProc = proc(this: ID3D12Device, desc: ptr D3D12_COMMAND_QUEUE_DESC, riid: ptr DXGuid, outQueue: ptr pointer): HRESULT {.stdcall.}
  CreateCommandAllocatorProc = proc(this: ID3D12Device, typ: D3D12_COMMAND_LIST_TYPE, riid: ptr DXGuid, outAlloc: ptr pointer): HRESULT {.stdcall.}
  CreateCommandListProc = proc(this: ID3D12Device, nodeMask: UINT, typ: D3D12_COMMAND_LIST_TYPE, allocator: ID3D12CommandAllocator, initialState: pointer, riid: ptr DXGuid, outList: ptr pointer): HRESULT {.stdcall.}
  CreateDescriptorHeapProc = proc(this: ID3D12Device, desc: ptr D3D12_DESCRIPTOR_HEAP_DESC, riid: ptr DXGuid, outHeap: ptr pointer): HRESULT {.stdcall.}
  GetDescriptorHandleIncrementSizeProc = proc(this: ID3D12Device, heapType: D3D12_DESCRIPTOR_HEAP_TYPE): UINT {.stdcall.}
  CreateRenderTargetViewProc = proc(this: ID3D12Device, resource: ID3D12Resource, desc: pointer, handle: D3D12_CPU_DESCRIPTOR_HANDLE) {.stdcall.}
  CreateFenceProc = proc(this: ID3D12Device, initialValue: UINT64, flags: uint32, riid: ptr DXGuid, outFence: ptr pointer): HRESULT {.stdcall.}

  ExecuteCommandListsProc = proc(this: ID3D12CommandQueue, count: UINT, lists: ptr ID3D12CommandList) {.stdcall.}
  SignalQueueProc = proc(this: ID3D12CommandQueue, fence: ID3D12Fence, value: UINT64): HRESULT {.stdcall.}

  CommandAllocatorResetProc = proc(this: ID3D12CommandAllocator): HRESULT {.stdcall.}

  CommandListResetProc = proc(this: ID3D12GraphicsCommandList, allocator: ID3D12CommandAllocator, pipelineState: pointer): HRESULT {.stdcall.}
  CommandListCloseProc = proc(this: ID3D12GraphicsCommandList): HRESULT {.stdcall.}
  CommandListResourceBarrierProc = proc(this: ID3D12GraphicsCommandList, count: UINT, barriers: ptr D3D12_RESOURCE_BARRIER) {.stdcall.}
  CommandListRSSetViewportsProc = proc(this: ID3D12GraphicsCommandList, count: UINT, viewports: ptr D3D12_VIEWPORT) {.stdcall.}
  CommandListRSSetScissorRectsProc = proc(this: ID3D12GraphicsCommandList, count: UINT, rects: ptr D3D12_RECT) {.stdcall.}
  CommandListOMSetRenderTargetsProc = proc(this: ID3D12GraphicsCommandList, numTargets: UINT, handles: ptr D3D12_CPU_DESCRIPTOR_HANDLE, singleHandle: BOOL32, depthStencil: pointer) {.stdcall.}
  CommandListClearRTVProc = proc(this: ID3D12GraphicsCommandList, handle: D3D12_CPU_DESCRIPTOR_HANDLE, color: ptr FLOAT, rectCount: UINT, rects: pointer) {.stdcall.}

  GetCpuDescriptorHandleOutProc = proc(this: ID3D12DescriptorHeap, ret: ptr D3D12_CPU_DESCRIPTOR_HANDLE): ptr D3D12_CPU_DESCRIPTOR_HANDLE {.stdcall.}

  FenceGetCompletedValueProc = proc(this: ID3D12Fence): UINT64 {.stdcall.}
  FenceSetEventOnCompletionProc = proc(this: ID3D12Fence, value: UINT64, evt: winlean.Handle): HRESULT {.stdcall.}

  FactoryMakeWindowAssociationProc = proc(this: IDXGIFactory4, hwnd: HWND, flags: UINT): HRESULT {.stdcall.}
  FactoryCreateSwapChainForHwndProc = proc(this: IDXGIFactory4, device: pointer, hwnd: HWND, desc: ptr DXGI_SWAP_CHAIN_DESC1, fullscreenDesc: pointer, restrictOutput: IDXGIOutput, outSwapChain: ptr pointer): HRESULT {.stdcall.}

  SwapChainPresentProc = proc(this: IDXGISwapChain3, syncInterval: UINT, flags: UINT): HRESULT {.stdcall.}
  SwapChainGetBufferProc = proc(this: IDXGISwapChain3, index: UINT, riid: ptr DXGuid, outSurface: ptr pointer): HRESULT {.stdcall.}

type
  D3D12DeviceMethods = object
    release: ReleaseProc
    createCommandQueue: CreateCommandQueueProc
    createCommandAllocator: CreateCommandAllocatorProc
    createCommandList: CreateCommandListProc
    createDescriptorHeap: CreateDescriptorHeapProc
    descriptorHandleIncrement: GetDescriptorHandleIncrementSizeProc
    createRenderTargetView: CreateRenderTargetViewProc
    createFence: CreateFenceProc

  D3D12DeviceHandle* = object
    raw*: ID3D12Device
    m: D3D12DeviceMethods

  D3D12CommandQueueMethods = object
    release: ReleaseProc
    execute: ExecuteCommandListsProc
    signal: SignalQueueProc

  D3D12CommandQueueHandle* = object
    raw*: ID3D12CommandQueue
    m: D3D12CommandQueueMethods

  D3D12CommandAllocatorMethods = object
    release: ReleaseProc
    reset: CommandAllocatorResetProc

  D3D12CommandAllocatorHandle* = object
    raw*: ID3D12CommandAllocator
    m: D3D12CommandAllocatorMethods

  D3D12GraphicsCommandListMethods = object
    release: ReleaseProc
    reset: CommandListResetProc
    close: CommandListCloseProc
    resourceBarrier: CommandListResourceBarrierProc
    rsSetViewports: CommandListRSSetViewportsProc
    rsSetScissorRects: CommandListRSSetScissorRectsProc
    omSetRenderTargets: CommandListOMSetRenderTargetsProc
    clearRenderTargetView: CommandListClearRTVProc

  D3D12GraphicsCommandListHandle* = object
    raw*: ID3D12GraphicsCommandList
    m: D3D12GraphicsCommandListMethods

  D3D12DescriptorHeapMethods = object
    release: ReleaseProc
    when defined(vcc):
      getHandle: GetCpuDescriptorHandleProc
    else:
      getHandleOut: GetCpuDescriptorHandleOutProc

  D3D12DescriptorHeapHandle* = object
    raw*: ID3D12DescriptorHeap
    m: D3D12DescriptorHeapMethods

  D3D12FenceMethods = object
    release: ReleaseProc
    getCompletedValue: FenceGetCompletedValueProc
    setEventOnCompletion: FenceSetEventOnCompletionProc

  D3D12FenceHandle* = object
    raw*: ID3D12Fence
    m: D3D12FenceMethods

  DXGIFactoryMethods = object
    release: ReleaseProc
    makeWindowAssociation: FactoryMakeWindowAssociationProc
    createSwapChainForHwnd: FactoryCreateSwapChainForHwndProc

  DXGIFactoryHandle* = object
    raw*: IDXGIFactory4
    m: DXGIFactoryMethods

  DXGISwapChainMethods = object
    release: ReleaseProc
    present: SwapChainPresentProc
    getBuffer: SwapChainGetBufferProc

  DXGISwapChainHandle* = object
    raw*: IDXGISwapChain3
    m: DXGISwapChainMethods

proc initDeviceHandle(raw: ID3D12Device): D3D12DeviceHandle =
  let v = getComVTable(raw)
  result.raw = raw
  result.m = D3D12DeviceMethods(
    release: cast[ReleaseProc](v[2]),
    createCommandQueue: cast[CreateCommandQueueProc](v[8]),
    createCommandAllocator: cast[CreateCommandAllocatorProc](v[9]),
    createCommandList: cast[CreateCommandListProc](v[12]),
    createDescriptorHeap: cast[CreateDescriptorHeapProc](v[14]),
    descriptorHandleIncrement: cast[GetDescriptorHandleIncrementSizeProc](v[15]),
    createRenderTargetView: cast[CreateRenderTargetViewProc](v[20]),
    createFence: cast[CreateFenceProc](v[36])
  )

proc initCommandQueueHandle(raw: ID3D12CommandQueue): D3D12CommandQueueHandle =
  let v = getComVTable(raw)
  result.raw = raw
  result.m = D3D12CommandQueueMethods(
    release: cast[ReleaseProc](v[2]),
    execute: cast[ExecuteCommandListsProc](v[10]),
    signal: cast[SignalQueueProc](v[14])
  )

proc initCommandAllocatorHandle(raw: ID3D12CommandAllocator): D3D12CommandAllocatorHandle =
  let v = getComVTable(raw)
  result.raw = raw
  result.m = D3D12CommandAllocatorMethods(
    release: cast[ReleaseProc](v[2]),
    reset: cast[CommandAllocatorResetProc](v[8])
  )

proc initGraphicsCommandListHandle(raw: ID3D12GraphicsCommandList): D3D12GraphicsCommandListHandle =
  let v = getComVTable(raw)
  result.raw = raw
  result.m = D3D12GraphicsCommandListMethods(
    release: cast[ReleaseProc](v[2]),
    reset: cast[CommandListResetProc](v[10]),
    close: cast[CommandListCloseProc](v[9]),
    resourceBarrier: cast[CommandListResourceBarrierProc](v[26]),
    rsSetViewports: cast[CommandListRSSetViewportsProc](v[21]),
    rsSetScissorRects: cast[CommandListRSSetScissorRectsProc](v[22]),
    omSetRenderTargets: cast[CommandListOMSetRenderTargetsProc](v[46]),
    clearRenderTargetView: cast[CommandListClearRTVProc](v[48])
  )

proc initDescriptorHeapHandle(raw: ID3D12DescriptorHeap): D3D12DescriptorHeapHandle =
  let v = getComVTable(raw)
  result.raw = raw
  when defined(vcc):
    result.m = D3D12DescriptorHeapMethods(
      release: cast[ReleaseProc](v[2]),
      getHandle: cast[GetCpuDescriptorHandleProc](v[9])
    )
  else:
    result.m = D3D12DescriptorHeapMethods(
      release: cast[ReleaseProc](v[2]),
      getHandleOut: cast[GetCpuDescriptorHandleOutProc](v[9])
    )

proc initFenceHandle(raw: ID3D12Fence): D3D12FenceHandle =
  let v = getComVTable(raw)
  result.raw = raw
  result.m = D3D12FenceMethods(
    release: cast[ReleaseProc](v[2]),
    getCompletedValue: cast[FenceGetCompletedValueProc](v[8]),
    setEventOnCompletion: cast[FenceSetEventOnCompletionProc](v[9])
  )

proc initFactoryHandle(raw: IDXGIFactory4): DXGIFactoryHandle =
  let v = getComVTable(raw)
  result.raw = raw
  result.m = DXGIFactoryMethods(
    release: cast[ReleaseProc](v[2]),
    makeWindowAssociation: cast[FactoryMakeWindowAssociationProc](v[8]),
    createSwapChainForHwnd: cast[FactoryCreateSwapChainForHwndProc](v[15])
  )

proc initSwapChainHandle(raw: IDXGISwapChain3): DXGISwapChainHandle =
  let v = getComVTable(raw)
  result.raw = raw
  result.m = DXGISwapChainMethods(
    release: cast[ReleaseProc](v[2]),
    present: cast[SwapChainPresentProc](v[8]),
    getBuffer: cast[SwapChainGetBufferProc](v[9])
  )

proc release*(self: var D3D12DeviceHandle) =
  if self.raw != nil:
    discard self.m.release(self.raw)
    self.raw = nil

proc release*(self: var D3D12CommandQueueHandle) =
  if self.raw != nil:
    discard self.m.release(self.raw)
    self.raw = nil

proc release*(self: var D3D12CommandAllocatorHandle) =
  if self.raw != nil:
    discard self.m.release(self.raw)
    self.raw = nil

proc release*(self: var D3D12GraphicsCommandListHandle) =
  if self.raw != nil:
    discard self.m.release(self.raw)
    self.raw = nil

proc release*(self: var D3D12DescriptorHeapHandle) =
  if self.raw != nil:
    discard self.m.release(self.raw)
    self.raw = nil

proc release*(self: var D3D12FenceHandle) =
  if self.raw != nil:
    discard self.m.release(self.raw)
    self.raw = nil

proc release*(self: var DXGIFactoryHandle) =
  if self.raw != nil:
    discard self.m.release(self.raw)
    self.raw = nil

proc release*(self: var DXGISwapChainHandle) =
  if self.raw != nil:
    discard self.m.release(self.raw)
    self.raw = nil

proc descriptorHandleIncrementSize*(self: D3D12DeviceHandle, heapType: D3D12_DESCRIPTOR_HEAP_TYPE): UINT =
  self.m.descriptorHandleIncrement(self.raw, heapType)

proc createCommandQueue*(self: D3D12DeviceHandle, desc: ptr D3D12_COMMAND_QUEUE_DESC, riid: ptr DXGuid, outQueue: ptr pointer): HRESULT =
  self.m.createCommandQueue(self.raw, desc, riid, outQueue)

proc createCommandAllocator*(self: D3D12DeviceHandle, typ: D3D12_COMMAND_LIST_TYPE, riid: ptr DXGuid, outAlloc: ptr pointer): HRESULT =
  self.m.createCommandAllocator(self.raw, typ, riid, outAlloc)

proc createCommandList*(self: D3D12DeviceHandle, nodeMask: UINT, typ: D3D12_COMMAND_LIST_TYPE, allocator: ID3D12CommandAllocator, initialState: pointer, riid: ptr DXGuid, outList: ptr pointer): HRESULT =
  self.m.createCommandList(self.raw, nodeMask, typ, allocator, initialState, riid, outList)

proc createDescriptorHeap*(self: D3D12DeviceHandle, desc: ptr D3D12_DESCRIPTOR_HEAP_DESC, riid: ptr DXGuid, outHeap: ptr pointer): HRESULT =
  self.m.createDescriptorHeap(self.raw, desc, riid, outHeap)

proc createRenderTargetView*(self: D3D12DeviceHandle, resource: ID3D12Resource, desc: pointer, handle: D3D12_CPU_DESCRIPTOR_HANDLE) =
  self.m.createRenderTargetView(self.raw, resource, desc, handle)

proc createFence*(self: D3D12DeviceHandle, initialValue: UINT64, flags: uint32, riid: ptr DXGuid, outFence: ptr pointer): HRESULT =
  self.m.createFence(self.raw, initialValue, flags, riid, outFence)

proc reset*(self: D3D12CommandAllocatorHandle): HRESULT =
  self.m.reset(self.raw)

proc reset*(self: D3D12GraphicsCommandListHandle, allocator: ID3D12CommandAllocator, pipelineState: pointer): HRESULT =
  self.m.reset(self.raw, allocator, pipelineState)

proc close*(self: D3D12GraphicsCommandListHandle): HRESULT =
  self.m.close(self.raw)

proc resourceBarrier*(self: D3D12GraphicsCommandListHandle, count: UINT, barriers: ptr D3D12_RESOURCE_BARRIER) =
  self.m.resourceBarrier(self.raw, count, barriers)

proc setViewports*(self: D3D12GraphicsCommandListHandle, count: UINT, viewports: ptr D3D12_VIEWPORT) =
  self.m.rsSetViewports(self.raw, count, viewports)

proc setScissorRects*(self: D3D12GraphicsCommandListHandle, count: UINT, rects: ptr D3D12_RECT) =
  self.m.rsSetScissorRects(self.raw, count, rects)

proc setRenderTargets*(self: D3D12GraphicsCommandListHandle, numTargets: UINT, handles: ptr D3D12_CPU_DESCRIPTOR_HANDLE, singleHandle: BOOL32, depthStencil: pointer) =
  self.m.omSetRenderTargets(self.raw, numTargets, handles, singleHandle, depthStencil)

proc clearRenderTargetView*(self: D3D12GraphicsCommandListHandle, handle: D3D12_CPU_DESCRIPTOR_HANDLE, color: ptr FLOAT, rectCount: UINT, rects: pointer) =
  self.m.clearRenderTargetView(self.raw, handle, color, rectCount, rects)

proc execute*(self: D3D12CommandQueueHandle, count: UINT, lists: ptr ID3D12CommandList) =
  self.m.execute(self.raw, count, lists)

proc signal*(self: D3D12CommandQueueHandle, fence: ID3D12Fence, value: UINT64): HRESULT =
  self.m.signal(self.raw, fence, value)

proc cpuHandle*(self: D3D12DescriptorHeapHandle): D3D12_CPU_DESCRIPTOR_HANDLE =
  when defined(vcc):
    self.m.getHandle(self.raw)
  else:
    var handle: D3D12_CPU_DESCRIPTOR_HANDLE
    discard self.m.getHandleOut(self.raw, addr handle)
    handle

proc completedValue*(self: D3D12FenceHandle): UINT64 =
  self.m.getCompletedValue(self.raw)

proc setEventOnCompletion*(self: D3D12FenceHandle, value: UINT64, evt: winlean.Handle): HRESULT =
  self.m.setEventOnCompletion(self.raw, value, evt)

proc makeWindowAssociation*(self: DXGIFactoryHandle, hwnd: HWND, flags: UINT): HRESULT =
  self.m.makeWindowAssociation(self.raw, hwnd, flags)

proc createSwapChainForHwnd*(self: DXGIFactoryHandle, device: pointer, hwnd: HWND, desc: ptr DXGI_SWAP_CHAIN_DESC1, fullscreenDesc: pointer, restrictOutput: IDXGIOutput, outSwapChain: ptr pointer): HRESULT =
  self.m.createSwapChainForHwnd(self.raw, device, hwnd, desc, fullscreenDesc, restrictOutput, outSwapChain)

proc present*(self: DXGISwapChainHandle, syncInterval: UINT, flags: UINT): HRESULT =
  self.m.present(self.raw, syncInterval, flags)

proc getBuffer*(self: DXGISwapChainHandle, index: UINT, riid: ptr DXGuid, outSurface: ptr pointer): HRESULT =
  self.m.getBuffer(self.raw, index, riid, outSurface)

# --- Helper types ---
type
  D3D12Context* = object
    device: D3D12DeviceHandle
    commandQueue: D3D12CommandQueueHandle
    swapChain: DXGISwapChainHandle
    descriptorHeap: D3D12DescriptorHeapHandle
    renderTargets: array[FRAME_COUNT, ID3D12Resource]
    rtvHandles: array[FRAME_COUNT, D3D12_CPU_DESCRIPTOR_HANDLE]
    commandAllocator: D3D12CommandAllocatorHandle
    commandList: D3D12GraphicsCommandListHandle
    fence: D3D12FenceHandle
    fenceValue: UINT64
    fenceEvent: winlean.Handle
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
  var factoryRaw: IDXGIFactory4
  checkHr(CreateDXGIFactory2_Ptr(0, addr IID_IDXGIFactory4, cast[ptr pointer](addr factoryRaw)), "CreateDXGIFactory2")
  var factory = initFactoryHandle(factoryRaw)

  # Create D3D12 device
  var deviceRaw: ID3D12Device
  checkHr(D3D12CreateDevice_Ptr(nil, D3D_FEATURE_LEVEL_11_0, addr IID_ID3D12Device, cast[ptr pointer](addr deviceRaw)), "D3D12CreateDevice")
  ctx.device = initDeviceHandle(deviceRaw)

  # Create command queue
  var queueDesc: D3D12_COMMAND_QUEUE_DESC
  queueDesc.Type = D3D12_COMMAND_LIST_TYPE_DIRECT
  queueDesc.Priority = D3D12_COMMAND_QUEUE_PRIORITY_NORMAL
  queueDesc.Flags = D3D12_COMMAND_QUEUE_FLAG_NONE
  queueDesc.NodeMask = 0
  var queueRaw: ID3D12CommandQueue
  checkHr(ctx.device.createCommandQueue(addr queueDesc, addr IID_ID3D12CommandQueue, cast[ptr pointer](addr queueRaw)), "CreateCommandQueue")
  ctx.commandQueue = initCommandQueueHandle(queueRaw)

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
  checkHr(factory.createSwapChainForHwnd(
    cast[pointer](ctx.commandQueue.raw),
    hwnd,
    addr swapDesc,
    nil,
    nil,
    cast[ptr pointer](addr swapChain1)
  ), "CreateSwapChainForHwnd")

  discard factory.makeWindowAssociation(hwnd, DXGI_MWA_NO_ALT_ENTER)

  # Upgrade to IDXGISwapChain3
  var swapChain3Raw: IDXGISwapChain3
  checkHr(queryInterface(swapChain1, addr IID_IDXGISwapChain3, cast[ptr pointer](addr swapChain3Raw)), "IDXGISwapChain1 -> IDXGISwapChain3")
  ctx.swapChain = initSwapChainHandle(swapChain3Raw)
  releaseComPtr(swapChain1)
  factory.release()

  # Descriptor heap for render targets
  var heapDesc: D3D12_DESCRIPTOR_HEAP_DESC
  heapDesc.typ = D3D12_DESCRIPTOR_HEAP_TYPE_RTV
  heapDesc.NumDescriptors = FRAME_COUNT
  heapDesc.Flags = D3D12_DESCRIPTOR_HEAP_FLAG_NONE
  heapDesc.NodeMask = 0
  var heapRaw: ID3D12DescriptorHeap
  checkHr(ctx.device.createDescriptorHeap(addr heapDesc, addr IID_ID3D12DescriptorHeap, cast[ptr pointer](addr heapRaw)), "CreateDescriptorHeap")
  ctx.descriptorHeap = initDescriptorHeapHandle(heapRaw)

  ctx.rtvDescriptorSize = ctx.device.descriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_RTV)
  let baseHandle = ctx.descriptorHeap.cpuHandle()

  # Create render target views for each swap chain buffer
  for i in 0..<FRAME_COUNT:
    ctx.rtvHandles[i] = offsetHandle(baseHandle, ctx.rtvDescriptorSize, i)
    checkHr(ctx.swapChain.getBuffer(UINT(i), addr IID_ID3D12Resource, cast[ptr pointer](addr ctx.renderTargets[i])), "SwapChain.GetBuffer")
    ctx.device.createRenderTargetView(ctx.renderTargets[i], nil, ctx.rtvHandles[i])

  # Command allocator + list
  var allocatorRaw: ID3D12CommandAllocator
  checkHr(ctx.device.createCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, addr IID_ID3D12CommandAllocator, cast[ptr pointer](addr allocatorRaw)), "CreateCommandAllocator")
  ctx.commandAllocator = initCommandAllocatorHandle(allocatorRaw)

  var commandListRaw: ID3D12GraphicsCommandList
  checkHr(ctx.device.createCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, ctx.commandAllocator.raw, nil, addr IID_ID3D12GraphicsCommandList, cast[ptr pointer](addr commandListRaw)), "CreateCommandList")
  ctx.commandList = initGraphicsCommandListHandle(commandListRaw)
  discard ctx.commandList.close()

  # Fence + event
  var fenceRaw: ID3D12Fence
  checkHr(ctx.device.createFence(0, D3D12_FENCE_FLAG_NONE, addr IID_ID3D12Fence, cast[ptr pointer](addr fenceRaw)), "CreateFence")
  ctx.fence = initFenceHandle(fenceRaw)
  ctx.fenceValue = 1
  ctx.fenceEvent = createEvent(nil, WINBOOL(0), WINBOOL(0), nil)
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
  checkHr(ctx.commandQueue.signal(ctx.fence.raw, fenceToWait), "Signal fence")
  inc ctx.fenceValue
  if ctx.fence.completedValue() < fenceToWait:
    checkHr(ctx.fence.setEventOnCompletion(fenceToWait, ctx.fenceEvent), "Fence.SetEventOnCompletion")
    discard waitForSingleObject(ctx.fenceEvent, WAIT_INFINITE)

proc moveToNextFrame(ctx: var D3D12Context) =
  let currentFence = ctx.fenceValue
  checkHr(ctx.commandQueue.signal(ctx.fence.raw, currentFence), "Signal fence")
  inc ctx.fenceValue
  if ctx.fence.completedValue() < currentFence:
    checkHr(ctx.fence.setEventOnCompletion(currentFence, ctx.fenceEvent), "Fence.SetEventOnCompletion")
    discard waitForSingleObject(ctx.fenceEvent, WAIT_INFINITE)
  ctx.currentFrame = (ctx.currentFrame + 1) mod FRAME_COUNT

proc recordCommandList(ctx: var D3D12Context, color: array[4, FLOAT]) =
  checkHr(ctx.commandAllocator.reset(), "CommandAllocator.Reset")
  checkHr(ctx.commandList.reset(ctx.commandAllocator.raw, nil), "CommandList.Reset")

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
  ctx.commandList.setViewports(1, addr ctx.viewport)
  ctx.commandList.setScissorRects(1, addr ctx.scissor)
  ctx.commandList.setRenderTargets(1, addr ctx.rtvHandles[ctx.currentFrame], BOOL32(1), nil)
  ctx.commandList.clearRenderTargetView(ctx.rtvHandles[ctx.currentFrame], unsafeAddr color[0], 0, nil)

  barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET
  barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT
  ctx.commandList.resourceBarrier(1, addr barrier)

  checkHr(ctx.commandList.close(), "CommandList.Close")

proc executeFrame(ctx: var D3D12Context) =
  var commandListIface = cast[ID3D12CommandList](ctx.commandList.raw)
  ctx.commandQueue.execute(1, addr commandListIface)
  checkHr(ctx.swapChain.present(1, 0), "SwapChain.Present")
  ctx.moveToNextFrame()

proc cleanup(ctx: var D3D12Context) =
  ctx.waitForGpu()
  for i in 0..<FRAME_COUNT:
    releaseComPtr(ctx.renderTargets[i])
  ctx.commandAllocator.release()
  ctx.commandList.release()
  ctx.commandQueue.release()
  ctx.descriptorHeap.release()
  ctx.swapChain.release()
  ctx.device.release()
  ctx.fence.release()
  if ctx.fenceEvent != 0:
    discard closeHandle(ctx.fenceEvent)
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
