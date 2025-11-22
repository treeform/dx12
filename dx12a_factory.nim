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

# IMPORTANT: Data1 must be uint32, not int32!
var IID_IDXGIFactory4* {.global.} = GUID(
  Data1: 0x1bc6ea02'u32,
  Data2: 0xef36'u16,
  Data3: 0x464f'u16,
  Data4: [0xbf'u8, 0x0c'u8, 0x21'u8, 0xca'u8, 0x39'u8, 0xe5'u8, 0x16'u8, 0x8a'u8]
)

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