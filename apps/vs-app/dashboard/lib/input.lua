local input       = {}

local running     = true
local locked      = true
local tuningState = 0

local state       = require("lib.state")
local display     = require("lib.display")
local config      = require("config.defaults")
local peripherals = require("lib.peripherals")
local net         = require("lib.net")
local protocol    = require("lib.protocol")

-- Handle mouse clicks in term header
local function handleMouseClick(button, x, y)
    local mx, my = term.getSize()
    if y == 1 then
        if x >= 1 and x <= 4 then
            running = false
        elseif x >= mx - 3 then
            locked = true
            display.drawLockScreen(config.lockText)
        end
    end
end

-- Handle monitor touches (tuning monitor menu)
local function handleMonitorTouch(side, x, y)
    local tuningMon    = peripherals.getTuningMonitor()
    local _, tmy       = tuningMon.getSize()
    local yposCentered = math.floor(tmy / 2)

    if side == config.tuning_monitor_side then
        if tuningState == 1 then -- main menu
            if y == yposCentered + 1 then
                tuningState = 2
                display.drawTransmissionMenu()
            elseif y == yposCentered + 2 then
                tuningState = 3
                display.drawSuspensionMenu()
            end
        elseif tuningState == 2 or tuningState == 3 then
            if y == 1 and x <= 2 then
                tuningState = 1
                display.drawMenu()
            end
        end
    end
end

-- Handle key presses
local function handleKey(key)
    if key == keys.c then
        locked = true
        tuningState = 0
        display.drawLockScreen(config.lockText)
    end
end

-- Handle a single event from os.pullEventRaw
function input.handleEvent(event)
    local ev = event[1]

    if ev == "mouse_click" and not locked then
        handleMouseClick(event[2], event[3], event[4])
    elseif ev == "monitor_touch" and not locked then
        handleMonitorTouch(event[2], event[3], event[4])
    elseif ev == "key" and not locked then
        handleKey(event[2])
    elseif ev == "redstone" and locked then
        if rs.getInput("left") then
            locked = false
            tuningState = 1
            display.drawMenu()
        end
    elseif ev == "modem_message" then
        -- Use net.receive to parse safely
        local payload = net.receive(event)
        if payload then
            state.updateFromMessage(payload)
            display.updateStatusMonitor(state.get())
        end
    end

    return running
end

return input
