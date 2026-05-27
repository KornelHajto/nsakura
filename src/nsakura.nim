import std/math
import std/os
import std/parseopt
import std/random
import std/strutils
import std/times

import illwill

when isMainModule:
  illwillInit(fullscreen = true)
  hideCursor()
  var dynamicBuffer = newTerminalBuffer(terminalWidth(), terminalHeight())
  var staticTreeBuffer = newTerminalBuffer(terminalWidth(), terminalHeight())

  type LeafState = enum
    Attached,
    Falling,
    Resting

  type Leaf = object
    x: float
    y: float
    dx: float
    phase: float
    state: LeafState
    ch: string
    color: ForegroundColor

  var leaves: seq[Leaf] = @[]
  var groundY = float(terminalHeight() - 1)
  var speedFactor = 1.0
  var swayAmplitude = 0.0
  var exportPath = "build/screenshots/frame.txt"
  var exportRequested = false

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

    var lowestRow = 0

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
            if by > lowestRow:
              lowestRow = by
            if float(sy) < float(artHeight) * 0.45 and rand(0.0..1.0) < 0.06:
              leaves.add(Leaf(x: float(bx), y: float(by), dx: 0.0, phase: rand(0.0..(PI * 2)), state: Attached, ch: "*", color: fgMagenta))
        sx = int(float(sx) + stepX)
      sy = int(float(sy) + stepY)

    groundY = min(float(terminalHeight() - 1), float(lowestRow))

  randomize()
  for kind, key, val in getOpt():
    if kind == cmdLongOption and key == "speed":
      try:
        speedFactor = clamp(parseFloat(val), 0.1, 5.0)
      except ValueError:
        speedFactor = 1.0
    if kind == cmdLongOption and key == "sway":
      try:
        swayAmplitude = clamp(parseFloat(val), 0.0, 1.0)
      except ValueError:
        swayAmplitude = 0.0
    if kind == cmdLongOption and key == "export":
      if val.len > 0:
        exportPath = val
  loadTreeArt("art.txt")

  proc exportFrame(path: string, tb: TerminalBuffer) =
    if path.len == 0:
      return

    let dir = splitFile(path).dir
    if dir.len > 0:
      createDir(dir)

    let w = width(tb)
    let h = height(tb)
    var output = newStringOfCap((w + 1) * h)
    for y in 0..<h:
      for x in 0..<w:
        output.add($tb[x, y].ch)
      if y < h - 1:
        output.add('\n')
    writeFile(path, output)

  proc updatePhysics() =
    for i in 0..<leaves.len:
      if leaves[i].state == Falling:
        leaves[i].y += 0.1 * speedFactor
        leaves[i].phase += 0.08
        leaves[i].x += leaves[i].dx + sin(leaves[i].phase) * 0.2
        if leaves[i].y >= groundY:
          leaves[i].y = groundY
          leaves[i].state = Resting
      elif leaves[i].state == Attached and swayAmplitude > 0.0:
        leaves[i].phase += 0.02

  proc drawLeaves() =
    for leaf in leaves:
      var drawX = leaf.x
      if leaf.state == Attached and swayAmplitude > 0.0:
        drawX += sin(leaf.phase) * swayAmplitude

      let ix = int(round(drawX))
      let iy = int(round(leaf.y))
      if ix >= 0 and iy >= 0 and ix < terminalWidth() and iy < terminalHeight():
        dynamicBuffer.write(ix, iy, leaf.ch, leaf.color)

  var lastGust = epochTime()
  var gustInterval = rand(2.0..5.0)

  while true:
    let key = getKey()
    if key in {Key.Q, Key.Escape}:
      exportFrame(exportPath, dynamicBuffer)
      break
    if key in {Key.S, Key.ShiftS}:
      exportRequested = true

    let now = epochTime()
    if now - lastGust >= gustInterval:
      lastGust = now
      gustInterval = rand(2.0..5.0)
      for i in 0..<leaves.len:
        if leaves[i].state == Attached and rand(0.0..1.0) < 0.08:
          leaves[i].state = Falling
          leaves[i].dx = rand(-0.35..0.35)
          leaves[i].phase = rand(0.0..(PI * 2))

    updatePhysics()
    dynamicBuffer.copyFrom(staticTreeBuffer)
    drawLeaves()
    dynamicBuffer.display()
    if exportRequested:
      exportFrame(exportPath, dynamicBuffer)
      exportRequested = false
    sleep(16)

  showCursor()
  illwillDeinit()
