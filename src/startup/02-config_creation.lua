-- 02-config_creation.lua
-- Ensures the startup configuration file exists.
-- Does not interpret or modify its contents.

local path = "config/startup.cfg"

if fs.exists(path) then
    if fs.isDir(path) then
        error(("Expected '%s' to be a file, but it is a directory."):format(path))
    end
    return
end

local file, err = fs.open(path, "w")
if not file then
    error(("Could not create '%s': %s"):format(path, err or "unknown error"))
end

file.write(textutils.serialize({}))
file.close()