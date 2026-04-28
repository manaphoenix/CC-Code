-- apps/tools/theme_downloader.lua

-- Load ThemeManager safely
local ok, ThemeManager = pcall(dofile, "lib/theme_manager.lua")
if not ok then
    print("Error: ThemeManager library not found.")
    return
end

if not http then
    print("Error: HTTP API is not enabled.")
    return
end

-- Clear terminal and reset cursor
term.clear()
term.setCursorPos(1, 1)

print("=== Theme Downloader ===")
print("You can download a theme from a direct URL or from GitHub.\n")

-- Ask user for download type
print("Select download method:")
print("1) Direct URL")
print("2) GitHub folder")
local method = tonumber(read())

if method ~= 1 and method ~= 2 then
    print("Invalid selection, aborting.")
    return
end

if method == 1 then
    -- Direct URL download
    print("Enter the direct URL to the .lua theme file:")
    local url = read()
    print("Enter the local theme name to save as:")
    local themeName = read()
    if themeName == "" then
        print("Invalid name, aborting.")
        return
    end

    local ok, err = pcall(ThemeManager.downloadTheme, url, themeName)
    if ok then
        print("Theme '" .. themeName .. "' downloaded successfully!")
    else
        print("Failed to download theme: " .. tostring(err))
    end
elseif method == 2 then
    -- GitHub folder download
    print("Enter GitHub username/org:")
    local user = read()
    print("Enter repository name:")
    local repo = read()
    print("Enter folder path in repo (e.g., themes/):")
    local folder = read()

    local apiUrl = string.format(
        "https://api.github.com/repos/%s/%s/contents/%s",
        user, repo, folder
    )

    local resp = http.get(apiUrl)
    if not resp then
        print("Failed to fetch GitHub folder contents.")
        return
    end

    local body = resp.readAll()
    resp.close()

    local ok, files = pcall(textutils.unserializeJSON, body)
    if not ok then
        print("Failed to parse GitHub API response.")
        return
    end

    -- Filter for .lua files
    local luaFiles = {}
    for _, item in ipairs(files) do
        if item.type == "file" and item.name:match("%.lua$") then
            table.insert(luaFiles, item)
        end
    end

    if #luaFiles == 0 then
        print("No .lua theme files found in that folder.")
        return
    end

    -- Show list of available themes
    print("\nAvailable themes:")
    for i, f in ipairs(luaFiles) do
        print(i .. ") " .. f.name)
    end

    print("Enter the number of the theme to download (or 0 to cancel):")
    local choice = tonumber(read())
    if not choice or choice < 0 or choice > #luaFiles then
        print("Invalid choice, aborting.")
        return
    elseif choice == 0 then
        print("Cancelled.")
        return
    end

    local selected = luaFiles[choice]
    local themeName = selected.name:gsub("%.lua$", "")
    local rawUrl = selected.download_url

    local ok, err = pcall(ThemeManager.downloadTheme, rawUrl, themeName)
    if ok then
        print("Theme '" .. themeName .. "' downloaded successfully!")
    else
        print("Failed to download theme: " .. tostring(err))
    end
end

print("\nDownload complete. Themes are stored in the 'themes/' folder.")
