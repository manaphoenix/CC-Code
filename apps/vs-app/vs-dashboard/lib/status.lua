--- Status Management Module for VS Receiver Dashboard
--- Handles system status data and message processing
--- @class Status
--- @field config Config Configuration settings
--- @field data table Current system status data
--- @field fuelToggle boolean Current fuel toggle state
--- @field lastReceived number Timestamp of last received message

local Status = {}

--- Create new Status instance
--- @param config Config Configuration settings
--- @return Status status Status instance
function Status.new(config)
    local self = setmetatable({}, { __index = Status })
    self.config = config

    -- Initialize status data with default values
    self.data = {
        activeGear = {
            [1] = false,
            [2] = false,
            [3] = true,
            [4] = false
        },
        speed = 0,
        usedStress = 0,
        stressCapacity = 1,
        currentFuel = 1,
        capacityFuel = 24000,
        energyPercent = 0,
        isOff = false
    }

    self.fuelToggle = false
    self.lastReceived = os.clock()

    return self
end

--- Initialize status system
--- @return boolean success Whether initialization succeeded
function Status:init()
    -- Reset to default state
    self.data = {
        activeGear = {
            [1] = false,
            [2] = false,
            [3] = true,
            [4] = false
        },
        speed = 0,
        usedStress = 0,
        stressCapacity = 1,
        currentFuel = 1,
        capacityFuel = 24000,
        energyPercent = 0,
        isOff = false
    }

    self.fuelToggle = false
    self.lastReceived = os.clock()

    return true
end

--- Update status from received message
--- @param messageData table Message payload data
--- @return boolean success Whether update was processed
function Status:updateFromMessage(messageData)
    if not messageData then return false end

    -- Update all status fields if provided
    if messageData.isOff ~= nil then
        self.data.isOff = messageData.isOff
    end

    if messageData.activeGear then
        for i = 1, 4 do
            if messageData.activeGear[i] ~= nil then
                self.data.activeGear[i] = messageData.activeGear[i]
            end
        end
    end

    if messageData.speed ~= nil then
        self.data.speed = messageData.speed
    end

    if messageData.usedStress ~= nil then
        self.data.usedStress = messageData.usedStress
    end

    if messageData.stressCapacity ~= nil then
        self.data.stressCapacity = messageData.stressCapacity
    end

    if messageData.currentFuel ~= nil then
        self.data.currentFuel = messageData.currentFuel
    end

    if messageData.capacityFuel ~= nil then
        self.data.capacityFuel = messageData.capacityFuel
    end

    if messageData.energyPercent ~= nil then
        self.data.energyPercent = messageData.energyPercent
    end

    return true
end

--- Get current status data
--- @return table data Current status data
function Status:getData()
    return self.data
end

--- Get gear state for specific gear
--- @param gearNum number Gear number (1-4)
--- @return boolean? state Gear state or nil if invalid
function Status:getGearState(gearNum)
    if gearNum < 1 or gearNum > 4 then return nil end
    return self.data.activeGear[gearNum]
end

--- Set gear state for specific gear
--- @param gearNum number Gear number (1-4)
--- @param state boolean New gear state
--- @return boolean success Whether operation succeeded
function Status:setGearState(gearNum, state)
    if gearNum < 1 or gearNum > 4 then return false end

    self.data.activeGear[gearNum] = state
    return true
end

--- Get current speed
--- @return number speed Current speed in RPM
function Status:getSpeed()
    return self.data.speed
end

--- Set current speed
--- @param speed number New speed in RPM
function Status:setSpeed(speed)
    self.data.speed = speed
end

--- Get stress information
--- @return number usedStress Current stress usage
--- @return number stressCapacity Maximum stress capacity
--- @return number percent Stress usage percentage
function Status:getStress()
    local percent = 0
    if self.data.stressCapacity > 0 then
        percent = math.floor(self.data.usedStress / self.data.stressCapacity * 100)
    end
    return self.data.usedStress, self.data.stressCapacity, percent
end

--- Set stress information
--- @param usedStress number Current stress usage
--- @param stressCapacity number Maximum stress capacity
function Status:setStress(usedStress, stressCapacity)
    if usedStress ~= nil then
        self.data.usedStress = usedStress
    end
    if stressCapacity ~= nil then
        self.data.stressCapacity = stressCapacity
    end
end

