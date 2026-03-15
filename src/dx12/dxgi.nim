# Auto-generated from dxgi.idl — do not edit manually.
# Regenerate with: nim r tools/generate_api.nim

import dxgitype, vtable
export dxgitype

const
  DXGI_CPU_ACCESS_NONE* = 0'u32
  DXGI_CPU_ACCESS_DYNAMIC* = 1'u32
  DXGI_CPU_ACCESS_READ_WRITE* = 2'u32
  DXGI_CPU_ACCESS_SCRATCH* = 3'u32
  DXGI_CPU_ACCESS_FIELD* = 15'u32
  DXGI_USAGE_SHADER_INPUT* = 0x10'u32
  DXGI_USAGE_RENDER_TARGET_OUTPUT* = 0x20'u32
  DXGI_USAGE_BACK_BUFFER* = 0x40'u32
  DXGI_USAGE_SHARED* = 0x80'u32
  DXGI_USAGE_READ_ONLY* = 0x100'u32
  DXGI_USAGE_DISCARD_ON_PRESENT* = 0x200'u32
  DXGI_USAGE_UNORDERED_ACCESS* = 0x400'u32
  DXGI_ENUM_MODES_INTERLACED* = 1'u32
  DXGI_ENUM_MODES_SCALING* = 2'u32
  DXGI_RESOURCE_PRIORITY_MINIMUM* = 0x28000000'u32
  DXGI_RESOURCE_PRIORITY_LOW* = 0x50000000'u32
  DXGI_RESOURCE_PRIORITY_NORMAL* = 0x78000000'u32
  DXGI_RESOURCE_PRIORITY_HIGH* = 0xa0000000'u32
  DXGI_RESOURCE_PRIORITY_MAXIMUM* = 0xc8000000'u32
  DXGI_MAP_READ* = 0x1'u32
  DXGI_MAP_WRITE* = 0x2'u32
  DXGI_MAP_DISCARD* = 0x4'u32

# DXGI_SWAP_EFFECT
const
  DXGI_SWAP_EFFECT_DISCARD* = 0'u32
  DXGI_SWAP_EFFECT_SEQUENTIAL* = 1'u32
  DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL* = 3'u32
  DXGI_SWAP_EFFECT_FLIP_DISCARD* = 4'u32

# DXGI_RESIDENCY
const
  DXGI_RESIDENCY_FULLY_RESIDENT* = 1'u32
  DXGI_RESIDENCY_RESIDENT_IN_SHARED_MEMORY* = 2'u32
  DXGI_RESIDENCY_EVICTED_TO_DISK* = 3'u32

# DXGI_SWAP_CHAIN_FLAG
const
  DXGI_SWAP_CHAIN_FLAG_NONPREROTATED* = 0x0001'u32
  DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH* = 0x0002'u32
  DXGI_SWAP_CHAIN_FLAG_GDI_COMPATIBLE* = 0x0004'u32
  DXGI_SWAP_CHAIN_FLAG_RESTRICTED_CONTENT* = 0x0008'u32
  DXGI_SWAP_CHAIN_FLAG_RESTRICT_SHARED_RESOURCE_DRIVER* = 0x0010'u32
  DXGI_SWAP_CHAIN_FLAG_DISPLAY_ONLY* = 0x0020'u32
  DXGI_SWAP_CHAIN_FLAG_FRAME_LATENCY_WAITABLE_OBJECT* = 0x0040'u32
  DXGI_SWAP_CHAIN_FLAG_FOREGROUND_LAYER* = 0x0080'u32
  DXGI_SWAP_CHAIN_FLAG_FULLSCREEN_VIDEO* = 0x0100'u32
  DXGI_SWAP_CHAIN_FLAG_YUV_VIDEO* = 0x0200'u32
  DXGI_SWAP_CHAIN_FLAG_HW_PROTECTED* = 0x0400'u32
  DXGI_SWAP_CHAIN_FLAG_ALLOW_TEARING* = 0x0800'u32
  DXGI_SWAP_CHAIN_FLAG_RESTRICTED_TO_ALL_HOLOGRAPHIC_DISPLAYS* = 0x1000'u32

# DXGI_ADAPTER_FLAG
const
  DXGI_ADAPTER_FLAG_NONE* = 0'u32
  DXGI_ADAPTER_FLAG_REMOTE* = 1'u32
  DXGI_ADAPTER_FLAG_SOFTWARE* = 2'u32
  DXGI_ADAPTER_FLAG_FORCE_DWORD* = 0xFFFFFFFF'u32

