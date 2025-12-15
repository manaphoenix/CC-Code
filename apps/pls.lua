local side = ...

term.clear()
term.setCursorPos(1, 1)

-- No side provided: show available peripherals
if not side then
    print("pls - peripheral listing tool")
    print("Usage: pls [side]")
    print("")
    print("Available peripherals:")
    print(("="):rep(22))

    local found = false
    for _, s in ipairs(peripheral.getNames()) do
        print(("- %s (%s)"):format(s, peripheral.getType(s)))
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

local perType = { peripheral.getType(side) }
print("Peripheral:", unpack(perType))
print(("="):rep(20))
print("Methods (callable)")
print(("="):rep(18))

for _, name in ipairs(peripheral.getMethods(side)) do
    print(" - " .. name .. "()")
end
