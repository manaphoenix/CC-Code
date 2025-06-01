-- ldoc.lua
return {
    name        = "CC_OC-Code",
    description = "A collection of ComputerCraft & OpenComputers utilities",
    author      = "manaphoenix",
    license     = "CC0-1.0",
    version     = "1.0.0",

    -- Tell LDoc to scan all Lua files under lib/ and apps/ for doc comments.
    source      = {
        dir     = "./lib", -- your library code (modules, utils, etc.)
        pattern = "*.lua",
        recurse = true,
    },

    -- If you also want to document 'apps/' (for example),
    -- you could add a second entry:
    -- source = {
    --   { dir = "./lib",   pattern = "*.lua", recurse = true },
    --   { dir = "./apps",  pattern = "*.lua", recurse = true }
    -- },

    output      = "docs", -- Put generated HTML into the existing docs/ folder
    exclude     = {
        -- If there are subfolders you do NOT want documented, list them here:
        -- "./lib/experimental/*"
    },

    -- (Optional) You can customize the LDoc theme, header/footer, etc.
    -- See the LDoc manual for details: https://stevedonovan.github.io/ldoc/manual.html
}
