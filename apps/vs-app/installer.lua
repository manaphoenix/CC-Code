-- VS-App Installer (GUI-like)
-- Arrow keys + mouse support
-- Downloads Engine or Dashboard and shared/util.lua

--========================
-- CONFIG
--========================
local github_base = "https://raw.githubusercontent.com/manaphoenix/CC_OC-Code/main/apps/vs-app"

local programs = {
    ["Engine"] = {
        folder = "vs-engine",
        files = {
            "main.lua",
            "core.lua",
            "config/defaults.lua",
            "lib/peripherals.lua",
            "lib/state.lua",
            "lib/apply.lua",
            "lib/net.lua",
            "lib/protocol.lua",
            "lib/snapshot.lua"
        }
    },
    ["Dashboard"] = {
        folder = "vs-dashboard",
        files = {
            "main.lua",
            "core.lua",
            "config/defaults.lua",
            "lib/peripherals.lua",
            "lib/state.lua",
            "lib/net.lua",
            "lib/display.lua",
            "lib/input.lua",
            "lib/protocol.lua"
        }
    }
}

local shared_files = {
    "shared/lib/util.lua"
}

--========================
-- FUNCTIONS
--========================

local function wget_file(url, dest)
    print("Downloading " .. url .. " → " .. dest)
    local ok, err = pcall(shell.run, "wget", url, dest)
    if not ok then
        print("ERROR downloading file: " .. tostring(err))
        return false
    end
    return true
end

local function createFolders(base, files)
    for _, path in ipairs(files) do
        local dir = fs.combine(base, fs.getDir(path))
        if dir ~= "" and not fs.exists(dir) then
            fs.makeDir(dir)
        end
    end
end

local function installProgram(name, info)
    local base = info.folder

    createFolders(base, info.files)
    createFolders(base, shared_files)

    -- download program files
    for _, file in ipairs(info.files) do
        local url = github_base .. "/" .. name:lower() .. "/" .. file
        local dest = fs.combine(base, file)
        wget_file(url, dest)
    end

    -- download shared files into lib/
    for _, file in ipairs(shared_files) do
        local dest_lib = fs.combine(base, "lib/" .. file:match(".+/([^/]+)$"))
        wget_file(github_base .. "/" .. file, dest_lib)
    end

    term.clear()
    term.setCursorPos(1, 1)
    print("Installation complete! Run with:")
    print("shell.run('" .. base .. "/main.lua')")
end

local function drawMenu(selected)
    term.clear()
    term.setCursorPos(1, 1)
    print("VS-App Installer")
    print("================")
    for i, name in ipairs(program_list) do
        if i == selected then
            term.setBackgroundColor(colors.gray)
            term.setTextColor(colors.black)
            print("  " .. name .. "  ")
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
        else
            print("  " .. name .. "  ")
        end
    end
    print("\nUse Up/Down arrows or mouse click to select, Enter to install, Esc to exit.")
end

--========================
-- MAIN LOOP
--========================

program_list = {}
for name, _ in pairs(programs) do table.insert(program_list, name) end

local selected = 1
drawMenu(selected)

while true do
    local event = { os.pullEvent() }

    if event[1] == "key" then
        local key = event[2]
        if key == keys.up then
            selected = selected - 1
            if selected < 1 then selected = #program_list end
            drawMenu(selected)
        elseif key == keys.down then
            selected = selected + 1
            if selected > #program_list then selected = 1 end
            drawMenu(selected)
        elseif key == keys.enter then
            installProgram(program_list[selected], programs[program_list[selected]])
            break
        elseif key == keys.esc then
            term.clear()
            term.setCursorPos(1, 1)
            print("Installer cancelled.")
            break
        end
    elseif event[1] == "mouse_click" then
        local _, x, y = table.unpack(event)
        -- header + separator lines = 2
        -- menu starts at line 3
        local menu_y = y - 2
        if menu_y >= 1 and menu_y <= #program_list then
            selected = menu_y
            drawMenu(selected)
            installProgram(program_list[selected], programs[program_list[selected]])
            break
        end
    end
end
