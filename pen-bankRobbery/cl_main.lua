local electricityBoxes = {}
local banks = {}
local waitTimer = 2500

RegisterNetEvent('pen-bankRobbery:client:syncData', function(data, data2)
    electricityBoxes = data
    banks = data2
end)

RegisterNetEvent('pen-bankRobbery:client:startHeist', function(bankName)
    createBankZones(bankName)
end)

RegisterNetEvent('pen-bankRobbery:client:endHeist', function(bankName)
    print('heist ended')
    removeZone(bankName)
end)

RegisterNetEvent('pen-bankRobbery:client:removeZone', function(name)
    removeZone(name)
end)


function explodeElectricityBox(name)
    TriggerServerEvent('pen-bankRobbery:server:explodeBox', name)
    print(name)
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
            if not coord.exploded then
                print(location)
                exports.ox_target:addBoxZone({
                    coords = vec3(coord.x, coord.y, coord.z+1),
                    rotation = coord.rotation,
                    size = vec3(1.5, 1, 1.75),
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
end

function createBankZones()
    for location, bank in pairs(banks) do
        for _, coord in ipairs(bank.data) do
            if coord.type == 'fleeca' then -- add box zone for hacking panel
                exports.ox_target:addBoxZone({
                    coords = vec3(coord.panelData.x, coord.panelData.y, coord.panelData.z-0.5),
                    rotation = coord.bankDoorData.closedDoorHeading,
                    size = coord.panelData.zoneSize,
                    debug = true,
                    drawSprite = true,
                    name = '' .. location .. '',
                    options = {
                        {
                            onSelect = function(args)
                                hackingMinigame(location)
                            end,
                            icon = 'fa-solid fa-circle',
                            label = '' .. location .. '',
                        }
                    }
                })
            end
        end
    end
end

function removeZone(bankName)
    exports.ox_target:removeZone('' .. bankName .. '')
end

function hackingMinigame(bankName)
end

Citizen.CreateThread(function()
    while true do
        for bank, location in pairs(banks) do
            for _, coord in ipairs(location.data) do
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                local bankCoords = vec3(coord.bankDoorData.x, coord.bankDoorData.y, coord.bankDoorData.z)
                local distance = #(pos - bankCoords)
        
                if distance < 15 then
                    if coord.doorOpen then
                        local object = GetClosestObjectOfType(bankCoords, 5.0, coord.bankDoorData.model, false, false, false)
                        if object ~= 0 then
                            SetEntityHeading(object, coord.bankDoorData.openDoorHeading)
                        end
                    else
                        local object = GetClosestObjectOfType(bankCoords, 5.0, coord.bankDoorData.model, false, false, false)
                        if object ~= 0 then
                            SetEntityHeading(object, coord.bankDoorData.closedDoorHeading)
                        end
                    end
                end
            end
        end
        Citizen.Wait(waitTimer)
    end
end)