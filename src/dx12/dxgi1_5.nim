# Auto-generated from dxgi1_5.idl — do not edit manually.
# Regenerate with: nim r tools/generate_api.nim

import dxgi1_4, vtable
export dxgi1_4

# DXGI_OUTDUPL_FLAG
const
  DXGI_OUTDUPL_COMPOSITED_UI_CAPTURE_ONLY* = 0x1'u32

# DXGI_HDR_METADATA_TYPE
const
  DXGI_HDR_METADATA_TYPE_NONE* = 0x0'u32
  DXGI_HDR_METADATA_TYPE_HDR10* = 0x1'u32
  DXGI_HDR_METADATA_TYPE_HDR10PLUS* = 0x2'u32

# DXGI_OFFER_RESOURCE_FLAGS
const
  DXGI_OFFER_RESOURCE_FLAG_ALLOW_DECOMMIT* = 0x1'u32

# DXGI_RECLAIM_RESOURCE_RESULTS
const
  DXGI_RECLAIM_RESOURCE_RESULT_OK* = 0x0'u32
  DXGI_RECLAIM_RESOURCE_RESULT_DISCARDED* = 0x1'u32
  DXGI_RECLAIM_RESOURCE_RESULT_NOT_COMMITTED* = 0x2'u32

# DXGI_FEATURE
const
  DXGI_FEATURE_PRESENT_ALLOW_TEARING* = 0x0'u32

type
  IDXGIOutput5* = ptr object
  IDXGISwapChain4* = ptr object
  IDXGIDevice4* = ptr object
  IDXGIFactory5* = ptr object

type
  DXGI_HDR_METADATA_HDR10* = object
    RedPrimary*: array[2, uint16]
    GreenPrimary*: array[2, uint16]
    BluePrimary*: array[2, uint16]
    WhitePoint*: array[2, uint16]
    MaxMasteringLuminance*: uint32
    MinMasteringLuminance*: uint32
    MaxContentLightLevel*: uint16
    MaxFrameAverageLightLevel*: uint16

  DXGI_HDR_METADATA_HDR10PLUS* = object
    Data*: array[72, uint8]

# --- IDXGIOutput5 methods ---

proc duplicateOutput1*(self: IDXGIOutput5, device: pointer, flags: uint32, format_count: uint32, formats: pointer, duplication: pointer) =
  type F = proc(this: IDXGIOutput5, device: pointer, flags: uint32, format_count: uint32, formats: pointer, duplication: pointer): int32 {.stdcall.}
  callVtblErr(self, 26, F, "IDXGIOutput5.DuplicateOutput1", device, flags, format_count, formats, duplication)

# --- IDXGISwapChain4 methods ---

proc setHDRMetaData*(self: IDXGISwapChain4, typ: uint32, size: uint32, metadata: pointer) =
  type F = proc(this: IDXGISwapChain4, typ: uint32, size: uint32, metadata: pointer): int32 {.stdcall.}
  callVtblErr(self, 40, F, "IDXGISwapChain4.SetHDRMetaData", typ, size, metadata)

# --- IDXGIDevice4 methods ---

proc offerResources1*(self: IDXGIDevice4, resource_count: uint32, resources: ptr IDXGIResource, priority: uint32, flags: uint32) =
  type F = proc(this: IDXGIDevice4, resource_count: uint32, resources: ptr IDXGIResource, priority: uint32, flags: uint32): int32 {.stdcall.}
  callVtblErr(self, 18, F, "IDXGIDevice4.OfferResources1", resource_count, resources, priority, flags)

proc reclaimResources1*(self: IDXGIDevice4, resource_count: uint32, resources: ptr IDXGIResource, results: pointer) =
  type F = proc(this: IDXGIDevice4, resource_count: uint32, resources: ptr IDXGIResource, results: pointer): int32 {.stdcall.}
  callVtblErr(self, 19, F, "IDXGIDevice4.ReclaimResources1", resource_count, resources, results)

# --- IDXGIFactory5 methods ---

proc checkFeatureSupport*(self: IDXGIFactory5, feature: uint32, support_data: pointer, support_data_size: uint32) =
  type F = proc(this: IDXGIFactory5, feature: uint32, support_data: pointer, support_data_size: uint32): int32 {.stdcall.}
  callVtblErr(self, 28, F, "IDXGIFactory5.CheckFeatureSupport", feature, support_data, support_data_size)

