-- mekMiner auto installer

local data = http.get("https://raw.githubusercontent.com/manaphoenix/CC_OC-Code/main/mekMiner.lua")
if data then
    local file = data.readAll()
    data.close()
    local f = fs.open("mekMiner.lua", "w")
    f.write(file)
    f.close()
end

local arg = {...}
local configFile = "mekConfig.conf"
local mx,my = term.getSize()

local function writeToScreen(str, skipNewLine)
    str = tostring(str)
    -- deal with word wrapping
    if #str < mx then
        term.write(str)
    else
        local words = {}
        for word in str:gmatch("[^%s]+") do
            table.insert(words, word)
        end
        local line = ""
        for i, word in ipairs(words) do
            if #line + #word + 1 > mx then
                term.write(line)
                term.setCursorPos(1, select(2, term.getCursorPos()) + 1)
                line = ""
            end
            line = line .. word .. " "
        end
        term.write(line)
    end


    if not skipNewLine then
        term.setCursorPos(1, select(2, term.getCursorPos()) + 1)
    end
end

local function reset()
    term.clear()
    term.setCursorPos(1, 1)
end

if arg[1] then
    reset()
    writeToScreen("Program updated!")
    error("", 0)
end

local config = {
    modemChannel = 1337, -- what channel to open the modem on (if you gave it one)
    stopFuelLevel = 64, -- what fuel level to stop mining at
}

if not fs.exists("mekminer.conf") then
    reset()
    writeToScreen("What fuel level do you want to stop mining?")
    writeToScreen("(64 is default)")
    writeToScreen("Fuel level: ", true)
    local fuelLevel = tonumber(read())
    config.stopFuelLevel = fuelLevel or 64

    reset()
    writeToScreen("What modem channel do you want to use?")
    writeToScreen("(1337 is default)")
    writeToScreen("Modem channel: ", true)
    local modemChannel = tonumber(read())
    config.modemChannel = modemChannel or 1337

    local file = fs.open(configFile, "wb")
    file.write(textutils.serialise(config))
    file.close()
end

reset()
writeToScreen("Do you want this program to start automatically?")
writeToScreen("(y/n)")
writeToScreen("Autostart: ", true)
local auto = read()
auto = (auto == "y") and true or false
if auto then
    local f = fs.open("startup.lua", "w")
    f.write("shell.run(\"mekMiner\")")
    f.close()
end

reset()
writeToScreen("Do you want to name this turtle?")
writeToScreen("(y/n)")
writeToScreen("name: ", true)
local name = read()
if name == "y" then
    reset()
    writeToScreen("What name do you want to give this turtle?")
    name = read()
    os.setComputerLabel(name)
end

reset()
writeToScreen("Please put these items in these slots: ")
writeToScreen("1. Digital miner")
writeToScreen("2. Energy Storage")
writeToScreen("3. Ender Chest (for output)")
writeToScreen("4. Ender Chest (for refueling)")
writeToScreen("Press any key to continue")
local _ = os.pullEvent("key")

reset()
writeToScreen("Required tools:")
writeToScreen("1. Diamond Pickaxe")
writeToScreen("OPTIONAL:")
writeToScreen("1. Ender modem (for sending/receiving messages)")
writeToScreen("2. Chunk Loader (for loading chunks)")
writeToScreen("Note: Chunk Loader is from an addon!")
writeToScreen("Press any key to continue")
local _ = os.pullEvent("key")

reset()
writeToScreen("Installer complete!")
writeToScreen("To update the program, run this again with the argument 'update'")
writeToScreen("To start the program, run \"mekMiner\"")
writeToScreen("Press any key to exit!")
local _ = os.pullEvent("key")

reset()