-- 04-set_aliases.lua
-- Registers shell aliases for installed apps (self-contained, no Resolver lib)

local APP_DIR = "apps"
local SELF_NAME = "launcher.lua"
local SELF_FOLDER = "launcher"

local function aliasExists(name)
    return shell.aliases()[name] ~= nil
end

-- Resolve an apps/ entry to a runnable path
-- Folder app  -> apps/<name>/main.lua
-- Flat script -> apps/<name>.lua
local function resolve(entry)
    local fullPath = fs.combine(APP_DIR, entry)

    if fs.isDir(fullPath) then
        local mainPath = fs.combine(fullPath, "main.lua")
        if fs.exists(mainPath) then
            return entry, mainPath
        end
    else
        return entry:gsub("%.lua$", ""), fullPath
    end
end

for _, entry in ipairs(fs.list(APP_DIR)) do
    if entry ~= SELF_NAME and entry ~= SELF_FOLDER then
        local name, path = resolve(entry)
        if name and path and not aliasExists(name) then
            shell.setAlias(name, path)
        end
    end
end