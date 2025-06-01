local mod = components.modem
local repChannel = 420
local modChannel = 69
mod.open(repChannel)

while true do
    mod.transmit(modChannel, repChannel, table.pack(os.pullEventRaw())) 
end
