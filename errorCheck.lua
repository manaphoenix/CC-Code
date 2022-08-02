-- add completion if it does not exist
local completions = shell.getCompletionInfo()
if not completions[shell.getRunningProgram()] then
    local completion = require("cc.shell.completion")
    local complete = completion.build(
    completion.file
    )
    shell.setCompletionFunction(shell.getRunningProgram(), complete)
    print("Auto completion added; please try running the command again.")
    return
end

-- program
local args = {...}
local file = args[1]
local fg = "e"
local bg = "f"
local format = "[%1] [%2] %3"
-- %1 is file
-- %2 is line number
-- %3 is message
local saveToFile = true -- if true, will save to file.
local errorLog = "errorLog.log" -- file to save errors to.

-- repack the rest of the arguments into a table
local targs = {}
for i = 2, #args do
    table.insert(targs, args[i])
end

if not file then
    print("No file specified")
    return
end

file = fs.exists(file) and file or file .. ".lua"

local function runFile()
    parallel.waitForAll(
        function()
            local f = loadfile(file)
            if f then
                f(table.unpack(targs))
            else
                error("file does not exist or could not be loaded!")
            end
        end)
end

local function printToConsole(newStr)
    term.clear()
    term.setCursorPos(1, 1)
    print("An error has occurred:")
    term.blit(newStr, fg:rep(#newStr), bg:rep(#newStr))
    term.setCursorPos(1, select(2, term.getCursorPos()) + 2)
end

local function errorHandler(err)
    local newStr = format:gsub("%%1", err:match(".*%.lua")):gsub("%%2", err:match("%:(%d+)")):gsub("%%3", err:match("%:%d+%: (.*)"))
    printToConsole(newStr)
    if saveToFile then
        local f = fs.open(errorLog, "a")
        f.writeLine(newStr)
        f.close()
    end
    print("Press any key to continue")
    os.pullEvent("key")
end

xpcall(runFile, errorHandler)
