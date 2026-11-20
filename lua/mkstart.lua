-- Boots with given coin/start timing and saves the first playable frame, so games begin from different random seeds.
-- For LEVEL above 1 it asks the game's own "board cleared" step until that level's first barrel board comes up,
-- so the bonus, difficulty and board order are the ones the game itself sets.
local mac = manager.machine
local COIN, START, NAME = tonumber(os.getenv("COIN")), tonumber(os.getenv("START")), os.getenv("NAME")
local LEVEL = tonumber(os.getenv("LEVEL") or 1)
local BOARD = tonumber(os.getenv("BOARD") or 1)   -- (2026-11-15) 4: carry on, the same way, to that level's rivet board
local sp, n, played = nil, 0, 0
emu.register_frame_done(function()
  if not sp then local c = mac.devices[":maincpu"]; if not c then return end; sp = c.spaces["program"] end
  n = n + 1
  local p = mac.ioport.ports[":IN2"]
  if n == COIN then p.fields["Coin 1"]:set_value(1) elseif n == COIN + 30 then p.fields["Coin 1"]:set_value(0) end
  if n == START then p.fields["1 Player Start"]:set_value(1) elseif n == START + 30 then p.fields["1 Player Start"]:set_value(0) end
  if n > START + 30 and sp:readv_u8(0x600A) == 0x0C then
    if sp:readv_u8(0x6229) == LEVEL and sp:readv_u8(0x6227) == BOARD then
      if LEVEL > 1 or BOARD ~= 1 then sp:write_u8(0x6228, 3) end   -- the skipped boards leave an extra life behind
      mac:save(NAME); mac:exit()
    else
      played = played + 1
      if played == 30 then sp:write_u8(0x600A, 0x16); played = 0 end
    end
  end
end)
