return function(name)
return [[
-- ]] .. name .. [[ (ui app)

local input = dofile("lib/input.lua")
local ledger = dofile("lib/ledger.lua")

local running = true

-- =========================
-- State
-- =========================

local state = {}

-- Example UI button structure
local buttons = {}

-- =========================
-- Layout (placeholder)
-- =========================

local function layout()
    buttons = {}

    local w, h = term.getSize()

    -- simple center button example
    table.insert(buttons, {
        label = "Exit",
        x = math.floor(w / 2) - 2,
        y = math.floor(h / 2),
        w = 4,
        h = 1,
        action = function()
            running = false
        end
    })
end

-- =========================
-- Rendering
-- =========================

local function draw()
    term.clear()
    term.setCursorPos(1,1)

    print("]] .. name .. [[ UI")
    print("")
    print("Click 'Exit' or press Q")
end

-- =========================
-- Input handling
-- =========================

local function handle(event, a, b, c)
    -- keyboard quit
    if event == "key" and a == keys.q then
        running = false
        return
    end

    -- mouse interaction
    if event == "mouse_click" then
        local mx, my = b, c

        for _, btn in ipairs(buttons) do
            if mx >= btn.x and mx < btn.x + btn.w and
               my >= btn.y and my < btn.y + btn.h then
                if btn.action then btn.action() end
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

    local event, a, b, c = input.pull()
    handle(event, a, b, c)
end

ledger.write("Exited ]] .. name .. [[ UI")
]]
end