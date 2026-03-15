# Auto-generated from d3d12shader.idl — do not edit manually.
# Regenerate with: nim r tools/generate_api.nim

import d3dcommon, vtable
export d3dcommon

# D3D12_SHADER_VERSION_TYPE
const
  D3D12_SHVER_PIXEL_SHADER* = 0x0'u32
  D3D12_SHVER_VERTEX_SHADER* = 0x1'u32
  D3D12_SHVER_GEOMETRY_SHADER* = 0x2'u32
  D3D12_SHVER_HULL_SHADER* = 0x3'u32
  D3D12_SHVER_DOMAIN_SHADER* = 0x4'u32
  D3D12_SHVER_COMPUTE_SHADER* = 0x5'u32
  D3D12_SHVER_RESERVED0* = 0xfff0'u32

type
  ID3D12ShaderReflectionConstantBuffer* = ptr object
  ID3D12ShaderReflectionType* = ptr object
  ID3D12ShaderReflectionVariable* = ptr object
  ID3D12ShaderReflection* = ptr object
  ID3D12FunctionParameterReflection* = ptr object
  ID3D12FunctionReflection* = ptr object
  ID3D12LibraryReflection* = ptr object

type
  D3D12_SHADER_DESC* = object
    Version*: uint32
    Creator*: cstring
    Flags*: uint32
    ConstantBuffers*: uint32
    BoundResources*: uint32
    InputParameters*: uint32
    OutputParameters*: uint32
    InstructionCount*: uint32
    TempRegisterCount*: uint32
    TempArrayCount*: uint32
    DefCount*: uint32
    DclCount*: uint32
    TextureNormalInstructions*: uint32
    TextureLoadInstructions*: uint32
    TextureCompInstructions*: uint32
    TextureBiasInstructions*: uint32
    TextureGradientInstructions*: uint32
    FloatInstructionCount*: uint32
    IntInstructionCount*: uint32
    UintInstructionCount*: uint32
    StaticFlowControlCount*: uint32
    DynamicFlowControlCount*: uint32
    MacroInstructionCount*: uint32
    ArrayInstructionCount*: uint32
    CutInstructionCount*: uint32
    EmitInstructionCount*: uint32
    GSOutputTopology*: uint32
    GSMaxOutputVertexCount*: uint32
    InputPrimitive*: uint32
    PatchConstantParameters*: uint32
    cGSInstanceCount*: uint32
    cControlPoints*: uint32
    HSOutputPrimitive*: uint32
    HSPartitioning*: uint32
    TessellatorDomain*: uint32
    cBarrierInstructions*: uint32
    cInterlockedInstructions*: uint32
    cTextureStoreInstructions*: uint32

  D3D12_SHADER_VARIABLE_DESC* = object
    Name*: cstring
    StartOffset*: uint32
    Size*: uint32
    uFlags*: uint32
    DefaultValue*: pointer
    StartTexture*: uint32
    TextureSize*: uint32
    StartSampler*: uint32
    SamplerSize*: uint32

  D3D12_SHADER_TYPE_DESC* = object
    Class*: uint32
    typ*: uint32
    Rows*: uint32
    Columns*: uint32
    Elements*: uint32
    Members*: uint32
    Offset*: uint32
    Name*: cstring

  D3D12_SHADER_BUFFER_DESC* = object
    Name*: cstring
    typ*: uint32
    Variables*: uint32
    Size*: uint32
    uFlags*: uint32

  D3D12_SHADER_INPUT_BIND_DESC* = object
    Name*: cstring
    typ*: uint32
    BindPoint*: uint32
    BindCount*: uint32
    uFlags*: uint32
    ReturnType*: uint32
    Dimension*: uint32
    NumSamples*: uint32
    Space*: uint32
    uID*: uint32

  D3D12_SIGNATURE_PARAMETER_DESC* = object
    SemanticName*: cstring
    SemanticIndex*: uint32
    Register*: uint32
    SystemValueType*: uint32
    ComponentType*: uint32
    Mask*: uint8
    ReadWriteMask*: uint8
    Stream*: uint32
    MinPrecision*: uint32

  D3D12_PARAMETER_DESC* = object
    Name*: cstring
    SemanticName*: cstring
    typ*: uint32
    Class*: uint32
    Rows*: uint32
    Columns*: uint32
    InterpolationMode*: uint32
    Flags*: uint32
    FirstInRegister*: uint32
    FirstInComponent*: uint32
    FirstOutRegister*: uint32
    FirstOutComponent*: uint32

  D3D12_FUNCTION_DESC* = object
    Version*: uint32
    Creator*: cstring
    Flags*: uint32
    ConstantBuffers*: uint32
    BoundResources*: uint32
    InstructionCount*: uint32
    TempRegisterCount*: uint32
    TempArrayCount*: uint32
    DefCount*: uint32
    DclCount*: uint32
    TextureNormalInstructions*: uint32
    TextureLoadInstructions*: uint32
    TextureCompInstructions*: uint32
    TextureBiasInstructions*: uint32
    TextureGradientInstructions*: uint32
    FloatInstructionCount*: uint32
    IntInstructionCount*: uint32
    UintInstructionCount*: uint32
    StaticFlowControlCount*: uint32
    DynamicFlowControlCount*: uint32
    MacroInstructionCount*: uint32
    ArrayInstructionCount*: uint32
    MovInstructionCount*: uint32
    MovcInstructionCount*: uint32
    ConversionInstructionCount*: uint32
    BitwiseInstructionCount*: uint32
    MinFeatureLevel*: uint32
    RequiredFeatureFlags*: uint64
    Name*: cstring
    FunctionParameterCount*: int32
    HasReturn*: int32
    Has10Level9VertexShader*: int32
    Has10Level9PixelShader*: int32

  D3D12_LIBRARY_DESC* = object
    Creator*: cstring
    Flags*: uint32
    FunctionCount*: uint32

