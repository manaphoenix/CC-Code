-- installer.lua (strict targeting)

local repoUser = "manaphoenix"
local repoName = "CC-Code"
local branch = "main"

local baseRaw = ("https://raw.githubusercontent.com/%s/%s/%s/"):format(repoUser, repoName, branch)
local baseApi = ("https://api.github.com/repos/%s/%s/contents/"):format(repoUser, repoName)

-- =====================
-- FS utilities
-- =====================

local function ensureDir(path)
    if path == "" then return end

    local parts = {}
    for part in string.gmatch(path, "[^/]+") do
        table.insert(parts, part)
    end

    local current = ""
    for i = 1, #parts - 1 do
        current = current .. parts[i] .. "/"
        if not fs.exists(current) then
            fs.makeDir(current)
        end
    end
end

local function writeFile(path, content)
    ensureDir(fs.getDir(path))
    local f = fs.open(path, "w")
    f.write(content)
    f.close()
end

-- =====================
-- Network
-- =====================

local function get(url)
    local r = http.get(url, {
        ["User-Agent"] = "CC-Tweaked Installer"
    })

    if not r then return nil end
    local data = r.readAll()
    r.close()
    return data
end

local function downloadFile(url, path)
    local content = get(url)
    if not content then
        print("\x13 Failed: " .. path)
        return false
    end

    writeFile(path, content)
    print("\xBB " .. path)
    return true
end

-- =====================
-- Directory fetch (ONLY when requested)
-- =====================

local function fetchDir(apiPath, localPath)
    local url = baseApi .. apiPath .. "?ref=" .. branch
    local raw = get(url)

    if not raw then
        print("\x13 Folder fetch failed: " .. apiPath)
        return
    end

    local data = textutils.unserializeJSON(raw)
    if type(data) ~= "table" then
        print("\x13 Bad JSON: " .. apiPath)
        return
    end

    for _, item in ipairs(data) do
        local targetPath = item.path

        if item.type == "file" then
            downloadFile(item.download_url, targetPath)
        elseif item.type == "dir" then
            fetchDir(item.path, item.path)
        end
    end
end

-- =====================
-- Target resolver (STRICT)
-- =====================

local function installTarget(path)
    -- DIRECTORY MODE (only if explicitly marked)
    if path:sub(-1) == "/" then
        fetchDir(path, path)
        return
    end

    -- FILE MODE (default)
    local url = baseRaw .. path
    downloadFile(url, path)
end

-- =====================
-- Main
-- =====================

term.clear()
term.setCursorPos(1, 1)
print("Installing CC-Code...\n")

local targets = {
    "startup/",
    "lib/theme_manager.lua",
    "lib/ledger.lua",
    "lib/resolver.lua",
    "themes/" -- explicit directory
}

for _, path in ipairs(targets) do
    installTarget(path)
end

print("\nDone.")
