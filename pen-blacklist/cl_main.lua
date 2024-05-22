
local timer = 0
local notified = false
local hasToRemove = false

Citizen.CreateThread( function()
    while true do
        Wait(timer)

        local ped = PlayerPedId()
        local isInVehicle = IsPedInAnyVehicle(ped, false)

        if isInVehicle then
            checkBlacklistedModifications()
            timer = 100
        else
            timer = 2000
        end
        
    end
end)


function checkBlacklistedModifications()

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local class = GetVehicleClass(veh)

    if class == 13 or class == 14 or class == 15 or class == 16 then return end

    if not Config.DriveByEnabled then
        SetPlayerCanDoDriveBy(PlayerId(), false)
    end

    for k,v in ipairs(Config.Excluded) do
        if tonumber(lib.getVehicleProperties(veh).model) == tonumber(GetHashKey(v)) then return end
    end

    if not Config.VehicleArmourEnabled then
        if lib.getVehicleProperties(veh).modArmor >= 0 then 
            hasToRemove = true
            lib.setVehicleProperties(veh, { modArmor = -1 })
        end
    end


    if not Config.BulletProofTyresEnabled then
        if not lib.getVehicleProperties(veh).bulletProofTyres then
            hasToRemove = true
            lib.setVehicleProperties(veh, { bulletProofTyres = true })
        end
    end

    if not Config.BulletProofTyresEnabled or Config.VehicleArmourEnabled then
        notify()
    end

end

function notify()
    if hasToRemove then
        local notified = true
        hasToRemove = false
        TriggerEvent('showmythic', 'Blacklisted Vehicle Modification Removed')
    end
end
