-- themes/cyberdream.lua
return {
    meta = {
        name = "CyberDream",
        author = "Manaphoenix",
        description = "A dark cyberpunk theme based on the CyberDream WezTerm palette",
        version = 1.2,
    },

    colors = {
        -- Core
        white = 0xffffff,
        black = 0x16181a,

        -- Indexed color
        orange = 0xffbd5e,

        -- ANSI / bright ANSI mappings
        red = 0xff6e5e,
        green = 0x5eff6c,
        yellow = 0xf1ff5e,
        blue = 0x5ea1ff,
        magenta = 0xff5ef1,
        cyan = 0x5ef1ff,
        gray = 0x3c4048,

        -- CC:Tweaked palette aliases
        lightGray = 0x7b8496,
        brown = 0xb36a3d,
        lime = 0xb6ff5e,
        pink = 0xff5ea0,
        lightBlue = 0x7fc8ff,
        purple = 0xbd5eff,
    },
    default = {
        bg = "#16181a",
        bg_alt = "#1e2124",
        bg_highlight = "#3c4048",
        fg = "#ffffff",
        grey = "#7b8496",
        blue = "#5ea1ff",
        green = "#5eff6c",
        cyan = "#5ef1ff",
        red = "#ff6e5e",
        yellow = "#f1ff5e",
        magenta = "#ff5ef1",
        pink = "#ff5ea0",
        orange = "#ffbd5e",
        purple = "#bd5eff",
    }
}
