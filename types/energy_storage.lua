---@meta

---@class energy_storage
---@field getEnergy fun(): number The energy stored in this block, in FE.
---@field getEnergyCapacity fun(): number The maximum amount of energy this block can store, in FE.
local energy_storage = {
    getEnergy = function() end,
    getEnergyCapacity = function() end
}

return energy_storage
