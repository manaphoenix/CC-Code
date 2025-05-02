-- stubinstaller.lua

local githubRepo = "https://raw.githubusercontent.com/manaphoenix/CC_OC-Code/main/"

-- Paths to download files to
local installPaths = {
    createStub = "createStub.lua",
    stubConfig = "config/stubConfig.lua",
    parallelAction = "lib/parallelAction.lua",
}

-- Function to download a file from the GitHub repo
local function downloadFile(url, path)
    local file = fs.open(path, "w")
    local response = http.get(url)
    
    if response then
        file.write(response.readAll())
        file.close()
        print("Successfully downloaded: " .. path)
    else
        print("Failed to download: " .. path)
    end
end

-- Function to ensure the directory exists
local function ensureDirectoryExists(path)
    local dir = path:match("(.+)/") -- Extract the directory part of the path
    if dir and not fs.exists(dir) then
        fs.makeDir(dir)
        print("Created directory: " .. dir)
    end
end

-- Function to install the required files
local function installFiles()
    -- Ensure the directories exist
    ensureDirectoryExists(installPaths.createStub)
    ensureDirectoryExists(installPaths.stubConfig)
    ensureDirectoryExists(installPaths.parallelAction)

    -- Download each file
    downloadFile(githubRepo .. "apps/stubcreator/createStub.lua", installPaths.createStub)
    downloadFile(githubRepo .. "apps/stubcreator/stubConfig.lua", installPaths.stubConfig)
    downloadFile(githubRepo .. "lib/parallelAction.lua", installPaths.parallelAction)

    print("Installation complete! You can now run the stub creator.")
end

-- Run the installation process
installFiles()
