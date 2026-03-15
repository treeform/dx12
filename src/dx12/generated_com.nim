# Auto-generated COM interface stubs and methods — do not edit manually.
# Regenerate with: nim r tools/generate_api.nim
#
# Depends on: generated_structs (for struct types)
# Depends on: callVtbl, callVtblErr, callVtbl0, callVtbl0Err templates

import generated_structs

type
  ID3D12Object* = ptr object
  ID3D12DeviceChild* = ptr object
  ID3D12Pageable* = ptr object
  ID3D12Resource* = ptr object
  ID3D12CommandList* = ptr object
  ID3D12DescriptorHeap* = ptr object
  ID3D12QueryHeap* = ptr object
  ID3D12CommandSignature* = ptr object
  ID3D12GraphicsCommandList* = ptr object
  ID3D12CommandQueue* = ptr object
  ID3D12RootSignature* = ptr object
  ID3D12PipelineState* = ptr object
  ID3D12Fence* = ptr object
  ID3D12CommandAllocator* = ptr object
  ID3D12Device* = ptr object
  ID3D12Debug* = ptr object
  ID3D12RootSignatureDeserializer* = ptr object
  ID3D12Heap* = ptr object
  IDXGISwapChain3* = ptr object
  IDXGIOutput4* = ptr object
  IDXGIFactory4* = ptr object
  IDXGIAdapter3* = ptr object
  ID3D12ShaderReflectionType* = ptr object
  ID3D12ShaderReflectionVariable* = ptr object
  ID3D12ShaderReflectionConstantBuffer* = ptr object
  ID3D12ShaderReflection* = ptr object
  ID3D12FunctionParameterReflection* = ptr object
  ID3D12FunctionReflection* = ptr object
  ID3D12LibraryReflection* = ptr object

# --- vtable call templates ---

template callVtbl0(iface: pointer, index: int, typ: typedesc): untyped =
  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)
  let vtbl = vtblPtr[]
  let fn = cast[typ](vtbl[index])
  fn(iface)

template callVtbl(iface: pointer, index: int, typ: typedesc, args: varargs[untyped]): untyped =
  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)
  let vtbl = vtblPtr[]
  let fn = cast[typ](vtbl[index])
  fn(iface, args)

template callVtbl0Err(iface: pointer, index: int, typ: typedesc, msg: string): untyped =
  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)
  let vtbl = vtblPtr[]
  let fn = cast[typ](vtbl[index])
  let hr = fn(iface)
  if hr < 0:
    raise newException(Exception, msg & " HRESULT " & $hr)

template callVtblErr(iface: pointer, index: int, typ: typedesc, msg: string, args: varargs[untyped]): untyped =
  let vtblPtr = cast[ptr ptr UncheckedArray[pointer]](iface)
  let vtbl = vtblPtr[]
  let fn = cast[typ](vtbl[index])
  let hr = fn(iface, args)
  if hr < 0:
    raise newException(Exception, msg & " HRESULT " & $hr)

# --- ID3D12Object methods ---

proc getPrivateData*(self: ID3D12Object, guid: pointer, data_size: ptr uint32, data: pointer) =
  type F = proc(this: ID3D12Object, guid: pointer, data_size: ptr uint32, data: pointer): int32 {.stdcall.}
  callVtblErr(self, 3, F, "ID3D12Object.GetPrivateData", guid, data_size, data)

proc setPrivateData*(self: ID3D12Object, guid: pointer, data_size: uint32, data: pointer) =
  type F = proc(this: ID3D12Object, guid: pointer, data_size: uint32, data: pointer): int32 {.stdcall.}
  callVtblErr(self, 4, F, "ID3D12Object.SetPrivateData", guid, data_size, data)

proc setPrivateDataInterface*(self: ID3D12Object, guid: pointer, data: pointer) =
  type F = proc(this: ID3D12Object, guid: pointer, data: pointer): int32 {.stdcall.}
  callVtblErr(self, 5, F, "ID3D12Object.SetPrivateDataInterface", guid, data)

proc setName*(self: ID3D12Object, name: pointer) =
  type F = proc(this: ID3D12Object, name: pointer): int32 {.stdcall.}
  callVtblErr(self, 6, F, "ID3D12Object.SetName", name)

# --- ID3D12DeviceChild methods ---

proc getDevice*(self: ID3D12DeviceChild, riid: pointer, device: ptr pointer) =
  type F = proc(this: ID3D12DeviceChild, riid: pointer, device: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 7, F, "ID3D12DeviceChild.GetDevice", riid, device)

# --- ID3D12Resource methods ---

proc map*(self: ID3D12Resource, sub_resource: uint32, read_range: ptr D3D12_RANGE, data: ptr pointer) =
  type F = proc(this: ID3D12Resource, sub_resource: uint32, read_range: ptr D3D12_RANGE, data: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 8, F, "ID3D12Resource.Map", sub_resource, read_range, data)

proc unmap*(self: ID3D12Resource, sub_resource: uint32, written_range: ptr D3D12_RANGE) =
  type F = proc(this: ID3D12Resource, sub_resource: uint32, written_range: ptr D3D12_RANGE): void {.stdcall.}
  callVtbl(self, 9, F, sub_resource, written_range)

proc getGPUVirtualAddress*(self: ID3D12Resource): uint64 =
  type F = proc(this: ID3D12Resource): uint64 {.stdcall.}
  callVtbl0(self, 11, F)

proc writeToSubresource*(self: ID3D12Resource, dst_sub_resource: uint32, dst_box: ptr D3D12_BOX, src_data: pointer, src_row_pitch: uint32, src_slice_pitch: uint32) =
  type F = proc(this: ID3D12Resource, dst_sub_resource: uint32, dst_box: ptr D3D12_BOX, src_data: pointer, src_row_pitch: uint32, src_slice_pitch: uint32): int32 {.stdcall.}
  callVtblErr(self, 12, F, "ID3D12Resource.WriteToSubresource", dst_sub_resource, dst_box, src_data, src_row_pitch, src_slice_pitch)

proc readFromSubresource*(self: ID3D12Resource, dst_data: pointer, dst_row_pitch: uint32, dst_slice_pitch: uint32, src_sub_resource: uint32, src_box: ptr D3D12_BOX) =
  type F = proc(this: ID3D12Resource, dst_data: pointer, dst_row_pitch: uint32, dst_slice_pitch: uint32, src_sub_resource: uint32, src_box: ptr D3D12_BOX): int32 {.stdcall.}
  callVtblErr(self, 13, F, "ID3D12Resource.ReadFromSubresource", dst_data, dst_row_pitch, dst_slice_pitch, src_sub_resource, src_box)

proc getHeapProperties*(self: ID3D12Resource, heap_properties: ptr D3D12_HEAP_PROPERTIES, flags: ptr uint32) =
  type F = proc(this: ID3D12Resource, heap_properties: ptr D3D12_HEAP_PROPERTIES, flags: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 14, F, "ID3D12Resource.GetHeapProperties", heap_properties, flags)

