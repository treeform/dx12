# Auto-generated from dxgi1_6.idl — do not edit manually.
# Regenerate with: nim r tools/generate_api.nim

import dxgi1_5, vtable
export dxgi1_5

# DXGI_ADAPTER_FLAG3
const
  DXGI_ADAPTER_FLAG3_NONE* = 0x0'u32
  DXGI_ADAPTER_FLAG3_REMOTE* = 0x1'u32
  DXGI_ADAPTER_FLAG3_SOFTWARE* = 0x2'u32
  DXGI_ADAPTER_FLAG3_ACG_COMPATIBLE* = 0x4'u32
  DXGI_ADAPTER_FLAG3_SUPPORT_MONITORED_FENCES* = 0x8'u32
  DXGI_ADAPTER_FLAG3_SUPPORT_NON_MONITORED_FENCES* = 0x10'u32
  DXGI_ADAPTER_FLAG3_KEYED_MUTEX_CONFORMANCE* = 0x20'u32
  DXGI_ADAPTER_FLAG3_FORCE_DWORD* = 0xffffffff'u32

# DXGI_HARDWARE_COMPOSITION_SUPPORT_FLAGS
const
  DXGI_HARDWARE_COMPOSITION_SUPPORT_FLAG_FULLSCREEN* = 0x1'u32
  DXGI_HARDWARE_COMPOSITION_SUPPORT_FLAG_WINDOWED* = 0x2'u32
  DXGI_HARDWARE_COMPOSITION_SUPPORT_FLAG_CURSOR_STRETCHED* = 0x4'u32

# DXGI_GPU_PREFERENCE
const
  DXGI_GPU_PREFERENCE_UNSPECIFIED* = 0x0'u32
  DXGI_GPU_PREFERENCE_MINIMUM_POWER* = 0x1'u32
  DXGI_GPU_PREFERENCE_HIGH_PERFORMANCE* = 0x2'u32

type
  IDXGIAdapter4* = ptr object
  IDXGIOutput6* = ptr object
  IDXGIFactory6* = ptr object
  IDXGIFactory7* = ptr object

type
  DXGI_ADAPTER_DESC3* = object
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
    GraphicsPreemptionGranularity*: uint32
    ComputePreemptionGranularity*: uint32

  DXGI_OUTPUT_DESC1* = object
    DeviceName*: array[32, pointer]
    DesktopCoordinates*: pointer
    AttachedToDesktop*: int32
    Rotation*: uint32
    Monitor*: pointer
    BitsPerColor*: uint32
    ColorSpace*: uint32
    RedPrimary*: array[2, float32]
    GreenPrimary*: array[2, float32]
    BluePrimary*: array[2, float32]
    WhitePoint*: array[2, float32]
    MinLuminance*: float32
    MaxLuminance*: float32
    MaxFullFrameLuminance*: float32

# --- IDXGIAdapter4 methods ---

proc getDesc3*(self: IDXGIAdapter4, desc: ptr DXGI_ADAPTER_DESC3) =
  type F = proc(this: IDXGIAdapter4, desc: ptr DXGI_ADAPTER_DESC3): int32 {.stdcall.}
  callVtblErr(self, 18, F, "IDXGIAdapter4.GetDesc3", desc)

# --- IDXGIOutput6 methods ---

proc getDesc1*(self: IDXGIOutput6, desc: ptr DXGI_OUTPUT_DESC1) =
  type F = proc(this: IDXGIOutput6, desc: ptr DXGI_OUTPUT_DESC1): int32 {.stdcall.}
  callVtblErr(self, 27, F, "IDXGIOutput6.GetDesc1", desc)

proc checkHardwareCompositionSupport*(self: IDXGIOutput6, flags: ptr uint32) =
  type F = proc(this: IDXGIOutput6, flags: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 28, F, "IDXGIOutput6.CheckHardwareCompositionSupport", flags)

# --- IDXGIFactory6 methods ---

proc enumAdapterByGpuPreference*(self: IDXGIFactory6, adapter_idx: uint32, gpu_preference: uint32, iid: pointer, adapter: pointer) =
  type F = proc(this: IDXGIFactory6, adapter_idx: uint32, gpu_preference: uint32, iid: pointer, adapter: pointer): int32 {.stdcall.}
  callVtblErr(self, 29, F, "IDXGIFactory6.EnumAdapterByGpuPreference", adapter_idx, gpu_preference, iid, adapter)

# --- IDXGIFactory7 methods ---

proc registerAdaptersChangedEvent*(self: IDXGIFactory7, event: pointer, cookie: ptr uint32) =
  type F = proc(this: IDXGIFactory7, event: pointer, cookie: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 30, F, "IDXGIFactory7.RegisterAdaptersChangedEvent", event, cookie)

proc unregisterAdaptersChangedEvent*(self: IDXGIFactory7, cookie: uint32) =
  type F = proc(this: IDXGIFactory7, cookie: uint32): int32 {.stdcall.}
  callVtblErr(self, 31, F, "IDXGIFactory7.UnregisterAdaptersChangedEvent", cookie)

