#!/usr/bin/env python3
"""oracle_why.py BATCH: for each death with a confirmed robust answer (oracle_review robust_confirm.json), replay the death game exactly
to its sealing moment and print what his planner made of the answer move (PLANDBG): predicted a hit (when), flagged it risky, or
thought it safe but preferred something else. Summary in runs/BATCH/oracle_review/why.json."""
import collections, glob, json, os, re, subprocess, sys, tempfile
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
b = sys.argv[1]
R = f"{H}/runs/{b}/oracle_review"
conf = json.load(open(f"{R}/robust_confirm.json")); sl = json.load(open(f"{R}/seal.json"))
games = {str(json.loads(l)["id"]): json.loads(l) for p in glob.glob(f"{H}/runs/{b}/games_*.jsonl") for l in open(p)}
held = [g for g, v in conf.items() if v["move"][0] / v["move"][1] >= 0.85]
def plan_of(m):   # the standard move as his planner writes plans: (act, w1, j1)
    a, w, j1, j2, h = m.split()
    act = {"0": 0, "1": -1, "2": 1}[a]
    j = None if j1 == "nil" else {"0": 0, "1": -1, "2": 1}[j1]
    return act, int(w), j
td = tempfile.mkdtemp(dir=os.environ["CLAUDE_JOB_DIR"] + "/tmp" if os.environ.get("CLAUDE_JOB_DIR") else None)
lv = json.load(open(f"{H}/runs/{b}/meta.json")).get("level", 5)
procs = []
for g in held:
    t = games[g]["frames"] - sl[g]
    d = f"{td}/{g}"; os.makedirs(d)
    open(f"{d}/scen.txt", "w").write(f"{g} {t + 2} 0 {games[g]['inp']}\n")
    env = dict(os.environ, DKH=H, MODE="scenario", SCEN=f"{d}/scen.txt", START_ID="0", STEP="1", LAST="0", OUT=f"{d}/o.jsonl", NO_INPUTS="1",
               PLANDBG=f"{t - 2}-{t + 1}", WORKER="0", LEVEL=str(lv), START_PREFIX="s" if lv == 1 else f"l{lv}_",
               DKX_ROMS=os.path.expanduser("~/dkx-build/DK-x86-AI/dkx/roms"), DKH_STATES=f"{H}/native/starts")
    env.pop("SEARCH", None); env.pop("DICE", None)
    procs.append(subprocess.Popen([f"{H}/native/build/dkh", f"{H}/lua/agent.lua"], env=env, stdout=subprocess.DEVNULL, stderr=open(f"{d}/err.txt", "w")))
    if len(procs) >= 8:
        for p in procs: p.wait()
        procs = []
for p in procs: p.wait()
kinds = collections.Counter(); res = {}
for g in held:
    act, w, j = plan_of(conf[g]["best"])
    lines = open(f"{td}/{g}/err.txt").read().splitlines()
    plans = [l for l in lines if l.startswith("PLAN")]
    chose = [l for l in lines if l.startswith("CHOSE")]
    # the planner's closest plan to the answer: same act and jump, nearest wait
    best, bd = None, 1e9
    for l in plans:
        m = re.match(r"PLAN f=(\d+) x=(-?\d+) act=(-?\d+) w1=(\d+) j1=(\S+) (.*)", l)
        if not m: continue
        a2, w2, j2 = int(m.group(3)), int(m.group(4)), None if m.group(5) == "nil" else int(m.group(5))
        if a2 == act and j2 == j and abs(w2 - w) < bd: bd, best = abs(w2 - w), (int(m.group(1)), w2, m.group(6))
    if not plans: kind = "planner not weighing plans then (a rule or a shortcut decided)"
    elif not best: kind = "the answer isn't among the plans he weighs"
    elif "HIT" in best[2]: kind = "predicted it would be hit"
    elif "risk=true" in best[2]: kind = "thought it safe but risky (a barrel that might come down)"
    else: kind = "thought it safe, preferred another plan"
    kinds[kind] += 1
    res[g] = {"answer": conf[g]["best"], "closest": best, "chose": chose[-1] if chose else None, "kind": kind, "why_lines": [l for l in lines if l.startswith("CHOSE")][-3:]}
json.dump(res, open(f"{R}/why.json", "w"), indent=1)
print(f"{len(held)} deaths with a confirmed human answer: what his planner made of that answer at the sealing moment")
for k, n in kinds.most_common(): print(f"  {k}: {n}")
