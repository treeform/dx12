## Hand-written extras for DirectX 12 bindings.
## Contains things that can't be auto-generated from IDL:
## DXGuid, DLL loading, COM helpers, IID-based ergonomic wrappers.

import std/dynlib
import vtable, win32defs, d3d12_api, d3dcommon, dxgi, dxgi1_2, dxgi1_4, dxgi1_5

type
  UINT64* = uint64
  FLOAT* = float32
  BOOL32* = int32

  D3D12_RECT* = object
    left*, top*, right*, bottom*: int32

  DXGuid* {.pure, packed.} = object
    Data1*: uint32
    Data2*: uint16
    Data3*: uint16
    Data4*: array[8, uint8]

proc newGuid*(
  data1: uint32, data2: uint16, data3: uint16,
  b0, b1, b2, b3, b4, b5, b6, b7: uint8
): DXGuid =
  DXGuid(Data1: data1, Data2: data2, Data3: data3,
         Data4: [b0, b1, b2, b3, b4, b5, b6, b7])

# --- DLL entry points loaded at runtime ---

type
  D3D12CreateDevice_t = proc(
    pAdapter: pointer, MinimumFeatureLevel: uint32,
    riid: ptr DXGuid, ppDevice: ptr pointer
  ): HRESULT {.stdcall.}

  CreateDXGIFactory2_t* = proc(
    Flags: uint32, riid: ptr DXGuid, ppFactory: ptr pointer
  ): HRESULT {.stdcall.}

  D3D12SerializeRootSignature_t = proc(
    desc: pointer, version: uint32,
    blob: ptr ID3DBlob, errorBlob: ptr ID3DBlob
  ): HRESULT {.stdcall.}

  D3DCompile_t = proc(
    pSrcData: pointer, SrcDataSize: csize_t, pSourceName: cstring,
    pDefines: pointer, pInclude: pointer, pEntryPoint: cstring,
    pTarget: cstring, Flags1: uint32, Flags2: uint32,
    ppCode: ptr ID3DBlob, ppErrorMsgs: ptr ID3DBlob
  ): HRESULT {.stdcall.}

var
  d3d12Lib: LibHandle
  dxgiLib: LibHandle
  D3D12CreateDevice_Ptr: D3D12CreateDevice_t
  CreateDXGIFactory2_Ptr: CreateDXGIFactory2_t
  D3D12SerializeRootSignature_Ptr: D3D12SerializeRootSignature_t
  d3dCompilerLib: LibHandle
  D3DCompile_Ptr: D3DCompile_t

proc release*(obj: pointer) =
  if obj == nil:
    raise newException(Exception, "COM object is nil")
  type F = proc(this: pointer): uint32 {.stdcall.}
  discard callVtbl0(obj, 2, F)

proc queryInterface*[T](iface: pointer, riid: ptr DXGuid): T =
  type F = proc(this: pointer, riid: ptr DXGuid, outObj: ptr pointer): HRESULT {.stdcall.}
  callVtblErr(iface, 0, F, "QueryInterface", riid, cast[ptr pointer](addr result))

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

proc loadCompiler*() =
  if d3dCompilerLib == nil:
    d3dCompilerLib = loadLib("d3dcompiler_47.dll")
    if d3dCompilerLib == nil:
      raise newException(Exception, "Could not load d3dcompiler_47.dll")
  if D3DCompile_Ptr == nil:
    let sym = d3dCompilerLib.symAddr("D3DCompile")
    if sym == nil:
      raise newException(Exception, "Could not find D3DCompile")
    D3DCompile_Ptr = cast[D3DCompile_t](sym)

