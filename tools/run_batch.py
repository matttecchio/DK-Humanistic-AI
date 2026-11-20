#!/usr/bin/env python3
"""Plays a batch of games across the workers: run_batch.py NAME [--games N] [--workers W]"""
import argparse, glob, json, os, shutil, subprocess, sys, time

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STALL_SECONDS = 120
sys.path.insert(0, f"{H}/tools")
import stats


def log_result(a, s, stalled):
    """One line per batch in RESULTS_LOG.md, with the rule changes it tested, so nothing gets lost."""
    path = f"{H}/RESULTS_LOG.md"
    if not os.path.exists(path):
        open(path, "w").write("# Test results\n\nAdded automatically after each batch. Conclusions are in FINDINGS.md.\n\n"
                              "| Date | Batch | What was tested | Rule changes | First game | Games | Cleared | At least (95%) | Hit 9,500+ | Median score |\n"
                              "|---|---|---|---|---|---|---|---|---|---|\n")
    note = (a.note or "") + (" (STALLED)" if stalled else "")
    with open(path, "a") as f:
        f.write(f"| {time.strftime('%Y-%m-%d %H:%M')} | {a.name} | {note} | {', '.join(a.set)} | {a.first} | {s['games']:,} | "
                f"{s['clear_rate']:.1%} ({s['clear_rate_all']:.1%} with fireballs) | {s['clear_rate_low']:.1%} | {s['goal_rate']:.1%} | {s['score_median']:,} |\n")


def say(text):
    subprocess.run([sys.executable, f"{H}/tools/say.py", text])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("name")
    ap.add_argument("--games", type=int, default=1000)
    ap.add_argument("--workers", type=int, default=8)
    ap.add_argument("--note", default="")
    ap.add_argument("--first", type=int, default=0, help="first game number, for testing on a fresh set of games")
    ap.add_argument("--board", type=int, default=1, help="4: start on the level's rivet board (starts r<level>_)")
    ap.add_argument("--stall", type=int, default=0, help="seconds without a result before the batch counts as stuck (default 120; slow players, e.g. RSEARCH, need more)")
    ap.add_argument("--set", action="append", default=[], metavar="KEY=VALUE", help="override a rule for this batch only (Lua value)")
    ap.add_argument("--level", type=int, default=1, help="level whose first barrel board to play (needs make_starts.py --level N)")
    ap.add_argument("--no-inputs", action="store_true", help="don't save each game's inputs (uses far less disk, but those games can't be replayed)")
    ap.add_argument("--no-grid", action="store_true", help="don't publish positions for the website")
    ap.add_argument("--native", action="store_true", help="play on dkx (native/build/dkh) instead of MAME: the same games, input for input, about 5x faster")
    a = ap.parse_args()
    d = f"{H}/runs/{a.name}"
    if os.path.exists(d):
        sys.exit(f"{d} already exists")
    os.makedirs(d)
    # keep the exact rules each batch played under
    shutil.copytree(f"{H}/lua", f"{d}/lua")
    if a.set:
        os.rename(f"{d}/lua/params.lua", f"{d}/lua/params_base.lua")
        lines = [f'local p = dofile("{d}/lua/params_base.lua")'] + [f"for _, l in pairs(p.levels or {{}}) do l.{kv.split('=', 1)[0]} = nil end\np.{kv.split('=', 1)[0]} = {kv.split('=', 1)[1]}" for kv in a.set] + ["return p"]   # a setting for this batch beats the level's own
        open(f"{d}/lua/params.lua", "w").write("\n".join(lines) + "\n")
    json.dump({"name": a.name, "games": a.games, "workers": a.workers, "note": a.note, "level": a.level, "board": a.board, "native": a.native, "started": time.time()}, open(f"{d}/meta.json", "w"))
    stats.ensure_ram()
    GRID = stats.grid_dir()
    shutil.rmtree(GRID, ignore_errors=True)
    os.makedirs(GRID, exist_ok=True)
    say(f"Testing: {a.note or a.name} ({a.games:,} games). Waiting for results")
    procs = []
    for w in range(a.workers):
        env = dict(os.environ, DKH=H, MODE="batch", START_ID=str(a.first + w), STEP=str(a.workers), LAST=str(a.first + a.games - 1), OUT=f"{d}/games_{w}.jsonl",
                   PARAMS=f"{d}/lua/params.lua", WORKER=str(w), LEVEL=str(a.level), START_PREFIX=(f"r{a.level}_" if a.board == 4 else "s" if a.level == 1 else f"l{a.level}_"))
        if a.no_inputs:
            env["NO_INPUTS"] = "1"
        if not a.no_grid:
            env["GRID"] = GRID
        if a.native:
            env.update(DKX_ROMS=os.path.expanduser("~/dkx-build/DK-x86-AI/dkx/roms"), DKH_STATES=f"{H}/native/starts")
            cmd = [f"{H}/native/build/dkh", f"{H}/lua/agent.lua"]
        else:
            cmd = [f"{H}/tools/mame.sh", "-nothrottle", "-numprocessors", "1", "-samplerate", "1000", "-state_directory", f"{H}/starts",
                   "-autoboot_script", f"{H}/lua/agent.lua"]
        procs.append(subprocess.Popen(cmd, env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL))
    t0 = time.time()
    stalled = False
    last_size, last_change = -1, time.time()
    while any(p.poll() is None for p in procs):
        time.sleep(1)
        # results should keep arriving; if they stop, the batch is stuck, so say so instead of sitting silently
        size = sum(os.path.getsize(f) for f in glob.glob(f"{d}/games_*.jsonl"))
        if size != last_size:
            last_size, last_change = size, time.time()
        elif time.time() - last_change > (a.stall or STALL_SECONDS):
            stalled = True
            for p in procs:
                p.kill()
            break
    el = time.time() - t0
    if stalled:
        say(f"Problem: {a.note or a.name} stopped producing results and was stopped")
        print(f"{a.name}: STALLED, no results for {STALL_SECONDS}s")
    games = stats.load(a.name)
    meta = json.load(open(f"{d}/meta.json"))
    meta.update(seconds=el, finished=time.time())
    json.dump(meta, open(f"{d}/meta.json", "w"))
    s = stats.summary(games)
    stats.totals()              # count it now, in case the batch gets deleted later
    say(f"Result: {a.note or a.name} survived {s['clear_rate']:.1%} of {s['games']:,} games, not counting {s['fireball_deaths']} fireball deaths")
    log_result(a, s, stalled)
    print(f"{a.name}: {s['games']} games in {el:.0f}s ({s['games'] / max(el, 1):.1f}/s)")
    print(f"clear {s['clear_rate']:.1%} without fireball deaths ({s['fireball_deaths']}), {s['clear_rate_all']:.1%} with; goal {s['goal_rate']:.1%}; median clear score {s['score_median']}, best {s['score_max']}; distinct games {s['variety']}")
    print("reached floor:", s["floors"])
    for k, v in s["causes"]:
        print(f"  {v:5d}  {k}")


if __name__ == "__main__":
    main()
