---@class StringBuilder
---@field append fun(self: StringBuilder, str: string): StringBuilder
---@field appendLine fun(self: StringBuilder, str?: string): StringBuilder
---@field appendFormat fun(self: StringBuilder, fmt: string, ...: any): StringBuilder
---@field appendFormatWithNewLine fun(self: StringBuilder, fmt: string, ...: any): StringBuilder
---@field appendSeparator fun(self: StringBuilder, char?: string, count?: number): StringBuilder
---@field toString fun(self: StringBuilder): string
---@field _parts string[] Internal storage (private)

local StringBuilder = {}
local methods = {}

function methods:append(str)
    table.insert(self._parts, str)
    return self
end

function methods:appendLine(str)
    table.insert(self._parts, (str or "") .. "\n")
    return self
end

function methods:appendFormat(fmt, ...)
    table.insert(self._parts, string.format(fmt, ...))
    return self
end

function methods:appendFormatWithNewLine(fmt, ...)
    table.insert(self._parts, string.format(fmt, ...) .. "\n")
    return self
end

---Append a separator line.
---Defaults to a single newline. You can specify a character and repeat count.
---@param char string? Character(s) to repeat. Defaults to "\n".
---@param count number? How many times to repeat. Defaults to 1.
---@return StringBuilder
function methods:appendSeparator(char, count)
    char = char or "\n"
    count = count or 1
    table.insert(self._parts, string.rep(char, count) .. "\n")
    return self
end

function methods:toString()
    return table.concat(self._parts)
end

---@return StringBuilder
function StringBuilder.new()
    local sb = { _parts = {} }
    setmetatable(sb, { __index = methods })
    return sb
end

return StringBuilder
