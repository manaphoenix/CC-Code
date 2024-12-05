--- A module for outputting colored text using blit.
---@class icolorModule
local icolor = {}

for _,v in pairs(colors) do
    if type(v) == "number" then
        local blitString = colors.toBlit(v)
        icolor[blitString] = blitString
    end
end

local pattern = "\\."
local _, my = term.getSize()

--- Outputs a string with specified background color, handling new lines.
---@param str string @The string to output.
---@param bg number @The background color.
---@param newLine boolean @Whether to move to a new line after output.
local cache = {}
local function out(str, bg, newLine)
    local key = str .. tostring(bg) .. tostring(newLine)
    if cache[key] then return cache[key] end

    local _, y = term.getCursorPos()
    bg = bg and icolor[colors.toBlit(bg)] or icolor[colors.toBlit(colors.black)]
    str = tostring(str)
    local result = ""
    repeat
        local startPoint, endPoint = str:find(pattern)
        if startPoint then
            local fg = icolor[str:sub(startPoint + 1, endPoint)]
            str = str:sub(endPoint + 1)
            if not str:find(pattern) then
                result = result .. str
                str = ""
            else
                local txt = str:sub(1, startPoint - 1)
                result = result .. txt
                str = str:sub(startPoint)
            end
        end
    until str == ""
    if newLine then
        if (y + 1) > my then
            term.scroll(1)
            term.setCursorPos(1, y)
        else
            term.setCursorPos(1, y + 1)
        end
    end
    cache[key] = result
    return result
end

return setmetatable({}, {
    __call = function(_, ...)
        return out(...)
    end
})