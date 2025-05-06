--- Furnace library by manaphoenix
---@class FurnaceLib
local module = {}

---@type table
local furnaces = {}
---@type table
local fuelChest = {}
---@type table
local outputChest = {}
---@type table
local inputChest = {}

-- internal functions

--- Counts the total fuel in the fuel chest
---@return number
local function countFuel()
    local fuel = 0
    for _, v in pairs(fuelChest.list()) do
        fuel = fuel + v.count
    end
    return fuel
end

--- Counts the total input items in the input chest
---@return number
local function countInput()
    local input = 0
    for _, v in pairs(inputChest.list()) do
        input = input + v.count
    end
    return input
end

--- Finds the first filled slot in the inventory
---@param inventory table
---@return number|nil
local function getFilledSlot(inventory)
    for i, v in pairs(inventory.list()) do
        if v.count > 0 then
            return i
        end
    end
    return nil
end

--- Gets the name of a peripheral
---@param periph table
---@return string|nil
local function getName(periph)
    if periph then
        return peripheral.getName(periph)
    end
    return nil
end

-- module functions

--- Adds a furnace to the list of furnaces
---@param furnace table
function module.addFurnace(furnace)
    table.insert(furnaces, furnace)
end

--- Removes a furnace from the list of furnaces
---@param furnace table
function module.removeFurnace(furnace)
    for i, v in pairs(furnaces) do
        if v == furnace then
            table.remove(furnaces, i)
            return
        end
    end
end

--- Gets the list of all furnaces
---@return table
function module.getFurnaces()
    return furnaces
end

--- Gets the count of all furnaces
---@return number
function module.getFurnaceCount()
    return #furnaces
end

--- Sets the fuel chest
---@param chest table
function module.setFuelChest(chest)
    fuelChest = chest
end

--- Sets the output chest
---@param chest table
function module.setOutputChest(chest)
    outputChest = chest
end

--- Sets the input chest
---@param chest table
function module.setInputChest(chest)
    inputChest = chest
end

--- Restacks items within a chest
---@param inventory table
function module.restackChest(inventory)
    for i, _ in pairs(inventory.list()) do
        inventory.pushItems(getName(inventory), i)
    end
end

--- Refuels all furnaces evenly from the fuel chest
function module.refuelFurnaces()
    local fuel = countFuel()
    local maxSplit = math.floor(fuel / #furnaces)
    local attemptFilled = 0
    print(maxSplit)
    for _, v in pairs(furnaces) do
        repeat
            local slot = getFilledSlot(fuelChest)
            local movedItems = v.pullItems(getName(fuelChest), slot, maxSplit, 2)
            if movedItems == 0 then
                break
            end
            attemptFilled = attemptFilled + movedItems
        until attemptFilled >= maxSplit
    end
end

--- Empties all furnaces into the output chest
function module.emptyFurnaces()
    for _, v in pairs(furnaces) do
        v.pushItems(getName(outputChest), 3)
    end
end

--- Fills all furnaces with input items
---@return boolean, string
function module.fillFurnaces()
    if #outputChest.list() ~= 0 then
        return false, "Empty the output chest!"
    end

    local items = countInput()
    if items < 8 then
        return false, "Not enough items in input chest!"
    end
    local maxSplit = math.floor(items / #furnaces)
    maxSplit = maxSplit > 8 and maxSplit or 8
    for _, v in pairs(furnaces) do
        local attemptFilled = 0
        repeat
            local slot = getFilledSlot(inputChest)
            local movedItems = v.pullItems(getName(inputChest), slot, maxSplit, 1)
            if movedItems == 0 then
                break
            end
            attemptFilled = attemptFilled + movedItems
        until attemptFilled >= maxSplit
    end
    return true, ""
end

--- Dumps all items from furnaces back to their respective chests
function module.dumpFurnaces()
    for _, v in pairs(furnaces) do
        v.pushItems(getName(outputChest), 3)
        v.pushItems(getName(fuelChest), 2)
        v.pushItems(getName(inputChest), 1)
    end
end

return module