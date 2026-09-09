-- lib/cli.lua

local cli = {}
cli.__index = cli

-- =========================
-- Constructor
-- =========================

---@param name string
---@param opts table?
---@return table
function cli.new(name, opts)
    opts = opts or {}

    local self = setmetatable({}, cli)

    self.name = name or "app"
    self.description = opts.description or ""
    self.flags = opts.flags or {}
    self.rawArgs = {}

    self.args = {}
    self.flagsParsed = {}

    return self
end

-- =========================
-- Parse arguments
-- =========================

---@param args table
function cli:parse(args)
    self.rawArgs = args

    for _, a in ipairs(args) do
        if a:sub(1,1) == "-" then
            -- handle --help or -abc style
            if a == "-h" or a == "--help" then
                self:help()
                return false
            end

            -- combined flags: -abc
            for i = 2, #a do
                self.flagsParsed[a:sub(i,i)] = true
            end
        else
            table.insert(self.args, a)
        end
    end

    return true
end

-- =========================
-- Helpers
-- =========================

---@param flag string
function cli:has(flag)
    return self.flagsParsed[flag] == true
end

---@return string|nil
function cli:target()
    return self.args[1]
end

-- =========================
-- Help system
-- =========================

function cli:help()
    print(self.name .. " CLI tool")
    print("")

    if self.description ~= "" then
        print(self.description)
        print("")
    end

    print("Usage:")
    print("  " .. self.name .. " [target] [-flags]")
    print("")

    if next(self.flags) then
        print("Flags:")
        for k, v in pairs(self.flags) do
            print("  -" .. k .. "  " .. v)
        end
    else
        print("No flags defined.")
    end
end

return cli