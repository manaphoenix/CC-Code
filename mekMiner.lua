--- Automating the Mekanism Digital Miner ---
-- By manaphoenix
-- License: CC0
-- requires a diamond pickaxe, an ender chest, a digital miner, and a power block
-- optional addons are an ender modem to connect to a pocket computer.
-- setup inventory as such: miner, power block, ender chest for ore output, an optional ender chest for refueling

local config = {
    modemChannel = 1337, -- what channel to open the modem on (if you gave it one)
    stopFuelLevel = 64, -- what fuel level to stop mining at
}

-- [[ INIT ]]
local States = {
    errored = -1,
    idle = 0,
    mining = 1,
    finished = 2,
    moving = 4,
    digging = 5,
    refueling = 6
}

local data = {
    lastKnownState = States.idle,
    moveCounter = 0,
    previousOreCount = 0
}

local configFile = "mekConfig.conf"
local datFile = "mekState.dat"
local prefix = os.getComputerLabel() or os.getComputerID()
local modem = peripheral.find("modem")
local miner = peripheral.wrap("top")

-- [[Utility Functions]]

local function loadF(fileName)
    if not fs.exists(fileName) then return nil end
    local f = fs.open(fileName, "r")
    local dt = textutils.unserialise(f.readAll())
    f.close()
    return data
end

local function writeToScreen(str, skipNewLine)
    str = tostring(str)
    -- deal with word wrapping
    if #str < mx then
        term.write(str)
    else
        local words = {}
        for word in str:gmatch("[^%s]+") do
            table.insert(words, word)
        end
        local line = ""
        for i, word in ipairs(words) do
            if #line + #word + 1 > mx then
                term.write(line)
                term.setCursorPos(1, select(2, term.getCursorPos()) + 1)
                line = ""
            end
            line = line .. word .. " "
        end
        term.write(line)
    end

    if not skipNewLine then
        term.setCursorPos(1, select(2, term.getCursorPos()) + 1)
    end
end

local function reset()
    term.clear()
    term.setCursorPos(1, 1)
end

local function out(str)
    str = tostring(str)
    if modem then
        modem.transmit(config.modemChannel, config.modemChannel, str)
    else
        writeToScreen(str)
    end
end

local function saveState()
    local f = fs.open(datFile, "wb")
    f.write(textutils.serialise(data))
    f.close()
end

local function smartMoveForward()
    repeat
        local f = turtle.forward()
        if not f then
            turtle.dig()
        end
    until f == true
    turtle.digUp()
    turtle.digDown()
end

-- [[ Load Config and Data ]]

if loadF(configFile) then
    config = loadF(configFile)
else
    local file = fs.open(configFile, "wb")
    file.write(textutils.serialise(config))
    file.close()
    error("Please setup mekminer.conf", 0)
end

if loadF(datFile) then
    data = loadF(datFile)
end

-- [[ Program functions ]]


local function checkFuel()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel < config.stopFuelLevel then
        return false
    end
    return true
end

local function emptyTurtle()
    for i = 5, 16 do
        turtle.select(i)
        turtle.dropUp()
    end
end

local function updateState(state)
    if state then
        data.lastKnownState = state
    else
        if data.lastKnownState == States.mining then
            local blocks = miner.getToMine()
            if blocks == 0 then
                data.lastKnownState = States.finished
            else
                if blocks ~= data.previousOreCount then
                    data.previousOreCount = blocks
                    out("Mining " .. blocks .. " blocks")
                else
                    data.lastKnownState = States.errored
                end
            end
        end
    end
    saveState()
end

local function setupMiner()
    if data.lastKnownState ~= States.idle then return end
    out("Setting up miner")
    turtle.select(1) -- miner
    turtle.placeUp()

    -- place energy block
    turtle.select(2) -- energy block
    turtle.turnRight()
    for i = 1, 2 do
        turtle.forward()
    end
    turtle.placeUp()

    -- return to start.
    for i = 1, 2 do
        turtle.back()
    end

    -- place storage block
    turtle.select(3) -- storage block
    turtle.turnLeft()
    for i = 1, 2 do
        turtle.forward()
    end
    turtle.up()
    turtle.placeUp()
    emptyTurtle()

    --return to start
    turtle.down()
    for i = 1, 2 do
        turtle.back()
    end
    miner = peripheral.wrap("top")
    updateState(States.mining)
end

local function pickupMiner()
    out("Mining done, picking up miner")
    miner = nil
    turtle.select(1) -- miner
    turtle.digUp()

    -- place energy block
    turtle.select(2) -- energy block
    turtle.turnRight()
    for i = 1, 2 do
        turtle.forward()
    end
    turtle.digUp()

    -- return to start.
    for i = 1, 2 do
        turtle.back()
    end

    -- place storage block
    turtle.select(3) -- storage block
    turtle.turnLeft()
    for i = 1, 2 do
        turtle.forward()
    end
    turtle.up()
    turtle.digUp()

    --return to start
    turtle.down()
    for i = 1, 2 do
        turtle.back()
    end
    updateState(States.idle)
