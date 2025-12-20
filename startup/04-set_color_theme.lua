-- 04-set_color_theme.lua

local cfg = _G.startupConfig

-- Safety defaults
cfg.applyColorThemeToTerms = cfg.applyColorThemeToTerms ~= false
cfg.applyColorThemeToMonitors = cfg.applyColorThemeToMonitors ~= false
cfg.defaultTheme = cfg.defaultTheme or "default"

-- Attempt to load ThemeManager safely using dofile
local ok, ThemeManager = pcall(dofile, "lib/theme_manager.lua")
if not ok then
    print("Warning: ThemeManager library not found. Skipping theme application.")
    return
end

-- Apply theme to terminal if enabled
if cfg.applyColorThemeToTerms then
    ThemeManager.applyTheme(term.current(), cfg.defaultTheme)
end

-- Apply theme to all monitors if enabled
if cfg.applyColorThemeToMonitors then
    local monitors = peripheral.find("monitor") or {}
    for _, monitor in ipairs(monitors) do
        ThemeManager.applyTheme(monitor, cfg.defaultTheme)
    end
end
