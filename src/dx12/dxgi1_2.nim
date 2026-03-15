# Auto-generated from dxgi1_2.idl — do not edit manually.
# Regenerate with: nim r tools/generate_api.nim

import dxgi, vtable
export dxgi

const
  DXGI_ENUM_MODES_STEREO* = 0x4'u32
  DXGI_ENUM_MODES_DISABLED_STEREO* = 0x8'u32
  DXGI_SHARED_RESOURCE_READ* = 0x80000000'u32
  DXGI_SHARED_RESOURCE_WRITE* = 0x00000001'u32

# DXGI_OFFER_RESOURCE_PRIORITY
const
  DXGI_OFFER_RESOURCE_PRIORITY_LOW* = 1'u32
  DXGI_OFFER_RESOURCE_PRIORITY_NORMAL* = 2'u32
  DXGI_OFFER_RESOURCE_PRIORITY_HIGH* = 3'u32

# DXGI_ALPHA_MODE
const
  DXGI_ALPHA_MODE_UNSPECIFIED* = 0'u32
  DXGI_ALPHA_MODE_PREMULTIPLIED* = 1'u32
  DXGI_ALPHA_MODE_STRAIGHT* = 2'u32
  DXGI_ALPHA_MODE_IGNORE* = 3'u32
  DXGI_ALPHA_MODE_FORCE_DWORD* = 0xffffffff'u32

# DXGI_OUTDUPL_POINTER_SHAPE_TYPE
const
  DXGI_OUTDUPL_POINTER_SHAPE_TYPE_MONOCHROME* = 0x00000001'u32
  DXGI_OUTDUPL_POINTER_SHAPE_TYPE_COLOR* = 0x00000002'u32
  DXGI_OUTDUPL_POINTER_SHAPE_TYPE_MASKED_COLOR* = 0x00000004'u32

# DXGI_SCALING
const
  DXGI_SCALING_STRETCH* = 0'u32
  DXGI_SCALING_NONE* = 1'u32
  DXGI_SCALING_ASPECT_RATIO_STRETCH* = 2'u32

# DXGI_GRAPHICS_PREEMPTION_GRANULARITY
const
  DXGI_GRAPHICS_PREEMPTION_DMA_BUFFER_BOUNDARY* = 0'u32
  DXGI_GRAPHICS_PREEMPTION_PRIMITIVE_BOUNDARY* = 1'u32
  DXGI_GRAPHICS_PREEMPTION_TRIANGLE_BOUNDARY* = 2'u32
  DXGI_GRAPHICS_PREEMPTION_PIXEL_BOUNDARY* = 3'u32
  DXGI_GRAPHICS_PREEMPTION_INSTRUCTION_BOUNDARY* = 4'u32

# DXGI_COMPUTE_PREEMPTION_GRANULARITY
const
  DXGI_COMPUTE_PREEMPTION_DMA_BUFFER_BOUNDARY* = 0'u32
  DXGI_COMPUTE_PREEMPTION_DISPATCH_BOUNDARY* = 1'u32
  DXGI_COMPUTE_PREEMPTION_THREAD_GROUP_BOUNDARY* = 2'u32
  DXGI_COMPUTE_PREEMPTION_THREAD_BOUNDARY* = 3'u32
  DXGI_COMPUTE_PREEMPTION_INSTRUCTION_BOUNDARY* = 4'u32

type
  IDXGIOutputDuplication* = ptr object
  IDXGISurface2* = ptr object
  IDXGIResource1* = ptr object
  IDXGIDisplayControl* = ptr object
  IDXGIDevice2* = ptr object
  IDXGISwapChain1* = ptr object
  IDXGIFactory2* = ptr object
  IDXGIAdapter2* = ptr object
  IDXGIOutput1* = ptr object

