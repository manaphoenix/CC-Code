local input = "manaphoenix/CC-Code/main/app/gfetch.lua"

local owner, repo, branch, path = input:match("([^/]+)/([^/]+)/([^/]+)/(.+)")

assert(owner == "manaphoenix", "Owner got wrong value: '" .. owner .. "'")
assert(repo == "CC-Code", "Repo got wrong value: '" .. repo .. "'")
assert(branch == "main", "Branch got wrong value: '" .. branch .. "'")
assert(path == "app/gfetch.lua", "Path got wrong value: '" .. path .. "'")