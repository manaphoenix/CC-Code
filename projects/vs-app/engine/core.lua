-- VS Engine Core Module
-- This contains the main engine logic rewritten from the original vsEngine.lua

local config = require("config.config")
local utils = require("lib.utils")

local core = {}

-- Engine state
local running = false
local input_relay, output_relay, enderModem, latch_relay
local stressometer, speedometer, tank, accumulator
local controllers = {}
local lastStates = {}
local activeTimer = -1
local lastSent = 0

-- Initialize peripherals and configuration
function core.init()
    -- Wrap peripherals
    input_relay = peripheral.wrap(config.input_side)
    output_relay = peripheral.wrap(config.output_side)
    enderModem = peripheral.wrap(config.ender_modem_side)

    -- Find additional peripherals
    stressometer = peripheral.find("Create_Stressometer")
    speedometer = peripheral.find("Create_Speedometer")
    tank = peripheral.find("fluid_storage")
    accumulator = peripheral.find("modular_accumulator")

    -- Find latch relay (the third redstone relay)
    local relays = { peripheral.find("redstone_relay") }
    for i, v in pairs(relays) do
        if v ~= input_relay and v ~= output_relay then
            latch_relay = v
            break
        end
    end

    -- Validate peripherals
    assert(input_relay, "Input relay not found on side " .. config.input_side)
    assert(output_relay, "Output relay not found on side " .. config.output_side)
    assert(enderModem, "Ender modem not found on side " .. config.ender_modem_side)
    assert(stressometer, "Stressometer not found!")
    assert(speedometer, "Speedometer not found!")
    assert(tank, "Fuel tank not found!")
    assert(latch_relay, "Latch relay not found!")
    assert(accumulator, "Accumulator not found!")

    -- Setup controllers
    core.setupControllers()

    -- Open modem channel
    enderModem.open(config.modem_code)

    -- Initialize state
    core.loadState()

    -- Set initial suspension controller speed
    if controllers.GS then
        controllers.GS.setTargetSpeed(0)
    end
end

-- Setup rotation speed controllers
function core.setupControllers()
    controllers = {
        G1 = -1, -- Gear 1
        G2 = -1, -- Gear 2
        G3 = -1, -- Gear 3
        GR = -1, -- Gear Reverse
        GS = -1, -- Gear Suspension Controller
    }

    if not fs.exists("config/vsengine.cfg") then
        -- Auto-detect controllers
        local speedControllers = { peripheral.find("Create_RotationSpeedController") }
        for _, controller in pairs(speedControllers) do
            local speed = controller.getTargetSpeed()
            for Gear, DefSpeed in pairs(config.def_gear_speeds) do
                if speed == DefSpeed then
                    controllers[Gear] = controller
                    break
                end
            end
        end

        -- Check for missing controllers
        for ID, controller in pairs(controllers) do
            if controller == -1 then
                error("Controller " .. ID .. " not found!", 0)
            end
        end

        -- Save configuration
        local file = fs.open("config/vsengine.cfg", "w")
        if file then
            local stable = {}
            for ID, controller in pairs(controllers) do
                if controller and controller ~= -1 then
                    stable[ID] = peripheral.getName(controller)
                end
            end
            file.write(textutils.serialize(stable))
            file.close()
        end
    else
        -- Load from configuration
        local file = fs.open("config/vsengine.cfg", "r")
        if file then
            local doc = file.readAll()
            file.close()

            if doc then
                local ustable = textutils.unserialize(doc)
                if ustable then
                    for ID, controllerName in pairs(ustable) do
                        controllers[ID] = peripheral.wrap(controllerName)
                    end
                end
            end
        end
    end
end

-- Save engine state
function core.saveState()
    local file = fs.open("data/vsengineState.dat", "w")
    if file then
        file.write(textutils.serialize(lastStates))
        file.close()
    end
end

-- Load engine state
function core.loadState()
    local file = fs.open("data/vsengineState.dat", "r")
    if file then
        local data = file.readAll()
        file.close()
        if data then
            local states = textutils.unserialize(data)
            if type(states) == "table" then
                lastStates = states
            end
        end
    end

    -- Initialize default states if needed
    if not lastStates.front then
        lastStates = {
            front = false,
            back = false,
            left = false,
            right = false,
            top = false,
            bottom = false,
            isOff = false
        }
    end
end

-- Update output relay based on current state
function core.updateState()
    for side, state in pairs(lastStates) do
        local outputSide = config.output_sides[side]
        if outputSide then
            output_relay.setOutput(outputSide, state)
        end
    end
    core.saveState()
