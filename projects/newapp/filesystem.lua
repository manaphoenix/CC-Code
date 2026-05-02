-- app/newapp/filesystem.lua

local fsys = {}

local function writeFile(path, content)
    local f = fs.open(path, "w")
    if not f then
        error("Failed to open file: " .. path)
    end
    f.write(content)
    f.close()
end

function fsys.writeApp(name, output)
    local base = "apps/" .. name

    if fs.exists(base) then
        print("Warning: overwriting existing app")
    else
        fs.makeDir(base)
    end

    writeFile(base .. "/main.lua", output.main)
    writeFile(base .. "/manifest.lua", output.manifest)
end

return fsys