# --- ID3D12CommandList methods ---

proc getType*(self: ID3D12CommandList): uint32 =
  type F = proc(this: ID3D12CommandList): uint32 {.stdcall.}
  callVtbl0(self, 8, F)

# --- ID3D12DescriptorHeap methods ---

# --- ID3D12GraphicsCommandList methods ---

proc close*(self: ID3D12GraphicsCommandList) =
  type F = proc(this: ID3D12GraphicsCommandList): int32 {.stdcall.}
  callVtbl0Err(self, 9, F, "ID3D12GraphicsCommandList.Close")

proc reset*(self: ID3D12GraphicsCommandList, allocator: ID3D12CommandAllocator, initial_state: ID3D12PipelineState) =
  type F = proc(this: ID3D12GraphicsCommandList, allocator: ID3D12CommandAllocator, initial_state: ID3D12PipelineState): int32 {.stdcall.}
  callVtblErr(self, 10, F, "ID3D12GraphicsCommandList.Reset", allocator, initial_state)

proc clearState*(self: ID3D12GraphicsCommandList, pipeline_state: ID3D12PipelineState) =
  type F = proc(this: ID3D12GraphicsCommandList, pipeline_state: ID3D12PipelineState): int32 {.stdcall.}
  callVtblErr(self, 11, F, "ID3D12GraphicsCommandList.ClearState", pipeline_state)

proc drawInstanced*(self: ID3D12GraphicsCommandList, vertex_count_per_instance: uint32, instance_count: uint32, start_vertex_location: uint32, start_instance_location: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, vertex_count_per_instance: uint32, instance_count: uint32, start_vertex_location: uint32, start_instance_location: uint32): void {.stdcall.}
  callVtbl(self, 12, F, vertex_count_per_instance, instance_count, start_vertex_location, start_instance_location)

proc drawIndexedInstanced*(self: ID3D12GraphicsCommandList, index_count_per_instance: uint32, instance_count: uint32, start_vertex_location: uint32, base_vertex_location: int32, start_instance_location: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, index_count_per_instance: uint32, instance_count: uint32, start_vertex_location: uint32, base_vertex_location: int32, start_instance_location: uint32): void {.stdcall.}
  callVtbl(self, 13, F, index_count_per_instance, instance_count, start_vertex_location, base_vertex_location, start_instance_location)

proc dispatch*(self: ID3D12GraphicsCommandList, x: uint32, u: uint32, z: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, x: uint32, u: uint32, z: uint32): void {.stdcall.}
  callVtbl(self, 14, F, x, u, z)

proc copyBufferRegion*(self: ID3D12GraphicsCommandList, dst_buffer: ID3D12Resource, dst_offset: uint64, src_buffer: ID3D12Resource, src_offset: uint64, byte_count: uint64) =
  type F = proc(this: ID3D12GraphicsCommandList, dst_buffer: ID3D12Resource, dst_offset: uint64, src_buffer: ID3D12Resource, src_offset: uint64, byte_count: uint64): void {.stdcall.}
  callVtbl(self, 15, F, dst_buffer, dst_offset, src_buffer, src_offset, byte_count)

proc copyTextureRegion*(self: ID3D12GraphicsCommandList, dst: pointer, dst_x: uint32, dst_y: uint32, dst_z: uint32, src: pointer, src_box: ptr D3D12_BOX) =
  type F = proc(this: ID3D12GraphicsCommandList, dst: pointer, dst_x: uint32, dst_y: uint32, dst_z: uint32, src: pointer, src_box: ptr D3D12_BOX): void {.stdcall.}
  callVtbl(self, 16, F, dst, dst_x, dst_y, dst_z, src, src_box)

proc copyResource*(self: ID3D12GraphicsCommandList, dst_resource: ID3D12Resource, src_resource: ID3D12Resource) =
  type F = proc(this: ID3D12GraphicsCommandList, dst_resource: ID3D12Resource, src_resource: ID3D12Resource): void {.stdcall.}
  callVtbl(self, 17, F, dst_resource, src_resource)

proc copyTiles*(self: ID3D12GraphicsCommandList, tiled_resource: ID3D12Resource, tile_region_start_coordinate: ptr D3D12_TILED_RESOURCE_COORDINATE, tile_region_size: ptr D3D12_TILE_REGION_SIZE, buffer: ID3D12Resource, buffer_offset: uint64, flags: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, tiled_resource: ID3D12Resource, tile_region_start_coordinate: ptr D3D12_TILED_RESOURCE_COORDINATE, tile_region_size: ptr D3D12_TILE_REGION_SIZE, buffer: ID3D12Resource, buffer_offset: uint64, flags: uint32): void {.stdcall.}
  callVtbl(self, 18, F, tiled_resource, tile_region_start_coordinate, tile_region_size, buffer, buffer_offset, flags)

proc resolveSubresource*(self: ID3D12GraphicsCommandList, dst_resource: ID3D12Resource, dst_sub_resource: uint32, src_resource: ID3D12Resource, src_sub_resource: uint32, format: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, dst_resource: ID3D12Resource, dst_sub_resource: uint32, src_resource: ID3D12Resource, src_sub_resource: uint32, format: uint32): void {.stdcall.}
  callVtbl(self, 19, F, dst_resource, dst_sub_resource, src_resource, src_sub_resource, format)

proc iaSetPrimitiveTopology*(self: ID3D12GraphicsCommandList, primitive_topology: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, primitive_topology: uint32): void {.stdcall.}
  callVtbl(self, 20, F, primitive_topology)

proc rsSetViewports*(self: ID3D12GraphicsCommandList, viewport_count: uint32, viewports: ptr D3D12_VIEWPORT) =
  type F = proc(this: ID3D12GraphicsCommandList, viewport_count: uint32, viewports: ptr D3D12_VIEWPORT): void {.stdcall.}
  callVtbl(self, 21, F, viewport_count, viewports)

proc rsSetScissorRects*(self: ID3D12GraphicsCommandList, rect_count: uint32, rects: pointer) =
  type F = proc(this: ID3D12GraphicsCommandList, rect_count: uint32, rects: pointer): void {.stdcall.}
  callVtbl(self, 22, F, rect_count, rects)

proc omSetBlendFactor*(self: ID3D12GraphicsCommandList, blend_factor: pointer) =
  type F = proc(this: ID3D12GraphicsCommandList, blend_factor: pointer): void {.stdcall.}
  callVtbl(self, 23, F, blend_factor)

proc omSetStencilRef*(self: ID3D12GraphicsCommandList, stencil_ref: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, stencil_ref: uint32): void {.stdcall.}
  callVtbl(self, 24, F, stencil_ref)

proc setPipelineState*(self: ID3D12GraphicsCommandList, pipeline_state: ID3D12PipelineState) =
  type F = proc(this: ID3D12GraphicsCommandList, pipeline_state: ID3D12PipelineState): void {.stdcall.}
  callVtbl(self, 25, F, pipeline_state)

