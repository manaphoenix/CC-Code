-- installer.lua (v4)

local repoUser = "manaphoenix"
local repoName = "CC-Code"
local branch = "main"

local baseRaw = ("https://raw.githubusercontent.com/%s/%s/%s/"):format(
    repoUser,
    repoName,
    branch
)

-- Character-chart symbols:
-- \x1E = upward marker, \x1F = downward marker
local symbols = {
    Success = "\x1E",
    Failure = "\x1F",
}

-- =========================
-- Utilities
-- =========================

local function ensureDir(path)
    if path == "" then
        return true
    end

    if fs.exists(path) then
        if not fs.isDir(path) then
            return false, ("'%s' exists but is not a directory"):format(path)
        end
        return true
    end

    local ok, err = pcall(fs.makeDir, path)
    if not ok then
        return false, err
    end

    return true
end

local function writeFile(path, content)
    local directoryOk, directoryErr = ensureDir(fs.getDir(path))
    if not directoryOk then
        return false, directoryErr
    end

    local file, err = fs.open(path, "w")
    if not file then
        return false, err or "could not open file for writing"
    end

    file.write(content)
    file.close()

    return true
end

local function get(url)
    local response, err = http.get(url, {
        ["User-Agent"] = "CC-Tweaked Installer",
    })

    if not response then
        return nil, err or "request failed"
    end

    local content = response.readAll()
    response.close()

    return content
end

local function download(src, dest)
    local content, downloadErr = get(baseRaw .. src)

    if not content then
        print(("%s Failed to download %s: %s"):format(
            symbols.Failure,
            src,
            downloadErr
        ))
        return false
    end

    local written, writeErr = writeFile(dest, content)
    if not written then
        print(("%s Failed to write %s: %s"):format(
            symbols.Failure,
            dest,
            writeErr
        ))
        return false
    end

    print(("%s %s"):format(symbols.Success, dest))
    return true
end

-- =========================
-- Core installer
-- =========================

local function installMap(map)
    local succeeded = 0
    local failed = 0

    for _, entry in ipairs(map) do
        if download(entry.src, entry.dest) then
            succeeded = succeeded + 1
        else
            failed = failed + 1
        end
    end

    return succeeded, failed
end

-- =========================
-- Install profile
-- =========================

local installProfile = {
    -- Startup system
    { src = "src/startup/01-folder_creation.lua", dest = "startup/01-folder_creation.lua" },
    { src = "src/startup/02-config_creation.lua", dest = "startup/02-config_creation.lua" },
    { src = "src/startup/03-set_color_theme.lua", dest = "startup/03-set_color_theme.lua" },
    { src = "src/startup/04-set_aliases.lua", dest = "startup/04-set_aliases.lua" },
    { src = "src/startup/05-setup_term.lua", dest = "startup/05-setup_term.lua" },

    -- Libraries
    { src = "src/lib/blit-util.lua", dest = "lib/core/blit-util.lua" },
    { src = "src/lib/ledger.lua", dest = "lib/core/ledger.lua" },
    { src = "src/lib/theme-manager.lua", dest = "lib/core/theme-manager.lua" },
    { src = "src/lib/unit-testing.lua", dest = "lib/core/unit-testing.lua" },
    { src = "src/lib/parallel-actions.lua", dest = "lib/core/parallel-actions.lua" },
    { src = "src/lib/simple-button.lua", dest = "lib/core/simple-button.lua" },

    -- Built-in apps
    { src = "src/apps/launcher.lua", dest = "apps/system/launcher.lua" },
    { src = "src/apps/theme-picker.lua", dest = "apps/system/theme-picker.lua" },

    -- Themes
    { src = "src/themes/default.lua", dest = "themes/default.lua" },
    { src = "src/themes/cyberdream.lua", dest = "themes/cyberdream.lua" },
    { src = "src/themes/2077.lua", dest = "themes/2077.lua" },
}

-- =========================
-- Main
-- =========================

term.clear()
term.setCursorPos(1, 1)

print("Ashgard Installer v4")
print("--------------------\n")

local succeeded, failed = installMap(installProfile)

print(("\nInstalled: %d | Failed: %d"):format(succeeded, failed))

if failed == 0 then
    print(symbols.Success .. " Installation complete.")
else
    print(symbols.Failure .. " Installation completed with errors.")
end