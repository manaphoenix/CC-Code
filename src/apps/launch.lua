-- New launcher app

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
    w = math.floor(w)
    h = math.floor(h)
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

local function makeGrid(rows, columns, width, height, startx, starty)
    local gridObj = {
        rows = rows,
        columns = columns,
        width = width,
        height = height,
        startx = startx,
        starty = starty,
        objs = {}
    }
    
    function gridObj:add(obj)
        table.insert(self.objs, obj)
        return true
    end
    
    function gridObj:remove(obj)
        for i,v in pairs(self.objs) do
            if v == obj then
                table.remove(self.objs, i)
                return true
            end
        end
        return false
    end
    
    function gridObj:render()
        -- TODO
    end
    
    return gridObj
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
local t = "| Components | PineStore | Themes | Theme Catalog |"
t = t:gsub("|",symbols.separator)
local f = ""
local b = ""
for c in t:gmatch(".") do
    if c == symbols.separator then
        f = f .. 7
        b = b .. 0
    else
        f = f .. 0
        b = b .. 7
    end
end

term.blit(t,f,b)

-- Work area: rows 3 through my - 1
-- grid of 3x3 (no idea if this is perm, just trying to get a visual)
local grid = makeGrid(3,3,mx,my-3,1,3)

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
term.setTextColor(peripheral.find("modem") and colors.lime or colors.red)
term.write(symbols.filledCircle .. " modem online")
term.setTextColor(colors.white)

os.pullEventRaw("terminate")

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)