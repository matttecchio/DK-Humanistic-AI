#!/usr/bin/env python3
"""Why did he choose that? Feeds a death's autopsy trace through the planner as he saw it, printing every plan's score.
why_plan.py BATCH GAME F0 F1 [key=value ...]"""
import json, os, subprocess, sys, tempfile
H = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
b, g, f0, f1 = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
level = json.load(open(f"{H}/runs/{b}/meta.json")).get("level", 1)
sets = "\n".join("params." + a for a in sys.argv[5:])
src = open(f"{H}/lua/policy.lua" if os.environ.get("WHY_CURRENT") else f"{H}/runs/{b}/lua/policy.lua").read()   # WHY_CURRENT: the planner as it is now
a = "        if not best_s or v > best_s then best_s = v; best = {act = act, w1 = w1, j1 = j1, cl = cl, juke = juke} end\n      elseif not fallback_t"
assert src.count(a) == 1
src = src.replace(a, "        if params.dbg and params.dbg(f) then print(string.format('  f=%d act=%d w1=%d j1=%s j2=%s cl=%.1f risk=%s t=%d xe=%.0f v=%.0f next=%s', f, act, w1, tostring(j1), tostring(j2), cl, tostring(risk), t, xe, v, j1 and tostring(next_ok(act, w1, j1)) or '-')) end\n" + a)
a3 = "        local h = hz[s]\n        for i = 1, #h, 6 do\n"
assert src.count(a3) == 1
src = src.replace(a3, "        local h = hz[s]\n        if params.dbgplan and params.dbg(f) and act == params.dbgplan[1] and w1 <= params.dbgplan[2] and j1 == params.dbgplan[3] and not j2 and not stay then local near, nd = nil, 1e9; for i = 1, #h, 6 do local d = math.abs(h[i] - mx) + math.abs(h[i + 1] - my); if d < nd then nd, near = d, i end end; print(string.format('    t=%d mario(%.1f,%.1f) nearest(%s,%s) maybe=%s', t, mx, my, near and string.format('%.1f', h[near]) or '-', near and string.format('%.1f', h[near + 1]) or '-', near and tostring(h[near + 2]) or '-')) end\n        for i = 1, #h, 6 do\n")
a2 = "      elseif not fallback_t or t > fallback_t then\n"
assert src.count(a2) == 1
src = src.replace(a2, "      elseif params.dbg and params.dbg(f) and print(string.format('  f=%d act=%d w1=%d j1=%s j2=%s HIT at t=%s', f, act, w1, tostring(j1), tostring(j2), tostring(t))) then\n" + a2)
with tempfile.TemporaryDirectory() as td:
    open(f"{td}/policy.lua", "w").write(src)
    lua = f'''
local params = dofile("{H}/runs/{b}/lua/params.lua")
for k, v in pairs(params.levels and params.levels[{level}] or {{}}) do params[k] = v end
{sets}
params.dbg = function(f) return f >= {f0} and f <= {f1} end
local P = dofile("{td}/policy.lua")
local rows = {{}}
for l in io.lines("{H}/runs/{b}/autopsy/{g}.trace") do
  local parts = {{}}
  for p in l:gmatch("[^|]+") do parts[#parts + 1] = p end
  local h = {{}}
  for w in parts[1]:gmatch("%S+") do h[#h + 1] = w end
  local o = {{x = tonumber(h[3]), y = tonumber(h[4]), lad = tonumber(h[5]), jmp = tonumber(h[6]), ham = 0, kong = 0, f = {{}}, b = {{}}}}
  for i = 2, #parts do
    local t = {{}}
    for w in parts[i]:gmatch("%S+") do t[#t + 1] = w end
    if t[1]:sub(1, 1) == "B" then o.b[#o.b + 1] = {{k = tonumber(t[1]:sub(2)), x = tonumber(t[2]), y = tonumber(t[3]), d = tonumber(t[4]), c = tonumber(t[5])}}
    elseif t[1]:sub(1, 1) == "F" then o.f[#o.f + 1] = {{k = tonumber(t[1]:sub(2)), x = tonumber(t[2]), y = tonumber(t[3])}} end
  end
  rows[tonumber(h[2])] = o
end
local c = P.new(params)
local first = math.huge
for k in pairs(rows) do if k < first then first = k end end
for f = first + 9, {f1} do
  local o = rows[f - 9]
  if o then
    local m = c.decide(o, f, 9)
    if f >= {f0} then print("f=" .. f .. " saw x=" .. o.x .. " y=" .. o.y .. " jmp=" .. o.jmp .. " m=" .. m .. " why=" .. c.why) end
  end
end
manager.machine:exit()
'''
    open(f"{td}/h.lua", "w").write(lua)
    if json.load(open(f"{H}/runs/{b}/meta.json")).get("native"):   # played on dkx: score it there, with the compiled planner
        r = subprocess.run([f"{H}/native/build/dkh", f"{td}/h.lua"], capture_output=True, text=True, timeout=300,
                           env=dict(os.environ, DKX_ROMS=os.path.expanduser("~/dkx-build/DK-x86-AI/dkx/roms"), DKH_STATES=f"{H}/native/starts"))
    else:
        r = subprocess.run([f"{H}/tools/mame.sh", "-nothrottle", "-numprocessors", "1", "-autoboot_script", f"{td}/h.lua"], capture_output=True, text=True, timeout=120)
print("\n".join(l for l in (r.stdout + r.stderr).splitlines() if l.startswith(("f=", "  f=", "    t=", "    hz")) or "rror" in l or "attempt" in l))
