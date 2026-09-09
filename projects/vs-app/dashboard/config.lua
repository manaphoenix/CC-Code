--- VS Receiver Configuration Module
--- @class Config
--- @field status_monitor_side string Side where status monitor is located
--- @field tuning_monitor_side string Side where tuning monitor is located
--- @field ender_modem_side string Side where ender modem is located
--- @field modemCode number Channel for ender modem communication
--- @field securityKey string Security key for message verification
--- @field statusTextScale number Text scale for status monitor
--- @field tuningTextScale number Text scale for tuning monitor
--- @field statusOverrides table Color overrides for status monitor
--- @field tuningOverrides table Color overrides for tuning monitor
--- @field statusColors table Color scheme for status display
--- @field tuningColors table Color scheme for tuning display
--- @field lockText string Text displayed when locked
--- @field dbgMessages boolean Enable debug messages
--- @field version string Application version

local Config = {}

--- Default configuration settings
--- @return Config
function Config.getDefault()
    return {
        -- Peripheral Sides
        status_monitor_side = "top",
        tuning_monitor_side = "right",
        ender_modem_side = "back",

        -- Ender Modem Settings
        modemCode = 1337,
        securityKey = "dogs",

        -- Text Scaling (0.5 - 5.0 in 0.5 increments)
        statusTextScale = 1.0,
        tuningTextScale = 2.0,

        -- Color Overrides
        statusOverrides = {
            gray = 0x171717,
        },
        tuningOverrides = {},

        -- Status Monitor Colors
        statusColors = {
            inactive = colors.orange,     -- Inactive gears
            active = colors.lime,         -- Active gears
            fuel = colors.yellow,         -- Fuel indicator
            stress = colors.purple,       -- Stress indicator
            speed = colors.blue,          -- Speed (RPM)
            refillInactive = colors.gray, -- Refill label (inactive)
            refillActive = colors.red,    -- Refill label (active)
            energy = colors.yellow,       -- Energy indicator
        },

        -- Tuning Monitor Colors
        tuningColors = {},

        -- Display Settings
        lockText = "Locked",
        dbgMessages = false,
        version = "2.0.0"
    }
end

--- Validate configuration settings
--- @param config Config Configuration to validate
--- @return boolean isValid Whether configuration is valid
--- @return string? error Error message if invalid
function Config.validate(config)
    -- Validate peripheral sides
    local validSides = { "top", "bottom", "left", "right", "front", "back" }
    for _, side in ipairs({ "status_monitor_side", "tuning_monitor_side", "ender_modem_side" }) do
        if not config[side] then
            return false, side .. " is required"
        end
        local isValid = false
        for _, validSide in ipairs(validSides) do
            if config[side] == validSide then
                isValid = true
                break
            end
        end
        if not isValid then
            return false, side .. " must be one of: " .. table.concat(validSides, ", ")
        end
    end

    -- Validate modem code
    if type(config.modemCode) ~= "number" or config.modemCode < 1 or config.modemCode > 65535 then
        return false, "modemCode must be a number between 1 and 65535"
    end

    -- Validate text scales
    for _, scale in ipairs({ "statusTextScale", "tuningTextScale" }) do
        if type(config[scale]) ~= "number" or config[scale] < 0.5 or config[scale] > 5.0 then
            return false, scale .. " must be a number between 0.5 and 5.0"
        end
    end

    -- Validate security key
    if not config.securityKey or type(config.securityKey) ~= "string" or #config.securityKey == 0 then
        return false, "securityKey must be a non-empty string"
    end

    return true
end

return Config
