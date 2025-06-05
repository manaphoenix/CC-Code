---
layout: codepage
title: Simple Button
tags: [Library, UI, Input, GUI, Buttons]
description: >
  A simple and flexible button implementation for ComputerCraft that supports both
  regular and toggle buttons with customizable appearance and behavior.
permalink: /pages/simple-button.html
overview: >
  The Simple Button library provides an easy way to create interactive buttons in
  ComputerCraft programs. It handles button drawing, click detection, and state
  management, making it simple to add interactive elements to your terminal or
  monitor interfaces.
installation: "manaphoenix/CC-Code/main/lib/simpleButton.lua"
basic_usage_description: >
  Create and manage interactive buttons with minimal code. Supports both regular
  buttons and toggle buttons with different visual states.
basic_usage: |
  local SimpleButton = require("simpleButton")
  
  -- Create a regular button
  local button = SimpleButton.new({
      x = 5, y = 5,
      width = 10, height = 3,
      text = "Click Me!",
      textColor = colors.white,
      backgroundColor = colors.blue,
      onClick = function()
          print("Button clicked!")
      end
  })
  
  -- In your event loop:
  while true do
      local event, p1, p2, p3 = os.pullEvent()
      SimpleButton.handleEvent(event, p1, p2, p3)
      SimpleButton.drawAll()
  end

methods:
  - method_name: new
    params:
      - name: options
        type: "table"
        optional: true
    return_type: "SimpleButton"
    method_description: "Creates a new button instance with the specified options."
    method_code: |
      local SimpleButton = require("simpleButton")
      
      -- Create a toggle button
      local toggle = SimpleButton.new({
          x = 5, y = 5,
          width = 15, height = 3,
          text = "Toggle Me",
          isToggle = true,
          toggled = false,
          textColor = colors.white,
          backgroundColorOn = colors.green,
          backgroundColorOff = colors.red,
          onToggle = function(self)
              print("Toggled:", self.toggled)
          end
      })

  - method_name: drawAll
    params: []
    return_type: "void"
    method_description: "Draws all created buttons on the screen."
    method_code: |
      -- In your draw/refresh function:
      SimpleButton.drawAll()

  - method_name: handleEvent
    params:
      - name: event
        type: "string"
      - name: _
        type: "any"
        optional: true
      - name: x
        type: "number"
      - name: y
        type: "number"
    return_type: "void"
    method_description: "Handles mouse/touch events and triggers button actions when clicked."
    method_code: |
      -- In your event loop:
      local event, p1, p2, p3 = os.pullEvent()
      SimpleButton.handleEvent(event, p1, p2, p3)

  - method_name: "Button Methods"
    params: []
    return_type: "void"
    method_description: "Methods available on button instances."
    method_code: |
      -- draw() - Redraws the button
      button:draw()
      
      -- within(x, y) - Checks if coordinates are within the button
      if button:within(5, 5) then
          print("Coordinates are within button bounds")
      end
      
      -- fire() - Triggers the button's action
      button:fire()

examples:
  - title: "Basic Button"
    code: |
      local SimpleButton = require("simpleButton")
      
      -- Create a simple button
      local button = SimpleButton.new({
          x = 2, y = 2,
          width = 20, height = 3,
          text = "Click Me!",
          textColor = colors.white,
          backgroundColor = colors.blue,
          onClick = function()
              print("Button was clicked!")
          end
      })
      
      -- Simple event loop
      while true do
          button:draw()
          local event, _, x, y = os.pullEvent()
          if event == "mouse_click" or event == "monitor_touch" then
              if button:within(x, y) then
                  button:fire()
              end
          end
      end

  - title: "Toggle Button"
    code: |
      local SimpleButton = require("simpleButton")
      
      -- Create a toggle button
      local toggle = SimpleButton.new({
          x = 2, y = 2,
          width = 20, height = 3,
          text = "Toggle Me",
          isToggle = true,
          toggled = false,
          textColor = colors.white,
          backgroundColorOn = colors.green,
          backgroundColorOff = colors.red,
          onToggle = function(self)
              print("Toggle state:", self.toggled)
          end
      })
      
      -- Event loop with drawAll
      while true do
          term.clear()
          SimpleButton.drawAll()
          local event = {os.pullEvent()}
          SimpleButton.handleEvent(table.unpack(event))
      end

