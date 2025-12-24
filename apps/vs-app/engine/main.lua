-- VS-Engine Main Entry Point
-- Loads core and starts engine

local ok, err = pcall(function()
    local core = require("core")
    core.run()
end)

if not ok then
    print("Error starting VS-Engine: " .. tostring(err))
end
