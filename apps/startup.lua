-- Default config
local defaultConfig = {
    clearTmp = true
}

-- Ensure folder exists
local function ensureDir(path)
    if not fs.exists(path) then fs.makeDir(path) end
end

-- Load or create config
local function loadConfig()
    ensureDir("config")
    local path = "config/startup.cfg"

    if fs.exists(path) then
        local file = fs.open(path, "r")
        local data = file.readAll()
        file.close()

        local result = textutils.unserialize(data)
        if type(result) == "table" then
            return result
        else
            return defaultConfig
        end
    else
        local file = fs.open(path, "w")
        file.write(textutils.serialize(defaultConfig))
        file.close()
        return defaultConfig
    end
end

-- Create folder structure
local function createFolders()
    local folders = {
        "config", "data", "installers", "lib",
        "logs", "tmp", "assets", "apps", "startup"
    }
    for _, folder in ipairs(folders) do
        ensureDir(folder)
    end
end

-- Main
local config = loadConfig()
createFolders()
