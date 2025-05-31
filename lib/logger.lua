-- logger.lua - Feature-complete logging utility for ComputerCraft

local fs = require("fs")

local logger = {}

-- === CONFIGURATION === --
local defaultConfig = {
    logToFile = true,
    logToTerminal = true,
    filePath = "/logs/log.txt",
    includeTimestamp = true,
    useColors = true,
    maxFileSize = 1024 * 32, -- 32 KB
    timestampFormat = "%Y-%m-%d %H:%M:%S"
}

local levels = {
    DEBUG = { tag = "[DEBUG]", color = colors.lightGray },
    INFO  = { tag = "[INFO]",  color = colors.white },
    WARN  = { tag = "[WARN]",  color = colors.orange },
    ERROR = { tag = "[ERROR]", color = colors.red },
    FATAL = { tag = "[FATAL]", color = colors.red },
}

local config = table.copy(defaultConfig)

-- === INTERNAL UTILITY === --
local function ensureLogDir()
    local dir = fs.getDir(config.filePath)
    if not fs.exists(dir) then
        fs.makeDir(dir)
    end
end

local function getTimestamp()
    return os.date(config.timestampFormat)
end

local function formatLine(levelTag, msg)
    local prefix = config.includeTimestamp and ("[" .. getTimestamp() .. "] ") or ""
    return prefix .. levelTag .. " " .. msg
end

local function writeToFile(line)
    if not config.logToFile then return end
    ensureLogDir()
    local file = fs.open(config.filePath, "a")
    if file then
        file.writeLine(line)
        file.close()

        -- Trim file if too large
        if fs.getSize(config.filePath) > config.maxFileSize then
            local oldLines = {}
            local f = fs.open(config.filePath, "r")
            for i = 1, 1000 do
                local l = f.readLine()
                if not l then break end
                table.insert(oldLines, l)
            end
            f.close()
            local newFile = fs.open(config.filePath, "w")
            for i = #oldLines - 500, #oldLines do
                if oldLines[i] then newFile.writeLine(oldLines[i]) end
            end
            newFile.close()
        end
    end
end

local function writeToTerminal(line, color)
    if not config.logToTerminal then return end
    if term.isColor() and config.useColors then
        term.setTextColor(color)
    end
    print(line)
    if term.isColor() then
        term.setTextColor(colors.white)
    end
end

-- === PUBLIC INTERFACE === --
function logger.setConfig(userConfig)
    for k, v in pairs(userConfig) do
        config[k] = v
    end
end

function logger.log(levelName, msg)
    local level = levels[levelName:upper()] or levels.INFO
    local line = formatLine(level.tag, msg)
    writeToTerminal(line, level.color)
    writeToFile(line)
end

-- Shortcuts
function logger.debug(msg) logger.log("DEBUG", msg) end
function logger.info(msg)  logger.log("INFO",  msg) end
function logger.warn(msg)  logger.log("WARN",  msg) end
function logger.error(msg) logger.log("ERROR", msg) end
function logger.fatal(msg) logger.log("FATAL", msg) end

-- Special
function logger.clearLog()
    if fs.exists(config.filePath) then
        fs.delete(config.filePath)
    end
    logger.info("Log cleared.")
end

function logger.tail(n)
    n = n or 10
    if not fs.exists(config.filePath) then
        print("Log file not found.")
        return
    end
    local lines = {}
    local f = fs.open(config.filePath, "r")
    while true do
        local line = f.readLine()
        if not line then break end
        table.insert(lines, line)
    end
    f.close()
    for i = math.max(1, #lines - n + 1), #lines do
        print(lines[i])
    end
end

return logger
