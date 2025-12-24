-- VS-Dashboard Main Entry Point
-- Loads core and starts dashboard

local ok, err = pcall(function()
    local core = require("core")
    core.run()
end)

if not ok then
    print("Error starting VS-Dashboard: " .. tostring(err))
end
