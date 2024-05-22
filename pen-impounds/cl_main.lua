local impound = {}
local impoundLogs = {}
local menu_options = {}
local menu_options2 = {}
local impoundLocation = nil

RegisterNetEvent('pen-garages:refreshImpoundData')
AddEventHandler('pen-garages:refreshImpoundData', function(data, data2)
    impound = data
    impoundLogs = data2
end)

Citizen.CreateThread(function()
    Citizen.Wait(500)
    refreshData()
end)

function registerMenu()
    refreshData()
    Citizen.Wait(500)
    for k,v in ipairs(impound) do
        table.insert(menu_options, {
            title = 'ID - ' .. v.id .. ' Date - ' .. v.date .. '',
            description = 'Plate - ' .. v.vehProperties.plate .. ' Model - ' .. v.vehModel .. '',
            onSelect = function(args)
                spawnCar(v.id, v.vehModel, v.vehProperties, v.reason, v.offender, v.impoundee)
                menu_options = {}     
            end,
            metadata = {
                {label = 'Offender', value = v.offender},
                {label = 'Impoundee', value = v.impoundee},
                {label = 'Reason', value = v.reason}
            }
        })
    end

    for k,v in ipairs(impoundLogs) do
        table.insert(menu_options2, {
            title = 'ID - ' .. v.id .. ' Date - ' .. v.date .. '',
            description = 'Reason - ' .. v.reason .. '',
            metadata = {
                {label = 'Offender', value = v.offender},
                {label = 'Impoundee', value = v.impoundee}
            }
        })
    end

    lib.registerContext({
        id = 'impound_menu2',
        title = 'Impound Logs',
        menu = 'impound_menu',
        onExit = function()
            menu_options = {}
            menu_options2 = {}
        end,
        onBack = function()
            menu_options = {}
            menu_options2 = {}
        end,
        options = menu_options2
    })

    lib.registerContext({
        id = 'impound_menu3',
        title = 'Current Impounds',
        menu = 'impound_menu',
        onExit = function()
            menu_options = {}
            menu_options2 = {}
        end,
        onBack = function()
            menu_options = {}
            menu_options2 = {}
        end,
        options = menu_options
    })

    lib.registerContext({
        id = 'impound_menu',
        title = 'Impound Menu',
        onExit = function()
            menu_options = {}
            menu_options2 = {}
        end,
        onBack = function()
            menu_options = {}
            menu_options2 = {}
        end,
        options = {
            {
                title = 'Current Impounds',
                description = 'View Current Impounds',
                menu = 'impound_menu3',
                arrow = true
            },
            {
                title = 'Impounds Log',
                description = 'View Previous Impounds',
                menu = 'impound_menu2',
                arrow = true
            }
        }
    })

    lib.showContext('impound_menu')
end

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

function deleteImpound(id, car, properties, reason, offender, impoundee)
    TriggerServerEvent('pen-garages:deleteImpound', id, car, properties, reason, offender, impoundee)
end

function spawnCar(id, car, properties, reason, offender, impoundee)
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


        deleteImpound(id, car, properties, reason, offender, impoundee)
    end
end

function refreshData()
    TriggerServerEvent('pen-garages:requestRefresh', GetPlayerServerId(PlayerId()))
end