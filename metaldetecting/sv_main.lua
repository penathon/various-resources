local burrowLocations = {}

Citizen.CreateThread(function()
    createBurrows()
end)

function createBurrows()
    for location, data in pairs(config.burrowlocations) do
		for i, spot in ipairs(data.zones) do
            generateRandomCoordinates(spot, spot.numberOfBurrows, location)
        end
    end
end

function generateRandomCoordinates(area, count, name)
    for i = 1, count do
        local x = math.random() * (area.maxX - area.minX) + area.minX
        local y = math.random() * (area.minY - area.maxY) + area.minY
        local z = 13.0
        table.insert(burrowLocations, { name = name, id = math.random(1,10000), x = x, y = y, z = z })
    end
end

function burrowFound(src)

end

RegisterNetEvent('pen-metaldetecting:server:requestBurrows', function()
    TriggerClientEvent('pen-metaldetecting:client:sendBurrows', source, burrowLocations)
end)

function updateAllBurrows()
    TriggerClientEvent('pen-metaldetecting:client:sendBurrows', -1, burrowLocations)
end

function removeBurrows(id)
    TriggerClientEvent('pen-metaldetecting:client:removeBurrows', -1, id, burrowLocations)
end

RegisterNetEvent('pen-metaldetecting:server:foundBurrows', function(data)
    local check = checkMatch(data)
    if check then
        table.remove(burrowLocations, check)
    end
    burrowFound(source)
    removeBurrows(data)
end)

function checkMatch(data)
    for k,v in ipairs(burrowLocations) do
        if v.id == data then
            return k
        end
    end
end
