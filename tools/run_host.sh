#!/bin/sh
# Run the port on a PC with the mini2d host stub (no window), dumping frames.
# usage: run_host.sh <seconds> [input-script] [dump-every] [keep-home]
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T=${1:-30}
[ -z "$4" ] && rm -rf /tmp/mrhome
rm -rf /tmp/pd; mkdir -p /tmp/mrhome /tmp/pd
export HOME=/tmp/mrhome XDG_DATA_HOME=/tmp/mrhome/.data MR_NOSOUND=${MR_NOSOUND-1}
[ -z "$MR_NOSOUND" ] && unset MR_NOSOUND
export M2D_LIB="$ROOT/mini2d/libmini2d_host.so" M2D_DUMP=/tmp/pd M2D_DUMP_EVERY=${3:-60}
[ -n "$2" ] && export M2D_INPUT="$2"
LOVE="${LOVE:-love}"
timeout $T "$LOVE" "${GAME:-$ROOT/game}" > /tmp/mr.log 2>&1
echo "rc=$? frames=$(ls /tmp/pd | wc -l)"
grep -n "Error\|error\|traceback" /tmp/mr.log | head -20
