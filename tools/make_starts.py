#!/usr/bin/env python3
"""Builds the library of game starts: same board, different coin/start timing, so different random seeds."""
import os, subprocess

H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
N = 64


def main():
    procs = []
    for i in range(N):
        coin = 800 + i * 7
        start = coin + 200 + i % 5
        env = dict(os.environ, COIN=str(coin), START=str(start), NAME=f"s{i:03d}")
        procs.append(subprocess.Popen([f"{H}/tools/mame.sh", "-nothrottle", "-samplerate", "1000", "-state_directory", f"{H}/starts",
                                       "-autoboot_script", f"{H}/lua/mkstart.lua"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL))
        if len(procs) == 8:
            for p in procs:
                p.wait()
            procs = []
    for p in procs:
        p.wait()
    print(len(os.listdir(f"{H}/starts/dkong")), "starts")


if __name__ == "__main__":
    main()
