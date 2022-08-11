-- make a linq library

local module = {}

local linq = {}

function linq:toString()
    local result = "{"
    for k, v in pairs(self) do
        if type(v) == "table" then
            result = result .. "{"
            for sk, sv in pairs(v) do
                result = result .. sk .. "=" .. sv .. ","
            end
            result = result .. "},"
        else
            result = result .. k .. " = " .. v .. ","
        end
    end
    -- remove extra comma
    result = result:sub(1, -2)
    return result .. "}"
end

function linq:concat(other)
    local result = {}
    setmetatable(result, { __index = self })
    for i, v in pairs(self) do
        table.insert(result, v)
    end
    for i, v in pairs(other) do
        table.insert(result, v)
    end
    return result
end

local linqmt = {
    __index = linq,
    __tostring = linq.toString,
    __concat = function(str, mytable)
        return str .. mytable:toString()
    end,
    __eq = function(str, mytable)
        return str:toString() == mytable:toString()
    end,
}

---@param delegate string @"(params) => predicate"
---@return function
function module.l(delegate)
    local params, predicate = delegate:gmatch("%(?(.-)%)? => (.*)")()
    local func = "return function(" .. params .. ") " ..
        (predicate:match("return") and predicate .. " end" or
            "return " .. predicate .. " end")
    return assert(load(func))()
end

function linq:where(predicate)
    local result = {}
    setmetatable(result, linqmt)
    for i, v in pairs(self) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

function linq:push(value)
    table.insert(self, value)
end

function linq:to_table()
    local result = {}
    setmetatable(result, linqmt)
    for i, v in pairs(self) do
        table.insert(result, v)
    end
    return result
end

function linq:contains(value)
    for i, v in pairs(self) do
        if v == value then
            return true
        end
    end
    return false
end

function linq:intersect(other)
    local result = {}
    setmetatable(result, linqmt)
    for i, v in pairs(self) do
        if other:contains(v) then
            table.insert(result, v)
        end
    end
    return result
end

function linq:select(selector)
    local result = {}
    setmetatable(result, linqmt)
    for i, v in pairs(self) do
        table.insert(result, selector(v))
    end
    return result
end

function linq:foreach(action)
    for i, v in pairs(self) do
        action(v)
    end
end

function linq:removeAll(predicate)
    local result = {}
    setmetatable(result, linqmt)
    for i, v in pairs(self) do
        if not predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

function linq:remove(value)
    return self:removeAll(function(x) return x == value end)
end

function linq:count()
    local result = 0
    for i, v in pairs(self) do
        result = result + 1
    end
    return result
end

function linq:all(predicate)
    for i, v in pairs(self) do
        if not predicate(v) then
            return false
        end
    end
    return true
end

function linq:any(predicate)
    for i, v in pairs(self) do
        if predicate(v) then
            return true
        end
    end
    return false
end

function linq:except(other)
    local result = {}
    setmetatable(result, linqmt)
    for i, v in pairs(self) do
        local found = false
        for i2, v2 in pairs(other) do
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
    for i, v in pairs(self) do
        if predicate(v) then
            return v
        end
    end
    return nil
end

function linq:last(predicate)
    local result = nil
    for i, v in pairs(self) do
        if predicate(v) then
            result = v
        end
    end
    return result
end

function linq:max(selector)
    local result = nil
    for i, v in pairs(self) do
        if not result or selector(v) > selector(result) then
            result = v
        end
    end
    return result
end

function linq:min(selector)
    local result = nil
    for i, v in pairs(self) do
        if not result or selector(v) < selector(result) then
            result = v
        end
    end
    return result
end

function linq:orderby(selector)
    local result = {}
    setmetatable(result, linqmt)
    for i, v in pairs(self) do
        table.insert(result, v)
    end
    table.sort(result, function(a, b)
        return selector(a, b)
    end)
    return result
end

linq.orderBy = linq.orderby

function linq:thenby(selector)
    local result = {}
    setmetatable(result, linqmt)
    for i, v in pairs(self) do
        table.insert(result, v)
    end
    table.sort(result, function(a, b)
        return selector(a, b)
    end)
    return result
end

-- reverse does not work with tables
function linq:reverse()
    local result = {}
    setmetatable(result, linqmt)
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
    setmetatable(result, linqmt)
    for i = 1, count do
        table.remove(self, 1)
    end
    for i, v in pairs(self) do
        table.insert(result, v)
    end
    return result
end

function linq:add(value)
    table.insert(self, value)
end

function linq:iter()
    return pairs(self)
end

function linq:sort(selector)
    local result = {}
    setmetatable(result, linqmt)
    for i, v in pairs(self) do
        table.insert(result, v)
    end
    table.sort(result, function(a, b)
        return selector(a, b)
    end)
    return result
end

function linq:toList()
    return self
end

linq.tolist = linq.toList

function linq:pairs()
    return pairs(self)
end

function linq:print()
    for i, v in pairs(self) do
        -- if elements are tables, print them with nice formatting
        if type(v) == "table" then
            print("{")
            for k, v in pairs(v) do
                print("", k, v)
            end
            print("}")
        else
            print(v)
        end
    end
end

function module.from(t)
    return setmetatable(t, { __index = linq })
end

function module.range(start, stop, step)
    local result = {}
    setmetatable(result, linqmt)
    for i = start, stop, step do
        table.insert(result, i)
    end
    return result
end

function module.empty()
    local result = {}
    setmetatable(result, linqmt)
    return result
end

function module.sort(t, func)
    func = func or function(a, b)
        return a < b
    end
    table.sort(t, func)
end

setmetatable(linq, {
    __call = function(self, t)
        return setmetatable(t, linqmt)
    end
})

setmetatable(module, {
    __call = function(self, t)
        return setmetatable(t, linqmt)
    end
})

return module
