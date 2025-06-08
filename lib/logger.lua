--- Logger module.
---@class logger
local logger = {}

local module = {}

--- Log levels.
---@private
local LEVELS = {
  NOTSET = 0,
  DEBUG = 10,
  INFO = 20,
  WARNING = 30,
  ERROR = 40,
  CRITICAL = 50
}

--- Colors for log levels.
---@private
local COLORS = {
  DEBUG = colors.lightGray, -- Detailed information, typically of interest only when diagnosing problems.
  INFO = colors.white,      -- Confirmation that things are working as expected.
  WARNING = colors.orange,  -- An indication that something unexpected happened, or indicative of some problem in the near future (e.g. ‘disk space low’). The software is still working as expected.
  ERROR = colors.red,       -- Due to a more serious problem, the software has not been able to perform some function.
  CRITICAL = colors.red,    -- A serious error, indicating that the program itself may be unable to continue running.
}

--- Merges two tables.
---@private
---@param proxy table the proxy table
---@param real table the real table
---@return function the merged table
local function merged_pairs(proxy, real)
  local seen = {}
  local pk, pv
  local rk, rv
  local phase = "proxy"

  return function()
    while true do
      if phase == "proxy" then
        pk, pv = next(proxy, pk)
        if pk ~= nil then
          seen[pk] = true
          return pk, pv
        else
          phase = "real"
        end
      end

      if phase == "real" then
        rk, rv = next(real, rk)
        if rk ~= nil and not seen[rk] then
          return rk, rv
        elseif rk == nil then
          return nil
        end
      end
    end
  end
end

--- Creates a protected table.
---@private
---@param base table the base table
---@param mode string the mode
---@param validator? function the validator
---@return table the protected table
local function createProtectedTable(base, mode, validator)
  local proxy = {}
  local userKeys = {}

  local mt = {
    __index = base,
    __newindex = function(_, k, v)
      local isPredefined = base[k] ~= nil and userKeys[k] == nil

      -- Validator check (if provided and not a deletion)
      if v ~= nil and validator and not validator(v) then
        error("Invalid value for key: " .. tostring(k), 2)
      end

      if isPredefined then
        if mode == "no-modify" then
          error("Cannot modify or delete key: " .. k, 2)
        elseif mode == "no-delete" and v == nil then
          error("Cannot delete protected key: " .. k, 2)
        else
          base[k] = v
        end
      else
        if v == nil then
          base[k] = nil
          userKeys[k] = nil
        else
          base[k] = v
          userKeys[k] = true
        end
      end
    end,
    __pairs = function() return merged_pairs(proxy, base) end,
  }

  setmetatable(proxy, mt)
  return proxy
end

--- Checks if a value is a valid color.
---@private
---@param value Color the value to check
---@return boolean true if the value is a valid color, false otherwise
local function isValidColor(value)
  for _, v in pairs(colors) do
    if v == value then return true end
  end
  return false
end

--- Checks if a value is a valid log level.
---@private
---@param value LogLevel the value to check
---@return boolean true if the value is a valid log level, false otherwise
local function isValidLevel(value)
  for _, v in pairs(logger.LEVELS) do
    if v == value then return true end
  end
  return false
end

--- Gets the name of a log level.
---@private
---@param level LogLevel the log level
---@return string the name of the log level
local function getLevelName(level)
  for k, v in pairs(logger.LEVELS) do
    if v == level then return k end
  end
  return ""
end

---@alias LogLevel number
logger.LEVELS = createProtectedTable(LEVELS, "no-modify")
logger.COLORS = createProtectedTable(COLORS, "no-delete", isValidColor)

---@class loggerConfig
---@field log_path? string the path to save logs to
---@field filename string the name of the log file
---@field level LogLevel the minimum level of logs to write to file
---@field fmt? string the format string for log messages, supports some intentional globals ${level}, ${message}, ${timestamp}, ${tag}; defaults to "${timestamp} ${level} [${tag}] ${message}"
---@field tag? string the default tag
---@field maxFiles? number the maximum number of log files to keep
---@field console? boolean whether to print to console

