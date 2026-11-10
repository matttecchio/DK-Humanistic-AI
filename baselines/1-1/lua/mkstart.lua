-- Boots with given coin/start timing and saves the first playable frame, so games begin from different random seeds.
local mac = manager.machine
local COIN, START, NAME = tonumber(os.getenv("COIN")), tonumber(os.getenv("START")), os.getenv("NAME")
local sp, n = nil, 0
emu.register_frame_done(function()
  if not sp then local c = mac.devices[":maincpu"]; if not c then return end; sp = c.spaces["program"] end
  n = n + 1
  local p = mac.ioport.ports[":IN2"]
  if n == COIN then p.fields["Coin 1"]:set_value(1) elseif n == COIN + 30 then p.fields["Coin 1"]:set_value(0) end
  if n == START then p.fields["1 Player Start"]:set_value(1) elseif n == START + 30 then p.fields["1 Player Start"]:set_value(0) end
  if n > START + 30 and sp:readv_u8(0x600A) == 0x0C then mac:save(NAME); mac:exit() end
end)
