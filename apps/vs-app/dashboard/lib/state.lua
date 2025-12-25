local state = {}

local statusConfig = {
    activeGear = { false, false, true, false },
    speed = 0,
    usedStress = 0,
    stressCapacity = 1,
    currentFuel = 1,
    capacityFuel = 24000,
    energyPercent = 0,
    isOff = false
}

function state.get() return statusConfig end

function state.updateFromMessage(data)
    for k, v in pairs(data) do
        if statusConfig[k] ~= nil then statusConfig[k] = v end
    end
end

return state
