local electricityBoxes = config.electricityBoxes
local banks = config.banks

function syncDataClient(player)
    TriggerClientEvent('pen-bankRobbery:client:syncData', player, electricityBoxes, banks)
end

RegisterNetEvent('pen-bankRobbery:server:requestData', function()
    local src = source
    syncDataClient(src)
end)

RegisterNetEvent('pen-bankRobbery:server:explodeDoor', function(data)
    banks[bankName].data[1].doorOpen = true
    syncDataClient(-1)
    TriggerClientEvent('pen-bankRobbery:client:openDoor', -1, data)
end)

RegisterNetEvent('pen-bankRobbery:server:explodeBox', function(data)
    electricityBoxes[data].coords[1].exploded = true
    TriggerClientEvent('pen-bankRobbery:client:openDoor', -1, data)
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
    -- function to check electricity box that is included in bank config if yes then exploded = false
    syncDataClient(-1)
    resetElectricityBoxes(bankName)
    TriggerClientEvent('pen-bankRobbery:client:endHeist', -1, bankName)
end

function resetElectricityBoxes(bankName)

    if banks[bankName] then
        for _, dataEntry in ipairs(banks[targetBankName].data) do
            if dataEntry.electricityBoxes then
                for _, boxName in ipairs(dataEntry.electricityBoxes) do
                    if electricityBoxes[boxName] then
                        for _, coord in ipairs(electricityBoxes[boxName].coords) do
                            coord.exploded = false
                        end
                    end
                end
            end
        end
    end

    for boxName, boxData in pairs(electricityBoxes) do
        for _, coord in ipairs(boxData.coords) do
            print(boxName, coord.x, coord.y, coord.z, coord.exploded)
        end
    end

end