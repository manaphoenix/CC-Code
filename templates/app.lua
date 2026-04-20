return function(name)
return [[
-- ]] .. name .. [[ (app)

local input = dofile("lib/input.lua")
local ledger = dofile("lib/ledger.lua")

local running = true

-- =========================
-- State
-- =========================

local state = {}

-- =========================
-- Render
-- =========================

local function draw()
    term.clear()
    term.setCursorPos(1,1)

    print("]] .. name .. [[")
    print("")
    print("[Q] Quit")
end

-- =========================
-- Event handling
-- =========================

local function handle(event, a, b, c)
    -- Quit logic lives here (NOT in input lib)
    if event == "key" and a == keys.q then
        running = false
        return
    end

    -- TODO: handle other events here
end

-- =========================
-- Lifecycle
-- =========================

ledger.write("Starting ]] .. name .. [[")

while running do
    draw()

    local event, a, b, c = input.pull()
    handle(event, a, b, c)
end

ledger.write("Exited ]] .. name .. [[")
]]
end