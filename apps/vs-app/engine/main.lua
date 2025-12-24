term.clear()
term.setCursorPos(1, 1)

local core = {} -- initialize so it can be used

local suc, err = pcall(function()
    core = require("core")
    core.run()
end)

if not suc then
    print("Error starting VS-Engine: " .. err)
else
    print("Starting VS-Engine Successfully Loaded.")
end
