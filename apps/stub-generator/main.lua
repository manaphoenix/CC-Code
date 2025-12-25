local args = { ... }
local side = args[1]

local p = peripheral.wrap(side)
assert(p, "Peripheral not found on side " .. side)

-- Get peripheral type
local types = { peripheral.getType(p) }
local class_name_raw = types[1] or "Peripheral"

-- Sanitize for Lua identifier and filename
local function sanitize(name)
    return name:gsub("[^%w]", "_")
end

local class_name = sanitize(class_name_raw)
local file_name = class_name .. "_stub.lua"

-- Get methods
local name = peripheral.getName(p)
local methods = peripheral.getMethods(name)

-- Capture other functions on the wrapped peripheral
local other_data = {}
for k, v in pairs(p) do
    if type(v) == "function" then
        other_data[k] = v
    end
end

-- --- Generate stub ---
local stub_lines = {}

-- Add class annotation (LuaCATS-safe) and original type as comment
table.insert(stub_lines, "---@class " .. class_name .. " -- original type: " .. class_name_raw)
table.insert(stub_lines, "local " .. class_name .. " = {}\n")

-- Add methods from peripheral.getMethods
for _, method in ipairs(methods) do
    table.insert(stub_lines, "---@return any")
    table.insert(stub_lines, "function " .. class_name .. "." .. method .. "(...) end\n")
end

-- Add any other functions
for method_name in pairs(other_data) do
    local found = false
    for _, m in ipairs(methods) do
        if m == method_name then
            found = true
            break
        end
    end
    if not found then
        table.insert(stub_lines, "---@return any")
        table.insert(stub_lines, "function " .. class_name .. "." .. method_name .. "(...) end\n")
    end
end

-- Return the table
table.insert(stub_lines, "return " .. class_name)

-- Write to file
local file = io.open("stubs/" .. file_name, "w")
file:write(table.concat(stub_lines, "\n"))
file:close()

print("Stub generated for peripheral: " .. class_name_raw .. " -> " .. file_name)
