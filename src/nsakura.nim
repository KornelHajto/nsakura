import std/math
import std/os

import illwill

when isMainModule:
  illwillInit(fullscreen = true)
  hideCursor()
  var screen = newTerminalBuffer(terminalWidth(), terminalHeight())
  var staticTreeBuffer = newTerminalBuffer(terminalWidth(), terminalHeight())

  proc drawBranch(x, y, length, angle: float, depth: int) =
    if depth <= 0 or length <= 0:
      return

    let nextX = x + cos(angle) * length
    let nextY = y - sin(angle) * length

    let steps = max(1, int(length))
    for i in 0..steps:
      let t = float(i) / float(steps)
      let px = x + (nextX - x) * t
      let py = y + (nextY - y) * t
      let ix = int(round(px))
      let iy = int(round(py))
      var ch = '|'
      if abs(nextX - x) > abs(nextY - y):
        if (nextY - y) < 0:
          ch = '/'
        else:
          ch = '\\'

      if ix >= 0 and iy >= 0 and ix < terminalWidth() and iy < terminalHeight():
        staticTreeBuffer.write(ix, iy, $ch)

    drawBranch(nextX, nextY, length * 0.7, angle - 0.4, depth - 1)
    drawBranch(nextX, nextY, length * 0.7, angle + 0.4, depth - 1)

  while true:
    let key = getKey()
    if key in {Key.Q, Key.Escape}:
      break

    screen.clear()
    screen.display()
    sleep(16)

  showCursor()
  illwillDeinit()
