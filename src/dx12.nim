## DirectX 12 wrapper for Nim on Windows.

when not defined(windows) and not defined(nimdoc):
  {.error: "dx12 is only supported on Windows.".}

import dx12/[dxgicommon, dxgiformat, dxgitype, dxgi, dxgi1_2, dxgi1_3,
    dxgi1_4, dxgi1_5, dxgi1_6, d3dcommon, d3d12_api, d3d12shader]
export dxgicommon, dxgiformat, dxgitype, dxgi, dxgi1_2, dxgi1_3, dxgi1_4,
    dxgi1_5, dxgi1_6, d3dcommon, d3d12_api, d3d12shader

import dx12/[vtable, win32defs, codes]
export vtable, win32defs, codes

when defined(windows):
  import dx12/[extras, context]
  export extras, context