proc resourceBarrier*(self: ID3D12GraphicsCommandList, barrier_count: uint32, barriers: pointer) =
  type F = proc(this: ID3D12GraphicsCommandList, barrier_count: uint32, barriers: pointer): void {.stdcall.}
  callVtbl(self, 26, F, barrier_count, barriers)

proc executeBundle*(self: ID3D12GraphicsCommandList, command_list: ID3D12GraphicsCommandList) =
  type F = proc(this: ID3D12GraphicsCommandList, command_list: ID3D12GraphicsCommandList): void {.stdcall.}
  callVtbl(self, 27, F, command_list)

proc setDescriptorHeaps*(self: ID3D12GraphicsCommandList, heap_count: uint32, heaps: ptr ID3D12DescriptorHeap) =
  type F = proc(this: ID3D12GraphicsCommandList, heap_count: uint32, heaps: ptr ID3D12DescriptorHeap): void {.stdcall.}
  callVtbl(self, 28, F, heap_count, heaps)

proc setComputeRootSignature*(self: ID3D12GraphicsCommandList, root_signature: ID3D12RootSignature) =
  type F = proc(this: ID3D12GraphicsCommandList, root_signature: ID3D12RootSignature): void {.stdcall.}
  callVtbl(self, 29, F, root_signature)

proc setGraphicsRootSignature*(self: ID3D12GraphicsCommandList, root_signature: ID3D12RootSignature) =
  type F = proc(this: ID3D12GraphicsCommandList, root_signature: ID3D12RootSignature): void {.stdcall.}
  callVtbl(self, 30, F, root_signature)

proc setComputeRootDescriptorTable*(self: ID3D12GraphicsCommandList, root_parameter_index: uint32, base_descriptor: D3D12_GPU_DESCRIPTOR_HANDLE) =
  type F = proc(this: ID3D12GraphicsCommandList, root_parameter_index: uint32, base_descriptor: D3D12_GPU_DESCRIPTOR_HANDLE): void {.stdcall.}
  callVtbl(self, 31, F, root_parameter_index, base_descriptor)

proc setGraphicsRootDescriptorTable*(self: ID3D12GraphicsCommandList, root_parameter_index: uint32, base_descriptor: D3D12_GPU_DESCRIPTOR_HANDLE) =
  type F = proc(this: ID3D12GraphicsCommandList, root_parameter_index: uint32, base_descriptor: D3D12_GPU_DESCRIPTOR_HANDLE): void {.stdcall.}
  callVtbl(self, 32, F, root_parameter_index, base_descriptor)

proc setComputeRoot32BitConstant*(self: ID3D12GraphicsCommandList, root_parameter_index: uint32, data: uint32, dst_offset: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, root_parameter_index: uint32, data: uint32, dst_offset: uint32): void {.stdcall.}
  callVtbl(self, 33, F, root_parameter_index, data, dst_offset)

proc setGraphicsRoot32BitConstant*(self: ID3D12GraphicsCommandList, root_parameter_index: uint32, data: uint32, dst_offset: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, root_parameter_index: uint32, data: uint32, dst_offset: uint32): void {.stdcall.}
  callVtbl(self, 34, F, root_parameter_index, data, dst_offset)

proc setComputeRoot32BitConstants*(self: ID3D12GraphicsCommandList, root_parameter_index: uint32, constant_count: uint32, data: pointer, dst_offset: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, root_parameter_index: uint32, constant_count: uint32, data: pointer, dst_offset: uint32): void {.stdcall.}
  callVtbl(self, 35, F, root_parameter_index, constant_count, data, dst_offset)

proc setGraphicsRoot32BitConstants*(self: ID3D12GraphicsCommandList, root_parameter_index: uint32, constant_count: uint32, data: pointer, dst_offset: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, root_parameter_index: uint32, constant_count: uint32, data: pointer, dst_offset: uint32): void {.stdcall.}
  callVtbl(self, 36, F, root_parameter_index, constant_count, data, dst_offset)

proc setComputeRootConstantBufferView*(self: ID3D12GraphicsCommandList, root_parameter_index: uint32, address: uint64) =
  type F = proc(this: ID3D12GraphicsCommandList, root_parameter_index: uint32, address: uint64): void {.stdcall.}
  callVtbl(self, 37, F, root_parameter_index, address)

proc setGraphicsRootConstantBufferView*(self: ID3D12GraphicsCommandList, root_parameter_index: uint32, address: uint64) =
  type F = proc(this: ID3D12GraphicsCommandList, root_parameter_index: uint32, address: uint64): void {.stdcall.}
  callVtbl(self, 38, F, root_parameter_index, address)

proc setComputeRootShaderResourceView*(self: ID3D12GraphicsCommandList, root_parameter_index: uint32, address: uint64) =
  type F = proc(this: ID3D12GraphicsCommandList, root_parameter_index: uint32, address: uint64): void {.stdcall.}
  callVtbl(self, 39, F, root_parameter_index, address)

proc setGraphicsRootShaderResourceView*(self: ID3D12GraphicsCommandList, root_parameter_index: uint32, address: uint64) =
  type F = proc(this: ID3D12GraphicsCommandList, root_parameter_index: uint32, address: uint64): void {.stdcall.}
  callVtbl(self, 40, F, root_parameter_index, address)

proc setComputeRootUnorderedAccessView*(self: ID3D12GraphicsCommandList, root_parameter_index: uint32, address: uint64) =
  type F = proc(this: ID3D12GraphicsCommandList, root_parameter_index: uint32, address: uint64): void {.stdcall.}
  callVtbl(self, 41, F, root_parameter_index, address)

proc setGraphicsRootUnorderedAccessView*(self: ID3D12GraphicsCommandList, root_parameter_index: uint32, address: uint64) =
  type F = proc(this: ID3D12GraphicsCommandList, root_parameter_index: uint32, address: uint64): void {.stdcall.}
  callVtbl(self, 42, F, root_parameter_index, address)

proc iaSetIndexBuffer*(self: ID3D12GraphicsCommandList, view: ptr D3D12_INDEX_BUFFER_VIEW) =
  type F = proc(this: ID3D12GraphicsCommandList, view: ptr D3D12_INDEX_BUFFER_VIEW): void {.stdcall.}
  callVtbl(self, 43, F, view)

proc iaSetVertexBuffers*(self: ID3D12GraphicsCommandList, start_slot: uint32, view_count: uint32, views: ptr D3D12_VERTEX_BUFFER_VIEW) =
  type F = proc(this: ID3D12GraphicsCommandList, start_slot: uint32, view_count: uint32, views: ptr D3D12_VERTEX_BUFFER_VIEW): void {.stdcall.}
  callVtbl(self, 44, F, start_slot, view_count, views)

