if _G.startupConfig and _G.startupConfig.disableMOTD and settings.get("motd.enable") ~= false then
    settings.set("motd.enable", false)
    settings.save()
end
