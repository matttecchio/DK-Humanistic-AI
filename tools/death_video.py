#!/usr/bin/env python3
"""Makes a video of deaths from a batch: death_video.py BATCH OUTPUT.mp4 [how many] [seed]
Picks them in proportion to what's killing him most. Each clip shows the last seconds before the death.
death_video.py BATCH OUTPUT.mp4 --review FILE shows the games listed in FILE ("ID caption" per line), 4 seconds either side of each death."""
import collections, json, os, random, subprocess, sys, tempfile
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, f"{H}/tools")
import stats

BEFORE, AFTER = 600, 150       # frames shown before the death and after it
FONT = "/System/Library/Fonts/Supplemental/Arial.ttf"


def pick(deaths, n, seed):
    """Takes turns across kinds of death, most common first, up to n."""
    rng = random.Random(seed)
    kinds = collections.defaultdict(list)
    for g in deaths:
        kinds[(g["cause"], g["doing"], g["floor"])].append(g)
    order = sorted(kinds, key=lambda k: -len(kinds[k]))
    share = {k: max(1, round(n * len(kinds[k]) / len(deaths))) for k in order}
    out = []
    for k in order:
        out += rng.sample(kinds[k], min(share[k], len(kinds[k])))
    return out[:n]


def main():
    batch, target = sys.argv[1], sys.argv[2]
    review = sys.argv[4] if len(sys.argv) > 4 and sys.argv[3] == "--review" else None
    n = int(sys.argv[3]) if len(sys.argv) > 3 and not review else 10
    seed = int(sys.argv[4]) if len(sys.argv) > 4 and not review else 1
    stats.use_starts(batch)
    deaths = [g for g in stats.load(batch, inputs=True) if g["outcome"] == "died"]
    before, after, captions = BEFORE, AFTER, {}
    if review:
        before, after = 240, 240
        captions = {int(l.split(None, 1)[0]): l.split(None, 1)[1].strip() for l in open(review) if l.strip()}
        by_id = {g["id"]: g for g in deaths}
        chosen = [by_id[i] for i in captions]
    else:
        chosen = pick(deaths, n, seed)
    with tempfile.TemporaryDirectory() as td:
        clips = []
        for i, g in enumerate(chosen, 1):
            rp, raw, clip = f"{td}/r{i}.txt", f"{td}/{i}.raw", f"{td}/{i}.mp4"
            open(rp, "w").write(f"{g['id']}\n{g['start']}\n{g['inp']}\n")
            env = dict(os.environ, REPLAY=rp, OUT_RAW=raw, FROM=str(max(1, g["frames"] - before)), AFTER=str(after))
            subprocess.run([f"{H}/tools/mame.sh", "-nothrottle", "-samplerate", "1000", "-state_directory", f"{H}/starts",
                            "-autoboot_script", f"{H}/lua/record.lua"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=300)
            where = "on a ladder" if g["doing"].startswith("ladder") else ("in mid-air" if g["doing"].startswith("jump") else "on the ground")
            top = f"Death {i} of {len(chosen)}"
            sub = f"Game {g['id']}  |  {g['cause'].replace('fall_or_unknown', 'fall')}, {where}, floor {g['floor']}  |  {g['score']:,} pts"
            text = lambda s, y, size: f"drawtext=fontfile={FONT}:text='{s}':x=(w-tw)/2:y={y}:fontsize={size}:fontcolor=white"
            esc = lambda t: t.replace(":", "\\:").replace("|", "\\|").replace("'", "")
            caption = [text(esc(captions[g["id"]]), 76, 18)] if g["id"] in captions else []
            vf = ",".join(["transpose=2", "scale=672:768:flags=neighbor", f"pad=672:{872 if caption else 840}:0:{104 if caption else 72}:color=0x101218",
                           text(top, 8, 28), text(esc(sub), 44, 18)] + caption)
            subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-f", "rawvideo", "-pix_fmt", "bgra", "-s", "256x224", "-r", "60", "-i", raw,
                            "-vf", vf, "-c:v", "libx264", "-preset", "veryfast", "-crf", "18", "-pix_fmt", "yuv420p", clip], check=True)
            os.remove(raw)
            clips.append(clip)
            print(i, g["id"], g["cause"], g["doing"], "floor", g["floor"], flush=True)
        lst = f"{td}/list.txt"
        open(lst, "w").write("".join(f"file '{c}'\n" for c in clips))
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-f", "concat", "-safe", "0", "-i", lst, "-c", "copy", "-movflags", "+faststart", target], check=True)
    print(target)


if __name__ == "__main__":
    main()
