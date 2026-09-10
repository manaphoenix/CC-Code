---@type ap.peripheral.RSBridge|ap.peripheral.StorageBridge
local bridge = assert(
  peripheral.find("rs_bridge") or peripheral.find("me_bridge"),
  "No RS or ME bridge was found"
)

local destination = "@back"

term.clear()
term.setCursorPos(1, 1)

local items = assert(bridge.getItems(), "Failed to retrieve the item list")

local exported = 0
local failed = 0

for _, item in ipairs(items) do
  if item.maxStackSize == 1 then
    local moved = bridge.exportItem(destination, { name = item.name })

    if moved and moved > 0 then
      exported = exported + moved
    else
      failed = failed + 1
      print("Could not export: " .. item.name)
    end
  end
end

print(("Complete: exported %d item(s), %d type(s) failed."):format(exported, failed))