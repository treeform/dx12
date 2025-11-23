import math
import windy
import windy/platforms/win32/windefs
import dx12, dx12/context

const
  width = 1280
  height = 800

when isMainModule:
  let window = newWindow("DirectX 12 Color Cycle", ivec2(width.int32, height.int32))

  var hwnd: HWND = window.getHWND()
  if hwnd == 0:
    raise newException(Exception, "Failed to acquire HWND from window")

  var ctx: D3D12Context
  ctx.initDevice(hwnd, width, height)

  try:
    var timeAcc = 0.0
    while not window.closeRequested:
      pollEvents()
      timeAcc += 0.016

      let r = (sin(timeAcc * 0.6) * 0.5 + 0.5).FLOAT
      let g = (sin(timeAcc * 0.6 + 2.094) * 0.5 + 0.5).FLOAT
      let b = (sin(timeAcc * 0.6 + 4.188) * 0.5 + 0.5).FLOAT
      let color = [r, g, b, 1.0.FLOAT]

      ctx.recordCommandList(color)
      ctx.executeFrame()
  finally:
    ctx.cleanup()

