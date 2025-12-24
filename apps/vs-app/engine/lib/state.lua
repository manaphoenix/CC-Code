local state = {}

-- internal authoritative state
local current = {
    front = false,
    back = false,
    left = false,
    right = false,
    top = false,
    bottom = false,
    isOff = false,
}

-- shallow copy helper (prevents external mutation)
local function copy(tbl)
    local out = {}
    for k, v in pairs(tbl) do
        out[k] = v
    end
    return out
end

-- return a snapshot of current state (read-only by convention)
function state.get()
    return copy(current)
end

-- explicitly set off-state (from latch relay)
function state.setOff(isOff)
    current.isOff = not not isOff
end

-- update state from input sides
-- inputs = { front=true, back=false, ... }
function state.updateFromInputs(inputs)
    -- count active inputs
    local activeCount = 0
    for _, v in pairs(inputs) do
        if v then activeCount = activeCount + 1 end
    end

    -- only accept exactly one active input
    if activeCount ~= 1 then
        return false
    end

    -- preserve off-state
    local isOff = current.isOff

    -- reset all sides
    for k, _ in pairs(current) do
        if k ~= "isOff" then
            current[k] = false
        end
    end

    -- apply new inputs
    for k, v in pairs(inputs) do
        if current[k] ~= nil then
            current[k] = v
        end
    end

    current.isOff = isOff
    return true
end

return state
