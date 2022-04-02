-- make a linq library

local module = {}

local linq = {}

---@param delegate string @"(params) => predicate"
---@return function
function module.lambda(delegate)
    local params, predicate = delegate:gmatch("%(?(.-)%)? => (.*)")()
    local func = "return function(" .. params .. ") " ..
                     (predicate:match("return") and predicate .. " end" or
                         "return " .. predicate .. " end")
    return assert(load(func))()
end

function linq:where(predicate)
    local result = {}
    setmetatable(result, {__index = linq})
    for i, v in ipairs(self) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

function linq:to_table()
    local result = {}
    setmetatable(result, {__index = linq})
    for i, v in ipairs(self) do
        table.insert(result, v)
    end
    return result
end

function linq:select(selector)
    local result = {}
    setmetatable(result, {__index = linq})
    for i, v in ipairs(self) do
        table.insert(result, selector(v))
    end
    return result
end

function linq:foreach(action)
    for i, v in ipairs(self) do
        action(v)
    end
end

function linq:removeAll(predicate)
    local result = {}
    setmetatable(result, {__index = linq})
    for i, v in ipairs(self) do
        if not predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

function linq:count()
    local result = 0
    for i, v in ipairs(self) do
        result = result + 1
    end
    return result
end

function linq:all(predicate)
    for i, v in ipairs(self) do
        if not predicate(v) then
            return false
        end
    end
    return true
end

function linq:any(predicate)
    for i, v in ipairs(self) do
        if predicate(v) then
            return true
        end
    end
    return false
end

function linq:except(other)
    local result = {}
    setmetatable(result, {__index = linq})
    for i, v in ipairs(self) do
        local found = false
        for i2, v2 in ipairs(other) do
            if v == v2 then
                found = true
                break
            end
        end
        if not found then
            table.insert(result, v)
        end
    end
    return result
end

function linq:first(predicate)
    for i, v in ipairs(self) do
        if predicate(v) then
            return v
        end
    end
    return nil
end

function linq:last(predicate)
    local result = nil
    for i, v in ipairs(self) do
        if predicate(v) then
            result = v
        end
    end
    return result
end

function linq:max(selector)
    local result = nil
    for i, v in ipairs(self) do
        if not result or selector(v) > selector(result) then
            result = v
        end
    end
    return result
end

function linq:min(selector)
    local result = nil
    for i, v in ipairs(self) do
        if not result or selector(v) < selector(result) then
            result = v
        end
    end
    return result
end

function linq:orderby(selector)
    local result = {}
    setmetatable(result, {__index = linq})
    for i, v in ipairs(self) do
        table.insert(result, v)
    end
    table.sort(result, function(a, b)
        return selector(a) < selector(b)
    end)
    return result
end

function linq:thenby(selector)
    local result = {}
    setmetatable(result, {__index = linq})
    for i, v in ipairs(self) do
        table.insert(result, v)
    end
    table.sort(result, function(a, b)
        return selector(a) < selector(b)
    end)
    return result
end

function linq:reverse()
    local result = {}
    setmetatable(result, {__index = linq})
    for i, v in ipairs(self) do
        table.insert(result, v)
    end
    table.sort(result, function(a, b)
        return a > b
    end)
    return result
end

function linq:skip(count)
    local result = {}
    setmetatable(result, {__index = linq})
    for i = 1, count do
        table.remove(self, 1)
    end
    for i, v in ipairs(self) do
        table.insert(result, v)
    end
    return result
end

function linq:add(value)
    table.insert(self, value)
end

function linq:iter()
    return ipairs(self)
end

function module.from(t)
    return setmetatable(t, {__index = linq})
end

function module.range(start, stop, step)
    local result = {}
    setmetatable(result, {__index = linq})
    for i = start, stop, step do
        table.insert(result, i)
    end
    return result
end

function module.empty()
    local result = {}
    setmetatable(result, {__index = linq})
    return result
end

return module