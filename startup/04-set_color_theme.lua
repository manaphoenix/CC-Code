-- Initialize palette
local palette = {
    white     = 0xE8E0FF,
    orange    = 0xFF6F40,
    magenta   = 0xA040FF,
    lightBlue = 0x6CB4E3,
    yellow    = 0xFFD540,
    lime      = 0x8FF0B5,
    pink      = 0xFFA3F7,
    gray      = 0x271B45,
    lightGray = 0x3B2A6E,
    cyan      = 0x3D88CE,
    purple    = 0x7B29D1,
    blue      = 0x5D6CFF,
    brown     = 0x7F2830,
    green     = 0xA6D250,
    red       = 0xFF559D,
    black     = 0x100720
}

-- Apply palette to terminal
for name, color in pairs(palette) do
    term.setPaletteColor(colors[name], color)
end

-- Apply palette to monitors, if any
local monitors = { peripheral.find("monitor") }
if #monitors == 0 then return end -- early return pattern

for _, monitor in ipairs(monitors) do
    -- Apply palette once per monitor
    for name, color in pairs(palette) do
        monitor.setPaletteColor(colors[name], color)
    end
    monitor.clear()
    monitor.setCursorPos(1, 1)
end
