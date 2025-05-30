--@module parallelAction

--- @class parallelAction
local module = {}

--- @type fun()[]
local actions = {}

--- @type integer
local maxActionsPerBatch = 250 -- cannot be higher than 255, but for safety batch size should stay below that, so 250 maximum

--- @type boolean
local executing = false

--- Set the maximum number of actions per batch
--- @param size integer
function module.setBatchSize(size)
    assert(type(size) == "number" and math.floor(size) == size, "Batch size must be an integer")
    assert(size <= 255, "Batch size cannot be higher than 255")
    maxActionsPerBatch = size
end

--- Adds an action to the list of actions to be executed in parallel
--- @param action fun()
function module.addAction(action)
    assert(type(action) == "function", "Action must be a function")
    assert(not executing, "Cannot add actions while executing")
    actions[#actions + 1] = action
end

--- Executes all actions added with addAction in parallel
--- @param optStr? string Optional identifier string for logging
--- @param verbose? boolean Whether to print execution logs
function module.execute(optStr, verbose)
    if executing or #actions == 0 then return end

    executing = true
    if verbose then
        print("executing: " .. (optStr or ""))
    end

    local total = #actions

    if total <= maxActionsPerBatch then
        parallel.waitForAll(table.unpack(actions, 1, total))
    else
        local batchSize = maxActionsPerBatch
        for i = 1, total, batchSize do
            local upper = math.min(i + batchSize - 1, total)
            local batchLen = upper - i + 1
            local batch = table.create and table.create(batchLen, 0) or {}  -- Use table.create if available (Lua 5.4+ or CC-Tweaked)
            for j = 1, batchLen do
                batch[j] = actions[i + j - 1]
            end
            parallel.waitForAll(table.unpack(batch, 1, batchLen))
        end
    end

    -- Clear the actions array in-place
    for i = 1, total do
        actions[i] = nil
    end

    executing = false
    if verbose then
        print("execution finished")
    end
end

return module
