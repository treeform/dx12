import 
  windy/platforms/win32/windefs,
  dx12

template ctxLog(msg: string) =
  echo "[D3D12Context] " & msg

# --- Helper types and context management ---
type
  D3D12Context* = object
    device*: ID3D12Device
    commandQueue*: ID3D12CommandQueue
    swapChain*: IDXGISwapChain3
    descriptorHeap*: ID3D12DescriptorHeap
    renderTargets*: array[FRAME_COUNT, ID3D12Resource]
    rtvHandles*: array[FRAME_COUNT, D3D12_CPU_DESCRIPTOR_HANDLE]
    commandAllocator*: ID3D12CommandAllocator
    commandList*: ID3D12GraphicsCommandList
    fence*: ID3D12Fence
    fenceValue*: UINT64
    fenceEvent*: HANDLE
    rtvDescriptorSize*: UINT
    currentFrame*: int
    viewport*: D3D12_VIEWPORT
    scissor*: D3D12_RECT

proc offsetHandle*(base: D3D12_CPU_DESCRIPTOR_HANDLE, descriptorSize: UINT, index: int): D3D12_CPU_DESCRIPTOR_HANDLE =
  result = base
  result.ptrValue = base.ptrValue + uint64(descriptorSize) * uint64(index)

proc initDevice*(ctx: var D3D12Context, hwnd: HWND, width, height: int) =
  loadNativeSymbols()
  ctxLog("Initializing D3D12 device for window " & $hwnd & " (" & $width & "x" & $height & ")")

  var factory = createDxgiFactory2(0)
  ctxLog("DXGI factory created")
  ctx.device = d3d12CreateDevice(nil, D3D_FEATURE_LEVEL_11_0)
  ctxLog("D3D12 device created")

  var queueDesc: D3D12_COMMAND_QUEUE_DESC
  queueDesc.Type = D3D12_COMMAND_LIST_TYPE_DIRECT
  queueDesc.Priority = D3D12_COMMAND_QUEUE_PRIORITY_NORMAL
  queueDesc.Flags = D3D12_COMMAND_QUEUE_FLAG_NONE
  queueDesc.NodeMask = 0
  ctx.commandQueue = ctx.device.createCommandQueue(addr queueDesc)
  ctxLog("Command queue created")

  var swapDesc: DXGI_SWAP_CHAIN_DESC1
  swapDesc.Width = UINT(width)
  swapDesc.Height = UINT(height)
  swapDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM
  swapDesc.Stereo = 0
  swapDesc.SampleDesc = DXGI_SAMPLE_DESC(Count: 1, Quality: 0)
  swapDesc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT
  swapDesc.BufferCount = FRAME_COUNT
  swapDesc.Scaling = DXGI_SCALING_STRETCH
  swapDesc.SwapEffect = DXGI_SWAP_EFFECT_FLIP_DISCARD
  swapDesc.AlphaMode = DXGI_ALPHA_MODE_UNSPECIFIED
  swapDesc.Flags = 0

  var swapChain1 = factory.createSwapChainForHwnd(
    cast[pointer](ctx.commandQueue),
    hwnd,
    addr swapDesc,
    nil,
    nil
  )
  factory.makeWindowAssociation(hwnd, DXGI_MWA_NO_ALT_ENTER)
  ctxLog("Swap chain created and window association configured")

  ctx.swapChain = swapChain1.upgradeToSwapChain3()
  swapChain1.release()
  factory.release()

  var heapDesc: D3D12_DESCRIPTOR_HEAP_DESC
  heapDesc.typ = D3D12_DESCRIPTOR_HEAP_TYPE_RTV
  heapDesc.NumDescriptors = FRAME_COUNT
  heapDesc.Flags = D3D12_DESCRIPTOR_HEAP_FLAG_NONE
  heapDesc.NodeMask = 0
  ctx.descriptorHeap = ctx.device.createDescriptorHeap(addr heapDesc)
  if ctx.descriptorHeap == nil:
    raise newException(Exception, "Descriptor heap creation returned nil")
  ctxLog("RTV descriptor heap ready")

  ctx.rtvDescriptorSize = ctx.device.getDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_RTV)
  let baseHandle = ctx.descriptorHeap.getCPUDescriptorHandleForHeapStart()

  for i in 0..<FRAME_COUNT:
    ctx.rtvHandles[i] = offsetHandle(baseHandle, ctx.rtvDescriptorSize, i)
    ctx.renderTargets[i] = ctx.swapChain.getBuffer(UINT(i))
    ctx.device.createRenderTargetView(ctx.renderTargets[i], nil, ctx.rtvHandles[i])
  ctxLog("Render target views created for all back buffers")

  ctx.commandAllocator = ctx.device.createCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT)
  ctx.commandList = ctx.device.createCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, ctx.commandAllocator, nil)
  ctx.commandList.close()
  ctxLog("Command allocator and command list initialized")

  ctx.fence = ctx.device.createFence(0, D3D12_FENCE_FLAG_NONE)
  ctx.fenceValue = 1
  ctx.fenceEvent = CreateEventW(nil, 0, 0, nil)
  if ctx.fenceEvent == 0:
    raise newException(Exception, "Failed to create fence event")
  ctxLog("Fence and synchronization primitives established")

  ctx.viewport = D3D12_VIEWPORT(
    TopLeftX: 0.0, TopLeftY: 0.0,
    Width: FLOAT(width), Height: FLOAT(height),
    MinDepth: 0.0, MaxDepth: 1.0
  )
  ctx.scissor = D3D12_RECT(left: 0, top: 0, right: int32(width), bottom: int32(height))
  ctxLog("Viewport and scissor rectangle configured")