end

-- Get current input states
function core.getInputSides()
    local rtTable = {}
    for side, _ in pairs(config.output_sides) do
        rtTable[side] = input_relay.getInput(side)
    end
    return rtTable
end

-- Send state message via modem
function core.sendStateMessage()
    local currentFuel = 0

    local tanks = tank.tanks()
    if #tanks > 0 then
        local first_tank = tanks[1]
        if first_tank ~= nil and first_tank.amount ~= nil then
            currentFuel = first_tank.amount
        end
    end

    local data = {
        key = config.security_key,
        payload = {
            speed = speedometer.getSpeed(),
            usedStress = stressometer.getStress(),
            stressCapacity = stressometer.getStressCapacity(),
            currentFuel = currentFuel,
            capacityFuel = config.fuel_capacity,
            activeGear = {},
            energyPercent = accumulator.getPercent(),
            isOff = lastStates.isOff
        }
    }

    for i = 1, 4 do
        data.payload.activeGear[i] = lastStates[config.gear_sides[i]]
    end

    enderModem.transmit(config.modem_code, config.modem_code, data)

    if config.debug_messages then
        utils.debugPrint("Sending state message", data.payload)
    end
end

-- Check if machine is off
function core.checkOff()
    local state = latch_relay.getInput(config.is_off_side)
    lastStates.isOff = state
    core.saveState()
end

-- Handle redstone input changes
function core.handleRedstone()
    local sides = core.getInputSides()

    core.checkOff()

    -- Count active inputs
    local activeCount = 0
    for _, state in pairs(sides) do
        if state then activeCount = activeCount + 1 end
    end

    -- Only update if exactly one input is active
    if activeCount == 1 then
        local isOffCopy = lastStates.isOff
        lastStates = sides
        lastStates.isOff = isOffCopy
    end

    core.updateState()
    core.sendStateMessage()
end

-- Handle timer events
function core.handleTimer()
    core.checkOff()
    core.sendStateMessage()
end

-- Handle modem messages
function core.handleModemMessage(message)
    if not message.key or message.key ~= config.security_key then
        return
    end
    local data = message.payload
    -- TODO: Implement message handling
end

-- Handle mouse clicks
function core.handleMouseClick(button, x, y)
    local mx, my = term.getSize()
    if y == 1 then
        if x >= 1 and x <= 4 then
            running = false
        elseif x >= mx - 4 then
            if fs.exists("config/vsengine.cfg") then
                fs.delete("config/vsengine.cfg")
            end
            running = false
        end
    end
end

-- Handle events
function core.handleEvent(evTable)
    local ev = evTable[1]

    if ev == "redstone" then
        core.handleRedstone()
    elseif ev == "key" then
        -- Key events not currently handled
    elseif ev == "modem_message" then
        local _, _, _, message, _ = evTable[2], evTable[3], evTable[4], evTable[5], evTable[6]
        core.handleModemMessage(message)
    elseif ev == "timer" then
        core.handleTimer()
    elseif ev == "mouse_click" then
        core.handleMouseClick(evTable[2], evTable[3], evTable[4])
    else
        return -- ignore other events
    end
    os.cancelTimer(activeTimer)
    activeTimer = os.startTimer(config.fuel_update)
end

-- Draw the UI header
function core.drawHeader()
    local cx, cy = term.getSize()

    term.clear()
    term.setCursorPos(1, 1)

    local title = "VS Engine by Manaphoenix v" .. config.version
    local width = #title
    local padding = (cx - width) / 2

    -- Make header bar
    term.setCursorPos(1, 1)
    term.blit((" "):rep(cx), ("b"):rep(cx), ("b"):rep(cx))

    -- Center the title
    term.setCursorPos(padding, 1)
    term.blit(title, ("0"):rep(width), ("b"):rep(width))

    -- Reset button
    term.setCursorPos(cx - 4, 1)
    term.blit("Reset", ("e"):rep(5), ("b"):rep(5))

    -- Exit button
    term.setCursorPos(1, 1)
    term.blit("Exit", ("0"):rep(4), ("b"):rep(4))
    term.setCursorPos(1, 2)
end

-- Main engine loop
function core.start()
    core.init()
    core.loadState()
    core.updateState()
    core.drawHeader()

    running = true
    activeTimer = os.startTimer(config.fuel_update)

    while running do
        local pull = { os.pullEvent() }
        core.handleEvent(pull)
    end

    term.clear()
    term.setCursorPos(1, 1)
end

return core