--- Get fuel information
--- @return number currentFuel Current fuel amount
--- @return number capacityFuel Maximum fuel capacity
--- @return number percent Fuel usage percentage
function Status:getFuel()
    local percent = 0
    if self.data.capacityFuel > 0 then
        percent = math.floor(self.data.currentFuel / self.data.capacityFuel * 100)
    end
    return self.data.currentFuel, self.data.capacityFuel, percent
end

--- Set fuel information
--- @param currentFuel number Current fuel amount
--- @param capacityFuel number Maximum fuel capacity
function Status:setFuel(currentFuel, capacityFuel)
    if currentFuel ~= nil then
        self.data.currentFuel = currentFuel
    end
    if capacityFuel ~= nil then
        self.data.capacityFuel = capacityFuel
    end
end

--- Get energy information
--- @return number percent Current energy percentage
function Status:getEnergy()
    return self.data.energyPercent
end

--- Set energy percentage
--- @param percent number New energy percentage
function Status:setEnergy(percent)
    self.data.energyPercent = percent
end

--- Get system power state
--- @return boolean isOff Whether system is off
function Status:isOff()
    return self.data.isOff
end

--- Set system power state
--- @param isOff boolean New power state
function Status:setPowerState(isOff)
    self.data.isOff = isOff
end

--- Get fuel toggle state
--- @return boolean fuelToggle Current fuel toggle state
function Status:getFuelToggle()
    return self.fuelToggle
end

--- Set fuel toggle state
--- @param toggle boolean New fuel toggle state
function Status:setFuelToggle(toggle)
    self.fuelToggle = toggle
end

--- Get last received timestamp
--- @return number timestamp Last received message timestamp
function Status:getLastReceived()
    return self.lastReceived
end

--- Set last received timestamp
--- @param timestamp number New timestamp
function Status:setLastReceived(timestamp)
    self.lastReceived = timestamp
end

--- Get time since last message
--- @return number seconds Seconds since last message
function Status:getTimeSinceLastMessage()
    return os.clock() - self.lastReceived
end

--- Check if system is in valid state
--- @return boolean isValid Whether system state is valid
--- @return string? error Error message if invalid
function Status:validateState()
    -- Validate gear states
    if type(self.data.activeGear) ~= "table" then
        return false, "Gear states must be a table"
    end

    for i = 1, 4 do
        if type(self.data.activeGear[i]) ~= "boolean" then
            return false, "Gear " .. i .. " state must be boolean"
        end
    end

    -- Validate numeric values
    local numericFields = {
        speed = "number",
        usedStress = "number",
        stressCapacity = "number",
        currentFuel = "number",
        capacityFuel = "number",
        energyPercent = "number"
    }

    for field, expectedType in pairs(numericFields) do
        if type(self.data[field]) ~= expectedType then
            return false, field .. " must be " .. expectedType
        end
    end

    -- Validate ranges
    if self.data.speed < 0 then
        return false, "Speed cannot be negative"
    end

    if self.data.usedStress < 0 then
        return false, "Used stress cannot be negative"
    end

    if self.data.stressCapacity <= 0 then
        return false, "Stress capacity must be positive"
    end

    if self.data.currentFuel < 0 then
        return false, "Current fuel cannot be negative"
    end

    if self.data.capacityFuel <= 0 then
        return false, "Fuel capacity must be positive"
    end

    if self.data.energyPercent < 0 or self.data.energyPercent > 100 then
        return false, "Energy percent must be between 0 and 100"
    end

    return true
end

--- Get status summary for debugging
--- @return table summary Status summary
function Status:getSummary()
    local usedStress, stressCapacity, stressPercent = self:getStress()
    local currentFuel, capacityFuel, fuelPercent = self:getFuel()

    return {
        gears = {
            active = self.data.activeGear,
            count = self:getActiveGearCount()
        },
        speed = self.data.speed,
        stress = {
            used = usedStress,
            capacity = stressCapacity,
            percent = stressPercent
        },
        fuel = {
            current = currentFuel,
            capacity = capacityFuel,
            percent = fuelPercent
        },
        energy = self.data.energyPercent,
        power = {
            isOff = self.data.isOff,
            lastMessage = self:getTimeSinceLastMessage()
        }
    }
end

--- Get count of active gears
--- @return number count Number of active gears
function Status:getActiveGearCount()
    local count = 0
    for i = 1, 4 do
        if self.data.activeGear[i] then
            count = count + 1
        end
    end
    return count
end

--- Reset status to defaults
function Status:reset()
    self:init()
end

return Status
