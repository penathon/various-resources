local currBurrows = {}
local created = false

Citizen.CreateThread(function()
    requestBurrows()
end)

function requestBurrows()
    TriggerServerEvent('pen-metaldetecting:server:requestBurrows')
end

function foundBurrow(id)
    TriggerServerEvent('pen-metaldetecting:server:foundBurrows', id)
end

RegisterNetEvent('pen-metaldetecting:client:sendBurrows', function(data)
    currBurrows = data
    createZones()
end)

RegisterNetEvent('pen-metaldetecting:client:removeBurrows', function(id, data)
    currBurrows = data
    removeZones(id)
end)

function createZones()
    for k,v in ipairs(currBurrows) do
        exports.ox_target:addSphereZone({
            coords = vec3(v.x, v.y, v.z),
            radius = 3,
            debug = true,
            drawSprite = true,
            name = '' .. v.id .. '',
            options = {
                {
                    onSelect = function(args)
                        foundBurrow(v.id)
                    end,
                    icon = 'fa-solid fa-circle',
                    label = '' .. v.id .. '',
                }
            }
        })
    end
end

function removeZones(id)
    exports.ox_target:removeZone('' .. id .. '')
end
