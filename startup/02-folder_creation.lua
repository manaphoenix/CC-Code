-- create folders if they don't exist.
local folders = {
    "apps",
    "assets",
    "bin",
    "config",
    "data",
    "docs",
    "lib",
    "logs",
    "services",
    "startup",
    "tmp",
    "workflows",
}

for _, v in pairs(folders) do
    if not fs.exists(v) then fs.makeDir(v) end
end
