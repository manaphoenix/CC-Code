local display = {}

local statusMon, tuningMon, config, scopy
local fueltog = false

function display.init(conf)
    config            = conf
    local peripherals = require("lib.peripherals")
    statusMon         = peripherals.getStatusMonitor()
    tuningMon         = peripherals.getTuningMonitor()

    scopy             = {}
    for k, v in pairs(conf.statusColors) do scopy[k] = v end
end

-- ===== Helpers =====
local function writeToMonitor(monitor, text, fg, bg)
    monitor.setTextColor(fg)
    monitor.setBackgroundColor(bg)
    monitor.write(text)
    local _, y = monitor.getCursorPos()
    monitor.setCursorPos(1, y + 1)
end

local function writeToMonitorCentered(monitor, text, fg, bg)
    local _, y = monitor.getCursorPos()
    local w, _ = monitor.getSize()
    local x = math.floor((w - #text) / 2) + 1
    monitor.setCursorPos(x, y)
    writeToMonitor(monitor, text, fg, bg)
end

display.writeToMonitor = writeToMonitor
display.writeToMonitorCentered = writeToMonitorCentered

-- ===== Draw Screens =====
function display.drawLockScreen(lockText)
    term.setBackgroundColor(colors.blue)
    term.clear()
    term.setCursorPos(math.floor(term.getSize() / 2 - #lockText / 2), math.floor(term.getSize() / 2))
    term.write(lockText)
    term.setBackgroundColor(colors.black)

    tuningMon.setBackgroundColor(colors.blue)
    tuningMon.setTextColor(colors.white)
    tuningMon.clear()
    local tmx, tmy = tuningMon.getSize()
    tuningMon.setCursorPos(math.floor(tmx / 2 - #lockText / 2), math.floor(tmy / 2))
    tuningMon.write(lockText)
    tuningMon.setBackgroundColor(colors.black)
end

function display.drawMenu()
    -- Term header
    term.clear()
    term.setCursorPos(1, 1)
    local title = "VS Receiver by Manaphoenix"
    local width = #title
    local mx, _ = term.getSize()
    local padding = math.floor((mx - width) / 2)

    term.setCursorPos(1, 1)
    term.blit((" "):rep(mx), ("b"):rep(mx), ("b"):rep(mx))
    term.setCursorPos(padding, 1)
    term.blit(title, ("0"):rep(width), ("b"):rep(width))
    term.setCursorPos(1, 1)
    term.blit("Exit", ("0"):rep(4), ("b"):rep(4))
    term.setCursorPos(mx - 3, 1)
    term.blit("Lock", ("0"):rep(4), ("b"):rep(4))
    term.setCursorPos(1, 2)

    -- Tuning monitor main menu
    tuningMon.clear()
    local _, tmy = tuningMon.getSize()
    tuningMon.setCursorPos(1, math.floor(tmy / 2 - 1))
    writeToMonitorCentered(tuningMon, "TUNING MENU", colors.yellow, colors.black)
    writeToMonitorCentered(tuningMon, "[Transmission]", colors.blue, colors.black)
    writeToMonitorCentered(tuningMon, "[Suspension]", colors.blue, colors.black)
end

function display.drawTransmissionMenu()
    tuningMon.clear()
    tuningMon.setCursorPos(1, 1)
    writeToMonitor(tuningMon, "<<", colors.blue, colors.black)
    writeToMonitorCentered(tuningMon, "Transmission Menu", colors.yellow, colors.black)

    for i = 1, 4 do
        local label = i < 4 and "[Gear " .. i .. "]" or "[Gear " .. i .. "(R)]"
        writeToMonitorCentered(tuningMon, label, colors.blue, colors.black)
    end
end

function display.drawSuspensionMenu()
    tuningMon.clear()
    tuningMon.setCursorPos(1, 1)
    writeToMonitor(tuningMon, "<<", colors.blue, colors.black)
    writeToMonitorCentered(tuningMon, "Suspension Menu", colors.yellow, colors.black)
    writeToMonitorCentered(tuningMon, "[Increase]", colors.blue, colors.black)
    writeToMonitorCentered(tuningMon, "[Decrease]", colors.blue, colors.black)
end

-- ===== Status Monitor =====
function display.updateStatusMonitor(statusConfig)
    statusMon.clear()
    statusMon.setCursorPos(1, 1)

    local colorsTable = statusConfig.isOff and scopy or {
        inactive = colors.gray,
        active = colors.gray,
        fuel = colors.gray,
        stress = colors.gray,
        speed = colors.gray,
        refillInactive = colors.gray,
        refillActive = colors.gray,
        energy = colors.gray
    }

    -- Gear display
    for gearNum, state in ipairs(statusConfig.activeGear) do
        local txt = gearNum < 4 and ("[Gear " .. gearNum .. "]") or "[Reverse]"
        local color = state and colorsTable.active or colorsTable.inactive
        writeToMonitor(statusMon, txt, color, colors.black)
    end

    -- Fuel
    statusMon.setCursorPos(1, 6)
    writeToMonitor(statusMon, "Fuel: " .. statusConfig.currentFuel .. "/", colorsTable.fuel, colors.black)
    writeToMonitor(statusMon, statusConfig.capacityFuel .. " mb", colorsTable.fuel, colors.black)

    if statusConfig.currentFuel <= 0 then
        writeToMonitor(statusMon, "REFILL", fueltog and colorsTable.refillActive or colorsTable.refillInactive,
            colors.black)
        fueltog = not fueltog
    else
        writeToMonitor(statusMon, "REFILL", colorsTable.refillInactive, colors.black)
        fueltog = false
    end

    -- Speed
    statusMon.setCursorPos(10, 1)
    writeToMonitor(statusMon, "Speed: " .. statusConfig.speed .. " RPM", colorsTable.speed, colors.black)

    -- Stress
    statusMon.setCursorPos(10, 3)
    local stressPercent = math.floor((statusConfig.usedStress / math.max(statusConfig.stressCapacity, 1)) * 100)
    writeToMonitor(statusMon, "Stress: " .. stressPercent .. "%", colorsTable.stress, colors.black)

    -- Energy
    statusMon.setCursorPos(1, 9)
    if statusConfig.isOff then
        writeToMonitor(statusMon, "Off       ", colorsTable.energy, colors.black)
    else
        local energyamt = math.floor(statusConfig.energyPercent / 10)
        local remaining = 10 - energyamt
        local energyText = ("5"):rep(energyamt) .. ("8"):rep(remaining)
        local statusBarTxt = (" "):rep(10)
        local txt = string.format("%d%%", statusConfig.energyPercent)
        local xpos = 5
        statusBarTxt = statusBarTxt:sub(1, xpos - 1) .. txt .. statusBarTxt:sub(xpos + #txt)
        statusMon.blit(statusBarTxt, ("0"):rep(10), energyText)
    end
end

return display
