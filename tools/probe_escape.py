#!/usr/bin/env python3
"""Was a death avoidable? Replays a game to just before it, then tries every simple move at every moment from a save state.
probe_escape.py BATCH GAME [frames before death to start, default 120]"""
import glob, json, os, subprocess, sys, tempfile
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, f"{H}/tools")
import stats


def main():
    batch, gid = sys.argv[1], int(sys.argv[2])
    back = int(sys.argv[3]) if len(sys.argv) > 3 else 120
    g = next(x for x in stats.load(batch, inputs=True) if x["id"] == gid)
    with tempfile.TemporaryDirectory() as td:
        rp, out = f"{td}/r.txt", f"{td}/out.txt"
        open(rp, "w").write(f"{g['id']}\n{g['start']}\n{g['inp']}\n")
        env = dict(os.environ, REPLAY=rp, OUT=out, F0=str(g["frames"] - back), DEATH=str(g["frames"]), HOME_DKH=H)
        subprocess.run([f"{H}/tools/mame.sh", "-nothrottle", "-samplerate", "1000", "-state_directory", f"{H}/starts",
                        "-autoboot_script", f"{H}/lua/probe.lua"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=600)
        rows = [l.split() for l in open(out)]
    for path in glob.glob(f"{H}/starts/**/probe{gid}*", recursive=True):
        os.remove(path)
    if os.getenv("PROBE_RAW"):
        for r in rows:
            print(*r)
    names = {0: "stand still", 1: "walk left", 2: "walk right", 16: "jump straight", 17: "jump left", 18: "jump right"}
    check = [r for r in rows if r[0] == "check"]
    print(f"check: recorded inputs die at frame {check[0][1] if check else '?'}, the game recorded {g['frames']}")
    rows = [r for r in rows if r[0] not in ("check", "lost")]
    print(f"game {gid}: tried {len(rows)} moves, starting {back} frames before death")
    for act, nm in names.items():
        ok = [int(r[1]) for r in rows if int(r[0]) == act and r[2] == "ok"]
        print(f"  {nm:14s} survives if started at frames before death: {[g['frames'] - x for x in ok] or 'never'}")


if __name__ == "__main__":
    main()