type
  IDXGIObject* = ptr object
  IDXGIDeviceSubObject* = ptr object
  IDXGIResource* = ptr object
  IDXGIKeyedMutex* = ptr object
  IDXGISurface* = ptr object
  IDXGISurface1* = ptr object
  IDXGIOutput* = ptr object
  IDXGIAdapter* = ptr object
  IDXGISwapChain* = ptr object
  IDXGIFactory* = ptr object
  IDXGIDevice* = ptr object
  IDXGIAdapter1* = ptr object
  IDXGIDevice1* = ptr object
  IDXGIFactory1* = ptr object

type
  LUID* = object
    LowPart*: uint32
    HighPart*: int32

  DXGI_SURFACE_DESC* = object
    Width*: uint32
    Height*: uint32
    Format*: uint32
    SampleDesc*: DXGI_SAMPLE_DESC

  DXGI_MAPPED_RECT* = object
    Pitch*: int32
    pBits*: ptr uint8

  DXGI_OUTPUT_DESC* = object
    DeviceName*: array[32, pointer]
    DesktopCoordinates*: pointer
    AttachedToDesktop*: int32
    Rotation*: uint32
    Monitor*: pointer

  DXGI_FRAME_STATISTICS* = object
    PresentCount*: uint32
    PresentRefreshCount*: uint32
    SyncRefreshCount*: uint32
    SyncQPCTime*: int64
    SyncGPUTime*: int64

  DXGI_ADAPTER_DESC* = object
    Description*: array[128, pointer]
    VendorId*: uint32
    DeviceId*: uint32
    SubSysId*: uint32
    Revision*: uint32
    DedicatedVideoMemory*: csize_t
    DedicatedSystemMemory*: csize_t
    SharedSystemMemory*: csize_t
    AdapterLuid*: uint64

  DXGI_SWAP_CHAIN_DESC* = object
    BufferDesc*: DXGI_MODE_DESC
    SampleDesc*: DXGI_SAMPLE_DESC
    BufferUsage*: uint32
    BufferCount*: uint32
    OutputWindow*: pointer
    Windowed*: int32
    SwapEffect*: uint32
    Flags*: uint32

  DXGI_SHARED_RESOURCE* = object
    Handle*: pointer

  DXGI_ADAPTER_DESC1* = object
    Description*: array[128, pointer]
    VendorId*: uint32
    DeviceId*: uint32
    SubSysId*: uint32
    Revision*: uint32
    DedicatedVideoMemory*: csize_t
    DedicatedSystemMemory*: csize_t
    SharedSystemMemory*: csize_t
    AdapterLuid*: uint64
    Flags*: uint32

  DXGI_DISPLAY_COLOR_SPACE* = object
    PrimaryCoordinates*: array[8, float32]
    WhitePoints*: array[16, float32]

type HMONITOR* = pointer
type DXGI_USAGE* = uint32

# --- IDXGIObject methods ---

proc setPrivateData*(self: IDXGIObject, guid: pointer, data_size: uint32, data: pointer) =
  type F = proc(this: IDXGIObject, guid: pointer, data_size: uint32, data: pointer): int32 {.stdcall.}
  callVtblErr(self, 3, F, "IDXGIObject.SetPrivateData", guid, data_size, data)

proc setPrivateDataInterface*(self: IDXGIObject, guid: pointer, objectField: pointer) =
  type F = proc(this: IDXGIObject, guid: pointer, objectField: pointer): int32 {.stdcall.}
  callVtblErr(self, 4, F, "IDXGIObject.SetPrivateDataInterface", guid, objectField)

proc getPrivateData*(self: IDXGIObject, guid: pointer, data_size: ptr uint32, data: pointer) =
  type F = proc(this: IDXGIObject, guid: pointer, data_size: ptr uint32, data: pointer): int32 {.stdcall.}
  callVtblErr(self, 5, F, "IDXGIObject.GetPrivateData", guid, data_size, data)

proc getParent*(self: IDXGIObject, riid: pointer, parent: pointer) =
  type F = proc(this: IDXGIObject, riid: pointer, parent: pointer): int32 {.stdcall.}
  callVtblErr(self, 6, F, "IDXGIObject.GetParent", riid, parent)

# --- IDXGIDeviceSubObject methods ---

