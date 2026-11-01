"""Reads a batch's game records and summarises them against the goal: 9,500+ in 20 of 21 games."""
import glob, json, math, os, subprocess

RUNS = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "runs")
RAM = "/Volumes/DKLabRAM"
GOAL_SCORE, GOAL_RATE = 9500, 20 / 21


def grid_dir():
    """Where live positions go: the RAM disk when it's there, so they never touch the SSD."""
    return f"{RAM}/grid" if os.path.ismount(RAM) else os.path.join(RUNS, ".grid")


def ensure_ram():
    """Creates a small RAM disk for live positions if there isn't one. It goes away on restart."""
    if os.path.ismount(RAM):
        return
    try:
        dev = subprocess.run(["hdiutil", "attach", "-nomount", "ram://65536"], capture_output=True, text=True, timeout=30).stdout.split()[0]
        subprocess.run(["diskutil", "erasevolume", "HFS+", os.path.basename(RAM), dev], capture_output=True, timeout=30)
        # macOS logs every file change on a volume, and that log alone would fill this disk. no_log turns it off once remounted.
        os.makedirs(f"{RAM}/.fseventsd", exist_ok=True)
        open(f"{RAM}/.fseventsd/no_log", "w").close()
        subprocess.run(["diskutil", "unmount", RAM], capture_output=True, timeout=30)
        subprocess.run(["diskutil", "mount", dev], capture_output=True, timeout=30)
    except (OSError, IndexError, subprocess.SubprocessError):
        pass                    # positions just go to disk instead


def load(name, inputs=False):
    games = []
    for path in glob.glob(os.path.join(RUNS, name, "games_*.jsonl")):
        with open(path) as f:
            for line in f:
                try:
                    g = json.loads(line)
                except ValueError:
                    continue            # a worker is part way through writing this line
                if not inputs:
                    g.pop("inp", None)
                games.append(g)
    games.sort(key=lambda g: g["id"])
    return games


def totals():
    """Games and clears across every batch, including ones since deleted: finished batches are added once to a saved tally."""
    path = os.path.join(RUNS, "totals.json")
    try:
        t = json.load(open(path))
    except (OSError, ValueError):
        t = {"games": 0, "clears": 0, "counted": []}
    games, clears, changed = t["games"], t["clears"], False
    for name in os.listdir(RUNS):
        meta = os.path.join(RUNS, name, "meta.json")
        if name.startswith(".") or not os.path.exists(meta) or name in t["counted"]:
            continue
        g = load(name)
        done = sum(x["outcome"] == "clear" for x in g)
        if "finished" in json.load(open(meta)):
            t["games"] += len(g)
            t["clears"] += done
            t["counted"].append(name)
            changed = True
        games += len(g)
        clears += done
    if changed:
        tmp = path + ".tmp"
        json.dump(t, open(tmp, "w"))
        os.replace(tmp, path)
    return {"games": games, "clears": clears}


def wilson_low(hits, n, z=1.96):
    """Lower end of the 95% range for the true rate: what we can claim from this many games."""
    if not n:
        return 0.0
    p = hits / n
    return (p + z * z / (2 * n) - z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n))) / (1 + z * z / n)


def pct(values, q):
    return values[min(len(values) - 1, int(q * len(values)))] if values else 0


def summary(games):
    n = len(games)
    clears = [g for g in games if g["outcome"] == "clear"]
    goal = sum(g["score"] >= GOAL_SCORE for g in clears)
    scores = sorted(g["score"] for g in clears)
    causes, floors = {}, {}
    for g in games:
        if g["outcome"] != "clear":
            k = f'{g["outcome"]}: {g["cause"]} while {g["doing"]}, floor {g["floor"]}'
            causes[k] = causes.get(k, 0) + 1
        floors[g["floor"]] = floors.get(g["floor"], 0) + 1
    return {
        "games": n,
        "clears": len(clears),
        "clear_rate": len(clears) / n if n else 0,
        "goal_hits": goal,
        "goal_rate": goal / n if n else 0,
        "goal_rate_low": wilson_low(goal, n),
        "clear_rate_low": wilson_low(len(clears), n),
        "goal_target": GOAL_RATE,
        "score_median": pct(scores, 0.5),
        "score_p10": pct(scores, 0.1),
        "score_max": scores[-1] if scores else 0,
        "variety": len({g["hash"] for g in games}),
        "causes": sorted(causes.items(), key=lambda kv: -kv[1])[:15],
        "floors": sorted(floors.items()),
    }
