-- lib/input.lua

local input = {}

-- =========================
-- Event wrapper (no logic)
-- =========================

---@return string, any, any, any
function input.pull()
    return os.pullEvent()
end

---@return string, any, any, any
function input.pullFiltered(filter)
    return os.pullEvent(filter)
end

-- =========================
-- Event utilities (pure helpers)
-- =========================

---@param event string
---@return boolean
function input.is(event, name)
    return event == name
end

---@param event string
---@param target string
---@return boolean
function input.isEvent(event, target)
    return event == target
end

return input