proc getDevice*(self: IDXGIDeviceSubObject, riid: pointer, device: pointer) =
  type F = proc(this: IDXGIDeviceSubObject, riid: pointer, device: pointer): int32 {.stdcall.}
  callVtblErr(self, 7, F, "IDXGIDeviceSubObject.GetDevice", riid, device)

# --- IDXGIResource methods ---

proc getSharedHandle*(self: IDXGIResource, pSharedHandle: ptr pointer) =
  type F = proc(this: IDXGIResource, pSharedHandle: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 8, F, "IDXGIResource.GetSharedHandle", pSharedHandle)

proc getUsage*(self: IDXGIResource, pUsage: pointer) =
  type F = proc(this: IDXGIResource, pUsage: pointer): int32 {.stdcall.}
  callVtblErr(self, 9, F, "IDXGIResource.GetUsage", pUsage)

proc setEvictionPriority*(self: IDXGIResource, EvictionPriority: uint32) =
  type F = proc(this: IDXGIResource, EvictionPriority: uint32): int32 {.stdcall.}
  callVtblErr(self, 10, F, "IDXGIResource.SetEvictionPriority", EvictionPriority)

proc getEvictionPriority*(self: IDXGIResource, pEvictionPriority: ptr uint32) =
  type F = proc(this: IDXGIResource, pEvictionPriority: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 11, F, "IDXGIResource.GetEvictionPriority", pEvictionPriority)

# --- IDXGIKeyedMutex methods ---

proc acquireSync*(self: IDXGIKeyedMutex, Key: uint64, dwMilliseconds: uint32) =
  type F = proc(this: IDXGIKeyedMutex, Key: uint64, dwMilliseconds: uint32): int32 {.stdcall.}
  callVtblErr(self, 8, F, "IDXGIKeyedMutex.AcquireSync", Key, dwMilliseconds)

proc releaseSync*(self: IDXGIKeyedMutex, Key: uint64) =
  type F = proc(this: IDXGIKeyedMutex, Key: uint64): int32 {.stdcall.}
  callVtblErr(self, 9, F, "IDXGIKeyedMutex.ReleaseSync", Key)

# --- IDXGISurface methods ---

proc getDesc*(self: IDXGISurface, desc: ptr DXGI_SURFACE_DESC) =
  type F = proc(this: IDXGISurface, desc: ptr DXGI_SURFACE_DESC): int32 {.stdcall.}
  callVtblErr(self, 8, F, "IDXGISurface.GetDesc", desc)

proc map*(self: IDXGISurface, mapped_rect: ptr DXGI_MAPPED_RECT, flags: uint32) =
  type F = proc(this: IDXGISurface, mapped_rect: ptr DXGI_MAPPED_RECT, flags: uint32): int32 {.stdcall.}
  callVtblErr(self, 9, F, "IDXGISurface.Map", mapped_rect, flags)

proc unmap*(self: IDXGISurface) =
  type F = proc(this: IDXGISurface): int32 {.stdcall.}
  callVtbl0Err(self, 10, F, "IDXGISurface.Unmap")

# --- IDXGISurface1 methods ---

proc getDC*(self: IDXGISurface1, discardField: int32, hdc: ptr pointer) =
  type F = proc(this: IDXGISurface1, discardField: int32, hdc: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 11, F, "IDXGISurface1.GetDC", discardField, hdc)

proc releaseDC*(self: IDXGISurface1, dirty_rect: pointer) =
  type F = proc(this: IDXGISurface1, dirty_rect: pointer): int32 {.stdcall.}
  callVtblErr(self, 12, F, "IDXGISurface1.ReleaseDC", dirty_rect)

# --- IDXGIOutput methods ---

proc getDesc*(self: IDXGIOutput, desc: ptr DXGI_OUTPUT_DESC) =
  type F = proc(this: IDXGIOutput, desc: ptr DXGI_OUTPUT_DESC): int32 {.stdcall.}
  callVtblErr(self, 7, F, "IDXGIOutput.GetDesc", desc)

proc getDisplayModeList*(self: IDXGIOutput, format: uint32, flags: uint32, mode_count: ptr uint32, desc: ptr DXGI_MODE_DESC) =
  type F = proc(this: IDXGIOutput, format: uint32, flags: uint32, mode_count: ptr uint32, desc: ptr DXGI_MODE_DESC): int32 {.stdcall.}
  callVtblErr(self, 8, F, "IDXGIOutput.GetDisplayModeList", format, flags, mode_count, desc)