proc waitForGpu*(ctx: var D3D12Context) =
  let fenceToWait = ctx.fenceValue
  ctxLog("Waiting for GPU fence value " & $fenceToWait)
  ctx.commandQueue.signal(ctx.fence, fenceToWait)
  inc ctx.fenceValue
  if ctx.fence.getCompletedValue() < fenceToWait:
    ctx.fence.setEventOnCompletion(fenceToWait, ctx.fenceEvent)
    discard WaitForSingleObject(ctx.fenceEvent, WAIT_INFINITE)
  ctxLog("GPU synchronization complete for fence " & $fenceToWait)

proc moveToNextFrame*(ctx: var D3D12Context) =
  ctxLog("Moving to next frame from " & $ctx.currentFrame)
  let currentFence = ctx.fenceValue
  ctx.commandQueue.signal(ctx.fence, currentFence)
  inc ctx.fenceValue
  if ctx.fence.getCompletedValue() < currentFence:
    ctx.fence.setEventOnCompletion(currentFence, ctx.fenceEvent)
    discard WaitForSingleObject(ctx.fenceEvent, WAIT_INFINITE)
  ctx.currentFrame = (ctx.currentFrame + 1) mod FRAME_COUNT
  ctxLog("Now rendering frame index " & $ctx.currentFrame)

proc recordCommandList*(ctx: var D3D12Context, color: array[4, FLOAT]) =
  ctxLog("Recording command list for frame " & $ctx.currentFrame)
  ctx.commandAllocator.reset()
  ctx.commandList.reset(ctx.commandAllocator, nil)

  var barrier = D3D12_RESOURCE_BARRIER(
    typ: D3D12_RESOURCE_BARRIER_TYPE_TRANSITION,
    Flags: D3D12_RESOURCE_BARRIER_FLAG_NONE,
    Transition: D3D12_RESOURCE_TRANSITION_BARRIER(
      pResource: ctx.renderTargets[ctx.currentFrame],
      Subresource: D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
      StateBefore: D3D12_RESOURCE_STATE_PRESENT,
      StateAfter: D3D12_RESOURCE_STATE_RENDER_TARGET
    )
  )
  ctx.commandList.resourceBarrier(1, addr barrier)
  ctx.commandList.rsSetViewports(1, addr ctx.viewport)
  ctx.commandList.rsSetScissorRects(1, addr ctx.scissor)
  ctx.commandList.omSetRenderTargets(1, addr ctx.rtvHandles[ctx.currentFrame], 1, nil)
  ctx.commandList.clearRenderTargetView(ctx.rtvHandles[ctx.currentFrame], unsafeAddr color[0], 0, nil)

  barrier.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET
  barrier.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT
  ctx.commandList.resourceBarrier(1, addr barrier)

  ctx.commandList.close()
  ctxLog("Command list recorded and closed")

proc executeFrame*(ctx: var D3D12Context) =
  ctxLog("Executing frame " & $ctx.currentFrame)
  var commandListIface = cast[ID3D12CommandList](ctx.commandList)
  ctx.commandQueue.executeCommandLists(1, addr commandListIface)
  ctx.swapChain.present(1, 0)
  ctx.moveToNextFrame()
  ctxLog("Frame execution submitted")

proc cleanup*(ctx: var D3D12Context) =
  ctxLog("Cleaning up D3D12 context")
  ctx.waitForGpu()
  for i in 0..<FRAME_COUNT:
    if ctx.renderTargets[i] != nil:
      ctx.renderTargets[i].release()
      ctx.renderTargets[i] = nil
  if ctx.commandAllocator != nil:
    ctx.commandAllocator.release()
    ctx.commandAllocator = nil
  if ctx.commandList != nil:
    ctx.commandList.release()
    ctx.commandList = nil
  if ctx.commandQueue != nil:
    ctx.commandQueue.release()
    ctx.commandQueue = nil
  if ctx.descriptorHeap != nil:
    ctx.descriptorHeap.release()
    ctx.descriptorHeap = nil
  if ctx.swapChain != nil:
    ctx.swapChain.release()
    ctx.swapChain = nil
  if ctx.device != nil:
    ctx.device.release()
    ctx.device = nil
  if ctx.fence != nil:
    ctx.fence.release()
    ctx.fence = nil
  if ctx.fenceEvent != 0:
    discard CloseHandle(ctx.fenceEvent)
    ctx.fenceEvent = 0
  ctxLog("D3D12 context cleanup complete")
