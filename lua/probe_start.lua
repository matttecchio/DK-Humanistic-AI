-- boot with a given coin/start timing, save the first playable frame, then watch the idle game to see how it varies
local mac = manager.machine
local COIN, START = tonumber(os.getenv("COIN")), tonumber(os.getenv("START"))
local NAME, OUT = os.getenv("NAME"), os.getenv("OUT")
local sp, n, t0, trace = nil, 0, nil, {}
local function r(a) return sp:readv_u8(a) end
emu.register_frame_done(function()
  if not sp then local c = mac.devices[":maincpu"]; if not c then return end; sp = c.spaces["program"] end
  n = n + 1
  local p = mac.ioport.ports[":IN2"]
  if n == COIN then p.fields["Coin 1"]:set_value(1) elseif n == COIN + 30 then p.fields["Coin 1"]:set_value(0) end
  if n == START then p.fields["1 Player Start"]:set_value(1) elseif n == START + 30 then p.fields["1 Player Start"]:set_value(0) end
  if not t0 and n > START + 30 and r(0x600A) == 0x0C then
    t0 = n; mac:save(NAME)
    local f = io.open(OUT, "w"); f:write(string.format("start frame=%d lives=%d level=%d board=%d timer=%d x=%d y=%d rng=%d %d\n", n, r(0x6228), r(0x6229), r(0x6227), r(0x62B1), r(0x6203), r(0x6205), r(0x6018), r(0x6019)))
    local s = mac.screens[":screen"]; local ok, px, w, h = pcall(function() return s:pixels() end)
    f:write(string.format("pixels ok=%s len=%s w=%s h=%s\n", tostring(ok), ok and #px or tostring(px), tostring(w), tostring(h))); f:close()
  end
  if t0 and (n - t0) % 30 == 0 then
    local t = {}
    for b = 0, 9 do local a = 0x6700 + 0x20 * b; if r(a) & 1 == 1 then t[#t+1] = r(a + 3) .. "," .. r(a + 5) end end
    trace[#trace+1] = table.concat(t, ";")
  end
  if t0 and n - t0 >= 900 then
    local f = io.open(OUT, "a"); f:write("trace " .. table.concat(trace, "|") .. "\n")
    if os.getenv("DUMP") then local px, w, h = mac.screens[":screen"]:pixels(); local g = io.open(os.getenv("DUMP"), "wb"); g:write(px); g:close(); f:write(string.format("dump %d %d\n", w, h)) end
    f:close(); mac:exit()
  end
end)