proc soSetTargets*(self: ID3D12GraphicsCommandList, start_slot: uint32, view_count: uint32, views: ptr D3D12_STREAM_OUTPUT_BUFFER_VIEW) =
  type F = proc(this: ID3D12GraphicsCommandList, start_slot: uint32, view_count: uint32, views: ptr D3D12_STREAM_OUTPUT_BUFFER_VIEW): void {.stdcall.}
  callVtbl(self, 45, F, start_slot, view_count, views)

proc omSetRenderTargets*(self: ID3D12GraphicsCommandList, render_target_descriptor_count: uint32, render_target_descriptors: ptr D3D12_CPU_DESCRIPTOR_HANDLE, single_descriptor_handle: int32, depth_stencil_descriptor: ptr D3D12_CPU_DESCRIPTOR_HANDLE) =
  type F = proc(this: ID3D12GraphicsCommandList, render_target_descriptor_count: uint32, render_target_descriptors: ptr D3D12_CPU_DESCRIPTOR_HANDLE, single_descriptor_handle: int32, depth_stencil_descriptor: ptr D3D12_CPU_DESCRIPTOR_HANDLE): void {.stdcall.}
  callVtbl(self, 46, F, render_target_descriptor_count, render_target_descriptors, single_descriptor_handle, depth_stencil_descriptor)

proc clearDepthStencilView*(self: ID3D12GraphicsCommandList, dsv: D3D12_CPU_DESCRIPTOR_HANDLE, flags: uint32, depth: float32, stencil: uint8, rect_count: uint32, rects: pointer) =
  type F = proc(this: ID3D12GraphicsCommandList, dsv: D3D12_CPU_DESCRIPTOR_HANDLE, flags: uint32, depth: float32, stencil: uint8, rect_count: uint32, rects: pointer): void {.stdcall.}
  callVtbl(self, 47, F, dsv, flags, depth, stencil, rect_count, rects)

proc clearRenderTargetView*(self: ID3D12GraphicsCommandList, rtv: D3D12_CPU_DESCRIPTOR_HANDLE, color: pointer, rect_count: uint32, rects: pointer) =
  type F = proc(this: ID3D12GraphicsCommandList, rtv: D3D12_CPU_DESCRIPTOR_HANDLE, color: pointer, rect_count: uint32, rects: pointer): void {.stdcall.}
  callVtbl(self, 48, F, rtv, color, rect_count, rects)

proc clearUnorderedAccessViewUint*(self: ID3D12GraphicsCommandList, gpu_handle: D3D12_GPU_DESCRIPTOR_HANDLE, cpu_handle: D3D12_CPU_DESCRIPTOR_HANDLE, resource: ID3D12Resource, values: pointer, rect_count: uint32, rects: pointer) =
  type F = proc(this: ID3D12GraphicsCommandList, gpu_handle: D3D12_GPU_DESCRIPTOR_HANDLE, cpu_handle: D3D12_CPU_DESCRIPTOR_HANDLE, resource: ID3D12Resource, values: pointer, rect_count: uint32, rects: pointer): void {.stdcall.}
  callVtbl(self, 49, F, gpu_handle, cpu_handle, resource, values, rect_count, rects)

proc clearUnorderedAccessViewFloat*(self: ID3D12GraphicsCommandList, gpu_handle: D3D12_GPU_DESCRIPTOR_HANDLE, cpu_handle: D3D12_CPU_DESCRIPTOR_HANDLE, resource: ID3D12Resource, values: pointer, rect_count: uint32, rects: pointer) =
  type F = proc(this: ID3D12GraphicsCommandList, gpu_handle: D3D12_GPU_DESCRIPTOR_HANDLE, cpu_handle: D3D12_CPU_DESCRIPTOR_HANDLE, resource: ID3D12Resource, values: pointer, rect_count: uint32, rects: pointer): void {.stdcall.}
  callVtbl(self, 50, F, gpu_handle, cpu_handle, resource, values, rect_count, rects)

proc discardResource*(self: ID3D12GraphicsCommandList, resource: ID3D12Resource, region: pointer) =
  type F = proc(this: ID3D12GraphicsCommandList, resource: ID3D12Resource, region: pointer): void {.stdcall.}
  callVtbl(self, 51, F, resource, region)

proc beginQuery*(self: ID3D12GraphicsCommandList, heap: ID3D12QueryHeap, typeField: uint32, index: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, heap: ID3D12QueryHeap, typeField: uint32, index: uint32): void {.stdcall.}
  callVtbl(self, 52, F, heap, typeField, index)

proc endQuery*(self: ID3D12GraphicsCommandList, heap: ID3D12QueryHeap, typeField: uint32, index: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, heap: ID3D12QueryHeap, typeField: uint32, index: uint32): void {.stdcall.}
  callVtbl(self, 53, F, heap, typeField, index)

proc resolveQueryData*(self: ID3D12GraphicsCommandList, heap: ID3D12QueryHeap, typeField: uint32, start_index: uint32, query_count: uint32, dst_buffer: ID3D12Resource, aligned_dst_buffer_offset: uint64) =
  type F = proc(this: ID3D12GraphicsCommandList, heap: ID3D12QueryHeap, typeField: uint32, start_index: uint32, query_count: uint32, dst_buffer: ID3D12Resource, aligned_dst_buffer_offset: uint64): void {.stdcall.}
  callVtbl(self, 54, F, heap, typeField, start_index, query_count, dst_buffer, aligned_dst_buffer_offset)

proc setPredication*(self: ID3D12GraphicsCommandList, buffer: ID3D12Resource, aligned_buffer_offset: uint64, operation: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, buffer: ID3D12Resource, aligned_buffer_offset: uint64, operation: uint32): void {.stdcall.}
  callVtbl(self, 55, F, buffer, aligned_buffer_offset, operation)

proc setMarker*(self: ID3D12GraphicsCommandList, metadata: uint32, data: pointer, size: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, metadata: uint32, data: pointer, size: uint32): void {.stdcall.}
  callVtbl(self, 56, F, metadata, data, size)

proc beginEvent*(self: ID3D12GraphicsCommandList, metadata: uint32, data: pointer, size: uint32) =
  type F = proc(this: ID3D12GraphicsCommandList, metadata: uint32, data: pointer, size: uint32): void {.stdcall.}
  callVtbl(self, 57, F, metadata, data, size)

proc endEvent*(self: ID3D12GraphicsCommandList) =
  type F = proc(this: ID3D12GraphicsCommandList): void {.stdcall.}
  callVtbl0(self, 58, F)

proc executeIndirect*(self: ID3D12GraphicsCommandList, command_signature: ID3D12CommandSignature, max_command_count: uint32, arg_buffer: ID3D12Resource, arg_buffer_offset: uint64, count_buffer: ID3D12Resource, count_buffer_offset: uint64) =
  type F = proc(this: ID3D12GraphicsCommandList, command_signature: ID3D12CommandSignature, max_command_count: uint32, arg_buffer: ID3D12Resource, arg_buffer_offset: uint64, count_buffer: ID3D12Resource, count_buffer_offset: uint64): void {.stdcall.}
  callVtbl(self, 59, F, command_signature, max_command_count, arg_buffer, arg_buffer_offset, count_buffer, count_buffer_offset)

