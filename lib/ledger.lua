local ledger = {} -- public API
local _ledger = { -- internal state
    terminalEcho = true,
    filePath = "ledger.log",
    sinks = {}
}

-- Internal helper: _emit
local function _emit(line)
    -- 1. Write to file
    local f = fs.open(_ledger.filePath, "a")
    if f then
        f.writeLine(line)
        f.close()
    end

    -- 2. Terminal echo
    if _ledger.terminalEcho then
        print(line)
    end

    -- 3. Call sinks
    for _, func in pairs(_ledger.sinks) do
        pcall(func, line) -- fire-and-forget
    end
end

-- Internal helper: raise an error pointing to the user's code
local function raiseError(message)
    error("[Ledger] " .. message, 2)
end

-- Public API
-- Write a plain line
function ledger.write(message)
    if type(message) ~= "string" then
        raiseError("write() expects a string")
    end
    _emit(message)
end

-- Write a formatted line
function ledger.writeFormatted(formatStr, ...)
    if type(formatStr) ~= "string" then
        raiseError("writeFormatted() expects a format string")
    end
    ledger.write(string.format(formatStr, ...))
end

-- Add a sink
function ledger.addSink(name, func)
    if type(name) ~= "string" or name == "" then
        raiseError("sink name must be a non-empty string")
    end
    if type(func) ~= "function" then
        raiseError("sink must be a function")
    end
    _ledger.sinks[name] = func
end

-- Remove a sink
function ledger.removeSink(name)
    if type(name) ~= "string" or name == "" then
        raiseError("sink name must be a non-empty string")
    end
    _ledger.sinks[name] = nil
end

-- Set terminal echo
function ledger.setTerminalEcho(bool)
    if type(bool) ~= "boolean" then
        raiseError("terminalEcho must be a boolean")
    end
    _ledger.terminalEcho = bool
end

-- Set file path
function ledger.setFile(path)
    if type(path) ~= "string" or path == "" then
        raiseError("file path must be a non-empty string")
    end

    if path:find('[%?%*%:"<>|]') then
        raiseError("file path contains forbidden characters")
    end

    if #path > 255 then
        raiseError("file path is too long")
    end

    local parent = fs.getDir(path)
    if parent and not fs.exists(parent) then
        pcall(fs.makeDir, parent)
    end

    _ledger.filePath = path
end

return ledger
