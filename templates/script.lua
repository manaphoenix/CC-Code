return {
    runtime = "script",

    generator = function(name)
        return [[
-- ]] .. name .. [[ (script)

local ledger = dofile("lib/ledger.lua")

local function waitForKey()
    term.setTextColor(colors.gray)
    print("\nPress any key to exit...")
    term.setTextColor(colors.white)
    os.pullEvent("key")
end

ledger.write("Running ]] .. name .. [[")

-- =========================
-- Main logic
-- =========================

-- TODO: implement script logic here

ledger.write("Done")

waitForKey()
]]
    end
}
