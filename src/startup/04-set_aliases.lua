-- 04-set_aliases.lua
-- Thin UX layer over Resolver (no discovery, no filesystem logic)

local Resolver = dofile("lib/resolver.lua")

local function aliasExists(name)
    return shell.aliases()[name] ~= nil
end

local function toAlias(name)
    return name
end

local function register(name)
    local path = Resolver.resolve(name)

    -- Trust Resolver as source of truth (no fs.exists check here)
    if not aliasExists(name) then
        shell.setAlias(toAlias(name), path)
    end
end

for _, name in ipairs(Resolver.list()) do
    register(name)
end
