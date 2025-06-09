-- Load configuration file
local function loadConfig()
    if not fs.exists("config/startup.cfg") then return nil end

    local file = fs.open("config/startup.cfg", "r")
    if not file then return nil end

    local content = file.readAll()
    file.close()

    if not content or content == "" then return nil end

    local data = textutils.unserialize(content)
    return type(data) == "table" and data or nil
end

-- Clear the tmp folder if it exists
local function clearTmpFolder()
    if not fs.exists("tmp") then return end

    for _, name in ipairs(fs.list("tmp")) do
        fs.delete(fs.combine("tmp", name))
    end
end

-- Main
local config = loadConfig()
if config and config.clearTmp then
    clearTmpFolder()
end
