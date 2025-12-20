-- apps/tools/theme_picker.lua

-- Load ThemeManager safely
local ok, ThemeManager = pcall(dofile, "lib/theme_manager.lua")
if not ok then
    print("Error: ThemeManager library not found.")
    return
end

-- Clear terminal and reset cursor
term.clear()
term.setCursorPos(1, 1)

-- Load current startup config
local cfgPath = "config/startup.cfg"
local cfg = _G.startupConfig or { defaultTheme = "default" }

-- Load or create config file if missing
if not fs.exists(cfgPath) then
    if not fs.exists("config") then fs.makeDir("config") end
    local file = fs.open(cfgPath, "w")
    file.write(textutils.serialize(cfg))
    file.close()
end

-- List all installed themes with metadata
local themes = ThemeManager.listThemes()
if #themes == 0 then
    print("No themes installed in 'themes/' folder.")
    return
end

print("Installed themes:")
for i, theme in ipairs(themes) do
    local meta = theme.meta or {}
    print(string.format("%d) %s (v%s) by %s",
        i,
        meta.name or theme.filename or "Unnamed",
        meta.version or "?",
        meta.author or "Unknown"
    ))
    print("   " .. (meta.description or "No description"))
end

-- Prompt user to select
print("\nEnter the number of the theme to apply (or 0 to cancel, current: " .. cfg.defaultTheme .. "):")
local input = read()
local choice = tonumber(input)

if not choice or choice < 0 or choice > #themes then
    print("Invalid selection, aborting.")
    return
elseif choice == 0 then
    print("No changes made, exiting.")
    return
end

local selected = themes[choice]
local selectedName = selected.filename

-- Update config
cfg.defaultTheme = selectedName
local file = fs.open(cfgPath, "w")
file.write(textutils.serialize(cfg))
file.close()

print("Theme '" .. (selected.meta.name or selectedName) .. "' applied and saved to startup.cfg!")

-- Apply live
ThemeManager.applyTheme(term.current(), selectedName)
local monitors = peripheral.find("monitor", true) or {}
for _, mon in ipairs(monitors) do
    ThemeManager.applyTheme(mon, selectedName)
end
print("Theme applied to terminal and monitors.")
