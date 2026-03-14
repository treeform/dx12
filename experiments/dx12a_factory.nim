import dynlib

type
  HRESULT* = int32
  UINT* = uint32

  GUID* {.pure, packed.} = object
    Data1*: uint32
    Data2*: uint16
    Data3*: uint16
    Data4*: array[8, uint8]

  IDXGIFactory4* = object   # placeholder interface

  CreateDXGIFactory2_t* = proc(
    Flags: UINT,
    riid: ptr GUID,
    ppFactory: ptr pointer
  ): HRESULT {.stdcall.}

const
  S_OK* = 0

# Creates GUIDs from the canonical IID literal format:
# 0xXXXXXXXX, 0xXXXX, 0xXXXX, 0xXX, ... (8 bytes total)
proc newGuid*(
  data1: uint32,
  data2: uint16,
  data3: uint16,
  b0, b1, b2, b3, b4, b5, b6, b7: uint8
): GUID =
  GUID(
    Data1: data1,
    Data2: data2,
    Data3: data3,
    Data4: [b0, b1, b2, b3, b4, b5, b6, b7]
  )

# IMPORTANT: Data1 must be uint32, not int32!
var IID_IDXGIFactory4* {.global.} = newGuid(0x1bc6ea02,0xef36,0x464f,0xbf,0x0c,0x21,0xca,0x39,0xe5,0x16,0x8a)

proc main() =
  let dxgi = loadLib("dxgi.dll")
  if dxgi == nil:
    echo "Could not load dxgi.dll"
    return

  let CreateDXGIFactory2_Ptr =
    cast[CreateDXGIFactory2_t](dxgi.symAddr("CreateDXGIFactory2"))
  if CreateDXGIFactory2_Ptr == nil:
    echo "CreateDXGIFactory2 not found"
    return

  var factory: ptr IDXGIFactory4

  echo "Calling CreateDXGIFactory2..."
  let hr = CreateDXGIFactory2_Ptr(
    0,
    addr IID_IDXGIFactory4,
    cast[ptr pointer](addr factory)
  )

  echo "Result: ", hr
  if hr == S_OK:
    echo "Success!"
  else:
    echo "Failed."

when isMainModule:
  main()
