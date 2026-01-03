--- VS Receiver Dashboard - Main Application Entry Point
--- Modular rewrite of the original VS Receiver by Manaphoenix
--- Uses LuaCats annotations for better code documentation

--- Import required modules
local Config = require("config")
local Display = require("lib.display")
local Peripherals = require("lib.peripherals")
local Events = require("lib.events")
local Status = require("lib.status")

--- Application class that manages all components
--- @class VSReceiver
--- @field config Config Configuration settings
--- @field peripherals Peripherals Peripheral manager
--- @field display Display Display manager
--- @field status Status Status manager
--- @field events Events Event manager
--- @field initialized boolean Whether application is initialized

local VSReceiver = {}

--- Create new VS Receiver instance
--- @return VSReceiver receiver VS Receiver instance
function VSReceiver.new()
    local self = setmetatable({}, { __index = VSReceiver })

    -- Load configuration
    self.config = Config.getDefault()

    -- Validate configuration
    local isValid, error = Config.validate(self.config)
    if not isValid then
        error("Invalid configuration: " .. error)
    end

    -- Initialize managers
    self.peripherals = Peripherals.new(self.config)
    self.status = Status.new(self.config)
    self.events = nil  -- Will be initialized after display
    self.display = nil -- Will be initialized after peripherals
    self.initialized = false

    return self
end

--- Initialize the application
--- @return boolean success Whether initialization succeeded
--- @return string? error Error message if failed
function VSReceiver:init()
    if self.initialized then
        return true
    end

    -- Initialize peripherals
    local success, error, peripherals = self.peripherals:init()
    if not success then
        return false, "Failed to initialize peripherals: " .. error
    end

    -- Initialize display
    self.display = Display.new(peripherals, self.config)
    success, error = self.display:init()
    if not success then
        return false, "Failed to initialize display: " .. error
    end

    -- Initialize events
    self.events = Events.new(self.config, self.display, self.peripherals, self.status)
    success = self.events:init()
    if not success then
        return false, "Failed to initialize events"
    end

    -- Initialize status
    success = self.status:init()
    if not success then
        return false, "Failed to initialize status"
    end

    -- Show loading screen
    self.display:showLoadingScreen()

    -- Show initial lock screen
    self.display:drawLockScreen()

    self.initialized = true
    return true
end

--- Run the main application loop
--- @return boolean success Whether application ran successfully
--- @return string? error Error message if failed
function VSReceiver:run()
    if not self.initialized then
        return false, "Application not initialized"
    end

    -- Main event loop
    while self.events:shouldRun() do
        local event = { os.pullEventRaw() }
        self.events:handleEvent(event)
    end

    -- Cleanup on exit
    self:cleanup()

    return true
end

--- Cleanup application resources
function VSReceiver:cleanup()
    if self.display then
        self.display:clearAll()
    end

    if self.peripherals then
        self.peripherals:cleanup()
    end
end

--- Get application status information
--- @return table info Application status
function VSReceiver:getStatus()
    if not self.initialized then
        return {
            initialized = false,
            version = self.config.version
        }
    end

    return {
        initialized = true,
        version = self.config.version,
        locked = self.events:isLocked(),
        tuningState = self.events:getTuningState(),
        peripherals = self.peripherals:getInfo(),
        status = self.status:getSummary()
    }
end

--- Handle application restart
--- @return boolean success Whether restart succeeded
--- @return string? error Error message if failed
function VSReceiver:restart()
    -- Cleanup current state
    self:cleanup()

    -- Reset initialization flag
    self.initialized = false

    -- Reinitialize
    return self:init()
end

--- Main execution function
--- @return boolean success Whether application executed successfully
--- @return string? error Error message if failed
local function main(...)
    -- Handle command line arguments
    local args = { ... }

    -- Check for help flag
    if #args > 0 and (args[1] == "--help" or args[1] == "-h") then
        print("VS Receiver Dashboard v" .. Config.getDefault().version)
        print("Usage: main.lua [options]")
        print("Options:")
        print("  --help, -h     Show this help message")
        print("  --version, -v  Show version information")
        print("  --status, -s   Show current status")
        return true
    end

    -- Check for version flag
    if #args > 0 and (args[1] == "--version" or args[1] == "-v") then
        print("VS Receiver Dashboard v" .. Config.getDefault().version)
        print("Original by Manaphoenix")
        print("Modular rewrite with LuaCats annotations")
        return true
    end

    -- Create and initialize application
    local app = VSReceiver.new()

    local success, error = app:init()
    if not success then
        print("Failed to initialize VS Receiver: " .. error)
        return false
    end

    -- Check for status flag
    if #args > 0 and (args[1] == "--status" or args[1] == "-s") then
        local status = app:getStatus()
        print("VS Receiver Status:")
        print("  Version: " .. status.version)
        print("  Initialized: " .. tostring(status.initialized))
        print("  Locked: " .. tostring(status.locked))
        print("  Tuning State: " .. status.tuningState)
        return true
    end

    -- Run main application
    success, error = app:run()
    if not success then
        print("VS Receiver error: " .. error)
        return false
    end

    return true
end

--- Error handling wrapper
local function safeMain()
    local success, result = pcall(main)
    if not success then
        print("VS Receiver crashed: " .. tostring(result))

        -- Clear screen on crash
        term.clear()
        term.setCursorPos(1, 1)
        print("VS Receiver Dashboard crashed")
        print("Error: " .. tostring(result))
        print("Press any key to continue...")

        -- Wait for user input before exiting
        os.pullEvent("key")
        return false
    end

    return result
end

--- Execute main function if this file is run directly
if ... == nil then
    return safeMain()
end

--- Export main function for external use
return {
    main = safeMain,
    VSReceiver = VSReceiver
}
