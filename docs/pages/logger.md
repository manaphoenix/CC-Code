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
