local electricityBoxes = {}
local banks = {}
local waitTimer = 5000

RegisterNetEvent('pen-bankRobbery:client:syncData', function(data, data2)
    electricityBoxes = data
    banks = data2
end)

RegisterNetEvent('pen-bankRobbery:client:startHeist', function(bankName)
    createBankZones(bankName)
end)

function explodeElectricityBox(name)
    TriggerServerEvent('pen-bankRobbery:server:explodeBox', location)
end

function explodeBox(location)
    if lib.progressBar({
        duration = 10000,
        label = 'Planting Charge',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
        },
        anim = {
            dict = 'anim@heists@ornate_bank@grab_cash',
            clip = 'intro'
        },
        prop = {
            model = `hei_prop_heist_thermite`,
            pos = vec3(0.03, 0.03, 0.02),
            rot = vec3(0.0, 0.0, -1.5)
        },
    }) then explodeElectricityBox(location) end
end

Citizen.CreateThread(function()
    TriggerServerEvent('pen-bankRobbery:server:requestData')
    Citizen.Wait(1000)
    createZones()
end)

function createZones()
    for location, data in pairs(electricityBoxes) do
        for _, coord in ipairs(data.coords) do
            exports.ox_target:addSphereZone({
                coords = vec3(coord.x, coord.y, coord.z+1),
                radius = 1,
                debug = true,
                drawSprite = true,
                name = '' .. location .. '',
                options = {
                    {
                        onSelect = function(args)
                            explodeBox(location)
                        end,
                        icon = 'fa-solid fa-circle',
                        label = '' .. location .. '',
                    }
                }
            })
        end
    end
end

function createBankZones()
    for location, datas in pairs(banks) do
        for _, coord in ipairs(datas.data) do
            exports.ox_target:addSphereZone({
                coords = vec3(coord.bankDoorCoords.x, coord.bankDoorCoords.y, coord.bankDoorCoords.z+1),
                radius = 1,
                debug = true,
                drawSprite = true,
                name = '' .. location .. '',
                options = {
                    {
                        onSelect = function(args)
                            --explodeDoor()
                        end,
                        icon = 'fa-solid fa-circle',
                        label = '' .. location .. '',
                    }
                }
            })
        end
    end
end
