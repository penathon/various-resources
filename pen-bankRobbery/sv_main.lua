local electricityBoxes = config.electricityBoxes
local banks = config.banks

function syncDataClient(player)
    TriggerClientEvent('pen-bankRobbery:client:syncData', player, electricityBoxes, banks)
end

RegisterNetEvent('pen-bankRobbery:server:requestData', function()
    local src = source
    syncDataClient(src)
end)

RegisterNetEvent('pen-bankRobbery:server:explodeBox', function(data)
    electricityBoxes[data].coords[1].exploded = true
    TriggerClientEvent('pen-bankRobbery:client:removeBox', -1, data)
    checkBoxes()
    syncDataClient(-1)
end)

function checkBoxes()
    local allExploded

    for bankName, bank in pairs(banks) do
        for _, bankData in ipairs(bank.data) do
            allExploded = true
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
        end
    end
    
    for bankName, bank in pairs(banks) do
        for _, bankData in ipairs(bank.data) do
            banks[bankName].data[1].ready = bankData.exploded
            if bankData.exploded then
                startHeist(bankName)
            end
        end
    end
end

function startHeist(bankName)
    banks[bankName].data[1].active = true
    startCooldown(bankName)
    TriggerClientEvent('pen-bankRobbery:client:startHeist', -1, bankName)
end

function startCooldown(bankName)
    banks[bankName].data[1].cooldownActive = true
    local timeCorrected = (banks[bankName].data[1].cooldownTime * 60000)
    lib.timer(timeCorrected, endCooldown(bankName), true)
end

function endCooldown(bankName)
    banks[bankName].data[1].active = false
    syncDataClient(-1)
    TriggerClientEvent('pen-bankRobbery:client:endHeist', -1, bankName)
end
