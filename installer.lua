-- installer.lua
local repoUser = "manaphoenix"
local repoName = "CC-Code"
local branch = "main"

local targets = {
    "startup",               -- all files in startup/
    "lib/theme_manager.lua", -- specific lib file
    "themes/default.lua"     -- specific theme file
}

local function ensureFolder(path)
    if not fs.exists(path) then fs.makeDir(path) end
end

local function downloadFile(url, path)
    local resp = http.get(url)
    if not resp then
        print("Failed: " .. url)
        return
    end
    local content = resp.readAll()
    resp.close()
    local dir = fs.getDir(path)
    if dir ~= "" then ensureFolder(dir) end
    local file = fs.open(path, "w")
    file.write(content)
    file.close()
end

local function downloadGitHubFolder(apiPath, localPath)
    local url = string.format(
        "https://api.github.com/repos/%s/%s/contents/%s?ref=%s",
        repoUser, repoName, apiPath, branch
    )
    local resp = http.get(url)
    if not resp then
        print("Failed to fetch folder: " .. apiPath)
        return
    end
    local ok, data = pcall(textutils.unserializeJSON, resp.readAll())
    resp.close()
    if not ok then
        print("Failed to parse API response: " .. apiPath)
        return
    end

    for _, item in ipairs(data) do
        if item.type == "file" then
            local targetPath = item.path
            print("Downloading: " .. targetPath)
            downloadFile(item.download_url, targetPath)
        elseif item.type == "dir" then
            downloadGitHubFolder(item.path, item.path)
        end
    end
end

-- === Main Installer ===
term.clear()
term.setCursorPos(1, 1)
print("Installing CC-Code startup files...\n")

for _, path in ipairs(targets) do
    if path:sub(-1) == "/" or fs.isDir(path) or path == "startup" then
        downloadGitHubFolder(path, path)
    else
        local url = string.format(
            "https://raw.githubusercontent.com/%s/%s/%s/%s",
            repoUser, repoName, branch, path
        )
        print("Downloading: " .. path)
        downloadFile(url, path)
    end
end

print("\nInstallation complete!")
