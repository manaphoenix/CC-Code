---
layout: codepage
title: Parallel Actions
tags: [Library, Concurrency, Performance, Utilities]
description: >
  A utility library for managing and executing multiple actions in parallel with batching support.
  Optimized for ComputerCraft to handle concurrent operations efficiently.
permalink: /pages/parallel-actions.html
overview: >
  A lightweight library that simplifies parallel execution of multiple functions with automatic batching
  to prevent system overload. Ideal for processing multiple independent tasks concurrently.
installation: "manaphoenix/CC-Code/main/lib/parallelActions.lua"
basic_usage_description: >
  Queue up functions to be executed in parallel, with automatic batching to prevent system overload.
basic_usage: |
  local parallelAction = require("parallelAction")

  -- Add some actions
  for i = 1, 10 do
      parallelAction.addAction(function()
          -- Some work here
          print("Processing item " .. i)
      end)
  end

  -- Execute all actions
  parallelAction.execute("Batch processing")

methods:
  - method_name: setBatchSize
    params:
      - name: size
        type: "number"
    return_type: "void"
    method_description: "Sets the maximum number of actions to execute in a single batch."
    method_code: |
      module.setBatchSize(50) -- works
      module.setBatchSize("50") -- errors, must be a number
      module.setBatchSize(256) -- errors, must be 255 or less
      module.setBatchSize(1.05) -- errors, must be an integer

  - method_name: addAction
    params:
      - name: action
        type: "function"
    return_type: "void"
    method_description: "Adds an action to the queue of actions to be executed."
    method_code: |
      local function someAction()
          print("Processing item")
      end

      module.addAction(someAction)

  - method_name: execute
    params:
      - name: optStr
        type: "string"
        optional: true
      - name: verbose
        type: "boolean"
        optional: true
    return_type: "void"
    method_description: "Executes all queued actions in parallel, handling batching automatically."
    method_code: |
      -- your code here

      module.execute("Batch processing", true) -- "Name" is optional, "verbose" is optional
      -- with verbose true, it will print the name of the batch and when it finished
---
