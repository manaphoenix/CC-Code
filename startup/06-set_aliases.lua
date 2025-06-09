-- Check if a shell alias already exists
local function aliasExists(name)
    return shell.aliases()[name] ~= nil
end

-- Recursively find all .lua files in a directory
local function findLuaFiles(dir, found)
    found = found or {}
    for _, item in ipairs(fs.list(dir)) do
        local path = fs.combine(dir, item)
        if fs.isDir(path) then
            findLuaFiles(path, found)
        elseif item:match("%.lua$") then
            table.insert(found, path)
        end
    end
    return found
end

-- Generate a flat alias name from a path like "apps/tools/logger.lua" → "tools.logger"
local function pathToAlias(path)
    local alias = path:gsub("^apps/", "") -- remove "apps/" prefix
    alias = alias:gsub("%.lua$", "")      -- remove ".lua"
    alias = alias:gsub("[/\\]", ".")      -- convert slashes to dots
    return alias
end

-- Create aliases for all discovered Lua files
local appsDir = "apps"
if not fs.exists(appsDir) or not fs.isDir(appsDir) then return end

for _, filepath in ipairs(findLuaFiles(appsDir)) do
    local alias = pathToAlias(filepath)
    if not aliasExists(alias) then
        shell.setAlias(alias, filepath)
    end
end
