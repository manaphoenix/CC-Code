-- VS Receiver by Manaphoenix

--====================================================================--
-- CONFIGURATION (EDIT THESE)
--====================================================================--

--====================================================================--
-- Peripheral Sides
--====================================================================--
-- what side the peripheral is located on
-- valid options are: "top", "bottom", "left", "right", "front", "back"

local status_monitor_side = "top"   -- Status monitor
local tuning_monitor_side = "right" -- Tuning monitor
local ender_modem_side    = "back"  -- Ender modem side

--====================================================================--
-- Ender Modem Settings
--====================================================================--

local modemCode           = 1337   -- Channel the ender modem listens on
local securityKey         = "dogs" -- Security key used to verify messages

--====================================================================--
-- Text Scaling
--====================================================================--
-- Valid range: 0.5 - 5.0 (increments of 0.5 required)

local statusTextScale     = 1.0 -- Status monitor
local tuningTextScale     = 1.0 -- Tuning monitor

--====================================================================--
-- Color Overrides
--====================================================================--
-- These override the default monitor palette colors.

local statusOverrides     = {
    gray = 0x171717,
}

local tuningOverrides     = {}

--====================================================================--
-- Monitor Colors
--====================================================================--
-- These are colors used for different parts of what’s written on the monitor.
-- Labeled to make them easy to change.

-- Status Monitor
local statusColors        = {
    inactive       = colors.orange, -- Inactive gears
    active         = colors.lime,   -- Active gears
    fuel           = colors.yellow, -- Fuel indicator
    stress         = colors.purple, -- Stress indicator
    speed          = colors.blue,   -- Speed (RPM)
    refillInactive = colors.gray,   -- Refill label (inactive)
    refillActive   = colors.red,    -- Refill label (active)
}



-- Tuning Monitor
local tuningColors = {}

local dbgMessages  = false -- should it print the debug message(s)

--====================================================================--
--===                    MAIN CODE (DO NOT MODIFY)                 ===--
--====================================================================--

-- constants
local enderModem   = peripheral.wrap(ender_modem_side)
local statusMon    = peripheral.wrap(status_monitor_side)
local tuningMon    = peripheral.wrap(tuning_monitor_side)
local fueltog      = false
local version      = "1.0.8"

local running      = true -- used to control the main loop
local lastReceived = os.clock()

assert(enderModem, "Ender modem not found on side " .. ender_modem_side)
assert(statusMon, "Status monitor not found on side " .. status_monitor_side)
assert(tuningMon, "Tuning monitor not found on side " .. tuning_monitor_side)

enderModem.open(modemCode)

statusMon.setTextScale(statusTextScale)
tuningMon.setTextScale(tuningTextScale)

for colName, col in pairs(statusOverrides) do
    statusMon.setPaletteColor(colors[colName], col)
end

for colName, col in pairs(tuningOverrides) do
    tuningMon.setPaletteColor(colors[colName], col)
end

local statusConfig = {
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
    isOff = false
}

local scopy = {}
for i, v in pairs(statusColors) do
    scopy[i] = v
end

local function writeToMonitor(monitor, text, fg, bg)
    monitor.setTextColor(fg)
    monitor.setBackgroundColor(bg)
    monitor.write(text)

    local cx, cy = monitor.getCursorPos()
    monitor.setCursorPos(1, cy + 1)
end

local function updateStatusMonitor()
    statusMon.clear()
    statusMon.setCursorPos(1, 1)


    if statusConfig.isOff == false then
        statusColors = {
            inactive       = colors.gray, -- Inactive gears
            active         = colors.gray, -- Active gears
            fuel           = colors.gray, -- Fuel indicator
            stress         = colors.gray, -- Stress indicator
            speed          = colors.gray, -- Speed (RPM)
            refillInactive = colors.gray, -- Refill label (inactive)
            refillActive   = colors.gray, -- Refill label (active)
        }
    else
        statusColors = scopy
    end

    -- Gear
    for gearNum, state in ipairs(statusConfig.activeGear) do
        if gearNum < 4 then
            if state then
                writeToMonitor(statusMon, "[Gear " .. gearNum .. "]", statusColors.active, colors.black)
            else
                writeToMonitor(statusMon, "Gear " .. gearNum, statusColors.inactive, colors.black)
            end
        else
            if state then
                writeToMonitor(statusMon, "[Reverse]", statusColors.active, colors.black)
            else
                writeToMonitor(statusMon, "Reverse", statusColors.inactive, colors.black)
            end
        end
    end

    -- Fuel
    statusMon.setCursorPos(1, 6)
    writeToMonitor(statusMon, "Fuel:  " .. statusConfig.currentFuel .. "/", statusColors.fuel, colors.black)
    writeToMonitor(statusMon, "       " .. statusConfig.capacityFuel .. " mb", statusColors.fuel, colors.black)

    statusMon.setCursorPos(1, 7)

    if statusConfig.currentFuel > 0 then
        writeToMonitor(statusMon, "REFILL", statusColors.refillInactive, colors.black)
        fueltog = false
    else
        if fueltog then
            writeToMonitor(statusMon, "REFILL", statusColors.refillInactive, colors.black)
            fueltog = false
        else
            writeToMonitor(statusMon, "REFILL", statusColors.refillActive, colors.black)
            fueltog = true
        end
    end

    -- Speed
    statusMon.setCursorPos(10, 1)
    writeToMonitor(statusMon, "Speed: ", statusColors.speed, colors.black)
    statusMon.setCursorPos(10, 2)
    writeToMonitor(statusMon, statusConfig.speed .. " RPM", statusColors.speed, colors.black)

    -- Stress
    statusMon.setCursorPos(10, 3)
    writeToMonitor(statusMon, "Stress: ", statusColors.stress, colors.black)
    statusMon.setCursorPos(10, 4)
    local stressPercent = math.floor(statusConfig.usedStress / statusConfig.stressCapacity * 100)
    writeToMonitor(statusMon, stressPercent .. "%", statusColors.stress, colors.black)
