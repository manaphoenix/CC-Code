local args = { ... }

-- Load config from /.gfetch.conf or /config/.gfetch.conf (first found)
local config = {}
local confPaths = { ".gfetch.conf", "config/.gfetch.conf" }
for _, path in ipairs(confPaths) do
    if fs.exists(path) then
        local file = fs.open(path, "r")
        local confData = textutils.unserialize(file.readAll())
        file.close()
        if type(confData) == "table" then
            config = confData
            break
        end
    end
end

-- handle no default confg exists:
if not config.gfetch_dir then
    config.gfetch_dir = ""
    config.aliases = {}
    local file = fs.open("config/.gfetch.conf", "w")
    file.write(textutils.serialize(config))
    file.close()
end

-- Handle alias management
if args[1] == "--alias" and args[2] and args[3] then
    local action = args[2]
    local aliasKey = args[3]

    if action == "add" and args[4] then
        config.aliases[aliasKey] = args[4]
        print("Alias '" .. aliasKey .. "' set to: " .. args[4])
    elseif action == "remove" then
        if config.aliases[aliasKey] then
            config.aliases[aliasKey] = nil
            print("Alias '" .. aliasKey .. "' removed.")
        else
            print("Alias '" .. aliasKey .. "' does not exist.")
        end
    else
        print("Invalid alias command. Usage:")
        print("  gfetch --alias add <key> <owner/repo/branch>")
        print("  gfetch --alias remove <key>")
        return
    end

    -- Save updated config
    local file = fs.open("config/.gfetch.conf", "w")
    file.write(textutils.serialize(config))
    file.close()
    return
end


local function split(str)
    local parts = {}
    for part in string.gmatch(str, "%S+") do
        table.insert(parts, part)
    end
    return parts
end

local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function decodeBase64(data)
    data = string.gsub(data, '[^' .. b .. '=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d%d%d%d%d%d', function(x)
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0) end
        return string.char(c)
    end))
end

local function fetch(owner, repo, branch, path, output)
    local api_url = ("https://api.github.com/repos/%s/%s/contents/%s?ref=%s"):format(owner, repo, path, branch)
    local res, err = http.get(api_url, { ["User-Agent"] = "gfetch" })
    if not res then return false, "API error: " .. tostring(err) end

    local data = textutils.unserializeJSON(res.readAll())
    res.close()

    if not data or not data.content then return false, "Invalid GitHub response" end

    local content = data.content:gsub("\n", "")
    local decoded = decodeBase64(content)

    local file = fs.open(output, "w")
    if not file then return false, "Failed to open " .. output end

    file.write(decoded)
    file.close()
    return true
end

local function parseTarget(input, aliases)
    aliases = aliases or {}

    local owner, repo, branch, path = input:match("([^/]+)/([^/]+)/([^/]+)/(.+)")
    if owner and repo and branch and path then
        return { owner = owner, repo = repo, branch = branch, path = path }
    end

    -- Try alias expansion: aliasKey/path/to/file
    local aliasKey, aliasRest = input:match("([^/]+)/(.+)")
    if aliasKey and aliases[aliasKey] then
        local expanded = aliases[aliasKey] .. "/" .. aliasRest
        return parseTarget(expanded, aliases) -- recursive call with expanded path
    end

    return nil, "Invalid path: " .. input
end

local function readGfetchLines(path)
    local lines = {}
    if path:match("^https?://") then
        local res = http.get(path)
        if not res then error("Failed to load remote .gfetch file") end
        for line in res.readAll():gmatch("[^\r\n]+") do table.insert(lines, line) end
        res.close()
    else
        if not fs.exists(path) then error(".gfetch file not found at " .. path) end
        local file = fs.open(path, "r")
        while true do
            local line = file.readLine()
            if not line then break end
            table.insert(lines, line)
        end
        file.close()
    end
    return lines
end

