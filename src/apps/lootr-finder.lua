--[[ CONFIGURATION ]] --

---@type integer
local SCAN_RADIUS = 16 -- Scan radius in blocks (maximum: 16).

---@class Filter
---@field filter string
---@field color integer
---@field state? string

---@type Filter[]
local FILTERS = {
    {filter = "lootr", color=0x00CC00},
    {filter = "trial_spawner",color=0xCC0000},
    {filter = "minecraft:vault",color=0xCCCC00,state="!ominous"},
    {filter = "minecraft:vault",color=0xCC00CC,state="ominous"}
} -- String to search for in block IDs (e.g. "minecraft:chest").
-- The entire block ID is searched, not just the portion after ":".

---@type number
local OPACITY = 0.25 -- Overlay opacity (0 = transparent, 1 = opaque).

---@type "Box"|"Block"
local MODE = "Box" -- Rendering mode: "Box" or "Block".
-- Block mode is not supported by shaders.

---@type number
local SCAN_COOLDOWN = 5 -- Time between scans in seconds (minimum: 2).

-- [[ DO NOT CHANGE ]] --

---@type ap.peripheral.GeoScanner
local geo = assert(
    peripheral.find("geo_scanner"),
    "Geo scanner is required"
)

---@type ap.peripheral.PlayerDetector
local playerDetector = assert(
    peripheral.find("player_detector"),
    "Player Detector is required"
)

assert(smartglasses, "This is a smartglasses app")

local overlay = assert(
    smartglasses.modules["advancedperipherals:overlay"],
    "The overlay module is required"
)

overlay.clear()

local function isTargetBlock(block)
    for _, filter in pairs(FILTERS) do
        if block.name:find(filter.filter, 1, true) ~= nil then
            return true
        end
    end
    return false
end

---@param tags table<string, boolean>|nil
---@param tag string|nil
---@return boolean
local function tagMatches(tags, tag)
    if not tags or not tag then
        return false
    end

    local isNot = tag:sub(1, 1) == "!"
    local tagName = isNot and tag:sub(2) or tag

    local value = tags[tagName]

    if isNot then
        return value == false
    end

    return value == true
end

---@param block {name: string, state?: table<string, boolean>}
---@return Filter|false
local function getFilter(block)
    for _, filter in ipairs(FILTERS) do
        if block.name:find(filter.filter, 1, true) then
            if not filter.state or tagMatches(block.state, filter.state) then
                return filter
            end
        end
    end

    return false
end

local function createMarkedPosition(block, player)
    local filterinfo = getFilter(block)

    local blockInfo = {
        x = math.floor(player.x + block.x) + 0.5,
        y = player.y + block.y + player.eyeHeight,
        z = math.floor(player.z + block.z) + 0.5,

        sizeX = 1,
        sizeY = 1,
        sizeZ = 1,

        opacity = OPACITY,
        depthTest = false,
        color = filterinfo and filterinfo.color or 0xFFFFFF,

        block = block.name,
        states = MODE == "Block" and block.state or {},
        tintAll = true
    }

    if MODE == "Block" then
        overlay.createBlock(blockInfo)
    elseif MODE == "Box" then
        overlay.createBox(blockInfo)
    end
end

local running = true

os.startTimer(1)

while running do
    local ev, keyPressed = os.pullEvent()
    if ev == "key_up" and keyPressed == keys.q then
        running = false
    end

    local player = playerDetector.getOwner()

    if player then
        local blocks, reason = geo.scanBlocks(SCAN_RADIUS)

        if blocks then
            overlay.clear()

            for _, block in ipairs(blocks) do
                if isTargetBlock(block) then
                    createMarkedPosition(block, player)
                end
            end
        else
            --printError("Geo scan failed: " .. tostring(reason))
        end
    else
        overlay.clear()
    end

    os.startTimer(SCAN_COOLDOWN)
end

term.clear()
term.setCursorPos(1, 1)
overlay.clear()