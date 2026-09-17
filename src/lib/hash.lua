-- hash.lua
--
-- Deterministic 32-bit FNV-1a hashing and canonical serialization.
--
-- Designed for CC:Tweaked.
--
-- The recipe fingerprint is based on:
--   * ingredient name
--   * ingredient count
--   * ingredient components
--
-- Ingredient order does not matter.
-- Map/component key order does not matter.
-- Array order does matter.
--
-- Hashes are returned as 8-character lowercase hexadecimal strings.

local bit = bit32

local M = {}

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

local FNV_OFFSET = 0x811C9DC5
local FNV_PRIME = 0x01000193
local UINT32 = 4294967296

---------------------------------------------------------------------------
-- 32-bit helpers
---------------------------------------------------------------------------

---@param value number
---@return number
local function u32(value)
    return value % UINT32
end

---@param value number
---@return string
local function hex32(value)
    return string.format("%08x", u32(value))
end

---------------------------------------------------------------------------
-- 32-bit multiplication
---------------------------------------------------------------------------

---@param a number
---@param b number
---@return number
local function mul32(a, b)
    -- Lua does not provide a portable native 32-bit integer
    -- multiplication operation, so split both operands into
    -- 16-bit halves.
    local aLo = bit.band(a, 0xFFFF)
    local aHi = bit.rshift(a, 16)

    local bLo = bit.band(b, 0xFFFF)
    local bHi = bit.rshift(b, 16)

    -- Only the low 32 bits are required.
    local lo = aLo * bLo
    local mid = aHi * bLo + aLo * bHi

    local low16 = bit.band(lo, 0xFFFF)

    local high16 = bit.band(
        math.floor(lo / 65536) + mid,
        0xFFFF
    )

    return bit.bor(
        low16,
        bit.lshift(high16, 16)
    )
end

---------------------------------------------------------------------------
-- FNV-1a
---------------------------------------------------------------------------

---Calculate a 32-bit FNV-1a hash.
---
---@param value string
---@return number hash Unsigned 32-bit hash value.
function M.fnv1a(value)
    local hash = FNV_OFFSET

    for i = 1, #value do
        hash = bit.bxor(
            hash,
            string.byte(value, i)
        )

        hash = mul32(hash, FNV_PRIME)
    end

    return u32(hash)
end

---Calculate a 32-bit FNV-1a hash and return it as hexadecimal.
---
---@param value string
---@return string hash Eight-character lowercase hexadecimal hash.
function M.fnv1aHex(value)
    return hex32(M.fnv1a(value))
end

---------------------------------------------------------------------------
-- Array detection
---------------------------------------------------------------------------

---@param value any
---@return boolean
local function isArray(value)
    if type(value) ~= "table" then
        return false
    end

    local count = 0

    for key in pairs(value) do
        if type(key) ~= "number"
            or key < 1
            or key ~= math.floor(key)
        then
            return false
        end

        count = count + 1
    end

    -- Arrays must be dense.
    for i = 1, count do
        if value[i] == nil then
            return false
        end
    end

    return true
end

---------------------------------------------------------------------------
-- Canonical serialization
---------------------------------------------------------------------------

---Convert a Lua value into a deterministic representation.
---
---Maps are serialized with their keys sorted by canonical key value.
---Arrays preserve their numeric order.
---
---@param value any
---@return string
function M.canonicalize(value)
    local valueType = type(value)

    if value == nil then
        return "N"

    elseif valueType == "boolean" then
        return value and "B1" or "B0"

    elseif valueType == "number" then
        return "D" .. string.format("%.17g", value)

    elseif valueType == "string" then
        -- Length-prefix strings so arbitrary contents cannot create
        -- ambiguous serialization boundaries.
        return "S" .. #value .. ":" .. value

    elseif valueType == "table" then
        local result = {}

        if isArray(value) then
            result[#result + 1] = "A"
            result[#result + 1] = tostring(#value)
            result[#result + 1] = "["

            for i = 1, #value do
                result[#result + 1] =
                    M.canonicalize(value[i])
            end

            result[#result + 1] = "]"

        else
            result[#result + 1] = "M"

            local keys = {}

            for key in pairs(value) do
                keys[#keys + 1] = key
            end

            table.sort(keys, function(a, b)
                return M.canonicalize(a)
                    < M.canonicalize(b)
            end)

            result[#result + 1] = tostring(#keys)
            result[#result + 1] = "{"

            for _, key in ipairs(keys) do
                result[#result + 1] =
                    M.canonicalize(key)

                result[#result + 1] =
                    M.canonicalize(value[key])
            end

            result[#result + 1] = "}"
        end

        return table.concat(result)

    else
        error(
            "Unsupported value type: " .. valueType,
            2
        )
    end
end

---------------------------------------------------------------------------
-- Recipe handling
---------------------------------------------------------------------------

---@class Ingredient
---@field name string
---@field count integer

---@param ingredient Ingredient
---@return Ingredient
local function normalizeIngredient(ingredient)
    return {
        name = ingredient.name,
        count = ingredient.count
    }
end

---Create the canonical representation of a recipe.
---
---Ingredient order does not affect the result.
---
---@param ingredients Ingredient[]
---@return string
function M.recipeCanonical(ingredients)
    local normalized = {}

    for _, ingredient in ipairs(ingredients) do
        normalized[#normalized + 1] =
            normalizeIngredient(ingredient)
    end

    table.sort(normalized, function(a, b)
        return M.canonicalize(a)
            < M.canonicalize(b)
    end)

    return M.canonicalize(normalized)
end

---Create a deterministic 32-bit fingerprint for a recipe.
---
---Ingredient order does not matter, but ingredient multiplicity,
---counts, names, and component values do.
---
---@param ingredients Ingredient[]
---@return string hash Eight-character lowercase hexadecimal hash.
function M.recipeFingerprint(ingredients)
    return M.fnv1aHex(
        M.recipeCanonical(ingredients)
    )
end

return M