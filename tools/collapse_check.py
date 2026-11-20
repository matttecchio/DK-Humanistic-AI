#!/usr/bin/env python3
"""collapse_check.py BATCH [N]: why his safe plan suddenly looks fatal (2026-11-12, Matt: no barrel deaths while jumping on
5-1). For each traced death: the last frame his planner had a safe plan (score >= 0) and the plan it was; at the next frame
it decided again, that same plan is put to the planner (why_plan.py, dbgnative) to see what it now predicts kills it (when,
where); then the real game (the trace) is checked: was any barrel really at that spot at that time (within 4 px)?
Prints a line per death and a summary: predicted killers that were real against ones that never came."""
import collections, json, os, re, subprocess, sys

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
b = sys.argv[1]; N = int(sys.argv[2]) if len(sys.argv) > 2 else 40
S = [json.loads(l) for l in open(f"{H}/runs/{b}/autopsy/summary.jsonl")]
res = collections.Counter(); out = open(f"{H}/runs/{b}/collapse_check.txt", "w")
done = 0
for s in S:
    if done >= N: break
    rows = [l.rstrip("\n").split("|") for l in open(f"{H}/runs/{b}/autopsy/{s['id']}.trace")]
    hd = [r[0].split() for r in rows]
    def plan(h):
        m = re.search(r"plan_a(-?\d+)_w(\d+)_j(-?\d+|nil)_s(-?\d+)", " ".join(h[8:])); return m.groups() if m else None
    last = None
    for i in range(len(rows) - 1, -1, -1):
        p = plan(hd[i])
        if p and int(p[3]) >= 0: last = i; break
    if last is None or last + 1 >= len(rows): continue
    a, w, j, sc = plan(hd[last])
    # the next frame he decided again
    c = next((k for k in range(last + 1, min(last + 6, len(rows))) if plan(hd[k])), last + 2)
    f = int(hd[c][1])
    # the safe plan, a few frames on (its wait shortened by the frames that passed)
    w2 = max(0, int(w) - (c - last))
    r = subprocess.run([sys.executable, f"{H}/tools/why_plan.py", b, str(s["id"]), str(f), str(f + 1), f"dbg=function(x) return x=={f} end",
                        f"dbgnative_at={{{a},{w2},{j}}}"], capture_output=True, text=True, env=dict(os.environ, WHY_CURRENT="1"), timeout=600)
    hits = [(int(m.group(1)), float(m.group(2)), float(m.group(3)), m.group(4), float(m.group(5)), float(m.group(6)), float(m.group(7)))
            for m in re.finditer(r"t=(\d+) mario\(([-\d.]+),([-\d.]+)\) (barrel|wild)\(([-\d.]+),([-\d.]+)\) cl=([-\d.]+)", r.stdout)]
    hits = [h for h in hits if h[6] <= 0.5]
    jj = "nil" if j == "nil" else j
    pl = [l.strip() for l in r.stdout.splitlines() if re.match(rf"\s+f={f} act={a} w1={w2} j1={jj} j2=nil( cl=| HIT)", l)]
    breakdown = pl[0].split(f"j2=nil ")[1] if pl else "?"
    T = {int(h[1]): k for k, h in enumerate(hd)}
    if not hits:
        verdict = "no predicted hit printed"
    else:
        t, mx, my, kind, hx, hy, cl = hits[0]
        k = T.get(f + t)
        if k is None:
            verdict = f"predicted {kind} hit at t={t} is after the death"
        else:
            bs = [(int(q.split()[1]), int(q.split()[2])) for q in rows[k][1:] if q.startswith("B")]
            near = min(bs, key=lambda p: abs(p[0] - hx) + abs(p[1] - hy), default=None)
            real = near and abs(near[0] - hx) <= 4 and abs(near[1] - hy) <= 4
            verdict = f"predicted {kind} at ({hx:.0f},{hy:.0f}) t={t}: " + ("REAL (a barrel was there)" if real else f"NEVER CAME (nearest real {near})")
    res[verdict.split(":")[-1].split(" (")[0].strip() if ":" in verdict else verdict] += 1
    line = f"{s['id']} safe plan a{a} w{w} j{j} (score {sc}) at frame {hd[last][1]}; at {f}: {verdict}; now: {breakdown}"
    print(line, flush=True); print(line, file=out, flush=True)
    done += 1
print("SUMMARY", dict(res)); print("SUMMARY", dict(res), file=out)
