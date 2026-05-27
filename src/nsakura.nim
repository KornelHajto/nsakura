import std/os

import illwill

when isMainModule:
  illwillInit(fullscreen = true)
  hideCursor()
  var screen = newTerminalBuffer(terminalWidth(), terminalHeight())
  var staticTreeBuffer = newTerminalBuffer(terminalWidth(), terminalHeight())

  while true:
    let key = getKey()
    if key in {Key.Q, Key.Escape}:
      break

    screen.clear()
    screen.display()
    sleep(16)

  showCursor()
  illwillDeinit()
