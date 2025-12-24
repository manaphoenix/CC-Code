-- VS-Dashboard Core
-- Handles initialization and main loop

-- Load shared utilities first
local util        = require("lib.util")

-- Load dependencies
local peripherals = require("lib.peripherals")
local state       = require("lib.state")
local net         = require("lib.net")
local display     = require("lib.display")
local input       = require("lib.input")
local protocol    = require("lib.protocol")

local Dashboard   = {}

function Dashboard.run()
    print("Starting VS-Dashboard...")

    -- Initialize peripherals (monitors, input devices)
    peripherals.init()

    -- Load last received state
    state.load()

    -- Main loop
    local running = true
    while running do
        local event = { os.pullEvent() }
        -- handle input, mouse, and messages
        input.handle(event)
        protocol.handleEvent(event)
        display.update(state.get())
        -- optional: save cache
        state.save()
    end
end

return Dashboard