proc findClosestMatchingMode*(self: IDXGIOutput, mode: ptr DXGI_MODE_DESC, closest_match: ptr DXGI_MODE_DESC, device: pointer) =
  type F = proc(this: IDXGIOutput, mode: ptr DXGI_MODE_DESC, closest_match: ptr DXGI_MODE_DESC, device: pointer): int32 {.stdcall.}
  callVtblErr(self, 9, F, "IDXGIOutput.FindClosestMatchingMode", mode, closest_match, device)

proc waitForVBlank*(self: IDXGIOutput) =
  type F = proc(this: IDXGIOutput): int32 {.stdcall.}
  callVtbl0Err(self, 10, F, "IDXGIOutput.WaitForVBlank")

proc takeOwnership*(self: IDXGIOutput, device: pointer, exclusive: int32) =
  type F = proc(this: IDXGIOutput, device: pointer, exclusive: int32): int32 {.stdcall.}
  callVtblErr(self, 11, F, "IDXGIOutput.TakeOwnership", device, exclusive)

proc releaseOwnership*(self: IDXGIOutput) =
  type F = proc(this: IDXGIOutput): void {.stdcall.}
  callVtbl0(self, 12, F)

proc getGammaControlCapabilities*(self: IDXGIOutput, gamma_caps: ptr DXGI_GAMMA_CONTROL_CAPABILITIES) =
  type F = proc(this: IDXGIOutput, gamma_caps: ptr DXGI_GAMMA_CONTROL_CAPABILITIES): int32 {.stdcall.}
  callVtblErr(self, 13, F, "IDXGIOutput.GetGammaControlCapabilities", gamma_caps)

proc setGammaControl*(self: IDXGIOutput, gamma_control: ptr DXGI_GAMMA_CONTROL) =
  type F = proc(this: IDXGIOutput, gamma_control: ptr DXGI_GAMMA_CONTROL): int32 {.stdcall.}
  callVtblErr(self, 14, F, "IDXGIOutput.SetGammaControl", gamma_control)

proc getGammaControl*(self: IDXGIOutput, gamma_control: ptr DXGI_GAMMA_CONTROL) =
  type F = proc(this: IDXGIOutput, gamma_control: ptr DXGI_GAMMA_CONTROL): int32 {.stdcall.}
  callVtblErr(self, 15, F, "IDXGIOutput.GetGammaControl", gamma_control)

proc setDisplaySurface*(self: IDXGIOutput, surface: IDXGISurface) =
  type F = proc(this: IDXGIOutput, surface: IDXGISurface): int32 {.stdcall.}
  callVtblErr(self, 16, F, "IDXGIOutput.SetDisplaySurface", surface)

proc getDisplaySurfaceData*(self: IDXGIOutput, surface: IDXGISurface) =
  type F = proc(this: IDXGIOutput, surface: IDXGISurface): int32 {.stdcall.}
  callVtblErr(self, 17, F, "IDXGIOutput.GetDisplaySurfaceData", surface)

proc getFrameStatistics*(self: IDXGIOutput, stats: ptr DXGI_FRAME_STATISTICS) =
  type F = proc(this: IDXGIOutput, stats: ptr DXGI_FRAME_STATISTICS): int32 {.stdcall.}
  callVtblErr(self, 18, F, "IDXGIOutput.GetFrameStatistics", stats)

# --- IDXGIAdapter methods ---

proc enumOutputs*(self: IDXGIAdapter, output_idx: uint32, output: pointer) =
  type F = proc(this: IDXGIAdapter, output_idx: uint32, output: pointer): int32 {.stdcall.}
  callVtblErr(self, 7, F, "IDXGIAdapter.EnumOutputs", output_idx, output)

proc getDesc*(self: IDXGIAdapter, desc: ptr DXGI_ADAPTER_DESC) =
  type F = proc(this: IDXGIAdapter, desc: ptr DXGI_ADAPTER_DESC): int32 {.stdcall.}
  callVtblErr(self, 8, F, "IDXGIAdapter.GetDesc", desc)

proc checkInterfaceSupport*(self: IDXGIAdapter, guid: pointer, umd_version: ptr int64) =
  type F = proc(this: IDXGIAdapter, guid: pointer, umd_version: ptr int64): int32 {.stdcall.}
  callVtblErr(self, 9, F, "IDXGIAdapter.CheckInterfaceSupport", guid, umd_version)

