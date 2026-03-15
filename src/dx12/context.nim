import windy/platforms/win32/windefs
import extras, dxgicommon, dxgiformat, dxgi, dxgi1_2, dxgi1_4, dxgi1_5, d3d12_api

# --- Helper types and context management ---
type
  D3D12Context* = object
    device*: ID3D12Device
    commandQueue*: ID3D12CommandQueue
    swapChain*: IDXGISwapChain3
    allowTearing*: bool
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

proc refreshRenderTargets(ctx: var D3D12Context) =
  ## Refreshes the RTVs from the current swap-chain buffers.
  let baseHandle = ctx.descriptorHeap.getCPUDescriptorHandleForHeapStart()
  for i in 0 ..< FRAME_COUNT:
    ctx.rtvHandles[i] = offsetHandle(baseHandle, ctx.rtvDescriptorSize, i)
    ctx.renderTargets[i] = ctx.swapChain.getBuffer(UINT(i))
    ctx.device.createRenderTargetView(
      ctx.renderTargets[i],
      nil,
      ctx.rtvHandles[i]
    )

proc updateViewport(ctx: var D3D12Context, width, height: int) =
  ## Updates the viewport and scissor to match the swap-chain size.
  ctx.viewport = D3D12_VIEWPORT(
    TopLeftX: 0.0,
    TopLeftY: 0.0,
    Width: FLOAT(width),
    Height: FLOAT(height),
    MinDepth: 0.0,
    MaxDepth: 1.0
  )
  ctx.scissor = D3D12_RECT(
    left: 0,
    top: 0,
    right: int32(width),
    bottom: int32(height)
  )

proc initDevice*(ctx: var D3D12Context, hwnd: HWND, width, height: int) =
  loadNativeSymbols()

  var factory = createDxgiFactory2(0)
  var factory5: IDXGIFactory5
  try:
    factory5 = factory.upgradeToFactory5()
    var allowTearing: BOOL32
    factory5.checkFeatureSupport(
      DXGI_FEATURE_PRESENT_ALLOW_TEARING,
      addr allowTearing,
      UINT(sizeof(allowTearing))
    )
    ctx.allowTearing = allowTearing != 0
  except:
    ctx.allowTearing = false
  finally:
    if factory5 != nil:
      release(factory5)

  ctx.device = d3d12CreateDevice(nil, D3D_FEATURE_LEVEL_11_0)

  var queueDesc: D3D12_COMMAND_QUEUE_DESC
  queueDesc.typ = D3D12_COMMAND_LIST_TYPE_DIRECT
  queueDesc.Priority = int32(D3D12_COMMAND_QUEUE_PRIORITY_NORMAL)
  queueDesc.Flags = D3D12_COMMAND_QUEUE_FLAG_NONE
  queueDesc.NodeMask = 0
  ctx.commandQueue = ctx.device.createCommandQueue(addr queueDesc)

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
  swapDesc.Flags =
    if ctx.allowTearing:
      DXGI_SWAP_CHAIN_FLAG_ALLOW_TEARING
    else:
      0

  var swapChain1 = factory.createSwapChainForHwnd(
    cast[pointer](ctx.commandQueue),
    hwnd,
    addr swapDesc,
    nil,
    nil
  )
  factory.makeWindowAssociation(hwnd, DXGI_MWA_NO_ALT_ENTER)

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

  ctx.rtvDescriptorSize = ctx.device.getDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_RTV)
  ctx.refreshRenderTargets()

  ctx.commandAllocator = ctx.device.createCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT)
  ctx.commandList = ctx.device.createCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, ctx.commandAllocator, nil)
  ctx.commandList.close()

  ctx.fence = ctx.device.createFence(0, D3D12_FENCE_FLAG_NONE)
  ctx.fenceValue = 1
  ctx.fenceEvent = CreateEventW(nil, 0, 0, nil)
  if ctx.fenceEvent == 0:
    raise newException(Exception, "Failed to create fence event")

  ctx.currentFrame = int(ctx.swapChain.getCurrentBackBufferIndex())
  ctx.updateViewport(width, height)