--- Formats a log message. This is not called directly, use logger.log() instead. supports some intentional globals ${level}, ${message}, ${timestamp}, ${tag};
---@private
---@param level LogLevel the log level
---@param message string the log message
---@param buildBlitStrings? boolean whether to build the blit strings
---@return string the formatted log message
local function messageFormatter(level, message, buildBlitStrings)
  assert(logger.config, "Logger not initialized")
  assert(logger.config.fmt, "fmt is required; how did you even manage this?")
  ---@type string
  local fmt = logger.config.fmt

  -- assert the level is of part of logger.LEVELS
  -- level will be the value, not the key
  assert(isValidLevel(level), "Invalid log level: " .. level .. " ret: " .. tostring(isValidLevel(level)))

  message = tostring(message) -- sanitize message

  local date = os.date("!%Y-%m-%d %H:%M:%S")
  local lvlName = getLevelName(level)
  local tag = logger.config.tag
  local msg = message

  fmt = fmt:gsub("${timestamp}", date)   -- utc timestamp
  fmt = fmt:gsub("${level}", lvlName)
  if tag ~= "" then
    fmt = fmt:gsub("${tag}", tag)
  end
  fmt = fmt:gsub("${message}", msg)

  if buildBlitStrings then
    local color = COLORS[lvlName] or colors.white
    local fg = colors.toBlit(color):rep(#fmt)
    local bg = ("f"):rep(#fmt)

    return fmt, fg, bg
  end

  return fmt
end

local function consoleWithBlit(level, message)
  -- blit is (string, string, string)
  -- first string is what you want to write
  -- second string is the foreground color, each character is a different color from 0-f
  -- third string is the background color, each character is a different color from 0-f
  local msg, fg, bg = messageFormatter(level, message, true)
  if term.blit then
    term.blit(msg, fg, bg)
  else
    term.write(msg)
  end
  local _, cy = term.getCursorPos()
  term.setCursorPos(1, cy + 1)
end

--- Writes a log message to a file.
---@private
---@param message string the log message
---@return nil
local function writeToOutput(message)
  local file = fs.open(fs.combine(logger.config.log_path, logger.config.filename), "a")
  file.writeLine(message)
  file.close()
end

--- Rotates the log file, removing old log files if they exceed the max log files.
---@private
---@return nil
local function rotateLog()
  local cfg = logger.config
  local baseName = cfg.filename:match("^(.-)%.([^%.]+)$")
  local ext = cfg.filename:match("%.([^%.]+)$") or ".log"
  local basePath = cfg.log_path
  local max = cfg.maxFiles or 10

  -- Step 1: Delete the oldest if it exists
  local oldest = fs.combine(basePath, baseName .. "." .. max .. "." .. ext)
  if fs.exists(oldest) then
    fs.delete(oldest)
  end

  -- Step 2: Shift files up (log.9 -> log.10, etc.)
  for i = max - 1, 1, -1 do
    local src = fs.combine(basePath, baseName .. "." .. i .. "." .. ext)
    local dst = fs.combine(basePath, baseName .. "." .. (i + 1) .. "." .. ext)
    if fs.exists(src) then
      fs.move(src, dst)
    end
  end

  -- Step 3: Move current log file to .1
  local current = fs.combine(basePath, baseName .. "." .. ext)
  local firstBackup = fs.combine(basePath, baseName .. ".1" .. "." .. ext)
  if fs.exists(current) then
    fs.move(current, firstBackup)
  end
end


--- Creates a new logger instance with basic configuration.
---@param basicConfig loggerConfig
---@return logger # the logger instance
function module.init(basicConfig)
  assert(basicConfig.filename ~= nil, "filename is required")
  assert(basicConfig.level ~= nil, "level is required")
  basicConfig.log_path = basicConfig.log_path or "/logs"
  basicConfig.fmt = basicConfig.fmt or "${timestamp} ${level} [${tag}] ${message}"
  basicConfig.tag = basicConfig.tag or shell.getRunningProgram():match("^(.-)%.([^%.]+)$") or "" -- defaults to file name
  basicConfig.maxFiles = basicConfig.maxFiles or 1
  basicConfig.console = basicConfig.console or false

  -- if filename doesn't have an extension, add .log
  if not basicConfig.filename:match("%..*$") then
    basicConfig.filename = basicConfig.filename .. ".log"
  end

  logger.config = basicConfig

  -- rotate log files
  if fs.exists(fs.combine(logger.config.log_path, logger.config.filename)) then
    rotateLog()
  end

  return logger
end

--- Sets a configuration value.
---@param key string the key to set
---@param value any the value to set
---@param allowNew? boolean whether to allow setting a new key
---@return nil
function logger.setConfigValue(key, value, allowNew)
  assert(logger.config, "Logger not initialized")
  if not allowNew then
    assert(logger.config[key], "Invalid key")
  end
  logger.config[key] = value
end

--- Logs a message.
---@param message string the message to log
---@param level? LogLevel the log level
---@return nil
function logger.log(message, level)
  assert(logger.config, "Logger not initialized")
  level = level or logger.config.level
  if level < logger.config.level then return end
  writeToOutput(messageFormatter(level, message))
  if logger.config.console then
    consoleWithBlit(level, message)
  end
end

--- Sets the tag.
---@param tag string the tag to set
---@return nil
function logger.setTag(tag)
  logger.config.tag = tag
end

--- Clears the tag.
---@return nil
function logger.clearTag()
  logger.config.tag = ""
end

--- Adds a new log level.
---@param level table<string, number> the log level to add
---@param color Color the color of the log level
function logger.addLevel(level, color)
  assert(type(level) == "table", "Level must be a table")
  assert(isValidColor(color), "Color must be a valid colors value")

  for k, v in pairs(level) do
    logger.LEVELS[k] = v
    logger.COLORS[k] = color
    break
  end
end

--- Removes a log level.
---@param level string the log level key
---@return nil
function logger.removeLevel(level)
  assert(type(level) == "string", "Level must be a string")
  logger.LEVELS[level] = nil
  logger.COLORS[level] = nil
end

--- Sets the color of a log level.
---@param level string the log level key to set the color of
---@param color Color the color to set
---@return nil
function logger.setLevelColor(level, color)
  assert(type(level) == "string", "Level must be a string")
  assert(isValidColor(color), "Color must be a valid colors value")
  logger.COLORS[level] = color
end

--- Logs a message with a tag.
---@param tag string the tag to log with
---@param message string the message to log
---@param level LogLevel the log level
---@return nil
function logger.logWithTag(tag, message, level)
  --store tag if already exists, restore it after logging
  local oldTag = logger.config.tag
  logger.config.tag = tag
  logger.log(message, level)
  logger.config.tag = oldTag
end

--- Logs an info message.
---@param message string the message to log
---@return nil
function logger.info(message)
  logger.log(message, logger.LEVELS.INFO)
end

--- Logs a warning message.
---@param message string the message to log
---@return nil
function logger.warning(message)
  logger.log(message, logger.LEVELS.WARNING)
end

logger.warn = logger.warning

--- Logs an error message.
---@param message string the message to log
---@return nil
function logger.error(message)
  logger.log(message, logger.LEVELS.ERROR)
end

--- Logs a critical message.
---@param message string the message to log
---@return nil
function logger.critical(message)
  logger.log(message, logger.LEVELS.CRITICAL)
end

--- Logs a debug message.
---@param message string the message to log
---@return nil
function logger.debug(message)
  logger.log(message, logger.LEVELS.DEBUG)
end

return module