local function parseGfetch(lines)
    local baseRepo
    local targets = {}

    for i, line in ipairs(lines) do
        line = line:match("^%s*(.-)%s*$") -- trim whitespace
        if line == "" or line:match("^//") then
            -- skip blank or comment lines
        elseif not baseRepo and line:match("^#%s*([^%s]+/[^%s]+/[^%s]+)") then
            -- first header comment line with owner/repo/branch
            baseRepo = line:match("^#%s*([^%s]+/[^%s]+/[^%s]+)")
        else
            -- parse target line
            local parts = split(line)
            local target = parts[1]
            local output = parts[2]

            if target:sub(1, 2) == "./" then
                if not baseRepo then
                    error("Relative path used but no base repo header found in .gfetch file")
                end
                target = baseRepo .. "/" .. target:sub(3)
            end

            table.insert(targets, { target = target, output = output })
        end
    end

    if not baseRepo then
        error("Missing required base repo header line in .gfetch file")
    end

    return targets
end

-- batch mode
if args[1] == "--batch" and args[2] then
    local batchFile = args[2]

    if config.gfetch_dir and not batchFile:match("^/") then
        batchFile = fs.combine(config.gfetch_dir, batchFile)
    end

    local lines = readGfetchLines(batchFile)
    local targets = parseGfetch(lines)

    print("Installing files from .gfetch:")
    for _, entry in ipairs(targets) do
        local parsed, err = parseTarget(entry.target, config.aliases)
        if not parsed then
            print("  [!] " .. err)
        else
            local output = entry.output or parsed.path
            io.write("  \26 " .. output .. " ... ")
            local ok, msg = fetch(parsed.owner, parsed.repo, parsed.branch, parsed.path, output)
            if ok then
                print("done.")
            else
                print("failed: " .. msg)
            end
        end
    end
    return
end

-- single file
if not args[1] then
    if shell then
        local completion = require "cc.shell.completion"

        local function handleCompletion(shellObj, strToComplete, previousArgs)
            if previousArgs[1] == "gfetch" and previousArgs[2] == nil and strToComplete:match("^-") then
                return completion.choice(shellObj, strToComplete, previousArgs, { "--batch", "--alias" })
            elseif previousArgs[2] == "--batch" then
                local path = (config.gfetch_dir or "") .. (previousArgs[3] or "")
                if fs.exists(path) then
                    local files = fs.list(path)
                    local fileCompletions = {}
                    for i,v in ipairs(files) do
                        if v:match("%.gfetch$") then
                            table.insert(fileCompletions, v)
                        end
                    end
                    return completion.choice(shellObj, strToComplete, previousArgs, fileCompletions)
                end
                return {}
            elseif previousArgs[2] == "--alias" and previousArgs[3] == nil then
                return completion.choice(shellObj, strToComplete, previousArgs, { "add", "remove" })
            elseif previousArgs[2] == "--alias" and previousArgs[3] == "add" then
                return {}
            elseif previousArgs[2] == "--alias" and previousArgs[3] == "remove" then
                local keys = {}
                for k in pairs(config.aliases or {}) do table.insert(keys, k) end
                return completion.choice(shellObj, strToComplete, previousArgs, keys)
            end
            local keys = {}
            for k in pairs(config.aliases or {}) do table.insert(keys, k .. "/") end
            return completion.choice(shellObj, strToComplete, previousArgs, keys)
        end

        local complete = completion.build(
            {
                handleCompletion,
                many = true
            }
        )

        shell.setCompletionFunction(shell.getRunningProgram(), complete)
    end


    print("Usage:")
    print("  gfetch owner/repo/branch/path/to/file [output]")
    print("  gfetch --batch file_or_url")
    return
end

local parsed, err = parseTarget(args[1], config.aliases)
if not parsed then error(err) end
local output = args[2] or parsed.path

io.write("Downloading \26 " .. output .. " ... ")
local ok, msg = fetch(parsed.owner, parsed.repo, parsed.branch, parsed.path, output)
if ok then
    print("done.")
else
    print("failed: " .. msg)
end