type
  DXGI_OUTDUPL_MOVE_RECT* = object
    SourcePoint*: pointer
    DestinationRect*: pointer

  DXGI_OUTDUPL_DESC* = object
    ModeDesc*: DXGI_MODE_DESC
    Rotation*: uint32
    DesktopImageInSystemMemory*: int32

  DXGI_OUTDUPL_POINTER_POSITION* = object
    Position*: pointer
    Visible*: int32

  DXGI_OUTDUPL_POINTER_SHAPE_INFO* = object
    typ*: uint32
    Width*: uint32
    Height*: uint32
    Pitch*: uint32
    HotSpot*: pointer

  DXGI_OUTDUPL_FRAME_INFO* = object
    LastPresentTime*: int64
    LastMouseUpdateTime*: int64
    AccumulatedFrames*: uint32
    RectsCoalesced*: int32
    ProtectedContentMaskedOut*: int32
    PointerPosition*: DXGI_OUTDUPL_POINTER_POSITION
    TotalMetadataBufferSize*: uint32
    PointerShapeBufferSize*: uint32

  DXGI_MODE_DESC1* = object
    Width*: uint32
    Height*: uint32
    RefreshRate*: DXGI_RATIONAL
    Format*: uint32
    ScanlineOrdering*: uint32
    Scaling*: uint32
    Stereo*: int32

  DXGI_SWAP_CHAIN_DESC1* = object
    Width*: uint32
    Height*: uint32
    Format*: uint32
    Stereo*: int32
    SampleDesc*: DXGI_SAMPLE_DESC
    BufferUsage*: uint32
    BufferCount*: uint32
    Scaling*: uint32
    SwapEffect*: uint32
    AlphaMode*: uint32
    Flags*: uint32

  DXGI_SWAP_CHAIN_FULLSCREEN_DESC* = object
    RefreshRate*: DXGI_RATIONAL
    ScanlineOrdering*: uint32
    Scaling*: uint32
    Windowed*: int32

  DXGI_PRESENT_PARAMETERS* = object
    DirtyRectsCount*: uint32
    pDirtyRects*: pointer
    pScrollRect*: pointer
    pScrollOffset*: pointer

  DXGI_ADAPTER_DESC2* = object
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

# --- IDXGIOutputDuplication methods ---

proc getDesc*(self: IDXGIOutputDuplication, desc: ptr DXGI_OUTDUPL_DESC) =
  type F = proc(this: IDXGIOutputDuplication, desc: ptr DXGI_OUTDUPL_DESC): void {.stdcall.}
  callVtbl(self, 7, F, desc)

proc acquireNextFrame*(self: IDXGIOutputDuplication, timeout_in_milliseconds: uint32, frame_info: ptr DXGI_OUTDUPL_FRAME_INFO, desktop_resource: pointer) =
  type F = proc(this: IDXGIOutputDuplication, timeout_in_milliseconds: uint32, frame_info: ptr DXGI_OUTDUPL_FRAME_INFO, desktop_resource: pointer): int32 {.stdcall.}
  callVtblErr(self, 8, F, "IDXGIOutputDuplication.AcquireNextFrame", timeout_in_milliseconds, frame_info, desktop_resource)

proc getFrameDirtyRects*(self: IDXGIOutputDuplication, dirty_rects_buffer_size: uint32, dirty_rects_buffer: pointer, dirty_rects_buffer_size_required: ptr uint32) =
  type F = proc(this: IDXGIOutputDuplication, dirty_rects_buffer_size: uint32, dirty_rects_buffer: pointer, dirty_rects_buffer_size_required: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 9, F, "IDXGIOutputDuplication.GetFrameDirtyRects", dirty_rects_buffer_size, dirty_rects_buffer, dirty_rects_buffer_size_required)

proc getFrameMoveRects*(self: IDXGIOutputDuplication, move_rects_buffer_size: uint32, move_rect_buffer: ptr DXGI_OUTDUPL_MOVE_RECT, move_rects_buffer_size_required: ptr uint32) =
  type F = proc(this: IDXGIOutputDuplication, move_rects_buffer_size: uint32, move_rect_buffer: ptr DXGI_OUTDUPL_MOVE_RECT, move_rects_buffer_size_required: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 10, F, "IDXGIOutputDuplication.GetFrameMoveRects", move_rects_buffer_size, move_rect_buffer, move_rects_buffer_size_required)

