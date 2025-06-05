---
layout: codepage
title: Math Utils
tags: [Library, Math, Utilities, Numbers]
description: >
  A collection of additional mathematical functions that extend Lua's built-in math
  library. Provides utilities for number theory, rounding, and other common operations.
permalink: /pages/math-utils.html
overview: >
  The Math Utils library extends Lua's standard math library with additional
  mathematical functions that are commonly needed in ComputerCraft programs.
  It includes functions for greatest common divisor, least common multiple, and
  precise number rounding.
installation: "manaphoenix/CC-Code/main/lib/mathUtils.lua"
basic_usage_description: >
  Import the library and use its functions for mathematical operations beyond
  what's provided by Lua's standard math library.
basic_usage: |
  local mathExt = require("mathUtils")
  
  -- Find GCD and LCM
  local gcd = mathExt.gcd(48, 18)  -- Returns 6
  local lcm = mathExt.lcm(21, 6)   -- Returns 42
  
  -- Round numbers
  local rounded = mathExt.round(3.14159, 2)  -- Returns 3.14

methods:
  - method_name: gcd
    params:
      - name: x
        type: "number"
      - name: y
        type: "number"
    return_type: "number"
    method_description: "Calculates the greatest common divisor of two integers."
    method_code: |
      local mathExt = require("mathUtils")
      local result = mathExt.gcd(48, 18)  -- Returns 6
      print(result)

  - method_name: lcm
    params:
      - name: a
        type: "number"
      - name: b
        type: "number"
    return_type: "number"
    method_description: "Calculates the least common multiple of two integers. Returns 0 if either input is 0."
    method_code: |
      local mathExt = require("mathUtils")
      local result = mathExt.lcm(21, 6)  -- Returns 42
      print(result)

  - method_name: leastCommonDivisor
    params:
      - name: a
        type: "number"
      - name: b
        type: "number"
    return_type: "number"
    method_description: "Finds the smallest common divisor greater than 1 of two numbers, or 1 if none exists."
    method_code: |
      local mathExt = require("mathUtils")
      local result = mathExt.leastCommonDivisor(12, 18)  -- Returns 2
      print(result)

  - method_name: round
    params:
      - name: num
        type: "number"
      - name: idp
        type: "number"
        optional: true
    return_type: "number"
    method_description: "Rounds a number to the specified number of decimal places. If idp is omitted, rounds to the nearest integer."
    method_code: |
      local mathExt = require("mathUtils")
      local result = mathExt.round(3.14159, 2)  -- Returns 3.14
      print(result)

examples:
  - title: "Finding Common Divisors"
    code: |
      local mathExt = require("mathUtils")
      
      -- Find greatest common divisor
      local gcd = mathExt.gcd(48, 18)  -- 6
      print("GCD of 48 and 18:", gcd)
      
      -- Find least common multiple
      local lcm = mathExt.lcm(21, 6)   -- 42
      print("LCM of 21 and 6:", lcm)
      
      -- Find smallest common divisor > 1
      local scd = mathExt.leastCommonDivisor(12, 18)  -- 2
      print("Smallest common divisor of 12 and 18:", scd)

  - title: "Number Rounding"
    code: |
      local mathExt = require("mathUtils")
      
      -- Round to nearest integer
      local rounded1 = mathExt.round(3.4)     -- 3
      local rounded2 = mathExt.round(3.5)     -- 4
      
      -- Round to specific decimal places
      local pi = 3.14159
      local pi2 = mathExt.round(pi, 2)       -- 3.14
      local pi4 = mathExt.round(pi, 4)       -- 3.1416
      
      print("Rounded values:", rounded1, rounded2, pi2, pi4)

advanced:
  - title: "Using in Fraction Calculations"
    description: "Simplify fractions using gcd"
    code: |
      local mathExt = require("mathUtils")
      
      function simplifyFraction(numerator, denominator)
          local divisor = mathExt.gcd(numerator, denominator)
          return numerator / divisor, denominator / divisor
      end
      
      -- Example: Simplify 18/24 to 3/4
      local num, den = simplifyFraction(18, 24)
      print(string.format("Simplified fraction: %d/%d", num, den))

  - title: "Finding Common Multiples"
    description: "Find numbers that are multiples of all numbers in a range"
    code: |
      local mathExt = require("mathUtils")
      
      function findCommonMultiple(numbers)
          if #numbers == 0 then return 0 end
          local result = numbers[1]
          for i = 2, #numbers do
              result = mathExt.lcm(result, numbers[i])
          end
          return result
      end
      
      -- Find smallest number divisible by all numbers from 1 to 10
      local numbers = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
      local result = findCommonMultiple(numbers)
      print("Smallest number divisible by 1-10:", result)
---
