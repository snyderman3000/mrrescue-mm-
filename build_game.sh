#!/bin/sh
# Rebuild game/ from the Mr. Rescue source + the Miyoo overlay.
set -e
cd "$(dirname "$0")"
SRC="${MR_SRC:-upstream}"
[ -f "$SRC/main.lua" ] || { echo "Mr. Rescue source not found in $SRC (git submodule update --init)"; exit 1; }
rm -rf game
mkdir game
cp -r "$SRC"/*.lua "$SRC/data" "$SRC/maps" "$SRC/LICENSE" "$SRC/README.md" game/
mv game/main.lua game/mr_main.lua
rm -f game/conf.lua
cp -r overlay/* game/
