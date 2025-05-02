-- Find all peripherals with an inventory component
local inventories = { peripheral.find("inventory") }

-- LUT to store references for the inventories by user-friendly names
-- lut: table<string, peripheral>
local lut = {}

-- Internal LUT to store full inventory names for quick access
-- fullNameLut: table<string, peripheral>
local fullNameLut = {}

-- Create a 'manager' table that will hold our inventory managers
-- manager: InventoryManager
local manager = {}

--- [[ Internal functions ]] 

--- Counts how many items with a specific name exist across all inventories
-- @param itemName string The name of the item to count
-- @return number The total count of the item across all inventories
local function countItemInInventories(itemName)
    local count = 0
    for _, inv in pairs(lut) do
        for _, item in pairs(inv.list()) do
            if item.name:match(itemName) then
                count = count + item.count
            end
        end
    end
    return count
end

-- Function to handle errors when an inventory is not found
-- @param name string The name of the inventory that was not found
local function handleInventoryError(name)
    error("Inventory '" .. name .. "' not found")
end

-- Function to get an inventory by its name (supports looking up by short or full name)
-- @param name string The name of the inventory
-- @return peripheral The found inventory peripheral
local function getInventoryByName(name)
    -- Check if the name exists in the user-friendly LUT
    local inv = lut[name] or fullNameLut[name]

    -- If not found in either LUT, handle the error
    if not inv then
        handleInventoryError(name)
    end

    return inv
end

-- Internal helper function to add a peripheral to the LUTs
-- @param peripheral peripheral The peripheral to be added
local function addInventoryPeripheral(inv)
    local fullName = peripheral.getName(inv)

    -- Check for duplicate inventories
    if lut[fullName] or fullNameLut[fullName] then
        error("Inventory with full name '" .. fullName .. "' already exists in the manager")
    end

    local shortName = fullName:match(":(.*)")  -- Extract short name
    local modName = fullName:match("^(.-):")  -- Extract mod name

    -- Add mod and name properties to the peripheral
    inv.name = fullName
    inv.mod = modName

    -- Enrich the peripheral with helper methods
    -- Calculate the number of used slots
    function inv:used()
        local count = 0
        for _ in pairs(self.list()) do
            count = count + 1
        end
        return count
    end

    -- Calculate the number of free slots
    function inv:free()
        return self.size() - self:used()
    end

    -- Check if the inventory is empty
    function inv:isEmpty()
        return self:used() == 0
    end

    -- Check if the inventory is full
    function inv:isFull()
        return self:used() == self.size()
    end

    -- Check if the inventory contains a specific item
    function inv:hasItem(itemName)
        for _, item in pairs(self.list()) do
            if item.name == itemName then
                return true
            end
        end
        return false
    end

    -- New request function to fetch items
    -- @param itemName string The name of the item to fetch
    -- @param amount number? The amount of items to fetch (optional, defaults to free slots)
    -- @return number The number of items successfully fetched
    function inv:fetch(itemName, amount)
        if not amount then
            amount = self:free() -- Use the 'free' slots instead of 'fill'
        end
        
        local requestedAmount = 0
        for _, otherInventory in pairs(lut) do
            if requestedAmount < amount then
                local availableToPull = countItemInInventories(itemName)
        
                if availableToPull > 0 then
                    -- Loop through the other inventory to find the slots with the item
                    for slot, item in pairs(otherInventory.list()) do
                        if item.name:match(itemName) and requestedAmount < amount then
                            -- Calculate how much we can pull from this slot
                            local pullAmount = math.min(amount - requestedAmount, item.count)
                            
                            -- Pull the items from this slot
                            self.pullItems(otherInventory.name, slot, pullAmount)
                            requestedAmount = requestedAmount + pullAmount
                        end
                        
                        -- If we've already pulled enough items, break out of the loop
                        if requestedAmount >= amount then
                            break
                        end
                    end
                end
            end
            
            -- If we've already pulled enough items, break out of the outer loop
            if requestedAmount >= amount then
                break
            end
        end
        
        return requestedAmount
    end

    -- Register in LUTs
    lut[shortName] = inv
    fullNameLut[fullName] = inv
end

-- Function to register inventories and create metatables
local function initInventories()
    -- Register all found inventories
    for _, inv in ipairs(inventories) do
        addInventoryPeripheral(inv)
    end

    -- Set metatable so that manager.chest (or whatever the name is) works
    setmetatable(manager, {
        __index = function(t, key)
            return getInventoryByName(key)
        end
    })
end

-- [[ Inventory update functions ]] 

