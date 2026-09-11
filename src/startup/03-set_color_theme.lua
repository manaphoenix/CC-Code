-- 03-set_color_theme.lua

local cfgPath = "config/startup.cfg"
local cfg = {}

local file = fs.open(cfgPath, "r")
if file then
    local parsed = textutils.unserialize(file.readAll())
    file.close()

    if type(parsed) == "table" then
        cfg = parsed
    end
end

local applyTerms = cfg.applyColorThemeToTerms ~= false
local applyMonitors = cfg.applyColorThemeToMonitors ~= false
local themeName = cfg.defaultTheme or "default"

local ok, ThemeManager = pcall(dofile, "lib/core/theme-manager.lua")
if not ok or type(ThemeManager) ~= "table" then
    print("Warning: ThemeManager missing or invalid; skipping theme setup.")
    return
end

local function apply(target)
    local success, err = pcall(ThemeManager.applyTheme, target, themeName)
    if not success then
        print(("Warning: could not apply theme '%s': %s"):format(themeName, err))
    end
end

if applyTerms then
    apply(term.current())
end

if applyMonitors then
    for _, monitor in ipairs({ peripheral.find("monitor") }) do
        apply(monitor)
    end
end