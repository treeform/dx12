import
  std/strutils,
  dx12, dx12/[codes, context]

echo "Testing constants"
doAssert FRAME_COUNT == 2
doAssert DXGI_FORMAT_R8G8B8A8_UNORM == 28'u32
doAssert D3D12_CULL_MODE_NONE == 1'u32
doAssert D3D12_FILTER_ANISOTROPIC == 0x55'u32

echo "Testing GUID construction"
let guid = newGuid(
  0x12345678'u32,
  0x9abc'u16,
  0xdef0'u16,
  0x11'u8,
  0x22'u8,
  0x33'u8,
  0x44'u8,
  0x55'u8,
  0x66'u8,
  0x77'u8,
  0x88'u8
)
doAssert guid.Data1 == 0x12345678'u32
doAssert guid.Data2 == 0x9abc'u16
doAssert guid.Data3 == 0xdef0'u16
doAssert guid.Data4 == [0x11'u8, 0x22'u8, 0x33'u8, 0x44'u8, 0x55'u8, 0x66'u8, 0x77'u8, 0x88'u8]

echo "Testing handle offsets"
let
  baseHandle = D3D12_CPU_DESCRIPTOR_HANDLE(ptrValue: 128'u64)
  offsetted = offsetHandle(baseHandle, 32'u32, 3)
doAssert offsetted.ptrValue == 224'u64

echo "Testing HRESULT helpers"
let
  successMessage = messageHr(0'i32, "load")
  invalidArgHr = cast[int32](0x80070057'u32)
  invalidArgMessage = messageHr(invalidArgHr, "validate")
doAssert successMessage == "load: S_OK: Operation successful"
doAssert invalidArgMessage.contains("E_INVALIDARG")

try:
  checkHr(invalidArgHr, "validate")
  doAssert false, "checkHr should raise on failing HRESULTs"
except Exception as e:
  doAssert e.msg.contains("E_INVALIDARG")

echo "All dx12 tests passed"
