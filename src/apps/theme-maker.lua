-- theme_maker.lua
-- Theme creator/editor with overwrite support

---@type table<string, boolean>
local REQUIRED_COLORS = {
    white = true,
    orange = true,
    magenta = true,
    lightBlue = true,
    yellow = true,
    lime = true,
    pink = true,
    gray = true,
    lightGray = true,
    cyan = true,
    purple = true,
    blue = true,
    brown = true,
    green = true,
    red = true,
    black = true,
}

local cancelled = false

local PREVIEW_X = 40
local PREVIEW_Y = 2
local PREVIEW_W = 10
local PREVIEW_H = 5

---@type table<number, number>
local originalPalette = {}

-- =========================
-- Helpers
-- =========================

local function parseHex(input)
    input = input:gsub("#", "")
    if input:sub(1, 2):lower() == "0x" then
        input = input:sub(3)
    end

    local n = tonumber(input, 16)
    return n or 0x000000
end

local function prompt(text)
    term.write(text)
    return read()
end

local function loadTheme(path)
    local fn = loadfile(path)
    if not fn then return nil end

    local ok, result = pcall(fn)
    if not ok then return nil end

    return result
end

local function drawPreview(color)
    -- save palette once per run (lazy init)
    if next(originalPalette) == nil then
        for i = 0, 15 do
            local r, g, b = term.getPaletteColor(2 ^ i)
            originalPalette[i] = { r, g, b }
        end
    end

    -- temporarily override a safe color (we use "gray" slot visually)
    term.setPaletteColor(colors.gray, color)

    for y = 0, PREVIEW_H - 1 do
        term.setCursorPos(PREVIEW_X, PREVIEW_Y + y)
        term.setBackgroundColor(colors.gray)
        term.write(string.rep(" ", PREVIEW_W))
    end

    term.setBackgroundColor(colors.black)
end

local function restorePalette()
    for i = 0, 15 do
        local c = originalPalette[i]
        term.setPaletteColor(2 ^ i, c[1], c[2], c[3])
    end
end

-- =========================
-- Input metadata
-- =========================

print("=== Theme Maker (Create / Edit) ===\n")

local name = prompt("Theme name: ")

if name == "" then
    error("Theme name cannot be empty")
end

local fileName = name:lower():gsub("%s+", "_")
local path = "themes/" .. fileName .. ".lua"

-- Load existing theme if present
local existing = nil
if fs.exists(path) then
    existing = loadTheme(path)
end

local author
local description

if existing then
    print("\nEditing existing theme: " .. name)

    -- reuse existing values (no prompts)
    author = existing.meta and existing.meta.author or "Unknown"
    description = existing.meta and existing.meta.description or ""
else
    print("\nCreating new theme: " .. name)

    -- only ask when creating
    author = prompt("Author: ")
    description = prompt("Description: ")
end

-- =========================
-- Colors
-- =========================

---@type table<string, number>
local themeColors = {}

print("\nEnter colors (leave blank to keep existing or default)\n")

local colorOrder = {
    "white", "orange", "magenta", "lightBlue",
    "yellow", "lime", "pink", "gray",
    "lightGray", "cyan", "purple", "blue",
    "brown", "green", "red", "black"
}

for _, colorName in ipairs(colorOrder) do
    local old = existing and existing.colors and existing.colors[colorName]
    local current = old or 0x000000
    local input = ""

    while true do
        -- redraw screen
        term.clear()
        term.setCursorPos(1, 1)

        print("Editing color: " .. colorName)
        print("Type hex value. Press Enter to confirm.")
        print("Preview updates while typing.\n")

        drawPreview(current)

        term.setCursorPos(1, 10)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)

        if old then
            term.write(colorName .. " (#" .. string.format("%06x", old) .. "): " .. input)
        else
            term.write(colorName .. ": " .. input)
        end

        local event, key = os.pullEvent()

        if event == "char" then
            input = input .. key
            current = parseHex(input)
        elseif event == "key" then
            if key == keys.backspace then
                input = input:sub(1, -2)

                if input == "" then
                    current = old or 0x000000
                else
                    current = parseHex(input)
                end
            elseif key == keys.enter then
                themeColors[colorName] = current
                break
            end
        end
    end
end

-- =========================
-- Build output
-- =========================

local function serialize(tbl, indent)
    indent = indent or 1
    local pad = string.rep("    ", indent)
    local out = { "{" }

    for k, v in pairs(tbl) do
        if type(v) == "table" then
            table.insert(out, pad .. k .. " = " .. serialize(v, indent + 1) .. ",")
        elseif type(v) == "number" then
            table.insert(out, pad .. k .. " = 0x" .. string.format("%06x", v) .. ",")
        else
            table.insert(out, pad .. k .. " = " .. string.format("%q", v) .. ",")
        end
    end

    table.insert(out, string.rep("    ", indent - 1) .. "}")
    return table.concat(out, "\n")
end

local themeData = {
    meta = {
        name = existing and existing.meta and existing.meta.name or name,
        author = author ~= "" and author or (existing and existing.meta and existing.meta.author) or "Unknown",
        description = description ~= "" and description or (existing and existing.meta and existing.meta.description) or
            "",
    },
    colors = themeColors
}

local output = "return " .. serialize(themeData)

-- =========================
-- Save / Cancel choice
-- =========================

restorePalette()

print("\nSave theme? (y = save, n = cancel)")

local choice = read()

if choice:lower() ~= "y" then
    print("Cancelled. No changes were saved.")
    cancelled = true
end

if not cancelled then
    if not fs.exists("themes") then
        fs.makeDir("themes")
    end

    local file = fs.open(path, "w")
    file.write(output)
    file.close()

    print("\nSaved theme to: " .. path)

    if existing then
        print("Theme updated successfully.")
    else
        print("Theme created successfully.")
    end
else
    print("\nExited without saving.")
end
