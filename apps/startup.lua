-- startup file
settings.set("motd.enable", false)
settings.save()
term.clear()
term.setCursorPos(1, 1)

-- intialize var
local pal = {
    white     = 0xE0D0FF,  -- soft lilac
    orange    = 0xFF7F50,  -- coral fire (phoenix heat)
    magenta   = 0xB85FFF,  -- mana magenta
    lightBlue = 0x7EC8E3,  -- airy magic blue
    yellow    = 0xFFD700,  -- golden flame core
    lime      = 0x9EFFD6,  -- mana-touched green
    pink      = 0xFFB7F5,  -- light pink-purple glow
    gray      = 0x1B0F2F,  -- deep royal shadow
    lightGray = 0x2E1A47,  -- soft obsidian violet
    cyan      = 0x529EDC,  -- retained, mana-infused cyan
    purple    = 0x6A0DAD,  -- royal purple (main brand)
    blue      = 0x5D5FEF,  -- mystical deep blue
    brown     = 0x6E1A25,  -- charred ember
    green     = 0x8BC550,  -- natural retained
    red       = 0xFF3CAC,  -- mana flame burst
    black     = 0x0A0613   -- true void (richer black)
}

-- configs
local config = {
    clearTmp = true,
    logStartup = false
}

if fs.exists("config/startup.cfg") then
    local ok, result = pcall(function()
        local f = fs.open("config/startup.cfg", "r")
        local data = f.readAll()
        f.close()
        return textutils.unserialize(data)
    end)
    if ok and type(result) == "table" then
        config = result
    else
        print("Warning: startup.cfg is invalid. Using defaults.")
        print(ok, result)
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

-- set colors
for i, v in pairs(pal) do term.setPaletteColor(colors[i], v) end

if (components.monitor) then
    for i, v in pairs(pal) do
        components.monitor.setPaletteColor(colors[i], v)
        components.monitor.clear()
        components.monitor.setCursorPos(1, 1)
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

_ENV.package.path = _ENV.package.path .. ";lib/?.lua"

coroutines[1] = { coro = coroutine.create(peripheralWatchDog), name = "peripheralWatchDog" }

print("System ready. Components loaded: " .. components:count())
