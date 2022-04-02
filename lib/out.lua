local icolor = {
    ["0"] = colors.toBlit(colors.white),
    ["1"] = colors.toBlit(colors.orange),
    ["2"] = colors.toBlit(colors.magenta),
    ["3"] = colors.toBlit(colors.lightBlue),
    ["4"] = colors.toBlit(colors.yellow),
    ["5"] = colors.toBlit(colors.lime),
    ["6"] = colors.toBlit(colors.pink),
    ["7"] = colors.toBlit(colors.gray),
    ["8"] = colors.toBlit(colors.lightGray),
    ["9"] = colors.toBlit(colors.cyan),
    a = colors.toBlit(colors.purple),
    b = colors.toBlit(colors.blue),
    c = colors.toBlit(colors.brown),
    d = colors.toBlit(colors.green),
    e = colors.toBlit(colors.red),
    f = colors.toBlit(colors.black)
}

local pattern = "\\."
local _, my = term.getSize()
local first = true

local function out(str, bg, newLine)
    local _,y = term.getCursorPos()
    if (y+1 > my) and not first then
        term.scroll(1)
        term.setCursorPos(1, y)
    else
        first = false
    end
    bg = bg and colors.toBlit(bg) or colors.toBlit(colors.black)
    str = tostring(str)
    repeat
        local startPoint, endPoint = str:find(pattern)
        if startPoint ~= nil then
            local fg = icolor[str:sub(startPoint+1,endPoint)]
            str = str:sub(endPoint+1)
            if not str:find(pattern) then
                term.blit(str, fg:rep(#str), bg:rep(#str))
                str = ""
            else
                startPoint, endPoint = str:find(pattern)
                local txt = str:sub(1, startPoint-1)
                term.blit(txt, fg:rep(#txt), bg:rep(#txt))
                str = str:sub(startPoint)
            end
        end
    until str == ""
    if newLine then
        if (y+1) > my then
            term.setCursorPos(1, y)
        else
            term.setCursorPos(1, y+1)
        end
    end
end

return out