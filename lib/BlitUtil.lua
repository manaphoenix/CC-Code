--[[ 
Color code legend (blit hex):
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

--- Example string: "{&r|bHello, World!"

---@alias BlitHex '"0"' | '"1"' | '"2"' | '"3"' | '"4"' | '"5"' | '"6"' | '"7"' 
---| '"8"' | '"9"' | '"a"' | '"b"' | '"c"' | '"d"' | '"e"' | '"f"'

--- A peripheral with terminal-like capabilities (term or monitor).
---@class BlitDevice
---@field blit fun(text: string, fg: string, bg: string)
---@field getSize fun(): integer, integer
---@field getCursorPos fun(): integer, integer
---@field setCursorPos fun(x: integer, y: integer)
---@field clear fun()
---@field getTextColor fun(): integer
---@field getBackgroundColor fun(): integer

--- Converts a color name, blit hex, or `colors.X` constant to a blit hex character.
---@param color string | integer @Color name (e.g. "red"), blit hex character, or color constant from `colors`
---@return BlitHex
local function colorToBlitHex(color)
  return colors.toBlit(color)
end

--- Moves cursor to the next line or resets to left edge if at bottom.
---@param device BlitDevice
local function nextLine(device)
  local _, maxY = device.getSize()
  local _, curY = device.getCursorPos()
  if curY == maxY then
    device.setCursorPos(1, curY)
  else
    device.setCursorPos(1, curY + 1)
  end
end

---@class BlitWriter
---@field write fun(str: string, autoNewLine?: boolean) @Write string with embedded color codes ({&x|y} or {&r}). Optional newline.
---@field writeLine fun(str: string) @Write string and move to next line.
---@field resetColors fun() @Reset foreground and background colors to default.
---@field setPos fun(x: integer, y: integer) @Set cursor position.
---@field getPos fun(): integer, integer @Get cursor position.
---@field clear fun() @Clear the screen.
---@field resetDevice fun() @Clear screen and reset cursor to top-left.
---@field rewriteLine fun(str: string) @Rewrite current line without changing position.

--- Creates a writer for a terminal or monitor.
---@param device BlitDevice
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
    setPos = device.setCursorPos,
    getPos = device.getCursorPos,
    clear = device.clear,
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
---@field forTerm fun(): BlitWriter @Create writer for the default terminal.
---@field forMonitor fun(mon: BlitDevice): BlitWriter @Create writer for a specific monitor.

---@type BlitUtil
return {
  forTerm = function() return createWriter(term) end,
  forMonitor = function(mon) return createWriter(mon) end
}
