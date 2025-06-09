local config = {
    clearTmp = true
}

if fs.exists("config/startup.cfg") then
    config = textutils.unserialize(fs.open("config/startup.cfg", "r").readAll())
else
    fs.open("config/startup.cfg", "w").write(textutils.serialize(config))
end
