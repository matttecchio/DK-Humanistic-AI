#!/usr/bin/env python3
"""pred_vs_real.py BATCH SPEC [--seeds 4]: what the planner predicted a move would run into, against what it really met.
(Matt, 2026-11-11: his sideways jumps came from predicting that the straight jump would die.) SPEC lines: "ID | frames before
the death | move" (move "a w j1 j2 h", e.g. "0 0 0 nil 0" a straight jump now). For each: (1) the planner at that moment, as
he saw it, asked about that plan (why_plan.py with dbgnative): its near misses and hits, when, and what (barrel or wild, where);
(2) the move played for real from that moment in his game, `seeds` times, traced every frame; (3) at each predicted near miss
or hit, where that hazard really was (the nearest barrel to the predicted spot at that frame) and how close it really came to
Mario. Results in SPEC.out."""
import argparse, glob, os, re, subprocess, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import stats

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def clear(mx, my, bx, by):
    return max(abs(bx - mx) - 5, abs(by - my) - 7)


def predicted(batch, gid, s, move):
    a, w, j1 = move.split()[:3]
    j = "nil" if j1 == "nil" else {"0": "0", "1": "-1", "2": "1"}[j1]          # spec 1 left / 2 right; planner -1 / 1
    act = {"0": "0", "1": "-1", "2": "1"}[a]
    env = dict(os.environ, WHY_CURRENT="1")
    r = subprocess.run([sys.executable, f"{H}/tools/why_plan.py", batch, str(gid), str(s), str(s + 1),
                        f"dbg=function(f) return f=={s} end", f"dbgnative_at={{{act},{w},{j}}}"], capture_output=True, text=True, env=env, timeout=600)
    out = []
    for l in r.stdout.splitlines():
        m = re.match(r"\s+t=(\d+) mario\(([-\d.]+),([-\d.]+)\) (barrel|wild)\(([-\d.]+),([-\d.]+)\) cl=([-\d.]+)", l)
        if m:
            out.append((int(m.group(1)), float(m.group(2)), float(m.group(3)), m.group(4), float(m.group(5)), float(m.group(6)), float(m.group(7))))
    verdict = [l.strip() for l in r.stdout.splitlines() if l.startswith(f"  f={s} act={act} w1={w} j1={j} j2=nil")]
    return out, verdict


def actual(batch, g, s, move, seed, td):
    scen = f"{td}/scen.txt"; tr = f"{td}/tr_{seed}.trace"
    open(scen, "w").write(f"{g['id']} {s} {seed} {g['inp']} {move}\n")
    if os.path.exists(tr): os.remove(tr)
    env = dict(os.environ, DKH=H, MODE="scenario", SCEN=scen, START_ID="0", STEP="1", LAST="0", OUT=f"{td}/o.jsonl", TRACE=tr,
               PARAMS=f"{H}/runs/{batch}/lua/params.lua", LEVEL="5", START_PREFIX="l5_", NO_INPUTS="1",
               DKX_ROMS=os.path.expanduser("~/dkx-build/DK-x86-AI/dkx/roms"), DKH_STATES=f"{H}/native/starts")
    if os.path.exists(f"{td}/o.jsonl"): os.remove(f"{td}/o.jsonl")
    subprocess.run([f"{H}/native/build/dkh", f"{H}/runs/{batch}/autopsy/agent_tr.lua"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=300)
    rows = {}
    for l in open(tr) if os.path.exists(tr) else []:
        p = l.rstrip("\n").split("|"); hd = p[0].split()
        bs = [tuple(int(v) for v in q.split()[1:5]) for q in p[1:] if q.startswith("B")]
        rows[int(hd[1])] = (int(hd[2]), int(hd[3]), bs)
    import json
    o = [json.loads(l) for l in open(f"{td}/o.jsonl")] if os.path.exists(f"{td}/o.jsonl") else []
    return rows, (o[0]["outcome"] if o else "?")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("batch"); ap.add_argument("spec"); ap.add_argument("--seeds", type=int, default=4)
    a = ap.parse_args()
    games = {g["id"]: g for g in stats.load(a.batch, inputs=True)}
    out = open(a.spec + ".out", "w")
    say = lambda t: (print(t, flush=True), print(t, file=out, flush=True))
    for l in open(a.spec):
        if not l.strip() or l.startswith("#"): continue
        gid, back, move = (x.strip() for x in l.split("|")); gid = int(gid); g = games[gid]; s = g["frames"] - int(back)
        pred, verdict = predicted(a.batch, gid, s, move)
        say(f"== {gid}, {back} frames before the death, move {move}: planner says {verdict[0] if verdict else '?'}")
        with tempfile.TemporaryDirectory(dir=os.environ.get("CLAUDE_JOB_DIR", "/tmp") + "/tmp" if os.environ.get("CLAUDE_JOB_DIR") else None) as td:
            runs = [actual(a.batch, g, s, move, seed, td) for seed in range(a.seeds)]
        say(f"   played for real {a.seeds} times: " + ", ".join(r[1] for r in runs))
        for t, mx, my, kind, hx, hy, cl in pred[:8]:
            f = s + t
            parts = []
            for rows, res in runs:
                if f not in rows: parts.append("-"); continue
                rx, ry, bs = rows[f]
                near = min(bs, key=lambda b: (b[0] - hx) ** 2 + (b[1] - hy) ** 2, default=None)
                real_cl = min((clear(rx, ry, b[0], b[1]) for b in bs), default=99)
                parts.append(f"Mario ({rx},{ry}); nearest real barrel to that spot " + (f"({near[0]},{near[1]}{' wild' if near[3] else ''})" if near else "none") + f"; closest to Mario {real_cl:.0f}")
            say(f"   t={t}: predicted Mario ({mx:.0f},{my:.0f}) and a {kind} at ({hx:.0f},{hy:.0f}), clearance {cl:.1f} | real: " + " / ".join(parts[:2]))


if __name__ == "__main__":
    main()
