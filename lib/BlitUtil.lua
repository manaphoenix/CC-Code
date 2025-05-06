---@alias BlitHex '"0"' | '"1"' | '"2"' | '"3"' | '"4"' | '"5"' | '"6"' | '"7"' 
---| '"8"' | '"9"' | '"a"' | '"b"' | '"c"' | '"d"' | '"e"' | '"f"'

---@class BlitDevice
---@field blit fun(text: string, fg: string, bg: string)
---@field getSize fun(): integer, integer
---@field getCursorPos fun(): integer, integer
---@field setCursorPos fun(x: integer, y: integer)
---@field clear fun()
---@field getTextColor fun(): integer
---@field getBackgroundColor fun(): integer

local colors = require("colors")  -- assuming standard CC:Tweaked colors API

local function colorToBlitHex(c)
  return colors.toBlit(c)
end

local function nextLine(device)
  local w, h = device.getSize()
  local x, y = device.getCursorPos()
  device.setCursorPos(1, (y == h) and y or (y + 1))
end

---@class BlitWriter
---@field write fun(str: string, autoNewLine?: boolean)
---@field writeLine fun(str: string)
---@field resetColors fun()
---@field setPos fun(x: integer, y: integer)
---@field getPos fun(): integer, integer
---@field clear fun()
---@field resetDevice fun()
---@field rewriteLine fun(str: string)

local function createWriter(device)
  -- cache default colors
  local defaultFg = colorToBlitHex(device.getTextColor())
  local defaultBg = colorToBlitHex(device.getBackgroundColor())
  local curFg, curBg = defaultFg, defaultBg

  -- locals for speed
  local blit    = device.blit
  local sub     = string.sub
  local len     = string.len

  local function writeColored(str, newLine)
    local L = len(str)
    -- preallocate tables
    local text = {}   text[L] = nil
    local fg   = {}   fg[L]   = nil
    local bg   = {}   bg[L]   = nil

    local t_i, f_i, b_i = 1, 1, 1
    local i = 1
    while i <= L do
      local c1 = sub(str, i, i)
      if c1 == "\\" and sub(str, i+1, i+3) == "{&" then
        -- escaped literal "{&"
        text[t_i], fg[f_i], bg[b_i] = "{", curFg, curBg
        t_i, f_i, b_i = t_i+1, f_i+1, b_i+1
        text[t_i], fg[f_i], bg[b_i] = "&", curFg, curBg
        t_i, f_i, b_i = t_i+1, f_i+1, b_i+1
        text[t_i], fg[f_i], bg[b_i] = "{", curFg, curBg
        t_i, f_i, b_i = t_i+1, f_i+1, b_i+1
        i = i + 4
      elseif c1 == "{" and sub(str, i+1, i+2) == "&" then
        -- color change
        local fgCode = sub(str, i+2, i+2)
        curFg = (fgCode == "r") and defaultFg or fgCode

        if sub(str, i+3, i+3) == "|" then
          local bgCode = sub(str, i+4, i+4)
          curBg = (bgCode == "r") and defaultBg or bgCode
          i = i + 6
        else
          i = i + 4
        end
      else
        -- normal character
        text[t_i], fg[f_i], bg[b_i] = c1, curFg, curBg
        t_i, f_i, b_i = t_i+1, f_i+1, b_i+1
        i = i + 1
      end
    end

    -- stitch and blit
    blit(table.concat(text,    1, t_i-1),
         table.concat(fg,      1, f_i-1),
         table.concat(bg,      1, b_i-1))
    if newLine then nextLine(device) end
  end

  return {
    write       = writeColored,
    writeLine   = function(s) writeColored(s, true) end,
    resetColors = function() curFg, curBg = defaultFg, defaultBg end,
    setPos      = device.setCursorPos,
    getPos      = device.getCursorPos,
    clear       = device.clear,
    resetDevice = function()
      device.clear()
      device.setCursorPos(1, 1)
    end,
    rewriteLine = function(s)
      local x, y = device.getCursorPos()
      device.setCursorPos(1, y)
      writeColored(s, false)
      device.setCursorPos(x, y)
    end,
  }
end

return {
  forTerm    = function() return createWriter(term) end,
  forMonitor = createWriter,
}
