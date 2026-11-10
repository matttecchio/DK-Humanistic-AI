#!/usr/bin/env python3
"""Goes through every death in a batch: autopsy.py BATCH [--max N] [--back FRAMES]
For each one it replays the game, keeps what he saw and planned over the last seconds, and tries every simple move
from save states to see which would have survived. Writes runs/BATCH/autopsy/ (one trace per death, and summary.jsonl)."""
import argparse, concurrent.futures as cf, glob, json, os, subprocess, sys
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, f"{H}/tools")
import stats

HOOK = '''
local TRF = io.open(os.getenv("TRACE"), "a")
local function TR(o)
  local parts = {string.format("%d %d %d %d %d %d %d %d %s", g.id, g.f, o.x, o.y, o.lad, o.jmp, o.ham, g.cur, (g.c.why or ""):gsub(" ","_"))}
  for _, b in ipairs(o.b) do parts[#parts+1] = string.format("B%d %d %d %d %d", b.k, b.x, b.y, b.d, b.c) end
  for _, f in ipairs(o.f) do parts[#parts+1] = string.format("F%d %d %d 0 0", f.k, f.x, f.y) end
  -- K: Kong's pose, how many frames he has held it, and the frame counter (Mario's walk rhythm)
  if o.kong ~= KP then KP = o.kong; KPF = g.f end
  parts[#parts+1] = string.format("K %d %d %d", o.kong, g.f - (KPF or g.f), o.fc or 0)
  TRF:write(table.concat(parts, "|"), "\\n")
end
'''
ACTS = {0: "stand", 1: "left", 2: "right", 16: "jump up", 17: "jump left", 18: "jump right"}


def build(batch, out):
    """A copy of the batch's exact player, which also writes down what it saw and planned."""
    d = f"{H}/runs/{batch}/lua"
    s = open(f"{d}/agent.lua").read().replace("local function play_frame()", HOOK + "local function play_frame()")
    s = s.replace("  if GRID then publish(o) end\n", "  if GRID then publish(o) end\n  TR(o)\n", 1)
    s = s.replace('dofile(HOME .. "/lua/policy.lua")', f'dofile("{out}/policy_tr.lua")')
    open(f"{out}/agent_tr.lua", "w").write(s)
    p = open(f"{d}/policy.lua").read()
    a = '    c.why = best and "plan" or "no safe plan"\n'
    assert a in p
    p = p.replace(a, a + '    c.why = c.why .. string.format(" a%d w%d j%s s%.0f", p.act, p.w1, tostring(p.j1), best_s or -1)\n')
    open(f"{out}/policy_tr.lua", "w").write(p)


def mame(script, env, timeout=300):
    subprocess.run([f"{H}/tools/mame.sh", "-nothrottle", "-numprocessors", "1", "-samplerate", "1000", "-state_directory", f"{H}/starts",
                    "-autoboot_script", script], env=dict(os.environ, **env), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=timeout)


def one(batch, g, out, back):
    gid = g["id"]
    tr, oj = f"{out}/{gid}.trace", f"{out}/{gid}.o"
    for p in (tr, oj):
        if os.path.exists(p):
            os.remove(p)
    env = dict(DKH=H, MODE="batch", START_ID=str(gid), STEP="1", LAST=str(gid), OUT=oj, TRACE=tr, PARAMS=f"{H}/runs/{batch}/lua/params.lua")
    if json.load(open(f"{H}/runs/{batch}/meta.json")).get("native"):
        # played on dkx: replay the player there too, or parts only the compiled planner has would play a different game
        subprocess.run([f"{H}/native/build/dkh", f"{out}/agent_tr.lua"], env=dict(os.environ, **env, DKX_ROMS=os.path.expanduser("~/dkx-build/DK-x86-AI/dkx/roms"),
                       DKH_STATES=f"{H}/native/starts"), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=300)
    else:
        mame(f"{out}/agent_tr.lua", env)
    os.remove(oj)
    if os.environ.get("TRACE_ONLY"):          # just the trace (any game, cleared ones too), no move probing
        return {"id": gid}
    frames = [l.rstrip("\n").split("|") for l in open(tr)]
    rp, pr = f"{out}/{gid}.rp", f"{out}/{gid}.pr"
    open(rp, "w").write(f"{gid}\n{g['start']}\n{g['inp']}\n")
    mame(f"{H}/lua/probe.lua", dict(REPLAY=rp, OUT=pr, F0=str(max(2, g["frames"] - back)), DEATH=str(g["frames"]), PSTEP="4"))
    os.remove(rp)
    for s in glob.glob(f"{H}/starts/**/probe{gid}*", recursive=True):
        os.remove(s)
    ok, check = {}, None
    for l in open(pr):
        a = l.split()
        if a[0] == "check":
            check = int(a[1]) - g["frames"]
        elif a[0] != "lost" and a[2] == "ok":
            ok.setdefault(ACTS[int(a[0])], []).append(g["frames"] - int(a[1]))
    os.remove(pr)
    # the hazard touching him at the end, and how it got there
    last = frames[-1]
    h = last[0].split()
    mx, my = int(h[2]), int(h[3])
    killer, best = None, 1e9
    for q in last[1:]:
        t = q.split()
        d = abs(int(t[1]) - mx) + abs(int(t[2]) - my)
        if d < best:
            best, killer = d, t[0]
    hist = []
    for fr in frames[-240:]:
        for q in fr[1:]:
            t = q.split()
            if t[0] == killer:
                hist.append((int(t[3]), int(t[4])))
    kind = "fireball" if killer and killer[0] == "F" else ("wild" if any(c for _, c in hist) else ("off ladder" if any(d & 1 for d, _ in hist) else ("off girder end" if any(d == 8 for d, _ in hist) else "roller")))
    whys = [" ".join(f[0].split()[8:]) for f in frames[-back:]]
    jump_f = None
    for i, f in enumerate(frames[::-1]):
        if int(f[0].split()[5]):
            jump_f = i
            break
    latest = max((min(v) for v in ok.values()), default=None)    # the last moment any simple move still worked
    return dict(id=gid, floor=g["floor"], cause=g["cause"], doing=g["doing"], x=g["x"], y=g["y"], frames=g["frames"], kind=kind, check=check,
                ok={k: sorted(v, reverse=True) for k, v in ok.items()}, latest=latest,
                no_plan=sum(w.startswith("no_safe") for w in whys), last_why=whys[-1])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("batch")
    ap.add_argument("--max", type=int, default=0)
    ap.add_argument("--back", type=int, default=240)
    ap.add_argument("--workers", type=int, default=8)
    ap.add_argument("--ids", default="", help="only these games, comma-separated")
    a = ap.parse_args()
    out = f"{H}/runs/{a.batch}/autopsy"
    os.makedirs(out, exist_ok=True)
    stats.use_starts(a.batch)
    build(a.batch, out)
    deaths = [g for g in stats.load(a.batch, inputs=True) if g["outcome"] != "clear" or os.environ.get("TRACE_ONLY")]
    if a.max:
        deaths = deaths[:a.max]
    if a.ids:
        keep = {int(i) for i in a.ids.split(",")}
        deaths = [g for g in deaths if g["id"] in keep]
    with cf.ThreadPoolExecutor(a.workers) as ex, open(f"{out}/summary.jsonl", "a" if a.ids else "w") as f:
        for r in ex.map(lambda g: one(a.batch, g, out, a.back), deaths):
            f.write(json.dumps(r) + "\n")
            f.flush()
    print(len(deaths), "deaths examined:", f"{out}/summary.jsonl")


if __name__ == "__main__":
    main()
