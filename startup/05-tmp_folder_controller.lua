-- Clear the tmp folder if it exists
local function clearTmpFolder()
    if not fs.exists("tmp") then return end

    for _, name in ipairs(fs.list("tmp")) do
        fs.delete(fs.combine("tmp", name))
    end
end

-- Main
if _G.startupConfig and _G.startupConfig.clearTmp then
    clearTmpFolder()
end
