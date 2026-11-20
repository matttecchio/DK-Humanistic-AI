#!/usr/bin/env python3
"""Tests a change on the very moments it's meant for, not just on random games.
scenario_test.py BATCH --level N [--label TEXT | --ids 1,2,3] [--back 60,90,120,150,180] [--trials 4] [--set k=v ...]
For each chosen death in BATCH, the recorded game is played back to a few seconds before the death, and from there he
plays it himself (with the change, if --set is given), several times, each with its own human timing. Prints how many
of those he gets through the board. Run it with and without --set to compare: the same takeovers and the same timings."""
import argparse, collections, glob, json, os, subprocess, sys, tempfile

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def run_rows(rows, level, sets=(), workers=8, inputs=False, full=False, prefix=None):
    """rows: (game_id, takeover_frame, trial, inputs[, "a w j1 j2 h"]). Returns each row's outcome, in order."""
    tmp = tempfile.mkdtemp(dir=os.environ.get("CLAUDE_JOB_DIR") and os.environ["CLAUDE_JOB_DIR"] + "/tmp")
    scen = f"{tmp}/scen.txt"
    with open(scen, "w") as f:
        for r in rows:
            f.write(f"{r[0]} {r[1]} {r[2]} {r[3]}" + (f" {r[4]}" if len(r) > 4 and r[4] else "") + "\n")
    params = f"{H}/lua/params.lua"
    if sets:
        params = f"{tmp}/params.lua"
        lines = [f'local p = dofile("{H}/lua/params.lua")'] + [f"for _, l in pairs(p.levels or {{}}) do l.{kv.split('=', 1)[0]} = nil end\np.{kv.split('=', 1)[0]} = {kv.split('=', 1)[1]}" for kv in sets] + ["return p"]
        open(params, "w").write("\n".join(lines) + "\n")
    procs = []
    for w in range(workers):
        env = dict(os.environ, DKH=H, MODE="scenario", SCEN=scen, START_ID=str(w), STEP=str(workers), LAST=str(len(rows) - 1), OUT=f"{tmp}/out_{w}.jsonl",
                   PARAMS=params, WORKER=str(w), LEVEL=str(level), START_PREFIX=prefix or ("s" if level == 1 else f"l{level}_"),
                   DKX_ROMS=os.path.expanduser("~/dkx-build/DK-x86-AI/dkx/roms"), DKH_STATES=f"{H}/native/starts")
        if not inputs:
            env["NO_INPUTS"] = "1"
        if os.environ.get("SHOW_GRID"):   # show the takeovers on the website's live boards (Matt: viewers watch)
            env["GRID"] = os.environ["SHOW_GRID"]
        procs.append(subprocess.Popen([f"{H}/native/build/dkh", f"{H}/lua/agent.lua"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL))
    for p in procs:
        p.wait()
    try:
        import stats; stats.count_replays(len(rows))   # (the dashboard's replay tally)
    except Exception:
        pass
    res = [None] * len(rows)
    for p in glob.glob(f"{tmp}/out_*.jsonl"):
        for l in open(p):
            o = json.loads(l)
            res[o["id"]] = o if full else ((o["outcome"], o["inp"], o["frames"]) if inputs else o["outcome"])   # full: the whole record
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("batch")
    ap.add_argument("--level", type=int, required=True)
    ap.add_argument("--label", help="deaths with this label in runs/BATCH/grind_labels.txt")
    ap.add_argument("--ids", help="comma-separated game ids")
    ap.add_argument("--non-fire", action="store_true", help="every death not from a fireball")
    ap.add_argument("--back", default="60,90,120,150,180")
    ap.add_argument("--trials", type=int, default=4)
    ap.add_argument("--set", action="append", default=[])
    ap.add_argument("--workers", type=int, default=8)
    ap.add_argument("--show", action="store_true", help="list each death's result")
    ap.add_argument("--groups", help="file of 'game_id group words' lines: results per group (and only those games)")
    a = ap.parse_args()
    games = {json.loads(l)["id"]: json.loads(l) for p in glob.glob(f"{H}/runs/{a.batch}/games_*.jsonl") for l in open(p)}
    groups = {}
    if a.groups:
        groups = {int(l.split(None, 1)[0]): l.split(None, 1)[1].strip() for l in open(a.groups) if l.strip() and int(l.split(None, 1)[0]) in games}
    if a.groups and not a.ids:
        ids = list(groups)
    elif a.ids:
        ids = [int(x) for x in a.ids.split(",")]
    elif a.label:
        ids = [int(l.split(None, 1)[0]) for l in open(f"{H}/runs/{a.batch}/grind_labels.txt") if a.label in l]
    else:
        ids = [i for i, g in games.items() if g["outcome"] == "died" and (not a.non_fire or g["cause"] != "fireball")]
    rows = []
    for i in ids:
        g = games[i]
        for b in [int(x) for x in a.back.split(",")]:
            if g["frames"] - b > 30:
                for t in range(a.trials):
                    rows.append((i, g["frames"] - b, t, g["inp"]))
    tmp = tempfile.mkdtemp(dir=os.environ.get("CLAUDE_JOB_DIR", None) and os.environ["CLAUDE_JOB_DIR"] + "/tmp")
    scen = f"{tmp}/scen.txt"
    with open(scen, "w") as f:
        for r in rows:
            f.write(f"{r[0]} {r[1]} {r[2]} {r[3]}\n")
    params = f"{H}/lua/params.lua"
    if a.set:
        params = f"{tmp}/params.lua"
        lines = [f'local p = dofile("{H}/lua/params.lua")'] + [f"for _, l in pairs(p.levels or {{}}) do l.{kv.split('=', 1)[0]} = nil end\np.{kv.split('=', 1)[0]} = {kv.split('=', 1)[1]}" for kv in a.set] + ["return p"]
        open(params, "w").write("\n".join(lines) + "\n")
    procs = []
    for w in range(a.workers):
        env = dict(os.environ, DKH=H, MODE="scenario", SCEN=scen, START_ID=str(w), STEP=str(a.workers), LAST=str(len(rows) - 1), OUT=f"{tmp}/out_{w}.jsonl",
                   PARAMS=params, WORKER=str(w), LEVEL=str(a.level), START_PREFIX="s" if a.level == 1 else f"l{a.level}_", NO_INPUTS="1",
                   DKX_ROMS=os.path.expanduser("~/dkx-build/DK-x86-AI/dkx/roms"), DKH_STATES=f"{H}/native/starts")
        procs.append(subprocess.Popen([f"{H}/native/build/dkh", f"{H}/lua/agent.lua"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL))
    for p in procs:
        p.wait()
    out = [json.loads(l) for p in glob.glob(f"{tmp}/out_*.jsonl") for l in open(p)]
    per = collections.defaultdict(lambda: [0, 0])
    for o in out:
        r = rows[o["id"]]
        per[r[0]][1] += 1
        if o["outcome"] == "clear":
            per[r[0]][0] += 1
    won = sum(v[0] for v in per.values()); tot = sum(v[1] for v in per.values())
    fixed = sum(1 for v in per.values() if v[0] * 2 > v[1])
    print(f"{len(ids)} deaths, {tot} takeovers: cleared {won} ({100 * won / max(tot, 1):.1f}%); deaths he mostly gets through now: {fixed}  [{' '.join(a.set) or 'as is'}]")
    if groups:
        by = collections.defaultdict(lambda: [0, 0, 0])
        for i in ids:
            k = groups.get(i, "?")
            by[k][0] += per[i][0]; by[k][1] += per[i][1]; by[k][2] += 1
        for k, v in sorted(by.items(), key=lambda kv: -kv[1][2]):
            print(f"  {k}: {v[2]} deaths, cleared {v[0]}/{v[1]} ({100 * v[0] / max(v[1], 1):.0f}%)")
    if a.show:
        for i in ids:
            print(f"  {i}: {per[i][0]}/{per[i][1]}")


if __name__ == "__main__":
    main()
