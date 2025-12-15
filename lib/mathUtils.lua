local mathExt = {}

local function assertNumber(n, name)
    if type(n) ~= "number" then
        error(("Expected number for %s, got %s"):format(name, type(n)), 3)
    end
end

--- Calculates the greatest common divisor of two integers.
function mathExt.gcd(x, y)
    assertNumber(x, "x")
    assertNumber(y, "y")
    x, y = math.floor(math.abs(x)), math.floor(math.abs(y))
    while y ~= 0 do
        x, y = y, x % y
    end
    return x
end

--- Calculates the least common multiple of two integers.
function mathExt.lcm(a, b)
    assertNumber(a, "a")
    assertNumber(b, "b")
    a, b = math.floor(math.abs(a)), math.floor(math.abs(b))
    if a == 0 or b == 0 then return 0 end
    return (a * b) / mathExt.gcd(a, b)
end

--- Finds the smallest common divisor of two numbers (greater than 1), or 1 if none.
function mathExt.leastCommonDivisor(a, b)
    assertNumber(a, "a")
    assertNumber(b, "b")
    a, b = math.floor(math.abs(a)), math.floor(math.abs(b))
    local minVal = math.min(a, b)
    for i = 2, minVal do
        if a % i == 0 and b % i == 0 then
            return i
        end
    end
    return 1
end

--- Rounds a number to the given number of decimal places.
function mathExt.round(num, idp)
    assertNumber(num, "num")
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

--- Clamp a number between a min and a max (inclusive)
function mathExt.clamp(num, min, max)
    assertNumber(num, "num")
    assertNumber(min, "min")
    assertNumber(max, "max")
    return math.min(max, math.max(min, num))
end

return mathExt
