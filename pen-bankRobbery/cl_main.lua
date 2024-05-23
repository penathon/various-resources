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

RegisterNetEvent('pen-bankRobbery:client:endHeist', function(bankName)
    removeZone(bankName)
end)

RegisterNetEvent('pen-bankRobbery:client:removeBox', function(name)
    removeZone(name)
end)

RegisterNetEvent('pen-bankRobbery:client:openDoor', function(name)
    openDoor(name)
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

function createBankZones(bankName)
    local bank = banks[bankName]
    if bank and bank.data and #bank.data > 0 then
        exports.ox_target:addBoxZone({
            coords = vec3(bank.data[1].bankDoorCoords.x, bank.data[1].bankDoorCoords.y, bank.data[1].bankDoorCoords.z+1),
            radius = 1,
            debug = true,
            drawSprite = true,
            name = '' .. bankName .. '',
            options = {
                {
                    onSelect = function(args)
                        explodeDoor(bankName)
                    end,
                    icon = 'fa-solid fa-circle',
                    label = '' .. bankName .. '',
                }
            }
        })
    end
end

function removeZone(bankName)
    exports.ox_target:removeZone('' .. bankName .. '')
end

function explodeDoor(bankName)
    TriggerServerEvent('pen-bankRobbery:server:explodeBox', bankName)
end

function openDoor(name)
    local bank = banks[name]
    vec3(bank.data[1].bankDoorCoords.x, bank.data[1].bankDoorCoords.y, bank.data[1].bankDoorCoords.z+1)
end