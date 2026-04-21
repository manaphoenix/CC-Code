-- installer.lua (refactored)

local repoUser = "manaphoenix"
local repoName = "CC-Code"
local branch = "main"

local targets = {
    "startup",
    "types",
    "templates",
    "lib/theme_manager.lua",
    "lib/ledger.lua",
    "lib/cli.lua",
    "lib/input.lua",
    "themes/default.lua",
    "apps/newapp.lua"
}

-- =====================
-- FS utilities
-- =====================

local function ensureDir(path)
    if path ~= "" and not fs.exists(path) then
        fs.makeDir(path)
    end
end

local function writeFile(path, content)
    ensureDir(fs.getDir(path))
    local f = fs.open(path, "w")
    f.write(content)
    f.close()
end

-- =====================
-- Network layer
-- =====================

local function get(url)
    local r = http.get(url)
    if not r then return nil end
    local data = r.readAll()
    r.close()
    return data
end

local function downloadFile(url, path)
    local content = get(url)
    if not content then
        print("\x2a Failed: " .. path)
        return false
    end

    writeFile(path, content)
    print("\xbb " .. path)
    return true
end

-- =====================
-- GitHub folder walker
-- =====================

local function fetchGithubDir(apiPath, localPath)
    local url = ("https://api.github.com/repos/%s/%s/contents/%s?ref=%s")
        :format(repoUser, repoName, apiPath, branch)

    local raw = get(url)
    if not raw then
        print("\x2a Folder fetch failed: " .. apiPath)
        return
    end

    local ok, data = pcall(textutils.unserializeJSON, raw)
    if not ok or type(data) ~= "table" then
        print("\x2a Bad JSON: " .. apiPath)
        return
    end

    for _, item in ipairs(data) do
        local targetPath = item.path

        if item.type == "file" then
            downloadFile(item.download_url, targetPath)

        elseif item.type == "dir" then
            fetchGithubDir(item.path, item.path)
        end
    end
end

-- =====================
-- Main installer
-- =====================

term.clear()
term.setCursorPos(1, 1)
print("Installing CC-Code...\n")

for _, path in ipairs(targets) do
    if fs.exists(path) or path:sub(-1) == "/" then
        fetchGithubDir(path, path)
    else
        local url = ("https://raw.githubusercontent.com/%s/%s/%s/%s")
            :format(repoUser, repoName, branch, path)

        downloadFile(url, path)
    end
end

print("\nDone.")