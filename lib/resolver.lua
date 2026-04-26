-- 04-resolver.lua
-- Canonical command entrypoint resolver (startup layer)

local Resolver = {}

-- Current resolution strategy
-- This is the ONLY assumption baked in:
-- apps/<name>/main.lua
local function defaultStrategy(name)
    return string.format("apps/%s/main.lua", name)
end

-- Internal strategy pointer (swappable later for Kiln)
local strategy = defaultStrategy

--- Set a new resolution strategy (future Kiln hook)
---@param fn fun(name: string): string
function Resolver.setStrategy(fn)
    strategy = fn or defaultStrategy
end

--- Resolve a command name to an executable path
---@param name string
---@return string
function Resolver.resolve(name)
    return strategy(name)
end

--- Optional helper: check if resolved file exists
---@param name string
---@return boolean
function Resolver.exists(name)
    local path = strategy(name)
    return fs.exists(path)
end

--- Optional helper: list all resolvable apps (convention-based)
---@return string[]
function Resolver.list()
    local apps = {}

    if not fs.exists("apps") then
        return apps
    end

    for _, dir in ipairs(fs.list("apps")) do
        local path = fs.combine("apps", dir, "main.lua")
        if fs.exists(path) then
            table.insert(apps, dir)
        end
    end

    return apps
end

-- Optional global exposure (ONLY for dev convenience)
-- You can remove this later if you want strict locality
_G.Resolver = Resolver

return Resolver
