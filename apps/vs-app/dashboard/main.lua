term.clear()
term.setCursorPos(1, 1)

local core = {} -- initialize so it can be used

local suc, err = pcall(function()
    core = require("core")
    core.run()
end)

if not suc then
    print("Error starting VS-Dashboard: " .. err)
else
    print("Starting VS-Dashboard Successfully Loaded.")
end
