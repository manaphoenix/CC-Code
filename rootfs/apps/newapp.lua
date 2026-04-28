-- newapp.lua
-- App generator for CC-Code system (runtime-based)

local args = { ... }

local name = args[1]
local templateName = args[2]

-- =========================
-- Template discovery
-- =========================

local function getTemplates()
    local list = {}

    if fs.exists("templates") then
        for _, file in ipairs(fs.list("templates")) do
            if file:match("%.lua$") then
                local id = file:gsub("%.lua$", "")
                list[#list + 1] = id
            end
        end
    end

    table.sort(list)
    return list
end

local function loadTemplate(name)
    local path = fs.combine("templates", name .. ".lua")

    if not fs.exists(path) then
        return nil
    end

    local ok, tpl = pcall(dofile, path)
    if not ok then
        return nil
    end

    return tpl
end

-- =========================
-- Completion
-- =========================

shell.setCompletionFunction("apps/newapp.lua", function(_, index, argument)
    if index == 2 then
        local out = {}
        for _, t in ipairs(getTemplates()) do
            if argument == "" or t:sub(1, #argument) == argument then
                out[#out + 1] = t
            end
        end
        return out
    end

    return {}
end)

-- =========================
-- Help
-- =========================

local function usage()
    print("Usage: newapp <name> <template>")
    print("")
    print("Available templates:")

    for _, t in ipairs(getTemplates()) do
        print("  - " .. t)
    end
end

-- =========================
-- Validation
-- =========================

if not name or not templateName then
    return usage()
end

local template = loadTemplate(templateName)

if not template or not template.runtime or not template.generator then
    print("Invalid template: " .. tostring(templateName))
    return usage()
end

local base = fs.combine("apps", name)

if fs.exists(base) then
    print("App already exists: " .. name)
    return
end

-- =========================
-- Create app folder
-- =========================

fs.makeDir(base)

-- main entry
local mainFile = fs.open(fs.combine(base, "main.lua"), "w")
mainFile.write(template.generator(name))
mainFile.close()

-- =========================
-- Manifest (runtime-driven)
-- =========================

local metaTable = {
    name = name,
    displayName = name,
    runtime = template.runtime, -- 🔥 THIS is the key change
    version = "1.0.0",
    description = "",
    trusted = true
}

local meta = fs.open(fs.combine(base, "manifest.lua"), "w")
meta.write("return " .. textutils.serialize(metaTable))
meta.close()

print("Created app: " .. name .. " (" .. template.runtime .. ")")
