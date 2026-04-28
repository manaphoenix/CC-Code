--- Event Handling Module for VS Receiver Dashboard
--- Handles all user input and system events
--- @class Events
--- @field config Config Configuration settings
--- @field display Display Display manager
--- @field peripherals Peripherals Peripheral manager
--- @field status Status Status manager
--- @field tuningState number Current tuning menu state
--- @field locked boolean Whether system is locked
--- @field running boolean Whether main loop should continue

local Events = {}

--- Create new Events instance
--- @param config Config Configuration settings
--- @param display Display Display manager
--- @param peripherals Peripherals Peripheral manager
--- @param status Status Status manager
--- @return Events events Events instance
function Events.new(config, display, peripherals, status)
    local self = setmetatable({}, { __index = Events })
    self.config = config
    self.display = display
    self.peripherals = peripherals
    self.status = status
    self.tuningState = 0 -- 0 = locked, 1 = menu, 2 = transmission, 3 = suspension
    self.locked = true
    self.running = true
    return self
end

--- Initialize event system
--- @return boolean success Whether initialization succeeded
function Events:init()
    self.tuningState = 0
    self.locked = true
    self.running = true
    return true
end

--- Handle keyboard events
--- @param key number Key code
--- @return boolean handled Whether event was handled
function Events:handleKeyEvent(key)
    if self.locked then return false end

    if key == keys.c then
        self.locked = true
        self.tuningState = 0
        self.display:drawLockScreen()
        return true
    end

    return false
end

--- Handle mouse click events on terminal
--- @param button number Mouse button
--- @param x number X coordinate
--- @param y number Y coordinate
--- @return boolean handled Whether event was handled
function Events:handleMouseClick(button, x, y)
    if self.locked then return false end

    if y == 1 then
        local termWidth = self.display.termSize.width

        -- Exit button
        if x >= 1 and x <= 4 then
            self.running = false
            return true
            -- Lock button
        elseif x >= termWidth - 3 and x <= termWidth then
            self.locked = true
            self.tuningState = 0
            self.display:drawLockScreen()
            return true
        end
    end

    return false
end

--- Handle monitor touch events
--- @param side string Monitor side
--- @param x number X coordinate
--- @param y number Y coordinate
--- @return boolean handled Whether event was handled
function Events:handleMonitorTouch(side, x, y)
    if self.locked then return false end

    if side ~= self.config.tuning_monitor_side then return false end

    local tuningSize = self.display.tuningSize
    local yposCentered = math.floor(tuningSize.height / 2)

    if self.tuningState == 1 then -- Main menu
        if y == yposCentered + 1 then
            self.tuningState = 2
            self.display:drawTransmissionMenu()
            return true
        elseif y == yposCentered + 2 then
            self.tuningState = 3
            self.display:drawSuspensionMenu()
            return true
        end
    elseif self.tuningState == 2 then -- Transmission menu
        if y == 1 and x <= 2 then     -- Back button
            self.tuningState = 1
            self.display:drawMenu()
            return true
        end
    elseif self.tuningState == 3 then -- Suspension menu
        if y == 1 and x <= 2 then     -- Back button
            self.tuningState = 1
            self.display:drawMenu()
            return true
        end
    end

    return false
end

--- Handle modem message events
--- @param message table Message data
--- @return boolean handled Whether event was handled
function Events:handleModemMessage(message)
    -- Verify security key
    if not message.key or message.key ~= self.config.securityKey then
        return false
    end

    local data = message.payload
    if not data then return false end

    -- Update status with received data
    self.status:updateFromMessage(data)

    -- Refresh display
    local fuelToggle = self.status:getFuelToggle()
    local newFuelToggle, success = self.display:updateStatusMonitor(self.status:getData(), fuelToggle)
    if success then
        self.status:setFuelToggle(newFuelToggle)
    end

    -- Update last received time
    self.status:setLastReceived(os.clock())

    -- Debug output if enabled
    if self.config.dbgMessages then
        self:debugPrintStatus()
    end

    return true
end

--- Handle redstone events for unlocking
--- @return boolean handled Whether event was handled
function Events:handleRedstoneEvent()
    if not self.locked then return false end

    if rs.getInput("left") then
        self.locked = false
        self.tuningState = 1
        self.display:drawMenu()
        return true
    end

    return false
end

--- Main event handler
--- @param event table Event data
--- @return boolean handled Whether event was handled
function Events:handleEvent(event)
    local ev = event[1]

    if ev == "key" then
        return self:handleKeyEvent(event[2])
    elseif ev == "mouse_click" then
        return self:handleMouseClick(event[2], event[3], event[4])
    elseif ev == "monitor_touch" then
        return self:handleMonitorTouch(event[2], event[3], event[4])
    elseif ev == "modem_message" then
        return self:handleModemMessage(event[5])
    elseif ev == "redstone" then
        return self:handleRedstoneEvent()
    end

    return false
end

--- Print debug status information
function Events:debugPrintStatus()
    term.setCursorPos(1, 2)
    print("Gear states:")
    local format = "\t%s: %s"
    local statusData = self.status:getData()

    for i, v in ipairs(statusData.activeGear) do
        print(string.format(format, i, v))
    end

    print("Other data:")
    for key, value in pairs(statusData) do
        if type(value) ~= "table" then
            print(string.format(format, key, value))
        end
    end

    -- Time since last message
    local lastRec = os.clock() - self.status:getLastReceived()
    print("Last received: " .. math.floor(lastRec * 100) / 100 .. " seconds ago")

    -- Current time
    print("Time: " .. os.date("%I:%M:%S %p"))
end

--- Check if application should continue running
--- @return boolean running Whether to continue running
function Events:shouldRun()
    return self.running
end

--- Get current tuning state
--- @return number state Current tuning state
function Events:getTuningState()
    return self.tuningState
end

--- Set tuning state
--- @param state number New tuning state
function Events:setTuningState(state)
    self.tuningState = state
end

--- Get lock status
--- @return boolean locked Whether system is locked
function Events:isLocked()
    return self.locked
end

--- Set lock status
--- @param locked boolean New lock status
function Events:setLocked(locked)
    self.locked = locked
end

--- Unlock the system
--- @return boolean success Whether unlock succeeded
function Events:unlock()
    if not self.locked then return true end

    self.locked = false
    self.tuningState = 1
    self.display:drawMenu()
    return true
end

--- Lock the system
--- @return boolean success Whether lock succeeded
function Events:lock()
    if self.locked then return true end

    self.locked = true
    self.tuningState = 0
    self.display:drawLockScreen()
    return true
end

--- Stop the application
function Events:stop()
    self.running = false
end

return Events
