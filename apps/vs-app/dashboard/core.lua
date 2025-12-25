local core = {}

function core.init()
    local config      = require("config.defaults")
    local peripherals = require("lib.peripherals")
    peripherals.init(config)
    local display    = require("lib.display")
    local input      = require("lib.input")
    local net        = require("lib.net")
    local protocol   = require("lib.protocol")
    local state      = require("lib.state")
    local util       = require("lib.util")

    core.config      = config
    core.display     = display
    core.input       = input
    core.net         = net
    core.peripherals = peripherals
    core.protocol    = protocol
    core.state       = state
    core.util        = util

    display.init(config)

    return core
end

return core
