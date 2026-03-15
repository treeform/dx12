# Auto-generated from dxgi1_3.idl — do not edit manually.
# Regenerate with: nim r tools/generate_api.nim

import dxgi1_2, vtable
export dxgi1_2

const
  DXGI_CREATE_FACTORY_DEBUG* = 0x1'u32

# DXGI_MULTIPLANE_OVERLAY_YCbCr_FLAGS
const
  DXGI_MULTIPLANE_OVERLAY_YCbCr_FLAG_NOMINAL_RANGE* = 0x1'u32
  DXGI_MULTIPLANE_OVERLAY_YCbCr_FLAG_BT709* = 0x2'u32
  DXGI_MULTIPLANE_OVERLAY_YCbCr_FLAG_xvYCC* = 0x4'u32

# DXGI_FRAME_PRESENTATION_MODE
const
  DXGI_FRAME_PRESENTATION_MODE_COMPOSED* = 0'u32
  DXGI_FRAME_PRESENTATION_MODE_OVERLAY* = 1'u32
  DXGI_FRAME_PRESENTATION_MODE_NONE* = 2'u32
  DXGI_FRAME_PRESENTATION_MODE_COMPOSITION_FAILURE* = 3'u32

# DXGI_OVERLAY_SUPPORT_FLAG
const
  DXGI_OVERLAY_SUPPORT_FLAG_DIRECT* = 0x1'u32
  DXGI_OVERLAY_SUPPORT_FLAG_SCALING* = 0x2'u32

type
  IDXGIDevice3* = ptr object
  IDXGISwapChain2* = ptr object
  IDXGIOutput2* = ptr object
  IDXGIFactory3* = ptr object
  IDXGIDecodeSwapChain* = ptr object
  IDXGIFactoryMedia* = ptr object
  IDXGISwapChainMedia* = ptr object
  IDXGIOutput3* = ptr object

type
  DXGI_MATRIX_3X2_F* = object
    f_11*: float32
    f_12*: float32
    f_21*: float32
    f_22*: float32
    f_31*: float32
    f_32*: float32

  DXGI_DECODE_SWAP_CHAIN_DESC* = object
    Flags*: uint32

  DXGI_FRAME_STATISTICS_MEDIA* = object
    PresentCount*: uint32
    PresentRefreshCount*: uint32
    SyncRefreshCount*: uint32
    SyncQPCTime*: int64
    SyncGPUTime*: int64
    CompositionMode*: uint32
    ApprovedPresentDuration*: uint32

# --- IDXGIDevice3 methods ---

proc trim*(self: IDXGIDevice3) =
  type F = proc(this: IDXGIDevice3): void {.stdcall.}
  callVtbl0(self, 17, F)

# --- IDXGISwapChain2 methods ---

proc setSourceSize*(self: IDXGISwapChain2, width: uint32, height: uint32) =
  type F = proc(this: IDXGISwapChain2, width: uint32, height: uint32): int32 {.stdcall.}
  callVtblErr(self, 29, F, "IDXGISwapChain2.SetSourceSize", width, height)

proc getSourceSize*(self: IDXGISwapChain2, width: ptr uint32, height: ptr uint32) =
  type F = proc(this: IDXGISwapChain2, width: ptr uint32, height: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 30, F, "IDXGISwapChain2.GetSourceSize", width, height)

proc setMaximumFrameLatency*(self: IDXGISwapChain2, max_latency: uint32) =
  type F = proc(this: IDXGISwapChain2, max_latency: uint32): int32 {.stdcall.}
  callVtblErr(self, 31, F, "IDXGISwapChain2.SetMaximumFrameLatency", max_latency)

proc getMaximumFrameLatency*(self: IDXGISwapChain2, max_latency: ptr uint32) =
  type F = proc(this: IDXGISwapChain2, max_latency: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 32, F, "IDXGISwapChain2.GetMaximumFrameLatency", max_latency)

proc getFrameLatencyWaitableObject*(self: IDXGISwapChain2): pointer =
  type F = proc(this: IDXGISwapChain2): pointer {.stdcall.}
  callVtbl0(self, 33, F)

proc setMatrixTransform*(self: IDXGISwapChain2, matrix: ptr DXGI_MATRIX_3X2_F) =
  type F = proc(this: IDXGISwapChain2, matrix: ptr DXGI_MATRIX_3X2_F): int32 {.stdcall.}
  callVtblErr(self, 34, F, "IDXGISwapChain2.SetMatrixTransform", matrix)

proc getMatrixTransform*(self: IDXGISwapChain2, matrix: ptr DXGI_MATRIX_3X2_F) =
  type F = proc(this: IDXGISwapChain2, matrix: ptr DXGI_MATRIX_3X2_F): int32 {.stdcall.}
  callVtblErr(self, 35, F, "IDXGISwapChain2.GetMatrixTransform", matrix)

# --- IDXGIOutput2 methods ---

proc supportsOverlays*(self: IDXGIOutput2): int32 =
  type F = proc(this: IDXGIOutput2): int32 {.stdcall.}
  callVtbl0(self, 23, F)

# --- IDXGIFactory3 methods ---

proc getCreationFlags*(self: IDXGIFactory3): uint32 =
  type F = proc(this: IDXGIFactory3): uint32 {.stdcall.}
  callVtbl0(self, 25, F)

# --- IDXGIDecodeSwapChain methods ---

proc presentBuffer*(self: IDXGIDecodeSwapChain, buffer_to_present: uint32, sync_interval: uint32, flags: uint32) =
  type F = proc(this: IDXGIDecodeSwapChain, buffer_to_present: uint32, sync_interval: uint32, flags: uint32): int32 {.stdcall.}
  callVtblErr(self, 3, F, "IDXGIDecodeSwapChain.PresentBuffer", buffer_to_present, sync_interval, flags)

