local comps = components or peripheral
local term = require("term")
local shell = require("shell")

local mon = comps.monitor
local modem = comps.modem

local config = {
    modChannel = 69,
    repChannel = 420
}

if mon then
    mon.setTextScale(0.5)
    term.redirect(mon)
end

term.clear()
term.setCursorPos(1, 1)

modem.open(config.modChannel)

local function runShell()
    shell.run("shell")
end

local function receiveEvents()
    while true do
        local event, side, channel, replyChannel, message = os.pullEvent("modem_message")
        if channel == config.modChannel and replyChannel == config.repChannel then
            if type(message) == "table" and message.type == "event" and type(message.payload) == "table" then
                os.queueEvent(table.unpack(message.payload))
            end
        end
    end
end

parallel.waitForAll(runShell, receiveEvents)
