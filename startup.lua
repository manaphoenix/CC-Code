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

-- configs
local config = {
    clearTmp = true,
    logStartup = false
}

if fs.exists("config/startup.cfg") then
    local ok, result = pcall(function()
        return textutils.unserialize(fs.readAll("config/startup.cfg"))
    end)
    if ok and type(result) == "table" then
        config = result
    else
        print("Warning: startup.cfg is invalid. Using defaults.")
    end
end

-- log startup
if config.logStartup then
    local f = fs.open("logs/startup.log", "a")
    f.writeLine(os.date() .. " - Startup completed")
    f.close()
end

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

components()

-- set colors
for i, v in pairs(pal) do term.setPaletteColor(colors[i], v) end

if (components.monitor) then
    for i, v in pairs(pal) do
        components.monitor.setPaletteColor(colors[i], v)
    end
end

-- create folders if they don't exist.
local folders = {
    "config",
    "data",
    "installers",
    "lib",
    "logs",
    "tmp",
    "assets",
    "apps"
}
for _, v in pairs(folders) do
    if not fs.exists(v) then fs.makeDir(v) end
end

-- create default config if does note exist.
if not fs.exists("config/startup.cfg") then
    local f = fs.open("config/startup.cfg", "w")
    f.write(textutils.serialize(config))
    f.close()
end

-- clear tmp folder
local function clearTmpFolder()
    if fs.exists("tmp") then
        for _, file in ipairs(fs.list("tmp")) do
            fs.delete(fs.combine("tmp", file))
        end
    end
end

if config.clearTmp then clearTmpFolder() end

-- set alias

-- check if alias exists
local function getAlias(aliasName)
    local aliases = shell.aliases()
    return aliases[aliasName] ~= nil
end

-- Automatically add aliases for scripts in the "apps" folder
local function createAppAliases()
    if not fs.exists("apps") then return end

    for _, file in ipairs(fs.list("apps")) do
        local path = fs.combine("apps", file)
        if not fs.isDir(path) and file:match("%.lua$") then
            local aliasName = file:gsub("%.lua$", "")
            if not getAlias(aliasName) then
                shell.setAlias(aliasName, path)
            end
        end
    end
end

createAppAliases()

coroutines[1] = { coro = coroutine.create(peripheralWatchDog), name = "peripheralWatchDog" }

print("System ready. Components loaded: " .. components:count())
