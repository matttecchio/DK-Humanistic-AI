# DK Humanistic AI

A program that plays Donkey Kong level 1-1 under human limits: it sees the game 133–167 ms late, can't see the game's upcoming random numbers, and plans ahead like a person. The aim is to clear the board at 9,500+ in 20 of 21 games.

- [FINDINGS.md](FINDINGS.md): what we've learned, including what didn't work
- [RESULTS_LOG.md](RESULTS_LOG.md): every test result

## Running it

You need MAME 0.264 built with the `dkong` driver and your own `dkong` ROM (not included). Paths are currently set for one Mac in `tools/mame.sh`.

```sh
python3 tools/make_starts.py                                # build the game starts
python3 web/server.py                                       # website on port 8765
python3 tools/run_batch.py my_test --games 1000 --note "…"  # play a batch
```

`lua/agent.lua` holds the fixed human limits. `lua/policy.lua` and `lua/params.lua` hold the rules, which can change.
