-- create folders if they don't exist.
local folders = {
    "config",
    "data",
    "installers", -- or "setup"
    "lib",
    "logs",
    "tmp",
    "assets",
    "apps",
    "startup",  -- renamed from startup for clarity
    "bin",      -- optional
    "services", -- optional
    "docs"      -- optional
}

for _, v in pairs(folders) do
    if not fs.exists(v) then fs.makeDir(v) end
end