proc getFramePointerShape*(self: IDXGIOutputDuplication, pointer_shape_buffer_size: uint32, pointer_shape_buffer: pointer, pointer_shape_buffer_size_required: ptr uint32, pointer_shape_info: ptr DXGI_OUTDUPL_POINTER_SHAPE_INFO) =
  type F = proc(this: IDXGIOutputDuplication, pointer_shape_buffer_size: uint32, pointer_shape_buffer: pointer, pointer_shape_buffer_size_required: ptr uint32, pointer_shape_info: ptr DXGI_OUTDUPL_POINTER_SHAPE_INFO): int32 {.stdcall.}
  callVtblErr(self, 11, F, "IDXGIOutputDuplication.GetFramePointerShape", pointer_shape_buffer_size, pointer_shape_buffer, pointer_shape_buffer_size_required, pointer_shape_info)

proc mapDesktopSurface*(self: IDXGIOutputDuplication, locked_rect: ptr DXGI_MAPPED_RECT) =
  type F = proc(this: IDXGIOutputDuplication, locked_rect: ptr DXGI_MAPPED_RECT): int32 {.stdcall.}
  callVtblErr(self, 12, F, "IDXGIOutputDuplication.MapDesktopSurface", locked_rect)

proc unMapDesktopSurface*(self: IDXGIOutputDuplication) =
  type F = proc(this: IDXGIOutputDuplication): int32 {.stdcall.}
  callVtbl0Err(self, 13, F, "IDXGIOutputDuplication.UnMapDesktopSurface")

proc releaseFrame*(self: IDXGIOutputDuplication) =
  type F = proc(this: IDXGIOutputDuplication): int32 {.stdcall.}
  callVtbl0Err(self, 14, F, "IDXGIOutputDuplication.ReleaseFrame")

# --- IDXGISurface2 methods ---

proc getResource*(self: IDXGISurface2, iid: pointer, parent_resource: pointer, subresource_idx: ptr uint32) =
  type F = proc(this: IDXGISurface2, iid: pointer, parent_resource: pointer, subresource_idx: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 13, F, "IDXGISurface2.GetResource", iid, parent_resource, subresource_idx)

# --- IDXGIResource1 methods ---

proc createSubresourceSurface*(self: IDXGIResource1, index: uint32, surface: pointer) =
  type F = proc(this: IDXGIResource1, index: uint32, surface: pointer): int32 {.stdcall.}
  callVtblErr(self, 12, F, "IDXGIResource1.CreateSubresourceSurface", index, surface)

proc createSharedHandle*(self: IDXGIResource1, attributes: ptr pointer, access: uint32, name: pointer, handle: ptr pointer) =
  type F = proc(this: IDXGIResource1, attributes: ptr pointer, access: uint32, name: pointer, handle: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 13, F, "IDXGIResource1.CreateSharedHandle", attributes, access, name, handle)

# --- IDXGIDisplayControl methods ---

proc isStereoEnabled*(self: IDXGIDisplayControl): int32 =
  type F = proc(this: IDXGIDisplayControl): int32 {.stdcall.}
  callVtbl0(self, 3, F)

proc setStereoEnabled*(self: IDXGIDisplayControl, enabled: int32) =
  type F = proc(this: IDXGIDisplayControl, enabled: int32): void {.stdcall.}
  callVtbl(self, 4, F, enabled)

# --- IDXGIDevice2 methods ---

proc offerResources*(self: IDXGIDevice2, NumResources: uint32, ppResources: ptr IDXGIResource, Priority: uint32) =
  type F = proc(this: IDXGIDevice2, NumResources: uint32, ppResources: ptr IDXGIResource, Priority: uint32): int32 {.stdcall.}
  callVtblErr(self, 14, F, "IDXGIDevice2.OfferResources", NumResources, ppResources, Priority)

