-- VS Engine by Manaphoenix

local output_side = "right"
-- side that the output relay is on, if your using a modem and leaving the redstone relay somewhere else, use its name
-- use the peripherals program to determine what its name is ^_^ (it also puts it in chat when you connect via modem too :shrug:)
local input_side = "left"
-- side that the input relay is on
local ender_modem_side = "top"
-- side that the ender modem is on

local outputsides = { -- overrides the default side mapping, so you can have an input on one side but have it mapped to a different side on the output
    -- valid options are ["top", "bottom", "left", "right", "front", "back"]
    front = "front",  -- inversion shouldn't be needed here as long as the relay is placed correctly
    back = "back",    -- inversion shouldn't be needed here as long as the relay is placed correctly
    left = "right",   -- inverted b/c the blocks are on opposite sides of the computer
    right = "left",   -- inverted b/c the blocks are on opposite sides of the computer
    top = "top",      -- top is always the top
    bottom = "bottom" -- bottom is always the bottom
}

local gearSides = { -- how does each side of the input relay map to the rotation speed controller
    [1] = "left",
    [2] = "top",
    [3] = "back",
    [4] = "front"
}

local isOffSide = "front" -- what side the latch give redstone power to to signify the machine being off

local modemCode = 1337
-- This is the channel the ender modem operates on (IE. the channel it will receive messages on)
local securityKey = "dogs"
-- This is the security key that the ender modem will use to verify messages

local fuelCapacity = 24000
-- max amount the tank can handle (this has to be hard coded there is no way to detect tank size)

local fuelUpdate = 0.5 -- how often in seconds should we check the fuel?

local defGearSpeeds = {
    G1 = 65,  -- Gear 1
    G2 = 128, -- Gear 2
    G3 = 256, -- Gear 3
    GR = -30, -- Gear Reverse
    GS = 1,   -- Gear Suspension Controller
}             -- NOTE: these are used to determine which
-- controller is which; once it figures them out the first time it will be
-- saved to a config though.

local dbgMessages = false -- should it print the debug message(s)

--== MAIN CODE (DO NOT MODIFY) ==--

-- constants
local input_relay = peripheral.wrap(input_side)
local output_relay = peripheral.wrap(output_side)
local enderModem = peripheral.wrap(ender_modem_side)
local stressometer = peripheral.find("Create_Stressometer")
local speedometer = peripheral.find("Create_Speedometer")
local tank = peripheral.find("fluid_storage")
local accumlator = peripheral.find("modular_accumulator")
local version = "1.1.6"

local latch_relay = nil
local controllers = {
    G1 = -1, -- Gear 1
    G2 = -1, -- Gear 2
    G3 = -1, -- Gear 3
    GR = -1, -- Gear Reverse
    GS = -1, -- Gear Suspension Controller
}

do
    local relays = { peripheral.find("redstone_relay") }
    for i, v in pairs(relays) do
        if v ~= input_relay and v ~= output_relay then
            latch_relay = v
            break
        end
    end

    if not fs.exists("config/vsengine.cfg") then
        local speedControllers = { peripheral.find("Create_RotationSpeedController") }
        for _, controller in pairs(speedControllers) do
            local speed = controller.getTargetSpeed()
            for Gear, DefSpeed in pairs(defGearSpeeds) do
                if speed == DefSpeed then
                    controllers[Gear] = controller
                    break
                end
            end
        end

        -- check for nil
        for ID, controller in pairs(controllers) do
            if controller == -1 then
                error("Controller " .. ID .. " not found!", 0)
            end
        end

        local file = fs.open("config/vsengine.cfg", "w")
        local stable = {}
        for ID, controller in pairs(controllers) do
            stable[ID] = peripheral.getName(controller)
        end

        file.write(textutils.serialize(stable))
        file.close()
    else
        local file = fs.open("config/vsengine.cfg", "r")
        local doc = file.readAll()
        file.close()

        local ustable = textutils.unserialize(doc)
        for ID, controllerName in pairs(ustable) do
            controllers[ID] = peripheral.wrap(controllerName)
        end
    end
end

assert(input_relay, "Input relay not found on side " .. input_side)
assert(output_relay, "Output relay not found on side " .. output_side)
assert(enderModem, "Ender modem not found on side " .. ender_modem_side)
assert(stressometer, "stressometer not found!")
assert(speedometer, "speedometer not found!")
assert(tank, "Fuel tank not found!")
assert(latch_relay, "Latch relay not found!")
assert(accumlator, "Accumlator not found!")

local running = true -- used to control the main loop
enderModem.open(modemCode)

local stateFileName = "vsengineState.dat"
local activeTimer   = -1 -- used to track the active timer
local lastSent      = os.clock()

-- state
local lastStates    = {
    -- initalize with default values
    front = false,
    back = false,
    left = false,
    right = false,
    top = false,
    bottom = false,
    isOff = false
} -- for reloading the computer from chunk reloads

controllers.GS.setTargetSpeed(0)

local function saveState()
    local file = fs.open("data/" .. stateFileName, "w")
    if file then
        file.write(textutils.serialize(lastStates))
        file.close()
    end
