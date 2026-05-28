# nsakura

Terminal cherry blossom screensaver written in Nim using the illwill library.
It draws a static ASCII tree and animates falling leaves with a lightweight
physics loop.





https://github.com/user-attachments/assets/037eda2f-fef5-406f-b034-e6d4dd09360d






## Features
- Fullscreen, double-buffered rendering (no flicker)
- ASCII tree loaded from the built-in art and scaled to the terminal
- Wind gusts and fluttering leaf motion
- Optional sway for attached leaves
- Adjustable speed for debugging

## Installation

### macOS & Linux (Homebrew)
The easiest way to install `nsakura` on macOS or Linux is via Homebrew:
```sh
brew install KornelHajto/tap/nsakura
```

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
- `--art=<path>`: use a custom art file instead of the built-in tree

Keys:
- `Q` or `Esc`: quit

## Notes
- Tree art is embedded by default. Use `--art=<path>` to load a custom file.
- For best results, run in a wide fullscreen terminal.

## License
MIT
