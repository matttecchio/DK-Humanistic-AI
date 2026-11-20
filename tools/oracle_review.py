#!/usr/bin/env python3
"""oracle_review.py BATCH STEP [--level 5]: what the all-knowing mode can teach the human-limited one (Matt, 2026-11-14: "use those
learnings to reinforce the previous human learning one"). Results in runs/BATCH/oracle_review/.
  seal     for each death in BATCH: the latest moment the all-knowing mode (SEARCH) can still take over and clear the board
           (tries 150, 120, 100, 80, 65, 50, 40, 30, 20, 12 frames before the death). seal.json: {id: frames before}
  robust   at each barrel death's sealing moment: his own move and each of the standard moves, played by him (human-limited)
           with new dice: the board exactly as it is, the random number 0x6018 set to another value (DICE; presses that change
           nothing on screen don't change the dice, tested). A move that clears with most new dice is a real human answer; one
           that only clears with this game's dice is luck. robust.json
  predict  at each barrel death's sealing moment: what his planner predicted for the barrel that killed him (PREDLOG), against
           where it really went (RNGLOG): which prediction errors cost deaths. predict.json"""
import argparse, collections, glob, json, os, random, subprocess, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import stats
from scenario_test import run_rows, H
from strict_solve import MOVES, ms

lv = lambda y: 6 if y < 95 else 5 if y < 125 else 4 if y < 160 else 3 if y < 195 else 2 if y < 225 else 1


def out_dir(batch):
    d = f"{H}/runs/{batch}/oracle_review"; os.makedirs(d, exist_ok=True); return d


def seal(a, deaths):
    os.environ["SEARCH"] = "1"
    backs = [150, 120, 100, 80, 65, 50, 40, 30, 20, 12]
    res = {}
    for b in backs:
        rows = [(g["id"], g["frames"] - b, 0, g["inp"]) for g in deaths if g["frames"] > b + 5]
        out = run_rows(rows, a.level)
        for r, o in zip(rows, out):
            if o == "clear": res[r[0]] = b   # the smallest one that clears wins, as backs shrink
        n = sum(1 for r, o in zip(rows, out) if o == "clear")
        print(f"{b} frames before: {n} of {len(rows)} cleared", flush=True)
    os.environ.pop("SEARCH")
    json.dump(res, open(f"{out_dir(a.batch)}/seal.json", "w"))
    by = collections.Counter(res.values())
    print("sealing point (latest takeover that still clears), frames before the death:", dict(sorted(by.items())))
    print("never escapable from 150 frames:", sum(1 for g in deaths if g["id"] not in res))


def robust(a, deaths):
    os.environ.pop("SEARCH", None); os.environ["DICE"] = "1"
    sl = json.load(open(f"{out_dir(a.batch)}/seal.json"))
    bd = [g for g in deaths if "barrel" in g["cause"] and str(g["id"]) in sl]
    # at each sealing moment: his own play and every standard move, trial 0 with the game's own dice, trials 1..k with new dice
    rows = []
    for g in bd:
        t = g["frames"] - sl[str(g["id"])]
        for k in range(a.k + 1):
            rows.append((g["id"], t, k, g["inp"], None))
            for m in MOVES: rows.append((g["id"], t, k, g["inp"], ms(m)))
    print(f"{len(bd)} barrel deaths, {len(rows)} takeovers", flush=True)
    out = run_rows(rows, a.level)
    os.environ.pop("DICE")
    tally = collections.defaultdict(lambda: collections.defaultdict(lambda: [0, 0]))
    for r, o in zip(rows, out):
        if r[2] == 0: continue   # the game's own dice: not what a human can count on
        t = tally[r[0]][r[4] or "his own"]; t[1] += 1; t[0] += o == "clear"
    res = {}
    for gid, mv in tally.items():
        own = mv["his own"]; best = max((m for m in mv if m != "his own"), key=lambda m: (mv[m][0] / max(1, mv[m][1]), mv[m][1]))
        res[gid] = {"own": own, "best": best, "best_rate": mv[best], "n": own[1], "all": {m: v for m, v in mv.items()}}
    json.dump(res, open(f"{out_dir(a.batch)}/robust.json", "w"))
    rate = lambda v: v[0] / max(1, v[1])
    real = [g for g, v in res.items() if rate(v["best_rate"]) >= 0.9 and rate(v["best_rate"]) - rate(v["own"]) >= 0.3]
    print(f"his own play from the sealing moment, new dice: {sum(v['own'][0] for v in res.values())} of {sum(v['own'][1] for v in res.values())} cleared")
    print(f"deaths with a robust human answer (a move that clears 90%+ with new dice, 30+ points better than his own): {len(real)} of {len(res)}")
    for g in sorted(real): print(f"  {g}: own {res[g]['own'][0]}/{res[g]['own'][1]}, best move {res[g]['best']} {res[g]['best_rate'][0]}/{res[g]['best_rate'][1]}")


