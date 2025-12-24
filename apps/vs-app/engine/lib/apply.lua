local apply = {}

local config = require("config.defaults")
local peripherals = require("lib.peripherals")

function apply.outputs(state)
    if type(state) ~= "table" then
        return false
    end

    local relay = peripherals.output_relay
    local mapping = config.outputsides

    for side, value in pairs(state) do
        local outputSide = mapping[side]
        if outputSide ~= nil then
            relay.setOutput(outputSide, value)
        end
    end

    return true
end

return apply
