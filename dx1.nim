import dynlib, windy, windy/platforms/win32/windefs

# --- Type Definitions for Binary Compatibility ---

type
  # Basic DirectX Types
  HRESULT* = int32
  UINT* = uint32
  FLOAT* = float32
  DXGI_FORMAT* = uint32
  D3D_DRIVER_TYPE* = uint32
  D3D_FEATURE_LEVEL* = uint32
  BOOL32* = int32

  # Opaque Pointers for COM Interfaces
  # We don't define the internals, just that they exist as pointers.
  IDXGISwapChain* = ptr object
  ID3D11Device* = ptr object
  ID3D11DeviceContext* = ptr object
  ID3D11RenderTargetView* = ptr object
  ID3D11Resource* = ptr object
  ID3D11Texture2D* = ptr object # Inherits from Resource

  # Structs required for Initialization
  DXGI_MODE_DESC* = object
    Width*: UINT
    Height*: UINT
    RefreshRate*: tuple[Numerator: UINT, Denominator: UINT]
    Format*: DXGI_FORMAT
    ScanlineOrdering*: UINT
    Scaling*: UINT

  DXGI_SAMPLE_DESC* = object
    Count*: UINT
    Quality*: UINT

  DXGI_SWAP_CHAIN_DESC* = object
    BufferDesc*: DXGI_MODE_DESC
    SampleDesc*: DXGI_SAMPLE_DESC
    BufferUsage*: UINT
    BufferCount*: UINT
    OutputWindow*: HWND
    Windowed*: BOOL32
    SwapEffect*: UINT
    Flags*: UINT

# Constants
const
  S_OK* = 0
  DXGI_FORMAT_R8G8B8A8_UNORM* = 28
  D3D_DRIVER_TYPE_HARDWARE* = 1
  D3D11_CREATE_DEVICE_SINGLETHREADED* = 1
  DXGI_USAGE_RENDER_TARGET_OUTPUT* = 32
  D3D11_SDK_VERSION* = 7
  DXGI_SWAP_EFFECT_DISCARD* = 0
  DXGI_SWAP_CHAIN_FLAG_NONE* = 0

# --- The VTable Magic ---

# This template effectively replicates the "header file" logic at runtime/compile time
# by blindly casting the object to a VTable array and grabbing the function at `index`.
template callVtbl*(iface: pointer, index: int, typ: typedesc, args: varargs[untyped]): untyped =
  # 1. Cast interface pointer to a pointer-to-VTable
  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)
  # 2. Dereference to get the actual VTable (array of func ptrs)
  let vtbl = vtblPtr[]
  # 3. Get the function pointer at the specific index
  let funcPtr = vtbl[index]
  # 4. Cast raw pointer to the specific procedure signature
  let function = cast[typ](funcPtr)
  # 5. Call it
  function(iface, args)

# --- Wrappers for Specific COM Methods ---
# We define the signature locally and call via index.

# IDXGISwapChain::Present (Index 8)
proc Present*(self: IDXGISwapChain, SyncInterval: UINT, Flags: UINT): HRESULT {.discardable.} =
  type F = proc(this: IDXGISwapChain, a: UINT, b: UINT): HRESULT {.stdcall.}
  callVtbl(self, 8, F, SyncInterval, Flags)

# IDXGISwapChain::GetBuffer (Index 9)
proc GetBuffer*(self: IDXGISwapChain, Buffer: UINT, riid: ptr GUID, ppSurface: ptr pointer): HRESULT {.discardable.} =
  type F = proc(this: IDXGISwapChain, b: UINT, r: ptr GUID, outP: ptr pointer): HRESULT {.stdcall.}
  callVtbl(self, 9, F, Buffer, riid, ppSurface)

