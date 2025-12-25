---@meta

---@class Enchantment
---@field level number the level of the enchantment
---@field name string the name of the enchantment
---@field displayName string the localized name of the enchantment

---@class itemGroup
---@field displayName string the localized name of the item group
---@field id string the id of the item group

---@class simpleItem
---@field count number the amount of items in the current slot
---@field name string the name of the item
---@field nbt? string the nbt hash of the item

---@class detailedItem:simpleItem
---@field displayName string the localized name of the item
---@field itemGroups? table<number, itemGroup> the list of item groups the item is in (seems to be creative tab)
---@field tags? table<string, boolean> the tags the item has, boolean is useless?
---@field maxCount number the max stack size of the item
---@field damage? number the amount of the damage the item has (durability uses this as an example)
---@field maxDamage? number the max damage the item can have before it breaks (disappears)
---@field enchantments? table<number, Enchantment> the list of enchantments the item has
---@field mapColor? number the number that represents how its tinted when in a particular biome
---@field mapColour? number same as mapColor

---@class inventory
---@field size fun(): number Gets the size of this inventory.
---@field list fun(): table<number, simpleItem> List all items in this inventory.
---@field getItemDetail fun(slot: number): detailedItem Gets detailed information about an item.
---@field getItemLimit fun(slot: number): number Gets the maximum number of items which can be stored in this slot.
---@field pushItems fun(toName: string, fromSlot: number, limit?: number, toSlot?: number): number Push items from one inventory to another connected one.
---@field pullItems fun(fromName: string, fromSlot: number, limit?: number, toSlot?: number): number Pull items from a connected inventory into this one.
local inventory = {
    size = function() end,
    list = function() end,
    getItemDetail = function() end,
    getItemLimit = function() end,
    pushItems = function() end,
    pullItems = function() end,
}

return inventory
