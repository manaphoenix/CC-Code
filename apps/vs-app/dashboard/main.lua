-- VS-Dashboard main.lua
-- Entry point

local core        = require("core").init()
local input       = core.input
local display     = core.display
local state       = core.state
local config      = core.config
local peripherals = core.peripherals

-- Initialize monitors and display
display.drawLockScreen(config.lockText)

local running = true

-- Main event loop
while running do
    local event = { os.pullEventRaw() }
    running = input.handleEvent(event)
end

-- Cleanup on exit
peripherals.clearAll()
