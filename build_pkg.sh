#!/bin/sh
# Assemble Roms/PORTS/Games/MrRescue (OnionOS Ports) and zip it.
# The LÖVE 11.5 runtime and its libraries are the ones built for the Panel
# Attack port: RUNTIME_ZIP points at a panelattack-miyoo release zip
# (see docs/BUILDING.md).
set -e
cd "$(dirname "$0")"
VERSION="${1:-$(cat VERSION)}"
TOOLCHAIN="${TOOLCHAIN:-/opt/mini}"
RUNTIME_ZIP="${RUNTIME_ZIP:?set RUNTIME_ZIP to a panelattack-miyoo release zip}"
./build_game.sh
./mini2d/build.sh
./dspfix/build.sh
OUT=pkg/Roms/PORTS/Games/MrRescue
rm -rf pkg rt && mkdir -p $OUT rt
unzip -q "$RUNTIME_ZIP" 'Roms/PORTS/Games/PanelAttack/bin/*' 'Roms/PORTS/Games/PanelAttack/lib/*' \
  'Roms/PORTS/Games/PanelAttack/licenses/THIRD_PARTY_NOTICES.md' -d rt
cp -r rt/Roms/PORTS/Games/PanelAttack/bin rt/Roms/PORTS/Games/PanelAttack/lib $OUT/
cp mini2d/libmini2d.so dspfix/libdspfix.so $OUT/lib/
rm -rf rt
cp -r game $OUT/game
NO_AUDIO=${NO_AUDIO:-}
[ -z "$NO_AUDIO" ] && python3 tools/convert_audio.py $OUT/game/data/sfx
cp pkgsrc/launch.sh pkgsrc/alsoft.conf pkgsrc/README.txt $OUT/
echo "$VERSION" > $OUT/VERSION
mkdir -p $OUT/licenses
cp LICENSE $OUT/licenses/LICENSE-port.txt
cp THIRD_PARTY_NOTICES.md $OUT/licenses/
chmod +x $OUT/launch.sh $OUT/bin/love
mkdir -p pkg/Roms/PORTS/Shortcuts/Platform pkg/Roms/PORTS/Imgs
# both names: OnionOS's "Import ports" prefers the .notfound copy and turns it into .port
cp pkgsrc/MrRescue.port "pkg/Roms/PORTS/Shortcuts/Platform/Mr. Rescue.port"
cp pkgsrc/MrRescue.port "pkg/Roms/PORTS/Shortcuts/Platform/Mr. Rescue.notfound"
cp docs/cover.png "pkg/Roms/PORTS/Imgs/Mr. Rescue.png"
ZIP="MrRescue-miyoo-v$VERSION.zip"
mkdir -p dist
(cd pkg && rm -f "../dist/$ZIP" && zip -qr9 "../dist/$ZIP" Roms)
du -sh $OUT; ls -la "dist/$ZIP"
