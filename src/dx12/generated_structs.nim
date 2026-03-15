# Auto-generated from d3d12.h — do not edit manually.
# Regenerate with: nim r tools/generate_api.nim

type
  D3D12_BOX* = object
    left*: uint32
    top*: uint32
    front*: uint32
    right*: uint32
    bottom*: uint32
    back*: uint32

  D3D12_VIEWPORT* = object
    TopLeftX*: float32
    TopLeftY*: float32
    Width*: float32
    Height*: float32
    MinDepth*: float32
    MaxDepth*: float32

  D3D12_RANGE* = object
    start*: csize_t
    finish*: csize_t

  D3D12_RESOURCE_ALLOCATION_INFO* = object
    SizeInBytes*: uint64
    Alignment*: uint64

  D3D12_DRAW_ARGUMENTS* = object
    VertexCountPerInstance*: uint32
    InstanceCount*: uint32
    StartVertexLocation*: uint32
    StartInstanceLocation*: uint32

  D3D12_DRAW_INDEXED_ARGUMENTS* = object
    IndexCountPerInstance*: uint32
    InstanceCount*: uint32
    StartIndexLocation*: uint32
    BaseVertexLocation*: int32
    StartInstanceLocation*: uint32

  D3D12_DISPATCH_ARGUMENTS* = object
    ThreadGroupCountX*: uint32
    ThreadGroupCountY*: uint32
    ThreadGroupCountZ*: uint32

  D3D12_FEATURE_DATA_D3D12_OPTIONS* = object
    DoublePrecisionFloatShaderOps*: int32
    OutputMergerLogicOp*: int32
    MinPrecisionSupport*: uint32
    TiledResourcesTier*: uint32
    ResourceBindingTier*: uint32
    PSSpecifiedStencilRefSupported*: int32
    TypedUAVLoadAdditionalFormats*: int32
    ROVsSupported*: int32
    ConservativeRasterizationTier*: uint32
    MaxGPUVirtualAddressBitsPerResource*: uint32
    StandardSwizzle64KBSupported*: int32
    CrossNodeSharingTier*: uint32
    CrossAdapterRowMajorTextureSupported*: int32
    VPAndRTArrayIndexFromAnyShaderFeedingRasterizerSupportedWithoutGSEmulation*: int32
    ResourceHeapTier*: uint32

  D3D12_FEATURE_DATA_FORMAT_SUPPORT* = object
    Format*: uint32
    Support1*: uint32
    Support2*: uint32

  D3D12_HEAP_PROPERTIES* = object
    typ*: uint32
    CPUPageProperty*: uint32
    MemoryPoolPreference*: uint32
    CreationNodeMask*: uint32
    VisibleNodeMask*: uint32

  D3D12_TILED_RESOURCE_COORDINATE* = object
    X*: uint32
    Y*: uint32
    Z*: uint32
    Subresource*: uint32

  D3D12_TILE_REGION_SIZE* = object
    NumTiles*: uint32
    UseBox*: int32
    Width*: uint32
    Height*: uint16
    Depth*: uint16

  D3D12_SUBRESOURCE_TILING* = object
    WidthInTiles*: uint32
    HeightInTiles*: uint16
    DepthInTiles*: uint16
    StartTileIndexInOverallResource*: uint32

  D3D12_TILE_SHAPE* = object
    WidthInTexels*: uint32
    HeightInTexels*: uint32
    DepthInTexels*: uint32

  D3D12_DEPTH_STENCIL_VALUE* = object
    Depth*: float32
    Stencil*: uint8

  D3D12_PACKED_MIP_INFO* = object
    NumStandardMips*: uint8
    NumPackedMips*: uint8
    NumTilesForPackedMips*: uint32
    StartTileIndexInOverallResource*: uint32

  D3D12_SUBRESOURCE_FOOTPRINT* = object
    Format*: uint32
    Width*: uint32
    Height*: uint32
    Depth*: uint32
    RowPitch*: uint32

  D3D12_DESCRIPTOR_RANGE* = object
    RangeType*: uint32
    NumDescriptors*: uint32
    BaseShaderRegister*: uint32
    RegisterSpace*: uint32
    OffsetInDescriptorsFromTableStart*: uint32

  D3D12_DESCRIPTOR_RANGE1* = object
    RangeType*: uint32
    NumDescriptors*: uint32
    BaseShaderRegister*: uint32
    RegisterSpace*: uint32
    Flags*: uint32
    OffsetInDescriptorsFromTableStart*: uint32

  D3D12_ROOT_CONSTANTS* = object
    ShaderRegister*: uint32
    RegisterSpace*: uint32
    Num32BitValues*: uint32

  D3D12_ROOT_DESCRIPTOR* = object
    ShaderRegister*: uint32
    RegisterSpace*: uint32

  D3D12_ROOT_DESCRIPTOR1* = object
    ShaderRegister*: uint32
    RegisterSpace*: uint32
    Flags*: uint32

  D3D12_STATIC_SAMPLER_DESC* = object
    Filter*: uint32
    AddressU*: uint32
    AddressV*: uint32
    AddressW*: uint32
    MipLODBias*: float32
    MaxAnisotropy*: uint32
    ComparisonFunc*: uint32
    BorderColor*: uint32
    MinLOD*: float32
    MaxLOD*: float32
    ShaderRegister*: uint32
    RegisterSpace*: uint32
    ShaderVisibility*: uint32

  D3D12_DESCRIPTOR_HEAP_DESC* = object
    typ*: uint32
    NumDescriptors*: uint32
    Flags*: uint32
    NodeMask*: uint32

  D3D12_CONSTANT_BUFFER_VIEW_DESC* = object
    BufferLocation*: uint64
    SizeInBytes*: uint32

  D3D12_BUFFER_SRV* = object
    FirstElement*: uint64
    NumElements*: uint32
    StructureByteStride*: uint32
    Flags*: uint32

  D3D12_TEX1D_SRV* = object
    MostDetailedMip*: uint32
    MipLevels*: uint32
    ResourceMinLODClamp*: float32

  D3D12_TEX1D_ARRAY_SRV* = object
    MostDetailedMip*: uint32
    MipLevels*: uint32
    FirstArraySlice*: uint32
    ArraySize*: uint32
    ResourceMinLODClamp*: float32

  D3D12_TEX2D_SRV* = object
    MostDetailedMip*: uint32
    MipLevels*: uint32
    PlaneSlice*: uint32
    ResourceMinLODClamp*: float32

  D3D12_TEX2D_ARRAY_SRV* = object
    MostDetailedMip*: uint32
    MipLevels*: uint32
    FirstArraySlice*: uint32
    ArraySize*: uint32
    PlaneSlice*: uint32
    ResourceMinLODClamp*: float32

  D3D12_TEX2DMS_SRV* = object
    UnusedField_NothingToDefine*: uint32

  D3D12_TEX2DMS_ARRAY_SRV* = object
    FirstArraySlice*: uint32
    ArraySize*: uint32

  D3D12_TEX3D_SRV* = object
    MostDetailedMip*: uint32
    MipLevels*: uint32
    ResourceMinLODClamp*: float32

  D3D12_TEXCUBE_SRV* = object
    MostDetailedMip*: uint32
    MipLevels*: uint32
    ResourceMinLODClamp*: float32

  D3D12_TEXCUBE_ARRAY_SRV* = object
    MostDetailedMip*: uint32
    MipLevels*: uint32
    First2DArrayFace*: uint32
    NumCubes*: uint32
    ResourceMinLODClamp*: float32

  D3D12_BUFFER_UAV* = object
    FirstElement*: uint64
    NumElements*: uint32
    StructureByteStride*: uint32
    CounterOffsetInBytes*: uint64
    Flags*: uint32

  D3D12_TEX1D_UAV* = object
    MipSlice*: uint32

  D3D12_TEX1D_ARRAY_UAV* = object
    MipSlice*: uint32
    FirstArraySlice*: uint32
    ArraySize*: uint32

  D3D12_TEX2D_UAV* = object
    MipSlice*: uint32
    PlaneSlice*: uint32

  D3D12_TEX2D_ARRAY_UAV* = object
    MipSlice*: uint32
    FirstArraySlice*: uint32
    ArraySize*: uint32
    PlaneSlice*: uint32

  D3D12_TEX3D_UAV* = object
    MipSlice*: uint32
    FirstWSlice*: uint32
    WSize*: uint32

  D3D12_BUFFER_RTV* = object
    FirstElement*: uint64
    NumElements*: uint32

  D3D12_TEX1D_RTV* = object
    MipSlice*: uint32

  D3D12_TEX1D_ARRAY_RTV* = object
    MipSlice*: uint32
    FirstArraySlice*: uint32
    ArraySize*: uint32

  D3D12_TEX2D_RTV* = object
    MipSlice*: uint32
    PlaneSlice*: uint32

  D3D12_TEX2D_ARRAY_RTV* = object
    MipSlice*: uint32
    FirstArraySlice*: uint32
    ArraySize*: uint32
    PlaneSlice*: uint32

  D3D12_TEX2DMS_RTV* = object
    UnusedField_NothingToDefine*: uint32

  D3D12_TEX2DMS_ARRAY_RTV* = object
    FirstArraySlice*: uint32
    ArraySize*: uint32

  D3D12_TEX3D_RTV* = object
    MipSlice*: uint32
    FirstWSlice*: uint32
    WSize*: uint32

  D3D12_TEX1D_DSV* = object
    MipSlice*: uint32

  D3D12_TEX1D_ARRAY_DSV* = object
    MipSlice*: uint32
    FirstArraySlice*: uint32
    ArraySize*: uint32

  D3D12_TEX2D_DSV* = object
    MipSlice*: uint32

  D3D12_TEX2D_ARRAY_DSV* = object
    MipSlice*: uint32
    FirstArraySlice*: uint32
    ArraySize*: uint32

  D3D12_TEX2DMS_DSV* = object
    UnusedField_NothingToDefine*: uint32

  D3D12_TEX2DMS_ARRAY_DSV* = object
    FirstArraySlice*: uint32
    ArraySize*: uint32

  D3D12_CPU_DESCRIPTOR_HANDLE* = object
    ptrValue*: csize_t

  D3D12_GPU_DESCRIPTOR_HANDLE* = object
    ptrValue*: uint64

  D3D12_DEPTH_STENCILOP_DESC* = object
    StencilFailOp*: uint32
    StencilDepthFailOp*: uint32
    StencilPassOp*: uint32
    StencilFunc*: uint32

  D3D12_RENDER_TARGET_BLEND_DESC* = object
    BlendEnable*: int32
    LogicOpEnable*: int32
    SrcBlend*: uint32
    DestBlend*: uint32
    BlendOp*: uint32
    SrcBlendAlpha*: uint32
    DestBlendAlpha*: uint32
    BlendOpAlpha*: uint32
    LogicOp*: uint32
    RenderTargetWriteMask*: uint8

  D3D12_RASTERIZER_DESC* = object
    FillMode*: uint32
    CullMode*: uint32
    FrontCounterClockwise*: int32
    DepthBias*: int32
    DepthBiasClamp*: float32
    SlopeScaledDepthBias*: float32
    DepthClipEnable*: int32
    MultisampleEnable*: int32
    AntialiasedLineEnable*: int32
    ForcedSampleCount*: uint32
    ConservativeRaster*: uint32

  D3D12_COMMAND_QUEUE_DESC* = object
    typ*: uint32
    Priority*: int32
    Flags*: uint32
    NodeMask*: uint32

  D3D12_FEATURE_DATA_ARCHITECTURE* = object
    NodeIndex*: uint32
    TileBasedRenderer*: int32
    UMA*: int32
    CacheCoherentUMA*: int32

  D3D12_FEATURE_DATA_FORMAT_INFO* = object
    Format*: uint32
    PlaneCount*: uint8

  D3D12_INDEX_BUFFER_VIEW* = object
    BufferLocation*: uint64
    SizeInBytes*: uint32
    Format*: uint32

  D3D12_VERTEX_BUFFER_VIEW* = object
    BufferLocation*: uint64
    SizeInBytes*: uint32
    StrideInBytes*: uint32

  D3D12_STREAM_OUTPUT_BUFFER_VIEW* = object
    BufferLocation*: uint64
    SizeInBytes*: uint64
    BufferFilledSizeLocation*: uint64

  D3D12_QUERY_DATA_PIPELINE_STATISTICS* = object
    IAVertices*: uint64
    IAPrimitives*: uint64
    VSInvocations*: uint64
    GSInvocations*: uint64
    GSPrimitives*: uint64
    CInvocations*: uint64
    CPrimitives*: uint64
    PSInvocations*: uint64
    HSInvocations*: uint64
    DSInvocations*: uint64
    CSInvocations*: uint64

  D3D12_QUERY_HEAP_DESC* = object
    typ*: uint32
    Count*: uint32
    NodeMask*: uint32

  DXGI_QUERY_VIDEO_MEMORY_INFO* = object
    Budget*: uint64
    CurrentUsage*: uint64
    AvailableForReservation*: uint64
    CurrentReservation*: uint64

