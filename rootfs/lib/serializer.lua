local serializer = {}

-- class definitions

---@class OptTable
---@field function_mode? "skip" | "stringify" | "error"  Optional, controls function serialization behavior
---@field recursion_marker? string                         Optional string for recursion cycles
---@field log_unsupported? boolean                          Optional, whether to log unsupported types

--- Internal log for each serialize call (array of strings)
---@type string[]
local internalLogs = {}

--- Default options table
---@type OptTable
local defaultOpts = {
    function_mode = "stringify",      -- "skip", "stringify", or "error"
    recursion_marker = "<recursive>", -- string used for recursion cycles
    log_unsupported = true,           -- whether to add logs for skipped/unsupported
}

--- Internal recursive serialization function
---@param value any Value to serialize
---@param seen? table<any, boolean> Table tracking visited tables to detect recursion
---@param path? string Path string representing current location in the structure (for logs)
---@param opts? OptTable Options controlling serialization behavior
---@return string #Serialized string representation of `value`
local function _serialize(value, seen, path, opts)
    local t = type(value)
    seen = seen or {}
    path = path or "root"
    opts = opts or defaultOpts

    if t == "number" or t == "boolean" then
        return tostring(value)
    elseif t == "string" then
        return string.format("%q", value)
    elseif t == "nil" then
        return "nil"
    elseif t == "table" then
        if seen[value] then
            if opts.log_unsupported then
                table.insert(internalLogs, ("[RECURSION] %s already seen"):format(path))
            end
            return string.format("%q", opts.recursion_marker or "<recursive>")
        end

        seen[value] = true
        local out = { "{" }

        for k, v in pairs(value) do
            local kStr = "[" .. _serialize(k, seen, path .. ".<key>", opts) .. "]"
            local vStr = _serialize(v, seen, path .. "." .. tostring(k), opts)
            table.insert(out, "  " .. kStr .. " = " .. vStr .. ",")
        end

        table.insert(out, "}")
        return table.concat(out, "\n")
    elseif t == "function" then
        if opts.function_mode == "skip" then
            if opts.log_unsupported then
                table.insert(internalLogs, ("[SKIP FUNCTION] %s is a function"):format(path))
            end
            return "nil"
        elseif opts.function_mode == "stringify" then
            if opts.log_unsupported then
                table.insert(internalLogs, ("[STRINGIFY FUNCTION] %s is a function"):format(path))
            end
            return string.format("%q", "<function>")
        elseif opts.function_mode == "error" then
            error(("Cannot serialize function at %s"):format(path))
        else
            -- Fallback: stringify
            if opts.log_unsupported then
                table.insert(internalLogs, ("[STRINGIFY FUNCTION] %s is a function (fallback)"):format(path))
            end
            return string.format("%q", "<function>")
        end
    elseif t == "thread" then
        if opts.log_unsupported then
            table.insert(internalLogs, ("[UNSERIALIZABLE] %s is a thread"):format(path))
        end
        return string.format("%q", "<thread>")
    elseif t == "userdata" then
        if opts.log_unsupported then
            table.insert(internalLogs, ("[UNSERIALIZABLE] %s is userdata"):format(path))
        end
        return string.format("%q", "<userdata>")
    else
        if opts.log_unsupported then
            table.insert(internalLogs, ("[UNKNOWN TYPE] %s is type '%s'"):format(path, t))
        end
        return string.format("%q", "<" .. t .. ">")
    end
end

--- Serialize a Lua value to a Lua source string with options and logging
---@param value any Value to serialize
---@param opts? OptTable Optional serialization options
---@return string? #Serialized Lua source string starting with "return " (nil on error)
---@return string[]|nil #Logs generated during serialization or nil if no logs / error occurred
function serializer.serialize(value, opts)
    opts = opts or {}
    -- Fill in missing options with defaults
    for k, v in pairs(defaultOpts) do
        if opts[k] == nil then opts[k] = v end
    end

    internalLogs = {}
    local ok, outputOrErr = pcall(_serialize, value, nil, "root", opts)
    if not ok then
        return nil, { outputOrErr } -- return error in logs table for consistency
    end
    return "return " .. outputOrErr, internalLogs
end

--- Deserialize Lua source string into a Lua value
---@param str string Lua source code to deserialize (should return a value)
---@return any|nil #Deserialized value or nil on error
---@return string|nil #Error message if deserialization failed
function serializer.deserialize(str)
    local chunk, err = load(str, "deserializer", "t", {})
    if not chunk then return nil, "Load error: " .. err end
    local ok, result = pcall(chunk)
    if not ok then return nil, "Runtime error: " .. result end
    return result
end

--- Serialize a Lua value to a file
---@param value any Value to serialize
---@param path string File path to save serialized string
---@param opts? OptTable Optional serialization options
---@return boolean #success True if file was written successfully
---@return string|nil #err Error message on failure or nil
---@return string[]|nil #logs Serialization logs, if any
function serializer.serializeToFile(value, path, opts)
    local str, logs = serializer.serialize(value, opts)
    if not str then
        return false, logs and logs[1] or "Unknown error", logs
    end
    local file, err = fs.open(path, "w")
    if not file then
        return false, "Failed to open file: " .. (err or "unknown error"), logs
    end
    file.write(str)
    file.close()
    return true, nil, logs
end

--- Load and deserialize Lua value from a file
---@param path string File path to read from
---@return any|nil #Deserialized value or nil on failure
---@return string|nil #Error message if failed
function serializer.deserializeFromFile(path)
    local file = fs.open(path, "r")
    if not file then return nil, "Failed to open file for reading" end
    local contents = file.readAll()
    file.close()
    if not contents then return nil, "Failed to read file contents" end
    return serializer.deserialize(contents)
end

--- Deserialize Lua source string with a custom environment
---@param str string Lua source code to deserialize
---@param env? table Environment table to use for chunk execution
---@return any|nil #Deserialized value or nil on failure
---@return string|nil #Error message if failed
function serializer.deserializeWithEnv(str, env)
    env = env or {}
    local chunk, err = load(str, "deserializer", "t", env)
    if not chunk then return nil, "Load error: " .. err end
    local ok, result = pcall(chunk)
    if not ok then return nil, "Runtime error: " .. result end
    return result
end

return serializer
