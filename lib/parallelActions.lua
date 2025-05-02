--@module parallelAction

--- @class parallelAction
local module = {}

--- @type fun()[]
local actions = {}

--- @type integer
local maxActionsPerBatch = 250

--- @type boolean
local executing = false

--- Set the maximum number of actions per batch
--- @param size integer
function module.setBatchSize(size)
    assert(type(size) == "number" and math.floor(size) == size, "Batch size must be an integer")
    maxActionsPerBatch = size
end

--- Adds an action to the list of actions to be executed in parallel
--- @param action fun()
function module.addAction(action)
    assert(type(action) == "function", "Action must be a function")
    assert(not executing, "Cannot add actions while executing")
    table.insert(actions, action)
end

--- Executes all actions added with addAction in parallel
function module.execute()
    if executing then return end
    executing = true

    local count = #actions
    if count == 0 then return end

    if count <= maxActionsPerBatch then
        parallel.waitForAll(table.unpack(actions))
    else
        for i = 1, count, maxActionsPerBatch do
            --- @type fun()[]
            local batch = {}
            for j = i, math.min(i + maxActionsPerBatch - 1, count) do
                table.insert(batch, actions[j])
            end
            parallel.waitForAll(table.unpack(batch))
        end
    end

    -- Clear actions table in-place
    for i = 1, count do
        actions[i] = nil
    end

    executing = false
end

return module
