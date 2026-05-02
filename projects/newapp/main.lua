-- app/newapp/main.lua

local util = require("util")
local templates = require("templates")
local render = require("render")
local fsys = require("filesystem")

local args = { ... }

---@type table<string, boolean>
local validExecution = {
    script = true,
    app = true,
}

---@type table<string, boolean>
local validRender = {
    term = true,
    monitor = true,
    mirror = true,
    split = true,
}

if #args < 3 then
    print("Usage: newapp <execution> <render-policy> <name>")
    print("Execution: script | app")
    print("Render: term | monitor | mirror | split")
    return
end

local execution, renderType, name = args[1], args[2], args[3]

if not validExecution[execution] then
    print("Invalid execution type")
    return
end

if not validRender[renderType] then
    print("Invalid render policy")
    return
end

local spec = {
    execution = execution,
    render = renderType,
    name = name,
}

local output = templates.generate(spec, render)

fsys.writeApp(util.slugify(name), output)

print("Created app: " .. name)
