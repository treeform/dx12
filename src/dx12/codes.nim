import std/[strformat, tables]

let codes = {
  0x00000000.uint32: "S_OK: Operation successful",
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

