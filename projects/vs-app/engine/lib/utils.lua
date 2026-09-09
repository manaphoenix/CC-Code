-- VS Engine Utilities
-- Helper functions for the VS Engine system

local utils = {}

-- Debug printing function
function utils.debugPrint(message, data)
    if not data then
        print(message)
    else
        print(message)
        if type(data) == "table" then
            for key, value in pairs(data) do
                if type(value) ~= "table" then
                    print(string.format("\t%s: %s", key, value))
                end
            end
        else
            print(string.format("\t%s", data))
        end

        -- Round to nearest 100th of a second for timing
        local lastRec = os.clock() - (utils.lastSent or 0)
        print("Last received: " .. math.floor(lastRec * 100) / 100 .. " seconds ago")
        print("Time: " .. os.date("%I:%M:%S %p"))
    end
end

-- Store last sent time for debug purposes
utils.lastSent = 0

return utils
