---
layout: codepage
title: BlitUtil
tags: [Library, Terminal, Monitor, Colors, Text Formatting]
description: >
  A utility library for simplified terminal and monitor output with color support.
  Provides an easy way to write colored text using blit codes.
permalink: /pages/blit-util.html
overview: >
  BlitUtil offers a convenient way to handle colored text output in ComputerCraft.
  It simplifies working with blit codes and provides a writer interface for both
  terminals and monitors with automatic color code parsing.
installation: "manaphoenix/CC-Code/main/lib/BlitUtil.lua"
basic_usage_description: >
  Create a writer for your terminal or monitor and start writing colored text
  using simple color codes.
basic_usage: |
  local BlitUtil = require("BlitUtil")
  
  -- For terminal
  local writer = BlitUtil.forTerm()
  writer.write("Hello {&e}World{&r}!")
  
  -- For a monitor
  local mon = peripheral.find("monitor")
  local monWriter = BlitUtil.forMonitor(mon)
  monWriter.write("Monitor {&a}ready{&r}!")

methods:
  - method_name: forTerm
    params: []
    return_type: "BlitWriter"
    method_description: "Creates a writer for the default terminal."
    method_code: |
      local BlitUtil = require("BlitUtil")
      local writer = BlitUtil.forTerm()
      writer.writeLine("Terminal writer created!")

  - method_name: forMonitor
    params:
      - name: monitor
        type: "table"
    return_type: "BlitWriter"
    method_description: "Creates a writer for a specific monitor peripheral."
    method_code: |
      local BlitUtil = require("BlitUtil")
      local mon = peripheral.find("monitor")
      if mon then
          local writer = BlitUtil.forMonitor(mon)
          writer.writeLine("Monitor writer created!")
      end

  - method_name: "BlitWriter:write"
    params:
      - name: text
        type: "string"
      - name: autoNewLine
        type: "boolean"
        optional: true
    return_type: "void"
    method_description: "Writes text with embedded color codes. Optional autoNewLine moves cursor down after writing."
    method_code: |
      local writer = BlitUtil.forTerm()
      writer.write("This is {&e}yellow{&r} text")
      writer.write(" on the same line")
      writer.write(" but this is on a new line", true)

  - method_name: "BlitWriter:writeLine"
    params:
      - name: text
        type: "string"
    return_type: "void"
    method_description: "Writes text and moves to the next line."
    method_code: |
      local writer = BlitUtil.forTerm()
      writer.writeLine("This is a line")
      writer.writeLine("This is another line")

  - method_name: "BlitWriter:rewriteLine"
    params:
      - name: text
        type: "string"
    return_type: "void"
    method_description: "Rewrites the current line with new text."
    method_code: |
      local writer = BlitUtil.forTerm()
      writer.write("This will be replaced")
      os.sleep(1)
      writer.rewriteLine("New content!")

  - method_name: "BlitWriter:resetColors"
    params: []
    return_type: "void"
    method_description: "Resets text and background colors to their defaults."
    method_code: |
      local writer = BlitUtil.forTerm()
      writer.write("{&e}Yellow text")
      writer.resetColors()
      writer.write(" Back to normal")

  - method_name: "BlitWriter:setPos"
    params:
      - name: x
        type: "integer"
      - name: y
        type: "integer"
    return_type: "void"
    method_description: "Sets the cursor position."
    method_code: |
      local writer = BlitUtil.forTerm()
      writer.setPos(10, 5)
      writer.write("This starts at (10,5)")

examples:
  - title: "Basic Colored Output"
    code: |
      local BlitUtil = require("BlitUtil")
      local writer = BlitUtil.forTerm()
      
      writer.writeLine("Welcome to {&e}My Program{&r}!")
      writer.writeLine("Status: {&a}OK{&r}")
      writer.write("Processing")
      for i = 1, 3 do
          writer.write(".")
          os.sleep(0.5)
      end
      writer.writeLine(" {&a}Done!{&r}")

  - title: "Progress Bar"
    code: |
      local BlitUtil = require("BlitUtil")
      local writer = BlitUtil.forTerm()
      
      local function drawProgress(percent)
          local width = 20
          local filled = math.floor(percent * width)
          local bar = "["
          for i = 1, width do
              if i <= filled then
                  bar = bar .. "="
              else
                  bar = bar .. " "
              end
          end
          bar = bar .. "] " .. math.floor(percent * 100) .. "%"
          writer.rewriteLine("Progress: {&a}" .. bar .. "{&r}")
      end
      
      for i = 0, 10 do
          drawProgress(i / 10)
          os.sleep(0.5)
      end