end

local function moveToNextLoc()
    if not checkFuel() then
        return
    end

    if data.moveCounter == 0 then
        turtle.up()
    end
    if data.moveCounter ~= 32 then
        for i = 1, (32-data.moveCounter) do
            smartMoveForward()
            data.moveCounter = i
            saveState()
        end
    end
    if data.moveCounter == 32 then
        turtle.down()
        data.moveCounter = 0
    end
    updateState(States.idle)
end

-- requires 4x4x4 space
local function digArea()
    if data.lastKnownState ~= States.digging then return end

    out("Digging area")
    turtle.up()
    turtle.digUp()
    turtle.back()
    turtle.digUp()
    turtle.turnLeft()

    -- Left Wall
    smartMoveForward()
    turtle.turnRight()
    for i = 1, 3 do
        smartMoveForward()
    end
    turtle.turnRight()

    -- Back wall
    for i = 1, 3 do
        smartMoveForward()
    end
    turtle.turnRight()

    -- Right wall
    for i = 1, 4 do
        smartMoveForward()
    end

    -- Inner right wall
    turtle.turnRight()
    smartMoveForward()
    turtle.turnRight()
    for i = 1, 3 do
        smartMoveForward()
    end
    -- Extra Center
    turtle.turnLeft()
    smartMoveForward()

    -- moving back to start
    turtle.turnRight()
    turtle.back()
    turtle.down()
    updateState(States.idle)
end

local function attemptToRefuel()
    out("Attempting to refuel!")
    turtle.select(4)
    turtle.placeUp()
    turtle.select(5)
    turtle.suckUp()
    turtle.refuel()
    turtle.select(4)
    turtle.digUp()
end

local function wait()
    repeat
        updateState()
        if data.lastKnownState == States.errored then
            out("Miner has hit an error, please check the miner!")
        end
        sleep(5)
    until data.lastKnownState == States.finished
end

-- [[ Setup ]]

reset()
writeToScreen("Mekanism Digital Miner Automater v1.0")
writeToScreen("By manaphoenix")
writeToScreen("License: CC0")
writeToScreen("")
writeToScreen("Loading...")

writeToScreen((modem and modem.isWireless() and "Modem Ready!") or "No Modem Found!")
if modem then
    modem.closeAll()
    modem.open(config.modemChannel)
end

local function doCycle()
    setupMiner()
    if not miner then
        out("Miner not found! Save data expected to be corrupted!")
        error("", 0)
    end
    miner.start()
    wait()
    pickupMiner()
end

local function pickUpAtLastState()
    if data.lastKnownState == States.idle then
        return
    elseif data.lastKnownState == States.digging then
        out("Program cannot return in the midle of digging!")
        error("", 0)
    elseif data.lastKnownState == States.moving then
        moveToNextLoc()
    elseif data.lastKnownState == States.refueling then
        attemptToRefuel()
    elseif data.lastKnownState == States.mining then
        wait()
        pickupMiner()
        updateState(States.moving)
        moveToNextLoc()
    elseif data.lastKnownState == States.finished then
        out("Cannot return in the middle of picking up miner!")
        error("", 0)
    end
end

local function main()
    pickUpAtLastState()
    while true do
        if not checkFuel() then
            updateState(States.refueling)
            attemptToRefuel()
            if not checkFuel() then
                out("Out of fuel! Mining stopped!")
                error("", 0)
            end
            updateState(States.idle)
        end
        updateState(States.digging)
        digArea()
        updateState(States.idle)
        doCycle()
        updateState(States.moving)
        moveToNextLoc()
    end
end

local modemFuncs = {
    ["stop"] = function()
        data.lastKnownState = States.idle
        if data.lastKnownState == States.mining then
            pickupMiner()
        end
        out("Miner stopped!")
        error("", 0)
    end,
    ["status"] = function()
        local state = ""
        for i, v in pairs(States) do
            if v == data.lastKnownState then
                state = i
                break
            end
        end
        if miner then
            state = state .. " and miner is " .. miner.getToMine() .. " blocks away"
        end
        out(state)
    end
}

local function eventHandler(ev)
    if ev[1] == "modem_message" then
        if modemFuncs[ev[5]] then
            modemFuncs[ev[5]]()
        end
    end
end

local function eventLoop()
    while true do
        local ev = { os.pullEvent() }
        eventHandler(ev)
    end
end

parallel.waitForAll(main, eventLoop)
