return {
    runtime = "cli",

    generator = function(name)
        return [[
-- ]] .. name .. [[ (cli tool)

local cli = dofile("lib/cli.lua")
local ledger = dofile("lib/ledger.lua")

local app = cli.new("]] .. name .. [[", {
    description = "TODO: describe this tool",
    flags = {
        i = "example flag i",
        t = "example flag t"
    }
})

if not app:parse({ ... }) then
    return
end

ledger.write("Running " .. app.name)

local target = app:target()

-- =========================
-- Main logic
-- =========================

if app:has("i") then
    ledger.write("Inventory mode enabled")
end

if target then
    ledger.write("Target: " .. target)
end

ledger.write("Done")
]]
    end
}