advanced:
  - title: "Color Code Reference"
    description: "List of available color codes for use in text."
    code: |
      -- Color codes for use in {&X} format:
      -- {&0} White
      -- {&1} Orange
      -- {&2} Magenta
      -- {&3} Light Blue
      -- {&4} Yellow
      -- {&5} Lime
      -- {&6} Pink
      -- {&7} Gray
      -- {&8} Light Gray
      -- {&9} Cyan
      -- {&a} Purple
      -- {&b} Blue
      -- {&c} Brown
      -- {&d} Green
      -- {&e} Red
      -- {&f} Black
      -- {&r} Reset to default colors
      
      -- Set both foreground and background:
      -- {&f|0} White text on black background
      -- {&0|f} Black text on white background
      
      -- Example with background:
      local writer = require("BlitUtil").forTerm()
      writer.writeLine("{&0|e} Black on Red {&r} Normal text")
      writer.writeLine("{&e|0} Red on Black {&r} Back to normal")

  - title: "Creating a Status Display"
    description: "Monitor display with multiple colored sections"
    code: |
      local BlitUtil = require("BlitUtil")
      
      local function createStatusDisplay()
          local mon = peripheral.find("monitor")
          if not mon then return nil end
          
          mon.setTextScale(0.5)
          local writer = BlitUtil.forMonitor(mon)
          
          local function drawHeader()
              local width = mon.getSize()
              local title = " SYSTEM STATUS "
              local pad = string.rep("=", math.floor((width - #title) / 2))
              writer.writeLine("{&0|e}" .. pad .. title .. pad .. "{&r}")
          end
          
          local function drawSection(title, content)
              writer.writeLine("\n{&a}" .. title .. "{&r}")
              writer.writeLine("" .. content)
          end
          
          return {
              clear = function()
                  mon.clear()
                  mon.setCursorPos(1, 1)
                  drawHeader()
              end,
              update = function()
                  local time = textutils.formatTime(os.time("ingame"), true)
                  local freeMem = math.floor(computer.freeMemory() / 1024)
                  local usedMem = math.floor((computer.totalMemory() - computer.freeMemory()) / 1024)
                  local uptime = os.clock()
                  
                  drawSection("TIME", time)
                  drawSection("MEMORY", string.format("Used: %dK, Free: %dK", usedMem, freeMem))
                  drawSection("UPTIME", string.format("%.1f seconds", uptime))
              end
          }
      end
      
      -- Usage:
      local status = createStatusDisplay()
      if status then
          while true do
              status.clear()
              status.update()
              os.sleep(1)
          end
      else
          print("No monitor found!")
      end
---

# BlitUtil Documentation

BlitUtil is a powerful library for handling colored text output in ComputerCraft. It simplifies working with blit codes and provides a clean interface for both terminal and monitor output.

## Color Code Reference

BlitUtil uses a simple `{&X}` format for color codes, where `X` is a hexadecimal digit (0-f) representing different colors. You can also set both foreground and background colors using `{&f|b}` where `f` is the foreground color and `b` is the background color.

### Available Colors

| Code | Color      | Example           |
|------|------------|-------------------|
| `0`  | White      | `{&0}White`       |
| `1`  | Orange     | `{&1}Orange`      |
| `2`  | Magenta    | `{&2}Magenta`     |
| `3`  | Light Blue | `{&3}Light Blue`  |
| `4`  | Yellow     | `{&4}Yellow`      |
| `5`  | Lime       | `{&5}Lime`        |
| `6`  | Pink       | `{&6}Pink`        |
| `7`  | Gray       | `{&7}Gray`        |
| `8`  | Light Gray | `{&8}Light Gray`  |
| `9`  | Cyan       | `{&9}Cyan`        |
| `a`  | Purple     | `{&a}Purple`      |
| `b`  | Blue       | `{&b}Blue`        |
| `c`  | Brown      | `{&c}Brown`       |
| `d`  | Green      | `{&d}Green`       |
| `e`  | Red        | `{&e}Red`         |
| `f`  | Black      | `{&f}Black`       |
| `r`  | Reset      | `{&r}Reset`       |


### Background Colors

To set both foreground and background colors, use `{&f|b}` where `f` is the foreground color and `b` is the background color. For example:

- `{&e|1}` - Red text on orange background
- `{&0|e}` - White text on red background
- `{&f|0}` - Black text on white background

## Best Practices

1. **Reset Colors**: Always use `{&r}` to reset colors after using colored text to avoid color bleeding.
2. **Escape Braces**: To include literal `{` or `}` in your text, escape them with `\` like `\{` or `\}`.
3. **Monitor Support**: When writing to monitors, ensure you've set an appropriate text scale for your content.
4. **Performance**: For frequently updated displays, consider using `rewriteLine` instead of clearing and redrawing the entire screen.
5. **Error Handling**: Always check if a monitor is available before trying to write to it.

## Advanced Usage

### Custom Color Palettes

You can modify the default colors by using ComputerCraft's `term.setPaletteColor()` function. This affects how the color codes are displayed.

```lua
-- Example: Change what color code '1' (orange) displays as
term.setPaletteColor(colors.orange, 0.9, 0.6, 0.2)  -- Make orange more vibrant
```

### Creating UI Components

BlitUtil makes it easy to create reusable UI components. Here's an example of a button:

```lua
local function createButton(writer, x, y, text, onClick)
    local width = #text + 4
    return {
        draw = function(selected)
            writer.setPos(x, y)
            local bg = selected and "{&0|a}" or "{&a|0}"
            writer.write(bg .. "[" .. text .. "]{&r}")
        end,
        checkClick = function(clickX, clickY)
            if clickY == y and clickX >= x and clickX < x + width then
                if onClick then onClick() end
                return true
            end
            return false
        end
    }
end

-- Usage:
local writer = BlitUtil.forTerm()
local button = createButton(writer, 5, 3, "Click Me!", function()
    writer.setPos(5, 5)
    writer.write("Button clicked!")
end)

button.draw(false)  -- Draw unselected
-- In your event loop:
-- local event, button, x, y = os.pullEvent("mouse_click")
-- button.checkClick(x, y)
```
