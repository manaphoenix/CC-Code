-- app/newapp/templates.lua

local util = require("util")

local templates = {}

function templates.script(name)
    return string.format([[
-- %s (script)

term.clear()
term.setCursorPos(1, 1)

local name = "%s"

print("Running script: " .. name)

-- script logic here

print(name .. " finished")
]], name, name)
end

function templates.app(name)
    return string.format([[
-- %s (app)

local running = true

local name = "%s"

local function init()
    print("Initializing app: " .. name)
end

local function update()
    -- update logic
end

local function render()
    -- render logic
end

local function handler(event)
    local ev = event[1]
    if ev == "key" then
        local keyCode = event[2]
        if keyCode == keys.q then
            running = false
        end
    end
end

init()

while running do
    update()
    render()

    local event = {os.pullEvent()}
    handler(event)
end
]], name, name)
end

function templates.generate(spec, render)
    local base

    if spec.execution == "script" then
        base = templates.script(spec.name)
    else
        base = templates.app(spec.name)
    end

    local renderBlock = render.build(spec.render)

    return {
        main = util.join(renderBlock.init) .. "\n\n" .. base,
        manifest = render.buildManifest(spec),
    }
end

return templates
