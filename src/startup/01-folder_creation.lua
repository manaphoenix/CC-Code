-- 01-folder_creation.lua
-- Creates the required filesystem layout.

local folders = {
    "apps",
    "apps/system", -- Built-in apps; distinguish from user-installed ones
    "apps/user",   -- User apps

    "config",      -- User-editable configuration

    "data",
    "data/cache", -- Safely disposable generated data
    "data/state", -- Persistent state to retain

    "lib",
    "lib/core",   -- Internal system modules
    "lib/vendor", -- Third-party libraries

    "logs",
    "logs/errors", -- errors and crash reports
    "logs/app",    -- app specific logs

    "themes",      -- Theme definitions
}

local function ensureDirectory(path)
    if not fs.isDir(path) then
        fs.makeDir(path)
    end
end

for _, path in ipairs(folders) do
    ensureDirectory(path)
end
