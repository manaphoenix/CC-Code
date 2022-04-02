--[[
    SimpleButton API for Computercraft
    
    A simple button class.
]]

local SimpleButton = {}

local buttonStorage = {}

local sharedFunctions = {
    draw = function(self)
        if self.toggled then
            self.backgroundColor = self.backgroundColorOn
        else
            self.backgroundColor = self.backgroundColorOff
        end
        term.setBackgroundColor(self.backgroundColor)
        term.setTextColor(self.textColor)
        -- draw the borders
        for i = self.y, (self.y + self.height - 1) do
            term.setCursorPos(self.x, i)
            term.write(string.rep(" ", self.width))
        end
        -- draw the text
        local xpos = self.x + math.floor(self.width / 2) - math.floor(string.len(self.text) / 2)
        local ypos = self.y + math.floor(self.height / 2)
        term.setCursorPos(xpos, ypos)
        term.write(self.text)
    end,
    within = function(self, x, y)
        if x >= self.x and x <= (self.x + self.width - 1) and y >= self.y and y <= (self.y + self.height - 1) then
            return true
        else
            return false
        end
    end,
    fire = function(self)
        if self.isToggle then
            self:onToggle()
        else
            self:onClick()
        end
    end
}

local buttonClass = {
    __index = sharedFunctions
}

local buttonTemplate = {
    x = 1,
    y = 1,
    width = 10,
    height = 3,
    text = "Button",
    textColor = colors.white,
    backgroundColor = colors.lightGray,
    backgroundColorOn = colors.gray,
    backgroundColorOff = colors.lightGray,
    isToggle = false,
    toggled = false,
    onClick = nil,
    onToggle = nil
}

-- util function to clone a table
local function clone(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

-- create a new button
function SimpleButton.new(tbl)
    local t = clone(buttonTemplate)
    for k, v in pairs(tbl) do
        t[k] = v
    end
    setmetatable(t, buttonClass)
    table.insert(buttonStorage, t)
    return t
end

-- draw all buttons
function SimpleButton.drawAll()
    for i = 1, #buttonStorage do
        buttonStorage[i]:draw()
    end
end

-- event handler
function SimpleButton.handleEvent(event, button, x, y)
    for i = 1, #buttonStorage do
        if buttonStorage[i]:within(x, y) then
            buttonStorage[i]:fire()
        end
    end
end

return SimpleButton