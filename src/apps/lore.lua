---@diagnostic disable: undefined-global

local INV_SIDE = "left"
local MODEM_SIDE = "right"
local MODEM_CHANNEL = 1337

local SECTION_SIGN = "\167"

if not peripheral.isPresent(INV_SIDE) then
    print("No barrel on left.")
    return
end

if not peripheral.isPresent(MODEM_SIDE) then
    print("No modem on right.")
    return
end

---@type ccTweaked.peripheral.Inventory
---@diagnostic disable-next-line: assign-type-mismatch
local barrel = peripheral.wrap(INV_SIDE)
---@type ccTweaked.peripheral.Modem
---@diagnostic disable-next-line: assign-type-mismatch
local modem = peripheral.wrap(MODEM_SIDE)

modem.open(MODEM_CHANNEL)

local items = barrel.list()
local slot = next(items)

if not slot then
    print("No item in barrel.")
    return
end

local item = barrel.getItemDetail(slot)

print("Editing: " .. (item.displayName or item.name))
print("")

write("Lore text: ")
local lore = read()

if lore == "" then
    print("Cancelled.")
    return
end

print("")
print("Color examples:")
print("red")
print("gold")
print("#FF55FF")
print("")

write("Color: ")
local color = read()

if color == "" then
    color = "white"
end

---@param text string
---@return string
local function trim(text)
    return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

---@param text string
---@return string
local function escapeJson(text)
    text = text:gsub("\\", "\\\\")
    text = text:gsub('"', '\\"')
    return text
end

---@param value string
---@return boolean
local function isHexColor(value)
    return value:match("^#%x%x%x%x%x%x$") ~= nil
end

color = trim(color)
lore = escapeJson(lore)

-- normalize named colors to lowercase
if not isHexColor(color) then
    color = string.lower(color)
end

color = escapeJson(color)

local mcSlot = slot - 1

local cmd =
    'data modify block ~ ~ ~-1 ' ..
    'Items[{Slot:' .. mcSlot .. 'b}].components."minecraft:lore" ' ..
    'set value [\'[{"text":"' .. lore .. '","italic":false,"color":"' .. color .. '"}]\']'

print("")
print("Running:")
print(cmd)
print("")

local ok, msg, data = commands.exec(cmd)

print("Success: " .. tostring(ok))

if msg ~= nil then
    print("Message:")
    if type(msg) == "table" then
        print(textutils.serialize(msg))
    else
        print(tostring(msg))
    end
end

if data ~= nil then
    print("Extra Data:")
    print(textutils.serialize(data))
end