# ID3D11Device::CreateRenderTargetView (Index 9)
proc CreateRenderTargetView*(self: ID3D11Device, pResource: ID3D11Resource, pDesc: pointer, ppRTView: ptr ID3D11RenderTargetView): HRESULT {.discardable.} =
  type F = proc(this: ID3D11Device, res: ID3D11Resource, desc: pointer, outView: ptr ID3D11RenderTargetView): HRESULT {.stdcall.}
  callVtbl(self, 9, F, pResource, pDesc, ppRTView)

# ID3D11DeviceContext::OMSetRenderTargets (Index 33)
proc OMSetRenderTargets*(self: ID3D11DeviceContext, NumViews: UINT, ppRenderTargetViews: ptr ID3D11RenderTargetView, pDepthStencilView: pointer) =
  type F = proc(this: ID3D11DeviceContext, n: UINT, views: ptr ID3D11RenderTargetView, dsv: pointer) {.stdcall.}
  callVtbl(self, 33, F, NumViews, ppRenderTargetViews, pDepthStencilView)

# ID3D11DeviceContext::RSSetViewports (Index 44)
type D3D11_VIEWPORT* = object
  TopLeftX*, TopLeftY*, Width*, Height*, MinDepth*, MaxDepth*: FLOAT

proc RSSetViewports*(self: ID3D11DeviceContext, NumViewports: UINT, pViewports: ptr D3D11_VIEWPORT) =
  type F = proc(this: ID3D11DeviceContext, n: UINT, vps: ptr D3D11_VIEWPORT) {.stdcall.}
  callVtbl(self, 44, F, NumViewports, pViewports)

# ID3D11DeviceContext::ClearRenderTargetView (Index 50)
proc ClearRenderTargetView*(self: ID3D11DeviceContext, pRenderTargetView: ID3D11RenderTargetView, ColorRGBA: array[4, FLOAT]) =
  type F = proc(this: ID3D11DeviceContext, view: ID3D11RenderTargetView, color: ptr FLOAT) {.stdcall.}
  # We pass the address of the first element of the array
  callVtbl(self, 50, F, pRenderTargetView, unsafeAddr(ColorRGBA[0]))

# --- DLL Loading ---

# The function signature for the main entry point in d3d11.dll
type D3D11CreateDeviceAndSwapChain_t = proc(
  pAdapter: pointer,
  DriverType: D3D_DRIVER_TYPE,
  Software: pointer,
  Flags: UINT,
  pFeatureLevels: pointer,
  FeatureLevels: UINT,
  SDKVersion: UINT,
  pSwapChainDesc: ptr DXGI_SWAP_CHAIN_DESC,
  ppSwapChain: ptr IDXGISwapChain,
  ppDevice: ptr ID3D11Device,
  pFeatureLevel: pointer,
  ppImmediateContext: ptr ID3D11DeviceContext
): HRESULT {.stdcall.}

var d3d11Lib: LibHandle
var D3D11CreateDeviceAndSwapChain_Ptr: D3D11CreateDeviceAndSwapChain_t

proc initDirectX*() =
  d3d11Lib = loadLib("d3d11.dll")
  if d3d11Lib == nil:
    quit("Could not load d3d11.dll")

  let sym = d3d11Lib.symAddr("D3D11CreateDeviceAndSwapChain")
  if sym == nil:
    quit("Could not find D3D11CreateDeviceAndSwapChain")

  D3D11CreateDeviceAndSwapChain_Ptr = cast[D3D11CreateDeviceAndSwapChain_t](sym)

proc createDeviceAndSwapChain*(
  desc: var DXGI_SWAP_CHAIN_DESC,
  swapChain: var IDXGISwapChain,
  device: var ID3D11Device,
  context: var ID3D11DeviceContext
): HRESULT =
  result = D3D11CreateDeviceAndSwapChain_Ptr(
    nil, # Adapter (default)
    D3D_DRIVER_TYPE_HARDWARE,
    nil, # Software rasterizer
    0,   # Flags
    nil, # Feature levels (default)
    0,
    D3D11_SDK_VERSION,
    addr desc,
    addr swapChain,
    addr device,
    nil, # Out feature level
    addr context
  )

