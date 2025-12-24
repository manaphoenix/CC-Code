local net = {}

local config = require("config.defaults")
local peripherals = require("lib.peripherals")
local protocol = require("lib.protocol")

local modem = peripherals.enderModem
local channel = config.modemCode

-- open modem once at load time
modem.open(channel)

-- send a protocol-valid message
function net.send(msg)
    if not protocol.validate(msg) then
        return false
    end

    modem.transmit(channel, channel, msg)
    return true
end

-- process a raw event table from os.pullEvent()
-- returns payload table or nil
function net.receive(event)
    if type(event) ~= "table" then
        return nil
    end

    if event[1] ~= "modem_message" then
        return nil
    end

    -- CC modem event layout:
    -- 1: event name
    -- 2: side
    -- 3: channel
    -- 4: replyChannel
    -- 5: message
    -- 6: distance
    local msg = event[5]

    if not protocol.validate(msg) then
        return nil
    end

    return msg.payload
end

return net
