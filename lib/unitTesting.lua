-- Unit Testing Library
local module = {}

local startTime = os.epoch("utc")
local strs = {
    start = "Testing: %s",
    time = "Took: %s"
}

local function nanoToMs(n)
    local ms = n/1000000
    ms = math.floor(ms*100)/100
    return ms
end

local function mark()
    if ccemux then
        startTime = os.epoch("nano")
    else
        startTime = os.epoch("utc")
    end
end

local function getEndTime()
    if ccemux then
        return os.epoch("nano") - startTime
    end
    return os.epoch("utc") - startTime
end

local function errHandler(err)
    print("Unit test failed: " .. err)
end

local function calculate()
    local endTime = getEndTime()
    local calcTime = ccemux and endTime / 1000000000 or endTime/1000
    calcTime = math.floor(calcTime)
    if calcTime > 0 then
        return os.date("!%X",calcTime) .. "s"
    elseif endTime > 0 and not ccemux then
        return endTime .. "ms"
    elseif nanoToMs(endTime) > 0 and ccemux then
        return "~" .. nanoToMs(endTime).. "ms"
    elseif endTime > 0 and ccemux then
        return endTime .. "ns"
    else
        return "Too small to calculate"
    end
end

---test how long a function takes to complete
---@param func function The function to test
---@param name? string Names the test (Default: unitTest)
function module.test(func, name)
    name = name or "unitTest"
    print(strs.start:format(name))
    mark()
    xpcall(func, errHandler)
    local format = calculate()
    print(strs.time:format(format))
end

return module