import std/math
import std/os
import std/random

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

    let lengthJitter = rand(0.6..0.8)
    let angleJitter = rand(0.25..0.6)

    drawBranch(nextX, nextY, length * lengthJitter, angle - angleJitter, depth - 1)
    drawBranch(nextX, nextY, length * lengthJitter, angle + angleJitter, depth - 1)

  randomize()
  let startX = float(terminalWidth() div 2)
  let startY = float(terminalHeight() - 2)
  drawBranch(startX, startY, float(terminalHeight()) * 0.35, PI / 2, 7)

  while true:
    let key = getKey()
    if key in {Key.Q, Key.Escape}:
      break

    screen.copyFrom(staticTreeBuffer)
    screen.display()
    sleep(16)

  showCursor()
  illwillDeinit()
