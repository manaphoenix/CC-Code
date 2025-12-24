local snapshot = {}

local FILE_PATH = "data/vsengineState.dat"

function snapshot.load()
    if not fs.exists(FILE_PATH) then
        return nil
    end

    local file = fs.open(FILE_PATH, "r")
    if not file then
        return nil
    end

    local raw = file.readAll()
    file.close()

    if not raw then
        return nil
    end

    local data = textutils.unserialize(raw)
    if type(data) ~= "table" then
        return nil
    end

    -- ensure isOff always exists (old saves might not have it)
    if data.isOff == nil then
        data.isOff = false
    end

    return data
end

function snapshot.save(state)
    if type(state) ~= "table" then
        return false
    end

    local file = fs.open(FILE_PATH, "w")
    if not file then
        return false
    end

    file.write(textutils.serialize(state))
    file.close()

    return true
end

return snapshot
