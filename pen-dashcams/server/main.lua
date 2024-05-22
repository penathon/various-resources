local activeLeo = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2500)
        for k, v in ipairs( GetPlayers() ) do
            local state = Player( v ).state.clockin or { isLeo = false, isFire = false }
            if state.isLeo then 
                local inTable = has_value(v)
                --print(v, inTable)
                if not inTable then
                    table.insert(activeLeo, {
                        serverid = v,
                        name = GetPlayerName(v),
                        vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(v), true)),
                        pedNetId = NetworkGetNetworkIdFromEntity(GetPlayerPed(v))
                    })
                end
            else
                local inTable = has_value(v)
                if inTable then
                    local key = findKey(v)
                    --print(key)
                    table.remove(activeLeo, key)
                end
            end
        end
    end
end)

lib.callback.register('pen-dashcam:getActiveLEO', function(cb)
    return activeLeo
end)


function notify(text)
    TriggerClientEvent('showmythic', 1, text)
end


function has_value (val)
    for index, value in ipairs(activeLeo) do
        -- We grab the first index of our sub-table instead
        if value.serverid == val then
            return true
        end
    end

    return false
end

function findKey(id)
    for key, value in ipairs(activeLeo) do
        if tonumber(value.serverid) == tonumber(id) then
          return key
        end
    end
end

function removeFromDatabase(id)
    local key = findKey(id)
    table.remove(activeLeo, key)
end

--[[RegisterCommand('showtable', function()
    print(json.encode(activeLeo, {indent=true}))
end)]]--


AddEventHandler('playerDropped', function (reason)
    removeFromDatabase(source)
end)

RegisterNetEvent('pen-dashcam:changeCulling')
AddEventHandler('pen-dashcam:changeCulling', function(id, enable)
    local src = id
    --print(src)
    if enable then
        SetPlayerCullingRadius(src, 100000000.0)
    elseif not enable then
        SetPlayerCullingRadius(src, 0.0)
    end
end)


lib.callback.register('pen-dashcam:getCommunications', function(cb, source)
    if exports["pen-util"]:IsRolePresent( source, "Communications" ) then
        return true
    else
        return false
    end
end)