proc createDxgiFactory2*(flags: uint32): IDXGIFactory4 =
  const IID_IDXGIFactory4 = newGuid(0x1bc6ea02'u32,0xef36'u16,0x464f'u16,0xbf'u8,0x0c'u8,0x21'u8,0xca'u8,0x39'u8,0xe5'u8,0x16'u8,0x8a'u8)
  let hr = CreateDXGIFactory2_Ptr(flags, addr IID_IDXGIFactory4, cast[ptr pointer](addr result))
  if hr < 0:
    raise newException(Exception, "CreateDXGIFactory2 failed HRESULT " & $hr)

proc d3d12CreateDevice*(pAdapter: pointer, MinimumFeatureLevel: uint32): ID3D12Device =
  const IID_ID3D12Device = newGuid(0x189819f1'u32,0x1db6'u16,0x4b57'u16,0xbe'u8,0x54'u8,0x18'u8,0x21'u8,0x33'u8,0x9b'u8,0x85'u8,0xf7'u8)
  let hr = D3D12CreateDevice_Ptr(pAdapter, MinimumFeatureLevel, addr IID_ID3D12Device, cast[ptr pointer](addr result))
  if hr < 0:
    raise newException(Exception, "D3D12CreateDevice failed HRESULT " & $hr)

# --- Ergonomic device methods with IID auto-fill ---

proc createCommandQueue*(self: ID3D12Device, desc: ptr D3D12_COMMAND_QUEUE_DESC): ID3D12CommandQueue =
  const IID = newGuid(0x0ec870a6'u32,0x5d7e'u16,0x4c22'u16,0x8c'u8,0xfc'u8,0x5b'u8,0xaa'u8,0xe0'u8,0x76'u8,0x16'u8,0xed'u8)
  type F = proc(this: ID3D12Device, desc: ptr D3D12_COMMAND_QUEUE_DESC, riid: ptr DXGuid, out0: ptr ID3D12CommandQueue): HRESULT {.stdcall.}
  callVtblErr(self, 8, F, "CreateCommandQueue", desc, addr IID, addr result)

proc createCommandAllocator*(self: ID3D12Device, typ: uint32): ID3D12CommandAllocator =
  const IID = newGuid(0x6102dee4'u32,0xaf59'u16,0x4b09'u16,0xb9'u8,0x99'u8,0xb4'u8,0x4d'u8,0x73'u8,0xf0'u8,0x9b'u8,0x24'u8)
  type F = proc(this: ID3D12Device, typ: uint32, riid: ptr DXGuid, out0: ptr pointer): HRESULT {.stdcall.}
  callVtblErr(self, 9, F, "CreateCommandAllocator", typ, addr IID, cast[ptr pointer](addr result))

proc createCommandList*(self: ID3D12Device, nodeMask: uint32, typ: uint32, allocator: ID3D12CommandAllocator, initialState: pointer): ID3D12GraphicsCommandList =
  const IID = newGuid(0x5b160d0f'u32,0xac1b'u16,0x4185'u16,0x8b'u8,0xa8'u8,0xb3'u8,0xae'u8,0x42'u8,0xa5'u8,0xa4'u8,0x55'u8)
  type F = proc(this: ID3D12Device, nodeMask: uint32, typ: uint32, allocator: ID3D12CommandAllocator, initialState: pointer, riid: ptr DXGuid, out0: ptr pointer): HRESULT {.stdcall.}
  callVtblErr(self, 12, F, "CreateCommandList", nodeMask, typ, allocator, initialState, addr IID, cast[ptr pointer](addr result))

proc createDescriptorHeap*(self: ID3D12Device, desc: ptr D3D12_DESCRIPTOR_HEAP_DESC): ID3D12DescriptorHeap =
  const IID = newGuid(0x8efb471d'u32,0x616c'u16,0x4f49'u16,0x90'u8,0xf7'u8,0x12'u8,0x7b'u8,0xb7'u8,0x63'u8,0xfa'u8,0x51'u8)
  type F = proc(this: ID3D12Device, desc: ptr D3D12_DESCRIPTOR_HEAP_DESC, riid: ptr DXGuid, out0: ptr pointer): HRESULT {.stdcall.}
  callVtblErr(self, 14, F, "CreateDescriptorHeap", desc, addr IID, cast[ptr pointer](addr result))

proc createRootSignature*(self: ID3D12Device, nodeMask: uint32, bytecode: pointer, bytecodeLength: csize_t): ID3D12RootSignature =
  const IID = newGuid(0xc54a6b66'u32,0x72df'u16,0x4ee8'u16,0x8b'u8,0xe5'u8,0xa9'u8,0x46'u8,0xa1'u8,0x42'u8,0x92'u8,0x14'u8)
  type F = proc(this: ID3D12Device, nodeMask: uint32, bytecode: pointer, bytecodeLength: csize_t, riid: ptr DXGuid, out0: ptr pointer): HRESULT {.stdcall.}
  callVtblErr(self, 16, F, "CreateRootSignature", nodeMask, bytecode, bytecodeLength, addr IID, cast[ptr pointer](addr result))

proc createGraphicsPipelineState*(self: ID3D12Device, desc: pointer): ID3D12PipelineState =
  const IID = newGuid(0x765a30f3'u32,0xf624'u16,0x4c6f'u16,0xa8'u8,0x28'u8,0xac'u8,0xe9'u8,0x48'u8,0x62'u8,0x24'u8,0x45'u8)
  type F = proc(this: ID3D12Device, desc: pointer, riid: ptr DXGuid, out0: ptr pointer): HRESULT {.stdcall.}
  callVtblErr(self, 10, F, "CreateGraphicsPipelineState", desc, addr IID, cast[ptr pointer](addr result))

proc createCommittedResource*(self: ID3D12Device, heapProps: ptr D3D12_HEAP_PROPERTIES, heapFlags: uint32, desc: pointer, initialState: uint32, clearValue: pointer): ID3D12Resource =
  const IID = newGuid(0x696442be'u32,0xa72e'u16,0x4059'u16,0xbc'u8,0x79'u8,0x5b'u8,0x5c'u8,0x98'u8,0x04'u8,0x0f'u8,0xad'u8)
  type F = proc(this: ID3D12Device, heapProps: ptr D3D12_HEAP_PROPERTIES, heapFlags: uint32, desc: pointer, initialState: uint32, clearValue: pointer, riid: ptr DXGuid, out0: ptr pointer): HRESULT {.stdcall.}
  callVtblErr(self, 27, F, "CreateCommittedResource", heapProps, heapFlags, desc, initialState, clearValue, addr IID, cast[ptr pointer](addr result))

proc createFence*(self: ID3D12Device, initialValue: uint64, flags: uint32): ID3D12Fence =
  const IID = newGuid(0x0a753dcf'u32,0xc4d8'u16,0x4b91'u16,0xad'u8,0xf6'u8,0xbe'u8,0x5a'u8,0x60'u8,0xd9'u8,0x5a'u8,0x76'u8)
  type F = proc(this: ID3D12Device, initialValue: uint64, flags: uint32, riid: ptr DXGuid, out0: ptr pointer): HRESULT {.stdcall.}
  callVtblErr(self, 36, F, "CreateFence", initialValue, flags, addr IID, cast[ptr pointer](addr result))

# --- Descriptor heap special methods (hidden return-ptr ABI) ---

proc getCPUDescriptorHandleForHeapStart*(self: ID3D12DescriptorHeap): D3D12_CPU_DESCRIPTOR_HANDLE =
  type F = proc(this: ID3D12DescriptorHeap, ret: ptr D3D12_CPU_DESCRIPTOR_HANDLE): ptr D3D12_CPU_DESCRIPTOR_HANDLE {.stdcall.}
  discard callVtbl(self, 9, F, addr result)

proc getGPUDescriptorHandleForHeapStart*(self: ID3D12DescriptorHeap): D3D12_GPU_DESCRIPTOR_HANDLE =
  type F = proc(this: ID3D12DescriptorHeap, ret: ptr D3D12_GPU_DESCRIPTOR_HANDLE): ptr D3D12_GPU_DESCRIPTOR_HANDLE {.stdcall.}
  discard callVtbl(self, 10, F, addr result)

# --- DXGI Factory methods ---

proc createSwapChainForHwnd*(factory: IDXGIFactory4, device: pointer, hwnd: HWND, desc: ptr DXGI_SWAP_CHAIN_DESC1, fullscreenDesc: pointer, restrictOutput: IDXGIOutput): IDXGISwapChain1 =
  type F = proc(this: IDXGIFactory4, device: pointer, hwnd: HWND, desc: ptr DXGI_SWAP_CHAIN_DESC1, fullscreenDesc: pointer, restrictOutput: IDXGIOutput, out0: ptr pointer): int32 {.stdcall.}
  callVtblErr(factory, 15, F, "CreateSwapChainForHwnd", device, hwnd, desc, fullscreenDesc, restrictOutput, cast[ptr pointer](addr result))

proc makeWindowAssociation*(factory: IDXGIFactory4, hwnd: HWND, flags: uint32) =
  type F = proc(this: IDXGIFactory4, hwnd: HWND, flags: uint32): int32 {.stdcall.}
  callVtblErr(factory, 8, F, "MakeWindowAssociation", hwnd, flags)

# --- DXGI SwapChain methods (typed for IDXGISwapChain3) ---

proc present*(self: IDXGISwapChain3, syncInterval: uint32, flags: uint32) =
  type F = proc(this: IDXGISwapChain3, syncInterval: uint32, flags: uint32): int32 {.stdcall.}
  callVtblErr(self, 8, F, "SwapChain.Present", syncInterval, flags)

proc getBuffer*(self: IDXGISwapChain3, index: uint32): ID3D12Resource =
  const IID = newGuid(0x696442be'u32,0xa72e'u16,0x4059'u16,0xbc'u8,0x79'u8,0x5b'u8,0x5c'u8,0x98'u8,0x04'u8,0x0f'u8,0xad'u8)
  type F = proc(this: IDXGISwapChain3, index: uint32, riid: ptr DXGuid, out0: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 9, F, "SwapChain.GetBuffer", index, addr IID, cast[ptr pointer](addr result))

proc resizeBuffers*(self: IDXGISwapChain3, bufferCount, width, height, newFormat, swapChainFlags: uint32) =
  type F = proc(this: IDXGISwapChain3, bufferCount, width, height, newFormat, swapChainFlags: uint32): int32 {.stdcall.}
  callVtblErr(self, 13, F, "SwapChain.ResizeBuffers", bufferCount, width, height, newFormat, swapChainFlags)

# --- Upgrade helpers ---

proc upgradeToSwapChain3*(swapChain1: IDXGISwapChain1): IDXGISwapChain3 =
  const IID = newGuid(0x94d99bdb'u32,0xf1f8'u16,0x4ab0'u16,0xb2'u8,0x36'u8,0x7d'u8,0xa0'u8,0x17'u8,0x0e'u8,0xda'u8,0xb1'u8)
  queryInterface[IDXGISwapChain3](swapChain1, addr IID)

proc upgradeToFactory5*(factory4: IDXGIFactory4): IDXGIFactory5 =
  const IID = newGuid(0x7632e1f5'u32,0xee65'u16,0x4dca'u16,0x87'u8,0xfd'u8,0x84'u8,0xcd'u8,0x75'u8,0xf8'u8,0x83'u8,0x8d'u8)
  queryInterface[IDXGIFactory5](factory4, addr IID)

proc serializeRootSignature*(desc: pointer): ID3DBlob =
  loadNativeSymbols()
  var errorBlob: ID3DBlob
  let hr = D3D12SerializeRootSignature_Ptr(desc, 1'u32, addr result, addr errorBlob)
  if errorBlob != nil:
    let msgPtr = cast[cstring](getBufferPointer(errorBlob))
    var msg = ""
    if msgPtr != nil: msg = $msgPtr
    release(errorBlob)
    if hr < 0:
      raise newException(Exception, "D3D12SerializeRootSignature failed: " & msg)
  if hr < 0:
    raise newException(Exception, "D3D12SerializeRootSignature failed HRESULT " & $hr)

proc compileShader*(source: string, entryPoint: string, target: string, flags: uint32 = 0): ID3DBlob =
  loadCompiler()
  var errorBlob: ID3DBlob
  let hr = D3DCompile_Ptr(
    cast[pointer](source.cstring), source.len.csize_t, nil, nil, nil,
    entryPoint.cstring, target.cstring, flags, 0, addr result, addr errorBlob)
  if errorBlob != nil:
    let msgPtr = cast[cstring](getBufferPointer(errorBlob))
    var msg = ""
    if msgPtr != nil: msg = $msgPtr
    release(errorBlob)
    if hr < 0:
      if result != nil: release(result)
      raise newException(Exception, "D3DCompile failed: " & msg)
  if hr < 0:
    raise newException(Exception, "D3DCompile failed HRESULT " & $hr)

proc shaderBytecode*(blob: ID3DBlob): D3D12_SHADER_BYTECODE =
  D3D12_SHADER_BYTECODE(pShaderBytecode: getBufferPointer(blob), BytecodeLength: getBufferSize(blob))

# --- Extra constants not from IDL ---

const
  FRAME_COUNT* = 2
  S_OK* = 0
  WAIT_INFINITE* = 0xFFFFFFFF'u32
  DXGI_MWA_NO_ALT_ENTER* = 0x2'u32
  DXGI_MWA_NO_WINDOW_CHANGES* = 0x1'u32
  DXGI_MWA_NO_PRINT_SCREEN* = 0x4'u32
  DXGI_PRESENT_ALLOW_TEARING* = 0x200'u32
  D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING* = 0x1688'u32
