# Building

Cross-compiled on Linux (x86-64) for the Miyoo Mini Plus (SigmaStar SSD202D,
Cortex-A7, glibc 2.28).

1. **Toolchain:** steward-fu's `mini_toolchain` unpacked to `/opt/mini`
   (with its `prebuilt` folder at `/opt/prebuilt`).
2. **MI_GFX / MI_SYS headers and libraries:** `mini/` from
   [steward-fu/sdl2](https://github.com/steward-fu/sdl2); point `MI_SDK=` at it.
3. **LÖVE runtime:** a [panelattack-miyoo](https://github.com/snyderman3000/panelattack-miyoo)
   release zip (its `bin/` and `lib/` are reused as-is); point `RUNTIME_ZIP=` at it.
   Building LÖVE yourself is described in that repository's `docs/BUILDING.md`.
4. **Mr. Rescue source:** `git submodule update --init` (fills `upstream/`).
5. **Package:**

```sh
RUNTIME_ZIP=PanelAttack-miyoo-v0.9.3.zip MI_SDK=../sdl2/mini ./build_pkg.sh
```

Produces `dist/MrRescue-miyoo-vX.Y.Z.zip`. Needs `ffmpeg` (audio re-encoding)
and Python 3. `NO_AUDIO=1` skips the audio conversion.

## Testing on a PC

`mini2d/build.sh` also builds `libmini2d_host.so`, which renders into memory,
paces itself to 60 fps and can dump frames. With desktop LÖVE 11.5:

```sh
./build_game.sh
python3 tools/mkinput.py /tmp/in.txt 200 40 a wait a wait a   # scripted button presses
tools/run_host.sh 20 /tmp/in.txt 30                           # frames land in /tmp/pd
python3 tools/tile.py /tmp/shot.png 0 5 10                    # contact sheet at 2x
```
