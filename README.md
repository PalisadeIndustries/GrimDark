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
art_source/ Source files from other tools (e.g. GEM engine models), kept for re-conversion
tools/     Scripts for running tests and converting assets
```

## Getting started

1. Install [Godot 4.7](https://godotengine.org/download) (standard build, not .NET), and get the project with
   `git clone` or GitHub's **Download ZIP**. Extract the ZIP to its own folder, not inside an existing copy.
2. Open `game/project.godot` in the Godot editor and press F5. This opens the **test range**.
3. F1 shows the controls. WASD move, Shift sprint, C crouch, Z prone, Space jump, LMB fire, RMB aim, R reload,
   B fire mode, 1-7 or E switch weapon, V vent plasma, I infinite ammo, F interact, Esc free the mouse.

### The test range (`scenes/test_range/test_range.tscn`)

- **Weapons range:** targets for every armour class at 25 m (cultist, Guardsman, Veteran, Sister, and Sentinel,
  Chimera and Leman Russ armour plates), plus Guardsmen and Veterans at 50-200 m. Every hit is logged top left with
  the damage maths (penetration vs armour, armour reduction, headshot, range falloff). Seven test weapons, all
  using the lasgun model for now. The ammo crate at the firing line refills ammo.
- **Animation yard** (to the right): the traitor guard in each procedural pose (press F on a soldier to change it),
  a soldier walking or running a loop, and the **Animation Station**, which plays any humanoid animation dropped
  into `game/assets/animations/` (see the README there).

Screenshots are in [`docs/mockups/`](docs/mockups/).

## Running tests

```bash
GODOT=/path/to/godot tools/run_tests.sh
```

Tests also run on every push through GitHub Actions.

## Balance data

All balance numbers live in `game/data/*.json`, not in code (GDD 20.2). Change values there; the `GameData` autoload loads them at startup.

## Converting GEM (Men of War) models

`tools/gem_to_gltf.py` converts a GEM model (`.mdl` skeleton, `.ply` mesh, `.mtl` materials and `.dds` textures) into a `.glb` that Godot imports with its skeleton, skin weights and textures:

```bash
python3 tools/gem_to_gltf.py art_source/gem/traitor_guard_1/traitor_guard_1.mdl \
    -o game/assets/characters/traitor_guard/traitor_guard_1.glb --textures art_source/gem/textures
```

It needs Python 3 and [Pillow](https://pypi.org/project/pillow/) for `.dds` textures. Normal maps are converted from GEM's DirectX two-channel format, and specular maps become roughness maps. LOD meshes and `.anm` animations aren't converted yet.

Binary art (`.glb`, `.png`, `.dds`, `.ply`) is stored directly in git, so a plain clone or GitHub's "Download ZIP" includes everything.
