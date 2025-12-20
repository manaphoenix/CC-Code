-- lib/theme_manager.lua
local ThemeManager = {}

-- Path to store themes
ThemeManager.themePath = "themes"

-- Ensure theme folder exists
if not fs.exists(ThemeManager.themePath) then fs.makeDir(ThemeManager.themePath) end

-- Internal: safely load a theme
local function loadThemeFile(themeName)
    local filePath = fs.combine(ThemeManager.themePath, themeName .. ".lua")
    if not fs.exists(filePath) then return nil end
    local ok, theme = pcall(dofile, filePath)
    if not ok or type(theme) ~= "table" or not theme.colors then return nil end
    return theme
end

--- Apply a theme to a device
---@param device table Terminal or monitor
---@param themeName string Name of the theme
function ThemeManager.applyTheme(device, themeName)
    local theme = loadThemeFile(themeName)
    if not theme then
        print("Warning: Theme '" .. themeName .. "' not found. Skipping.")
        return
    end

    for name, color in pairs(theme.colors) do
        if colors[name] then
            device.setPaletteColor(colors[name], color)
        end
    end

    -- Reset cursor and clear screen
    device.clear()
    device.setCursorPos(1, 1)
end

--- List all installed themes
---@return table List of theme names
function ThemeManager.listThemes()
    local themes = {}
    if fs.exists(ThemeManager.themePath) then
        for _, file in ipairs(fs.list(ThemeManager.themePath)) do
            local name = file:match("^(.-)%.lua$")
            if name then table.insert(themes, name) end
        end
    end
    return themes
end

--- Get metadata of a theme
---@param themeName string Name of the theme
---@return table|nil Metadata table or nil if not found
function ThemeManager.getMetadata(themeName)
    local theme = loadThemeFile(themeName)
    return theme and theme.meta or nil
end

--- Download a theme from a URL
---@param url string URL to download
---@param themeName string Name to save locally
function ThemeManager.downloadTheme(url, themeName)
    if not http then error("HTTP is not enabled") end

    local response = http.get(url)
    if not response then error("Failed to fetch theme from URL") end

    local content = response.readAll()
    response.close()

    if not fs.exists(ThemeManager.themePath) then fs.makeDir(ThemeManager.themePath) end
    local file = fs.open(fs.combine(ThemeManager.themePath, themeName .. ".lua"), "w")
    file.write(content)
    file.close()
end

--- Download a theme directly from GitHub
---@param user string GitHub username or org
---@param repo string Repository name
---@param filePath string Path to theme file in repo (e.g., "themes/cyberdream.lua")
---@param themeName string Local name
---@param branch? string Branch (default: "main")
function ThemeManager.downloadGitHubTheme(user, repo, filePath, themeName, branch)
    branch = branch or "main"
    if not http then error("HTTP is not enabled") end

    local url = string.format(
        "https://raw.githubusercontent.com/%s/%s/%s/%s",
        user, repo, branch, filePath
    )

    ThemeManager.downloadTheme(url, themeName)
end

return ThemeManager
