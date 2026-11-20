#!/usr/bin/env python3
"""pair_video.py A B OUTPUT.mp4 FILE: for each game in FILE ("ID caption" per line), the death in batch A (4 s either side), then
the same game in batch B over the same frames (2026-11-14: the human-limited player's death, then the all-knowing mode getting
through the same moment). Clips are made by replaying the recorded inputs in MAME (lua/record.lua), as death_video.py does."""
import os, subprocess, sys, tempfile
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, f"{H}/tools")
import stats

FONT = "/System/Library/Fonts/Supplemental/Arial.ttf"
BEFORE, AFTER = 240, 240


def clip(g, frm, n, top, sub, cap, out, td):
    rp, raw = f"{td}/r.txt", f"{td}/c.raw"
    open(rp, "w").write(f"{g['id']}\n{g['start']}\n{g['inp']}\n")
    env = dict(os.environ, REPLAY=rp, OUT_RAW=raw, FROM=str(max(1, frm)), AFTER=str(n))
    subprocess.run([f"{H}/tools/mame.sh", "-nothrottle", "-samplerate", "1000", "-state_directory", f"{H}/starts",
                    "-autoboot_script", f"{H}/lua/record.lua"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=300)
    esc = lambda t: t.replace(":", "\\:").replace("|", "\\|").replace("'", "")
    text = lambda s, y, size: f"drawtext=fontfile={FONT}:text='{esc(s)}':x=(w-tw)/2:y={y}:fontsize={size}:fontcolor=white"
    vf = ",".join(["transpose=2", "scale=672:768:flags=neighbor", "pad=672:872:0:104:color=0x101218", text(top, 8, 28), text(sub, 44, 18), text(cap, 76, 18)])
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-f", "rawvideo", "-pix_fmt", "bgra", "-s", "256x224", "-r", "60", "-i", raw,
                    "-vf", vf, "-c:v", "libx264", "-preset", "veryfast", "-crf", "18", "-pix_fmt", "yuv420p", out], check=True)
    os.remove(raw)


def main():
    a, b, target, spec = sys.argv[1:5]
    stats.use_starts(a)
    ga = {g["id"]: g for g in stats.load(a, inputs=True)}
    gb = {g["id"]: g for g in stats.load(b, inputs=True)}
    rows = [(int(l.split(None, 1)[0]), l.split(None, 1)[1].strip()) for l in open(spec) if l.strip()]
    with tempfile.TemporaryDirectory() as td:
        clips = []
        for i, (gid, cap) in enumerate(rows, 1):
            d = ga[gid]; frm = d["frames"] - BEFORE
            ca, cb = f"{td}/{i}a.mp4", f"{td}/{i}b.mp4"
            clip(d, frm, AFTER, f"{i} of {len(rows)}: as a human would play", f"Game {gid}  |  dies: {d['cause']}, {d['doing']}, girder {d['floor']}", cap, ca, td)
            clip(gb[gid], frm, AFTER, f"{i} of {len(rows)}: knowing the dice", f"Game {gid}  |  taken over 2 s before that death by the all-knowing mode", "every press checked on a copy of the game first", cb, td)
            clips += [ca, cb]
            print(i, gid, flush=True)
        lst = f"{td}/list.txt"
        open(lst, "w").write("".join(f"file '{c}'\n" for c in clips))
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-f", "concat", "-safe", "0", "-i", lst, "-c", "copy", "-movflags", "+faststart", target], check=True)
    print(target)


if __name__ == "__main__":
    main()
