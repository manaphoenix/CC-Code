-- small update to check for sha change!
local fuel = turtle.getFuelLevel()
local size = {...}
local fuelNeeded = size[1] * size[2] * size[3]
term.clear()
term.setCursorPos(1,1)
local rowState = "right"

print("Fuel: " .. fuel)
print("Fuel Needed: " .. fuelNeeded)
print("Size: " .. size[1] .. "x" .. size[2] .. "x" .. size[3])

for i,v in pairs(size) do
    size[i] = tonumber(v)
end

if fuelNeeded > fuel then
    print("Not enough fuel!")
    return
end

local function digLine(length)
    for i = 1, length-1 do
        turtle.dig()
        turtle.forward()
    end
end

local function nextRow(invert)
    if invert then
        if rowState == "right" then
            rowState = "left"
        else
            rowState = "right"
        end
    end
    if rowState == "right" then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
    turtle.dig()
    turtle.forward()
    if rowState == "right" then
        turtle.turnRight()
        rowState = "left"
    else
        turtle.turnLeft()
        rowState = "right"
    end
end

for j = 1, size[3] do
    for i = 1, size[2] do
        digLine(size[1])
        if (i+1) <= size[2] then
            nextRow()
        else
            turtle.digDown()
            turtle.down()
            turtle.turnLeft()
            turtle.turnLeft()
        end
    end
end