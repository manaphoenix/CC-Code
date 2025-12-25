return {
    status_monitor_side = "top",
    tuning_monitor_side = "right",
    ender_modem_side    = "back",

    modemCode           = 1337,
    securityKey         = "dogs",

    statusTextScale     = 1.0,
    tuningTextScale     = 2.0,

    statusOverrides     = { gray = 0x171717 },
    tuningOverrides     = {},

    statusColors        = {
        inactive       = colors.orange,
        active         = colors.lime,
        fuel           = colors.yellow,
        stress         = colors.purple,
        speed          = colors.blue,
        refillInactive = colors.gray,
        refillActive   = colors.red,
        energy         = colors.yellow,
    },

    lockText            = "Locked",
    dbgMessages         = false
}
