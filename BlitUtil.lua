---@meta

--[[
white 0
orange 1
magenta 2
lightBlue 3
yellow 4
lime 5
pink 6
gray 7
lightGray 8
cyan 9
purple a
blue b
brown c
green d
red e
black f
]]

---@alias BlitHex string  @Single-character hex color code ('0'-'f')

---Convert a color constant or code to a blit hex character.
---@param color string|integer @Can be a color name, blit hex character, or `colors.X` constant.
---@return BlitHex
local function colorToBlitHex(color)
  return colors.toBlit(color)
end

---Advance the cursor to the next line or reset if bottom of device.
---@param device table @The terminal or monitor object
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
---@field write fun(self:BlitWriter, str:string, autoNewLine?:boolean) @Write a string with embedded color codes. Does **not** add a newline unless `autoNewLine` is explicitly `true`.
---@field writeLine fun(self:BlitWriter, str:string) @Write a string with embedded color codes and move to the next line (like `print`)
---@field resetColors fun(self:BlitWriter) @Reset foreground/background colors to their defaults
---@field setPos fun(self:BlitWriter, x:integer, y:integer) @Set the cursor position to `(x, y)`
---@field getPos fun(self:BlitWriter): integer, integer @Get the current cursor position `(x, y)`
---@field clear fun(self:BlitWriter) @Clear the display surface without moving the cursor
---@field resetDevice fun(self:BlitWriter) @Clear the screen and reset the cursor to the top-left corner (1,1)

---Create a new writer for the given device.
---@param device table @The terminal or monitor object
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
    end
  }
end

---@class BlitUtil
---@field forTerm fun(): BlitWriter
---@field forMonitor fun(mon:table): BlitWriter

---Return a module for creating blit writers.
---@type BlitUtil
return {
  forTerm = function() return createWriter(term) end,
  forMonitor = function(mon) return createWriter(mon) end
}
