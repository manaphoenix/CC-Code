-- Folder layout
-- Organized by ownership and responsibility
--
-- apps/     User-run programs
-- assets/   Non-code resources
-- config/   User-editable configuration
-- data/     Persistent runtime state
-- lib/      Shared libraries and internal modules
-- logs/     Diagnostic output and execution logs
-- startup/  Modular startup scripts
-- tmp/      Temporary files
-- themes/   Theme assets
-- tasks/    Task definitions (future-facing, harmless to create early)
-- types/    Type definitions (for the type system)

local folders = {
    "apps",
    "assets",
    "config",
    "data",
    "lib",
    "logs",
    "startup",
    "themes",
    "tmp",
    "tasks",
    "types",
}

for _, name in ipairs(folders) do
    if not fs.exists(name) then
        fs.makeDir(name)
    end
end
