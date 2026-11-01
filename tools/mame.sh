#!/bin/bash
# headless MAME 0.264 (LTO build), side files kept inside the project; the caller passes its own -autoboot_script
H=/Users/matt/dkong-human
export SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy
cd "$H/runs"
exec /Users/matt/mame-0264-lto/dkong dkong -rompath /Users/matt/.mame/roms -skip_gameinfo -video none -sound none -cfg_directory "$H/runs/.cfg" -nvram_directory "$H/runs/.nvram" -snapshot_directory "$H/runs/.snap" -diff_directory "$H/runs/.diff" -comment_directory "$H/runs/.com" "$@"