def predict(a, deaths):
    os.environ.pop("SEARCH", None)
    sl = json.load(open(f"{out_dir(a.batch)}/seal.json"))
    bd = [g for g in deaths if "barrel" in g["cause"] and str(g["id"]) in sl]
    td = tempfile.mkdtemp(dir=os.environ.get("CLAUDE_JOB_DIR", "/tmp") + "/tmp" if os.environ.get("CLAUDE_JOB_DIR") else None)
    procs = []
    for g in bd:
        d = f"{td}/{g['id']}"; os.makedirs(d)
        open(f"{d}/scen.txt", "w").write(f"{g['id']} {g['frames'] + 5} 0 {g['inp']}\n")
        env = dict(os.environ, DKH=H, MODE="scenario", SCEN=f"{d}/scen.txt", START_ID="0", STEP="1", LAST="0", OUT=f"{d}/o.jsonl", NO_INPUTS="1",
                   PREDLOG=f"{d}/pred.txt", RNGLOG=d, WORKER="0", LEVEL=str(a.level), START_PREFIX="s" if a.level == 1 else f"l{a.level}_",
                   PARAMS=f"{H}/runs/{a.batch}/lua/params.lua" if os.path.exists(f"{H}/runs/{a.batch}/lua/params.lua") else f"{H}/lua/params.lua",
                   DKX_ROMS=os.path.expanduser("~/dkx-build/DK-x86-AI/dkx/roms"), DKH_STATES=f"{H}/native/starts")
        procs.append(subprocess.Popen([f"{H}/native/build/dkh", f"{H}/lua/agent.lua"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL))
        if len(procs) >= 8:
            for p in procs: p.wait()
            procs = []
    for p in procs: p.wait()
    res, kinds = {}, collections.Counter()
    for g in bd:
        d = f"{td}/{g['id']}"
        real = collections.defaultdict(dict)   # frame -> slot -> (x, y)
        if not os.path.exists(f"{d}/r_0.txt"): continue
        for l in open(f"{d}/r_0.txt"):
            p = l.rstrip("\n").split("|"); f = int(p[0].split()[1])
            for q in p[1:]:
                k, x, y, b2, b7 = (int(v) for v in q.split()); real[f][k] = (x, y)
        fd = g["frames"]; fs = fd - sl[str(g["id"])]
        last = max(f for f in real if f < fd)
        # the barrel that killed him: nearest to where he died, in the last frame before it
        kk = min(real[last], key=lambda k: abs(real[last][k][0] - g["x"]) + abs(real[last][k][1] - g["y"]), default=None)
        if kk is None: continue
        preds = []
        for l in open(f"{d}/pred.txt"):
            p = l.split()
            if p[0] != "P" or int(p[2]) != kk: continue
            f = int(p[1])
            if fs - 24 <= f <= fs + 4: preds.append((f, int(p[3]), int(p[5]), int(p[6]), p[7:]))
        # did it come down a ladder between the sealing moment and the death (dropped a girder away from the ends)?
        ys = [(f, real[f][kk]) for f in sorted(real) if fs <= f <= fd and kk in real[f]]
        ladder = any(lv(b[1]) < lv(a[1]) and 40 < a[0] < 215 for (_, a), (_, b) in zip(ys, ys[1:]))
        wild = any(p[1] != 0 for p in preds)
        main_err, seen_lad = None, False
        for f, c, maybe, lad, pos in preds:
            if lad: seen_lad = True
            if maybe == 0 and len(pos) >= 5 and pos[4] != "-":
                px, py = (float(v) for v in pos[4].split(","))
                rf = f + 48
                if rf in real and kk in real[rf]: main_err = max(main_err or 0, abs(px - real[rf][kk][0]) + abs(py - real[rf][kk][1]))
        first = min((f for f in real if kk in real[f]), default=fd)
        kind = "new barrel, only just on screen" if first > fs - 6 else "on screen, nothing predicted for it" if not preds else "wild" if wild else ("ladder, not foreseen" if ladder and not seen_lad else "ladder, foreseen as a maybe" if ladder else
                "rolled, predicted off by 8+ px" if (main_err or 0) >= 8 else "rolled as predicted (a choice, not a prediction)")
        kinds[kind] += 1
        res[g["id"]] = {"kind": kind, "killer": kk, "main_err": main_err, "seal_back": sl[str(g["id"])]}
    json.dump(res, open(f"{out_dir(a.batch)}/predict.json", "w"))
    print(f"the barrel that killed him, as his planner saw it at the sealing moment ({len(res)} deaths):")
    for k, n in kinds.most_common(): print(f"  {k}: {n}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("batch"); ap.add_argument("step", choices=["seal", "robust", "predict"])
    ap.add_argument("--level", type=int, default=5)
    ap.add_argument("--k", type=int, default=10)
    a = ap.parse_args()
    stats.use_starts(a.batch)
    # on the website's live boards, like every test (Matt: viewers watch them)
    import shutil
    stats.ensure_ram(); grid = stats.grid_dir()
    shutil.rmtree(grid, ignore_errors=True); os.makedirs(grid, exist_ok=True)
    os.environ["SHOW_GRID"] = grid
    deaths = [g for g in stats.load(a.batch, inputs=True) if g["outcome"] == "died"]
    {"seal": seal, "robust": robust, "predict": predict}[a.step](a, deaths)


if __name__ == "__main__":
    main()
