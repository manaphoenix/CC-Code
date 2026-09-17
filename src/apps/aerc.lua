-- == Libraries == --
local hash = require("lib.hash")

-- == Peripherals == --
local tokenInventory = assert(peripheral.wrap("sophisticatedstorage:barrel_15"), "Token Inventory not found")
local bufferInventory = assert(peripheral.wrap("sophisticatedstorage:barrel_14"), "Buffer Inventory not found")
local outputInventory = assert(peripheral.wrap("sophisticatedstorage:barrel_16"), "Output Inventory not found")
local provider = assert(peripheral.wrap("expandedae:exp_pattern_provider_2"), "Pattern Provider not found")
---@type ap.peripheral.StorageBridge
local bridge = assert(peripheral.find("me_bridge"), "ME Bridge not found")

provider.name = peripheral.getName(provider)
outputInventory.name = peripheral.getName(outputInventory)

-- == Variables == --
local maxWidth, maxHeight = term.getSize()
local tokenHash = hash.recipeFingerprint(tokenInventory.list()) -- used to track if the tokenInventory changes
local running = true                                            -- to end the program

local recipes = {} -- known recipes

-- == Utility Functions == --

---Returns what slot the token matching the nbthash is in.
---@param nbt string
---@return number
local function getToken(nbt, inv)
    for slot, item in pairs(inv) do
        if item.nbt == nbt then
            return slot
        end
    end
    return -1
end

---set the title bar for the program
---@param txt string
local function setTitle(txt)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.lightGray)

    term.setCursorPos(1, 1)
    print((" "):rep(maxWidth))
    term.setCursorPos((maxWidth / 2) - (#txt / 2), 1)
    print(txt)

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

local function collapseTable(tab)
    local out = {}
    for _, v in pairs(tab) do
        table.insert(out, v)
    end
    return out
end

local function buildInputTable(inputs)
    local out = {}
    for _, item in pairs(inputs) do
        local inp = item.primaryInput
        table.insert(out, { name = inp.name, count = item.multiplier, nbt = inp.nbt })
    end
    return out
end

local function buildBufferTable(inputs)
    local out = {}
    for _, item in pairs(inputs) do
        local key = item.name .. "|" .. (item.nbt or "")
        if out[key] then
            out[key].count = out[key].count + item.count
        else
            out[key] = {count=item.count,name=item.name}
            if item.nbt then out[key].nbt = item.nbt end
        end
    end
    return collapseTable(out)
end

-- == Helper Functions == --

--- Builds the recipes table, built once per run, and automatically if the tokenInventory changes.
local function buildRecipes()
    recipes = {}
    local pats = bridge.getPatterns()
    if pats == nil then return end
    local total = 0
    local tokeninv = tokenInventory.list()

    for _, pattern in pairs(pats) do
        if pattern.patternType == "processing" and pattern.primaryOutput.nbt then
            if getToken(pattern.primaryOutput.nbt,tokeninv) ~= -1 then
                local inpTable = buildInputTable(pattern.inputs)
                local inpHash = hash.recipeFingerprint(inpTable)
                recipes[inpHash] = pattern.primaryOutput.nbt
                total = total + 1
            end
        end
    end
    print("Total recipes found: " .. total)
end

local function emptyBuffer()
    repeat
        local invlist = bufferInventory.list()
        for slot, _ in pairs(invlist) do
            bufferInventory.pushItems(outputInventory.name, slot)
        end
    until next(bufferInventory.list()) == nil
end

-- == Main == --

local function main()
    term.setCursorPos(1, 3)

    local outInv = bufferInventory.list()
    if next(outInv) == nil then
        return
    end
        local outFilteredInv = buildBufferTable(outInv)
        local outHash = hash.recipeFingerprint(outFilteredInv)
        local curRecipe = recipes[outHash]
        if curRecipe then
            local tokeninv = tokenInventory.list()
            local tokenSlot = getToken(curRecipe, tokeninv)
            if tokenSlot == -1 then
                return
            end
            emptyBuffer()
            tokenInventory.pushItems(provider.name, tokenSlot)
        end
end

-- == Initalization == --

-- reset term
term.clear()
setTitle("AE Recipe Core")

buildRecipes() -- once per run build

os.startTimer(1)

while running do
    local ev, arg1 = os.pullEvent()
    if ev == "key" and arg1 == keys.q then
        running = false
    elseif ev == "timer" then
        local tokeninv = tokenInventory.list()
        local curTokenHash = hash.recipeFingerprint(tokeninv)
        if curTokenHash == tokenHash then
            main()
        else
            buildRecipes()
            tokenHash = curTokenHash
        end
        os.startTimer(1)
    end
end

term.clear()
term.setCursorPos(1, 1)
