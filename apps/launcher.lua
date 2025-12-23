-- ComputerCraft Program Launcher (Refactored)
-- Single-player, disk-edited, CC:Tweaked-friendly

local term, fs, shell, colors, keys =
    term, fs, shell, colors, keys

-- ======================
-- Configuration
-- ======================
local CONFIG = {
    searchPaths = { "/apps" },
    extensions = { ".lua", ".out" },
    showHidden = false,
}

-- ======================
-- UI Theme
-- ======================
local UI = {
    bg       = colors.black,
    fg       = colors.white,
    selected = colors.blue,
    border   = colors.gray,
    title    = colors.yellow,
    success  = colors.green,
    error    = colors.red,
    dim      = colors.lightGray,
}

-- ======================
-- State
-- ======================
local state = {
    apps     = {},
    filtered = {},
    search   = "",
    selected = 1,
    page     = 1,
}

-- ======================
-- Utilities
-- ======================
local function hasExt(name)
    for _, ext in ipairs(CONFIG.extensions) do
        if name:sub(- #ext) == ext then
            return true
        end
    end
end

local function isHidden(name)
    return name:sub(1, 1) == "."
end

local function termSize()
    return term.getSize()
end

local function clear()
    term.setBackgroundColor(UI.bg)
    term.setTextColor(UI.fg)
    term.clear()
    term.setCursorPos(1, 1)
end

local function writeAt(x, y, text, fg, bg)
    if fg then term.setTextColor(fg) end
    if bg then term.setBackgroundColor(bg) end
    term.setCursorPos(x, y)
    term.write(text)
end

-- ======================
-- App Discovery
-- ======================
local function discover()
    state.apps = {}

    for _, root in ipairs(CONFIG.searchPaths) do
        if fs.exists(root) and fs.isDir(root) then
            for _, name in ipairs(fs.list(root)) do
                if not (isHidden(name) and not CONFIG.showHidden) then
                    local full = fs.combine(root, name)

                    if fs.isDir(full) then
                        local entry, entryType

                        if fs.exists(fs.combine(full, "startup")) then
                            entry = fs.combine(full, "startup")
                            entryType = "startup"
                        else
                            for _, main in ipairs({ "main.lua", "init.lua" }) do
                                local p = fs.combine(full, main)
                                if fs.exists(p) then
                                    entry = p
                                    entryType = main
                                    break
                                end
                            end
                        end

                        table.insert(state.apps, {
                            name      = name,
                            display   = name,
                            path      = entry,
                            isDir     = true,
                            entryType = entryType,
                        })
                    elseif hasExt(name) then
                        table.insert(state.apps, {
                            name    = name,
                            display = name:gsub("%.lua$", ""):gsub("%.out$", ""),
                            path    = full,
                            isDir   = false,
                        })
                    end
                end
            end
        end
    end

    table.sort(state.apps, function(a, b)
        return a.display:lower() < b.display:lower()
    end)

    state.filtered = state.apps
    state.selected = 1
    state.page = 1
end

-- ======================
-- Filtering
-- ======================
local function applyFilter()
    if state.search == "" then
        state.filtered = state.apps
    else
        local s = state.search:lower()
        state.filtered = {}
        for _, app in ipairs(state.apps) do
            if app.display:lower():find(s, 1, true) then
                table.insert(state.filtered, app)
            end
        end
    end
    state.selected = 1
    state.page = 1
end

-- ======================
-- Layout Metrics
-- ======================
local function layout()
    local w, h = termSize()
    local listTop = 5
    local listHeight = h - listTop - 3
    return w, h, listTop, listHeight
end

-- ======================
-- Drawing
-- ======================
local function drawTitle(w)
    local title = "=== ComputerCraft Launcher ==="
    writeAt(math.floor((w - #title) / 2) + 1, 1, title, UI.title)
end

local function drawSearch(w)
    writeAt(1, 3, "Search: " .. state.search)
    writeAt(1 + 8 + #state.search, 3, string.rep(" ", w))
end

local function drawList()
    local w, h, top, height = layout()
    local pageSize = height
    local start = (state.page - 1) * pageSize + 1
    local finish = math.min(start + pageSize - 1, #state.filtered)

    for i = start, finish do
        local y = top + (i - start)
        local app = state.filtered[i]
        local selected = (i == state.selected)

        local label = app.display
        if app.isDir then
            label = label .. (app.entryType and " [DIR]" or " [DIR*]")
        end

        term.setCursorPos(2, y)
        term.setBackgroundColor(selected and UI.selected or UI.bg)
        term.write((selected and "\26\128 " or "  ") .. label)
        term.write(string.rep(" ", w - #label - 4))
    end

    term.setBackgroundColor(UI.bg)
end

local function drawStatus(w, h)
    writeAt(1, h - 1, string.rep("\140", w), UI.border)

    local pages = math.max(1, math.ceil(#state.filtered / (h - 8)))
    local msg = string.format(
        "Page %d/%d | %d items | \24\25 Move | Enter Run | S Search | R Refresh | Q Quit",
        state.page, pages, #state.filtered
    )

    writeAt(math.floor((w - #msg) / 2) + 1, h, msg)
end

local function render()
    clear()
    local w, h = termSize()
    drawTitle(w)
    drawSearch(w)
    drawList()
    drawStatus(w, h)
end

-- ======================
-- Execution
-- ======================
local function run(app)
    clear()
    writeAt(1, 1, "Running: " .. app.display, UI.success)
    writeAt(1, 3, "Path: " .. (app.path or "<none>"))

    os.pullEvent("key")
    clear()

    if app.path and fs.exists(app.path) then
        shell.run(app.path)
    else
        writeAt(1, 1, "Error: No runnable entrypoint", UI.error)
        os.pullEvent("key")
    end

    discover()
end

-- ======================
-- Input
-- ======================
local function handleKey()
    if #state.filtered == 0 then
        os.pullEvent("key")
        return true
    end

    local _, key = os.pullEvent("key")
    local _, _, _, height = layout()
    local pageSize = height

    if key == keys.q or key == keys.escape then
        return false
    elseif key == keys.up then
        state.selected = math.max(1, state.selected - 1)
    elseif key == keys.down then
        state.selected = math.min(#state.filtered, state.selected + 1)
    elseif key == keys.left then
        state.page = math.max(1, state.page - 1)
        state.selected = (state.page - 1) * pageSize + 1
    elseif key == keys.right then
        state.page = math.min(
            math.ceil(#state.filtered / pageSize),
            state.page + 1
        )
        state.selected = (state.page - 1) * pageSize + 1
    elseif key == keys.enter then
        run(state.filtered[state.selected])
    elseif key == keys.r then
        discover()
    elseif key == keys.s then
        local original = state.search
        state.search = ""

        while true do
            render()
            term.setCursorPos(9 + #state.search, 3)

            local e, p = os.pullEventRaw()

            if e == "char" then
                state.search = state.search .. p
                applyFilter()
            elseif e == "key" then
                if p == keys.backspace then
                    state.search = state.search:sub(1, -2)
                    applyFilter()
                elseif p == keys.enter then
                    -- Accept search
                    break
                elseif p == keys.q then
                    -- Explicit quit shortcut
                    state.search = original
                    applyFilter()
                    break
                end
            end
        end
    end

    state.page = math.ceil(state.selected / pageSize)
    return true
end

-- ======================
-- Main
-- ======================
local function main()
    discover()
    while true do
        render()
        if not handleKey() then break end
    end
    clear()
end

pcall(main)
