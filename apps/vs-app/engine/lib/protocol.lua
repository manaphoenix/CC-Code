local protocol = {}

local config = require("config.defaults")

-- build a status message payload
function protocol.buildStatus(state, sensors)
    if type(state) ~= "table" or type(sensors) ~= "table" then
        return nil
    end

    -- active gear mapping (matches old logic)
    local activeGear = {}
    for i = 1, 4 do
        local side = config.gearSides[i]
        activeGear[i] = side and state[side] or false
    end

    return {
        key = config.securityKey,
        payload = {
            speed = sensors.speed,
            usedStress = sensors.usedStress,
            stressCapacity = sensors.stressCapacity,
            currentFuel = sensors.currentFuel,
            capacityFuel = sensors.capacityFuel,
            energyPercent = sensors.energyPercent,
            activeGear = activeGear,
            isOff = state.isOff
        }
    }
end

-- validate an incoming message
function protocol.validate(msg)
    if type(msg) ~= "table" then
        return false
    end

    if msg.key ~= config.securityKey then
        return false
    end

    if type(msg.payload) ~= "table" then
        return false
    end

    return true
end

return protocol
