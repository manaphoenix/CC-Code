local args = {...}
local http = http
local fs = fs
local function split(str)
  local parts = {}
  for part in string.gmatch(str, "%S+") do
    table.insert(parts, part)
  end
  return parts
end

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function decodeBase64(data)
  data = string.gsub(data, '[^'..b..'=]', '')
  return (data:gsub('.', function(x)
    if x == '=' then return '' end
    local r,f='',(b:find(x)-1)
    for i=6,1,-1 do r=r..(f%2^i - f%2^(i-1) > 0 and '1' or '0') end
    return r
  end):gsub('%d%d%d%d%d%d%d%d', function(x)
    local c=0
    for i=1,8 do c=c + (x:sub(i,i) == '1' and 2^(8-i) or 0) end
    return string.char(c)
  end))
end


local function fetch(owner, repo, branch, path, output)
  local api_url = ("https://api.github.com/repos/%s/%s/contents/%s?ref=%s"):format(owner, repo, path, branch)
  local res, err = http.get(api_url, {["User-Agent"] = "gfetch"})
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

local function parseTarget(input)
  local owner, repo, branch, path = input:match("([^/]+)/([^/]+)/([^/]+)/(.+)")
  if not (owner and repo and branch and path) then
    return nil, "Invalid path: " .. input
  end
  return { owner = owner, repo = repo, branch = branch, path = path }
end

-- batch mode
if args[1] == "--batch" and args[2] then
  local lines = {}
  if args[2]:match("^https?://") then
    local res = http.get(args[2])
    if not res then error("Failed to load remote .gfetch file") end
    for line in res.readAll():gmatch("[^\r\n]+") do table.insert(lines, line) end
    res.close()
  else
    if not fs.exists(args[2]) then error(".gfetch file not found") end
    local file = fs.open(args[2], "r")
    for line in file.readLine do table.insert(lines, line) end
    file.close()
  end

  print("Installing files from .gfetch:")
  for i, line in ipairs(lines) do
    line = line:match("^%s*(.-)%s*$") -- trim
    if line == "" or line:match("^//") then goto continue end
    local parts = split(line)
    local target, outPath = parts[1], parts[2]
    local parsed, err = parseTarget(target)
    if not parsed then print("  [!] " .. err) goto continue end
    outPath = outPath or parsed.path

    io.write("  → " .. outPath .. " ... ")
    local ok, msg = fetch(parsed.owner, parsed.repo, parsed.branch, parsed.path, outPath)
    if ok then
      print("done.")
    else
      print("failed: " .. msg)
    end
    ::continue::
  end
  return
end

-- single file
if not args[1] then
  print("Usage:")
  print("  gfetch owner/repo/branch/path/to/file [output]")
  print("  gfetch --batch file_or_url")
  return
end

local parsed, err = parseTarget(args[1])
if not parsed then error(err) end
local output = args[2] or parsed.path

io.write("Downloading \26 " .. output .. " ... ")
local ok, msg = fetch(parsed.owner, parsed.repo, parsed.branch, parsed.path, output)
if ok then
  print("done.")
else
  print("failed: " .. msg)
end