# --- ID3D12CommandQueue methods ---

proc updateTileMappings*(self: ID3D12CommandQueue, resource: ID3D12Resource, region_count: uint32, region_start_coordinates: ptr D3D12_TILED_RESOURCE_COORDINATE, region_sizes: ptr D3D12_TILE_REGION_SIZE, range_count: uint32, range_flags: pointer, heap_range_offsets: ptr uint32, range_tile_counts: ptr uint32, flags: uint32) =
  type F = proc(this: ID3D12CommandQueue, resource: ID3D12Resource, region_count: uint32, region_start_coordinates: ptr D3D12_TILED_RESOURCE_COORDINATE, region_sizes: ptr D3D12_TILE_REGION_SIZE, range_count: uint32, range_flags: pointer, heap_range_offsets: ptr uint32, range_tile_counts: ptr uint32, flags: uint32): void {.stdcall.}
  callVtbl(self, 8, F, resource, region_count, region_start_coordinates, region_sizes, range_count, range_flags, heap_range_offsets, range_tile_counts, flags)

proc copyTileMappings*(self: ID3D12CommandQueue, dst_resource: ID3D12Resource, dst_region_start_coordinate: ptr D3D12_TILED_RESOURCE_COORDINATE, src_resource: ID3D12Resource, src_region_start_coordinate: ptr D3D12_TILED_RESOURCE_COORDINATE, region_size: ptr D3D12_TILE_REGION_SIZE, flags: uint32) =
  type F = proc(this: ID3D12CommandQueue, dst_resource: ID3D12Resource, dst_region_start_coordinate: ptr D3D12_TILED_RESOURCE_COORDINATE, src_resource: ID3D12Resource, src_region_start_coordinate: ptr D3D12_TILED_RESOURCE_COORDINATE, region_size: ptr D3D12_TILE_REGION_SIZE, flags: uint32): void {.stdcall.}
  callVtbl(self, 9, F, dst_resource, dst_region_start_coordinate, src_resource, src_region_start_coordinate, region_size, flags)

proc executeCommandLists*(self: ID3D12CommandQueue, command_list_count: uint32, command_lists: ptr ID3D12CommandList) =
  type F = proc(this: ID3D12CommandQueue, command_list_count: uint32, command_lists: ptr ID3D12CommandList): void {.stdcall.}
  callVtbl(self, 10, F, command_list_count, command_lists)

proc setMarker*(self: ID3D12CommandQueue, metadata: uint32, data: pointer, size: uint32) =
  type F = proc(this: ID3D12CommandQueue, metadata: uint32, data: pointer, size: uint32): void {.stdcall.}
  callVtbl(self, 11, F, metadata, data, size)

proc beginEvent*(self: ID3D12CommandQueue, metadata: uint32, data: pointer, size: uint32) =
  type F = proc(this: ID3D12CommandQueue, metadata: uint32, data: pointer, size: uint32): void {.stdcall.}
  callVtbl(self, 12, F, metadata, data, size)

proc endEvent*(self: ID3D12CommandQueue) =
  type F = proc(this: ID3D12CommandQueue): void {.stdcall.}
  callVtbl0(self, 13, F)

proc signal*(self: ID3D12CommandQueue, fence: ID3D12Fence, value: uint64) =
  type F = proc(this: ID3D12CommandQueue, fence: ID3D12Fence, value: uint64): int32 {.stdcall.}
  callVtblErr(self, 14, F, "ID3D12CommandQueue.Signal", fence, value)

proc wait*(self: ID3D12CommandQueue, fence: ID3D12Fence, value: uint64) =
  type F = proc(this: ID3D12CommandQueue, fence: ID3D12Fence, value: uint64): int32 {.stdcall.}
  callVtblErr(self, 15, F, "ID3D12CommandQueue.Wait", fence, value)

proc getTimestampFrequency*(self: ID3D12CommandQueue, frequency: ptr uint64) =
  type F = proc(this: ID3D12CommandQueue, frequency: ptr uint64): int32 {.stdcall.}
  callVtblErr(self, 16, F, "ID3D12CommandQueue.GetTimestampFrequency", frequency)

proc getClockCalibration*(self: ID3D12CommandQueue, gpu_timestamp: ptr uint64, cpu_timestamp: ptr uint64) =
  type F = proc(this: ID3D12CommandQueue, gpu_timestamp: ptr uint64, cpu_timestamp: ptr uint64): int32 {.stdcall.}
  callVtblErr(self, 17, F, "ID3D12CommandQueue.GetClockCalibration", gpu_timestamp, cpu_timestamp)

# --- ID3D12PipelineState methods ---

proc getCachedBlob*(self: ID3D12PipelineState, blob: pointer) =
  type F = proc(this: ID3D12PipelineState, blob: pointer): int32 {.stdcall.}
  callVtblErr(self, 8, F, "ID3D12PipelineState.GetCachedBlob", blob)

# --- ID3D12Fence methods ---

proc getCompletedValue*(self: ID3D12Fence): uint64 =
  type F = proc(this: ID3D12Fence): uint64 {.stdcall.}
  callVtbl0(self, 8, F)

proc setEventOnCompletion*(self: ID3D12Fence, value: uint64, event: pointer) =
  type F = proc(this: ID3D12Fence, value: uint64, event: pointer): int32 {.stdcall.}
  callVtblErr(self, 9, F, "ID3D12Fence.SetEventOnCompletion", value, event)

proc signal*(self: ID3D12Fence, value: uint64) =
  type F = proc(this: ID3D12Fence, value: uint64): int32 {.stdcall.}
  callVtblErr(self, 10, F, "ID3D12Fence.Signal", value)

# --- ID3D12CommandAllocator methods ---

proc reset*(self: ID3D12CommandAllocator) =
  type F = proc(this: ID3D12CommandAllocator): int32 {.stdcall.}
  callVtbl0Err(self, 8, F, "ID3D12CommandAllocator.Reset")

# --- ID3D12Device methods ---

proc getNodeCount*(self: ID3D12Device): uint32 =
  type F = proc(this: ID3D12Device): uint32 {.stdcall.}
  callVtbl0(self, 7, F)

proc createCommandQueue*(self: ID3D12Device, desc: ptr D3D12_COMMAND_QUEUE_DESC, riid: pointer, command_queue: ptr pointer) =
  type F = proc(this: ID3D12Device, desc: ptr D3D12_COMMAND_QUEUE_DESC, riid: pointer, command_queue: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 8, F, "ID3D12Device.CreateCommandQueue", desc, riid, command_queue)

proc createCommandAllocator*(self: ID3D12Device, typeField: uint32, riid: pointer, command_allocator: ptr pointer) =
  type F = proc(this: ID3D12Device, typeField: uint32, riid: pointer, command_allocator: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 9, F, "ID3D12Device.CreateCommandAllocator", typeField, riid, command_allocator)

