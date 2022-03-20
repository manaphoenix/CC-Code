local mon = components.monitor
local modem = components.modem
local modChannel = 69
local repChannel = 420
term.redirect(mon)
term.clear()
term.setCursorPos(1, 1)
modem.open(modChannel) -- giggity

local function runShell() shell.run("shell") end

local function receiveEvents()
    while true do
        local event, side, channel, replyChannel, message, distance =
            os.pullEvent("modem_message")
        if channel == modChannel and replyChannel == repChannel then
            if type(message == table) then
                os.queueEvent(table.unpack(message))
            end
        end
    end
end

parallel.waitForAll(runShell, receiveEvents)