proc reclaimResources*(self: IDXGIDevice2, NumResources: uint32, ppResources: ptr IDXGIResource, pDiscarded: ptr int32) =
  type F = proc(this: IDXGIDevice2, NumResources: uint32, ppResources: ptr IDXGIResource, pDiscarded: ptr int32): int32 {.stdcall.}
  callVtblErr(self, 15, F, "IDXGIDevice2.ReclaimResources", NumResources, ppResources, pDiscarded)

proc enqueueSetEvent*(self: IDXGIDevice2, hEvent: pointer) =
  type F = proc(this: IDXGIDevice2, hEvent: pointer): int32 {.stdcall.}
  callVtblErr(self, 16, F, "IDXGIDevice2.EnqueueSetEvent", hEvent)

# --- IDXGISwapChain1 methods ---

proc getDesc1*(self: IDXGISwapChain1, pDesc: ptr DXGI_SWAP_CHAIN_DESC1) =
  type F = proc(this: IDXGISwapChain1, pDesc: ptr DXGI_SWAP_CHAIN_DESC1): int32 {.stdcall.}
  callVtblErr(self, 18, F, "IDXGISwapChain1.GetDesc1", pDesc)

proc getFullscreenDesc*(self: IDXGISwapChain1, pDesc: ptr DXGI_SWAP_CHAIN_FULLSCREEN_DESC) =
  type F = proc(this: IDXGISwapChain1, pDesc: ptr DXGI_SWAP_CHAIN_FULLSCREEN_DESC): int32 {.stdcall.}
  callVtblErr(self, 19, F, "IDXGISwapChain1.GetFullscreenDesc", pDesc)

proc getHwnd*(self: IDXGISwapChain1, pHwnd: ptr pointer) =
  type F = proc(this: IDXGISwapChain1, pHwnd: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 20, F, "IDXGISwapChain1.GetHwnd", pHwnd)

proc getCoreWindow*(self: IDXGISwapChain1, refiid: pointer, ppUnk: pointer) =
  type F = proc(this: IDXGISwapChain1, refiid: pointer, ppUnk: pointer): int32 {.stdcall.}
  callVtblErr(self, 21, F, "IDXGISwapChain1.GetCoreWindow", refiid, ppUnk)

proc present1*(self: IDXGISwapChain1, SyncInterval: uint32, PresentFlags: uint32, pPresentParameters: ptr DXGI_PRESENT_PARAMETERS) =
  type F = proc(this: IDXGISwapChain1, SyncInterval: uint32, PresentFlags: uint32, pPresentParameters: ptr DXGI_PRESENT_PARAMETERS): int32 {.stdcall.}
  callVtblErr(self, 22, F, "IDXGISwapChain1.Present1", SyncInterval, PresentFlags, pPresentParameters)

proc isTemporaryMonoSupported*(self: IDXGISwapChain1): int32 =
  type F = proc(this: IDXGISwapChain1): int32 {.stdcall.}
  callVtbl0(self, 23, F)

proc getRestrictToOutput*(self: IDXGISwapChain1, ppRestrictToOutput: pointer) =
  type F = proc(this: IDXGISwapChain1, ppRestrictToOutput: pointer): int32 {.stdcall.}
  callVtblErr(self, 24, F, "IDXGISwapChain1.GetRestrictToOutput", ppRestrictToOutput)

proc setBackgroundColor*(self: IDXGISwapChain1, pColor: pointer) =
  type F = proc(this: IDXGISwapChain1, pColor: pointer): int32 {.stdcall.}
  callVtblErr(self, 25, F, "IDXGISwapChain1.SetBackgroundColor", pColor)

proc getBackgroundColor*(self: IDXGISwapChain1, pColor: pointer) =
  type F = proc(this: IDXGISwapChain1, pColor: pointer): int32 {.stdcall.}
  callVtblErr(self, 26, F, "IDXGISwapChain1.GetBackgroundColor", pColor)

