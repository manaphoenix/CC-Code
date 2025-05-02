---@meta

--[[
Color code legend:
white      = 0
orange     = 1
magenta    = 2
lightBlue  = 3
yellow     = 4
lime       = 5
pink       = 6
gray       = 7
lightGray  = 8
cyan       = 9
purple     = a
blue       = b
brown      = c
green      = d
red        = e
black      = f
]]

---@alias BlitHex '"0"'|'"1"'|'"2"'|'"3"'|'"4"'|'"5"'|'"6"'|'"7"'|'"8"'|'"9"'|'"a"'|'"b"'|'"c"'|'"d"'|'"e"'|'"f"'

---Converts a color name, blit code, or `colors.X` constant to a blit hex character.
---@param color string|integer @Color name (e.g. "red"), blit hex character, or color constant from `colors`
---@return BlitHex
local function colorToBlitHex(color)
  return colors.toBlit(color)
end

---Advance the cursor to the next line or reset if bottom of device.
---@param device {getSize: fun(): integer, integer, getCursorPos: fun(): integer, integer, setCursorPos: fun(x: integer, y: integer)} @Terminal or monitor object
local function nextLine(device)
  local _, my = device.getSize()
  local _, cy = device.getCursorPos()
  if cy == my then
    device.setCursorPos(1, cy)
  else
    device.setCursorPos(1, cy + 1)
  end
end

---@class BlitWriter
---@field write fun(str: string, autoNewLine?: boolean) @Write a string with embedded color codes. Optional `autoNewLine` moves cursor to next line.
---@field writeLine fun(str: string) @Write a string and automatically move to the next line.
---@field resetColors fun() @Resets foreground and background colors to default.
---@field setPos fun(x: integer, y: integer) @Sets cursor position.
---@field getPos fun(): integer, integer @Returns current cursor position.
---@field clear fun() @Clears the device screen.
---@field resetDevice fun() @Clears screen and resets cursor to top-left.
---@field rewriteLine fun(str: string) @Rewrites current line with given string.

---Creates a new writer for a terminal or monitor device.
---@param device {blit: fun(text: string, fg: string, bg: string), getSize: fun(): integer, integer, getCursorPos: fun(): integer, integer, setCursorPos: fun(x: integer, y: integer), clear: fun(), getTextColor: fun(): integer, getBackgroundColor: fun(): integer}
---@return BlitWriter
local function createWriter(device)
  local defaultFg = colorToBlitHex(device.getTextColor())
  local defaultBg = colorToBlitHex(device.getBackgroundColor())

  local currentFg = defaultFg
  local currentBg = defaultBg

  local function writeColored(str, autoNewLine)
    local text, fgStr, bgStr = {}, {}, {}
    local i, len = 1, #str

    while i <= len do
      if str:sub(i, i + 2) == "\\{&" then
        table.insert(text, "{&")
        table.insert(fgStr, currentFg)
        table.insert(fgStr, currentFg)
        table.insert(bgStr, currentBg)
        table.insert(bgStr, currentBg)
        i = i + 3
      elseif str:sub(i, i + 1) == "{&" then
        local code = str:sub(i + 2, i + 2)
        currentFg = (code == "r") and defaultFg or code
        if str:sub(i + 3, i + 3) == "|" then
          local bgColor = str:sub(i + 4, i + 4)
          currentBg = (bgColor == "r") and defaultBg or bgColor
          i = i + 6
        else
          i = i + 4
        end
      else
        local char = str:sub(i, i)
        table.insert(text, char)
        table.insert(fgStr, currentFg)
        table.insert(bgStr, currentBg)
        i = i + 1
      end
    end

    local textStr = table.concat(text)
    local fgStrStr = table.concat(fgStr)
    local bgStrStr = table.concat(bgStr)

    if #textStr == #fgStrStr and #textStr == #bgStrStr then
      device.blit(textStr, fgStrStr, bgStrStr)
      if autoNewLine then
        nextLine(device)
      end
    else
      error(("Mismatched string lengths: text=%d, fg=%d, bg=%d"):format(#textStr, #fgStrStr, #bgStrStr), 0)
    end
  end

  local function reset()
    currentFg = defaultFg
    currentBg = defaultBg
  end

  return {
    write = writeColored,
    resetColors = reset,
    setPos = function(x, y)
      device.setCursorPos(x, y)
    end,
    getPos = function()
      return device.getCursorPos()
    end,
    clear = function()
      device.clear()
    end,
    resetDevice = function()
      device.clear()
      device.setCursorPos(1, 1)
    end,
    writeLine = function(str)
      writeColored(str, true)
    end,
    rewriteLine = function(str)
      local x, y = device.getCursorPos()
      device.setCursorPos(1, y)
      writeColored(str)
      device.setCursorPos(x, y)
    end
  }
end

---@class BlitUtil
---@field forTerm fun(): BlitWriter @Creates a writer for the default terminal.
---@field forMonitor fun(mon: table): BlitWriter @Creates a writer for the specified monitor.

---Blit writer utility module.
---@type BlitUtil
return {
  forTerm = function() return createWriter(term) end,
  forMonitor = function(mon) return createWriter(mon) end
}
