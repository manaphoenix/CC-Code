-- peripherals
local reactor = peripheral.find("BiggerReactors_Reactor")
local monitor = peripheral.find("monitor")

-- variables
local termOnly = false
local reactorStatus = {prevStored = reactor.battery().stored()}
setmetatable(reactorStatus, {
    __index = function(_, key)
        if key == "active" then
            return reactor.active()
        elseif key == "valid" then
            return reactor.connected()
        elseif key == "capacity" then
            return reactor.battery().capacity()
        elseif key == "producedLastTick" then
            return reactor.battery().producedLastTick()
        elseif key == "stored" then
            return reactor.battery().stored()
        elseif key == "fuelCapacity" then
            return reactor.fuelTank().capacity()
        elseif key == "fuelStored" then
            return reactor.fuelTank().fuel()
        elseif key == "rodLevel" then
            return 100 - reactor.getControlRod(0).level()
        elseif key == "difference" then
            return reactorStatus.stored - reactorStatus.prevStored
        elseif key == "fill" then
            return math.floor((reactorStatus.stored / reactorStatus.capacity) *
                                  100)
        elseif key == "needed" then
            if reactorStatus.difference > 0 then -- return exact
                return reactorStatus.producedLastTick - reactorStatus.difference
            elseif reactorStatus.difference < 0 then -- return exact
                return reactorStatus.producedLastTick +
                           (-reactorStatus.difference)
            elseif reactorStatus.difference == 0 then
                local val = reactorStatus.stored - reactorStatus.prevStored
                if (val ~= 0) then -- return exact
                    return val
                else
                    if reactorStatus.stored == reactorStatus.capacity then -- if the stored == max cap then
                        return -1 -- -1 == reduce
                    else
                        return 0 -- 0 == increase
                    end
                end
            end
        else
            return key .. " not found!"
        end
    end
})

-- peripheral check
if not reactor then
    print("No reactor found! Exiting")
    return
end

if not reactor.connected then
    print("Not a valid reactor!")
    return
end

if not reactor.active() then reactor.setActive(true) end

local x,y = 0,0

if not monitor then
    print("Monitor not found, switching to terminal only mode")
    termOnly = true
else
    monitor.setTextScale(0.5)
end

x,y = monitor.getSize();
-- utility functions

local function addLetters(slot, length, letter)
    for i = 1, length do
        slot = slot .. letter
    end
    return slot
end

local function conditionMatches(str, condition)
    if not condition then return true end

    if type(condition) == "string" then
        return str:match(condition)
    elseif type(condition) == "boolean" then
        return condition
    end

    return true
end

local function write(str, colorTable, newLine, perip)
    local background = ""
    local foreground = ""
    perip = perip or term

    background = addLetters(background, str:len(), "f")

    if not colorTable then
        foreground = addLetters(foreground, str:len(), "0")
    else
        for _, v in ipairs(colorTable) do
            local condition = conditionMatches(str, v.condition)
            if condition then
                local length = v.length or str:len()-foreground:len()
                foreground = addLetters(foreground, length, colors.toBlit(v.color))
            end
        end

        if (str:len() - foreground:len()) > 0 then
            foreground = addLetters(foreground, str:len() - foreground:len(), "0")
        end
    end

    perip.blit(str, foreground, background)

    if newLine then
        local x, y = perip.getCursorPos()
        perip.setCursorPos(1, y+1)
    end
end

local function setUpGui()
    local txt = ""
    local foreground = ""
    local background = ""
    for i = 1, x do
        txt = txt .. " "
        foreground = foreground .. "0"
        background = background .. "7"
    end
    monitor.blit(txt, foreground, background)
end

local function resetScreen()
    term.clear()
    term.setCursorPos(1, 1)

    if not termOnly then
        monitor.clear()
        monitor.setCursorPos(1,1)
    end
end

-- first check

reactor.setAllControlRodLevels(0) -- start at nothing and slowly increase

local function writeStatus(perip)
    perip = perip or term
    local status = (reactorStatus.active and "Online" or "Offline")
    local storage = reactorStatus.stored .. " / " .. reactorStatus.capacity .. " FE"
    local fill = reactorStatus.fill .. "%"
    local rate = math.floor(reactorStatus.rodLevel) .. "%"
    local powerDifference = (reactorStatus.difference > 0 and ("+" .. reactorStatus.difference) or reactorStatus.difference)
    local need = reactorStatus.needed .. " FE"

    if perip == monitor then
        setUpGui()
        local txt = " Reactor Controller "
        monitor.setCursorPos(x/2-txt:len()/2, 1)
        write(txt, {{color = colors.white}}, true, monitor)
        write("", nil, true, monitor)
    end

    write("Status: " .. status, {{color = colors.white, length = 8},{color = colors.red, condition = "Offline"},{color = colors.green, condition = "Online"}}, true, perip)
    write("", nil, true, perip)
    write("Storage: " .. storage, {{color = colors.white, length = 9}, {color = colors.green, condition = reactorStatus.fill > 60}}, true, perip)
    write("Filled: " .. fill, {{color = colors.white, length = 8}, {color = colors.green, condition = reactorStatus.fill > 60}}, true, perip)
    write("Production Rate: " .. rate, nil,  true, perip)
    write("Difference: " .. powerDifference, {{color = colors.white, length = 12},{color = colors.red, condition = "-"}, {color = colors.green, condition = "+"}}, true, perip)
    write("Needed: " .. need, nil, true, perip)
end

while true do
    resetScreen()
    writeStatus()
    writeStatus(monitor)

    if (reactorStatus.needed == 0 and reactorStatus.fill >= 60) then
        reactor.setActive(false)
    end

    if (reactorStatus.needed > 0 and reactorStatus.fill < 60 ) then
        reactor.setActive(true)
    end

    if reactorStatus.fill >= 60 then
        reactor.setAllControlRodLevels(reactorStatus.fill)
    end

    reactorStatus.prevStored = reactorStatus.stored
    sleep()
end