# --- ID3D12ShaderReflectionType methods ---

proc getDesc*(self: ID3D12ShaderReflectionType, desc: ptr D3D12_SHADER_TYPE_DESC) =
  type F = proc(this: ID3D12ShaderReflectionType, desc: ptr D3D12_SHADER_TYPE_DESC): int32 {.stdcall.}
  callVtblErr(self, 3, F, "ID3D12ShaderReflectionType.GetDesc", desc)

proc isEqual*(self: ID3D12ShaderReflectionType, typ: ID3D12ShaderReflectionType) =
  type F = proc(this: ID3D12ShaderReflectionType, typ: ID3D12ShaderReflectionType): int32 {.stdcall.}
  callVtblErr(self, 7, F, "ID3D12ShaderReflectionType.IsEqual", typ)

proc getNumInterfaces*(self: ID3D12ShaderReflectionType): uint32 =
  type F = proc(this: ID3D12ShaderReflectionType): uint32 {.stdcall.}
  callVtbl0(self, 10, F)

proc isOfType*(self: ID3D12ShaderReflectionType, typ: ID3D12ShaderReflectionType) =
  type F = proc(this: ID3D12ShaderReflectionType, typ: ID3D12ShaderReflectionType): int32 {.stdcall.}
  callVtblErr(self, 12, F, "ID3D12ShaderReflectionType.IsOfType", typ)

proc implementsInterface*(self: ID3D12ShaderReflectionType, base: ID3D12ShaderReflectionType) =
  type F = proc(this: ID3D12ShaderReflectionType, base: ID3D12ShaderReflectionType): int32 {.stdcall.}
  callVtblErr(self, 13, F, "ID3D12ShaderReflectionType.ImplementsInterface", base)

# --- ID3D12ShaderReflectionVariable methods ---

proc getDesc*(self: ID3D12ShaderReflectionVariable, desc: ptr D3D12_SHADER_VARIABLE_DESC) =
  type F = proc(this: ID3D12ShaderReflectionVariable, desc: ptr D3D12_SHADER_VARIABLE_DESC): int32 {.stdcall.}
  callVtblErr(self, 3, F, "ID3D12ShaderReflectionVariable.GetDesc", desc)

