-- 01-config_creation.lua

local path = "config/startup.cfg"

-- Ensure config file exists (no interpretation, no state, no merging)
if not fs.exists(path) then
    local file = fs.open(path, "w")
    file.write("{}")
    file.close()
end
