-- automatic peripheral mounting
_G.components = {
    count = function(self)
        local c = 0
        for k, v in pairs(self) do
            if type(v) == "table" then c = c + 1 end
        end
        return c
    end
}

-- utility functions
local function reset()
    for i, v in pairs(components) do
        if type(v) == "table" then components[i] = nil end
    end
end

local function updateComponents()
    reset()
    local perips = peripheral.getNames()
    if #perips == 0 then return end
    for _, v in pairs(perips) do
        local name = peripheral.getType(v)
        name = name:gsub(".+:(.+)", "%1")
        if components[name] then
            local t = 2
            local test = name .. "_" .. t

            while (components[test] ~= nil) do
                t = t + 1
                test = name .. "_" .. t
            end

            name = test
        end
        components[name] = peripheral.wrap(v)
        components[name].side = v
    end
end

-- components metatable
local componentMT = {
    __tostring = function(self)
        -- print all components, formatted
        local str = ""
        for k, v in pairs(self) do
            if type(v) == "table" then
                str = str .. k .. "\n"
            end
        end
        -- remove extra newline
        str = str:sub(1, -2)
        if str == "" then
            str = "None"
        end
        return str
    end,
    __call = updateComponents
}

setmetatable(components, componentMT)

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

-- peripheral watcher
local function peripheralWatchDog()
    while true do
        local ev, side = os.pullEvent()
        if ev == "peripheral" then
            local name = peripheral.getType(side)
            name = name:gsub(".+:(.+)", "%1")
            components[name] = peripheral.wrap(side)
            components[name].side = side
        elseif ev == "peripheral_detach" then
            for i, v in pairs(components) do
                if type(v) == "table" and v.side == side then
                    components[i] = nil
                end
            end
        end
    end
end

components()

coroutines[1] = { coro = coroutine.create(peripheralWatchDog), name = "peripheralWatchDog" }

print("System ready. Components loaded: " .. components:count())
