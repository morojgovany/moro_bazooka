local bazookaInUse = false

RegisterCommand(Config.command, function(source, args, raw)
    local _source = source
    TriggerClientEvent('moro_bazooka:startBazooka', _source)
end, Config.adminCheck)

RegisterServerEvent("moro_bazooka:syncBazooka")
AddEventHandler("moro_bazooka:syncBazooka", function(create)
    local _source = source
    local pos = GetEntityCoords(GetPlayerPed(_source))
    TriggerClientEvent("moro_bazooka:syncBazooka", -1, _source, pos, create)
    if not create then
        bazookaInUse = false
    end
end)

