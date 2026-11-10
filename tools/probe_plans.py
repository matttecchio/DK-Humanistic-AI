#!/usr/bin/env python3
"""Was there a better way? Tries thousands of short plans from before a death: walk, jump, maybe jump again, from every moment.
probe_plans.py BATCH GAME [frames before death to start, default 160] [--ladder]   writes runs/BATCH/plans_GAME.txt"""
import glob, os, subprocess, sys, tempfile
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, f"{H}/tools")
import stats

DIR = {"0": "up", "1": "left", "2": "right", "nil": "-"}
STICK = {0: "stand", 1: "left", 2: "right", 4: "climb"}


def main():
    args = [a for a in sys.argv[1:] if a not in ("--ladder", "--native", "--steer")]
    batch, gid = args[0], int(args[1])
    back = int(args[2]) if len(args) > 2 else 160
    stats.use_starts(batch)
    g = next(x for x in stats.load(batch, inputs=True) if x["id"] == gid)
    target = f"{H}/runs/{batch}/plans_{gid}.txt"
    with tempfile.TemporaryDirectory() as td:
        rp = f"{td}/r.txt"
        open(rp, "w").write(f"{g['id']}\n{g['start']}\n{g['inp']}\n")
        env = dict(os.environ, REPLAY=rp, OUT=target, F0=str(g["frames"] - back), DEATH=str(g["frames"]))
        if "--steer" in sys.argv:
            env["PSTEER"] = "1"
        if "--ladder" in sys.argv:
            env["PLADDER"] = "1"
        if "--native" in sys.argv:   # on dkx: the same game, input for input, and much faster
            env.update(DKX_ROMS=os.path.expanduser("~/dkx-build/DK-x86-AI/dkx/roms"), DKH_STATES=f"{H}/native/starts")
            subprocess.run([f"{H}/native/build/dkh", f"{H}/lua/probe_plans.lua"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=3000)
        else:
            subprocess.run([f"{H}/tools/mame.sh", "-nothrottle", "-samplerate", "1000", "-state_directory", f"{H}/starts",
                            "-autoboot_script", f"{H}/lua/probe_plans.lua"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=3000)
    for path in glob.glob(f"{H}/starts/**/plan{gid}*", recursive=True) + glob.glob(f"{H}/native/starts/plan{gid}*"):
        os.remove(path)
    report(target, g)


def report(path, g):
    rows = [l.split() for l in open(path)]
    check = [r for r in rows if r[0] == "check"]
    rows = [r for r in rows if r[0] != "check"]
    print(f"game {g['id']}: recording dies at {check[0][1] if check else '?'} (recorded {g['frames']}), {len(rows)} plans tried, {sum(r[5] == 'ok' for r in rows)} survive")
    groups = {}
    for at, a, w, j1, j2, res, *_ in rows:
        if res == "ok":
            groups.setdefault((int(a), int(w), DIR[j1], DIR[j2]), []).append(g["frames"] - int(at))
    # Most forgiving first: the plans that work from the most different moments.
    for (a, w, j1, j2), ats in sorted(groups.items(), key=lambda kv: -len(kv[1]))[:14]:
        print(f"  {STICK[a]:5s} {w:3d} then jump {j1:5s} then {j2:5s}: works starting {max(ats)}..{min(ats)} frames before death ({len(ats)} moments)")
    last = {}
    for at, a, w, j1, j2, res, *_ in rows:
        if res == "ok":
            k = DIR[j1]
            last[k] = min(last.get(k, 9999), g["frames"] - int(at) - 0 + 0)
    print("  latest start of any surviving plan, by first jump:", last)


if __name__ == "__main__":
    main()
