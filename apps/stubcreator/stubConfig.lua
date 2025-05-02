-- config.lua

--[[
    This configuration file allows you to customize how the type stub generator works.
    Below, you'll find the settings that you can modify to fit your needs.

    Please make sure to only modify the settings you're comfortable with. You don't need to
    touch anything else unless you understand the underlying code.
--]]

return {
    -- Enable or disable JSON output.
    -- Set to `true` if you want to generate a JSON output file.
    -- Set to `false` to disable JSON output.
    json = true,

    -- Enable or disable LuaCATS output.
    -- Set to `true` if you want to generate a LuaCATS annotation file.
    -- Set to `false` to disable LuaCATS output.
    luacats = true,

    -- Output directory and filename for generated files.
    -- This will be used as the root path to store the output JSON and LuaCATS files.
    -- The script will save the files as [outputPath]/[rootTypeName].json and [rootTypeName].lua.
    outputPath = "data/item_details",

    -- Root type name for the generated stub.
    -- This will be used as the root class name for both JSON and LuaCATS output.
    rootTypeName = "ItemDetail",

    -- Root type description for the generated stub.
    -- You can fill in a description here that will be included in the stub output.
    rootTypeDescription = "please fill in!",

    --[[
        If you want to directly define the table to scan, you can set it here.
        By default, it's an empty table. If left empty, the script will try to get the table
        using a provider (see `tableProvider` below).
        
        Example: 
        tableToScan = {1, 2, 3} -- If you want to scan a predefined list.
    --]]
    tableToScan = {},

    --[[
        Override function for how to resolve an item from the given index and value.
        you can just return value, if you don't need to resolve additional data.
        however it does beg the question of why aren't you using the tableToScan setting?
        
        This is useful if you're using a peripheral that requires resolving additional data.
        
        Example: for inventory/barrel, the function resolves item details by index.
        
        -- Default resolution for barrel:
        resolveItem = function(index, value)
            return components.barrel.getItemDetail(index)
        end
    --]]
    resolveItem = function(index, value)
        -- Default for peripherals like inventory/barrel
        return components.barrel.getItemDetail(index)
    end,

    --[[
        Optional: Override this function if you want to control what table should be scanned.
        By default, the script will try to resolve the table using `tableProvider()`.
        
        Example: 
        tableProvider = function()
            return components.barrel.list() -- Will return a list of items from the barrel.
        end
    --]]
    tableProvider = function()
        return components.barrel.list()
    end
}
