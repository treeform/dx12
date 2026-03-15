import std/[strformat, tables]

let codes = {
  # Generic COM success codes
  0x00000000.uint32: "S_OK: Operation successful",
  0x00000001.uint32: "S_FALSE: Success, but nonstandard completion",

  # Generic COM error codes
  0x80004001.uint32: "E_NOTIMPL: Not implemented",
  0x80004002.uint32: "E_NOINTERFACE: No such interface supported",
  0x80004003.uint32: "E_POINTER: Pointer that is not valid",
  0x80004004.uint32: "E_ABORT: Operation aborted",
  0x80004005.uint32: "E_FAIL: Unspecified failure",
  0x8000FFFF.uint32: "E_UNEXPECTED: Unexpected failure",
  0x80070005.uint32: "E_ACCESSDENIED: General access denied error",
  0x80070006.uint32: "E_HANDLE: Handle that is not valid",
  0x8007000E.uint32: "E_OUTOFMEMORY: Failed to allocate necessary memory",
  0x80070057.uint32: "E_INVALIDARG: One or more arguments are not valid",

  # DXGI status codes (success, from winerror.h)
  0x087A0001.uint32: "DXGI_STATUS_OCCLUDED: Window content not visible",
  0x087A0002.uint32: "DXGI_STATUS_CLIPPED: Content clipped to destination area",
  0x087A0004.uint32: "DXGI_STATUS_NO_REDIRECTION: No redirection by DWM",
  0x087A0005.uint32: "DXGI_STATUS_NO_DESKTOP_ACCESS: No desktop access for current process",
  0x087A0006.uint32: "DXGI_STATUS_GRAPHICS_VIDPN_SOURCE_IN_USE: VidPN source already in use",
  0x087A0007.uint32: "DXGI_STATUS_MODE_CHANGED: Display mode has changed",
  0x087A0008.uint32: "DXGI_STATUS_MODE_CHANGE_IN_PROGRESS: Display mode change in progress",
  0x087A0009.uint32: "DXGI_STATUS_UNOCCLUDED: Window is no longer occluded",
  0x087A000A.uint32: "DXGI_STATUS_DDA_WAS_STILL_DRAWING: Desktop Duplication API was still drawing",
  0x087A002F.uint32: "DXGI_STATUS_PRESENT_REQUIRED: Present is required to regain rendering",

  # DXGI error codes (from winerror.h)
  0x887A0001.uint32: "DXGI_ERROR_INVALID_CALL: Invalid parameter data",
  0x887A0002.uint32: "DXGI_ERROR_NOT_FOUND: GUID not recognized or enumeration out of range",
  0x887A0003.uint32: "DXGI_ERROR_MORE_DATA: Buffer too small for requested data",
  0x887A0004.uint32: "DXGI_ERROR_UNSUPPORTED: Requested functionality not supported",
  0x887A0005.uint32: "DXGI_ERROR_DEVICE_REMOVED: GPU device removed or driver upgraded",
  0x887A0006.uint32: "DXGI_ERROR_DEVICE_HUNG: Device failed due to badly formed commands",
  0x887A0007.uint32: "DXGI_ERROR_DEVICE_RESET: Device failed; recreate the device",
  0x887A000A.uint32: "DXGI_ERROR_WAS_STILL_DRAWING: GPU was busy; operation not executed",
  0x887A000B.uint32: "DXGI_ERROR_FRAME_STATISTICS_DISJOINT: Presentation statistics gathering interrupted",
  0x887A000C.uint32: "DXGI_ERROR_GRAPHICS_VIDPN_SOURCE_IN_USE: Output already acquired by another application",
  0x887A0020.uint32: "DXGI_ERROR_DRIVER_INTERNAL_ERROR: Driver encountered a problem",
  0x887A0021.uint32: "DXGI_ERROR_NONEXCLUSIVE: Global counter resource in use",
  0x887A0022.uint32: "DXGI_ERROR_NOT_CURRENTLY_AVAILABLE: Resource not currently available",
  0x887A0023.uint32: "DXGI_ERROR_REMOTE_CLIENT_DISCONNECTED: Remote client disconnected",
  0x887A0024.uint32: "DXGI_ERROR_REMOTE_OUTOFMEMORY: Remote device out of memory",
  0x887A0025.uint32: "DXGI_ERROR_MODE_CHANGE_IN_PROGRESS: Display mode change in progress",
  0x887A0026.uint32: "DXGI_ERROR_ACCESS_LOST: Desktop duplication interface invalid",
  0x887A0027.uint32: "DXGI_ERROR_WAIT_TIMEOUT: Timeout waiting for resource",
  0x887A0028.uint32: "DXGI_ERROR_SESSION_DISCONNECTED: Remote Desktop session disconnected",
  0x887A0029.uint32: "DXGI_ERROR_RESTRICT_TO_OUTPUT_STALE: Output restriction is stale",
  0x887A002A.uint32: "DXGI_ERROR_CANNOT_PROTECT_CONTENT: Content protection unavailable",
  0x887A002B.uint32: "DXGI_ERROR_ACCESS_DENIED: Insufficient access privileges",
  0x887A002C.uint32: "DXGI_ERROR_NAME_ALREADY_EXISTS: Shared resource name already in use",
  0x887A002D.uint32: "DXGI_ERROR_SDK_COMPONENT_MISSING: SDK component missing or mismatched",
  0x887A002E.uint32: "DXGI_ERROR_NOT_CURRENT: Interface is not current",
  0x887A0030.uint32: "DXGI_ERROR_HW_PROTECTION_OUTOFMEMORY: Hardware protection out of memory",
  0x887A0031.uint32: "DXGI_ERROR_DYNAMIC_CODE_POLICY_VIOLATION: Dynamic code policy violation",
  0x887A0032.uint32: "DXGI_ERROR_NON_COMPOSITED_UI: Non-composited UI detected",
  0x887A0033.uint32: "DXGI_ERROR_CACHE_CORRUPT: PSO cache is corrupt",
  0x887A0034.uint32: "DXGI_ERROR_CACHE_FULL: PSO cache is full",
  0x887A0035.uint32: "DXGI_ERROR_CACHE_HASH_COLLISION: PSO cache hash collision",
  0x887A0036.uint32: "DXGI_ERROR_ALREADY_EXISTS: Desired element already exists",
  0x887A0064.uint32: "DXGI_ERROR_MPO_UNPINNED: Multiplane overlay unpinned",

  # D3D12 error codes (from winerror.h)
  0x887E0001.uint32: "D3D12_ERROR_ADAPTER_NOT_FOUND: Cached PSO created on a different adapter",
  0x887E0002.uint32: "D3D12_ERROR_DRIVER_VERSION_MISMATCH: Cached PSO created on a different driver version",
  0x887E0003.uint32: "D3D12_ERROR_INVALID_REDIST: Invalid DirectX redistributable",
}.toTable

proc messageHr*(hr: int32, msg: string): string =
  if hr < 0:
    let hrCode = hr.uint32
    if hrCode in codes:
      msg & ": " & codes[hrCode]
    else:
      msg & ": " & fmt"Unknown error: {hrCode:0x}"
  else:
    let hrCode = hr.uint32
    if hrCode in codes:
      msg & ": " & codes[hrCode]
    else:
      msg & ": " & fmt"Unknown success: {hrCode:0x}"

proc checkHr*(hr: int32, msg: string) =
  if hr < 0:
    raise newException(Exception, messageHr(hr, msg))
