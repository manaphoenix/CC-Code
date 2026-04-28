-- VS Engine Configuration
-- All configurable parameters for the VS Engine system

local config = {}

-- Peripheral side configurations
config.input_side = "left"
config.output_side = "right"
config.ender_modem_side = "top"

-- Output side mapping (overrides default side mapping)
config.output_sides = {
    -- valid options are ["top", "bottom", "left", "right", "front", "back"]
    front = "front",  -- inversion shouldn't be needed here as long as the relay is placed correctly
    back = "back",    -- inversion shouldn't be needed here as long as the relay is placed correctly
    left = "right",   -- inverted b/c the blocks are on opposite sides of the computer
    right = "left",   -- inverted b/c the blocks are on opposite sides of the computer
    top = "top",      -- top is always the top
    bottom = "bottom" -- bottom is always the bottom
}

-- Gear side mapping (how each side of the input relay maps to the rotation speed controller)
config.gear_sides = {
    [1] = "left",
    [2] = "top",
    [3] = "back",
    [4] = "front"
}

-- Latch relay side (what side the latch give redstone power to to signify the machine being off)
config.is_off_side = "right"

-- Modem configuration
config.modem_code = 1337
config.security_key = "dogs"

-- Fuel tank configuration
config.fuel_capacity = 24000
config.fuel_update = 0.5 -- how often in seconds should we check the fuel?

-- Default gear speeds (used for auto-detection)
config.def_gear_speeds = {
    G1 = 65,  -- Gear 1
    G2 = 128, -- Gear 2
    G3 = 256, -- Gear 3
    GR = -30, -- Gear Reverse
    GS = 1,   -- Gear Suspension Controller
}

-- Debug settings
config.debug_messages = false -- should it print the debug message(s)

-- Version information
config.version = "2.0.0"

return config
