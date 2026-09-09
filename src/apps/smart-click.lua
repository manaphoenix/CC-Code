local keyboard = smartglasses.modules["keyboard"]

keyboard.setHandlingInteraction(2,true)

local file = fs.open("interactionOutput.lua","w")

local ev, int, blockstate = os.pullEvent("player_interaction")

if blockstate ~= nil then
    file.write(textutils.serialise(blockstate))
end

file.close()

keyboard.setHandlingInteraction(2,false)