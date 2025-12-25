local peripherals = {}

local config = require("config.defaults")

-- wrap input/output relays
peripherals.input_relay = peripheral.wrap(config.input_side)
peripherals.output_relay = peripheral.wrap(config.output_side)
peripherals.enderModem = peripheral.wrap(config.ender_modem_side)

-- find latch relay (any redstone relay not input/output)
do
    local relays = { peripheral.find("redstone_relay") }
    for _, r in ipairs(relays) do
        if r ~= peripherals.input_relay and r ~= peripherals.output_relay then
            peripherals.latch_relay = r
            break
        end
    end
end

-- find sensors
peripherals.stressometer = peripheral.find("Create_Stressometer")
peripherals.speedometer = peripheral.find("Create_Speedometer")
peripherals.tank = peripheral.find("fluid_storage")
peripherals.accumulator = peripheral.find("modular_accumulator")

-- sanity checks
assert(peripherals.input_relay, "Input relay not found on side " .. config.input_side)
assert(peripherals.output_relay, "Output relay not found on side " .. config.output_side)
assert(peripherals.enderModem, "Ender modem not found on side " .. config.ender_modem_side)
assert(peripherals.latch_relay, "Latch relay not found")
assert(peripherals.stressometer, "Stressometer not found")
assert(peripherals.speedometer, "Speedometer not found")
assert(peripherals.tank, "Fuel tank not found")
assert(peripherals.accumulator, "Accumulator not found")

return peripherals