proc setSourceRect*(self: IDXGIDecodeSwapChain, rect: pointer) =
  type F = proc(this: IDXGIDecodeSwapChain, rect: pointer): int32 {.stdcall.}
  callVtblErr(self, 4, F, "IDXGIDecodeSwapChain.SetSourceRect", rect)

proc setTargetRect*(self: IDXGIDecodeSwapChain, rect: pointer) =
  type F = proc(this: IDXGIDecodeSwapChain, rect: pointer): int32 {.stdcall.}
  callVtblErr(self, 5, F, "IDXGIDecodeSwapChain.SetTargetRect", rect)

proc setDestSize*(self: IDXGIDecodeSwapChain, width: uint32, height: uint32) =
  type F = proc(this: IDXGIDecodeSwapChain, width: uint32, height: uint32): int32 {.stdcall.}
  callVtblErr(self, 6, F, "IDXGIDecodeSwapChain.SetDestSize", width, height)

proc getSourceRect*(self: IDXGIDecodeSwapChain, rect: pointer) =
  type F = proc(this: IDXGIDecodeSwapChain, rect: pointer): int32 {.stdcall.}
  callVtblErr(self, 7, F, "IDXGIDecodeSwapChain.GetSourceRect", rect)

proc getTargetRect*(self: IDXGIDecodeSwapChain, rect: pointer) =
  type F = proc(this: IDXGIDecodeSwapChain, rect: pointer): int32 {.stdcall.}
  callVtblErr(self, 8, F, "IDXGIDecodeSwapChain.GetTargetRect", rect)

proc getDestSize*(self: IDXGIDecodeSwapChain, width: ptr uint32, height: ptr uint32) =
  type F = proc(this: IDXGIDecodeSwapChain, width: ptr uint32, height: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 9, F, "IDXGIDecodeSwapChain.GetDestSize", width, height)

proc setColorSpace*(self: IDXGIDecodeSwapChain, colorspace: uint32) =
  type F = proc(this: IDXGIDecodeSwapChain, colorspace: uint32): int32 {.stdcall.}
  callVtblErr(self, 10, F, "IDXGIDecodeSwapChain.SetColorSpace", colorspace)

proc getColorSpace*(self: IDXGIDecodeSwapChain): uint32 =
  type F = proc(this: IDXGIDecodeSwapChain): uint32 {.stdcall.}
  callVtbl0(self, 11, F)

# --- IDXGIFactoryMedia methods ---

proc createSwapChainForCompositionSurfaceHandle*(self: IDXGIFactoryMedia, device: pointer, surface: pointer, desc: ptr DXGI_SWAP_CHAIN_DESC1, restrict_to_output: IDXGIOutput, swapchain: pointer) =
  type F = proc(this: IDXGIFactoryMedia, device: pointer, surface: pointer, desc: ptr DXGI_SWAP_CHAIN_DESC1, restrict_to_output: IDXGIOutput, swapchain: pointer): int32 {.stdcall.}
  callVtblErr(self, 3, F, "IDXGIFactoryMedia.CreateSwapChainForCompositionSurfaceHandle", device, surface, desc, restrict_to_output, swapchain)

proc createDecodeSwapChainForCompositionSurfaceHandle*(self: IDXGIFactoryMedia, device: pointer, surface: pointer, desc: ptr DXGI_DECODE_SWAP_CHAIN_DESC, yuv_decode_buffers: IDXGIResource, restrict_to_output: IDXGIOutput, swapchain: pointer) =
  type F = proc(this: IDXGIFactoryMedia, device: pointer, surface: pointer, desc: ptr DXGI_DECODE_SWAP_CHAIN_DESC, yuv_decode_buffers: IDXGIResource, restrict_to_output: IDXGIOutput, swapchain: pointer): int32 {.stdcall.}
  callVtblErr(self, 4, F, "IDXGIFactoryMedia.CreateDecodeSwapChainForCompositionSurfaceHandle", device, surface, desc, yuv_decode_buffers, restrict_to_output, swapchain)

# --- IDXGISwapChainMedia methods ---

proc getFrameStatisticsMedia*(self: IDXGISwapChainMedia, stats: ptr DXGI_FRAME_STATISTICS_MEDIA) =
  type F = proc(this: IDXGISwapChainMedia, stats: ptr DXGI_FRAME_STATISTICS_MEDIA): int32 {.stdcall.}
  callVtblErr(self, 3, F, "IDXGISwapChainMedia.GetFrameStatisticsMedia", stats)

proc setPresentDuration*(self: IDXGISwapChainMedia, duration: uint32) =
  type F = proc(this: IDXGISwapChainMedia, duration: uint32): int32 {.stdcall.}
  callVtblErr(self, 4, F, "IDXGISwapChainMedia.SetPresentDuration", duration)

proc checkPresentDurationSupport*(self: IDXGISwapChainMedia, desired_present_duration: uint32, closest_smaller_present_duration: ptr uint32, closest_larger_present_duration: ptr uint32) =
  type F = proc(this: IDXGISwapChainMedia, desired_present_duration: uint32, closest_smaller_present_duration: ptr uint32, closest_larger_present_duration: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 5, F, "IDXGISwapChainMedia.CheckPresentDurationSupport", desired_present_duration, closest_smaller_present_duration, closest_larger_present_duration)

# --- IDXGIOutput3 methods ---

proc checkOverlaySupport*(self: IDXGIOutput3, enum_format: uint32, concerned_device: pointer, flags: ptr uint32) =
  type F = proc(this: IDXGIOutput3, enum_format: uint32, concerned_device: pointer, flags: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 24, F, "IDXGIOutput3.CheckOverlaySupport", enum_format, concerned_device, flags)

