RegisterNetEvent('bombRegister:server')
AddEventHandler('bombRegister:server', function(coords, heading)
    TriggerClientEvent('bombRegister:client', -1, coords, heading)
end)

RegisterNetEvent('pen-bombs:audioCountdownServer')
AddEventHandler('pen-bombs:audioCountdownServer', function(coords)
    local compactedCoords = vector3(coords.x, coords.y, coords.z)
    exports["pen-audiobank"]:PlaySoundFromCoords({
        audioBank = '',
        audioName = {'Beep_Red'},
        audioRef = 'DLC_HEIST_HACKING_SNAKE_SOUNDS',
        coords = compactedCoords,
        range = 20,
    })
end)

-- Phone Bombs

local savedid = nil
local hasPerms = exports["pen-util"]:IsRolePresent( source, "Developer" )

RegisterCommand('pen-bombs:placePhoneBomb', function(source)
    local src = source
    --if exports["pen-util"]:IsRolePresent( src, "Developer" ) then
        local coords = GetEntityCoords(GetPlayerPed(src))
        print(coords)
        addPhoneToInitiate(src)
        TriggerClientEvent('pen-bombs:registerClientBomb', src, coords)
        savedid = src
    --end
end)

function addPhoneToInitiate(id)
    local phoneNumber = exports.npwd:generatePhoneNumber()
    TriggerClientEvent('showmythic', id, '' .. phoneNumber .. '')
    --print(phoneNumber)
    TriggerClientEvent('pen-bombs:copyClipboard', id, phoneNumber)
    exports.npwd:onCall(phoneNumber, function(ctx)
        ctx.reply("Disconnected")
        ctx.exit()
        TriggerClientEvent('pen-bombs:triggerClientBomb', savedid)
        savedid = nil
    end)
end

-- Car Stuff

RegisterCommand('pen-bombs:placePhoneCarBomb', function(source)
    local src = source
    --if exports["pen-util"]:IsRolePresent( src, "Developer" ) then
        local vehicleNet = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(src)))
        addPhoneToInitiateCar(src)
        TriggerClientEvent('pen-bombs:registerClientCarBomb', src, vehicleNet)
        savedid = src
    --end
end)


RegisterCommand('pen-bombs:targetplacePhoneCarBomb', function(source, target)
    local src = source
    --if exports["pen-util"]:IsRolePresent( src, "Developer" ) then
        local vehicleNet = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(target)))
        targetaddPhoneToInitiateCar(src, target)
        TriggerClientEvent('pen-bombs:registerClientCarBomb', target, vehicleNet)
        savedid = target
    --end
end)

function addPhoneToInitiateCar(id)
    local phoneNumber = exports.npwd:generatePhoneNumber()
    TriggerClientEvent('showmythic', id, '' .. phoneNumber .. '')
    --print(phoneNumber)
    TriggerClientEvent('pen-bombs:copyClipboard', id, phoneNumber)
    exports.npwd:onCall(phoneNumber, function(ctx)
        ctx.reply("Disconnected")
        ctx.exit()
        TriggerClientEvent('pen-bombs:triggerClientCarBomb', savedid)
        savedid = nil
    end)
end

function targetaddPhoneToInitiateCar(id, target)
    local phoneNumber = exports.npwd:generatePhoneNumber()
    TriggerClientEvent('showmythic', id, '' .. phoneNumber .. '')
    --print(phoneNumber)
    TriggerClientEvent('pen-bombs:copyClipboard', id, phoneNumber)
    exports.npwd:onCall(phoneNumber, function(ctx)
        ctx.reply("Disconnected")
        ctx.exit()
        TriggerClientEvent('pen-bombs:triggerClientCarBomb', savedid)
        savedid = nil
    end)
end

RegisterCommand('pen-bombs:placePhoneSpeedBomb', function(source, args)
    local src = source
    local id = args[1]
    local time = args[2]
    local speed = args[3]
    TriggerClientEvent('pen-bombs:clientSpeedBomb', id, time, speed)
end)

RegisterCommand('pen-bombs:stopPhoneSpeedBomb', function(source, args)
    local src = source
    local id = args[1]
    TriggerClientEvent('pen-bombs:stopClientSpeedBomb', id)
end)
