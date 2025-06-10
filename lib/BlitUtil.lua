--[[
Color code legend (blit hex):
white      = {&0}
orange     = {&1}
magenta    = {&2}
lightBlue  = {&3}
yellow     = {&4}
lime       = {&5}
pink       = {&6}
gray       = {&7}
lightGray  = {&8}
cyan       = {&9}
purple     = {&a}
blue       = {&b}
brown      = {&c}
green      = {&d}
red        = {&e}
black      = {&f}
reset      = {&r}

to also set background do:
{&r|b} where r is foreground, and b is background

example: {&e}Hello{&b} World{&r}

example with background: {&e|f}Hello{&b|f} World{&r}
]]

---@alias BlitHex '"0"' | '"1"' | '"2"' | '"3"' | '"4"' | '"5"' | '"6"' | '"7"'
---| '"8"' | '"9"' | '"a"' | '"b"' | '"c"' | '"d"' | '"e"' | '"f"'

--- A peripheral with terminal-like capabilities (term or monitor).
---@class BlitDevice
---@field blit fun(text: string, fg: string, bg: string) @Blits the text with specified foreground and background color codes.
---@field getSize fun(): integer, integer @Returns the width and height of the device.
---@field getCursorPos fun(): integer, integer @Returns the current cursor position (x, y).
---@field setCursorPos fun(x: integer, y: integer) @Sets the cursor to the specified (x, y) position.
---@field clear fun() @Clears the device screen.
---@field getTextColor fun(): integer @Returns the current text color index.
---@field getBackgroundColor fun(): integer @Returns the current background color index.

--- Converts a color name, blit hex, or `colors.X` constant to a blit hex character.
---@param color string | integer @Color name (e.g. "red"), blit hex character, or color constant from `colors`.
---@return BlitHex @The corresponding blit hex color code.
local function colorToBlitHex(color)
  return colors.toBlit(color)
end

--- Moves cursor to the next line or resets to the left edge if at the bottom.
---@param device BlitDevice @The device to check the cursor position on.
local function nextLine(device)
  local _, maxY = device.getSize()
  local _, curY = device.getCursorPos()
  if curY == maxY then
    device.setCursorPos(1, curY)
  else
    device.setCursorPos(1, curY + 1)
  end
end

--- Removes all blit formatting tags from a string.
--- Useful for layout calculations (e.g., centering).
---@param txt string The formatted string
---@return string plainText The visible text with all {&} codes stripped
local function stripFormatting(txt)
  return (txt:gsub("{&.-}", ""))
end

---@class BlitWriter
---@field write fun(str: string, autoNewLine?: boolean) @Writes a string with embedded color codes, optionally moving to the next line after.
---@field writeLine fun(str: string) @Writes a string and moves the cursor to the next line.
---@field resetColors fun() @Resets foreground and background colors to the default colors.
---@field setPos fun(x: integer, y: integer) @Sets the cursor to the specified (x, y) position.
---@field getPos fun(): integer, integer @Returns the current cursor position (x, y).
---@field clear fun() @Clears the screen.
---@field resetDevice fun() @Clears the screen and resets the cursor position to the top-left corner.
---@field rewriteLine fun(str: string) @Rewrites the current line with the specified string.

--- Creates a writer for a terminal or monitor device.
---@param device BlitDevice @The device to create the writer for (can be terminal or monitor).
---@return BlitWriter @Returns a new BlitWriter instance for the specified device.
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
---@field forTerm fun(): BlitWriter @Creates a writer for the default terminal.
---@field forMonitor fun(mon: BlitDevice): BlitWriter @Creates a writer for a specific monitor device.

---@type BlitUtil
return {
  forTerm = function() return createWriter(term) end,
  forMonitor = function(mon) return createWriter(mon) end,
  stripFormatting = stripFormatting
}
