# GrimDark

A free, non-commercial fan project: a 45-player co-op PvE tactical shooter set in Warhammer 40,000, played from the side of a Chaos-corrupted traitor Guard platoon. Bots fill any empty slots.

Warhammer 40,000 is a trademark of Games Workshop. This project is unofficial and not endorsed by Games Workshop.

- [Game Design Document](docs/GDD.md)

## Project layout

```
docs/      Design documents
game/      Godot 4 project
  data/      Balance tables (JSON) taken from the GDD
  scenes/    Scenes (.tscn, always saved as text)
  scripts/   GDScript
  tests/     Headless tests
  assets/    Art and audio (Git LFS)
tools/     Scripts for running tests
```

## Getting started

1. Install [Godot 4.7](https://godotengine.org/download) (standard build, not .NET).
2. Open `game/project.godot` in the Godot editor and press F5.
3. In the greybox test range: WASD to move, Shift to sprint, C to crouch, Z to go prone, Space to jump, Esc to free the mouse.

## Running tests

```bash
GODOT=/path/to/godot tools/run_tests.sh
```

Tests also run on every push through GitHub Actions.

## Balance data

All balance numbers live in `game/data/*.json`, not in code (GDD 20.2). Change values there; the `GameData` autoload loads them at startup.