proc getInterfaceSlot*(self: ID3D12ShaderReflectionVariable, index: uint32): uint32 =
  type F = proc(this: ID3D12ShaderReflectionVariable, index: uint32): uint32 {.stdcall.}
  callVtbl(self, 6, F, index)

# --- ID3D12ShaderReflectionConstantBuffer methods ---

proc getDesc*(self: ID3D12ShaderReflectionConstantBuffer, desc: ptr D3D12_SHADER_BUFFER_DESC) =
  type F = proc(this: ID3D12ShaderReflectionConstantBuffer, desc: ptr D3D12_SHADER_BUFFER_DESC): int32 {.stdcall.}
  callVtblErr(self, 3, F, "ID3D12ShaderReflectionConstantBuffer.GetDesc", desc)

# --- ID3D12ShaderReflection methods ---

proc getDesc*(self: ID3D12ShaderReflection, desc: ptr D3D12_SHADER_DESC) =
  type F = proc(this: ID3D12ShaderReflection, desc: ptr D3D12_SHADER_DESC): int32 {.stdcall.}
  callVtblErr(self, 3, F, "ID3D12ShaderReflection.GetDesc", desc)

proc getResourceBindingDesc*(self: ID3D12ShaderReflection, index: uint32, desc: ptr D3D12_SHADER_INPUT_BIND_DESC) =
  type F = proc(this: ID3D12ShaderReflection, index: uint32, desc: ptr D3D12_SHADER_INPUT_BIND_DESC): int32 {.stdcall.}
  callVtblErr(self, 6, F, "ID3D12ShaderReflection.GetResourceBindingDesc", index, desc)

proc getInputParameterDesc*(self: ID3D12ShaderReflection, index: uint32, desc: ptr D3D12_SIGNATURE_PARAMETER_DESC) =
  type F = proc(this: ID3D12ShaderReflection, index: uint32, desc: ptr D3D12_SIGNATURE_PARAMETER_DESC): int32 {.stdcall.}
  callVtblErr(self, 7, F, "ID3D12ShaderReflection.GetInputParameterDesc", index, desc)

proc getOutputParameterDesc*(self: ID3D12ShaderReflection, index: uint32, desc: ptr D3D12_SIGNATURE_PARAMETER_DESC) =
  type F = proc(this: ID3D12ShaderReflection, index: uint32, desc: ptr D3D12_SIGNATURE_PARAMETER_DESC): int32 {.stdcall.}
  callVtblErr(self, 8, F, "ID3D12ShaderReflection.GetOutputParameterDesc", index, desc)

proc getPatchConstantParameterDesc*(self: ID3D12ShaderReflection, index: uint32, desc: ptr D3D12_SIGNATURE_PARAMETER_DESC) =
  type F = proc(this: ID3D12ShaderReflection, index: uint32, desc: ptr D3D12_SIGNATURE_PARAMETER_DESC): int32 {.stdcall.}
  callVtblErr(self, 9, F, "ID3D12ShaderReflection.GetPatchConstantParameterDesc", index, desc)

proc getResourceBindingDescByName*(self: ID3D12ShaderReflection, name: cstring, desc: ptr D3D12_SHADER_INPUT_BIND_DESC) =
  type F = proc(this: ID3D12ShaderReflection, name: cstring, desc: ptr D3D12_SHADER_INPUT_BIND_DESC): int32 {.stdcall.}
  callVtblErr(self, 11, F, "ID3D12ShaderReflection.GetResourceBindingDescByName", name, desc)

proc getMovInstructionCount*(self: ID3D12ShaderReflection): uint32 =
  type F = proc(this: ID3D12ShaderReflection): uint32 {.stdcall.}
  callVtbl0(self, 12, F)

proc getMovcInstructionCount*(self: ID3D12ShaderReflection): uint32 =
  type F = proc(this: ID3D12ShaderReflection): uint32 {.stdcall.}
  callVtbl0(self, 13, F)

proc getConversionInstructionCount*(self: ID3D12ShaderReflection): uint32 =
  type F = proc(this: ID3D12ShaderReflection): uint32 {.stdcall.}
  callVtbl0(self, 14, F)