proc setRotation*(self: IDXGISwapChain1, Rotation: uint32) =
  type F = proc(this: IDXGISwapChain1, Rotation: uint32): int32 {.stdcall.}
  callVtblErr(self, 27, F, "IDXGISwapChain1.SetRotation", Rotation)

proc getRotation*(self: IDXGISwapChain1, pRotation: pointer) =
  type F = proc(this: IDXGISwapChain1, pRotation: pointer): int32 {.stdcall.}
  callVtblErr(self, 28, F, "IDXGISwapChain1.GetRotation", pRotation)

# --- IDXGIFactory2 methods ---

proc isWindowedStereoEnabled*(self: IDXGIFactory2): int32 =
  type F = proc(this: IDXGIFactory2): int32 {.stdcall.}
  callVtbl0(self, 14, F)

proc createSwapChainForHwnd*(self: IDXGIFactory2, pDevice: pointer, hWnd: pointer, pDesc: ptr DXGI_SWAP_CHAIN_DESC1, pFullscreenDesc: ptr DXGI_SWAP_CHAIN_FULLSCREEN_DESC, pRestrictToOutput: IDXGIOutput, ppSwapChain: pointer) =
  type F = proc(this: IDXGIFactory2, pDevice: pointer, hWnd: pointer, pDesc: ptr DXGI_SWAP_CHAIN_DESC1, pFullscreenDesc: ptr DXGI_SWAP_CHAIN_FULLSCREEN_DESC, pRestrictToOutput: IDXGIOutput, ppSwapChain: pointer): int32 {.stdcall.}
  callVtblErr(self, 15, F, "IDXGIFactory2.CreateSwapChainForHwnd", pDevice, hWnd, pDesc, pFullscreenDesc, pRestrictToOutput, ppSwapChain)

proc createSwapChainForCoreWindow*(self: IDXGIFactory2, pDevice: pointer, pWindow: pointer, pDesc: ptr DXGI_SWAP_CHAIN_DESC1, pRestrictToOutput: IDXGIOutput, ppSwapChain: pointer) =
  type F = proc(this: IDXGIFactory2, pDevice: pointer, pWindow: pointer, pDesc: ptr DXGI_SWAP_CHAIN_DESC1, pRestrictToOutput: IDXGIOutput, ppSwapChain: pointer): int32 {.stdcall.}
  callVtblErr(self, 16, F, "IDXGIFactory2.CreateSwapChainForCoreWindow", pDevice, pWindow, pDesc, pRestrictToOutput, ppSwapChain)

proc getSharedResourceAdapterLuid*(self: IDXGIFactory2, hResource: pointer, pLuid: ptr LUID) =
  type F = proc(this: IDXGIFactory2, hResource: pointer, pLuid: ptr LUID): int32 {.stdcall.}
  callVtblErr(self, 17, F, "IDXGIFactory2.GetSharedResourceAdapterLuid", hResource, pLuid)

proc registerStereoStatusWindow*(self: IDXGIFactory2, WindowHandle: pointer, wMsg: uint32, pdwCookie: ptr uint32) =
  type F = proc(this: IDXGIFactory2, WindowHandle: pointer, wMsg: uint32, pdwCookie: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 18, F, "IDXGIFactory2.RegisterStereoStatusWindow", WindowHandle, wMsg, pdwCookie)

proc registerStereoStatusEvent*(self: IDXGIFactory2, hEvent: pointer, pdwCookie: ptr uint32) =
  type F = proc(this: IDXGIFactory2, hEvent: pointer, pdwCookie: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 19, F, "IDXGIFactory2.RegisterStereoStatusEvent", hEvent, pdwCookie)

proc unregisterStereoStatus*(self: IDXGIFactory2, dwCookie: uint32) =
  type F = proc(this: IDXGIFactory2, dwCookie: uint32): void {.stdcall.}
  callVtbl(self, 20, F, dwCookie)

