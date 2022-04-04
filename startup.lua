-- startup file
settings.set("motd.enable", false)
settings.save()
term.clear()
term.setCursorPos(1, 1)

-- utility functions
local function reset()
    for i, v in pairs(components) do
        if type(v) == "table" then components[i] = nil end
    end
end

-- automatic peripheral mounting
_G.components = {
    updateComponents = function()
        reset()
        local perips = peripheral.getNames()
        if #perips == 0 then return end
        for _, v in ipairs(perips) do
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
}

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

-- intialize var
local pal = {
    white = 0xD9D5CC,
    orange = 0xFB8100,
    magenta = 0xFF00FF,
    lightBlue = 0x87CEEB,
    yellow = 0xC7A000,
    lime = 0x00ff00,
    pink = 0xFF69B4,
    gray = 0x3F3F3F,
    lightGray = 0x545454,
    cyan = 0x2BBAA8,
    purple = 0xD553AB,
    blue = 0x61AFE3,
    brown = 0x964B00,
    green = 0x89CA60,
    red = 0xcc3300,
    black = 0x0C0C0C
}

components.updateComponents()

-- Download Custom Libs
local req = http.get("https://api.github.com/repos/manaphoenix/CC_OC-Code/git/trees/main?recursive=1")
local gitTemplate = "https://raw.githubusercontent.com/manaphoenix/CC_OC-Code/main/"
local files = textutils.unserialiseJSON(req.readAll())
req.close()

for _,v in pairs(files.tree) do
    if v.path:match("lib/.-%.lua") then
        if not fs.exists(v.path) then
            req = http.get(gitTemplate .. v.path)
            if req then
                local file = fs.open(v.path, "w")
                file.write(req.readAll())
                file.close()
            end
        end
    end
end

-- set colors
for i, v in pairs(pal) do term.setPaletteColor(colors[i], v) end

if (components.monitor) then
    for i, v in pairs(pal) do
        components.monitor.setPaletteColor(colors[i], v)
    end
end

local function runShell()
    shell.run("shell")
end

parallel.waitForAny(peripheralWatchDog, runShell)
shell.exit()
