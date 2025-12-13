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
    [1] = "front",
    [2] = "top",
    [3] = "left",
    [4] = "back"
}

local modemCode = 1337
-- This is the channel the ender modem operates on (IE. the channel it will receive messages on)
local securityKey = "dogs"
-- This is the security key that the ender modem will use to verify messages

local fuelCapacity = 24000
-- max amount the tank can handle (this has to be hard coded there is no way to detect tank size)

local fuelUpdate = 3      -- how often in seconds should we check the fuel?

local dbgMessages = false -- should it print the debug message(s)

--== MAIN CODE (DO NOT MODIFY) ==--

-- constants
local input_relay = peripheral.wrap(input_side)
local output_relay = peripheral.wrap(output_side)
local enderModem = peripheral.wrap(ender_modem_side)
local stressometer = peripheral.find("Create_Stressometer")
local speedometer = peripheral.find("Create_Speedometer")
local tank = peripheral.find("fluid_storage")
local speedControllers = { peripheral.find("Create_RotationSpeedController") }

assert(input_relay, "Input relay not found on side " .. input_side)
assert(output_relay, "Output relay not found on side " .. output_side)
assert(enderModem, "Ender modem not found on side " .. ender_modem_side)
assert(stressometer, "stressometer not found!")
assert(speedometer, "speedometer not found!")
assert(tank, "Fuel tank not found!")
assert(#speedControllers > 0, "No speed controllers found!")

local running = true -- used to control the main loop
enderModem.open(modemCode)

local stateFileName = "vsengineState.dat"

-- state
local lastStates = {
    -- initalize with default values
    front = false,
    back = false,
    left = false,
    right = false,
    top = false,
    bottom = false
} -- for reloading the computer from chunk reloads

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

    if tank.tanks()[1] ~= nil and tank.tanks()[1].amount ~= nil then
        currentFuel = tank.tanks()[1].amount
    end

    local data = {
        key = securityKey,
        payload = {
            speed = speedometer.getSpeed(),
            usedStress = stressometer.getStress(),
            stressCapacity = stressometer.getStressCapacity(),
            currentFuel = currentFuel,
            capacityFuel = fuelCapacity,
            activeGear = {}
        }
    }

    for i = 1, 4 do
        data.payload.activeGear[i] = lastStates[gearSides[i]]
    end

    enderModem.transmit(modemCode, modemCode, data)
end

local function handle_redstone()
    local sides = getInputSides()

    -- check if more than one input was received, if true; ignore the input
    -- Count active inputs
    local activeCount = 0
    for _, state in pairs(sides) do
        if state then activeCount = activeCount + 1 end
    end

    -- Only update if exactly one input is active
    if activeCount == 1 then
        lastStates = sides
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
    sendStateMessage()
    os.startTimer(fuelUpdate)
end

local function handleEvent(evTable)
    local ev = evTable[1]
    -- local args = { select(2, unpack(evTable)) } -- not currently used, handler is just setup to allow for more events in the future
    if ev == "redstone" then
        handle_redstone()
    elseif ev == "key" then
        local key = evTable[2]
        if key == keys.x then
            running = false
        end
    elseif ev == "modem_message" then
        local _, _, _, message, _ = evTable[2], evTable[3], evTable[4], evTable[5], evTable[6]
        if not message.key or message.key ~= securityKey then
            return
        end
        local data = message.payload
        handleMessage(data)
    elseif ev == "timer" then
        handleTimer()
    end
end

-- Load saved state on startup
loadState()
updateState()

term.clear()
term.setCursorPos(1, 1)

print("VS Engine by Manaphoenix")
print("Press X to exit")
os.startTimer(fuelUpdate)

while running do
    local pull = { os.pullEvent() }
    if dbgMessages then
        print("Current handling event: " .. pull[1], pull[2])
    end
    handleEvent(pull)
    --sleep(0.1) -- to avoid double input detection
end

term.clear()
term.setCursorPos(1, 1)
