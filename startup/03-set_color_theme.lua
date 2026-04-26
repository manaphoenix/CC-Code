-- 03-set_color_theme.lua

-- Load config directly (no globals)
local cfgPath = "config/startup.cfg"
local cfg = {}

if fs.exists(cfgPath) then
    local file = fs.open(cfgPath, "r")
    cfg = textutils.unserialize(file.readAll()) or {}
    file.close()
end

-- Defaults (pure local interpretation)
local applyTerms = cfg.applyColorThemeToTerms ~= false
local applyMonitors = cfg.applyColorThemeToMonitors ~= false
local themeName = cfg.defaultTheme or "default"

-- Load ThemeManager
local ok, ThemeManager = pcall(dofile, "lib/theme_manager.lua")
if not ok then
    print("Warning: ThemeManager missing, skipping theme setup")
    return
end

-- Apply to terminal
if applyTerms then
    ThemeManager.applyTheme(term.current(), themeName)
end

-- Apply to monitors
if applyMonitors then
    for _, monitor in ipairs({ peripheral.find("monitor") }) do
        ThemeManager.applyTheme(monitor, themeName)
    end
end