end

local function loadState()
    local file = fs.open("data/" .. stateFileName, "r")
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
    if lastStates.isOff == nil then
        lastStates.isOff = false
    end
end

local function updateState()
    -- Update the output relay based on current input states
    for side, state in pairs(lastStates) do
        local outputSide = outputsides[side]
        if outputSide then
            output_relay.setOutput(outputSide, state)
        end
    end

    saveState()
end

local function getInputSides()
    local rtTable = {}
    for side, _ in pairs(outputsides) do
        rtTable[side] = input_relay.getInput(side)
    end
    return rtTable
end

local function sendStateMessage()
    local currentFuel = 0

    local tanks = tank.tanks()
    if #tanks > 0 then
        local first_tank = tanks[1]

        if first_tank ~= nil and first_tank.amount ~= nil then
            currentFuel = first_tank.amount
        end
    end

    local data = {
        key = securityKey,
        payload = {
            speed = speedometer.getSpeed(),
            usedStress = stressometer.getStress(),
            stressCapacity = stressometer.getStressCapacity(),
            currentFuel = currentFuel,
            capacityFuel = fuelCapacity,
            activeGear = {},
            energyPercent = accumlator.getPercent(),
            isOff = lastStates.isOff
        }
    }

    for i = 1, 4 do
        data.payload.activeGear[i] = lastStates[gearSides[i]]
    end

    enderModem.transmit(modemCode, modemCode, data)
    if dbgMessages then
        term.setCursorPos(1, 2)
        print("Sending: ")
        print("Gear states: ")
        local format = "\t%s: %s"
        for i, v in ipairs(data.payload.activeGear) do
            print(string.format(format, i, v))
        end
        print("Other data: ")
        for i, v in pairs(data.payload) do
            if type(v) ~= "table" then
                print(string.format(format, i, v))
            end
        end
        -- round to nearest 100th of a second
        local lastRec = os.clock() - lastSent
        print("Last received: " .. math.floor(lastRec * 100) / 100 .. " seconds ago")
        -- time to make sure
        print("Time: " .. os.date("%I:%M:%S %p"))
    end
end

local function checkOff()
    local state = latch_relay.getInput(isOffSide)
    lastStates.isOff = state -- just do it every time w/e man
    saveState()
end

local function handle_redstone()
    local sides = getInputSides()

    checkOff()
    -- check if more than one input was received, if true; ignore the input
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


    -- Update the output relay
    updateState()

    -- Send a message to the ender modem to update the state
    sendStateMessage()
end

local function handleMessage(data)
    -- TODO: Implement message handling
end

local function handleTimer()
    checkOff()
    sendStateMessage()
end

local function handleMouseClick(button, x, y)
    if y == 1 then
        if x >= 1 and x <= 4 then
            running = false
        elseif x >= cx - 4 and x <= cx then
            if fs.exists("config/vsengine.cfg") then
                fs.delete("config/vsengine.cfg")
            end
            running = false
        end
    end
end

local function handleEvent(evTable)
    local ev = evTable[1]
    -- local args = { select(2, unpack(evTable)) } -- not currently used, handler is just setup to allow for more events in the future
    if ev == "redstone" then
        handle_redstone()
    elseif ev == "key" then
        local key = evTable[2]
        -- do nothing
    elseif ev == "modem_message" then
        local _, _, _, message, _ = evTable[2], evTable[3], evTable[4], evTable[5], evTable[6]
        if not message.key or message.key ~= securityKey then
            return
        end
        local data = message.payload
        handleMessage(data)
    elseif ev == "timer" then
        handleTimer()
    elseif ev == "mouse_click" then
        handleMouseClick(evTable[2], evTable[3], evTable[4])
    end
    os.cancelTimer(activeTimer)
    activeTimer = os.startTimer(fuelUpdate)
end

-- Load saved state on startup
loadState()
updateState()

do
    local cx, cy = term.getSize()

    term.clear()
    term.setCursorPos(1, 1)
    -- make header
    -- blit has to have all 3 params match in lengths
    local title   = "VS Engine by Manaphoenix v" .. version
    local width   = #title
    local padding = (cx - width) / 2

    -- make header bar
    term.setCursorPos(1, 1)
    term.blit((" "):rep(cx), ("b"):rep(cx), ("b"):rep(cx))

    -- center the title
    term.setCursorPos(padding, 1)
    term.blit(title, ("0"):rep(width), ("b"):rep(width))

    -- reset
    term.setCursorPos(cx - 4, 1)
    term.blit("Reset", ("e"):rep(5), ("b"):rep(5))

    -- exit
    term.setCursorPos(1, 1)
    term.blit("Exit", ("0"):rep(4), ("b"):rep(4))
    term.setCursorPos(1, 2)
end

activeTimer = os.startTimer(fuelUpdate)

while running do
    local pull = { os.pullEvent() }
    handleEvent(pull)
    --sleep(0.1) -- to avoid double input detection
end

term.clear()
term.setCursorPos(1, 1)
