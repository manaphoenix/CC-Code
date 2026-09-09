--- Display Module for VS Receiver Dashboard
--- Handles all monitor drawing and UI rendering
--- @class Display
--- @field statusMon Monitor Status monitor peripheral
--- @field tuningMon Monitor Tuning monitor peripheral
--- @field config Config Configuration settings
--- @field termSize {width: number, height: number} Terminal dimensions
--- @field tuningSize {width: number, height: number} Tuning monitor dimensions

local Display = {}

--- Create new Display instance
--- @param peripherals table Peripheral objects
--- @param config Config Configuration settings
--- @return Display display Display instance
function Display.new(peripherals, config)
    local self = setmetatable({}, { __index = Display })

    local mx, my = term.getSize()

    self.statusMon = peripherals.statusMon
    self.tuningMon = peripherals.tuningMon
    self.config = config
    self.termSize = { width = mx, height = my }
    self.tuningSize = { width = 0, height = 0 }

    if self.tuningMon then
        self.tuningSize.width, self.tuningSize.height = self.tuningMon.getSize()
    end

    return self
end

--- Initialize display with peripherals and apply settings
--- @return boolean success Whether initialization succeeded
--- @return string? error Error message if failed
function Display:init()
    if not self.statusMon or not self.tuningMon then
        return false, "Missing required monitors"
    end

    -- Apply text scales
    self.statusMon.setTextScale(self.config.statusTextScale)
    self.tuningMon.setTextScale(self.config.tuningTextScale)

    -- Apply color overrides
    for colName, col in pairs(self.config.statusOverrides) do
        self.statusMon.setPaletteColor(colors[colName], col)
    end

    for colName, col in pairs(self.config.tuningOverrides) do
        self.tuningMon.setPaletteColor(colors[colName], col)
    end

    return true
end

--- Write text to monitor with colors and move to next line
--- @param monitor Monitor Monitor to write to
--- @param text string Text to write
--- @param fg number Foreground color
--- @param bg number Background color
local function writeToMonitor(monitor, text, fg, bg)
    monitor.setTextColor(fg)
    monitor.setBackgroundColor(bg)
    monitor.write(text)

    local cx, cy = monitor.getCursorPos()
    monitor.setCursorPos(1, cy + 1)
end

