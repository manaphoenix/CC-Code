---
layout: codepage
title: Test Library
tags: [Collections, Data Processing, Queries]
description: >
  A powerful LINQ-style library for Lua that provides collection manipulation
  methods similar to .NET's LINQ. Enables complex table operations with a fluent interface.
permalink: /pages/test.html
overview: >
  Updated LINQ-style library for Lua with safety, performance, and feature improvements.
installation: "manaphoenix/CC-Code/main/lib/linq.lua"
basic_usage_description: >
  Use the library by calling `require` and chaining query methods on tables.
basic_usage: |
  local linq = require("linq")
  local data = linq.from({1, 2, 3, 4})
  local evens = data:where(function(x) return x % 2 == 0 end)
methods:
  - method_name: where
    params:
      - name: predicate
        type: "function"
    return_type: "Linq<T>"
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

  - method_name: "select"
    params:
      - name: selector
        type: "function"
    return_type: "Linq<T>"
    method_description: "Projects each element into a new form using the selector function."
    method_code: |
      function linq:select
          local result = {}
          for i, v in ipairs(self) do
              result[i] = selector(v)
          end
          return setmetatable(result, getmetatable(self))
      end

  - method_name: "count"
    params:
      - name: predicate
        type: "function"
    return_type: "number"
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