end

local function updateTuningMonitor()
    -- TODO: program logic for this monitor
end

local function handleMessage(data)
    if data.isOff == true then
        statusConfig.isOff = data.isOff
        if data.activeGear then
            for i = 1, 4 do
                statusConfig.activeGear[i] = data.activeGear[i]
            end
        end
        if data.speed then
            statusConfig.speed = data.speed
        end
        if data.usedStress then
            statusConfig.usedStress = data.usedStress
        end
        if data.stressCapacity then
            statusConfig.stressCapacity = data.stressCapacity
        end
        if data.currentFuel then
            statusConfig.currentFuel = data.currentFuel
        end
        if data.capacityFuel then
            statusConfig.capacityFuel = data.capacityFuel
        end
    end
    if statusConfig.isOff ~= data.isOff then
        statusConfig.isOff = data.isOff
    end

    if dbgMessages then
        term.setCursorPos(1, 2)
        print("Gear states:")
        local format = "\t%s: %s"
        for i, v in ipairs(statusConfig.activeGear) do
            print(string.format(format, i, v))
        end
        print("Other data:")
        for i, v in pairs(statusConfig) do
            if type(v) ~= "table" then
                print(string.format(format, i, v))
            end
        end
        -- round to nearest 100th of a second
        local lastRec = os.clock() - lastReceived
        print("Last received: " .. math.floor(lastRec * 100) / 100 .. " seconds ago")
        -- time to make sure
        print("Time: " .. os.date("%I:%M:%S %p"))
    end
end

local function handleMouseClick(button, x, y)
    if y == 1 then
        if x >= 1 and x <= 4 then
            running = false
        end
    end
end

local function handleEvent(event)
    local ev = event[1]
    if ev == "key" then
        local key = event[2]
        if key == keys.x then
            running = false
        end
    elseif ev == "modem_message" then
        local _, _, _, message, _ = event[2], event[3], event[4], event[5], event[6]
        if not message.key or message.key ~= securityKey then
            return
        end
        local data = message.payload
        handleMessage(data)
        updateStatusMonitor()
        lastReceived = os.clock()
    elseif ev == "mouse_click" then
        handleMouseClick(event[2], event[3], event[4])
    end
end

-- intial loading of monitors
statusMon.clear()
tuningMon.clear()
statusMon.setCursorPos(1, 1)
tuningMon.setCursorPos(1, 1)
statusMon.write("Loading...")
tuningMon.write("Loading...")

do
    term.clear()
    term.setCursorPos(1, 1)
    local cx, cy  = term.getSize()

    -- make header
    -- blit has to have all 3 params match in lengths
    local title   = "VS Receiver by Manaphoenix v" .. version
    local width   = #title
    local padding = (cx - width) / 2

    -- make header bar
    term.setCursorPos(1, 1)
    term.blit((" "):rep(cx), ("b"):rep(cx), ("b"):rep(cx))

    -- center the title
    term.setCursorPos(padding, 1)
    term.blit(title, ("0"):rep(width), ("b"):rep(width))

    -- exit
    term.setCursorPos(1, 1)
    term.blit("Exit", ("0"):rep(4), ("b"):rep(4))
    term.setCursorPos(1, 2)
end

while running do
    local ev = { os.pullEvent() }
    handleEvent(ev)
end

term.clear()
term.setCursorPos(1, 1)

statusMon.clear()
tuningMon.clear()