advanced:
  - title: "Dynamic Button Creation"
    description: "Create buttons dynamically based on data"
    code: |
      local SimpleButton = require("simpleButton")
      
      local buttons = {}
      local options = {
          {name = "Option 1", x = 2, y = 2},
          {name = "Option 2", x = 2, y = 6},
          {name = "Option 3", x = 2, y = 10}
      }
      
      -- Create buttons from options
      for i, opt in ipairs(options) do
          buttons[i] = SimpleButton.new({
              x = opt.x,
              y = opt.y,
              width = 15,
              height = 3,
              text = opt.name,
              textColor = colors.white,
              backgroundColor = colors.blue,
              onClick = function()
                  print("Selected:", opt.name)
              end
          })
      end
      
      -- Event loop
      while true do
          SimpleButton.drawAll()
          local event = {os.pullEvent()}
          SimpleButton.handleEvent(table.unpack(event))
      end

  - title: "Button with Custom Drawing"
    description: "Extend button with custom drawing"
    code: |
      local SimpleButton = require("simpleButton")
      
      -- Create a custom button
      local customBtn = SimpleButton.new({
          x = 2, y = 2,
          width = 20, height = 3,
          text = "Custom",
          textColor = colors.white,
          backgroundColor = colors.purple
      })
      
      -- Override draw method
      local oldDraw = customBtn.draw
      function customBtn:draw()
          -- Call original draw
          oldDraw(self)
          
          -- Add custom decoration
          term.setCursorPos(self.x + 1, self.y + 1)
          term.blit("★", colors.toBlit(colors.yellow), colors.toBlit(colors.purple))
      end
      
      -- Event loop
      while true do
          term.clear()
          SimpleButton.drawAll()
          local event = {os.pullEvent()}
          SimpleButton.handleEvent(table.unpack(event))
      end
---

# Simple Button Documentation

A flexible and easy-to-use button implementation for ComputerCraft that supports both regular and toggle buttons with customizable appearance and behavior.

## Features

- **Simple API**: Create buttons with just a few lines of code
- **Toggle Support**: Built-in support for toggle buttons with different visual states
- **Flexible Styling**: Customize colors, size, and position
- **Event Handling**: Automatic click detection and event handling
- **Minimal Dependencies**: Works with standard ComputerCraft

## Button Properties

| Property | Type | Description |
|----------|------|-------------|
| `x`, `y` | number | Button position (top-left corner) |
| `width`, `height` | number | Button dimensions |
| `text` | string | Button text |
| `textColor` | number | Text color (use `colors` constants) |
| `backgroundColor` | number | Background color for regular buttons |
| `backgroundColorOn` | number | Background when toggle is on |
| `backgroundColorOff` | number | Background when toggle is off |
| `isToggle` | boolean | Whether the button is a toggle button |
| `toggled` | boolean | Current toggle state (for toggle buttons) |
| `onClick` | function | Callback for regular button clicks |
| `onToggle` | function | Callback for toggle state changes |

## Best Practices

1. **Performance**:
   - Only redraw buttons when necessary
   - Use `drawAll()` to update all buttons at once

2. **Layout**:
   - Add padding around buttons for better touch targets
   - Consider using a layout manager for complex UIs

3. **Error Handling**:
   - Always check if callbacks exist before calling them
   - Handle cases where button text might be too long

## Integration with Other Libraries

### With BlitUtil
```lua
local SimpleButton = require("simpleButton")
local BlitUtil = require("BlitUtil")
local writer = BlitUtil.forTerm()

-- Override default drawing to use BlitUtil
local oldDraw = SimpleButton.draw
function SimpleButton:draw()
    local bg = self.isToggle and (self.toggled and self.backgroundColorOn or self.backgroundColorOff) or self.backgroundColor
    writer.setPos(self.x, self.y)
    writer.write(string.format("{&%x|%x}%s", 
        self.textColor, 
        bg,
        string.rep(" ", self.width)
    ))
    -- Add more BlitUtil drawing as needed
end
```

### With Parallel Actions
```lua
local SimpleButton = require("simpleButton")
local parallelAction = require("parallelAction")

-- Handle button clicks in parallel
local buttons = {}
for i = 1, 10 do
    buttons[i] = SimpleButton.new({
        x = 2, y = 2 + (i-1)*3,
        width = 15, height = 3,
        text = "Button " .. i,
        onClick = function()
            parallelAction.addAction(function()
                -- Long-running task
                os.sleep(1)
                print("Completed task", i)
            end)
        end
    })
end

-- In your event loop
while true do
    SimpleButton.drawAll()
    local event, p1, p2, p3 = os.pullEvent()
    SimpleButton.handleEvent(event, p1, p2, p3)
    parallelAction.execute()
end
```

## Troubleshooting

### Buttons Not Responding
- Make sure you're calling `handleEvent()` with the correct parameters
- Check that button coordinates are within the terminal/monitor bounds
- Verify that your event loop is running and not blocked

### Visual Issues
- Ensure there's enough space for the button text
- Check that colors are valid `colors` constants
- Make sure to call `drawAll()` after making changes to button properties
