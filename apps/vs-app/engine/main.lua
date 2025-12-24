-- main.lua
-- Program entry point for VS-Engine

term.clear()
term.setCursorPos(1, 1)

-- Initialize core and modules
local core = require("core").init()
local state = core.state
local snapshot = core.snapshot
local apply = core.apply
local protocol = core.protocol
local net = core.net
local peripherals = core.peripherals
local config = core.config

local running = true
local activeTimer = -1
local fuelUpdate = config.fuelUpdate
local mx, my = term.getSize()

-- ===== Helper functions =====

-- save state to disk
local function saveState()
    snapshot.save(state.get())
end

-- update outputs based on state
local function updateOutputs()
    apply.outputs(state.get())
    saveState()
end

-- read redstone inputs and update state
local function handleInputs()
    local inputs = {}
    for side, _ in pairs(config.outputsides) do
        inputs[side] = peripherals.input_relay.getInput(side)
    end

    local changed = state.updateFromInputs(inputs)
    if changed then
        updateOutputs()
    end
end

-- check if machine is off via latch
local function handleOffState()
    local isOff = peripherals.latch_relay.getInput(config.isOffSide)
    state.setOff(isOff)
    saveState()
end

-- send telemetry message
local function sendTelemetry()
    -- gather sensors
    local sensors = {
        speed = peripherals.speedometer.getSpeed(),
        usedStress = peripherals.stressometer.getStress(),
        stressCapacity = peripherals.stressometer.getStressCapacity(),
        currentFuel = (peripherals.tank.tanks()[1] or { amount = 0 }).amount,
        capacityFuel = config.fuelCapacity,
        energyPercent = peripherals.accumlator.getPercent()
    }

    local msg = protocol.buildStatus(state.get(), sensors)
    net.send(msg)
end

-- handle incoming modem messages
local function handleModem(event)
    local payload = net.receive(event)
    if payload then
        -- TODO: implement message logic
        -- e.g., change gears, trigger actions, etc.
    end
end

-- handle mouse clicks (exit/reset)
local function handleMouse(event)
    local button, x, y = event[2], event[3], event[4]
    if y == 1 then
        -- exit
        if x >= 1 and x <= 4 then
            running = false
            -- reset config
        elseif x >= mx - 4 then
            if fs.exists("config/vsengine.cfg") then
                fs.delete("config/vsengine.cfg")
            end
            running = false
        end
    end
end

-- handle timers
local function handleTimer()
    handleOffState()
    sendTelemetry()
end

-- unified event handler
local function handleEvent(event)
    local ev = event[1]

    if ev == "redstone" then
        handleInputs()
        handleOffState()
        sendTelemetry()
    elseif ev == "mouse_click" then
        handleMouse(event)
    elseif ev == "modem_message" then
        handleModem(event)
    elseif ev == "timer" then
        handleTimer()
    end

    -- restart fuel timer
    os.cancelTimer(activeTimer)
    activeTimer = os.startTimer(fuelUpdate)
end

-- ===== UI Header =====
local function drawHeader()
    term.clear()
    term.setCursorPos(1, 1)

    local title = "VS Engine by Manaphoenix v1.1.7"
    local width = #title
    local padding = math.floor((mx - width) / 2)

    -- header bar
    term.setCursorPos(1, 1)
    term.blit((" "):rep(mx), ("b"):rep(mx), ("b"):rep(mx))

    -- center title
    term.setCursorPos(padding, 1)
    term.blit(title, ("0"):rep(width), ("b"):rep(width))

    -- exit / reset
    term.setCursorPos(1, 1)
    term.blit("Exit", ("0"):rep(4), ("b"):rep(4))
    term.setCursorPos(mx - 4, 1)
    term.blit("Reset", ("e"):rep(5), ("b"):rep(5))

    term.setCursorPos(1, 2)
end

-- ===== Main Loop =====

-- initial UI draw
drawHeader()

-- start fuel timer
activeTimer = os.startTimer(fuelUpdate)

-- event loop
while running do
    local event = { os.pullEvent() }
    handleEvent(event)
end

-- cleanup on exit
term.clear()
term.setCursorPos(1, 1)
