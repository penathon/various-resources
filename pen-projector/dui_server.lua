local activeDui = {}
local savedDui = "https://media.tenor.com/NQfq1liFH-8AAAAd/byuntear-sad.gif"

RegisterNetEvent('pen-police:duiSave')
AddEventHandler('pen-police:duiSave', function(image)
    savedDui = image
    TriggerClientEvent('pen-police:duiChange', -1, savedDui)
    --SendWebhook('**' .. GetPlayerName(source) .. '** has changed the board room URL to **' .. image .. '**')
end)

RegisterCommand('pen-dui:changeMRPD', function(source, args)
    if source == 0 then
        local image = args[1]
        savedDui = image
        TriggerClientEvent('pen-police:duiChange', -1, savedDui)
    end
end)

RegisterNetEvent('pen-police:duiRecieve')
AddEventHandler('pen-police:duiRecieve', function()
    TriggerClientEvent('pen-police:duiChange', -1, savedDui)
end)

RegisterNetEvent('pen-police:InitialduiRecieve')
AddEventHandler('pen-police:InitialduiRecieve', function(id)
    --print(id)
    TriggerClientEvent('pen-police:InitialduiChange', id, savedDui)
end)


function SendWebhook(text)
    local content = {
	    content = text,
    }

    PerformHttpRequest("", 
        function(err, text, headers) end, 'POST', json.encode(content), { ['Content-Type'] = 'application/json' })
end