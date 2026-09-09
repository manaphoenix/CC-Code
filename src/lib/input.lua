local input = {}

---@return table
function input.pull()
    local event = { os.pullEvent() }

    local e = event[1]

    -- KEY EVENTS
    if e == "key" then
        return {
            type = "key",
            key = event[2]
        }
    end

    -- MOUSE CLICK (terminal)
    if e == "mouse_click" then
        return {
            type = "click",
            button = event[2],
            x = event[3],
            y = event[4]
        }
    end

    -- MONITOR TOUCH (treat as click)
    if e == "monitor_touch" then
        return {
            type = "click",
            x = event[3],
            y = event[4]
        }
    end

    -- fallback raw passthrough (for unknown events)
    return {
        type = e,
        raw = event
    }
end

---@param filter string
function input.pullFiltered(filter)
    return os.pullEvent(filter)
end

return input
