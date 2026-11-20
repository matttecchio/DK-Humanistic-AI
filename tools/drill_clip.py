#!/usr/bin/env python3
"""drill_clip.py PACK ATTEMPTS_FILE ID ATTEMPT OUT.mp4: a clip of one of Matt's drill attempts (his game replayed to the moment, then his
inputs), 2 s of lead-in, for him to confirm before anything is learned from it."""
import os, subprocess, sys, tempfile
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
pack, att_file, gid, att, out = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4]), sys.argv[5]
sc = next(l.split() for l in open(pack) if l.split()[0] == gid)
start, frm, inp = int(sc[1]), int(sc[2]), sc[4]
a = next(l.split() for l in open(att_file) if l.split()[0] == gid and int(l.split()[2]) == att)
mine = a[5]
full = inp[:frm] + mine
FONT = "/System/Library/Fonts/Supplemental/Arial.ttf"
with tempfile.TemporaryDirectory() as td:
    rp, raw = f"{td}/r.txt", f"{td}/c.raw"
    open(rp, "w").write(f"{gid}\n{start}\n{full}\n")
    env = dict(os.environ, REPLAY=rp, OUT_RAW=raw, FROM=str(max(1, frm - 120)), AFTER="60", START_PREFIX="l5_")
    subprocess.run([f"{H}/tools/mame.sh", "-nothrottle", "-samplerate", "1000", "-state_directory", f"{H}/starts", "-autoboot_script", f"{H}/lua/record.lua"],
                   env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=300)
    title = f"Your attempt {att} (game {gid}): {a[3]}"
    vf = ",".join(["transpose=2", "scale=672:768:flags=neighbor", "pad=672:820:0:52:color=0x101218",
                   f"drawtext=fontfile={FONT}:text='{title}':x=(w-tw)/2:y=14:fontsize=24:fontcolor=white"])
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-f", "rawvideo", "-pix_fmt", "bgra", "-s", "256x224", "-r", "60", "-i", raw,
                    "-vf", vf, "-c:v", "libx264", "-preset", "veryfast", "-crf", "18", "-pix_fmt", "yuv420p", out], check=True)
print(out)
