---@meta

---@class FluidTank
---@field name string the name of the fluid
---@field amount number in mB (1:1000th of a bucket)

---@class fluid_storage
---@field tanks fun(): table<number, FluidTank>
---@field pushFluid fun(toName: string, limit?: number, fluidName?: string): number -- returns amount transferred
---@field pullFluid fun(fromName: string, limit?: number, fluidName?: string): number -- returns amount transferred
local fluid_storage = {
    tanks = function() end,
    pushFluid = function() end,
    pullFluid = function() end
}

return fluid_storage
