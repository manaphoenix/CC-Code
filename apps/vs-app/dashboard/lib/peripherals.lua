local peripherals = {}

local statusMon, tuningMon, enderModem

function peripherals.init(config)
    statusMon  = peripheral.wrap(config.status_monitor_side)
    tuningMon  = peripheral.wrap(config.tuning_monitor_side)
    enderModem = peripheral.wrap(config.ender_modem_side)

    assert(statusMon, "Status monitor not found")
    assert(tuningMon, "Tuning monitor not found")
    assert(enderModem, "Ender modem not found")

    statusMon.setTextScale(config.statusTextScale)
    tuningMon.setTextScale(config.tuningTextScale)

    for colName, col in pairs(config.statusOverrides) do
        statusMon.setPaletteColor(colors[colName], col)
    end
    for colName, col in pairs(config.tuningOverrides) do
        tuningMon.setPaletteColor(colors[colName], col)
    end

    enderModem.open(config.modemCode)

    peripherals.statusMon  = statusMon
    peripherals.tuningMon  = tuningMon
    peripherals.enderModem = enderModem
end

function peripherals.getStatusMonitor() return statusMon end

function peripherals.getTuningMonitor() return tuningMon end

function peripherals.getEnderModem() return enderModem end

function peripherals.clearAll()
    statusMon.clear()
    tuningMon.clear()
    term.clear()
    term.setCursorPos(1, 1)
end

return peripherals
