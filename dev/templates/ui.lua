return {
    runtime = "app",

    generator = function(name)
        return [[
-- ]] .. name .. [[ (ui app)

local input = dofile("lib/input.lua")
local ledger = dofile("lib/ledger.lua")

local running = true

-- =========================
-- State
-- =========================

local state = {}
local buttons = {}

-- =========================
-- UI helpers
-- =========================

local function addButton(label, x, y, w, h, action)
    buttons[#buttons + 1] = {
        label = label,
        x = x,
        y = y,
        w = w,
        h = h,
        action = action
    }
end

local function isInside(btn, x, y)
    return x >= btn.x and x < btn.x + btn.w and
           y >= btn.y and y < btn.y + btn.h
end

-- =========================
-- Layout
-- =========================

local function layout()
    buttons = {}

    local w, h = term.getSize()

    addButton(
        "Exit",
        math.floor(w / 2) - 2,
        math.floor(h / 2),
        4,
        1,
        function()
            running = false
        end
    )
end

-- =========================
-- Rendering
-- =========================

local function draw()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)

    print("]] .. name .. [[ UI")
    print("")
    print("Press Q to quit")

    for _, btn in ipairs(buttons) do
        term.setCursorPos(btn.x, btn.y)
        term.write(btn.label)
    end
end

-- =========================
-- Input handling
-- =========================

local function handle(event)
    if event.type == "key" and event.key == keys.q then
        running = false
        return
    end

    if event.type == "click" then
        for _, btn in ipairs(buttons) do
            if isInside(btn, event.x, event.y) then
                if btn.action then btn.action() end
                return
            end
        end
    end
end

-- =========================
-- Lifecycle
-- =========================

ledger.write("Starting ]] .. name .. [[ UI")

layout()

while running do
    draw()

    local event = input.pull()
    handle(event)
end

ledger.write("Exited ]] .. name .. [[ UI")
]]
    end
}
