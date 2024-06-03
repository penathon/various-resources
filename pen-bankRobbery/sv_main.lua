local electricityBoxes = config.electricityBoxes
local banks = config.banks

function syncDataClient(player)
    TriggerClientEvent('pen-bankRobbery:client:syncData', player, electricityBoxes, banks)
end

RegisterNetEvent('pen-bankRobbery:server:requestData', function()
    syncDataClient(source)
end)

RegisterNetEvent('pen-bankRobbery:server:explodeDoor', function(data)
    local bankData = banks[data].data[1]
    bankData.doorOpen = true
    TriggerClientEvent('pen-bankRobbery:client:removeZone', -1, data)
    syncDataClient(-1)
end)

RegisterNetEvent('pen-bankRobbery:server:explodeBox', function(data)
    local box = electricityBoxes[data]
    if box then
        box.coords[1].exploded = true
        TriggerClientEvent('pen-bankRobbery:client:removeZone', -1, data)
        checkBoxes()
        syncDataClient(-1)
    end
end)

function checkBoxes()
    for bankName, bank in pairs(banks) do
        for _, bankData in ipairs(bank.data) do
            local allExploded = true
            for _, boxName in ipairs(bankData.electricityBoxes) do
                local box = electricityBoxes[boxName]
                if box then
                    for _, coord in ipairs(box.coords) do
                        if not coord.exploded then
                            allExploded = false
                            break
                        end
                    end
                else
                    allExploded = false
                end
                if not allExploded then break end
            end
            bankData.exploded = allExploded
            banks[bankName].data[1].ready = allExploded
            if allExploded then
                startHeist(bankName)
            end
        end
    end
end

function startHeist(bankName)
    local bankData = banks[bankName].data[1]
    bankData.active = true
    startCooldown(bankName)
    TriggerClientEvent('pen-bankRobbery:client:startHeist', -1, bankName)
end

function startCooldown(bankName)
    local bankData = banks[bankName].data[1]
    bankData.cooldownActive = true
    local timeCorrected = bankData.cooldownTime * 60000
    --lib.timer(timeCorrected, endCooldown(bankName), false)
end

function endCooldown(bankName)
    local bankData = banks[bankName].data[1]
    bankData.active = false
    syncDataClient(-1)
    resetElectricityBoxes(bankName)
    TriggerClientEvent('pen-bankRobbery:client:endHeist', -1, bankName)
end

function resetElectricityBoxes(bankName)
    local bank = banks[bankName]
    if bank then
        for _, dataEntry in ipairs(bank.data) do
            if dataEntry.electricityBoxes then
                for _, boxName in ipairs(dataEntry.electricityBoxes) do
                    local box = electricityBoxes[boxName]
                    if box then
                        for _, coord in ipairs(box.coords) do
                            coord.exploded = false
                        end
                    end
                end
            end
        end
    end
end
