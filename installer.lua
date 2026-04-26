-- installer.lua (boot-aware materializer)

local repoUser = "manaphoenix"
local repoName = "CC-Code"
local branch = "main"

local targets = {
    "startup",
    "lib",
    "themes",
    "apps"
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
        print("* Failed: " .. path)
        return false
    end

    writeFile(path, content)
    print(">> " .. path)
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
        print("* Folder fetch failed: " .. apiPath)
        return
    end

    local ok, data = pcall(textutils.unserializeJSON, raw)
    if not ok or type(data) ~= "table" then
        print("* Bad JSON: " .. apiPath)
        return
    end

    for _, item in ipairs(data) do
        if item.type == "file" then
            downloadFile(item.download_url, item.path)
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
print("Installing system...\n")

for _, path in ipairs(targets) do
    fetchGithubDir(path, path)
end

print("\nDone.")
