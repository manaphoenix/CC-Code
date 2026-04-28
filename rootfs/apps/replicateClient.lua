local comps = components or peripheral
local modem = comps.modem

local config = {
    modChannel = 69,
    repChannel = 420
}

modem.open(config.repChannel)

while true do
    local evt = table.pack(os.pullEventRaw())
    modem.transmit(config.modChannel, config.repChannel, {
        type = "event",
        payload = evt
    })
end
