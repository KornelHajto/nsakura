# nsakura

Terminal cherry blossom screensaver written in Nim using the illwill library.
It draws a static ASCII tree and animates falling leaves with a lightweight
physics loop.

## Features
- Fullscreen, double-buffered rendering (no flicker)
- ASCII tree loaded from `art.txt` and scaled to the terminal
- Wind gusts and fluttering leaf motion
- Optional sway for attached leaves
- Adjustable speed for debugging

## Build
```sh
nimble install illwill
nim c -r src/nsakura.nim
```

## Usage
```sh
nim c -r src/nsakura.nim --speed=1
```

Optional flags:
- `--speed=<float>`: scales fall speed (default 1.0)
- `--sway=<float>`: attached leaf sway amplitude (0.0 to 1.0, default 0.0)

Keys:
- `Q` or `Esc`: quit

## Notes
- `art.txt` controls the tree shape. Replace it to change the look.
- For best results, run in a wide fullscreen terminal.

## License
MIT
