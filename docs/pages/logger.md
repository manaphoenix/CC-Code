---
layout: codepage
title: Logger
tags: [Library, Logging, Debugging, Utilities]
description: >
  A flexible logging library for ComputerCraft with file and console output,
  color-coded log levels, and support for tagged loggers.
permalink: /pages/logger.html
overview: >
  The Logger library provides a simple yet powerful way to handle logging in
  ComputerCraft programs. It supports multiple log levels, colored console output,
  and file-based logging with automatic log rotation.
installation: "manaphoenix/CC-Code/main/lib/logger.lua"
basic_usage_description: >
  Get started with the default logger or create tagged loggers for different
  components of your application.
basic_usage: |
  local logger = require("logger")
  
  -- Basic logging
  logger.info("Application started")
  logger.warn("This is a warning")
  logger.error("Something went wrong!")
  
  -- Create a tagged logger
  local netLog = logger.createTagged("NETWORK")
  netLog.info("Connected to server")
  netLog.error("Connection timeout")

methods:
  - method_name: log
    params:
      - name: level
        type: "string"
      - name: message
        type: "string"
      - name: file
        type: "string"
        optional: true
    return_type: "void"
    method_description: "Logs a message with the specified level and optional file output."
    method_code: |
      local logger = require("logger")
      logger.log("info", "This is an info message")
      logger.log("error", "This is an error", "errors.log")

  - method_name: createTagged
    params:
      - name: tag
        type: "string"
      - name: file
        type: "string"
        optional: true
    return_type: "table"
    method_description: "Creates a new logger instance that prefixes all messages with a tag."
    method_code: |
      local logger = require("logger")
      local netLog = logger.createTagged("NETWORK")
      netLog.info("Initialized network module")  -- Logs: [HH:MM:SS] [info] [NETWORK] Initialized network module

  - method_name: "Log Levels (Shortcut Methods)"
    params: []
    return_type: "void"
    method_description: "Convenience methods for each log level."
    method_code: |
      local logger = require("logger")
      
      -- Available log levels (in increasing severity):
      logger.trace("Detailed debug information")
      logger.debug("Debug information")
      logger.info("Informational message")
      logger.warn("Warning message")
      logger.error("Error message")
      logger.fatal("Fatal error, application may terminate")

examples:
  - title: "Basic Logging"
    code: |
      local logger = require("logger")
      
      -- Set up logging
      logger.info("Starting application")
      
      -- Log different levels
      logger.debug("Debug information")
      logger.info("User logged in", "auth.log")
      logger.warn("Disk space low")
      logger.error("Failed to save file", "errors.log")
      
      -- Create a tagged logger for a specific module
      local dbLog = logger.createTagged("DATABASE")
      dbLog.info("Connected to database")
      dbLog.error("Query failed")

  - title: "Error Handling with Logging"
    code: |
      local logger = require("logger")
      
      local function processFile(filename)
          local file = fs.open(filename, "r")
          if not file then
              logger.error(string.format("Failed to open file: %s", filename))
              return nil
          end
          
          logger.debug(string.format("Processing file: %s", filename))
          -- File processing logic here
          file.close()
          return true
      end
      
      -- Usage
      local success, err = pcall(processFile, "config.txt")
      if not success then
          logger.error(string.format("Error in processFile: %s", err))
      end

advanced:
  - title: "Custom Log File Location"
    description: "Change the default log directory and file."
    code: |
      local logger = require("logger")
      
      -- Change default log directory (do this before any logging)
      logger.LOG_PATH = "/my/custom/logs"
      logger.DEFAULT_FILE = "myapp.log"
      
      -- Now all logs will go to /my/custom/logs/myapp.log
      logger.info("Using custom log location")

  - title: "Custom Log Levels"
    description: "Add or modify log levels."
    code: |
      local logger = require("logger")
      
      -- Add a new log level
      logger.LOG_LEVELS.notice = 2.5  -- Between info and warn
      logger.COLOR_CODES.notice = colors.blue
      
      -- Create a notice function
      logger.notice = function(msg, file)
          logger.log("notice", msg, file)
      end
      
      -- Now you can use the new level
      logger.notice("This is a notice")

---

# Logger Library Documentation

A comprehensive logging solution for ComputerCraft that combines console and file logging with support for different log levels and colored output.

## Log Levels

The logger supports the following log levels (in order of increasing severity):

| Level  | Color      | Description                                      |
|--------|------------|--------------------------------------------------|
| trace  | Gray       | Very detailed debugging information            |
| debug  | Light Gray | Debug-level information                         |
| info   | White      | General information about application operation |
| warn   | Orange     | Warnings about potential issues                 |
| error  | Red        | Error conditions that don't prevent operation  |
| fatal  | Red        | Severe errors that may cause application abort  |


## Configuration

### Default Settings

- **Log Directory**: `/logs`
- **Default Log File**: `default.log`
- **Default Log Level**: `info`

### Customization

You can modify these defaults by changing the module's properties before any logging occurs:

```lua
local logger = require("logger")
logger.LOG_PATH = "/var/log/myapp"
logger.DEFAULT_FILE = "app.log"
```

## Best Practices

1. **Use Appropriate Log Levels**:
   - Use `debug` for detailed debugging information
   - Use `info` for normal operational messages
   - Use `warn` for unexpected but handled conditions
   - Use `error` for errors that don't prevent the application from running
   - Use `fatal` for critical errors that cause the application to terminate

2. **Tagged Loggers**:
   Create separate loggers for different modules using `createTagged()` for better organization:
   ```lua
   local dbLog = logger.createTagged("DATABASE")
   local netLog = logger.createTagged("NETWORK")
   ```

3. **Error Context**:
   Always include relevant context in error messages:
   ```lua
   -- Bad
   logger.error("File not found")
   
   -- Good
   logger.error(string.format("File not found: %s", filename))
   ```

## Performance Considerations

1. **String Concatenation**:
   For performance-critical sections, avoid string concatenation in log statements:
   ```lua
   -- Bad (creates string even if debug is disabled)
   logger.debug("Processing item: " .. item.id)
   
   -- Better (string.format is only called if debug is enabled)
   logger.debug(string.format("Processing item: %s", item.id))
   ```

2. **Conditional Logging**:
   For very verbose debug logs, consider checking the log level first:
   ```lua
   if logger.LOG_LEVELS.debug >= logger.LOG_LEVELS[logger.DEFAULT_LEVEL] then
       logger.debug(expensiveDebugFunction())
   end
   ```

## Integration with Other Libraries

The logger can be easily integrated with other libraries. For example, to create a BlitUtil-compatible logger:

```lua
local logger = require("logger")
local BlitUtil = require("BlitUtil")
local writer = BlitUtil.forTerm()

-- Override the default color print function
logger.colorPrint = function(msg, level)
    local color = logger.COLOR_CODES[level] or colors.white
    local oldFg = term.getTextColor()
    term.setTextColor(color)
    print(msg)
    term.setTextColor(oldFg)
end

-- Now all logs will use BlitUtil for colored output
logger.info("Using BlitUtil for colored logging")
```

## Troubleshooting

### Logs not appearing
- Check if the log directory exists and is writable
- Verify the log level is set appropriately (e.g., if using `debug` but default level is `info`)
- Check for any errors in the ComputerCraft console

### Performance Issues
- Reduce log verbosity in production
- Use string.format instead of concatenation
- Consider disabling file logging if not needed