--- Updates the inventories when peripherals are attached or detached
-- @param event string The event that triggered the update (either "peripheral" or "peripheral_detach")
-- @param side string The side of the peripheral that was attached or detached
function manager.updateInventory(event, side)
    if event == "peripheral" then
        -- Wrap the new peripheral
        local newPeripheral = peripheral.wrap(side)

        -- Check if the new peripheral is an inventory
        if peripheral.hasType(newPeripheral, "inventory") then
            -- Attempt to add the new peripheral to the manager using the helper
            addInventoryPeripheral(newPeripheral)
        end
    elseif event == "peripheral_detach" then
        -- Inventory was detached, handle removal
        if fullNameLut[side] then
            local fullName = fullNameLut[side]

            -- Remove the inventory from the LUT and fullNamesLUT
            lut[fullName] = nil
            fullNameLut[side] = nil
        end
    end
end

--- Refreshes the inventories by removing any that are no longer present and adding any new ones
function manager.refreshInventories()
    -- Remove any inventories that no longer exist
    for fullName, inv in pairs(fullNameLut) do
        if not peripheral.isPresent(inv) then
            lut[inv.name] = nil
            fullNameLut[fullName] = nil
        end
    end

    -- Add any new inventories
    local currentInventories = { peripheral.find("inventory") }
    for _, inv in ipairs(currentInventories) do
        addInventoryPeripheral(inv)
    end
end

-- Method to dynamically override the LUT mapping (post-init)
-- @param oldName string The old inventory name
-- @param newName string The new inventory name
function manager.rename(oldName, newName)
    local inv = lut[oldName]

    if not inv then
        error("Inventory with name '" .. oldName .. "' not found")
    end

    -- Check if the new name already exists in the LUT
    if lut[newName] then
        error("An inventory with the name '" .. newName .. "' already exists")
    end

    -- Perform the rename in the LUT
    lut[newName] = inv
    lut[oldName] = nil -- Remove the old name from the LUT
end

-- Removes an inventory from the LUT by its name
-- @param name string The name of the inventory to remove
function manager.removeInventory(name)
    local inv = lut[name]
    if not inv then
        error("Inventory with name '" .. name .. "' not found")
    end

    local fullName = peripheral.getName(inv)
    lut[name] = nil
    fullNameLut[fullName] = nil
end

--- Filter inventories using a predicate function
-- @param predicate fun(name: string, inv: peripheral): boolean A function that takes (name, inventory) and returns true if it should be included
-- @return table<string, peripheral> A table of matching inventories
function manager.filterInventories(predicate)
    local results = {}
    for name, inv in pairs(lut) do
        if predicate(name, inv) then
            results[name] = inv
        end
    end
    return results
end

--- Returns a list of all inventories in the manager
-- @return table<string, peripheral> A table of all inventories
function manager.listInventories()
    return lut
end

-- [[ Replication of inventory methods ]] 

-- Helper functions to move items between inventories
function manager.pushItems(from, to, fromSlot, toSlot, limit)
    local invFrom = getInventoryByName(from)
    local invTo = getInventoryByName(to)
    return invFrom.pushItems(invTo.name, fromSlot, limit, toSlot)
end

function manager.pullItems(from, to, fromSlot, toSlot, limit)
    local invFrom = getInventoryByName(from)
    local invTo = getInventoryByName(to)
    return invFrom.pullItems(invTo.name, fromSlot, limit, toSlot)
end

-- Utility functions to interact with inventory items
function manager.list(invName)
    local inv = getInventoryByName(invName)
    return inv.list()
end

function manager.size(invName)
    local inv = getInventoryByName(invName)
    return inv.size()
end

function manager.getItemLimit(invName, slot)
    local inv = getInventoryByName(invName)
    return inv.getItemLimit(slot)
end

function manager.getItemDetail(invName, slot)
    local inv = getInventoryByName(invName)
    return inv.getItemDetail(slot)
end

-- [[ new inventory methods ]] 

function manager.request(invName, itemName, amount)
    local inv = getInventoryByName(invName)
    local totalPulled = 0
    local maxAmount = amount or math.huge

    for _, sourceInv in pairs(lut) do
        if sourceInv ~= inv then
            local availableToPull = countItemInInventories(itemName)

            if availableToPull > 0 then
                -- Find the first slot containing the requested item in the source inventory
                for slot, item in pairs(sourceInv.list()) do
                    if item.name:match(itemName) then
                        local pullAmount = math.min(maxAmount - totalPulled, item.count)
                        sourceInv.pushItems(inv.name, slot, pullAmount)
                        totalPulled = totalPulled + pullAmount
                        if totalPulled >= maxAmount then
                            return totalPulled
                        end
                    end
                end
            end
        end
    end

    return totalPulled
end

-- Initialize the inventories and set up manager access
initInventories()

return manager
