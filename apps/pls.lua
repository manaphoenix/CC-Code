local args = { ... }

term.clear()
term.setCursorPos(1, 1)

local mx, my = term.getSize()

-- Parse flags
local side
local flags = {
    tanks = false,
    inventory = false,
}

for _, a in ipairs(args) do
    if a:sub(1, 1) == "-" then
        -- Handle combined flags like -it
        for i = 2, #a do
            local f = a:sub(i, i)
            if f == "t" then
                flags.tanks = true
            elseif f == "i" then
                flags.inventory = true
            else
                error("Unknown flag: -" .. f, 0)
            end
        end
    else
        -- Non-flag argument = side
        side = a
    end
end

local function separator()
    print(("="):rep(mx))
end

local function fmtNumber(n)
    local s = tostring(math.floor(n))
    local sign, int = s:match("^([+-]?)(%d+)$")
    if not int then return s end

    return sign .. int:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end


local function fmtFluid(mb)
    if not mb then return "0 mB" end
    local buckets = mb / 1000
    return ("%s mB (%.2f B)"):format(fmtNumber(mb), buckets)
end

-- No side provided: show available peripherals
if not side then
    print("pls - peripheral listing tool")
    print("Usage: pls [side] [-ti]")
    print("")
    print("  -t: list tanks")
    print("  -i: list inventory")
    print("")
    print("Available peripherals:")
    separator()

    local found = false
    for _, s in ipairs(peripheral.getNames()) do
        local types = { peripheral.getType(s) }
        print(("- %s (%s)"):format(s, table.concat(types, ", ")))
        found = true
    end

    if not found then
        print("None found.")
    end

    return
end



-- Side provided: inspect it
if not peripheral.isPresent(side) then
    error("No peripheral found on side: " .. side, 0)
end

local methods = {}
for _, m in ipairs(peripheral.getMethods(side)) do
    methods[m] = true
end

local perType = { peripheral.getType(side) }
print(("Peripheral - %s"):format(table.concat(perType, ", ")))
separator()

if not flags.tanks and not flags.inventory then
    -- Print methods
    print("")
    print("Methods (callable)")
    separator()
    for m in pairs(methods) do
        print(" - " .. m .. "()")
    end
end

-- Tank listing (-t)
if flags.tanks then
    print("")
    print("Tanks")
    separator()

    local tankMethod =
        methods.tanks and "tanks"
        or methods.getTanks and "getTanks"

    if not tankMethod then
        print("Peripheral has no tank support.")
    else
        local tanks = peripheral.call(side, tankMethod)
        if #tanks == 0 then
            print("No tanks found.")
        else
            for i, t in ipairs(tanks) do
                print(("- Tank %d:"):format(i))
                print(("  Name: %s"):format(t.name or "unknown"))
                print(("  Amount: %s"):format(fmtFluid(t.amount or 0)))
            end
        end
    end
end

-- Inventory listing (-i)
if flags.inventory then
    print("")
    print("Inventory")
    separator()

    if not methods.list then
        print("Peripheral is not inventory-capable.")
    else
        local items = peripheral.call(side, "list")
        local cx, cy = term.getCursorPos()
        local line = cy

        local remainingSpace = my - cy

        local count = 0
        for _, _ in pairs(items) do
            count = count + 1
        end

        if count > 0 then
            local fmtString = "- Slot %d: %s x%d"
            for slot, item in pairs(items) do
                print(fmtString:format(
                    slot,
                    item.name,
                    item.count
                ))

                line = line + 1
                if line >= my - 1 then
                    print("... (screen limit reached)")
                    break
                end
            end
        else
            print("Inventory is empty!")
        end
    end
end
