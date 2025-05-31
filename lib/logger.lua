-- logger.lua
-- A feature-complete logger library for ComputerCraft
-- Compatible with standard CC Lua (no table.copy or other unavailable features)

local logger = {}

-- === CONFIGURATION === --
local LOG_PATH = "/logs"
local DEFAULT_FILE = "default.log"
local DEFAULT_LEVEL = "info"
local LOG_LEVELS = { trace = 0, debug = 1, info = 2, warn = 3, error = 4, fatal = 5 }
local COLOR_CODES = {
  trace = colors.gray,
  debug = colors.lightGray,
  info = colors.white,
  warn = colors.orange,
  error = colors.red,
  fatal = colors.red
}

-- === UTILITY === --
local function ensureDir(path)
  if not fs.exists(path) then
    fs.makeDir(path)
  end
end

local function shallowCopy(tbl)
  local new = {}
  for k, v in pairs(tbl) do new[k] = v end
  return new
end

local function formatTimestamp()
  local t = textutils.formatTime(os.time(), true)
  return string.format("[%s]", t)
end

local function getLogLevelValue(level)
  return LOG_LEVELS[level] or LOG_LEVELS[DEFAULT_LEVEL]
end

local function colorPrint(msg, level)
  local old = term.getTextColor()
  term.setTextColor(COLOR_CODES[level] or old)
  print(msg)
  term.setTextColor(old)
end

local function writeToFile(file, msg)
  local h = fs.open(file, "a")
  if h then
    h.writeLine(msg)
    h.close()
  end
end

-- === LOGGING FUNCTION === --
function logger.log(level, message, file)
  level = string.lower(level)
  local ts = formatTimestamp()
  local line = string.format("%s [%s] %s", ts, level:upper(), message)

  -- Terminal output
  colorPrint(line, level)

  -- File output
  ensureDir(LOG_PATH)
  writeToFile(fs.combine(LOG_PATH, file or DEFAULT_FILE), line)
end

-- === SHORTCUT METHODS === --
for name in pairs(LOG_LEVELS) do
  logger[name] = function(msg, file)
    logger.log(name, msg, file)
  end
end

-- === LOGGER INSTANCE CREATOR === --
function logger.createTagged(tag, file)
  local newLogger = {}
  for name in pairs(LOG_LEVELS) do
    newLogger[name] = function(msg)
      logger.log(name, string.format("[%s] %s", tag, msg), file)
    end
  end
  return newLogger
end

return logger
