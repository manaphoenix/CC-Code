-- VS Engine Startup Script
-- This script launches the VS Engine system

-- Change to the vs-engine directory
local currentDir = shell.dir()
if currentDir ~= "vs-engine" then
    shell.setDir("vs-engine")
end

-- Run the main engine
require("main")

-- Return to original directory
shell.setDir(currentDir)
