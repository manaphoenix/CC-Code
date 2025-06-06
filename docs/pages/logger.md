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
  and file-based logging with automatic directory creation.
installation: "manaphoenix/CC-Code/main/lib/logger.lua"
basic_usage_description: >
  Get started with the default logger or create tagged loggers for different
  components of your application.
basic_usage: |
  local logger = require("logger")
  
  -- Basic logging
  logger.info("Application started")
  logger.warning("This is a warning")
  logger.error("Something went wrong!")
  
  -- Create a tagged logger
  local netLog = logger.get("NETWORK")
  netLog.info("Connected to server")
  netLog.error("Connection timeout")

methods:
  - method_name: log
    params:
      - name: level
        type: "string"
      - name: message
        type: "string"
      - name: tag
        type: "string"
        optional: true
      - name: file
        type: "string"
        optional: true
    return_type: "void"
    method_description: "Logs a message with the specified level, optional tag, and optional file output."
    method_code: |
      local logger = require("logger")
      logger.log("INFO", "This is an info message")
      logger.log("ERROR", "This is an error", "NETWORK", "network_errors.log")

  - method_name: get
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
      local netLog = logger.get("NETWORK")
      netLog.info("Initialized network module")  -- Logs: [HH:MM:SS] [INFO] [NETWORK] Initialized network module

  - method_name: "Log Levels (Shortcut Methods)"
    params: []
    return_type: "void"
    method_description: "Convenience methods for each log level."
    method_code: |
      local logger = require("logger")
      
      -- Available log levels (in increasing severity):
      logger.debug("Debug information")
      logger.info("Informational message")
      logger.warning("Warning message")
      logger.error("Error message")
      logger.critical("Critical error, application may terminate")

examples:
  - title: "Basic Logging"
    code: |
      local logger = require("logger")
      
      -- Configure logger
      logger.setLogPath("/myapp/logs")
      logger.setDefaultFile("app.log")
      logger.setLevel("DEBUG")  -- Show all messages
      
      -- Basic logging
      logger.debug("Debug information")
      logger.info("Application started")
      logger.warning("Disk space low")
      logger.error("Failed to save file")
      
      -- Log to a specific file
      logger.info("User logged in", nil, "auth.log")
      
      -- Create a tagged logger for a specific module
      local dbLog = logger.get("DATABASE")
      dbLog.info("Connected to database")
      dbLog.error("Query failed")

  - title: "Error Handling with Logging"
    code: |
      local logger = require("logger")
      
      -- Create a logger for file operations
      local fileLog = logger.get("FILE")
      
      local function processFile(filename)
          local file = fs.open(filename, "r")
          if not file then
              fileLog.error(string.format("Failed to open file: %s", filename))
              return nil
          end
          
          fileLog.debug(string.format("Processing file: %s", filename))
          -- File processing logic here
          local success, err = pcall(function()
              -- Simulate file processing
              if filename:find("test") then
                  error("Test file processing failed")
              end
          end)
          
          file.close()
          
          if not success then
              fileLog.error(string.format("Error processing %s: %s", filename, err))
              return nil
          end
          
          return true
      end
      
      -- Usage
      processFile("config.txt")  -- Will log to default file
      processFile("test.txt")    -- Will log error to default file

advanced:
  - title: "Configuration Options"
    description: "Configure logger behavior programmatically."
    code: |
      local logger = require("logger")
      
      -- Set log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
      logger.setLevel("DEBUG")  -- Show all messages
      
      -- Toggle output destinations
      logger.setOutput({
          console = true,  -- Enable/disable console output
          file = true      -- Enable/disable file output
      })
      
      -- Set log directory and default file
      logger.setLogPath("/myapp/logs")  -- Will be created if it doesn't exist
      logger.setDefaultFile("app.log")
      
      -- Toggle features
      logger.setColors(true)       -- Enable/disable colored output
      logger.setTimestamp(true)    -- Show/hide timestamps

  - title: "Advanced Usage"
    description: "Tagged loggers with different output files."
    code: |
      local logger = require("logger")
      
      -- Configure default logger
      logger.setLogPath("/myapp/logs")
      
      -- Create loggers for different modules
      local dbLogger = logger.get("DATABASE", "database.log")
      local netLogger = logger.get("NETWORK", "network.log")
      
      -- These will go to their respective files
      dbLogger.info("Connected to database")
      netLogger.info("Connected to server")
      
      -- This will go to the default log file
      logger.info("Application started")

---
