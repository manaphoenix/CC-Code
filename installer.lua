-- installer.lua (v3 - src aware installer)

local repoUser = "manaphoenix"
local repoName = "CC-Code"
local branch = "main"

local baseRaw = ("https://raw.githubusercontent.com/%s/%s/%s/"):format(repoUser, repoName, branch)

-- =========================
-- Utilities
-- =========================

local function ensureDir(path)
	if path == "" then
		return
	end

	local parts = {}
	for part in string.gmatch(path, "[^/]+") do
		table.insert(parts, part)
	end

	local current = ""
	for i = 1, #parts - 1 do
		current = current .. parts[i] .. "/"
		if not fs.exists(current) then
			fs.makeDir(current)
		end
	end
end

local function writeFile(path, content)
	ensureDir(fs.getDir(path))
	local f = fs.open(path, "w")
	f.write(content)
	f.close()
end

local function get(url)
	local r = http.get(url, {
		["User-Agent"] = "CC-Tweaked Installer",
	})

	if not r then
		return nil
	end
	local data = r.readAll()
	r.close()
	return data
end

local function download(src, dest)
	local url = baseRaw .. src

	local content = get(url)
	if not content then
		print("✗ Failed: " .. src)
		return false
	end

	writeFile(dest, content)
	print("✓ " .. dest)
	return true
end

-- =========================
-- Core installer
-- =========================

local function installMap(map)
	for _, entry in ipairs(map) do
		download(entry.src, entry.dest)
	end
end

-- =========================
-- INSTALL PROFILE
-- =========================

local installProfile = {
	-- startup system
	{ src = "src/startup/01-folder_creation.lua", dest = "startup/01-folder_creation.lua" },
	{ src = "src/startup/02-config_creation.lua", dest = "startup/02-config_creation.lua" },
	{ src = "src/startup/03-set_color_theme.lua", dest = "startup/03-set_color_theme.lua" },
	{ src = "src/startup/04-set_aliases.lua", dest = "startup/04-set_aliases.lua" },
	{ src = "src/startup/05-setup_term.lua", dest = "startup/05-setup_term.lua" },

	-- libraries
	{ src = "src/lib/blit-util.lua", dest = "lib/blit-util.lua" },
	{ src = "src/lib/ledger.lua", dest = "lib/ledger.lua" },
	{ src = "src/lib/cli.lua", dest = "lib/cli.lua" },
	{ src = "src/lib/resolver.lua", dest = "lib/resolver.lua" },
	{ src = "src/lib/theme-manager.lua", dest = "lib/theme-manager.lua" },
	{ src = "src/lib/serializer.lua", dest = "lib/serializer.lua" },
	{ src = "src/lib/unit-testing.lua", dest = "lib/unit-testing.lua" },
	{ src = "src/lib/parallel-actions.lua", dest = "lib/parallel-actions.lua" },
	{ src = "src/lib/simple-button.lua", dest = "lib/simple-button.lua" },

	-- apps
	{ src = "src/apps/launcher.lua", dest = "apps/launcher.lua" },
	{ src = "src/apps/gfetch.lua", dest = "apps/gfetch.lua" },
	{ src = "src/apps/theme-picker.lua", dest = "apps/theme-picker.lua" },

	-- themes
	{ src = "src/themes/default.lua", dest = "themes/default.lua" },
	{ src = "src/themes/cyberdream.lua", dest = "themes/cyberdream.lua" },
	{ src = "src/themes/2077.lua", dest = "themes/2077.lua" },

	-- projects
	{ src = "projects/newapp/main.lua", dest = "apps/newapp/main.lua" },
	{ src = "projects/newapp/filesystem.lua", dest = "apps/newapp/filesystem.lua" },
	{ src = "projects/newapp/manifest.lua", dest = "apps/newapp/manifest.lua" },
	{ src = "projects/newapp/render.lua", dest = "apps/newapp/render.lua" },
	{ src = "projects/newapp/templates.lua", dest = "apps/newapp/templates.lua" },
	{ src = "projects/newapp/util.lua", dest = "apps/newapp/util.lua" },
}

-- =========================
-- Main
-- =========================

term.clear()
term.setCursorPos(1, 1)

print("Ashgard Installer v2")
print("----------------------\n")

installMap(installProfile)

print("\nDone.")
