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
            term.setBackgroundColor(self.backgroundColor)
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

-- create a new button
function SimpleButton.new(tbl)
    local t = setmetatable(tbl or {}, buttonClass)
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
