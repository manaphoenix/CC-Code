-- Unit Testing Library
local module = {}

local startTime = os.clock()

function module.restart()
    startTime = os.clock()
end

function module.calculate()
    return os.clock() - startTime
end

function module.startTest(name)
    print("Starting test: " .. name)
    module.restart()
end

function module.endTest(name)
    print("Ending test: " .. name)
    print("Time taken: " .. module.calculate())
end

function module.doTest(name, func)
    module.startTest(name)
    func()
    module.endTest(name)
end

return module