local modem = peripheral.wrap("back")
modem.closeAll()
modem.open(1337)
local messageTemplate = "Message received from Mek Miner:"
term.clear()
term.setCursorPos(1,1)

local function eventModem(ev, side, channel, replyChannel, message, distance)
    print(messageTemplate)
    print(message)
end

local function eventHandler(ev)
    if ev[1] == "modem_message" then
        eventModem(table.unpack(ev))
    end
end

while true do
    local ev = {os.pullEvent()}
    eventHandler(ev)
end