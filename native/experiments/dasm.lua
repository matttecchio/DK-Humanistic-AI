-- With MAME started with -debug: writes the game's whole program ROM as Z80 assembly, then quits.
local done = false
emu.register_frame_done(function()
  if done then return end
  done = true
  local d = manager.machine.debugger
  d:command("dasm " .. os.getenv("DASM_OUT") .. ",0,4000")
  manager.machine:exit()
end)
