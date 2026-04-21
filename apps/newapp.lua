-- newapp.lua
-- App generator for CC-Code system

local args = { ... }

local name = args[1]
local type = args[2]

-- =========================
-- Template discovery
-- =========================

local function getTemplates()
    local list = {}

    if fs.exists("templates") then
        for _, file in ipairs(fs.list("templates")) do
            if file:match("%.lua$") then
                list[#list + 1] = file:gsub("%.lua$", "")
            end
        end
    end

    table.sort(list)
    return list
end

local function templateExists(t)
    for _, v in ipairs(getTemplates()) do
        if v == t then return true end
    end
    return false
end

-- =========================
-- Help
-- =========================

shell.setCompletionFunction("apps/newapp.lua", function(_, index, argument, previous)
    local templates = getTemplates()

    -- Completing <type> (newapp <name> <type>)
    if index == 2 then
        local out = {}

        for _, t in ipairs(templates) do
            if argument == "" or t:sub(1, #argument) == argument then
                out[#out + 1] = t
            end
        end

        return out
    end

    return {}
end)

local function usage()
    print("Usage: newapp <name> <type>")
    print("")
    print("Available types:")

    for _, t in ipairs(getTemplates()) do
        print("  - " .. t)
    end
end

-- =========================
-- Validation
-- =========================

if not name or not type then
    return usage()
end

if not templateExists(type) then
    return usage()
end

local base = fs.combine("apps", name)

if fs.exists(base) then
    print("App already exists: " .. name)
    return
end

-- =========================
-- Load template
-- =========================

local templatePath = fs.combine("templates", type .. ".lua")

local templateFn = dofile(templatePath)

-- =========================
-- Create app folder
-- =========================

fs.makeDir(base)

-- main entry
local mainFile = fs.open(fs.combine(base, "main.lua"), "w")
mainFile.write(templateFn(name))
mainFile.close()

-- metadata (clean standard)
local metaTable = {
    name = name,
    displayName = name,
    type = type,
    version = "1.0.0",
    description = ""
}

local meta = fs.open(fs.combine(base, "manifest.lua"), "w")
meta.write("return " .. textutils.serialize(metaTable))
meta.close()

print("Created app: " .. name .. " (" .. type .. ")")
