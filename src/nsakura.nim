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
    let targetWidth = max(1, terminalWidth())
    let targetHeight = max(1, terminalHeight() - 1)
    let stepX = max(1.0, float(artWidth) / float(targetWidth))
    let stepY = max(1.0, float(artHeight) / float(targetHeight))
    let scaledWidth = int(ceil(float(artWidth) / stepX))
    let scaledHeight = int(ceil(float(artHeight) / stepY))
    let offsetX = max(0, (terminalWidth() - scaledWidth) div 2)
    let offsetY = max(0, terminalHeight() - scaledHeight - 1)

    var sy = 0
    while sy < artHeight:
      let line = lines[sy]
      var sx = 0
      while sx < line.len:
        let ch = line[sx]
        if ch != ' ':
          let bx = offsetX + int(float(sx) / stepX)
          let by = offsetY + int(float(sy) / stepY)
          if bx >= 0 and by >= 0 and bx < terminalWidth() and by < terminalHeight():
            staticTreeBuffer.write(bx, by, $ch)
            if float(sy) < float(artHeight) * 0.45 and rand(0.0..1.0) < 0.06:
              leaves.add(Leaf(x: float(bx), y: float(by), state: Attached, ch: "*", color: fgMagenta))
        sx = int(float(sx) + stepX)
      sy = int(float(sy) + stepY)

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
