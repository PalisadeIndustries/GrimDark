#!/usr/bin/env bash
# Imports the Godot project and runs the headless tests.
# Usage: tools/run_tests.sh   (set GODOT to the Godot binary if it isn't on PATH as "godot")
set -euo pipefail
GODOT="${GODOT:-godot}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$GODOT" --headless --path "$ROOT/game" --import
"$GODOT" --headless --path "$ROOT/game" -s res://tests/run_tests.gd
