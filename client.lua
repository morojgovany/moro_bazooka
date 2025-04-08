local bazookaFiring = false
local bazookaObject = nil

RegisterNetEvent('moro_bazooka:syncBazooka')
AddEventHandler('moro_bazooka:syncBazooka', function(player, coords, create)
    local playerFromSrv = GetPlayerFromServerId(player)
    if create then
        bazookaObject = CreateObject('p_cannonbarrel01x', coords.x, coords.y, coords.z, false, false, false)
        local boneIndex = GetEntityBoneIndexByName(GetPlayerPed(playerFromSrv), 'SKEL_R_Hand')
        AttachEntityToEntity(bazookaObject, GetPlayerPed(playerFromSrv), boneIndex, 0.17999999999999, -0.00999999999997, -0.12, 9.34, -89.99999999999994, 1.61999999999998, true, false, false, true, 1, true)
    else
        if DoesEntityExist(bazookaObject) then
            Wait(2000)
            DeleteEntity(bazookaObject)
            bazookaObject = nil
        end
    end
end)

RegisterNetEvent('moro_bazooka:startBazooka')
AddEventHandler('moro_bazooka:startBazooka', function()
    if not bazookaFiring then
        bazookaFiring = true
        local playerPed = PlayerPedId()
        LoadModel('p_cannonbarrel01x')
        RequestAnimDict('amb_work@prop_vehicle_wagon@lumber_unload@4@shoulder_lumber@male_a@base')
        while (not HasAnimDictLoaded("amb_work@prop_vehicle_wagon@lumber_unload@4@shoulder_lumber@male_a@base")) do
            Wait(100)
        end
        TaskPlayAnim(PlayerPedId(), "amb_work@prop_vehicle_wagon@lumber_unload@4@shoulder_lumber@male_a@base", 'base', 1.0, 8.0, -1, 31, 0, false, false, false)
        TriggerServerEvent('moro_bazooka:syncBazooka', true)


        Citizen.CreateThread(function()
            while bazookaFiring do
                DisableControlAction(0, Config.disableCancelAnimationKey, true) --disable cancel anim key
                Citizen.Wait(1)
                if IsControlJustReleased(0, 0x07CE1E61) then
                    local position = GetEntityCoords(playerPed)
                    local forwardVector = GetEntityForwardVector(playerPed)
                    local explosionPos = position + forwardVector * 20.0


                    AddExplosion(explosionPos.x, explosionPos.y, explosionPos.z, 28, 1.0, true, false, true)

                    ShakeGameplayCam("HAND_SHAKE", 1.5)

                    DetachEntity(bazookaObject)
                    ClearPedTasksImmediately(playerPed)
                    RemoveAnimDict("amb_work@prop_vehicle_wagon@lumber_unload@4@shoulder_lumber@male_a@base")
                    local reverseVector = vector3(-forwardVector.x, -forwardVector.y, 0.2)
                    local velocity = reverseVector * 15.0
                    SetEntityVelocity(playerPed, velocity.x, velocity.y, 2.0)
                    Citizen.InvokeNative(0xAE99FB955581844A, playerPed, 2000, 2000, 0, 0, 0, "falling")
                    bazookaFiring = false
                    TriggerServerEvent('moro_bazooka:syncBazooka', false)
                    Wait(200)
                    ShakeGameplayCam("HAND_SHAKE", 0.0)
                end
            end
        end)
    else
        bazookaFiring = false
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if bazookaObject ~= nil then
        if DoesEntityExist(bazookaObject) then
            DeleteEntity(bazookaObject)
        end
    end
    ClearPedTasksImmediately(PlayerPedId())
end)
