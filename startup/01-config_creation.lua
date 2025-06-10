local config = {
    clearTmp = true
}

local path = "config/startup.cfg"

if fs.exists(path) then
    config = textutils.unserialize(fs.open(path, "r").readAll())
else
    fs.open(path, "w").write(textutils.serialize(config))
end
