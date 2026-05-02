-- app/newapp/util.lua

local util = {}

function util.slugify(str)
    str = string.lower(str)
    str = str:gsub("%s+", "-")
    str = str:gsub("[^%w%-_]", "")
    return str
end

function util.join(lines)
    return table.concat(lines, "\n")
end

return util