# IID helper for GetBuffer (UUID for ID3D11Texture2D)
# {6f15aaf2-d208-4e89-9ab4-489535d34f9c}
var IID_ID3D11Texture2D* = GUID(
  Data1: 0x6f15aaf2'i32, Data2: 0xd208'u16, Data3: 0x4e89'u16,
  Data4: [0x9a'u8, 0xb4, 0x48, 0x95, 0x35, 0xd3, 0x4f, 0x9c]
)



# --- Example Application ---
when isMainModule:
  import math
  
  # Initialize DirectX
  initDirectX()
  
  # Create window
  let window = newWindow("DirectX Example", ivec2(1280, 800))
  
  # Get HWND from the window
  var hWnd: HWND
  hWnd = window.getHWND()
  # Ensure window is visible before creating DirectX device
  if hWnd == 0:
    quit("Failed to get window handle")
  
  # Create swap chain description
  var swapChainDesc: DXGI_SWAP_CHAIN_DESC
  swapChainDesc.BufferDesc.Width = 1280
  swapChainDesc.BufferDesc.Height = 800
  swapChainDesc.BufferDesc.RefreshRate = (60'u32, 1'u32)
  swapChainDesc.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM
  swapChainDesc.BufferDesc.ScanlineOrdering = 0
  swapChainDesc.BufferDesc.Scaling = 0
  swapChainDesc.SampleDesc.Count = 1
  swapChainDesc.SampleDesc.Quality = 0
  swapChainDesc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT
  swapChainDesc.BufferCount = 1
  swapChainDesc.OutputWindow = hWnd
  swapChainDesc.Windowed = 1 # TRUE
  swapChainDesc.SwapEffect = DXGI_SWAP_EFFECT_DISCARD
  swapChainDesc.Flags = DXGI_SWAP_CHAIN_FLAG_NONE
  
  # Create device and swap chain
  var swapChain: IDXGISwapChain
  var device: ID3D11Device
  var context: ID3D11DeviceContext
  
  let hr = createDeviceAndSwapChain(swapChainDesc, swapChain, device, context)
  if hr != S_OK:
    quit("Failed to create DirectX device and swap chain: " & $hr)
  
  # Get back buffer
  var backBuffer: pointer
  let hr2 = swapChain.GetBuffer(0, addr IID_ID3D11Texture2D, addr backBuffer)
  if hr2 != S_OK:
    quit("Failed to get back buffer: " & $hr2)
  
  # Create render target view
  var renderTargetView: ID3D11RenderTargetView
  let hr3 = device.CreateRenderTargetView(cast[ID3D11Resource](backBuffer), nil, addr renderTargetView)
  if hr3 != S_OK:
    quit("Failed to create render target view: " & $hr3)
  
  # Set render target
  context.OMSetRenderTargets(1, addr renderTargetView, nil)
  
  # Set viewport
  var viewport: D3D11_VIEWPORT
  viewport.TopLeftX = 0.0
  viewport.TopLeftY = 0.0
  viewport.Width = 1280.0
  viewport.Height = 800.0
  viewport.MinDepth = 0.0
  viewport.MaxDepth = 1.0
  context.RSSetViewports(1, addr viewport)
  
  # Animation variables
  var time = 0.0
  
  # Main loop
  while not window.closeRequested:
    pollEvents()
    
    # Update time
    time += 0.016 # ~60 FPS
    
    # Calculate animated color (cycling through RGB)
    let r = (sin(time * 0.5) * 0.5 + 0.5).float32
    let g = (sin(time * 0.5 + 2.094) * 0.5 + 0.5).float32  # 2π/3 phase
    let b = (sin(time * 0.5 + 4.189) * 0.5 + 0.5).float32  # 4π/3 phase
    let color = [r, g, b, 1.0'f32]
    
    # Clear render target with animated color
    context.ClearRenderTargetView(renderTargetView, color)
    
    # Present the frame
    discard swapChain.Present(1, 0) # VSync on, no flags