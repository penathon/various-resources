local bombLocation, bombPlanted, carBomb, vehicleId = nil, false, false, nil

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        if bombPlanted then
            if carBomb then
                playSoundCountdownVehicle()
            else
                playSoundCountdown()
            end
        end
    end
end)

-- Events

RegisterNetEvent('pen-bombs:registerClientBomb')
AddEventHandler('pen-bombs:registerClientBomb', function(coords)
    bombLocation = coords
    bombPlanted = true
    createObject(bombLocation)
end)

RegisterNetEvent('pen-bombs:triggerClientBomb')
AddEventHandler('pen-bombs:triggerClientBomb', function(coords)
    local c = bombLocation
    bombPlanted = false

    PlaySoundFromCoord(-1, 'Hack_Success', c.x, c.y, c.z, 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS', true, 10, true)
    Wait(2000)
    AddExplosion(bombLocation.x, bombLocation.y, bombLocation.z, 29, 30.0, true, false, true)
    resetState()
end)

RegisterNetEvent('pen-bombs:registerClientCarBomb')
AddEventHandler('pen-bombs:registerClientCarBomb', function(vehicleNet)
    vehicleId = NetToVeh(vehicleNet)
    bombLocation = coords
    carBomb = true
    bombPlanted = true
end)

RegisterNetEvent('pen-bombs:triggerClientCarBomb')
AddEventHandler('pen-bombs:triggerClientCarBomb', function()
    local c = GetEntityCoords(vehicleId)
    bombPlanted = false

    PlaySoundFromEntity(-1, 'Hack_Success', vehicleId, 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS', true, 10)
    Wait(2000)
    AddExplosion(c.x, c.y, c.z, 29, 30.0, true, false, true)
    resetState()
end)

RegisterNetEvent('pen-bombs:copyClipboard')
AddEventHandler('pen-bombs:copyClipboard', function(data)
    SendNUIMessage({
        type = 'clipboard',
        data = '' .. data .. ''
    })
end)

-- Functions

function resetState()
    bombLocation = nil
    bombPlanted = false
    carBomb = false
    vehicleId = nil
end

function playSoundCountdown()
    local c = bombLocation
    --PlaySoundFromCoord(-1, 'Beep_Red', c.x, c.y, c.z, 'DLC_HEIST_HACKING_SNAKE_SOUNDS', true, 10, true)
    TriggerServerEvent('pen-bombs:audioCountdownServer', c)
end

function playSoundCountdownVehicle()
    local v = vehicleId
    PlaySoundFromEntity(-1, 'Beep_Red', v, 'DLC_HEIST_HACKING_SNAKE_SOUNDS', true, 10)
end

function createObject(coords)
    local model, modelHash = 'tr_prop_tr_bag_bombs_01a', GetHashKey('tr_prop_tr_bag_bombs_01a')
    if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
        RequestModel(modelHash)

        while not HasModelLoaded(modelHash) do
            Citizen.Wait(1)
        end
    end
    local playerPed = PlayerPedId()
    local obj = CreateObject(model, coords, true, false, true)
    SetModelAsNoLongerNeeded(model)
    PlaceObjectOnGroundProperly(obj)
	FreezeEntityPosition(obj, true)
end