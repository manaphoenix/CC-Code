---@meta

---@class Enchantment
---@field level number The level of the enchantment
---@field name string The name of the enchantment
---@field displayName string The localized name of the enchantment

---@class itemGroup
---@field displayName string The localized name of the item group
---@field id string The id of the item group

---@class simpleItem
---@field count number The amount of items in the current slot
---@field name string The name of the item
---@field nbt? string The NBT hash of the item

---@class detailedItem: simpleItem
---@field displayName string The localized name of the item
---@field itemGroups? table<number, itemGroup> List of item groups the item is in (e.g., creative tabs)
---@field tags? table<string, boolean> The tags the item has
---@field maxCount number Max stack size of the item
---@field damage? number Current damage/durability
---@field maxDamage? number Max damage before breaking
---@field enchantments? table<number, Enchantment> List of enchantments
---@field mapColor? number Color tint for maps
---@field mapColour? number Alias for mapColor

---@class inventory
local inventory = {}

--- Gets the size of this inventory.
---@return number
function inventory.size()
end

--- Lists all items in this inventory.
---@return table<number, simpleItem>
function inventory.list()
end

--- Gets detailed information about an item.
---@param slot number
---@return detailedItem
function inventory.getItemDetail(slot)
end

--- Gets the maximum number of items which can be stored in this slot.
---@param slot number
---@return number
function inventory.getItemLimit(slot)
end

--- Push items from one inventory to another connected inventory.
---@param toName string
---@param fromSlot number
---@param limit? number
---@param toSlot? number
---@return number Amount transferred
function inventory.pushItems(toName, fromSlot, limit, toSlot)
end

--- Pull items from a connected inventory into this one.
---@param fromName string
---@param fromSlot number
---@param limit? number
---@param toSlot? number
---@return number Amount transferred
function inventory.pullItems(fromName, fromSlot, limit, toSlot)
end

return inventory
