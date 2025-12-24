-- core.lua
-- Handles initialization and wiring

local core = {}

function core.init()
    -- Load modules
    local util        = require("lib.util")
    local config      = require("config.defaults")
    local peripherals = require("lib.peripherals")
    local state       = require("lib.state")
    local net         = require("lib.net")
    local protocol    = require("lib.protocol")
    local snapshot    = require("lib.snapshot")
    local apply       = require("lib.apply")

    -- Store modules inside core for easy access
    core.util         = util
    core.config       = config
    core.peripherals  = peripherals
    core.state        = state
    core.net          = net
    core.protocol     = protocol
    core.snapshot     = snapshot
    core.apply        = apply

    -- Load saved state (if any)
    local savedState  = snapshot.load()
    if savedState then
        state.set(savedState)
    end

    return core
end

return core