proc registerOcclusionStatusWindow*(self: IDXGIFactory2, WindowHandle: pointer, wMsg: uint32, pdwCookie: ptr uint32) =
  type F = proc(this: IDXGIFactory2, WindowHandle: pointer, wMsg: uint32, pdwCookie: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 21, F, "IDXGIFactory2.RegisterOcclusionStatusWindow", WindowHandle, wMsg, pdwCookie)

proc registerOcclusionStatusEvent*(self: IDXGIFactory2, hEvent: pointer, pdwCookie: ptr uint32) =
  type F = proc(this: IDXGIFactory2, hEvent: pointer, pdwCookie: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 22, F, "IDXGIFactory2.RegisterOcclusionStatusEvent", hEvent, pdwCookie)

proc unregisterOcclusionStatus*(self: IDXGIFactory2, dwCookie: uint32) =
  type F = proc(this: IDXGIFactory2, dwCookie: uint32): void {.stdcall.}
  callVtbl(self, 23, F, dwCookie)

proc createSwapChainForComposition*(self: IDXGIFactory2, pDevice: pointer, pDesc: ptr DXGI_SWAP_CHAIN_DESC1, pRestrictToOutput: IDXGIOutput, ppSwapChain: pointer) =
  type F = proc(this: IDXGIFactory2, pDevice: pointer, pDesc: ptr DXGI_SWAP_CHAIN_DESC1, pRestrictToOutput: IDXGIOutput, ppSwapChain: pointer): int32 {.stdcall.}
  callVtblErr(self, 24, F, "IDXGIFactory2.CreateSwapChainForComposition", pDevice, pDesc, pRestrictToOutput, ppSwapChain)

# --- IDXGIAdapter2 methods ---

proc getDesc2*(self: IDXGIAdapter2, pDesc: ptr DXGI_ADAPTER_DESC2) =
  type F = proc(this: IDXGIAdapter2, pDesc: ptr DXGI_ADAPTER_DESC2): int32 {.stdcall.}
  callVtblErr(self, 11, F, "IDXGIAdapter2.GetDesc2", pDesc)

# --- IDXGIOutput1 methods ---

proc getDisplayModeList1*(self: IDXGIOutput1, enum_format: uint32, flags: uint32, num_modes: ptr uint32, desc: ptr DXGI_MODE_DESC1) =
  type F = proc(this: IDXGIOutput1, enum_format: uint32, flags: uint32, num_modes: ptr uint32, desc: ptr DXGI_MODE_DESC1): int32 {.stdcall.}
  callVtblErr(self, 19, F, "IDXGIOutput1.GetDisplayModeList1", enum_format, flags, num_modes, desc)

proc findClosestMatchingMode1*(self: IDXGIOutput1, mode_to_match: ptr DXGI_MODE_DESC1, closest_match: ptr DXGI_MODE_DESC1, concerned_device: pointer) =
  type F = proc(this: IDXGIOutput1, mode_to_match: ptr DXGI_MODE_DESC1, closest_match: ptr DXGI_MODE_DESC1, concerned_device: pointer): int32 {.stdcall.}
  callVtblErr(self, 20, F, "IDXGIOutput1.FindClosestMatchingMode1", mode_to_match, closest_match, concerned_device)

proc getDisplaySurfaceData1*(self: IDXGIOutput1, destination: IDXGIResource) =
  type F = proc(this: IDXGIOutput1, destination: IDXGIResource): int32 {.stdcall.}
  callVtblErr(self, 21, F, "IDXGIOutput1.GetDisplaySurfaceData1", destination)

proc duplicateOutput*(self: IDXGIOutput1, device: pointer, output_duplication: pointer) =
  type F = proc(this: IDXGIOutput1, device: pointer, output_duplication: pointer): int32 {.stdcall.}
  callVtblErr(self, 22, F, "IDXGIOutput1.DuplicateOutput", device, output_duplication)