proc waitForGpu*(ctx: var D3D12Context) =
  ## Waits until the GPU has finished all queued work.
  let fenceToWait = ctx.fenceValue
  ctx.commandQueue.signal(ctx.fence, fenceToWait)
  inc ctx.fenceValue
  if ctx.fence.getCompletedValue() < fenceToWait:
    ctx.fence.setEventOnCompletion(fenceToWait, cast[pointer](ctx.fenceEvent))
    discard WaitForSingleObject(ctx.fenceEvent, WAIT_INFINITE)

proc moveToNextFrame*(ctx: var D3D12Context) =
  let currentFence = ctx.fenceValue
  ctx.commandQueue.signal(ctx.fence, currentFence)
  inc ctx.fenceValue
  if ctx.fence.getCompletedValue() < currentFence:
    ctx.fence.setEventOnCompletion(currentFence, cast[pointer](ctx.fenceEvent))
    discard WaitForSingleObject(ctx.fenceEvent, WAIT_INFINITE)
  ctx.currentFrame = int(ctx.swapChain.getCurrentBackBufferIndex())

proc recordCommandList*(ctx: var D3D12Context, color: array[4, FLOAT]) =
  ctx.commandAllocator.reset()
  ctx.commandList.reset(ctx.commandAllocator, nil)

  var barrier = D3D12_RESOURCE_BARRIER(
    typ: D3D12_RESOURCE_BARRIER_TYPE_TRANSITION,
    Flags: D3D12_RESOURCE_BARRIER_FLAG_NONE,
    data: D3D12_RESOURCE_BARRIER_union(
      Transition: D3D12_RESOURCE_TRANSITION_BARRIER(
        pResource: ctx.renderTargets[ctx.currentFrame],
        Subresource: D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
        StateBefore: D3D12_RESOURCE_STATE_PRESENT,
        StateAfter: D3D12_RESOURCE_STATE_RENDER_TARGET
      )
    )
  )
  ctx.commandList.resourceBarrier(1, addr barrier)
  ctx.commandList.rsSetViewports(1, addr ctx.viewport)
  ctx.commandList.rsSetScissorRects(1, addr ctx.scissor)
  ctx.commandList.omSetRenderTargets(1, addr ctx.rtvHandles[ctx.currentFrame], 1, nil)
  ctx.commandList.clearRenderTargetView(ctx.rtvHandles[ctx.currentFrame], unsafeAddr color[0], 0, nil)

  barrier.data.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET
  barrier.data.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT
  ctx.commandList.resourceBarrier(1, addr barrier)

  ctx.commandList.close()

proc executeFrame*(ctx: var D3D12Context, vsync = true) =
  ## Presents the current frame using the window vsync policy.
  var commandListIface = cast[ID3D12CommandList](ctx.commandList)
  ctx.commandQueue.executeCommandLists(1, addr commandListIface)
  let flags =
    if not vsync and ctx.allowTearing:
      DXGI_PRESENT_ALLOW_TEARING
    else:
      0
  ctx.swapChain.present(if vsync: 1 else: 0, flags)
  ctx.moveToNextFrame()

proc resize*(ctx: var D3D12Context, width, height: int) =
  ## Resizes the swap-chain buffers and refreshes dependent state.
  let
    safeWidth = max(1, width)
    safeHeight = max(1, height)
  ctx.waitForGpu()
  for i in 0 ..< FRAME_COUNT:
    if ctx.renderTargets[i] != nil:
      ctx.renderTargets[i].release()
      ctx.renderTargets[i] = nil
  ctx.swapChain.resizeBuffers(
    FRAME_COUNT,
    UINT(safeWidth),
    UINT(safeHeight),
    DXGI_FORMAT_R8G8B8A8_UNORM,
    if ctx.allowTearing:
      DXGI_SWAP_CHAIN_FLAG_ALLOW_TEARING
    else:
      0
  )
  ctx.currentFrame = int(ctx.swapChain.getCurrentBackBufferIndex())
  ctx.refreshRenderTargets()
  ctx.updateViewport(safeWidth, safeHeight)

proc cleanup*(ctx: var D3D12Context) =
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
