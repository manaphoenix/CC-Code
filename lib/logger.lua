-- logger.lua
-- Feature-complete logger inspired by Python's 'logging' module, adapted for ComputerCraft Lua

local logger = {}

-- === CONFIGURATION === --
local config = {
  log_path = "/logs",
  default_file = "default.log",
  level = "DEBUG",
  use_colors = true,
  show_timestamp = true,
  output_to_console = true,
  output_to_file = true,
}

local LEVELS = {
  NOTSET = 0,
  DEBUG = 10,
  INFO = 20,
  WARNING = 30,
  ERROR = 40,
  CRITICAL = 50,
}

local COLORS = {
  DEBUG = colors.lightGray,
  INFO = colors.white,
  WARNING = colors.orange,
  ERROR = colors.red,
  CRITICAL = colors.red,
}

-- === INTERNAL UTILS === --
local function ensure_dir(path)
  if not fs.exists(path) then
    fs.makeDir(path)
  end
end

local function get_timestamp()
  return string.format("[%s]", textutils.formatTime(os.time(), true))
end

local function should_log(level)
  return LEVELS[level] >= LEVELS[config.level]
end

local function sanitize_message(str)
  return tostring(str):gsub("[%c]", " ")
end

local function sanitize_filename(name)
  return tostring(name or config.default_file):gsub("[^%w%._-]", "_")
end

local function format_message(level, message, tag)
  local parts = {}
  if config.show_timestamp then table.insert(parts, get_timestamp()) end
  table.insert(parts, string.format("[%s]", level))
  if tag then table.insert(parts, string.format("[%s]", sanitize_message(tag))) end
  table.insert(parts, sanitize_message(message))
  return table.concat(parts, " ")
end

local function print_console(msg, level)
  local old = term.getTextColor()
  if config.use_colors and COLORS[level] then
    term.setTextColor(COLORS[level])
  end
  print(msg)
  term.setTextColor(old)
end

local function write_file(msg, file)
  ensure_dir(config.log_path)
  local path = fs.combine(config.log_path, sanitize_filename(file))
  local handle = fs.open(path, "a")
  if handle then
    handle.writeLine(msg)
    handle.close()
  end
end

-- === CORE LOGGING FUNCTION === --
function logger.log(level, message, tag, file)
  if not LEVELS[level] then error("Invalid log level: " .. tostring(level)) end
  if not should_log(level) then return end
  local formatted = format_message(level, message, tag)
  if config.output_to_console then print_console(formatted, level) end
  if config.output_to_file then write_file(formatted, file) end
end

-- === LEVEL-SPECIFIC METHODS === --
for level in pairs(LEVELS) do
  logger[string.lower(level)] = function(msg, tag, file)
    logger.log(level, msg, tag, file)
  end
end

-- === TAGGED LOGGER FACTORY === --
function logger.get(tag, file)
  local inst = {}
  for level in pairs(LEVELS) do
    inst[string.lower(level)] = function(msg)
      logger.log(level, msg, tag, file)
    end
  end
  return inst
end

-- === CONFIGURATION API === --
function logger.setLevel(level)
  if not LEVELS[level] then error("Invalid log level: " .. tostring(level)) end
  config.level = level
end

function logger.setOutput(opts)
  config.output_to_console = opts.console ~= false
  config.output_to_file = opts.file ~= false
end

function logger.setColors(enabled)
  config.use_colors = enabled
end

function logger.setTimestamp(enabled)
  config.show_timestamp = enabled
end

function logger.setLogPath(path)
  config.log_path = path
end

function logger.setDefaultFile(name)
  config.default_file = sanitize_filename(name)
end

return logger
