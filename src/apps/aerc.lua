-- == Libraries == --
local hash = require("lib.hash")

-- == Peripherals == --
local tokenInventory = assert(peripheral.wrap("sophisticatedstorage:barrel_11"), "Token Inventory not found")
local outputInventory = assert(peripheral.wrap("sophisticatedstorage:barrel_13"), "Output Inventory not found")
local provider = assert(peripheral.wrap("expandedae:exp_pattern_provider_1"), "Pattern Provider not found")
---@type ap.peripheral.StorageBridge
local bridge = assert(peripheral.find("me_bridge"), "ME Bridge not found")

provider.name = peripheral.getName(provider)

-- == Annotation Metas == --

---@class recipe
---@field input string the input hash of the inputs for the recipe
---@field output string the nbt hash of the output token for the recipe

-- == Variables == --
local maxWidth, maxHeight = term.getSize()
local tokenHash = hash.recipeFingerprint(tokenInventory.list()) -- used to track if the tokenInventory changes
local running = true                                            -- to end the program

---@type recipe[]
local recipes = {} -- known recipes

-- == Utility Functions == --

---Returns what slot the token matching the nbthash is in.
---@param nbt string
---@return number
local function getToken(nbt)
    local inv = tokenInventory.list()
    for slot, item in pairs(inv) do
        if item.nbt == nbt then
            return slot
        end
    end
    return -1
end

---find the recipe based on its inputs
---@param hashstring string
---@return recipe|nil
local function getRecipe(hashstring)
    if #recipes == 0 then return end

    for _, recipe in ipairs(recipes) do
        if recipe.input == hashstring then
            return recipe
        end
    end
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

local function buildInputTable(inputs)
    local out = {}
    for _, item in pairs(inputs) do
        local inp = item.primaryInput
        table.insert(out, { name = inp.name, count = item.multiplier, nbt = inp.nbt })
    end
    return out
end

-- == Helper Functions == --

--- Builds the recipes table, built once per run, and automatically if the tokenInventory changes.
local function buildRecipes()
    recipes = {}
    local pats = bridge.getPatterns()
    if pats == nil then return end
    local total = 0

    for _, pattern in pairs(pats) do
        if pattern.patternType == "processing" and pattern.primaryOutput.nbt then
            if getToken(pattern.primaryOutput.nbt) ~= -1 then
                local inpTable = buildInputTable(pattern.inputs)
                ---@type recipe
                local recipe = {
                    input = hash.recipeFingerprint(inpTable),
                    output = pattern.primaryOutput.nbt
                }
                table.insert(recipes, recipe)
                total = total + 1
            end
        end
    end
    print("Total recipes found: " .. total)
end

-- == Main == --

local function main()
    term.setCursorPos(1, 2)

    local outInv = outputInventory.list()
    if #outInv > 0 then
        local outHash = hash.recipeFingerprint(outInv)
        local curRecipe = getRecipe(outHash)
        if curRecipe then
            local tokenSlot = getToken(curRecipe.output)
            tokenInventory.pushItems(provider.name, tokenSlot)
        end
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
        local curTokenHash = hash.recipeFingerprint(tokenInventory.list())
        if curTokenHash == tokenHash then
            main()
        else
            buildRecipes()
        end
        os.startTimer(1)
    end
end

term.clear()
term.setCursorPos(1, 1)
