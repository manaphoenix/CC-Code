local module = {}

-- Fallback utility to strip blit formatting if blitUtil not present
local function stripFormatting(str)
    return (str:gsub("{&.-}", ""))
end

-- Calculates visible string length (excluding blit codes)
local function visibleLen(str, util)
    if util and util.stripFormatting then
        return #(util.stripFormatting(str))
    else
        return #stripFormatting(str)
    end
end

local function padLeft(str, len, util)
    local vlen = visibleLen(str, util)
    if vlen < len then
        return string.rep(" ", len - vlen) .. str
    end
    return str
end

local function padCenter(str, len, util)
    local vlen = visibleLen(str, util)
    if vlen >= len then
        return str
    end
    local totalPad = len - vlen
    local leftPad = math.floor(totalPad / 2)
    local rightPad = totalPad - leftPad
    return string.rep(" ", leftPad) .. str .. string.rep(" ", rightPad)
end


local function padRight(str, len, util)
    local vlen = visibleLen(str, util)
    if vlen < len then
        return str .. string.rep(" ", len - vlen)
    end
    return str
end

local function createRenderer(writer, util)
    if writer and writer.writeLine then
        return {
            writeLine = function(line) writer.writeLine(line) end,
            strip = util and util.stripFormatting or stripFormatting,
            len = function(str) return visibleLen(str, util) end,
        }
    else
        return {
            writeLine = function(line) print(stripFormatting(line)) end,
            strip = stripFormatting,
            len = function(str) return visibleLen(str, nil) end,
        }
    end
end

local function init(config, writer, util)
    config = config or {}
    local columns = config.columns or {}
    local padding = config.padding or 1
    local rows = {}

    local renderer = createRenderer(writer, util)

    local function padCell(str, width, align)
        align = align or "left"
        if align == "left" then
            return padRight(str, width + padding, renderer)
        elseif align == "right" then
            return padLeft(str, width + padding, renderer)
        elseif align == "center" then
            return padCenter(str, width + padding, renderer)
        else
            return padRight(str, width + padding, renderer) -- fallback
        end
    end

    local obj = {}

    function obj:addRow(row)
        table.insert(rows, row)
    end

    function obj:clear()
        rows = {}
    end

    function obj:render()
        local colWidths = {}
        for i, colName in ipairs(columns) do
            colWidths[i] = renderer.len(colName)
        end
        for _, row in ipairs(rows) do
            for i, cell in ipairs(row) do
                local clen = renderer.len(cell)
                if clen > (colWidths[i] or 0) then
                    colWidths[i] = clen
                end
            end
        end

        -- Render header with different background color (e.g., blue bg, white fg)
        local headerLine = ""
        for i, col in ipairs(columns) do
            headerLine = headerLine ..
                "{&0|b}|" .. padCell(col, colWidths[i], config.align and config.align[i])
        end
        headerLine = headerLine .. "{&0|b}|{&r|r}"
        renderer.writeLine(headerLine)

        -- Render rows normally (no special background)
        for _, row in ipairs(rows) do
            local line = ""
            for i, cell in ipairs(row) do
                line = line .. "{&8}|" .. padCell(cell, colWidths[i], config.align and config.align[i])
            end
            line = line .. "{&8}|{&r}"
            renderer.writeLine(line)
        end
    end

    function obj:serializeToMarkdown(heading, filePath)
        local function escapeCell(cell)
            cell = tostring(cell or "")
            cell = cell:gsub("\\", "\\\\") -- Escape backslashes
            cell = cell:gsub("|", "\\|")   -- Escape pipes
            return cell
        end

        local function stripCell(cell)
            return renderer.strip(cell or "")
        end

        local function alignToken(align)
            if align == "left" then
                return ":---"
            elseif align == "right" then
                return "---:"
            elseif align == "center" then
                return ":---:"
            else
                return "---"
            end
        end

        -- Optional heading before table
        local md = ""
        if heading then
            md = "# " .. heading .. "\n\n"
        end

        -- Header row
        for _, col in ipairs(columns) do
            md = md .. "| " .. escapeCell(stripCell(col)) .. " "
        end
        md = md .. "|\n"

        -- Alignment row
        for i = 1, #columns do
            local align = config.align and config.align[i] or "left"
            md = md .. "| " .. alignToken(align) .. " "
        end
        md = md .. "|\n"

        -- Data rows
        for _, row in ipairs(rows) do
            for i = 1, #columns do
                md = md .. "| " .. escapeCell(stripCell(row[i] or "")) .. " "
            end
            md = md .. "|\n"
        end

        -- Optional footer comment with timestamp for traceability
        md = md .. "\n<!-- Generated on " .. os.date("%Y-%m-%d %H:%M:%S") .. " -->\n"

        -- Optional file output
        if filePath then
            local h = fs.open(filePath, "w")
            if h then
                h.write(md)
                h.close()
            else
                error("Could not open file for writing: " .. filePath)
            end
        end

        return md
    end

    return obj
end

return { init = init }