# --- IDXGISwapChain methods ---

proc present*(self: IDXGISwapChain, sync_interval: uint32, flags: uint32) =
  type F = proc(this: IDXGISwapChain, sync_interval: uint32, flags: uint32): int32 {.stdcall.}
  callVtblErr(self, 8, F, "IDXGISwapChain.Present", sync_interval, flags)

proc getBuffer*(self: IDXGISwapChain, buffer_idx: uint32, riid: pointer, surface: pointer) =
  type F = proc(this: IDXGISwapChain, buffer_idx: uint32, riid: pointer, surface: pointer): int32 {.stdcall.}
  callVtblErr(self, 9, F, "IDXGISwapChain.GetBuffer", buffer_idx, riid, surface)

proc setFullscreenState*(self: IDXGISwapChain, fullscreen: int32, target: IDXGIOutput) =
  type F = proc(this: IDXGISwapChain, fullscreen: int32, target: IDXGIOutput): int32 {.stdcall.}
  callVtblErr(self, 10, F, "IDXGISwapChain.SetFullscreenState", fullscreen, target)

proc getFullscreenState*(self: IDXGISwapChain, fullscreen: ptr int32, target: pointer) =
  type F = proc(this: IDXGISwapChain, fullscreen: ptr int32, target: pointer): int32 {.stdcall.}
  callVtblErr(self, 11, F, "IDXGISwapChain.GetFullscreenState", fullscreen, target)

proc getDesc*(self: IDXGISwapChain, desc: ptr DXGI_SWAP_CHAIN_DESC) =
  type F = proc(this: IDXGISwapChain, desc: ptr DXGI_SWAP_CHAIN_DESC): int32 {.stdcall.}
  callVtblErr(self, 12, F, "IDXGISwapChain.GetDesc", desc)

proc resizeBuffers*(self: IDXGISwapChain, buffer_count: uint32, width: uint32, height: uint32, format: uint32, flags: uint32) =
  type F = proc(this: IDXGISwapChain, buffer_count: uint32, width: uint32, height: uint32, format: uint32, flags: uint32): int32 {.stdcall.}
  callVtblErr(self, 13, F, "IDXGISwapChain.ResizeBuffers", buffer_count, width, height, format, flags)

proc resizeTarget*(self: IDXGISwapChain, target_mode_desc: ptr DXGI_MODE_DESC) =
  type F = proc(this: IDXGISwapChain, target_mode_desc: ptr DXGI_MODE_DESC): int32 {.stdcall.}
  callVtblErr(self, 14, F, "IDXGISwapChain.ResizeTarget", target_mode_desc)

proc getContainingOutput*(self: IDXGISwapChain, output: pointer) =
  type F = proc(this: IDXGISwapChain, output: pointer): int32 {.stdcall.}
  callVtblErr(self, 15, F, "IDXGISwapChain.GetContainingOutput", output)

proc getFrameStatistics*(self: IDXGISwapChain, stats: ptr DXGI_FRAME_STATISTICS) =
  type F = proc(this: IDXGISwapChain, stats: ptr DXGI_FRAME_STATISTICS): int32 {.stdcall.}
  callVtblErr(self, 16, F, "IDXGISwapChain.GetFrameStatistics", stats)

proc getLastPresentCount*(self: IDXGISwapChain, last_present_count: ptr uint32) =
  type F = proc(this: IDXGISwapChain, last_present_count: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 17, F, "IDXGISwapChain.GetLastPresentCount", last_present_count)

# --- IDXGIFactory methods ---

proc enumAdapters*(self: IDXGIFactory, adapter_idx: uint32, adapter: pointer) =
  type F = proc(this: IDXGIFactory, adapter_idx: uint32, adapter: pointer): int32 {.stdcall.}
  callVtblErr(self, 7, F, "IDXGIFactory.EnumAdapters", adapter_idx, adapter)

proc makeWindowAssociation*(self: IDXGIFactory, window: pointer, flags: uint32) =
  type F = proc(this: IDXGIFactory, window: pointer, flags: uint32): int32 {.stdcall.}
  callVtblErr(self, 8, F, "IDXGIFactory.MakeWindowAssociation", window, flags)

proc getWindowAssociation*(self: IDXGIFactory, window: ptr pointer) =
  type F = proc(this: IDXGIFactory, window: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 9, F, "IDXGIFactory.GetWindowAssociation", window)

