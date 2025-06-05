---
layout: codepage
title: Unit Testing
tags: [Library, Testing, Debugging, Development]
description: >
  A lightweight unit testing framework for ComputerCraft that helps measure and log
  the execution time of test functions, with support for both CC and CCEmuX environments.
permalink: /pages/unit-testing.html
overview: >
  The Unit Testing library provides a simple way to measure and log the execution
  time of test functions in ComputerCraft. It automatically detects the environment
  (CCEmuX or regular ComputerCraft) and formats timing information appropriately.
installation: "manaphoenix/CC-Code/main/lib/unitTesting.lua"
basic_usage_description: >
  Quickly test functions and measure their execution time with minimal setup.
  The library handles timing calculations and error reporting automatically.
basic_usage: |
  local UnitTester = require("unitTesting")
  
  -- Define a test function
  local function myTest()
      -- Your test code here
      local result = 2 + 2
      assert(result == 4, "2 + 2 should equal 4")
  end
  
  -- Run the test
  UnitTester.test(myTest, "Basic addition test")

methods:
  - method_name: test
    params:
      - name: func
        type: "function"
      - name: name
        type: "string"
        optional: true
    return_type: "void"
    method_description: "Executes a test function, measures its execution time, and reports the results."
    method_code: |
      local UnitTester = require("unitTesting")
      
      -- Simple test
      UnitTester.test(function()
          local x = 5 * 5
          assert(x == 25, "5 * 5 should equal 25")
      end, "Multiplication test")
      
      -- Test with custom name
      local function complexTest()
          -- Complex test logic here
          os.sleep(0.5)  -- Simulate work
      end
      UnitTester.test(complexTest, "Complex operation test")

examples:
  - title: "Basic Test Case"
    code: |
      local UnitTester = require("unitTesting")
      
      -- Define a simple test
      local function testStringOperations()
          local str = "Hello, World!"
          assert(string.len(str) == 13, "String length should be 13")
          assert(string.find(str, "World"), "Should find 'World' in string")
      end
      
      -- Run the test
      print("Running string operation tests...")
      UnitTester.test(testStringOperations, "String operations test")
      print("Tests completed!")

  - title: "Testing Multiple Cases"
    code: |
      local UnitTester = require("unitTesting")
      
      -- Test case 1: Number operations
      UnitTester.test(function()
          local result = 10 / 2
          assert(result == 5, "10 / 2 should equal 5")
      end, "Division test")
      
      -- Test case 2: Table operations
      UnitTester.test(function()
          local t = {1, 2, 3, 4, 5}
          assert(#t == 5, "Table should have 5 elements")
          table.insert(t, 6)
          assert(#t == 6, "Table should now have 6 elements")
      end, "Table operations test")
      
      -- Test case 3: Error case (will show error handling)
      UnitTester.test(function()
          local x = nil
          assert(x ~= nil, "This test is expected to fail")
      end, "Failing test")

advanced:
  - title: "Testing Asynchronous Code"
    description: "Example of testing code with delays or async operations"
    code: |
      local UnitTester = require("unitTesting")
      
      -- Test function with delay
      local function testWithDelay()
          local start = os.epoch("utc")
          os.sleep(0.5)  -- Simulate async operation
          local duration = (os.epoch("utc") - start) / 1000  -- Convert to seconds
          assert(duration >= 0.5, "Delay should be at least 0.5 seconds")
      end
      
      -- Run the test
      print("Testing async operation...")
      UnitTester.test(testWithDelay, "Async operation test")

  - title: "Custom Error Handler"
    description: "Override the default error handler for custom error reporting"
    code: |
      local UnitTester = require("unitTesting")
      
      -- Save original error handler
      local originalHandler = UnitTester.errHandler
      
      -- Custom error handler
      UnitTester.errHandler = function(err)
          print("❌ Test failed with error: " .. tostring(err))
          -- You could log to a file or perform other actions here
      end
      
      -- Run a failing test
      UnitTester.test(function()
          error("This is an expected test failure")
      end, "Expected failure test")
      
      -- Restore original handler
      UnitTester.errHandler = originalHandler

  - title: "Benchmarking Performance"
    description: "Use the tester to benchmark function performance"
    code: |
      local UnitTester = require("unitTesting")
      
      -- Function to benchmark
      local function slowOperation()
          local total = 0
          for i = 1, 1000000 do
              total = total + i
          end
          return total
      end
      
      -- Benchmark the function
      print("Benchmarking operation...")
      UnitTester.test(slowOperation, "Performance benchmark")
---
