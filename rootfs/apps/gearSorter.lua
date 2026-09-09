---@type parallelAction
local actions = require("lib.parallelActions")

---@class inventoryItem
---@field name string
---@field count number
---@field nbtHash? string

---@class itemGroup
---@field displayName string
---@field id string

---@class inventoryItemDetailed
---@field count number
---@field damage? number
---@field displayName string
---@field enchantments? table
---@field itemGroups table<integer, itemGroup>
---@field mapColor? number
---@field mapColour? number
---@field maxCount number
---@field maxDamage? number
---@field name string
---@field nbt? string
---@field potionEffects? table
---@field tags table

---@type inventory
local outputBarrel = peripheral.wrap("sophisticatedstorage:barrel_4")
---@type inventory
local inputBarrel = peripheral.wrap("sophisticatedstorage:barrel_5")
---@type inventory
local backpack = peripheral.find("sophisticatedbackpacks:backpack")
---@type inventory
local bufferBarrel = peripheral.wrap("sophisticatedstorage:barrel_3")
---@type inventory
local apothSalvager = peripheral.find("apotheosis:salvaging_table")
---@type inventory
local silentBarrel = peripheral.wrap("sophisticatedstorage:barrel_1")
---@type inventory
local enchantmentBarrel = peripheral.wrap("sophisticatedstorage:barrel_0")
---@type inventory
local enchantmentLibrary = peripheral.find("apothic_enchanting:library")


local timerid = os.startTimer(1)

inputBarrel.name = peripheral.getName(inputBarrel)
outputBarrel.name = peripheral.getName(outputBarrel)
bufferBarrel.name = peripheral.getName(bufferBarrel)

local enchantmentExtractEnabled = true
local apothSalvagerEnabled = true
local silentGearEnabled = true

if backpack then
    backpack.name = peripheral.getName(backpack)
end

local silentFilter = {}

if fs.exists("config/silentFilter.lua") then
    local file = fs.open("config/silentFilter.lua","r")
    local data = file.readAll()
    file.close()
    silentFilter = textutils.unserialise(data)
else
    local file = fs.open("config/silentFilter.lua","w")
    file.write(textutils.serialise(silentFilter))
    file.close()
end

---@type detailedItem[]
local detailItemList = {}

local function buildDetailedItemList(invDevice)
    detailItemList = {}
    for i = 1, invDevice.size() do
        actions.addAction(function()
            local item = invDevice.getItemDetail(i)
            if item then
                detailItemList[i] = item
            end
        end)
    end
    actions.execute()
end

---@param item detailedItem
local function isInFilter(item)
    for _, filter in pairs(silentFilter) do
        if item.name == filter then
            return true
        end
    end
    return false
end

local function sortItems(invDeviceOverride)
    local invDevice = invDeviceOverride or backpack or inputBarrel
    if #invDevice.list() < 1 then return end

    buildDetailedItemList(invDevice)
    for slot, item in pairs(detailItemList) do
        if enchantmentExtractEnabled and item.enchantments and not item.name:match("enchanted_book") then
            actions.addAction(function()
                enchantmentBarrel.pullItems(invDevice.name, slot)
            end)
        elseif enchantmentExtractEnabled and item.name:match("enchanted_book") and enchantmentLibrary then
            actions.addAction(function()
                enchantmentLibrary.pullItems(invDevice.name, slot)
            end)
        elseif silentGearEnabled and isInFilter(item) then
            actions.addAction(function()
                silentBarrel.pullItems(invDevice.name, slot)
            end)
        else
            if apothSalvagerEnabled then
                --- default to try and push items into the apothSalvager
                actions.addAction(function()
                    apothSalvager.pullItems(invDevice.name, slot)
                    apothSalvager.pushItems(outputBarrel.name, 1, item.count)
                end)
            end
        end
    end
    actions.execute()
end

local function emptyBuffer()
    if #bufferBarrel.list() < 1 then return end
    sortItems(bufferBarrel)
    local invDevice = backpack or outputBarrel
    for i, _ in pairs(bufferBarrel.list()) do
        actions.addAction(function()
            invDevice.pullItems(bufferBarrel.name, i)
        end)
    end
    actions.execute()
end

while true do
    local ev = { os.pullEvent() }
    local evName = ev[1]
    if evName == "timer" then
        timerid = os.startTimer(10)
        sortItems()
        emptyBuffer()
    elseif evName == "peripheral" then
        local peripheralName = ev[2]
        if peripheralName:match("backpack") then
            backpack = peripheral.wrap(peripheralName)
            backpack.name = peripheral.getName(backpack)
        end
    elseif evName == "peripheral_detach" then
        local peripheralName = ev[2]
        if peripheralName:match("backpack") then
            backpack = nil
        end
    end
end
