local defaults = {}

-- sides
defaults.output_side = "right"
defaults.input_side = "left"
defaults.ender_modem_side = "top"

-- side mapping for outputs
defaults.outputsides = {
    front = "front",
    back = "back",
    left = "right", -- inverted because of opposite placement
    right = "left", -- inverted because of opposite placement
    top = "top",
    bottom = "bottom"
}

-- input sides mapped to gear controllers
defaults.gearSides = {
    [1] = "left",
    [2] = "top",
    [3] = "back",
    [4] = "front"
}

-- side that latch signals "off"
defaults.isOffSide = "front"

-- ender modem
defaults.modemCode = 1337
defaults.securityKey = "dogs"

-- fuel settings
defaults.fuelCapacity = 24000
defaults.fuelUpdate = 0.5 -- seconds

-- default gear speeds (used only on first config scan)
defaults.defGearSpeeds = {
    G1 = 65,  -- Gear 1
    G2 = 128, -- Gear 2
    G3 = 256, -- Gear 3
    GR = -30, -- Gear Reverse
    GS = 1    -- Gear Suspension Controller
}

-- debugging
defaults.dbgMessages = false

return defaults
