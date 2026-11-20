#!/usr/bin/env python3
"""Builds the library of game starts: same board, different coin/start timing, so different random seeds."""
import argparse, os, subprocess

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
N = 64


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--level", type=int, default=1, help="level to start on; above 1 the game itself carries on to that level's first barrel board")
    ap.add_argument("--board", type=int, default=1, help="4: the level's rivet board (prefix r<level>_)")
    a = ap.parse_args()
    prefix = (f"r{a.level}_" if a.board == 4 else "s" if a.level == 1 else f"l{a.level}_")
    procs = []
    for i in range(N):
        coin = 800 + i * 7
        start = coin + 200 + i % 5
        env = dict(os.environ, COIN=str(coin), START=str(start), NAME=f"{prefix}{i:03d}", LEVEL=str(a.level), BOARD=str(a.board))
        procs.append(subprocess.Popen([f"{H}/tools/mame.sh", "-nothrottle", "-samplerate", "1000", "-state_directory", f"{H}/starts",
                                       "-autoboot_script", f"{H}/lua/mkstart.lua"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL))
        if len(procs) == 8:
            for p in procs:
                p.wait()
            procs = []
    for p in procs:
        p.wait()
    print(sum(n.startswith(prefix) for n in os.listdir(f"{H}/starts/dkong")), "starts")


if __name__ == "__main__":
    main()
