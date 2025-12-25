local protocol = {}

local config = require("config.defaults")

-- validate an incoming message
function protocol.validate(msg)
    if type(msg) ~= "table" then return false end
    if msg.key ~= config.securityKey then return false end
    if type(msg.payload) ~= "table" then return false end
    return true
end

-- build a status message to send (optional, Dashboard may not use)
function protocol.buildStatus(state, sensors)
    if type(state) ~= "table" or type(sensors) ~= "table" then return nil end

    local activeGear = {}
    -- Dashboard might not have gearSides mapping; mirror Engine if needed
    for i = 1, 4 do
        activeGear[i] = state.activeGear[i] or false
    end

    return {
        key = config.securityKey,
        payload = {
            speed = state.speed or 0,
            usedStress = state.usedStress or 0,
            stressCapacity = state.stressCapacity or 1,
            currentFuel = state.currentFuel or 0,
            capacityFuel = state.capacityFuel or 0,
            energyPercent = state.energyPercent or 0,
            activeGear = activeGear,
            isOff = state.isOff or false
        }
    }
end

return protocol
