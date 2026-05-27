import std/os
import std/random
import std/strutils

import illwill

when isMainModule:
  illwillInit(fullscreen = true)
  hideCursor()
  var screen = newTerminalBuffer(terminalWidth(), terminalHeight())
  var staticTreeBuffer = newTerminalBuffer(terminalWidth(), terminalHeight())

  type LeafState = enum
    Attached,
    Falling,
    Resting

  type Leaf = object
    x: float
    y: float
    state: LeafState
    ch: string
    color: ForegroundColor

  var leaves: seq[Leaf] = @[]

  proc loadTreeArt(path: string) =
    if not fileExists(path):
      return

    staticTreeBuffer.clear()
    leaves.setLen(0)

    let lines = readFile(path).splitLines()
    var artWidth = 0
    for line in lines:
      if line.len > artWidth:
        artWidth = line.len

    let artHeight = lines.len
    let offsetX = max(0, (terminalWidth() - artWidth) div 2)
    let offsetY = max(0, terminalHeight() - artHeight - 1)

    for y, line in lines:
      for x, ch in line:
        if ch != ' ':
          let bx = offsetX + x
          let by = offsetY + y
          if bx >= 0 and by >= 0 and bx < terminalWidth() and by < terminalHeight():
            staticTreeBuffer.write(bx, by, $ch)
            if float(y) < float(artHeight) * 0.45 and rand(0.0..1.0) < 0.08:
              leaves.add(Leaf(x: float(bx), y: float(by), state: Attached, ch: "*", color: fgMagenta))

  randomize()
  loadTreeArt("art.txt")

  while true:
    let key = getKey()
    if key in {Key.Q, Key.Escape}:
      break

    screen.copyFrom(staticTreeBuffer)
    screen.display()
    sleep(16)

  showCursor()
  illwillDeinit()
