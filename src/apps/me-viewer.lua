local me = peripheral.find("me_bridge")

if not me then
    print("No ME bridge found")
    return
end

-- =========================
-- State
-- =========================

local threshold = 1
local selected = 1
local page = 1
local items = {}
local viewMode = "group" -- "group" or "detail"
local expandedItem = nil
local sortMode = "count"
local sortReverse = true
local searchQuery = ""
local searching = false
local allItems = {}
local exportSide = "bottom"

-- =========================
-- Helpers
-- =========================

local function getListHeight()
    local _, h = term.getSize()
    return h - 4 -- 2 header + list + toolbar
end

local function getMaxPage()
    local perPage = getListHeight()
    return math.max(1, math.ceil(#items / perPage))
end

local function clampSelection()
    if #items == 0 then
        selected = 1
    else
        selected = math.max(1, math.min(selected, #items))
    end
end

local function wrapPage()
    local maxPage = getMaxPage()

    if maxPage <= 1 then
        page = 1
        return
    end

    if page < 1 then
        page = maxPage
    elseif page > maxPage then
        page = 1
    end
end

local function syncPageToSelection()
    local perPage = getListHeight()

    if perPage <= 0 then return end

    local startIndex = ((page - 1) * perPage) + 1
    local endIndex = startIndex + perPage - 1

    if selected < startIndex or selected > endIndex then
        selected = startIndex
    end

    clampSelection()
end

local function isSortModeValid(mode)
    if mode == "unique" then
        -- only valid if at least one item has uniques > 1
        for _, v in pairs(items) do
            if v.unique then
                return true
            end
        end
        return false
    end

    if mode == "stack" then
        -- only valid if at least one item is unstackable or variable
        for _, v in pairs(items) do
            if v.maxStackSize then
                return true
            end
        end
        return false
    end

    return true
end

local function sortItems(list)
    table.sort(list, function(a, b)
        local function getValue(x)
            if sortMode == "count" then
                return x.count or 0
            elseif sortMode == "name" then
                return x.name or ""
            elseif sortMode == "unique" then
                return x.unique or 0
            elseif sortMode == "stack" then
                return x.maxStackSize or 0
            end

            return 0
        end

        local av = getValue(a)
        local bv = getValue(b)

        local result

        if type(av) == "string" then
            result = av < bv
        else
            result = av < bv
        end

        if sortReverse then
            return not result
        end

        return result
    end)
end

local function syncSelectionToPage()
    local perPage = getListHeight()

    local startIndex = ((page - 1) * perPage) + 1
    selected = startIndex
    clampSelection()
end

local function applySearchFilter()
    if searchQuery == "" then
        items = allItems
        return
    end

    local q = searchQuery:lower()
    items = {}

    for _, item in ipairs(allItems) do
        if item.name:lower():find(q, 1, true) then
            table.insert(items, item)
        end
    end

    -- IMPORTANT: keep sorted order from allItems
    sortItems(items)

    clampSelection()
    syncSelectionToPage()
end

local function buildDetailItems(name)
    local inventory = me.getItems()
    local list = {}

    for i = 1, #inventory do
        local item = inventory[i]

        if item and item.name == name then
            table.insert(list, {
                name = item.name,
                display = item.displayName or (item.components and item.components.Name) or item.name,
                count = item.count or 1,
                fingerprint = item.fingerprint,
                maxStackSize = item.maxStackSize or 64
            })
        end
    end

    table.sort(list, function(a, b)
        return a.display:lower() < b.display:lower()
    end)

    return list
end

local function trim(text, len)
    if #text > len then
        return text:sub(1, len - 1) .. "…"
    end
    return text
end

local function padRight(str, len)
    str = tostring(str or "")
    if #str > len then
        return str:sub(1, len)
    end
    return str .. string.rep(" ", len - #str)
end

local function padLeft(str, len)
    str = tostring(str or "")
    if #str > len then
        return str:sub(1, len)
    end
    return string.rep(" ", len - #str) .. str
end

local function formatRow(selected, count, label, unique, maxStack)
    local sel = selected and "\x10" or "\xb7"

    local countStr = padLeft(count .. "x", 6) -- fixed width column

    local uniqueStr = ""
    if unique and unique > 1 then
        uniqueStr = "\x04" .. unique
    end
    uniqueStr = padRight(uniqueStr, 5)

    local stackStr = ""
    if (maxStack or 1) == 1 then
        stackStr = "USTK"
    elseif (maxStack or 1) < 64 or (maxStack or 1) > 64 then
        stackStr = "STK:" .. (maxStack or 1)
    end
    stackStr = padRight(stackStr, 6)

    label = trim(label, 50)
    label = padRight(label, 50)

    return string.format(
        "%s %s \x7c %s \x7c %s \x7c %s",
        sel,
        countStr,
        label,
        uniqueStr,
        stackStr
    )
end

local function rebuildView()
    if viewMode == "detail" and expandedItem then
        items = buildDetailItems(expandedItem)
    else
        items = {}

        for _, v in ipairs(allItems) do
            table.insert(items, v)
        end

        applySearchFilter()
    end

    sortItems(items)
    clampSelection()
    syncSelectionToPage()
end

local function canEnterDetail()
    local item = items[selected]
    if not item then return false end

    return item.unique and item.unique > 1
end

local function exportSelected()
    local item = items[selected]
    if not item then return end

    me.exportItem({ name = item.name, count = 1 }, exportSide)

    item.count = item.count - 1
    if item.count <= 0 then
        table.remove(allItems, selected)
        selected = math.max(1, selected - 1)
    end
end

-- =========================
-- Data Refresh
-- =========================

local function refreshItems()
    allItems = {}

    local inventory = me.getItems()
    local data = {}

    for i = 1, #inventory do
        local item = inventory[i]

        if item then
            local name = item.name
            local fp = item.fingerprint or textutils.serialize(item.components or {})

            if not data[name] then
                data[name] = {
                    count = 0,
                    uniques = {},
                    maxStackSize = item.maxStackSize or 1
                }
            end

            data[name].count = data[name].count + (item.count or 0)
            data[name].uniques[fp] = true
        end
    end

    for name, entry in pairs(data) do
        local uniqueCount = 0

        for _ in pairs(entry.uniques) do
            uniqueCount = uniqueCount + 1
        end

        if entry.count >= threshold then
            table.insert(allItems, {
                name = name,
                count = entry.count,
                unique = uniqueCount,
                maxStackSize = entry.maxStackSize or 1
            })
        end
    end

    sortItems(allItems)
    rebuildView()
end

-- =========================
-- UI
-- =========================

local function drawHeader()
    local w = select(1, term.getSize())

    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.cyan)
    term.setTextColor(colors.black)
    term.clearLine()

    local title = " ME Item Threshold Viewer "
    term.setCursorPos(math.max(1, math.floor((w - #title) / 2) + 1), 1)
    term.write(title)

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

local function getHelpLines()
    if searching then
        return {
            "Search: " .. searchQuery .. " | Enter: confirm | Backspace: del | Delete: clear"
        }
    end

    if viewMode == "detail" then
        return {
            "Detail | Backspace: back | R: refresh | Q: quit",
            "Items: " ..
            #items ..
            " | Page: " .. page .. "/" .. getMaxPage() .. " | Sort: " .. sortMode .. (sortReverse and " \x19" or " \x18")
        }
    end

    if #items == 0 then
        return {
            "No results | / search | R refresh"
        }
    end

    local enterHint = canEnterDetail() and " [Enter] open" or ""

    return {
        "[R] refresh [T] threshold [/] search" ..
        enterHint ..
        " [Tab] sort [V] order [Del] reset [Q] quit [E] export",
        "Threshold: " ..
        threshold ..
        " | Items: " ..
        #items ..
        " | Page: " .. page .. "/" .. getMaxPage() .. " | Sort: " .. sortMode .. (sortReverse and " \x19" or " \x18")
    }
end

local function drawToolbar()
    local w, h = term.getSize()

    local function writeCentered(y, text, fg, bg)
        term.setCursorPos(1, y)
        term.setBackgroundColor(bg)
        term.setTextColor(fg)
        term.clearLine()

        text = text or ""
        if #text > w then
            text = text:sub(1, w)
        end

        local x = math.max(1, math.floor((w - #text) / 2) + 1)
        term.setCursorPos(x, y)
        term.write(text)
    end

    local lines = getHelpLines()

    local y1 = h - (#lines - 1)

    for i, line in ipairs(lines) do
        local y = y1 + (i - 1)

        local bg = (i == 1) and colors.blue or colors.lightBlue
        local fg = (i == 1) and colors.white or colors.black

        writeCentered(y, line, fg, bg)
    end

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

local function render()
    term.clear()

    drawHeader()

    local perPage = getListHeight()
    local startIndex = ((page - 1) * perPage) + 1
    local finish = math.min(#items, startIndex + perPage - 1)

    term.setCursorPos(1, 2)

    if #items == 0 then
        print("(no matching items)")
    else
        for i = startIndex, finish do
            local item = items[i]
            local isSelected = (i == selected)

            local label
            if viewMode == "detail" then
                label = item.display or item.name
            else
                label = item.name
            end

            local line = formatRow(
                isSelected,
                item.count,
                label,
                (viewMode == "group") and item.unique or nil,
                item.maxStackSize
            )

            -- color handling
            if isSelected then
                term.setTextColor(colors.yellow)
            else
                term.setTextColor(colors.white)
            end

            print(line)
        end
    end

    drawToolbar()
end

local function setThreshold()
    local _, h = term.getSize()

    term.setCursorPos(1, h - 2)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clearLine()

    term.write("New threshold: ")

    local value = tonumber(read())

    if value and value >= 1 then
        threshold = math.floor(value)
        refreshItems()
    end
end

local function scanReset()
    threshold = 1
    searchQuery = ""
    searching = false
    viewMode = "group"
    expandedItem = nil

    page = 1
    selected = 1

    refreshItems()
end

-- =========================
-- Input
-- =========================

local function handleKey(key)
    if key == keys.q then
        return false
    elseif key == keys.r then
        refreshItems()
    elseif key == keys.up then
        selected = selected - 1
        clampSelection()
        syncPageToSelection()
    elseif key == keys.down then
        selected = selected + 1
        clampSelection()
        syncPageToSelection()
    elseif key == keys.left then
        page = page - 1
        wrapPage()
        syncSelectionToPage()
    elseif key == keys.right then
        page = page + 1
        wrapPage()
        syncSelectionToPage()
    elseif key == keys.t then
        sleep()
        setThreshold()
    elseif key == keys.enter then
        if viewMode == "group" and items[selected] and items[selected].unique > 1 then
            viewMode = "detail"
            expandedItem = items[selected].name
            rebuildView()
            selected = 1
            page = 1
            wrapPage()
            syncSelectionToPage()
        else
            viewMode = "group"
            expandedItem = nil
            refreshItems()
        end
    elseif key == keys.backspace then
        if viewMode == "detail" then
            viewMode = "group"
            expandedItem = nil
            refreshItems()
        end
    elseif key == keys.tab then
        local modes = { "count", "name", "unique", "stack" }

        local currentIndex = 1
        for i, v in ipairs(modes) do
            if v == sortMode then
                currentIndex = i
                break
            end
        end

        local nextMode
        local attempts = 0

        repeat
            currentIndex = currentIndex + 1
            if currentIndex > #modes then
                currentIndex = 1
            end

            nextMode = modes[currentIndex]
            attempts = attempts + 1

            -- safety break (prevents infinite loop)
            if attempts > #modes then
                nextMode = "count"
                break
            end
        until isSortModeValid(nextMode)

        sortMode = nextMode
        sortItems(allItems)
        rebuildView()
    elseif key == keys.v then
        sortReverse = not sortReverse
        sortItems(allItems)
        rebuildView()
    elseif key == keys.slash then
        sleep()
        searching = true
        searchQuery = ""
    elseif key == keys.delete then
        scanReset()
    elseif key == keys.e then
        exportSelected()
    end

    return true
end

-- =========================
-- Main
-- =========================

refreshItems()

while true do
    render()

    local eventData = { os.pullEvent() }
    local event = eventData[1]
    local key = eventData[2]

    local keepRunning = true

    if searching and event == "char" then
        searchQuery = searchQuery .. key
        applySearchFilter()
    elseif searching and event == "key" then
        if searching and key == keys.backspace then
            if #searchQuery == 0 then
                searching = false
            else
                searchQuery = searchQuery:sub(1, -2)
                applySearchFilter()
            end
        elseif key == keys.enter then
            searching = false
        elseif key == keys.delete then
            searching = false
            searchQuery = ""
            applySearchFilter()
        end
    end

    if not searching and event == "key" then
        keepRunning = handleKey(key)
    end

    if not keepRunning then
        break
    end
end

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
print("Exited.")
