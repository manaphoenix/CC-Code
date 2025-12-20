-- Core filesystem layout
-- These folders define ownership and responsibility, not file type.
--
-- apps/    → User-run programs (CLI, menu, GUI — all the same in CC)
-- assets/  → Non-code resources (UI data, templates, text, etc.)
-- config/  → User-editable configuration (written once, edited later)
-- data/    → Persistent runtime state (saves, caches, install state)
-- lib/     → Shared libraries and internal modules (not run directly)
-- logs/    → Diagnostic output and execution logs
-- startup/ → Modular startup scripts loaded automatically on boot (CraftOS)
-- tmp/     → Temporary files (safe to delete on reboot)
-- tasks/   → Task definitions for the task runner (added when implemented)

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
    "tasks", -- future-facing, harmless to create early
}

for _, name in ipairs(folders) do
    if not fs.exists(name) then
        fs.makeDir(name)
    end
end
