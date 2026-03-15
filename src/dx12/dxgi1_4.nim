# Auto-generated from dxgi1_4.idl — do not edit manually.
# Regenerate with: nim r tools/generate_api.nim

import dxgi1_3, vtable
export dxgi1_3

# DXGI_SWAP_CHAIN_COLOR_SPACE_SUPPORT_FLAG
const
  DXGI_SWAP_CHAIN_COLOR_SPACE_SUPPORT_FLAG_PRESENT* = 0x1'u32
  DXGI_SWAP_CHAIN_COLOR_SPACE_SUPPORT_FLAG_OVERLAY_PRESENT* = 0x2'u32

# DXGI_OVERLAY_COLOR_SPACE_SUPPORT_FLAG
const
  DXGI_OVERLAY_COLOR_SPACE_SUPPORT_FLAG_PRESENT* = 0x1'u32

# DXGI_MEMORY_SEGMENT_GROUP
const
  DXGI_MEMORY_SEGMENT_GROUP_LOCAL* = 0x0'u32
  DXGI_MEMORY_SEGMENT_GROUP_NON_LOCAL* = 0x1'u32

type
  IDXGISwapChain3* = ptr object
  IDXGIOutput4* = ptr object
  IDXGIFactory4* = ptr object
  IDXGIAdapter3* = ptr object

type
  DXGI_QUERY_VIDEO_MEMORY_INFO* = object
    Budget*: uint64
    CurrentUsage*: uint64
    AvailableForReservation*: uint64
    CurrentReservation*: uint64

# --- IDXGISwapChain3 methods ---

proc getCurrentBackBufferIndex*(self: IDXGISwapChain3): uint32 =
  type F = proc(this: IDXGISwapChain3): uint32 {.stdcall.}
  callVtbl0(self, 36, F)

proc checkColorSpaceSupport*(self: IDXGISwapChain3, colour_space: uint32, colour_space_support: ptr uint32) =
  type F = proc(this: IDXGISwapChain3, colour_space: uint32, colour_space_support: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 37, F, "IDXGISwapChain3.CheckColorSpaceSupport", colour_space, colour_space_support)

proc setColorSpace1*(self: IDXGISwapChain3, colour_space: uint32) =
  type F = proc(this: IDXGISwapChain3, colour_space: uint32): int32 {.stdcall.}
  callVtblErr(self, 38, F, "IDXGISwapChain3.SetColorSpace1", colour_space)

proc resizeBuffers1*(self: IDXGISwapChain3, buffer_count: uint32, width: uint32, height: uint32, format: uint32, flags: uint32, node_mask: ptr uint32, present_queue: pointer) =
  type F = proc(this: IDXGISwapChain3, buffer_count: uint32, width: uint32, height: uint32, format: uint32, flags: uint32, node_mask: ptr uint32, present_queue: pointer): int32 {.stdcall.}
  callVtblErr(self, 39, F, "IDXGISwapChain3.ResizeBuffers1", buffer_count, width, height, format, flags, node_mask, present_queue)

# --- IDXGIOutput4 methods ---

proc checkOverlayColorSpaceSupport*(self: IDXGIOutput4, format: uint32, colour_space: uint32, device: pointer, flags: ptr uint32) =
  type F = proc(this: IDXGIOutput4, format: uint32, colour_space: uint32, device: pointer, flags: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 25, F, "IDXGIOutput4.CheckOverlayColorSpaceSupport", format, colour_space, device, flags)

# --- IDXGIFactory4 methods ---

proc enumAdapterByLuid*(self: IDXGIFactory4, luid: uint64, iid: pointer, adapter: pointer) =
  type F = proc(this: IDXGIFactory4, luid: uint64, iid: pointer, adapter: pointer): int32 {.stdcall.}
  callVtblErr(self, 26, F, "IDXGIFactory4.EnumAdapterByLuid", luid, iid, adapter)

proc enumWarpAdapter*(self: IDXGIFactory4, iid: pointer, adapter: pointer) =
  type F = proc(this: IDXGIFactory4, iid: pointer, adapter: pointer): int32 {.stdcall.}
  callVtblErr(self, 27, F, "IDXGIFactory4.EnumWarpAdapter", iid, adapter)

# --- IDXGIAdapter3 methods ---

proc registerHardwareContentProtectionTeardownStatusEvent*(self: IDXGIAdapter3, event: pointer, cookie: ptr uint32) =
  type F = proc(this: IDXGIAdapter3, event: pointer, cookie: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 12, F, "IDXGIAdapter3.RegisterHardwareContentProtectionTeardownStatusEvent", event, cookie)

proc unregisterHardwareContentProtectionTeardownStatus*(self: IDXGIAdapter3, cookie: uint32) =
  type F = proc(this: IDXGIAdapter3, cookie: uint32): void {.stdcall.}
  callVtbl(self, 13, F, cookie)

proc queryVideoMemoryInfo*(self: IDXGIAdapter3, node_index: uint32, segment_group: uint32, memory_info: ptr DXGI_QUERY_VIDEO_MEMORY_INFO) =
  type F = proc(this: IDXGIAdapter3, node_index: uint32, segment_group: uint32, memory_info: ptr DXGI_QUERY_VIDEO_MEMORY_INFO): int32 {.stdcall.}
  callVtblErr(self, 14, F, "IDXGIAdapter3.QueryVideoMemoryInfo", node_index, segment_group, memory_info)

proc setVideoMemoryReservation*(self: IDXGIAdapter3, node_index: uint32, segment_group: uint32, reservation: uint64) =
  type F = proc(this: IDXGIAdapter3, node_index: uint32, segment_group: uint32, reservation: uint64): int32 {.stdcall.}
  callVtblErr(self, 15, F, "IDXGIAdapter3.SetVideoMemoryReservation", node_index, segment_group, reservation)

proc registerVideoMemoryBudgetChangeNotificationEvent*(self: IDXGIAdapter3, event: pointer, cookie: ptr uint32) =
  type F = proc(this: IDXGIAdapter3, event: pointer, cookie: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 16, F, "IDXGIAdapter3.RegisterVideoMemoryBudgetChangeNotificationEvent", event, cookie)

proc unregisterVideoMemoryBudgetChangeNotification*(self: IDXGIAdapter3, cookie: uint32) =
  type F = proc(this: IDXGIAdapter3, cookie: uint32): void {.stdcall.}
  callVtbl(self, 17, F, cookie)

