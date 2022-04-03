local icolor = {}

for _,v in pairs(colors) do
    if type(v) == "number" then
        local blitString = colors.toBlit(v)
        icolor[blitString] = blitString
    end
end

local pattern = "\\."
local _, my = term.getSize()

local function out(str, bg, newLine)
    local _,y = term.getCursorPos()
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
            term.scroll(1)
            term.setCursorPos(1, y)
        else
            term.setCursorPos(1, y+1)
        end
    end
end

return out