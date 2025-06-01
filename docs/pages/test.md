---
layout: codepage
title: Linq Library
overview: >
  Updated LINQ-style library for Lua with safety, performance, and feature improvements.
installation: "https://raw.githubusercontent.com/manaphoenix/CC_OC-Code/refs/heads/main/lib/linq.lua lib/linq"
basic_usage_description: >
  Use the library by calling `require` and chaining query methods on tables.
basic_usage: |
  local linq = require("linq")
  local data = linq.from({1, 2, 3, 4})
  local evens = data:where(function(x) return x % 2 == 0 end)
methods:
  - method_name: "where(predicate)"
    method_description: "Filters the collection based on the predicate function."
    method_code: |
      function linq:where(predicate)
          local result = {}
          for _, v in ipairs(self) do
              if predicate(v) then
                  table.insert(result, v)
              end
          end
          return setmetatable(result, getmetatable(self))
      end

  - method_name: "select(selector)"
    method_description: "Projects each element into a new form using the selector function."
    method_code: |
      function linq:select(selector)
          local result = {}
          for i, v in ipairs(self) do
              result[i] = selector(v)
          end
          return setmetatable(result, getmetatable(self))
      end

  - method_name: "count(predicate)"
    method_description: "Counts elements that satisfy the predicate or all if none given."
    method_code: |
      function linq:count(predicate)
          local count = 0
          for _, v in ipairs(self) do
              if not predicate or predicate(v) then
                  count = count + 1
              end
          end
          return count
      end

examples:
  - title: "Basic Filtering"
    code: |
      local linq = require("linq")
      local data = linq.from({1, 2, 3, 4, 5, 6})
      local evens = data:where(function(x) return x % 2 == 0 end)
      for _, v in ipairs(evens) do
          print(v)
      end

advanced:
  - title: "Lambda Support"
    description: "Using lambda expressions for concise query predicates."
    code: |
      local linq = require("linq")
      local data = linq.from({1, 2, 3, 4})
      local doubled = data:select(module.lambda("x => x * 2"))
      for _, v in ipairs(doubled) do
          print(v)
      end
---

# Linq Library Documentation

Welcome to the documentation page for the Linq Library in Lua.
