-- =========================
-- Paging-enabled CC Launcher
-- =========================

---@class App
---@field name string
---@field path string

---@class Button
---@field app App
---@field x number
---@field y number
---@field w number
---@field h number

local APP_DIR = "apps"
local SELF_NAME = "app_launcher.lua"

local apps = {}
local buttons = {}

-- =========================
-- Paging state
-- =========================

local page = 1
local cols = 3
local rows = 3
local perPage = cols * rows

-- =========================
-- Utility
-- =========================

local function clamp(v, min, max)
    return math.max(min, math.min(max, v))
end

local function center(w, text)
    return math.floor((w - #text) / 2)
end

local function stripLua(name)
    return (name:gsub("%.lua$", ""))
end

-- =========================
-- Load apps
-- =========================

local function loadApps()
    local files = fs.list(APP_DIR)
    local result = {}

    for _, file in ipairs(files) do
        if not fs.isDir(fs.combine(APP_DIR, file)) then
            if file ~= SELF_NAME then
                table.insert(result, {
                    name = stripLua(file):gsub("_", " "),
                    path = fs.combine(APP_DIR, file)
                })
            end
        end
    end

    table.sort(result, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    return result
end

-- =========================
-- Layout engine (PAGED)
-- =========================

local function layout()
    buttons = {}

    local sw, sh = term.getSize()

    local winW = math.floor(sw * 0.8)
    local winH = math.floor(sh * 0.8)
    local winX = center(sw, "") + 1
    local winY = center(sh, "") + 1

    winX = math.floor((sw - winW) / 2)
    winY = math.floor((sh - winH) / 2)

    local pad = 2

    local cellW = math.floor((winW - (pad * (cols + 1))) / cols)
    local cellH = 5

    local start = (page - 1) * perPage + 1
    local finish = math.min(#apps, page * perPage)

    local index = 0

    for i = start, finish do
        local app = apps[i]
        index = index + 1

        local col = (index - 1) % cols
        local row = math.floor((index - 1) / cols)

        local x = winX + pad + col * (cellW + pad)
        local y = winY + 3 + row * (cellH + pad)

        table.insert(buttons, {
            app = app,
            x = x,
            y = y,
            w = cellW,
            h = cellH
        })
    end

    local maxPage = math.max(1, math.ceil(#apps / perPage))
    page = clamp(page, 1, maxPage)

    return winX, winY, winW, winH, maxPage
end

-- =========================
-- Rendering
-- =========================

local function drawBox(x, y, w, h, bg)
    term.setBackgroundColor(bg)

    for dy = 0, h - 1 do
        term.setCursorPos(x, y + dy)
        write(string.rep(" ", w))
    end
end

local function drawButton(btn, hovered)
    local bg = hovered and colors.gray or colors.lightGray
    local fg = hovered and colors.white or colors.black

    drawBox(btn.x, btn.y, btn.w, btn.h, bg)

    term.setTextColor(fg)

    local label = btn.app.name
    if #label > btn.w - 2 then
        label = label:sub(1, btn.w - 5) .. "..."
    end

    local lx = btn.x + math.floor((btn.w - #label) / 2)
    local ly = btn.y + math.floor(btn.h / 2)

    term.setCursorPos(lx, ly)
    write(label)
end

local function draw(mx, my)
    term.setBackgroundColor(colors.black)
    term.clear()

    local sw, sh = term.getSize()
    local winX, winY, winW, winH, maxPage = layout()

    drawBox(winX, winY, winW, winH, colors.black)

    term.setTextColor(colors.white)
    term.setCursorPos(winX + 2, winY + 1)
    write("App Launcher")

    term.setCursorPos(winX + winW - 20, winY + 1)
    write("Page " .. page .. "/" .. maxPage)

    for _, btn in ipairs(buttons) do
        local hovered =
            mx and my and
            mx >= btn.x and mx < btn.x + btn.w and
            my >= btn.y and my < btn.y + btn.h

        drawButton(btn, hovered)
    end

    term.setTextColour(colors.white)
end

-- =========================
-- Interaction
-- =========================

local function getButtonAt(x, y)
    for _, btn in ipairs(buttons) do
        if x >= btn.x and x < btn.x + btn.w and
            y >= btn.y and y < btn.y + btn.h then
            return btn
        end
    end
end

local function clearScreen()
    term.setBackgroundColor(colors.black)
    term.setTextColour(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
end

local function launch(btn)
    clearScreen()

    print("Launching: " .. btn.app.name .. "...\n")

    shell.run(btn.app.path)

    clearScreen()

    print("App finished.")
    print("Returning to launcher...")
    print("\nPress any key to continue")

    os.pullEvent("key")
end

-- =========================
-- Main loop
-- =========================

apps = loadApps()

local mx, my = nil, nil

while true do
    draw(mx, my)

    local event, a, b, c = os.pullEvent()

    if event == "mouse_click" then
        local btn = getButtonAt(b, c)
        if btn then
            launch(btn)
        end
    elseif event == "monitor_touch" then
        local btn = getButtonAt(b, c)
        if btn then
            launch(btn)
        end
    elseif event == "key" then
        if a == keys.q then
            clearScreen()
            sleep()
            return
        elseif a == keys.left then
            page = math.max(1, page - 1)
        elseif a == keys.right then
            local maxPage = math.max(1, math.ceil(#apps / perPage))
            page = math.min(maxPage, page + 1)
        end
    end
end
