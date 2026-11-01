-- Rules the program may tune. The human limits in agent.lua are not in here on purpose.
return {
  anticipate_top = true, -- knows when he has reached the top of a ladder before seeing it
  exact_arc = false,   -- uses the measured arc for barrels falling off girder ends
  ladder3 = 131,       -- the shorter way up from floor 3, which also shortens floor 4
  arrive3 = 1,
  arrive5 = 1,         -- waiting past this ladder lets barrels coming down it roll away from him
  horizon = 130,       -- frames ahead it plans
  decide_every = 2,    -- frames between decisions
  -- jumps to try for, best first: sideways clearance, frames clear after landing, ignore "might" barrels
  -- (contact is within 5 sideways; he needs about 25 frames after landing to see it and jump again)
  jump_tries = {{10, 28, false}, {8, 28, false}, {8, 16, true}, {7, 8, true}},
  jump_within = 20,    -- only consider a jump when a barrel will reach him within this many frames
  maybe_within = 40,   -- hold back from a barrel that might drop onto him this soon
  hold_clear = 24,     -- standing still or backing off has to stay clear this long
  defer = 8,           -- frames it may hold off a jump that would still work
  must_act = 14,       -- frames before a predicted hit when it stops deferring
  throw_every = 80,    -- Kong's soonest usual next barrel, in frames
  standoff = 10,       -- how far past a ladder to wait
  look_ahead = 50,     -- how far ahead it checks the way it's walking
  after_climb = 24,    -- a climb has to stay clear this long after reaching the top
  clear_x = 8,         -- keep this far from a barrel sideways (contact is within 5)
  clear_y = 9,         -- and this far vertically (contact is within 7)
  land_wait = 6,       -- frames after a jump before he can jump again
  plan_tail = 20,      -- a plan must stay clear this long after its last move, to leave time to react
  need_clear = 3,      -- pixels of clearance that count as close to a "might" barrel
  walk_clear = 6,      -- with this much room there is nothing to think about
  min_clear = 4,       -- a plan needs at least this much clearance to count as safe
  w_later = 0.3,       -- slight preference for moving later, when more is known
  w_thin = 100,        -- cost of a plan with less than min_clear
  clear_cap = 6,       -- extra clearance beyond this earns nothing
  w_clear = 10,        -- value of each pixel of clearance
  w_prog = 40,         -- value of moving towards the goal
  w_jump = 15,         -- cost of each jump
  w_risk = 500,        -- cost of going near a barrel that might take a ladder
  fire_horizon = 30,   -- fireballs wander, so don't predict them far ahead
  fire_x = 6,          -- contact box, measured
  fire_y = 8,
  fire_spread = 0.1,   -- how much a fireball's possible position grows per frame
}
