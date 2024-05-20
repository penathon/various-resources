local activeCalls = {}

RegisterNetEvent('pen-callHandling:createCall')
AddEventHandler('pen-callHandling:createCall', function(caller, callId, message)
    --print(caller, callId, message)
    local inTable = has_value(callId)
    if not inTable then
        table.insert( activeCalls, {
            callId = callId,
            originCaller = tonumber(caller)
        })
        print('^1[callHandling]^7 Created call with ID - ' .. callId .. '')

        local data = exports["pen-core"]:GetCharacterData(tonumber(caller))
        local name = "" .. data.firstName .. " | " .. data.lastName .. ""
        sendMessage(caller, callId, message, name)
        for k, v in ipairs( GetPlayers() ) do
            local state = Player( v ).state.clockin or { isLeo = false, isFire = false }
            if state.isLeo then 
                sendMessage(v, callId, message, name)
            end
        end
    end

    --print(json.encode(activeCalls, {indent=true}))
end)

RegisterCommand('911r', function(source, args)
    local callId = args[1]
    local message = concatText(args, 2)
    local player = source

    local data = exports["pen-core"]:GetCharacterData(player)
    local name = "" .. data.firstName .. " | " .. data.lastName .. ""

    local isReplierCop = Player( source ).state.clockin or { isLeo = false, isFire = false }
    local inTable = has_value(callId)
    if callId ~= nil then
        if inTable then
            for k,v in ipairs(activeCalls) do
                if v.callId == tonumber(callId) then -- checks if callid in table matches one sent in command
                    --print('call id matches')
                    --print(v.originCaller, player)
                    if v.originCaller == player then 
                        sendMessage(player, callId, message, name)
                        for k, v in ipairs( GetPlayers() ) do
                            local state = Player( v ).state.clockin or { isLeo = false, isFire = false }
                            if state.isLeo then 
                                sendMessage(v, callId, message, name)
                            end
                        end
                    elseif isReplierCop.isLeo then
                        sendMessage(v.originCaller, callId, message, name)
                        for k, v in ipairs( GetPlayers() ) do
                            local state = Player( v ).state.clockin or { isLeo = false, isFire = false }
                            if state.isLeo then 
                                sendMessage(v, callId, message, name)
                            end
                        end
                    else
                        TriggerClientEvent('showmythic', player, "" .. callId .. " - Call ID is invalid.")
                    end
                end
            end
        else
            TriggerClientEvent('showmythic', player, "" .. callId .. " - Call ID is invalid.")
        end
    end
end)

function has_value (val)
    for index, value in ipairs(activeCalls) do
        if value.callId == tonumber(val) then
            return true
        end
    end
    return false
end

function sendMessage(id, callId, message, name)
    TriggerClientEvent('chat:addMessage', id, { 
        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(158, 0, 0, 0.25); border-radius: 5px;"><i class="fas fa-user-crown"></i> {0} </div>',
        args = { "^7911 | (" .. callId .. ") " .. name .. " : ^7\n"..message }, color = { 255, 255, 255 } 
    })
end

--[[RegisterCommand('fake911test', function(source, args)
    local message = table.concat(args, " ")
    TriggerEvent('pen-callHandling:createCall', source, math.random(1,20000), message)
end)]]--

function concatText(args, index)
    -- Get the second argument and everything after it
  local startIndex = index -- Change this number if your arguments start at a different index
  local arguments = {}
  for i = startIndex, #args do
    table.insert(arguments, args[i])
  end
  
  -- Concatenate the arguments
  local concatenated = table.concat(arguments, " ")
  
  -- Do something with the concatenated string
  return concatenated
end