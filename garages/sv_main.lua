impound = {}


Citizen.CreateThread(function()
    dbSync()
end)

RegisterNetEvent('pen-garages:saveImpound')
AddEventHandler('pen-garages:saveImpound', function(properties, netId, reason, offender)
    local random = math.random(1,10000)
    saveToDB(random, properties.model, json.encode(properties), reason, offender)
end)

function saveToDB(id, model, properties, reason, offender)
    local date = os.date('%Y-%m-%d %H:%M:%S')
    local trunk = "NONE"
    MySQL.Async.execute("INSERT INTO pen_garages (id, model, properties, trunk, date, reason, offender) VALUES (@id, @model, @properties, @trunk, @date, @reason, @offender)", {["@id"] = id, ["@model"] = model, ["@properties"] = properties, ["@trunk"] = trunk, ["@date"] = date, ["@reason"] = reason, ["@offender"] = offender})
    dbSync()
end

function dbSync()
    impound = {}
    MySQL.query('SELECT * FROM `pen_garages`', function(response)
        if response then
            for i = 1, #response do
                local row = response[i]
                --print(row.firstname, row.lastname)
                table.insert(impound, {
                    id = tonumber(row.id),
                    vehModel = tonumber(row.model),
                    vehProperties = json.decode(row.properties),
                    trunk = row.trunk,
                    date = row.date,
                    reason = row.reason,
                    offender = row.offender
                })
                --print(json.encode(impound))
            end
        end
        sendRefresh(-1)
    end)
end

function deleteCar(id, car, properties, reason)
    MySQL.prepare('DELETE FROM `pen_garages` WHERE `id` = ?', {
        id
    }, function(response)
        --print(json.encode(response, { indent = true, sort_keys = true }))
        --print('deleted')
    end)

    local date = os.date('%Y-%m-%d %H:%M:%S')
    MySQL.Async.execute("INSERT INTO pen_garages_logs (id, model, properties, reason, date) VALUES (@id, @model, @properties, @reason, @date)", {["@id"] = id, ["@model"] = model, ["@properties"] = properties, ["@reason"] = reason, ["@date"] = date})
    
    removeFromDatabase(id)
    dbSync()
    sendRefresh(-1)
end

function findKey(id)
    for key, value in ipairs(impound) do
        if tonumber(value.id) == tonumber(id) then
          return key
        end
    end
end

function removeFromDatabase(id)
    local key = findKey(id)
    table.remove(impound, key)
end



--[[RegisterCommand('testspawn', function(source, id)
    for k,v in ipairs(impound) do
        if v.id == id then
            TriggerClientEvent('pen-garages:spawnImpound', source, v.vehModel, v.vehProperties)
        end
    end
end)]]--

-- Send to client



function sendRefresh(playerId)

    TriggerClientEvent('pen-garages:refreshImpoundData', playerId, impound)
end

RegisterNetEvent('pen-garages:requestRefresh')
AddEventHandler('pen-garages:requestRefresh', function(playerServerId)
    sendRefresh(playerServerId)
end)

RegisterNetEvent('pen-garages:deleteImpound')
AddEventHandler('pen-garages:deleteImpound', function(id, car, properties, reason)
    deleteCar(id, car, properties, reason)
end)