proc createGraphicsPipelineState*(self: ID3D12Device, desc: pointer, riid: pointer, pipeline_state: ptr pointer) =
  type F = proc(this: ID3D12Device, desc: pointer, riid: pointer, pipeline_state: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 10, F, "ID3D12Device.CreateGraphicsPipelineState", desc, riid, pipeline_state)

proc createComputePipelineState*(self: ID3D12Device, desc: pointer, riid: pointer, pipeline_state: ptr pointer) =
  type F = proc(this: ID3D12Device, desc: pointer, riid: pointer, pipeline_state: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 11, F, "ID3D12Device.CreateComputePipelineState", desc, riid, pipeline_state)

proc createCommandList*(self: ID3D12Device, node_mask: uint32, typeField: uint32, command_allocator: ID3D12CommandAllocator, initial_pipeline_state: ID3D12PipelineState, riid: pointer, command_list: ptr pointer) =
  type F = proc(this: ID3D12Device, node_mask: uint32, typeField: uint32, command_allocator: ID3D12CommandAllocator, initial_pipeline_state: ID3D12PipelineState, riid: pointer, command_list: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 12, F, "ID3D12Device.CreateCommandList", node_mask, typeField, command_allocator, initial_pipeline_state, riid, command_list)

proc checkFeatureSupport*(self: ID3D12Device, feature: uint32, feature_data: pointer, feature_data_size: uint32) =
  type F = proc(this: ID3D12Device, feature: uint32, feature_data: pointer, feature_data_size: uint32): int32 {.stdcall.}
  callVtblErr(self, 13, F, "ID3D12Device.CheckFeatureSupport", feature, feature_data, feature_data_size)

proc createDescriptorHeap*(self: ID3D12Device, desc: ptr D3D12_DESCRIPTOR_HEAP_DESC, riid: pointer, descriptor_heap: ptr pointer) =
  type F = proc(this: ID3D12Device, desc: ptr D3D12_DESCRIPTOR_HEAP_DESC, riid: pointer, descriptor_heap: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 14, F, "ID3D12Device.CreateDescriptorHeap", desc, riid, descriptor_heap)

proc getDescriptorHandleIncrementSize*(self: ID3D12Device, descriptor_heap_type: uint32): uint32 =
  type F = proc(this: ID3D12Device, descriptor_heap_type: uint32): uint32 {.stdcall.}
  callVtbl(self, 15, F, descriptor_heap_type)

proc createRootSignature*(self: ID3D12Device, node_mask: uint32, bytecode: pointer, bytecode_length: csize_t, riid: pointer, root_signature: ptr pointer) =
  type F = proc(this: ID3D12Device, node_mask: uint32, bytecode: pointer, bytecode_length: csize_t, riid: pointer, root_signature: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 16, F, "ID3D12Device.CreateRootSignature", node_mask, bytecode, bytecode_length, riid, root_signature)

proc createConstantBufferView*(self: ID3D12Device, desc: ptr D3D12_CONSTANT_BUFFER_VIEW_DESC, descriptor: D3D12_CPU_DESCRIPTOR_HANDLE) =
  type F = proc(this: ID3D12Device, desc: ptr D3D12_CONSTANT_BUFFER_VIEW_DESC, descriptor: D3D12_CPU_DESCRIPTOR_HANDLE): void {.stdcall.}
  callVtbl(self, 17, F, desc, descriptor)

proc createShaderResourceView*(self: ID3D12Device, resource: ID3D12Resource, desc: pointer, descriptor: D3D12_CPU_DESCRIPTOR_HANDLE) =
  type F = proc(this: ID3D12Device, resource: ID3D12Resource, desc: pointer, descriptor: D3D12_CPU_DESCRIPTOR_HANDLE): void {.stdcall.}
  callVtbl(self, 18, F, resource, desc, descriptor)

proc createUnorderedAccessView*(self: ID3D12Device, resource: ID3D12Resource, counter_resource: ID3D12Resource, desc: pointer, descriptor: D3D12_CPU_DESCRIPTOR_HANDLE) =
  type F = proc(this: ID3D12Device, resource: ID3D12Resource, counter_resource: ID3D12Resource, desc: pointer, descriptor: D3D12_CPU_DESCRIPTOR_HANDLE): void {.stdcall.}
  callVtbl(self, 19, F, resource, counter_resource, desc, descriptor)

proc createRenderTargetView*(self: ID3D12Device, resource: ID3D12Resource, desc: pointer, descriptor: D3D12_CPU_DESCRIPTOR_HANDLE) =
  type F = proc(this: ID3D12Device, resource: ID3D12Resource, desc: pointer, descriptor: D3D12_CPU_DESCRIPTOR_HANDLE): void {.stdcall.}
  callVtbl(self, 20, F, resource, desc, descriptor)

proc createDepthStencilView*(self: ID3D12Device, resource: ID3D12Resource, desc: pointer, descriptor: D3D12_CPU_DESCRIPTOR_HANDLE) =
  type F = proc(this: ID3D12Device, resource: ID3D12Resource, desc: pointer, descriptor: D3D12_CPU_DESCRIPTOR_HANDLE): void {.stdcall.}
  callVtbl(self, 21, F, resource, desc, descriptor)

proc createSampler*(self: ID3D12Device, desc: pointer, descriptor: D3D12_CPU_DESCRIPTOR_HANDLE) =
  type F = proc(this: ID3D12Device, desc: pointer, descriptor: D3D12_CPU_DESCRIPTOR_HANDLE): void {.stdcall.}
  callVtbl(self, 22, F, desc, descriptor)

proc copyDescriptors*(self: ID3D12Device, dst_descriptor_range_count: uint32, dst_descriptor_range_offsets: ptr D3D12_CPU_DESCRIPTOR_HANDLE, dst_descriptor_range_sizes: ptr uint32, src_descriptor_range_count: uint32, src_descriptor_range_offsets: ptr D3D12_CPU_DESCRIPTOR_HANDLE, src_descriptor_range_sizes: ptr uint32, descriptor_heap_type: uint32) =
  type F = proc(this: ID3D12Device, dst_descriptor_range_count: uint32, dst_descriptor_range_offsets: ptr D3D12_CPU_DESCRIPTOR_HANDLE, dst_descriptor_range_sizes: ptr uint32, src_descriptor_range_count: uint32, src_descriptor_range_offsets: ptr D3D12_CPU_DESCRIPTOR_HANDLE, src_descriptor_range_sizes: ptr uint32, descriptor_heap_type: uint32): void {.stdcall.}
  callVtbl(self, 23, F, dst_descriptor_range_count, dst_descriptor_range_offsets, dst_descriptor_range_sizes, src_descriptor_range_count, src_descriptor_range_offsets, src_descriptor_range_sizes, descriptor_heap_type)

