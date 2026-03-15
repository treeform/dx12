# Auto-generated from dxgitype.idl — do not edit manually.
# Regenerate with: nim r tools/generate_api.nim

import dxgicommon, dxgiformat
export dxgicommon, dxgiformat

# DXGI_MODE_ROTATION
const
  DXGI_MODE_ROTATION_UNSPECIFIED* = 0x0'u32
  DXGI_MODE_ROTATION_IDENTITY* = 0x1'u32
  DXGI_MODE_ROTATION_ROTATE90* = 0x2'u32
  DXGI_MODE_ROTATION_ROTATE180* = 0x3'u32
  DXGI_MODE_ROTATION_ROTATE270* = 0x4'u32

# DXGI_MODE_SCANLINE_ORDER
const
  DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED* = 0x0'u32
  DXGI_MODE_SCANLINE_ORDER_PROGRESSIVE* = 0x1'u32
  DXGI_MODE_SCANLINE_ORDER_UPPER_FIELD_FIRST* = 0x2'u32
  DXGI_MODE_SCANLINE_ORDER_LOWER_FIELD_FIRST* = 0x3'u32

# DXGI_MODE_SCALING
const
  DXGI_MODE_SCALING_UNSPECIFIED* = 0x0'u32
  DXGI_MODE_SCALING_CENTERED* = 0x1'u32
  DXGI_MODE_SCALING_STRETCHED* = 0x2'u32

type
  D3DCOLORVALUE* = object
    r*: float32
    g*: float32
    b*: float32
    a*: float32

  DXGI_MODE_DESC* = object
    Width*: uint32
    Height*: uint32
    RefreshRate*: DXGI_RATIONAL
    Format*: uint32
    ScanlineOrdering*: uint32
    Scaling*: uint32

  DXGI_GAMMA_CONTROL_CAPABILITIES* = object
    ScaleAndOffsetSupported*: int32
    MaxConvertedValue*: float32
    MinConvertedValue*: float32
    NumGammaControlPoints*: uint32
    ControlPointPositions*: array[1025, float32]

  DXGI_RGB* = object
    Red*: float32
    Green*: float32
    Blue*: float32

  DXGI_GAMMA_CONTROL* = object
    Scale*: DXGI_RGB
    Offset*: DXGI_RGB
    GammaCurve*: array[1025, DXGI_RGB]

type DXGI_RGBA* = D3DCOLORVALUE

