local output_side = "right"
-- side that the output relay is on, if your using a modem and leaving the redstone relay somewhere else, use its name
-- use the peripherals program to determine what its name is ^_^ (it also puts it in chat when you connect via modem too :shrug:)
local input_side = "left"
-- side that the input relay is on

local outputsides = { -- overrides the default side mapping, so you can have an input on one side but have it mapped to a different side on the output
    -- valid options are ["top", "bottom", "left", "right", "front", "back"]
    front = "front",  -- inversion shouldn't be needed here as long as the relay is placed correctly
    back = "back",    -- inversion shouldn't be needed here as long as the relay is placed correctly
    left = "right",   -- inverted b/c the blocks are on opposite sides of the computer
    right = "left",   -- inverted b/c the blocks are on opposite sides of the computer
    top = "top",      -- top is always the top
    bottom = "bottom" -- bottom is always the bottom
}

--== MAIN CODE (DO NOT MODIFY) ==--

-- constants
local input_relay = peripheral.wrap(input_side)
local output_relay = peripheral.wrap(output_side)

assert(input_relay, "Input relay not found on side " .. input_side)
assert(output_relay, "Output relay not found on side " .. output_side)

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

term.clear()
term.setCursorPos(1, 1)

local function saveState()
    local file = fs.open("rstracker_state.lua", "w")
    if file then
        file.write(textutils.serialize(lastStates))
        file.close()
    end
end

local function loadState()
    local file = fs.open("rstracker_state.lua", "r")
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
end

local function handleEvent(evTable)
    local ev = evTable[1]
    local args = { select(2, unpack(evTable)) } -- not currently used, handler is just setup to allow for more events in the future
    if ev == "redstone" then
        handle_redstone()
    end
end

-- Load saved state on startup
loadState()
updateState()

while true do
    local pull = { os.pullEvent() }
    handleEvent(pull)
    sleep(0.1) -- to avoid double input detection
end