--- Write centered text to monitor
--- @param monitor Monitor Monitor to write to
--- @param text string Text to write
--- @param fg number Foreground color
--- @param bg number Background color
local function writeToMonitorCentered(monitor, text, fg, bg)
    local _, cy = monitor.getCursorPos()
    local mx, _ = monitor.getSize()

    local x = math.floor((mx - #text) / 2) + 1
    monitor.setCursorPos(x, cy)

    writeToMonitor(monitor, text, fg, bg)
end

--- Draw transmission menu on tuning monitor
--- @return boolean success Whether drawing succeeded
function Display:drawTransmissionMenu()
    if not self.tuningMon then return false end

    self.tuningMon.clear()
    self.tuningMon.setCursorPos(1, 1)
    writeToMonitor(self.tuningMon, "<<", colors.blue, colors.black)
    self.tuningMon.setCursorPos(1, 1)
    writeToMonitorCentered(self.tuningMon, "Transmission Menu", colors.yellow, colors.black)

    self.tuningMon.setCursorPos(1, 3)
    for i = 1, 4 do
        local gearText = i < 4 and "[Gear " .. i .. "]" or "[Gear " .. i .. "(R)]"
        writeToMonitorCentered(self.tuningMon, gearText, colors.blue, colors.black)
    end

    return true
end

--- Draw suspension menu on tuning monitor
--- @return boolean success Whether drawing succeeded
function Display:drawSuspensionMenu()
    if not self.tuningMon then return false end

    self.tuningMon.clear()
    self.tuningMon.setCursorPos(1, 1)
    writeToMonitor(self.tuningMon, "<<", colors.blue, colors.black)
    self.tuningMon.setCursorPos(1, 1)
    writeToMonitorCentered(self.tuningMon, "Suspension Menu", colors.yellow, colors.black)

    self.tuningMon.setCursorPos(1, 3)
    writeToMonitorCentered(self.tuningMon, "[Increase]", colors.blue, colors.black)

    self.tuningMon.setCursorPos(1, 4)
    writeToMonitorCentered(self.tuningMon, "[Decrease]", colors.blue, colors.black)

    return true
end

--- Draw main menu on terminal and tuning monitor
--- @return boolean success Whether drawing succeeded
function Display:drawMenu()
    -- Terminal menu
    term.clear()
    term.setCursorPos(1, 1)

    local title = "VS Receiver by Manaphoenix v" .. self.config.version
    local width = #title
    local padding = (self.termSize.width - width) / 2

    -- Header bar
    term.setCursorPos(1, 1)
    term.blit((" "):rep(self.termSize.width), ("b"):rep(self.termSize.width), ("b"):rep(self.termSize.width))

    -- Centered title
    term.setCursorPos(padding, 1)
    term.blit(title, ("0"):rep(width), ("b"):rep(width))

    -- Exit and Lock buttons
    term.setCursorPos(1, 1)
    term.blit("Exit", ("0"):rep(4), ("b"):rep(4))
    term.setCursorPos(self.termSize.width - 3, 1)
    term.blit("Lock", ("0"):rep(4), ("b"):rep(4))
    term.setCursorPos(1, 2)

    -- Tuning monitor menu
    if self.tuningMon then
        self.tuningMon.clear()
        local centerY = math.floor(self.tuningSize.height / 2)

        self.tuningMon.setCursorPos(1, centerY - 1)
        writeToMonitorCentered(self.tuningMon, "TUNING MENU", colors.yellow, colors.black)

        self.tuningMon.setCursorPos(1, centerY + 1)
        writeToMonitorCentered(self.tuningMon, "[Transmission]", colors.blue, colors.black)

        self.tuningMon.setCursorPos(1, centerY + 2)
        writeToMonitorCentered(self.tuningMon, "[Suspension]", colors.blue, colors.black)
    end

    return true
end

--- Draw lock screen on terminal and tuning monitor
--- @return boolean success Whether drawing succeeded
function Display:drawLockScreen()
    local textWidth = #self.config.lockText
    local textPadding = math.floor((self.termSize.width - textWidth) / 2)

    -- Terminal lock screen
    term.setBackgroundColor(colors.blue)
    term.clear()
    term.setCursorPos(textPadding, self.termSize.height / 2)
    term.write(self.config.lockText)
    term.setBackgroundColor(colors.black)

    -- Tuning monitor lock screen
    if self.tuningMon then
        self.tuningMon.setBackgroundColor(colors.blue)
        self.tuningMon.setTextColor(colors.white)
        self.tuningMon.clear()

        local monHalfX = math.floor(self.tuningSize.width / 2)
        local monHalfY = math.floor(self.tuningSize.height / 2)
        self.tuningMon.setCursorPos(monHalfX - math.floor(textWidth / 2), monHalfY)
        self.tuningMon.write(self.config.lockText)
        self.tuningMon.setBackgroundColor(colors.black)
    end

    return true
end

--- Update status monitor with current system status
--- @param statusData table Current system status
--- @param fuelToggle boolean Current fuel toggle state
--- @return boolean newFuelToggle New fuel toggle state
--- @return boolean success Whether update succeeded
function Display:updateStatusMonitor(statusData, fuelToggle)
    if not self.statusMon then return fuelToggle, false end

    self.statusMon.clear()
    self.statusMon.setCursorPos(1, 1)

    -- Determine colors based on system state
    local scolors = self.config.statusColors
    if not statusData.isOff then
        scolors = {
            inactive = colors.gray,
            active = colors.gray,
            fuel = colors.gray,
            stress = colors.gray,
            speed = colors.gray,
            refillInactive = colors.gray,
            refillActive = colors.gray,
            energy = colors.gray,
        }
    end

    -- Draw gear status
    for gearNum, state in ipairs(statusData.activeGear) do
        local gearText
        if gearNum < 4 then
            gearText = state and ("[Gear " .. gearNum .. "]") or ("Gear " .. gearNum)
        else
            gearText = state and "[Reverse]" or "Reverse"
        end

        local gearColor = state and scolors.active or scolors.inactive
        writeToMonitor(self.statusMon, gearText, gearColor, colors.black)
    end

    -- Draw fuel status
    self.statusMon.setCursorPos(1, 6)
    writeToMonitor(self.statusMon, "Fuel:  " .. statusData.currentFuel .. "/", scolors.fuel, colors.black)
    writeToMonitor(self.statusMon, "       " .. statusData.capacityFuel .. " mb", scolors.fuel, colors.black)

    self.statusMon.setCursorPos(1, 7)
    local newFuelToggle = fuelToggle
    if statusData.currentFuel > 0 then
        writeToMonitor(self.statusMon, "REFILL", scolors.refillInactive, colors.black)
        newFuelToggle = false
    else
        if fuelToggle then
            writeToMonitor(self.statusMon, "REFILL", scolors.refillInactive, colors.black)
            newFuelToggle = false
        else
            writeToMonitor(self.statusMon, "REFILL", scolors.refillActive, colors.black)
            newFuelToggle = true
        end
    end

    -- Draw speed
    self.statusMon.setCursorPos(10, 1)
    writeToMonitor(self.statusMon, "Speed: ", scolors.speed, colors.black)
    self.statusMon.setCursorPos(10, 2)
    writeToMonitor(self.statusMon, statusData.speed .. " RPM", scolors.speed, colors.black)

    -- Draw stress
    self.statusMon.setCursorPos(10, 3)
    writeToMonitor(self.statusMon, "Stress: ", scolors.stress, colors.black)
    self.statusMon.setCursorPos(10, 4)
    local stressPercent = math.floor(statusData.usedStress / statusData.stressCapacity * 100)
    writeToMonitor(self.statusMon, stressPercent .. "%", scolors.stress, colors.black)

    -- Draw energy
    self.statusMon.setCursorPos(1, 9)
    writeToMonitor(self.statusMon, "Battery: ", scolors.energy, colors.black)
    self.statusMon.setCursorPos(1, 10)

    if statusData.isOff then
        local energyAmt = math.floor(statusData.energyPercent / 10)
        local remaining = 10 - energyAmt
        local energyText = ("5"):rep(energyAmt) .. ("8"):rep(remaining)

        local statusBarTxt = (" "):rep(10)
        local txt = string.format("%d%%", statusData.energyPercent)
        local xpos = 5

        statusBarTxt = statusBarTxt:sub(1, xpos - 1) .. txt .. statusBarTxt:sub(xpos + #txt)

        self.statusMon.blit(statusBarTxt, ("0"):rep(10), energyText)
    else
        writeToMonitor(self.statusMon, "Off       ", scolors.energy, colors.black)
    end

    return newFuelToggle, true
end

--- Show loading screen on both monitors
--- @return boolean success Whether loading screen was shown
function Display:showLoadingScreen()
    if self.statusMon then
        self.statusMon.clear()
        self.statusMon.setCursorPos(1, 1)
        self.statusMon.write("Loading...")
    end

    if self.tuningMon then
        self.tuningMon.clear()
        self.tuningMon.setCursorPos(1, 1)
        self.tuningMon.write("Loading...")
    end

    return true
end

--- Clear all monitors
--- @return boolean success Whether monitors were cleared
function Display:clearAll()
    term.clear()
    term.setCursorPos(1, 1)

    if self.statusMon then
        self.statusMon.clear()
    end

    if self.tuningMon then
        self.tuningMon.clear()
    end

    return true
end

return Display
