--- Peripheral Management Module for VS Receiver Dashboard
--- Handles initialization and management of all hardware peripherals
--- @class Peripherals
--- @field config Config Configuration settings
--- @field statusMon Monitor? Status monitor peripheral
--- @field tuningMon Monitor? Tuning monitor peripheral
--- @field enderModem Modem? Ender modem peripheral

local Peripherals = {}

--- Create new Peripherals instance
--- @param config Config Configuration settings
--- @return Peripherals peripherals Peripherals instance
function Peripherals.new(config)
    local self = setmetatable({}, { __index = Peripherals })
    self.config = config
    self.statusMon = nil
    self.tuningMon = nil
    self.enderModem = nil
    return self
end

--- Initialize all required peripherals
--- @return boolean success Whether initialization succeeded
--- @return string? error Error message if failed
--- @return table? peripherals Initialized peripheral objects
function Peripherals:init()
    local peripherals = {}

    -- Initialize status monitor
    self.statusMon = peripheral.wrap(self.config.status_monitor_side)
    if not self.statusMon then
        return false, "Status monitor not found on side " .. self.config.status_monitor_side
    end
    peripherals.statusMon = self.statusMon

    -- Initialize tuning monitor
    self.tuningMon = peripheral.wrap(self.config.tuning_monitor_side)
    if not self.tuningMon then
        return false, "Tuning monitor not found on side " .. self.config.tuning_monitor_side
    end
    peripherals.tuningMon = self.tuningMon

    -- Initialize ender modem
    self.enderModem = peripheral.wrap(self.config.ender_modem_side)
    if not self.enderModem then
        return false, "Ender modem not found on side " .. self.config.ender_modem_side
    end
    peripherals.enderModem = self.enderModem

    -- Open modem channel
    self.enderModem.open(self.config.modemCode)

    return true, nil, peripherals
end

--- Validate that all peripherals are still available
--- @return boolean isValid Whether all peripherals are valid
--- @return string? error Error message if invalid
function Peripherals:validate()
    -- Check status monitor
    if not self.statusMon then
        return false, "Status monitor is not initialized"
    end

    -- Check tuning monitor
    if not self.tuningMon then
        return false, "Tuning monitor is not initialized"
    end

    -- Check ender modem
    if not self.enderModem then
        return false, "Ender modem is not initialized"
    end

    -- Test peripheral responsiveness
    local success, err = pcall(function()
        self.statusMon.getSize()
        self.tuningMon.getSize()
        self.enderModem.isOpen(self.config.modemCode)
    end)

    if not success then
        return false, "Peripheral communication failed: " .. tostring(err)
    end

    return true
end

--- Get monitor dimensions
--- @param monitorType string "status" or "tuning"
--- @return number? width Monitor width
--- @return number? height Monitor height
--- @return string? error Error message if failed
function Peripherals:getMonitorSize(monitorType)
    local monitor
    if monitorType == "status" then
        monitor = self.statusMon
    elseif monitorType == "tuning" then
        monitor = self.tuningMon
    else
        return nil, nil, "Invalid monitor type: " .. tostring(monitorType)
    end

    if not monitor then
        return nil, nil, monitorType .. " monitor is not initialized"
    end

    local success, width, height = pcall(function()
        return monitor.getSize()
    end)

    if not success then
        return nil, nil, "Failed to get " .. monitorType .. " monitor size"
    end

    return width, height
end

--- Send message via ender modem
--- @param targetChannel number Channel to send message to
--- @param message table Message payload
--- @return boolean success Whether message was sent
--- @return string? error Error message if failed
function Peripherals:sendMessage(targetChannel, message)
    if not self.enderModem then
        return false, "Ender modem is not initialized"
    end

    local success, err = pcall(function()
        self.enderModem.transmit(targetChannel, self.config.modemCode, {
            key = self.config.securityKey,
            payload = message
        })
    end)

    if not success then
        return false, "Failed to send message: " .. tostring(err)
    end

    return true
end

--- Check if modem channel is open
--- @param channel number Channel to check
--- @return boolean isOpen Whether channel is open
--- @return string? error Error message if check failed
function Peripherals:isChannelOpen(channel)
    if not self.enderModem then
        return false, "Ender modem is not initialized"
    end

    local success, isOpen = pcall(function()
        return self.enderModem.isOpen(channel)
    end)

    if not success then
        return false, "Failed to check channel status: " .. tostring(isOpen)
    end

    return isOpen
end

--- Reopen modem channel if closed
--- @return boolean success Whether channel was opened
--- @return string? error Error message if failed
function Peripherals:ensureChannelOpen()
    if not self.enderModem then
        return false, "Ender modem is not initialized"
    end

    local isOpen, err = self:isChannelOpen(self.config.modemCode)
    if not isOpen then
        local success, openErr = pcall(function()
            self.enderModem.open(self.config.modemCode)
        end)

        if not success then
            return false, "Failed to open channel: " .. tostring(openErr)
        end
    end

    return true
end

--- Get peripheral information for debugging
--- @return table info Peripheral information
function Peripherals:getInfo()
    local info = {
        statusMonitor = {
            side = self.config.status_monitor_side,
            available = self.statusMon ~= nil
        },
        tuningMonitor = {
            side = self.config.tuning_monitor_side,
            available = self.tuningMon ~= nil
        },
        enderModem = {
            side = self.config.ender_modem_side,
            available = self.enderModem ~= nil,
            channel = self.config.modemCode,
            channelOpen = false
        }
    }

    -- Check if modem channel is open
    if self.enderModem then
        info.enderModem.channelOpen = self:isChannelOpen(self.config.modemCode)
    end

    return info
end

--- Cleanup peripherals (close channels, reset state)
--- @return boolean success Whether cleanup succeeded
function Peripherals:cleanup()
    local success = true

    -- Close modem channel
    if self.enderModem then
        local ok, err = pcall(function()
            self.enderModem.close(self.config.modemCode)
        end)
        if not ok then
            success = false
        end
    end

    -- Clear monitors
    if self.statusMon then
        pcall(function()
            self.statusMon.clear()
        end)
    end

    if self.tuningMon then
        pcall(function()
            self.tuningMon.clear()
        end)
    end

    return success
end

return Peripherals
