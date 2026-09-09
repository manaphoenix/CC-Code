--- VS Receiver Dashboard Startup Script
--- This file should be placed in the computer's root directory as "startup"
--- It will automatically launch the VS Receiver Dashboard when the computer starts

--- Set the working directory to the vs-dashboard folder
local dashboardPath = "/vs-dashboard"

--- Check if dashboard directory exists
local function checkDashboard()
    local success, err = pcall(function()
        local list = fs.list(dashboardPath)
        return #list > 0
    end)

    if not success then
        print("Error: VS Dashboard directory not found at " .. dashboardPath)
        print("Please ensure the vs-dashboard folder is in the computer's root directory")
        return false
    end

    return true
end

--- Launch the dashboard application
local function launchDashboard()
    -- Change to dashboard directory
    shell.setDir(dashboardPath)

    -- Load and run the main application
    local mainApp = require("main")
    local success, result = mainApp.main()

    if not success then
        print("VS Receiver Dashboard failed to start")
        if result then
            print("Error: " .. tostring(result))
        end
        return false
    end

    return true
end

--- Main startup function
local function main()
    -- Clear screen and show startup message
    term.clear()
    term.setCursorPos(1, 1)

    print("VS Receiver Dashboard Startup")
    print("================================")

    -- Check if dashboard exists
    if not checkDashboard() then
        print("Press any key to continue to shell...")
        os.pullEvent("key")
        return
    end

    print("Starting VS Receiver Dashboard...")
    print()

    -- Launch the dashboard
    local success = launchDashboard()

    if success then
        print("VS Receiver Dashboard exited normally")
    else
        print("VS Receiver Dashboard exited with errors")
    end

    print()
    print("Press any key to continue to shell...")
    os.pullEvent("key")

    -- Return to shell
    term.clear()
    term.setCursorPos(1, 1)
end

--- Run startup with error handling
local function safeStartup()
    local success, err = pcall(main)
    if not success then
        term.clear()
        term.setCursorPos(1, 1)
        print("Startup Error: " .. tostring(err))
        print("Press any key to continue to shell...")
        os.pullEvent("key")
    end
end

-- Execute startup
safeStartup()
