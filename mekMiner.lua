--- Automating the Mekanism Digital Miner ---
-- By manaphoenix
-- License: CC0
-- requires a diamond pickaxe, an ender chest, a digital miner, and a power block
-- optional addons are an ender modem to connect to a pocket computer.
-- setup inventory as such: miner, power block, ender chest

local config = {
    modemChannel = 1337, -- what channel to open the modem on (if you gave it one)
    stopFuelLevel = 64, -- what fuel level to stop mining at
}

if fs.exists("mekminer.conf") then
    local file = fs.open("mekminer.conf", "rb")
    config = textutils.unserialise(file.readAll())
    file.close()
    print(type(config.stopFuelLevel))
else
    local file = fs.open("mekminer.conf", "wb")
    file.write(textutils.serialise(config))
    file.close()
    print("Please setup mekminer.conf")
    error("",0)
end

term.clear()
term.setCursorPos(1, 1)

local States = {
    idle = 0,
    mining = 1,
    finished = 2,
    errored = 3,
    moving = 4,
    digging = 5
}

local curState = States.idle

local previousCheck = 0
local modem = peripheral.find("modem")
local miner = peripheral.wrap("top")
local waitingState = States.idle
if modem == nil then
    print("No modem found! Manual mode activated!")
elseif modem and not modem.isWireless() then
    print("Modem is not wireless! Manual mode activated!")
else
    modem.closeAll()
    modem.open(config.modemChannel)
end

local function out(str)
    str = tostring(str)
    if modem then
        modem.transmit(config.modemChannel,config.modemChannel,str)
    else
        print(str)
    end
end

local function checkFuel()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel < config.stopFuelLevel then
        out("Out of fuel! Stopping mining!")
        return false
    end
    return true
end

local function emptyTurtle()
    for i = 4, 16 do
        turtle.select(i)
        turtle.dropUp()
    end
end

local function setupMiner()
    if curState ~= States.idle then
        out("Already mining!")
        return
    end
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
    curState = States.mining
end

local function pickupMiner()
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
    curState = States.idle
end

local function checkState()
    local blocks = miner.getToMine()
    if blocks > 0 and blocks ~= previousCheck then
        previousCheck = blocks
        return States.mining
    elseif blocks > 0 and blocks == previousCheck then
        return States.errored
    else
        return States.finished
    end
end

local function saveState()
    local f = fs.open("mekMinerState.dat", "wb")
    f.write(textutils.serialise(curState))
    f.close()
end

local function loadState()
    if not fs.exists("mekMinerState.dat") then
        return
    end
    local f = fs.open("mekMinerState.dat", "rb")
    curState = f.read()
    f.close()
end

local function wait()
    repeat
        waitingState = checkState()
        if waitingState == States.errored then
            out("Miner has hit an error, please check the miner!")
        end
        sleep(5)
    until waitingState == States.finished
    waitingState = States.idle
end

local function doCycle()
    if curState == States.moving or curState == States.digging then return end
    setupMiner()
    saveState()
    miner.start()
    wait()
    pickupMiner()
    saveState()
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

local function moveToNextLoc()
    if not checkFuel() then
        return
    end

    turtle.up()
    for i = 1, 32 do
        smartMoveForward()
    end
    turtle.down()
end

-- requires 4x4x4 space
local function digArea()
    if curState ~= States.digging then return end

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
end

local function main()
    loadState()
    while true do
        if not checkFuel() then
            out("Out of fuel! Stopping mining!")
            error("", 0)
        end
        if curState == States.moving then
            out("Turtle stopped unexpectedly, please manually move to next location!")
            curState = States.digging
            saveState()
            error("", 0)
        end
        doCycle()
        curState = States.moving
        saveState()
        moveToNextLoc()
        curState = States.digging
        digArea()
    end
end

local modemFuncs = {
    ["stop"] = function()
        curState = States.idle
        saveState()
        if curState == States.mining then
            pickupMiner()
        end
        out("Miner stopped!")
        error("",0)
    end,
    ["status"] = function()
        local state = ""
        for i,v in pairs(States) do
            if v == curState then
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
        local ev = {os.pullEvent()}
        eventHandler(ev)
    end
end

parallel.waitForAll(main, eventLoop)