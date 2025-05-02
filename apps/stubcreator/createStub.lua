-- variable creation
local actions = require("lib.parallelAction")
local stub = {}
local optionals = {}
local knownSubTypes = {}
local config = require("config.stubConfig") -- Load the config from the external file

-- write functions
local function writeJsonTypeStub(data, path)
    local file = fs.open(path .. ".json", "w")
    file.write(textutils.serialiseJSON(data, true))
    file.close()
end

local function writeLuaCATS(data, path)
    local file = fs.open(path .. ".lua", "w")
    file.write("---@" .. "class " .. data.name .. "\n")
    for _, field in ipairs(data.fields) do
        file.write(string.format("---@field %s %s\n", field.name, field.type .. (field.optional and "?" or "")))
    end
    for _, sub in ipairs(data.subTypes or {}) do
        file.write("\n---@class " .. sub.name .. "\n")
        for _, subField in ipairs(sub.fields) do
            file.write(string.format("---@field %s %s\n", subField.name,
                subField.type .. (subField.optional and "?" or "")))
        end
    end
    file.close()
end

local writers = {
    json = writeJsonTypeStub,
    luacats = writeLuaCATS
}

-- generate JSON function

local function generateJSON()
    local function isSequentialArray(tbl)
        local i = 0
        for _ in pairs(tbl) do
            i = i + 1
            if tbl[i] == nil then
                return false
            end
        end
        return true
    end

    local function inferFieldType(value, keyName)
        local valueType = type(value)

        if valueType == "string" then return "string" end
        if valueType == "number" then return "number" end
        if valueType == "boolean" then return "boolean" end
        if valueType == "function" or valueType == "thread" or valueType == "userdata" then
            return "unknown" -- or "any", or even error if you'd prefer to block it
        end

        if valueType == "table" then
            -- Empty tables: ambiguous
            if next(value) == nil then return "table" end

            if isSequentialArray(value) then
                -- Sample first element
                local first = value[1]
                local subtype = inferFieldType(first, keyName .. "Item")

                -- Check if the subtype is an object (i.e., custom class)
                if type(first) == "table" then
                    local subTypeName = keyName:gsub("^%l", string.upper)
                    if not knownSubTypes[subTypeName] then
                        local fields = {}
                        for subK, subV in pairs(first) do
                            table.insert(fields, {
                                name = subK,
                                type = inferFieldType(subV, subK),
                                optional = false
                            })
                        end
                        knownSubTypes[subTypeName] = {
                            name = subTypeName,
                            fields = fields
                        }
                    end
                    return subTypeName .. "[]"
                else
                    return subtype .. "[]"
                end
            else
                -- If not sequential, check for map shape: string keys with uniform value types
                local keyType, valType = nil, nil
                for k, v in pairs(value) do
                    if type(k) ~= "string" then return "table" end
                    local vt = type(v)
                    if valType and valType ~= vt then return "table" end
                    valType = vt
                end
                return "table<string, " .. valType .. ">"
            end
        end

        return "any"
    end

    -- Build structured type definition output
    local fields = {}
    for key, value in pairs(stub) do
        local fieldType = inferFieldType(value, key)
        table.insert(fields, {
            name = key,
            type = fieldType,
            optional = optionals[key] == true
        })
    end

    local finalOutput = {
        name = config.rootTypeName,
        description = config.rootTypeDescription,
        fields = fields,
        subTypes = {}
    }

    for _, subDef in pairs(knownSubTypes) do
        table.insert(finalOutput.subTypes, subDef)
    end
    return finalOutput
end

-- building the stub

local function doScan(callback)
    local entries = config.tableToScan and next(config.tableToScan) ~= nil and config.tableToScan or (config.tableProvider and config.tableProvider()) -- Check tableToScan or use tableProvider

    for index, value in pairs(entries) do
        actions.addAction(function()
            local resolved = config.resolveItem and config.resolveItem(index, value) or value
            if resolved then callback(resolved) end
        end)
    end
    actions.execute()
end

local function buildStub(tabEntry)
    for k, v in pairs(tabEntry) do
        if stub[k] == nil then
            stub[k] = v
        elseif stub[k] ~= nil and (stub[k] == "" or stub[k] == {}) then
            stub[k] = v
        end
    end
end

local function markOptional(tabEntry)
    for k, v in pairs(stub) do
        if tabEntry[k] == nil then
            optionals[k] = true
        end
    end
end

-- build stub

doScan(buildStub)
doScan(markOptional)

local finalOutput = generateJSON()

for k, enabled in pairs(config) do
    if enabled and writers[k] then
        writers[k](finalOutput, config.outputPath)
    end
end
