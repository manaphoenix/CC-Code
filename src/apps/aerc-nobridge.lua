local paperBarrel = peripheral.wrap("sophisticatedstorage:barrel_6")
local outputBarrel = peripheral.wrap("sophisticatedstorage:barrel_7")
local interface = peripheral.wrap("expandedae:exp_pattern_provider_0")

interface.name = peripheral.getName(interface)

local recipeFile = "recipes.lua"
local recipes = {}

local maxWidth, maxHeight = term.getSize()
local statusTxt = "Name: %s requested: %d fulfilled: %d"

do
    local file = fs.open(recipeFile, "r")
    if file then
        local content = file.readAll()
        file.close()
        if content then
            local unsContent = textutils.unserialize(content)
            if unsContent then
                recipes = unsContent
            end
        end
    end
end

local recipesRequested = {} -- inserted is recipes index = 0
local recipesFulfilled = {} -- inserted is recipes index = 0, where 0 is the number of times the recipe has being completed.
-- used to send the paper a right number of times.

-- == Utility functions == --
local function countRecipeAmount(recipe, invlist)
    return 1 -- todo, count the number of recipes in the list
end

local function countTable(tab)
    local n = 0
    for _, _ in pairs(tab) do
        n = n + 1
    end
    return n
end

local function findInInventory(invlist, name)
    for _, item in pairs(invlist) do
        if item.name == name then
            return true
        end
    end
    return false
end

local function findSlotByNbt(inv, nbthash)
    for slot, item in pairs(inv) do
        if item.nbt == nbthash then
            return slot
        end
    end
    return -1
end

local function indexOf(tab)
    for i, v in pairs(tab) do
        return i
    end
end

-- == main functions == --

local function isRecipeInBarrel(recipe, invlist)
    local totalInputs = countTable(recipe.inputs)
    local n = 0
    for input, amount in pairs(recipe.inputs) do
        if not findInInventory(invlist, input) then break end
        n = n + 1
    end
    return n == totalInputs
end

local function getRecipesInBarrel()
    local invlist = outputBarrel.list()
    local invcount = countTable(invlist)
    local recipesFulfilledcount = countTable(recipesFulfilled)
    if invcount == 0 and recipesFulfilledcount >= 1 then
        recipesFulfilled = {} -- reset
        recipesRequested = {}
    elseif invcount > 0 then
        for recipeID, recipe in pairs(recipes) do
            local foundRecipe = isRecipeInBarrel(recipe, invlist)
            if foundRecipe then
                recipesRequested[recipeID] = countRecipeAmount(recipe, invlist)
                if recipesFulfilled[recipeID] == nil then
                    recipesFulfilled[recipeID] = 0
                end
            end
        end
    end
end

local function dofulfillcycle()
    local papers = paperBarrel.list()
    for id, requested in pairs(recipesRequested) do
        if recipesFulfilled[id] < requested then
            local recipe = recipes[id]
            local slot = findSlotByNbt(papers, indexOf(recipe.outputs)) -- TODO get the index of the table entry
            if slot ~= -1 then
                local moved = paperBarrel.pushItems(interface.name, slot)
                recipesFulfilled[id] = recipesFulfilled[id] + moved
            end
        end
    end
end

term.clear()
term.setCursorPos(1, 1)
print("Custom Pattern Completer:")

while true do
    term.setCursorPos(1, 2)

    getRecipesInBarrel()
    if countTable(recipesRequested) > 0 then
        for id, amount in pairs(recipesRequested) do
            local txt = statusTxt:format(recipes[id].name, amount or 0, recipesFulfilled[id] or 0) .. (" "):rep(maxWidth)
            print(txt)
        end

        dofulfillcycle()
    end
    sleep(1)
end
