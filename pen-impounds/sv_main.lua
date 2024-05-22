impound = {}
impoundLogs = {}

Citizen.CreateThread(function()
    dbSync()
end)

function dbSync()
    MySQL.query('SELECT * FROM `pen_garages`', function(response)
        if response then
            for i = 1, #response do
                local row = response[i]
                table.insert(impound, {
                    id = tonumber(row.id),
                    vehModel = tonumber(row.model),
                    vehProperties = json.decode(row.properties),
                    trunk = row.trunk,
                    date = row.date,
                    reason = row.reason,
                    offender = row.offender,
                    impoundee = row.impoundee
                })
                print('found row')
            end
        end
    end)

    MySQL.query('SELECT * FROM `pen_garages_logs`', function(response)
        if response then
            for i = 1, #response do
                local row = response[i]
                table.insert(impoundLogs, {
                    id = tonumber(row.id),
                    vehModel = tonumber(row.model),
                    date = row.date,
                    reason = row.reason,
                    offender = row.offender,
                    impoundee = row.impoundee
                })
            end
        end
    end)
    print('synced')
    sendRefresh(-1)
end

function deleteCar(id, car, properties, reason, offender, impoundee)
    removeFromDatabase(id)
    addToLog(id, car, properties, reason, offender, impoundee)
    Citizen.Wait(1000)
    dbSync()
end

function saveToDB(id, model, properties, reason, offender, impoundee)
    local date = os.date('%Y-%m-%d %H:%M:%S')
    local trunk = "NONE"
    MySQL.Async.execute("INSERT INTO pen_garages (id, model, properties, trunk, date, reason, offender, impoundee) VALUES (@id, @model, @properties, @trunk, @date, @reason, @offender, @impoundee)", {["@id"] = id, ["@model"] = model, ["@properties"] = properties, ["@trunk"] = trunk, ["@date"] = date, ["@reason"] = reason, ["@offender"] = offender, ["@impoundee"] = impoundee})
    Citizen.Wait(1000)
    dbSync()
end

function removeFromDatabase(id)
    local key = findKey(id, impound)
    MySQL.prepare('DELETE FROM `pen_garages` WHERE `id` = ?', { id }, function(response) end)
    table.remove(impound, key)
end

function findKey(id, table)
    for k,v in ipairs(table) do
        if v.id == id then
            return k
        end
    end
end

function sendRefresh(playerId)
    TriggerClientEvent('pen-garages:refreshImpoundData', playerId, impound, impoundLogs)
end

function addToLog(id, model, properties, reason, offender, impoundee)
    print(id, model, properties, reason, offender, impoundee)
    local date = os.date('%Y-%m-%d %H:%M:%S')
    MySQL.Async.execute("INSERT INTO pen_garages_logs (id, model, reason, date, offender, impoundee) VALUES (@id, @model, @reason, @date, @offender, @impoundee)", {["@id"] = id, ["@model"] = model, ["@reason"] = reason, ["@date"] = date, ["@offender"] = offender, ["@impoundee"] = impoundee})
end

RegisterNetEvent('pen-garages:requestRefresh')
AddEventHandler('pen-garages:requestRefresh', function(playerServerId)
    sendRefresh(playerServerId)
    print(json.encode(impound, { indent = true, sort_keys = true }))
end)

RegisterNetEvent('pen-garages:deleteImpound')
AddEventHandler('pen-garages:deleteImpound', function(id, car, properties, reason, offender, impoundee)
    deleteCar(id, car, properties, reason, offender, impoundee)
end)

RegisterNetEvent('pen-garages:saveImpound')
AddEventHandler('pen-garages:saveImpound', function(properties, netId, reason, offender)
    local src = source
    local random = math.random(1,10000)
    saveToDB(random, properties.model, json.encode(properties), reason, offender, GetPlayerName(src))
end)