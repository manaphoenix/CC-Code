-- 01-folder_creation.lua

-- Folder layout
-- Ensures all required directories exist for the system
--
-- apps/       User-run programs
-- config/     User-editable configuration
-- data/       Persistent runtime state
-- lib/        Shared libraries and internal modules
-- logs/       Diagnostic output and execution logs
-- themes/     Theme files and configurations

local folders = {
    "apps",
    "config",
    "data",
    "lib",
    "logs",
    "themes"
}

for _, name in ipairs(folders) do
    if not fs.exists(name) then
        fs.makeDir(name)
    end
end