proc copyDescriptorsSimple*(self: ID3D12Device, descriptor_count: uint32, dst_descriptor_range_offset: D3D12_CPU_DESCRIPTOR_HANDLE, src_descriptor_range_offset: D3D12_CPU_DESCRIPTOR_HANDLE, descriptor_heap_type: uint32) =
  type F = proc(this: ID3D12Device, descriptor_count: uint32, dst_descriptor_range_offset: D3D12_CPU_DESCRIPTOR_HANDLE, src_descriptor_range_offset: D3D12_CPU_DESCRIPTOR_HANDLE, descriptor_heap_type: uint32): void {.stdcall.}
  callVtbl(self, 24, F, descriptor_count, dst_descriptor_range_offset, src_descriptor_range_offset, descriptor_heap_type)

proc createCommittedResource*(self: ID3D12Device, heap_properties: ptr D3D12_HEAP_PROPERTIES, heap_flags: uint32, desc: pointer, initial_state: uint32, optimized_clear_value: pointer, riid: pointer, resource: ptr pointer) =
  type F = proc(this: ID3D12Device, heap_properties: ptr D3D12_HEAP_PROPERTIES, heap_flags: uint32, desc: pointer, initial_state: uint32, optimized_clear_value: pointer, riid: pointer, resource: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 27, F, "ID3D12Device.CreateCommittedResource", heap_properties, heap_flags, desc, initial_state, optimized_clear_value, riid, resource)

proc createHeap*(self: ID3D12Device, desc: pointer, riid: pointer, heap: ptr pointer) =
  type F = proc(this: ID3D12Device, desc: pointer, riid: pointer, heap: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 28, F, "ID3D12Device.CreateHeap", desc, riid, heap)

proc createPlacedResource*(self: ID3D12Device, heap: ID3D12Heap, heap_offset: uint64, desc: pointer, initial_state: uint32, optimized_clear_value: pointer, riid: pointer, resource: ptr pointer) =
  type F = proc(this: ID3D12Device, heap: ID3D12Heap, heap_offset: uint64, desc: pointer, initial_state: uint32, optimized_clear_value: pointer, riid: pointer, resource: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 29, F, "ID3D12Device.CreatePlacedResource", heap, heap_offset, desc, initial_state, optimized_clear_value, riid, resource)

proc createReservedResource*(self: ID3D12Device, desc: pointer, initial_state: uint32, optimized_clear_value: pointer, riid: pointer, resource: ptr pointer) =
  type F = proc(this: ID3D12Device, desc: pointer, initial_state: uint32, optimized_clear_value: pointer, riid: pointer, resource: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 30, F, "ID3D12Device.CreateReservedResource", desc, initial_state, optimized_clear_value, riid, resource)

proc createSharedHandle*(self: ID3D12Device, objectField: ID3D12DeviceChild, attributes: pointer, access: uint32, name: pointer, handle: ptr pointer) =
  type F = proc(this: ID3D12Device, objectField: ID3D12DeviceChild, attributes: pointer, access: uint32, name: pointer, handle: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 31, F, "ID3D12Device.CreateSharedHandle", objectField, attributes, access, name, handle)

proc openSharedHandle*(self: ID3D12Device, handle: pointer, riid: pointer, objectField: ptr pointer) =
  type F = proc(this: ID3D12Device, handle: pointer, riid: pointer, objectField: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 32, F, "ID3D12Device.OpenSharedHandle", handle, riid, objectField)

proc openSharedHandleByName*(self: ID3D12Device, name: pointer, access: uint32, handle: ptr pointer) =
  type F = proc(this: ID3D12Device, name: pointer, access: uint32, handle: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 33, F, "ID3D12Device.OpenSharedHandleByName", name, access, handle)

proc makeResident*(self: ID3D12Device, object_count: uint32, objects: ptr ID3D12Pageable) =
  type F = proc(this: ID3D12Device, object_count: uint32, objects: ptr ID3D12Pageable): int32 {.stdcall.}
  callVtblErr(self, 34, F, "ID3D12Device.MakeResident", object_count, objects)

proc evict*(self: ID3D12Device, object_count: uint32, objects: ptr ID3D12Pageable) =
  type F = proc(this: ID3D12Device, object_count: uint32, objects: ptr ID3D12Pageable): int32 {.stdcall.}
  callVtblErr(self, 35, F, "ID3D12Device.Evict", object_count, objects)

proc createFence*(self: ID3D12Device, initial_value: uint64, flags: uint32, riid: pointer, fence: ptr pointer) =
  type F = proc(this: ID3D12Device, initial_value: uint64, flags: uint32, riid: pointer, fence: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 36, F, "ID3D12Device.CreateFence", initial_value, flags, riid, fence)

proc getDeviceRemovedReason*(self: ID3D12Device) =
  type F = proc(this: ID3D12Device): int32 {.stdcall.}
  callVtbl0Err(self, 37, F, "ID3D12Device.GetDeviceRemovedReason")

proc getCopyableFootprints*(self: ID3D12Device, desc: pointer, first_sub_resource: uint32, sub_resource_count: uint32, base_offset: uint64, layouts: pointer, row_count: ptr uint32, row_size: ptr uint64, total_bytes: ptr uint64) =
  type F = proc(this: ID3D12Device, desc: pointer, first_sub_resource: uint32, sub_resource_count: uint32, base_offset: uint64, layouts: pointer, row_count: ptr uint32, row_size: ptr uint64, total_bytes: ptr uint64): void {.stdcall.}
  callVtbl(self, 38, F, desc, first_sub_resource, sub_resource_count, base_offset, layouts, row_count, row_size, total_bytes)

proc createQueryHeap*(self: ID3D12Device, desc: ptr D3D12_QUERY_HEAP_DESC, riid: pointer, heap: ptr pointer) =
  type F = proc(this: ID3D12Device, desc: ptr D3D12_QUERY_HEAP_DESC, riid: pointer, heap: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 39, F, "ID3D12Device.CreateQueryHeap", desc, riid, heap)

proc setStablePowerState*(self: ID3D12Device, enable: int32) =
  type F = proc(this: ID3D12Device, enable: int32): int32 {.stdcall.}
  callVtblErr(self, 40, F, "ID3D12Device.SetStablePowerState", enable)

proc createCommandSignature*(self: ID3D12Device, desc: pointer, root_signature: ID3D12RootSignature, riid: pointer, command_signature: ptr pointer) =
  type F = proc(this: ID3D12Device, desc: pointer, root_signature: ID3D12RootSignature, riid: pointer, command_signature: ptr pointer): int32 {.stdcall.}
  callVtblErr(self, 41, F, "ID3D12Device.CreateCommandSignature", desc, root_signature, riid, command_signature)

