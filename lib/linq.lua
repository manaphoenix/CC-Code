-- Updated LINQ-style library for Lua with safety, performance, and feature improvements

local module = {}

-- Internal helper for shallow clone
local function clone(t)
    local result = {}
    for i, v in ipairs(t) do
        result[i] = v
    end
    return setmetatable(result, getmetatable(t))
end

-- Improved stringifier with cycle protection
local function toString(value, indent, visited)
    indent = indent or ""
    visited = visited or {}
    if visited[value] then return "<cycle>" end
    visited[value] = true

    if type(value) ~= "table" then return tostring(value) end

    local str = "{\n"
    local nextIndent = indent .. "  "
    for k, v in pairs(value) do
        str = str .. nextIndent .. tostring(k) .. " = " .. toString(v, nextIndent, visited) .. ",\n"
    end
    return str .. indent .. "}"
end

local function stringMT(self)
    return toString(self)
end

local linq = {}
linq.__index = linq

function linq:where(predicate)
    local result = {}
    for _, v in ipairs(self) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return setmetatable(result, getmetatable(self))
end

function linq:select(selector)
    local result = {}
    for i, v in ipairs(self) do
        result[i] = selector(v)
    end
    return setmetatable(result, getmetatable(self))
end

function linq:any(predicate)
    for _, v in ipairs(self) do
        if predicate(v) then
            return true
        end
    end
    return false
end

function linq:all(predicate)
    for _, v in ipairs(self) do
        if not predicate(v) then
            return false
        end
    end
    return true
end

function linq:contains(value)
    for _, v in ipairs(self) do
        if v == value then
            return true
        end
    end
    return false
end

function linq:first(predicate)
    if not predicate then
        return self[1]
    end
    for _, v in ipairs(self) do
        if predicate(v) then
            return v
        end
    end
    return nil
end

function linq:last(predicate)
    for i = #self, 1, -1 do
        local v = self[i]
        if not predicate or predicate(v) then
            return v
        end
    end
    return nil
end

function linq:count(predicate)
    local count = 0
    for _, v in ipairs(self) do
        if not predicate or predicate(v) then
            count = count + 1
        end
    end
    return count
end

function linq:sum(selector)
    selector = selector or function(x) return x end
    local sum = 0
    for _, v in ipairs(self) do
        sum = sum + selector(v)
    end
    return sum
end

function linq:average(selector)
    selector = selector or function(x) return x end
    local sum, count = 0, 0
    for _, v in ipairs(self) do
        sum = sum + selector(v)
        count = count + 1
    end
    return count > 0 and (sum / count) or 0
end

function linq:max(selector)
    selector = selector or function(x) return x end
    local max = nil
    for _, v in ipairs(self) do
        local val = selector(v)
        if not max or val > max then
            max = val
        end
    end
    return max
end

function linq:min(selector)
    selector = selector or function(x) return x end
    local min = nil
    for _, v in ipairs(self) do
        local val = selector(v)
        if not min or val < min then
            min = val
        end
    end
    return min
end

function linq:distinct()
    local seen, result = {}, {}
    for _, v in ipairs(self) do
        if not seen[v] then
            seen[v] = true
            table.insert(result, v)
        end
    end
    return setmetatable(result, getmetatable(self))
end

function linq:skip(count)
    local result = {}
    for i = count + 1, #self do
        result[#result + 1] = self[i]
    end
    return setmetatable(result, getmetatable(self))
end

function linq:take(count)
    local result = {}
    for i = 1, math.min(count, #self) do
        result[#result + 1] = self[i]
    end
    return setmetatable(result, getmetatable(self))
end

function linq:reverse()
    local result = {}
    for i = #self, 1, -1 do
        table.insert(result, self[i])
    end
    return setmetatable(result, getmetatable(self))
end

function linq:orderBy(selector)
    local result = clone(self)
    table.sort(result, function(a, b)
        return selector(a) < selector(b)
    end)
    return setmetatable(result, getmetatable(self))
end

function linq:intersect(other)
    local otherLinq = module(other)
    local result = {}
    for _, v in ipairs(self) do
        if otherLinq:contains(v) then
            table.insert(result, v)
        end
    end
    return setmetatable(result, getmetatable(self))
end

function linq:except(other)
    local otherLinq = module(other)
    local result = {}
    for _, v in ipairs(self) do
        if not otherLinq:contains(v) then
            table.insert(result, v)
        end
    end
    return setmetatable(result, getmetatable(self))
end

function linq:flatMap(selector)
    local result = {}
    for _, item in ipairs(self) do
        for _, v in ipairs(selector(item)) do
            table.insert(result, v)
        end
    end
    return setmetatable(result, getmetatable(self))
end

function linq:zip(other, combiner)
    local result = {}
    local len = math.min(#self, #other)
    for i = 1, len do
        result[i] = combiner(self[i], other[i])
    end
    return setmetatable(result, getmetatable(self))
end

function linq:forEach(action)
    for _, v in ipairs(self) do
        action(v)
    end
end

linq.each = linq.forEach

-- Lambda support for x => x*2 style
function module.lambda(delegate)
    local params, body = delegate:match("%(?([%w_, ]+)%s*%)?%s*=>%s*(.+)")
    if not params or not body then
        error("Invalid lambda syntax: " .. tostring(delegate))
    end
    local fn, err = load("return function(" .. params .. ") return " .. body .. " end")
    if not fn then error("Lambda error: " .. err) end
    return fn()
end

function module.from(t)
    return setmetatable(t, linq)
end

setmetatable(module, {
    __call = function(_, t)
        return module.from(t)
    end
})

linq.__tostring = stringMT

return module
