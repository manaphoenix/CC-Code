-- startup file
settings.set("motd.enable", false)
settings.save()
term.clear()
term.setCursorPos(1, 1)

-- intialize var
local pal = {
    white = 0xD3D7CF,
    orange = 0xFF7F00,
    magenta = 0xFF00FF,
    lightBlue = 0xADD8E6,
    yellow = 0xFFD700,
    lime = 0x00FF00,
    pink = 0xFFC0CB,
    gray = 0x1E2227,
    lightGray = 0x23272E,
    cyan = 0x529EDC,
    purple = 0x75507B,
    blue = 0x0000ff,
    brown = 0xA52A2A,
    green = 0x8BC550,
    red = 0xE42D2D,
    black = 0x0C0C0C
}

-- automatic peripheral mounting
_G.components = {}

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
                        if v.terminate then ok, v.filter = coroutine.resume(v.coro, "terminate")
                        else ok, v.filter = coroutine.resume(v.coro, table.unpack(ev, 1, ev.n)) end
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

-- Download Custom Libs
local function downloadFiles()
    local gitTemplate = "https://raw.githubusercontent.com/manaphoenix/CC_OC-Code/main/"
    if not http then return end
    local req = http.get("https://api.github.com/repos/manaphoenix/CC_OC-Code/git/trees/main?recursive=1")
    if not req then return end
    local files = textutils.unserialiseJSON(req.readAll())
    req.close()
    local toDownload = {}

    local shaFile = fs.open("fileShas.txt", "w")
    for _, v in pairs(files.tree) do
        if v.path:match("%.lua") and not fs.exists(v.path) then
            table.insert(toDownload, function()
                req = http.get(gitTemplate .. v.path, nil, true)
                if not req then return end
                local file = fs.open(v.path, "wb")
                if file then
                    file.write(req.readAll())
                    file.close()
                end
                req.close()
            end)
        end
        shaFile.writeLine(v.path .. " " .. v.sha)
    end
    parallel.waitForAll(table.unpack(toDownload))
    shaFile.close()
end

-- cosu auto completion
-- add completion if it does not exist
local completions = shell.getCompletionInfo()
if not completions["cosu.lua"] then
    local completion = require("cc.shell.completion")
    local complete = completion.build(
        completion.file
    )
    shell.setCompletionFunction("cosu.lua", complete)
end

components()
--downloadFiles()

-- set colors
for i, v in pairs(pal) do term.setPaletteColor(colors[i], v) end

if (components.monitor) then
    for i, v in pairs(pal) do
        components.monitor.setPaletteColor(colors[i], v)
    end
end

coroutines[1] = { coro = coroutine.create(peripheralWatchDog), name = "peripheralWatchDog" }
