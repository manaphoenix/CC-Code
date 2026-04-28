-- installer.lua (v2 - rootfs aware installer)

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
	{ src = "rootfs/startup/01-folder_creation.lua", dest = "startup/01-folder_creation.lua" },
	{ src = "rootfs/startup/02-config_creation.lua", dest = "startup/02-config_creation.lua" },
	{ src = "rootfs/startup/03-set_color_theme.lua", dest = "startup/03-set_color_theme.lua" },
	{ src = "rootfs/startup/04-set_aliases.lua", dest = "startup/04-set_aliases.lua" },
	{ src = "rootfs/startup/05-setup_term.lua", dest = "startup/05-setup_term.lua" },

	-- libraries
	{ src = "rootfs/lib/BlitUtil.lua", dest = "lib/BlitUtil.lua" },
	{ src = "rootfs/lib/ledger.lua", dest = "lib/ledger.lua" },
	{ src = "rootfs/lib/cli.lua", dest = "lib/cli.lua" },
	{ src = "rootfs/lib/resolver.lua", dest = "lib/resolver.lua" },
	{ src = "rootfs/lib/theme_manager.lua", dest = "lib/theme_manager.lua" },
	{ src = "rootfs/lib/serializer.lua", dest = "lib/serializer.lua" },
	{ src = "rootfs/lib/unitTesting.lua", dest = "lib/unitTesting.lua" },
	{ src = "rootfs/lib/parallelActions.lua", dest = "lib/parallelActions.lua" },
	{ src = "rootfs/lib/simpleButton.lua", dest = "lib/simpleButton.lua" },

	-- apps
	{ src = "rootfs/apps/app_launcher.lua", dest = "apps/app_launcher.lua" },
	{ src = "rootfs/apps/gfetch.lua", dest = "apps/gfetch.lua" },
	{ src = "rootfs/apps/theme_picker.lua", dest = "apps/theme_picker.lua" },

	-- themes
	{ src = "rootfs/themes/default.lua", dest = "themes/default.lua" },
	{ src = "rootfs/themes/cyberdream.lua", dest = "themes/cyberdream.lua" },
	{ src = "rootfs/themes/2077.lua", dest = "themes/2077.lua" },

	-- types
	{ src = "rootfs/types/inventory.lua", dest = "types/inventory.lua" },
	{ src = "rootfs/types/energy_storage.lua", dest = "types/energy_storage.lua" },
	{ src = "rootfs/types/fluid_storage.lua", dest = "types/fluid_storage.lua" },
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
