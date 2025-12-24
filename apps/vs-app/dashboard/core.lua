--- Core Code
--- Handles initialization and main loop

local core = {}

function core.run()
    -- start by loading utilities
    local util = require("lib.util")

    -- then load the config
    local config = require("config.defaults")

    -- finally load the rest of the libs, in a sensical order
    local peripherals = require("lib.peripherals")
    local state = require("lib.state")
    local net = require("lib.net")
    local protocol = require("lib.protocol")
    local display = require("lib.display")
    local input = require("lib.input")

    -- if all requires don't error, add them to the core
    core.util = util
    core.config = config
    core.peripherals = peripherals
    core.state = state
    core.net = net
    core.protocol = protocol
    core.display = display
    core.input = input
end

return core
