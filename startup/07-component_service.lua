-- automatic peripheral mounting
local components = {
    count = function(self)
        local c = 0
        for _, v in pairs(self) do
            if type(v) == "table" then c = c + 1 end
        end
        return c
    end
}
_G.components = components

-- utility functions
local function reset()
    for k in pairs(components) do
        if type(components[k]) == "table" then
            components[k] = nil
        end
    end
end

local function updateComponents()
    reset()
    local perips = peripheral.getNames()
    for _, side in ipairs(perips) do
        local pType = peripheral.getType(side)
        if not pType then goto continue end
        local baseName = pType:match(":(.+)") or pType
        local name = baseName
        local t = 2

        while components[name] do
            name = baseName .. "_" .. t
            t = t + 1
        end

        local wrapped = peripheral.wrap(side)
        if wrapped then
            wrapped.side = side
            components[name] = wrapped
        end
        ::continue::
    end
end

-- components metatable
setmetatable(components, {
    __tostring = function(self)
        local parts = {}
        for k, v in pairs(self) do
            if type(v) == "table" then
                parts[#parts + 1] = k
            end
        end
        return #parts > 0 and table.concat(parts, "\n") or "None"
    end,
    __call = updateComponents
})

-- peripheral watcher
local function peripheralWatchDog()
    while true do
        local ev, side = os.pullEvent()
        if ev == "peripheral" then
            local pType = peripheral.getType(side)
            if not pType then goto continue end
            local baseName = pType:match(":(.+)") or pType
            local name = baseName
            local t = 2

            while components[name] do
                name = baseName .. "_" .. t
                t = t + 1
            end

            local wrapped = peripheral.wrap(side)
            if wrapped then
                wrapped.side = side
                components[name] = wrapped
            end
        elseif ev == "peripheral_detach" then
            for k, v in pairs(components) do
                if type(v) == "table" and v.side == side then
                    components[k] = nil
                    break
                end
            end
        end
        ::continue::
    end
end

components()

-- === RedRun === --
-- === do not modify === --

--- RedRun - A very tiny background task runner using the native top-level coroutine
-- By JackMacWindows
-- Licensed under CC0, though I'd appreciate it if this notice was left in place.
local redrun = {}
local coroutines = {}

--- Initializes the RedRun runtime. This is called automatically, but it's still available if desired.
-- @param silent Set to any truthy value to inhibit the status message.
function redrun.init(silent)
    local env = getfenv(rednet.run)
    if env.__redrun_coroutines then
        -- RedRun was already initialized, so just grab the coroutine table and run
        coroutines = env.__redrun_coroutines
    else
        -- For the actual code execution, we go through os.pullEventRaw which is the only function called unconditionally each loop
        -- To avoid breaking real os, we set this through the environment of the function
        -- We also use a metatable to avoid writing every other function out
        env.os = setmetatable({
            pullEventRaw = function()
                local ev = table.pack(coroutine.yield())
                local delete = {}
                for k, v in pairs(coroutines) do
                    if v.terminate or v.filter == nil or v.filter == ev[1] or ev[1] == "terminate" then
                        local ok
                        if v.terminate then
                            ok, v.filter = coroutine.resume(v.coro, "terminate")
                        else
                            ok, v.filter = coroutine.resume(v.coro, table.unpack(ev, 1, ev.n))
                        end
                        if not ok or coroutine.status(v.coro) ~= "suspended" or v.terminate then delete[#delete + 1] = k end
                    end
                end
                for _, v in pairs(delete) do coroutines[v] = nil end
                return table.unpack(ev, 1, ev.n)
            end
        }, { __index = os, __isredrun = true })
        -- Add the coroutine table to the environment to be fetched by init later
        env.__redrun_coroutines = coroutines
        if not silent then print("Successfully registered RedRun.") end
    end
end

redrun.init(true)

coroutines[1] = { coro = coroutine.create(peripheralWatchDog), name = "peripheralWatchDog" }

print("System ready. Components loaded: " .. components:count())
