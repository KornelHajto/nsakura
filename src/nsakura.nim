import std/os

import illwill

when isMainModule:
  illwillInit(fullscreen = true)
  hideCursor()
  var screen = newTerminalBuffer(terminalWidth(), terminalHeight())

  while true:
    screen.clear()
    screen.display()
    sleep(16)
