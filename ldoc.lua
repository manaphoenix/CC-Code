-- ldoc.lua
return {
    name        = "CC_OC-Code",
    description = "A collection of ComputerCraft & OpenComputers utilities",
    author      = "manaphoenix",
    license     = "CC0-1.0",
    version     = "1.0.0",

    source      = {
        {
            dir     = "./lib",
            pattern = "*.lua",
            recurse = true
        },
        -- { dir = "./apps", pattern = "*.lua", recurse = true },  -- optional
    },

    output      = "docs",
    exclude     = {
        -- "./lib/experimental/*"
    },
}
