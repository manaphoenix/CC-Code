-- make a linq library

---@class linqModule
---@operator call(table):linqTable
local module = {}

---@class linqTable
---@operator concat:string
local linq = {}

local function stringMT()
    local result = "{\n"
    for k, v in pairs(self) do
        if type(v) == "table" then
            result = result .. "{\n"
            for sk, sv in pairs(v) do
                result = result .. "\t\t" .. sk .. "=" .. sv .. ",\n"
            end
            result = result .. "},\n"
        else
            result = result .. "\t" ..  k .. " = " .. v .. ",\n"
        end
    end
    -- remove extra comma
    result = result:sub(1, -3)
    return result .. "\n}"
end

local linqmt = {
    __index = linq,
    __tostring = stringMT,
    __concat = function(str, mytable)
        return str .. mytable:toString()
    end,
    __eq = function(str, mytable)
        return str:toString() == mytable:toString()
    end,
}

local functionString = [[
    return function(%s)
        return %s
    end
]]

---returns a function, built using the delegate string.
---@param delegate string @"(params) => predicate"
---@return function
function module.lambda(delegate)
    local params, predicate = delegate:match("%(?(.-)%)? => (.*)")
    predicate = predicate:gsub("return","")
    local func = functionString:format(params, predicate)
    return assert(load(func,"lambda","bt", _ENV))()
end

---combines two tables into one.
---@param other table
---@return linqTable
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

---returns all elements which match the predicate
---@param predicate function
---@return linqTable
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

---returns if the table contains element
---@param value any
---@return boolean
function linq:contains(value)
    for i, v in pairs(self) do
        if v == value then
            return true
        end
    end
    return false
end

---returns all elements which exist in both tables
---@param other table
---@return linqTable
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

---performs an action on each element in the table
---@param action function
function linq:foreach(action)
    for i, v in pairs(self) do
        action(v)
    end
end

---removes all elements that match the predicate
---@param predicate function
---@return linqTable
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

---removes all elements that match the value
---@param value any
---@return linqTable
function linq:remove(value)
    return self:removeAll(function(x) return x == value end)
end

---returns the number of entries in the table
---@return integer
function linq:count()
    local result = 0
    for i, v in pairs(self) do
        result = result + 1
    end
    return result
end

---returns if all elements in the table match the predicate
---@param predicate function
---@return boolean
function linq:all(predicate)
    for i, v in pairs(self) do
        if not predicate(v) then
            return false
        end
    end
    return true
end

---returns if at least one element in the table matches the predicate
---@param predicate function
---@return boolean
function linq:any(predicate)
    for i, v in pairs(self) do
        if predicate(v) then
            return true
        end
    end
    return false
end

---returns all elements that do not exist in the other table
---@param other table
---@return linqTable
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

---returns the first element that matches the predicate
---@param predicate function
---@return any | nil
function linq:first(predicate)
    for i, v in pairs(self) do
        if predicate(v) then
            return v
        end
    end
    return nil
end

---returns the last element in the table that matches the predicate (NOTE: may not be the last element due to the way Lua iterators work)
---@param predicate function
---@return unknown
function linq:last(predicate)
    local result = nil
    for i, v in pairs(self) do
        if predicate(v) then
            result = v
        end
    end
    return result
end

---returns the largest value based on the selector
---@param selector function
---@return any | nil
function linq:max(selector)
    local result = nil
    for i, v in pairs(self) do
        if not result or selector(v) > selector(result) then
            result = v
        end
    end
    return result
end

---returns the mininum value based on the selector
---@param selector function
---@return any | nil
function linq:min(selector)
    local result = nil
    for i, v in pairs(self) do
        if not result or selector(v) < selector(result) then
            result = v
        end
    end
    return result
end

---sorts the table by the selector
---@param selector function
---@return linqTable
function linq:orderBy(selector)
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

linq.thenBy = linq.orderBy

---reverses the entries in the table (Note: only works with standard Lua tables)
---@return linqTable
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

---removes entries 1 through count
---@param count number
function linq:skip(count)
    local result = {}
    setmetatable(result, linqmt)
    for i = 1, count do
        table.remove(self, 1)
    end
end

---makes a table into a linq table
---@param t table
---@return linqTable
function module.from(t)
    return setmetatable(t, { __index = linq })
end

setmetatable(module, {
    __call = function(self, t)
        return setmetatable(t, linqmt)
    end
})

return module
