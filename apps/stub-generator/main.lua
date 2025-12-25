local side = ...

local p = peripheral.wrap(side)
assert(p, "Peripheral not found on side " .. side)

---@type string
local name = peripheral.getName(p)
---@type table<string>
local methods = peripheral.getMethods(name)
---@type table<string>
local types = { peripheral.getType(p) }

local other_data = {}
local other_count = 0

for i, v in pairs(p) do
    if type(v) ~= "function" then
        other_data[i] = v
        other_count = other_count + 1
    end
end

local saveLoc = "types/"
local stringBuilder = require("stringbuilder")

local doc = stringBuilder.new()

local function steralizeClassName(className)
    return className:gsub(":", "_")
end

local function removeKnownMethods(methodList)
    -- if methodList contains any of the methods in methods, remove it from methods
    -- note: methods is table<number, string> where string is the method name
    -- methodList is table<string, function> where string is the method named
    if methodList == nil then
        return
    end

    if methods == nil then
        return
    end

    for i = #methods, 1, -1 do
        if methodList[methods[i]] then
            table.remove(methods, i)
        end
    end
end

local function inhereitFromRecognizedClasses(classTable)
    local combined = ""
    for i, v in ipairs(classTable) do
        if i > 1 and fs.exists(fs.combine(saveLoc, v .. ".lua")) then
            combined = combined .. "," .. v

            local tmp = dofile(fs.combine("/types/", v .. ".lua"))
            removeKnownMethods(tmp)
        end
    end
    return combined == "" and "" or (":%s"):format(combined:sub(2))
end

---Generate LuaCATS fields and a requireable table
---@param doc StringBuilder The StringBuilder instance
---@param className string The name of the class
---@param methods table<number,string> List of method names
---@param properties table<number,string> List of property names
---@param inherit string? Optional inheritance string for the class annotation
local function generateClassStub(doc, className, methods, properties, inherit)
    inherit = inherit or ""

    -- class annotation
    doc:appendLine("---@meta")
    doc:appendLine()
    doc:appendFormatWithNewLine("---@class %s%s", className, inherit)

    -- fields for methods
    for _, name in pairs(methods or {}) do
        doc:appendFormatWithNewLine("---@field %s fun(): any", name)
    end

    -- fields for properties
    for _, name in pairs(properties or {}) do
        doc:appendFormatWithNewLine("---@field %s %s", name, "any") -- or type detection
    end

    -- requireable table
    if (#methods > 0) or (#properties > 0) then
        doc:appendFormatWithNewLine("local %s = {", className)

        for _, name in pairs(methods or {}) do
            doc:appendFormatWithNewLine("\t%s = function() end,", name)
        end

        for _, name in pairs(properties or {}) do
            doc:appendFormatWithNewLine("\t%s = nil,", name) -- default dummy value
        end

        doc:appendLine("}")
        doc:appendLine()
        doc:appendFormatWithNewLine("return %s", className)
    end
end


local class = steralizeClassName(types[1]) -- type[1] is always the class name
local filePath = fs.combine(saveLoc, class .. ".lua")

local file = fs.open(filePath, "w")
assert(file, "Failed to open file")

local className = steralizeClassName(class)
local inheritance = inhereitFromRecognizedClasses(types)

generateClassStub(doc, className, methods, other_data, inheritance)

-- end of program
file.write(doc:toString())
file.close()

term.clear()
term.setCursorPos(1, 1)
print("definition file created: " .. filePath)
