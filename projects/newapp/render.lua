-- app/newapp/render.lua

local util = require("util")

local render = {}

local policies = {}

policies.term = {
    init = function()
        return {
            "term.clear()",
            "term.setCursorPos(1, 1)",
        }
    end
}

policies.monitor = {
    init = function()
        return {
            "local monitor = peripheral.find(\"monitor\")",
            "if not monitor then error(\"No monitor found\") end",
            "monitor.clear()",
            "monitor.setCursorPos(1, 1)",
            "-- render: monitor only",
        }
    end
}

policies.mirror = {
    init = function()
        return {
            "local monitor = peripheral.find(\"monitor\")",
            "monitor.clear()",
            "monitor.setCursorPos(1, 1)",
            "-- render: mirror term + monitor",
        }
    end
}

policies.split = {
    init = function()
        return {
            "local monitor = peripheral.find(\"monitor\")",
            "monitor.clear()",
            "monitor.setCursorPos(1, 1)",
            "-- render: split logic/display",
        }
    end
}

function render.build(policyName)
    local policy = policies[policyName]

    if not policy then
        error("Unknown render policy: " .. tostring(policyName))
    end

    return {
        init = policy.init(),
    }
end

function render.buildManifest(spec)
    return string.format([[
return {
    runtime = "%s",
    name = "%s",
    trusted = true,
    description = "",
    version = "1.0.0",
    displayName = "%s"
}
]], spec.execution, util.slugify(spec.name), spec.name)
end

return render