proc createSwapChain*(self: IDXGIFactory, device: pointer, desc: ptr DXGI_SWAP_CHAIN_DESC, swapchain: pointer) =
  type F = proc(this: IDXGIFactory, device: pointer, desc: ptr DXGI_SWAP_CHAIN_DESC, swapchain: pointer): int32 {.stdcall.}
  callVtblErr(self, 10, F, "IDXGIFactory.CreateSwapChain", device, desc, swapchain)

proc createSoftwareAdapter*(self: IDXGIFactory, swrast: pointer, adapter: pointer) =
  type F = proc(this: IDXGIFactory, swrast: pointer, adapter: pointer): int32 {.stdcall.}
  callVtblErr(self, 11, F, "IDXGIFactory.CreateSoftwareAdapter", swrast, adapter)

# --- IDXGIDevice methods ---

proc getAdapter*(self: IDXGIDevice, adapter: pointer) =
  type F = proc(this: IDXGIDevice, adapter: pointer): int32 {.stdcall.}
  callVtblErr(self, 7, F, "IDXGIDevice.GetAdapter", adapter)

proc createSurface*(self: IDXGIDevice, desc: ptr DXGI_SURFACE_DESC, surface_count: uint32, usage: uint32, shared_resource: ptr DXGI_SHARED_RESOURCE, surface: pointer) =
  type F = proc(this: IDXGIDevice, desc: ptr DXGI_SURFACE_DESC, surface_count: uint32, usage: uint32, shared_resource: ptr DXGI_SHARED_RESOURCE, surface: pointer): int32 {.stdcall.}
  callVtblErr(self, 8, F, "IDXGIDevice.CreateSurface", desc, surface_count, usage, shared_resource, surface)

proc queryResourceResidency*(self: IDXGIDevice, resources: pointer, residency: pointer, resource_count: uint32) =
  type F = proc(this: IDXGIDevice, resources: pointer, residency: pointer, resource_count: uint32): int32 {.stdcall.}
  callVtblErr(self, 9, F, "IDXGIDevice.QueryResourceResidency", resources, residency, resource_count)

proc setGPUThreadPriority*(self: IDXGIDevice, priority: int32) =
  type F = proc(this: IDXGIDevice, priority: int32): int32 {.stdcall.}
  callVtblErr(self, 10, F, "IDXGIDevice.SetGPUThreadPriority", priority)

proc getGPUThreadPriority*(self: IDXGIDevice, priority: ptr int32) =
  type F = proc(this: IDXGIDevice, priority: ptr int32): int32 {.stdcall.}
  callVtblErr(self, 11, F, "IDXGIDevice.GetGPUThreadPriority", priority)

# --- IDXGIAdapter1 methods ---

proc getDesc1*(self: IDXGIAdapter1, pDesc: ptr DXGI_ADAPTER_DESC1) =
  type F = proc(this: IDXGIAdapter1, pDesc: ptr DXGI_ADAPTER_DESC1): int32 {.stdcall.}
  callVtblErr(self, 10, F, "IDXGIAdapter1.GetDesc1", pDesc)

# --- IDXGIDevice1 methods ---

proc setMaximumFrameLatency*(self: IDXGIDevice1, MaxLatency: uint32) =
  type F = proc(this: IDXGIDevice1, MaxLatency: uint32): int32 {.stdcall.}
  callVtblErr(self, 12, F, "IDXGIDevice1.SetMaximumFrameLatency", MaxLatency)

proc getMaximumFrameLatency*(self: IDXGIDevice1, pMaxLatency: ptr uint32) =
  type F = proc(this: IDXGIDevice1, pMaxLatency: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 13, F, "IDXGIDevice1.GetMaximumFrameLatency", pMaxLatency)

# --- IDXGIFactory1 methods ---

proc enumAdapters1*(self: IDXGIFactory1, Adapter: uint32, ppAdapter: pointer) =
  type F = proc(this: IDXGIFactory1, Adapter: uint32, ppAdapter: pointer): int32 {.stdcall.}
  callVtblErr(self, 12, F, "IDXGIFactory1.EnumAdapters1", Adapter, ppAdapter)

proc isCurrent*(self: IDXGIFactory1): int32 =
  type F = proc(this: IDXGIFactory1): int32 {.stdcall.}
  callVtbl0(self, 13, F)

