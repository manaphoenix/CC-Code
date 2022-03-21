-- Original created by 9551Dev, updated to work with 1.18.x
if not fs.exists("lib/log.lua") then
    shell.run("wget https://github.com/9551-Dev/apis/raw/main/log.lua")
end

-- variable init
local history, cache, cfg = {}, {}, {}
local wrap = peripheral.find("occultism:storage_controller")
if not wrap then error("failed to find Storage interface", 0) end
local old_list = wrap.list() -- convert_to_name(wrap.list())
local api = require("lib/log")
local mons = {peripheral.find("monitor")}
local logs = {}
local list = {}
local function log(str, type) for _, v in pairs(logs) do v(str, type) end end
local lt = debug.getmetatable(api.create_log(term)).__index

-- util functions
local function loadItem(str)
    local temp = {}
    if fs.exists(str) then
        local file = fs.open(str, "r")
        temp = textutils.unserialise(file.readAll())
        file.close()
    end
    return temp
end

local function writeToCache()
    local file = fs.open("ae_name.cache", "w")
    file.write(textutils.serialise(cache))
    file.close()
end

local function getName(item)
    local index, itemTable = item[1], item[2]
    local name = cfg.use_display_names and wrap.getItemDetail(index).displayName or itemTable.name
    if not cache[index] then
        cache[index] = name
        log("found unnamed item " .. name .. " adding into name cache....", lt.warn)
    end
    return name
end

local function dump(info)
    local lg = logs[math.random(1, #logs)]
    lg:dump("ae")
    local file = fs.open("ae.history", "w")
    file.write(textutils.serialise(lg.history))
    file.close()
end

-- init
cfg = loadItem("ae.cfg")
if cfg.update_time == nil then
    cfg = {
        update_time = 0,
        log_frequency = 1,
        use_display_names = true,
        keep_log_history = true
    }
    local file = fs.open("ae.cfg", "w")
    file.write(textutils.serialise(cfg))
    file.close()
end
history = cfg.keep_log_history and loadItem("ae.history") or {}
cache = loadItem("ae_name.cache")

for _, v in pairs(mons) do
    v.clear()
    v.setTextScale(0.5)
    v.setCursorPos(1, 1)
    v.setBackgroundColor(colors.orange)
    local _log = api.create_log(v, "item logger", "\127")
    _log.history = history
    table.insert(logs, _log)
    v.setBackgroundColor(colors.black)
    v.setCursorPos(1, 3)
end

for _, v in pairs(history) do
    for _, _log in pairs(logs) do
        _log(":" .. v.str, v.type)
        table.remove(_log.history, #_log.history)
    end
end

for i = 1, math.huge do
    list = wrap.list()
    for k, v in pairs(old_list) do
        local name = cache[k] or getName({k,v})
        if list[k] then
            if v.count < list[k].count then
                log(name .. " increased by: " .. tostring(list[k].count - v.count), lt.update)
            end
            if v.count > list[k].count then
                log(name .. " dropped by: " .. tostring(v.count - list[k].count), lt.error)
            end
        else
            log("Removed " .. name .. " from system", lt.fatal)
        end
    end
    for k, v in pairs(list) do
        local name = cache[k] or getName({k,v})
        if not old_list[k] then
            log("Added " .. name .. " into system", lt.success)
        end
    end
    writeToCache()
    old_list = list
    if i % cfg.log_frequency == 0 then dump(math.ceil(i / cfg.log_frequency)) end
    sleep(cfg.update_time)
end
