-- stubinstaller.lua

-- Check if HTTP is enabled
if not http then
    print("HTTP is not enabled. Please enable HTTP in your ComputerCraft settings.")
    return
end

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

-- Function to check if a file exists
local function fileExists(path)
    return fs.exists(path) and not fs.isDir(path)
end

-- Function to install or update the required files
local function installFiles()
    -- Ensure the directories exist
    ensureDirectoryExists(installPaths.createStub)
    ensureDirectoryExists(installPaths.stubConfig)
    ensureDirectoryExists(installPaths.parallelAction)

    -- Download or update each file
    for _, path in pairs(installPaths) do
        if fileExists(path) then
            print(path .. " already exists, deleting and reinstalling...")
            fs.delete(path)  -- Delete the file to ensure the latest version
        end
        local url = githubRepo .. path
        downloadFile(url, path)
    end

    print("Installation complete! You can now run the stub creator.")
end

-- Function to move or delete the installer after use
local function cleanupInstaller()
    local installerPath = "stubinstaller.lua"
    local backupPath = "installers/stubinstaller.lua"

    if fs.exists(installerPath) then
        -- Optionally, move the installer to a backup folder
        if not fs.exists("installers") then
            fs.makeDir("installers")
        end
        fs.move(installerPath, backupPath)
        print("Installer moved to 'installers/stubinstaller.lua' for later use.")
    else
        print("Installer file not found for cleanup.")
    end
end

-- Run the installation process
installFiles()

-- Cleanup installer
cleanupInstaller()
