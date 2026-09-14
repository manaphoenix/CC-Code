local symbols = require(".lib.core.symbols")

term.clear()
term.setCursorPos(1, 1)

local mx, my = term.getSize()
local title = "Ashgard Systems"

local function center(text, y)
  term.setCursorPos(math.floor((mx - #text) / 2) + 1, y)
  term.write(text)
end

local function drawButton(w,h)
    -- first line
    local t = "\x97%s"
    term.write(t:format(("\x83"):rep(w-2)))
    local bgcolor = term.getBackgroundColor()
    term.setBackgroundColor(term.getTextColor())
    term.setTextColor(bgcolor)
    term.write("\x94")
    term.setTextColor(term.getBackgroundColor())
    term.setBackgroundColor(bgcolor)
    -- middle parts
    local cx, cy = term.getCursorPos()
    term.setCursorPos(cx-w,cy+1)
    for i = 2, h-2 do
        term.write("\x95")
        term.write((" "):rep(w-2))
        local bgcolor = term.getBackgroundColor()
        term.setBackgroundColor(term.getTextColor())
        term.setTextColor(bgcolor)
        term.write("\x95")
        term.setTextColor(term.getBackgroundColor())
        term.setBackgroundColor(bgcolor)
        cx, cy = term.getCursorPos()
        term.setCursorPos(cx-w,cy+1)
    end
    
    -- last line
    t = "\x8A%s"
    local bgcolor = term.getBackgroundColor()
    term.setBackgroundColor(term.getTextColor())
    term.setTextColor(bgcolor)
    term.write(t:format(("\x8F"):rep(w-2)))
    term.write("\x85")
    term.setTextColor(term.getBackgroundColor())
    term.setBackgroundColor(bgcolor)
end

-- Title bar
term.setBackgroundColor(colors.lightGray)
term.setTextColor(colors.black)
term.write((" "):rep(mx))
center(title, 1)

-- Tab bar
term.setCursorPos(1, 2)
term.setBackgroundColor(colors.gray)
term.write((" "):rep(mx))

term.setCursorPos(1, 2)
term.setBackgroundColor(colors.lightBlue) -- active: Apps
term.setTextColor(colors.white)
term.write(" Apps ")

term.setBackgroundColor(colors.gray)
term.setTextColor(colors.white)
term.write(symbols.separator .. " Components " .. symbols.separator .. " PineStore ")

-- Work area: rows 3 through my - 1
-- grid of 3x3 (no idea if this is perm, just trying to get a visual)
term.setCursorPos(2,4)
drawButton(mx/3-3,my/3-3)
term.setCursorPos(mx/3+3,4)
drawButton(mx/3-3,my/3-3)
term.setCursorPos(mx-(mx/3)+3,4)
drawButton(mx/3-3,my/3-3)

term.setCursorPos(2,my/3+3)
drawButton(mx/3-3,my/3-3)
term.setCursorPos(mx/3+3,my/3+3)
drawButton(mx/3-3,my/3-3)
term.setCursorPos(mx-(mx/3)+3,my/3+3)
drawButton(mx/3-3,my/3-3)

term.setCursorPos(2,my-(my/3)+3)
drawButton(mx/3-3,my/3-3)
term.setCursorPos(mx/3+3,my-(my/3)+3)
drawButton(mx/3-3,my/3-3)
term.setCursorPos(mx-(mx/3)+3,my-(my/3)+3)
drawButton(mx/3-3,my/3-3)

-- Status bar
term.setCursorPos(1, my)
term.setBackgroundColor(colors.lightGray)
term.write((" "):rep(mx))

local numSystem = #fs.list("apps/system")
local numUser = #fs.list("apps/user")

term.setCursorPos(1, my)
term.setTextColor(colors.black)
term.write((" Apps: %d/%d Installed"):format(numSystem,numUser))
term.setCursorPos(mx-#(symbols.filledCircle .. " modem online"),my)
term.setTextColor(colors.lime)
term.write(symbols.filledCircle .. " modem online")
term.setTextColor(colors.white)

os.pullEventRaw("terminate")

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)