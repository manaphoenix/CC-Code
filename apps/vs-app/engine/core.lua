-- VS-Engine Core
-- Handles initialization and main loop

-- Load shared utilities first
local util        = require("lib.util")

-- Load dependencies
local peripherals = require("lib.peripherals")
local state       = require("lib.state")
local apply       = require("lib.apply")
local net         = require("lib.net")
local protocol    = require("lib.protocol")
local snapshot    = require("lib.snapshot")

local Engine      = {}

function Engine.run()
    print("Starting VS-Engine...")

    -- Initialize peripherals
    peripherals.init()

    -- Load state
    state.load()

    -- Main loop
    local running = true
    while running do
        local event = { os.pullEvent() }
        -- handle events through net/protocol
        protocol.handleEvent(event)
        -- update peripherals/state if needed
        apply.update()
        state.save()
    end
end

return Engine