proc getResourceTiling*(self: ID3D12Device, resource: ID3D12Resource, total_tile_count: ptr uint32, packed_mip_info: ptr D3D12_PACKED_MIP_INFO, standard_tile_shape: ptr D3D12_TILE_SHAPE, sub_resource_tiling_count: ptr uint32, first_sub_resource_tiling: uint32, sub_resource_tilings: ptr D3D12_SUBRESOURCE_TILING) =
  type F = proc(this: ID3D12Device, resource: ID3D12Resource, total_tile_count: ptr uint32, packed_mip_info: ptr D3D12_PACKED_MIP_INFO, standard_tile_shape: ptr D3D12_TILE_SHAPE, sub_resource_tiling_count: ptr uint32, first_sub_resource_tiling: uint32, sub_resource_tilings: ptr D3D12_SUBRESOURCE_TILING): void {.stdcall.}
  callVtbl(self, 42, F, resource, total_tile_count, packed_mip_info, standard_tile_shape, sub_resource_tiling_count, first_sub_resource_tiling, sub_resource_tilings)

# --- ID3D12Debug methods ---

proc enableDebugLayer*(self: ID3D12Debug) =
  type F = proc(this: ID3D12Debug): void {.stdcall.}
  callVtbl0(self, 3, F)

# --- ID3D12RootSignatureDeserializer methods ---

# --- ID3D12ShaderReflectionType methods ---

proc isEqual*(self: ID3D12ShaderReflectionType, typeField: ID3D12ShaderReflectionType) =
  type F = proc(this: ID3D12ShaderReflectionType, typeField: ID3D12ShaderReflectionType): int32 {.stdcall.}
  callVtblErr(self, 4, F, "ID3D12ShaderReflectionType.IsEqual", typeField)

proc getNumInterfaces*(self: ID3D12ShaderReflectionType): uint32 =
  type F = proc(this: ID3D12ShaderReflectionType): uint32 {.stdcall.}
  callVtbl0(self, 7, F)

proc isOfType*(self: ID3D12ShaderReflectionType, typeField: ID3D12ShaderReflectionType) =
  type F = proc(this: ID3D12ShaderReflectionType, typeField: ID3D12ShaderReflectionType): int32 {.stdcall.}
  callVtblErr(self, 9, F, "ID3D12ShaderReflectionType.IsOfType", typeField)

proc implementsInterface*(self: ID3D12ShaderReflectionType, base: ID3D12ShaderReflectionType) =
  type F = proc(this: ID3D12ShaderReflectionType, base: ID3D12ShaderReflectionType): int32 {.stdcall.}
  callVtblErr(self, 10, F, "ID3D12ShaderReflectionType.ImplementsInterface", base)

# --- ID3D12ShaderReflectionVariable methods ---

proc getInterfaceSlot*(self: ID3D12ShaderReflectionVariable, index: uint32): uint32 =
  type F = proc(this: ID3D12ShaderReflectionVariable, index: uint32): uint32 {.stdcall.}
  callVtbl(self, 3, F, index)

# --- ID3D12ShaderReflection methods ---

proc getDesc*(self: ID3D12ShaderReflection, desc: pointer) =
  type F = proc(this: ID3D12ShaderReflection, desc: pointer): int32 {.stdcall.}
  callVtblErr(self, 3, F, "ID3D12ShaderReflection.GetDesc", desc)

proc getResourceBindingDesc*(self: ID3D12ShaderReflection, index: uint32, desc: pointer) =
  type F = proc(this: ID3D12ShaderReflection, index: uint32, desc: pointer): int32 {.stdcall.}
  callVtblErr(self, 6, F, "ID3D12ShaderReflection.GetResourceBindingDesc", index, desc)

proc getInputParameterDesc*(self: ID3D12ShaderReflection, index: uint32, desc: pointer) =
  type F = proc(this: ID3D12ShaderReflection, index: uint32, desc: pointer): int32 {.stdcall.}
  callVtblErr(self, 7, F, "ID3D12ShaderReflection.GetInputParameterDesc", index, desc)

proc getOutputParameterDesc*(self: ID3D12ShaderReflection, index: uint32, desc: pointer) =
  type F = proc(this: ID3D12ShaderReflection, index: uint32, desc: pointer): int32 {.stdcall.}
  callVtblErr(self, 8, F, "ID3D12ShaderReflection.GetOutputParameterDesc", index, desc)

proc getPatchConstantParameterDesc*(self: ID3D12ShaderReflection, index: uint32, desc: pointer) =
  type F = proc(this: ID3D12ShaderReflection, index: uint32, desc: pointer): int32 {.stdcall.}
  callVtblErr(self, 9, F, "ID3D12ShaderReflection.GetPatchConstantParameterDesc", index, desc)

proc getResourceBindingDescByName*(self: ID3D12ShaderReflection, name: pointer, desc: pointer) =
  type F = proc(this: ID3D12ShaderReflection, name: pointer, desc: pointer): int32 {.stdcall.}
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

proc getNumInterfaceSlots*(self: ID3D12ShaderReflection): uint32 =
  type F = proc(this: ID3D12ShaderReflection): uint32 {.stdcall.}
  callVtbl0(self, 18, F)

proc getMinFeatureLevel*(self: ID3D12ShaderReflection, level: ptr uint32) =
  type F = proc(this: ID3D12ShaderReflection, level: ptr uint32): int32 {.stdcall.}
  callVtblErr(self, 19, F, "ID3D12ShaderReflection.GetMinFeatureLevel", level)

proc getThreadGroupSize*(self: ID3D12ShaderReflection, sizex: ptr uint32, sizey: ptr uint32, sizez: ptr uint32): uint32 =
  type F = proc(this: ID3D12ShaderReflection, sizex: ptr uint32, sizey: ptr uint32, sizez: ptr uint32): uint32 {.stdcall.}
  callVtbl(self, 20, F, sizex, sizey, sizez)

proc getRequiresFlags*(self: ID3D12ShaderReflection): uint64 =
  type F = proc(this: ID3D12ShaderReflection): uint64 {.stdcall.}
  callVtbl0(self, 21, F)

# --- ID3D12FunctionReflection methods ---

proc getResourceBindingDesc*(self: ID3D12FunctionReflection, index: uint32, desc: pointer) =
  type F = proc(this: ID3D12FunctionReflection, index: uint32, desc: pointer): int32 {.stdcall.}
  callVtblErr(self, 3, F, "ID3D12FunctionReflection.GetResourceBindingDesc", index, desc)

proc getResourceBindingDescByName*(self: ID3D12FunctionReflection, name: pointer, desc: pointer) =
  type F = proc(this: ID3D12FunctionReflection, name: pointer, desc: pointer): int32 {.stdcall.}
  callVtblErr(self, 5, F, "ID3D12FunctionReflection.GetResourceBindingDescByName", name, desc)

# --- ID3D12LibraryReflection methods ---

proc getDesc*(self: ID3D12LibraryReflection, desc: pointer) =
  type F = proc(this: ID3D12LibraryReflection, desc: pointer): int32 {.stdcall.}
  callVtblErr(self, 3, F, "ID3D12LibraryReflection.GetDesc", desc)

