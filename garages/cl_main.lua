local impound = {}
local menu_options = {}
local impoundLocation = nil

function spawnCar(id, car, properties, reason)
    if lib.progressBar({
        duration = 5000,
        label = 'Spawning Vehicle',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true
        },
    }) then 
        local p = PlayerPedId()

        RequestModel(car)
        while not HasModelLoaded(car) do
            RequestModel(car)
            Citizen.Wait(0)
        end

        for location, data in pairs(Config.Locations) do
            for i, spot in ipairs(data.zones) do
                if spot.name == impoundLocation then
                    local vehicle = CreateVehicle(car, spot.carSpawn.coords, spot.carSpawn.heading, true, false)
                    lib.setVehicleProperties(vehicle, properties)
                end
            end
        end


        TriggerServerEvent('pen-garages:deleteImpound', id, car, properties, reason)
        menu_options = {}
        impound = {}
    else 
    end
end

RegisterNetEvent('pen-garages:refreshImpoundData')
AddEventHandler('pen-garages:refreshImpoundData', function(data)
    impound = {}
    impound = data
    --print('data refreshed')
    --print(json.encode(impound))
end)

Citizen.CreateThread(function()
    TriggerServerEvent('pen-garages:requestRefresh', GetPlayerServerId(PlayerId()))
end)

function registerMenu()
    for k,v in ipairs(impound) do
        table.insert(menu_options, {
            title = 'ID - ' .. v.id .. ' Date - ' .. v.date .. '',
            description = 'Plate - ' .. v.vehProperties.plate .. ' Model - ' .. v.vehModel .. '',
            onSelect = function(args)
                spawnCar(v.id, v.vehModel, v.vehProperties, v.reason)
                menu_options = {}     
            end,
            metadata = {
                {label = 'Offender', value = v.offender},
                {label = 'Reason', value = v.reason}
            }
        })
    end

    lib.registerContext({
        id = 'impound_menu',
        title = 'Impound',
        onExit = function()
            menu_options = {}
        end,
        options = menu_options
    })
    lib.showContext('impound_menu')
end

RegisterCommand('impound', function()
    registerMenu()
    lib.showContext('impound_menu')
end)



for location, data in pairs(Config.Locations) do
    for i, spot in ipairs(data.zones) do
        local newSpot = BoxZone:Create(spot.coords, spot.length, spot.width, {
            name = 'Impound',
            debugPoly = spot.debug,
            heading = spot.heading,
            minZ = spot.minZ,
            maxZ = spot.maxZ,
        })
        newSpot:onPlayerInOut(function(isPointInside, _)
            local onDuty = checkIfDuty()
            if isPointInside and onDuty then
                lib.addRadialItem({
                    {
                    id = 'impound',
                    label = 'Impound List',
                    icon = 'warehouse',
                    onSelect = function()
                        registerMenu()
                    end
                    }
                })
                impoundLocation = spot.name
            else
                lib.removeRadialItem('impound')
                impoundLocation = nil
            end
        end)
    end
end

function checkIfDuty()
    local state = LocalPlayer.state.clockin
    local clockedin = state.isLeo
    return clockedin
end