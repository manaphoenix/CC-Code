--[[
    SimpleButton API for Computercraft
    
    A simple button class.
]]

local SimpleButton = {}

local buttonStorage = {}

local IButton = {
    draw = function(self)
        if self.isToggle then
            self.backgroundColor = self.toggled and self.backgroundColorOn or self.backgroundColorOff
        end
        local bg = colors.toBlit(self.backgroundColor):rep(self.width)
        local fg = colors.toBlit(self.textColor):rep(self.width)
        local ypos = self.y + math.floor(self.height / 2)
        local len = string.len(self.text)
        -- draw the borders
        local t = string.rep(" ", self.width)
        for i = self.y, (self.y + self.height - 1) do
            term.setCursorPos(self.x, i)
            if i ~= ypos then
                term.blit(t, fg, bg)
            else
                local txtLine = t:sub(1, (self.width/2)-(len/2)) .. self.text .. t:sub((self.width/2)+(len/2)+1, self.width)
                term.blit(txtLine, fg, bg)
            end
        end
    end,
    within = function(self, x, y)
        return x >= self.x and x <= (self.x + self.width) and y >= self.y and y <= (self.y + self.height)
    end,
    fire = function(self)
        if self.isToggle then
            self.toggled = not self.toggled
            self:onToggle()
            return
        end
        self:onClick()
    end,
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

local buttonClass = {
    __index = IButton
}

---@class SimpleButton
---@field x number The x position to draw the button at
---@field y number The y position to draw the button at
---@field width number How wide the button should be
---@field height number How tall the button should be
---@field text string What text does the button have?
---@field textColor number What is the text color of the button?
---@field backgroundColor number What is the background Color for the button? (Gets handled automatically for toggle buttons)
---@field backgroundColorOn number The background color of the toggle button when it is toggled on
---@field backgroundColorOff number The background color of the toggle button when it is toggled off
---@field isToggle boolean Whether the button is a togglable button
---@field toggled boolean The current toggle state of the toggle button, can be set to set a default state, or used to check state.
---@field onClick function The function to run when the button is clicked (does not get called for toggle buttons)
---@field onToggle function the function to run when the toggle button is clicked

-- create a new button
---@param tbl? table
---@return SimpleButton
function SimpleButton.new(tbl)
    local t = setmetatable({}, buttonClass)
    if tbl then
        for i,v in pairs(tbl) do
            t[i] = v
        end
    end
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
function SimpleButton.handleEvent(event, _, x, y)
    if event ~= "mouse_click" and event ~= "monitor_touch" then return end
    for i = 1, #buttonStorage do
        if buttonStorage[i]:within(x, y) then
            buttonStorage[i]:fire()
        end
    end
end

return SimpleButton
