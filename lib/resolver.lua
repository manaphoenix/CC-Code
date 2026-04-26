-- 04-resolver.lua

local Resolver = {}

-- Default resolution rules (ordered fallback chain)
local function defaultStrategy(name)
    return {
        string.format("apps/%s/main.lua", name), -- Kiln-style
        string.format("apps/%s.lua", name)       -- flat file fallback
    }
end

local strategy = defaultStrategy

--- Set custom resolution strategy (Kiln hook)
---@param fn fun(name: string): string[]
function Resolver.setStrategy(fn)
    strategy = fn or defaultStrategy
end

--- Resolve to first existing executable path
---@param name string
---@return string|nil
function Resolver.resolve(name)
    local candidates = strategy(name)

    for _, path in ipairs(candidates) do
        if fs.exists(path) then
            return path
        end
    end

    return nil
end

--- Check if any valid entry exists
---@param name string
---@return boolean
function Resolver.exists(name)
    return Resolver.resolve(name) ~= nil
end

--- List structured apps (Kiln-style only, intentional separation)
---@return string[]
function Resolver.list()
    local apps = {}

    if not fs.exists("apps") then
        return apps
    end

    for _, dir in ipairs(fs.list("apps")) do
        if fs.exists(fs.combine("apps", dir, "main.lua")) then
            table.insert(apps, dir)
        end
    end

    return apps
end

return Resolver
