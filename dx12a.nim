import dynlib

type
  HRESULT = int32
  UINT = uint32
  
  GUID {.pure.} = object
    Data1: int32
    Data2: uint16
    Data3: uint16
    Data4: array[8, uint8]

  CreateDXGIFactory2_t = proc(Flags: UINT, riid: ptr GUID, ppFactory: ptr pointer): HRESULT {.stdcall.}
  CoInitializeEx_t = proc(pvReserved: pointer, dwCoInit: int32): HRESULT {.stdcall.}

const
  S_OK = 0
  COINIT_MULTITHREADED = 0x0
  COINIT_APARTMENTTHREADED = 0x2

var
  CreateDXGIFactory2_Ptr: CreateDXGIFactory2_t
  CoInitializeEx_Ptr: CoInitializeEx_t

# IDXGIFactory: 7b7166ec-21c7-44ae-b21a-c9ae321ae369
var IID_IDXGIFactory = GUID(Data1: 0x7b7166ec'i32, Data2: 0x21c7'u16, Data3: 0x44ae'u16, Data4: [0xb2'u8, 0x1a, 0xc9, 0xae, 0x32, 0x1a, 0xe3, 0x69])

# IDXGIFactory2: 50c83a1c-e072-4c48-87b1-362799108545
var IID_IDXGIFactory2 = GUID(Data1: 0x50c83a1c'i32, Data2: 0xe072'u16, Data3: 0x4c48'u16, Data4: [0x87'u8, 0xb1, 0x36, 0x27, 0x99, 0x10, 0x85, 0x45])

# IDXGIFactory4: 1bc6ea02-ef36-493e-982f-0d543e780298
var IID_IDXGIFactory4 = GUID(Data1: 0x1bc6ea02'i32, Data2: 0xef36'u16, Data3: 0x493e'u16, Data4: [0x98'u8, 0x2f, 0x0d, 0x54, 0x3e, 0x78, 0x02, 0x98])

proc main() =
  echo "Initializing..."
  
  let ole32 = loadLib("ole32.dll")
  if ole32 != nil:
    CoInitializeEx_Ptr = cast[CoInitializeEx_t](ole32.symAddr("CoInitializeEx"))
    if CoInitializeEx_Ptr != nil:
      # Try Apartment Threaded first, just to see
      let hr = CoInitializeEx_Ptr(nil, COINIT_APARTMENTTHREADED)
      echo "CoInitializeEx(APARTMENTTHREADED): ", hr
  
  let dxgi = loadLib("dxgi.dll")
  if dxgi == nil:
    echo "Could not load dxgi.dll"
    return
    
  CreateDXGIFactory2_Ptr = cast[CreateDXGIFactory2_t](dxgi.symAddr("CreateDXGIFactory2"))
  if CreateDXGIFactory2_Ptr == nil:
    echo "CreateDXGIFactory2 not found"
    return

  var factory: pointer
  
  echo "Trying CreateDXGIFactory2 with IID_IDXGIFactory4..."
  var hr = CreateDXGIFactory2_Ptr(0, addr IID_IDXGIFactory4, addr factory)
  echo "Result: ", hr
  
  if hr == S_OK:
    echo "Success! Created IDXGIFactory4"
  else:
    echo "Trying CreateDXGIFactory2 with IID_IDXGIFactory2..."
    hr = CreateDXGIFactory2_Ptr(0, addr IID_IDXGIFactory2, addr factory)
    echo "Result: ", hr
    if hr == S_OK:
      echo "Success! Created IDXGIFactory2"
    else:
      echo "Trying CreateDXGIFactory2 with IID_IDXGIFactory..."
      hr = CreateDXGIFactory2_Ptr(0, addr IID_IDXGIFactory, addr factory)
      echo "Result: ", hr
      if hr == S_OK:
        echo "Success! Created IDXGIFactory"
      else:
        echo "Failed to create factory."

when isMainModule:
  main()