proc getBitwiseInstructionCount*(self: ID3D12ShaderReflection): uint32 =
  type F = proc(this: ID3D12ShaderReflection): uint32 {.stdcall.}
  callVtbl0(self, 15, F)

proc getGSInputPrimitive*(self: ID3D12ShaderReflection): uint32 =
  type F = proc(this: ID3D12ShaderReflection): uint32 {.stdcall.}
  callVtbl0(self, 16, F)

proc isSampleFrequencyShader*(self: ID3D12ShaderReflection): int32 =
  type F = proc(this: ID3D12ShaderReflection): int32 {.stdcall.}
  callVtbl0(self, 17, F)

proc getNumInterfaceSlots*(self: ID3D12ShaderReflection): uint32 =
  type F = proc(this: ID3D12ShaderReflection): uint32 {.stdcall.}
  callVtbl0(self, 18, F)

proc getMinFeatureLevel*(self: ID3D12ShaderReflection, level: pointer) =
  type F = proc(this: ID3D12ShaderReflection, level: pointer): int32 {.stdcall.}
  callVtblErr(self, 19, F, "ID3D12ShaderReflection.GetMinFeatureLevel", level)

proc getThreadGroupSize*(self: ID3D12ShaderReflection, sizex: ptr uint32, sizey: ptr uint32, sizez: ptr uint32): uint32 =
  type F = proc(this: ID3D12ShaderReflection, sizex: ptr uint32, sizey: ptr uint32, sizez: ptr uint32): uint32 {.stdcall.}
  callVtbl(self, 20, F, sizex, sizey, sizez)

proc getRequiresFlags*(self: ID3D12ShaderReflection): uint64 =
  type F = proc(this: ID3D12ShaderReflection): uint64 {.stdcall.}
  callVtbl0(self, 21, F)

# --- ID3D12FunctionParameterReflection methods ---

proc getDesc*(self: ID3D12FunctionParameterReflection, desc: ptr D3D12_PARAMETER_DESC) =
  type F = proc(this: ID3D12FunctionParameterReflection, desc: ptr D3D12_PARAMETER_DESC): int32 {.stdcall.}
  callVtblErr(self, 3, F, "ID3D12FunctionParameterReflection.GetDesc", desc)

# --- ID3D12FunctionReflection methods ---

proc getDesc*(self: ID3D12FunctionReflection, desc: ptr D3D12_FUNCTION_DESC) =
  type F = proc(this: ID3D12FunctionReflection, desc: ptr D3D12_FUNCTION_DESC): int32 {.stdcall.}
  callVtblErr(self, 3, F, "ID3D12FunctionReflection.GetDesc", desc)

proc getResourceBindingDesc*(self: ID3D12FunctionReflection, index: uint32, desc: ptr D3D12_SHADER_INPUT_BIND_DESC) =
  type F = proc(this: ID3D12FunctionReflection, index: uint32, desc: ptr D3D12_SHADER_INPUT_BIND_DESC): int32 {.stdcall.}
  callVtblErr(self, 6, F, "ID3D12FunctionReflection.GetResourceBindingDesc", index, desc)

proc getResourceBindingDescByName*(self: ID3D12FunctionReflection, name: cstring, desc: ptr D3D12_SHADER_INPUT_BIND_DESC) =
  type F = proc(this: ID3D12FunctionReflection, name: cstring, desc: ptr D3D12_SHADER_INPUT_BIND_DESC): int32 {.stdcall.}
  callVtblErr(self, 8, F, "ID3D12FunctionReflection.GetResourceBindingDescByName", name, desc)

# --- ID3D12LibraryReflection methods ---

proc getDesc*(self: ID3D12LibraryReflection, desc: ptr D3D12_LIBRARY_DESC) =
  type F = proc(this: ID3D12LibraryReflection, desc: ptr D3D12_LIBRARY_DESC): int32 {.stdcall.}
  callVtblErr(self, 3, F, "ID3D12LibraryReflection.GetDesc", desc)

