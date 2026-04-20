-- newapp.lua
-- App generator for CC-Code system

local args = { ... }

local name = args[1]
local type = args[2] or "script"

local base = fs.combine("apps", name or "")

local valid = {
    script = true,
    cli = true,
    loop = true,
    ui = true
}

local function getTemplates()
    local list = {}

    if fs.exists("templates") then
        for _, file in ipairs(fs.list("templates")) do
            if file:sub(-4) == ".lua" then
                list[#list + 1] = file:gsub("%.lua$", "")
            end
        end
    end

    table.sort(list)
    return list
end

local function usage()
    print("Usage: newapp <name> <type>")
    print("")
    print("Available types:")

    for _, t in ipairs(getTemplates()) do
        print("  - " .. t)
    end
end

if not name then
    return usage()
end

if not valid[type] then
    return usage()
end

if fs.exists(base) then
    return usage()
end

-- load template
local templatePath = fs.combine("templates", type .. ".lua")

if not fs.exists(templatePath) then
    return usage()
end

local template = dofile(templatePath)

fs.makeDir(base)

-- create main.lua 
local mainFile = fs.open(fs.combine(base, "main.lua"), "w")
mainFile.write(template(name))
mainFile.close()

-- create metadata
local meta = fs.open(fs.combine(base, "app.lua"), "w")
meta.write([[return {
    name = "]] .. name .. [[",
    type = "]] .. type .. [[",
    version = "1.0.0"
}]])
meta.close()

print("Created app: " .. name .. " (" .. type .. ")")