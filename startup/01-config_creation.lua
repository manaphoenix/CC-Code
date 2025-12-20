-- 01-config_creation

-- Unique global to avoid CC:Tweaked conflicts
_G.startupConfig = _G.startupConfig or {}
local cfg = _G.startupConfig

-- Ensure the config folder exists
if not fs.exists("config") then fs.makeDir("config") end

local path = "config/startup.cfg"

-- Load existing config if present
if fs.exists(path) then
    local file = fs.open(path, "r")
    local data = textutils.unserialize(file.readAll()) or {}
    file.close()
    -- Merge loaded values into the global config
    for k, v in pairs(data) do
        cfg[k] = v
    end
end

-- Apply defaults for missing keys
cfg.clearTmp = cfg.clearTmp ~= false
cfg.applyColorThemeToTerms = cfg.applyColorThemeToTerms ~= false
cfg.applyColorThemeToMonitors = cfg.applyColorThemeToMonitors ~= false
cfg.defaultTheme = cfg.defaultTheme or "default"

-- Write config file if it didn’t exist
if not fs.exists(path) then
    local file = fs.open(path, "w")
    file.write(textutils.serialize(cfg))
    file.close()
end
