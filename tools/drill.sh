#!/bin/bash
# Scenario drills for Matt: tools/drill.sh [PACK] [ATTEMPTS]. Opens MAME in a window at normal speed; each scenario starts 3.5 s before
# one of his deaths, holds still for a 1.5 s countdown, then it's yours: arrows to walk and climb, Q / E / W jump left / right / straight. Each attempt ends when
# Mario dies or gets 2 s past where he died; the same moment loads again for the next attempt, then the next scenario. Your inputs go
# to runs/drill_attempts.txt (nothing is learned from them until you've confirmed which were right). Esc quits.
H=/Users/matt/dkong-human
PACK=$(cd "$(dirname "${1:-$H/runs/drill1.txt}")" && pwd)/$(basename "${1:-$H/runs/drill1.txt}"); ATT=${2:-3}
cd "$H/runs"
DRILL="$PACK" OUT="$H/runs/drill_attempts.txt" ATTEMPTS="$ATT" exec /Users/matt/mame-0264-lto/dkong dkong -rompath /Users/matt/.mame/roms \
  -window -nomaximize -resolution 672x768 -video opengl -sound none -samplerate 1000 -skip_gameinfo \
  -state_directory "$H/starts" -cfg_directory "$H/runs/.cfg" -nvram_directory "$H/runs/.nvram" -snapshot_directory "$H/runs/.snap" \
  -autoboot_script "$H/lua/drill.lua"
