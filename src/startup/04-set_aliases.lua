-- 04-set_aliases.lua
-- Registers aliases for runnable system and user apps.
-- User apps win when both define the same command.

local APP_DIRS = {
    "apps/system",
    "apps/user",
}

local SELF_NAME = "launcher.lua"
local SELF_FOLDER = "launcher"

local function aliasExists(name)
    return shell.aliases()[name] ~= nil
end

local function resolve(directory, entry)
    local fullPath = fs.combine(directory, entry)

    if fs.isDir(fullPath) then
        local mainPath = fs.combine(fullPath, "main.lua")
        if fs.exists(mainPath) and not fs.isDir(mainPath) then
            return entry, mainPath
        end
        return nil
    end

    if entry:sub(-4) == ".lua" then
        return entry:sub(1, -5), fullPath
    end

    return nil
end

for _, directory in ipairs(APP_DIRS) do
    for _, entry in ipairs(fs.list(directory)) do
        if entry ~= SELF_NAME and entry ~= SELF_FOLDER then
            local name, path = resolve(directory, entry)

            if name and not aliasExists(name) then
                shell.setAlias(name, path)
            end
        end
    end
end