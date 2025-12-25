---@meta

---@class FluidTank
---@field name string The name of the fluid
---@field amount number Amount in mB (1:1000th of a bucket)

---@class fluid_storage
local fluid_storage = {}

--- Returns a table of tanks indexed by number.
---@return table<number, FluidTank>
function fluid_storage.tanks()
end

--- Transfers fluid to a tank.
---@param toName string The name of the target tank
---@param limit? number Optional limit of fluid to transfer
---@param fluidName? string Optional fluid type
---@return number Amount transferred
function fluid_storage.pushFluid(toName, limit, fluidName)
end

--- Pulls fluid from a tank.
---@param fromName string The name of the source tank
---@param limit? number Optional limit of fluid to pull
---@param fluidName? string Optional fluid type
---@return number Amount transferred
function fluid_storage.pullFluid(fromName, limit, fluidName)
end

return fluid_storage
