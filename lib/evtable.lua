---@class OnChangeTable
local OnChangeTable = {}

---@alias OnChangeCallback fun(tbl: table, key: any, oldValue: any, newValue: any)

--- Creates a table that calls a callback when a key is changed, does not support nested tables
---@param onchange OnChangeCallback The callback to be called when a key is changed
---@param initialTable? table The initial table, defaults to an empty table
---@param readOnly? boolean Whether the table is read-only, defaults to false
---@return table eventTable The table with the event attached, don't use the original
function OnChangeTable.new(onchange, initialTable, readOnly)
    for _, v in pairs(initialTable or {}) do
        if type(v) == "table" then
            error("nested tables are not supported", 2)
        end
    end

    local proxy = {}
    local original = initialTable or {}
    readOnly = readOnly or false

    local mt = {
        __index = function(_, key)
            return original[key]
        end,
        __newindex = function(t, key, value)
            if original[key] ~= nil then
                if value == nil and readOnly then
                    -- do nothing, table is read-only
                    return
                end
                if value ~= original[key] then
                    onchange(t, key, original[key], value)
                    original[key] = value
                else
                    -- do nothing, value is the same
                end
            else
                if readOnly then
                    -- do nothing, table is read-only
                    return
                else
                    original[key] = value
                end
            end
        end,
        __pairs = function(_)
            return pairs(original)
        end,
        __len = function(_)
            local count = 0
            for _ in pairs(original) do
                count = count + 1
            end
            return count
        end,
        __tostring = function(_)
            local parts = {}
            for k, v in pairs(original) do
                if type(v) == "function" then
                    -- do nothing, functions are not serializable
                else
                    table.insert(parts, tostring(k) .. "=" .. tostring(v))
                end
            end
            return "{" .. table.concat(parts, ", ") .. "}"
        end,
        __call = function(_, key)
            return textutils.serialise(original)
        end
    }

    setmetatable(proxy, mt)
    return proxy
end

return OnChangeTable
