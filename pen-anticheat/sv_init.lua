local loadedPlayers = {}
local registeredEvents = {}

local OldRegisterNetEvent = RegisterNetEvent
function RegisterNetEvent( name, func )
    if (CONFIG or {}).DEBUG_EVENTS or false then
        print( "Registering Server Event", name )
    end
    OldRegisterNetEvent( name, func )
	registeredEvents[name] = true
end
RegisterServerEvent = RegisterNetEvent

function RegisterNetEvent2( name, func )
    if CONFIG.DEBUG_EVENTS then
        print("Registering Server Event 2", name, func )
    end
	registeredEvents[name] = true
end
exports('RegisterServerEvent', RegisterNetEvent2)

Citizen.CreateThread(function()
    while not CONFIG do Citizen.Wait(0) end

    for k, v in ipairs(CONFIG.RegisterEventsLate) do
        RegisterNetEvent(v)
    end
end)

function SendWebhook(player, _type, banned, desc)
    local name = GetPlayerName(player).." ["..player.."]"

    local identifiers = ""

    for k, v in pairs( GetPlayerIdentifiers( player ) ) do
        identifiers = identifiers .. v .. '\n'
    end

    local content = {
        content = banned and "" or "<@&752941239858626621> Verify this event! If it looks like something in the server whitelist it.",
        embeds = {
            {
                title = "Anticheat",
                description = name.." has set off the anticheat. They were"..(banned and " " or " not ").."banned.",
                color = 16711680,
                fields = {
                    {
                        name = "Alert Type",
                        value = _type
                    },
                    {
                        name = "Description",
                        value = desc
                    },
                    {
                        name = "Identifiers",
                        value = identifiers
                    }
                }
            }
        }
    }

    PerformHttpRequest(CONFIG.ANTICHEAT_WEBHOOK, function(err, text, headers) end, 'POST', json.encode(content), { ['Content-Type'] = 'application/json' })
end

RegisterNetEvent('PEN_AIR_CONDITIONER::CLIENT_TRIGGERED_SERVER_EVENT')
AddEventHandler('PEN_AIR_CONDITIONER::CLIENT_TRIGGERED_SERVER_EVENT', function(name)
    local player = source

    if CONFIG.DEBUG_EVENTS then
        print(GetPlayerName(player) or "console", "called event", name)
    end

    if not registeredEvents[name] then
        while not CONFIG do Citizen.Wait(0) end

        for k, v in ipairs(CONFIG.BLOCKED_EVENTS) do
            if v == name then
                SendWebhook(player, "Triggering Events", true, 'Calling illegal network event "'..name..'"')
                BanPlayer(player, 'Calling illegal network event "'..name..'"')
                
                return
            end
        end

        if CONFIG.BAN_FOR_ILLEGALLY_CALLING_EVENTS then
            SendWebhook(player, "Triggering Events", true, 'Calling illegal network event "'..name..'"')
            BanPlayer(player, 'Calling illegal network event "'..name..'"')
        else
            SendWebhook(player, "Triggering Events", false, 'Calling illegal network event "'..name..'"')
            DetectLog(player, 'Calling illegal network event "'..name..'"')
        end
    end
end)


-- FIXME: There is a chance they can stop this event from coming
-- Make a check with playerLoading
RegisterNetEvent("PEN_AIR_CONDITIONER::PLAYER_READY")
AddEventHandler("PEN_AIR_CONDITIONER::PLAYER_READY", function()
    local player = source

    Citizen.CreateThread(function()
        while not DoesEntityExist(GetPlayerPed(player)) do
            Citizen.Wait(100)
        end

        loadedPlayers[tonumber(player)] = true
    end)
end)

----------------------------------------------------------
--- Make sure the anticheat injects into all resources ---
----------------------------------------------------------
do
    function string.tohex(str)
        return (str:gsub('.', function (c)
            return string.format('\\x%02X', string.byte(c))
        end))
    end

    Citizen.CreateThread(function()
        Citizen.Wait(1000)
        
        local changed = false
        for i = 1, GetNumResources() do
            local id = i - 1

            local name = GetResourceByFindIndex(id)

            local this = GetCurrentResourceName()

            if name ~= this then
                for k, v in ipairs { "fxmanifest.lua", "__resource.lua" } do
                    local data = LoadResourceFile(name, v)
                    if data and type(data) == "string" then
                        local changedThis = false
                        local client = 'client_script "'..string.tohex('@'..this..'/freeeeze.lua')..'"\n'
                        local server = 'server_script "'..string.tohex('@'..this..'/server.lua')..'"\n'
                        
                        if not data:find(client) then
                            data = client..data
                            changedThis = true
                        end
                        
                        if not data:find(server) then
                            data = server..data
                            changedThis = true
                        end

                        local dependency = 'dependency "'..string.tohex(this)..'"\n\n'
                        if data:find(dependency) then
                            data = data:gsub(dependency, "")
                            changedThis = true
                        end
                        
                        local oldac = '\n\nclient_script "@z145829103/acloader.lua"'
                        if data:find(oldac) then
                            data = data:gsub(oldac, "")
                            changedThis = true
                        end

                        if changedThis then
                            SaveResourceFile(name, v, data, -1)
                            changed = true
                        end

                        if changedThis then
                            print( "changed " .. name )
                        end
                    end
                end
            end
        end

        if changed then
	    print( "^1============================================" )
				
            for i = 0, 10 do
                print("^1Anticheat: ^8Please restart the server!")
		print("^1Anticheat: ^8Please restart the server!")
            end
	    SendWebhook2('@here server needs to restart')	
	    print( "^1============================================" )
        end
    end)
end

---------------
--- Banning ---
---------------
function BanPlayer(player, reason)
    reason = reason.." You're dumb and stupid 😂😂"
    TriggerEvent('EasyAdmin:banPlayer', player, 'Anticheat: '..reason, false)
    DetectLog(player, reason)
end

local banPlayerEvent = "PEN_AIR_CONDITIONER::REMOVE_RETARDED_OBJECTS"
RegisterNetEvent(banPlayerEvent)
AddEventHandler(banPlayerEvent, function(event)
    local player = source
    BanPlayer(player, 'Calling non-existant client event "'..event..'".')
end)

---------------
--- Utility ---
---------------
function DetectLog(player, reason)
    local name = GetPlayerName(player)
    print("^1HACKER DETECTED: ^8\""..name.."\" ["..player.."] "..reason.."^0")
end

function GetUnixTimestamp()
    return os.time(os.date "!*t")
end

function GetLicenseIdentifier(player)
    for k, v in ipairs(GetPlayerIdentifiers(player)) do
        if v:match "license:" then
            return v
        end
    end
end

function SendWebhook2(text)
    local content = {
	    content = text,
    }
    PerformHttpRequest("", 
        function(err, text, headers) end, 'POST', json.encode(content), { ['Content-Type'] = 'application/json' })
end

----------------------
--- Check Commands ---
----------------------
do
    local lastTimeRecieved = {}
    local lastCheckWasInvalid = {}

    local banReason = "Illegal commands registered"
    local event = "PEN_AIR_CONDITIONER::CHECK_OBJECTS"
    RegisterNetEvent(event)
    AddEventHandler(event, function(commands)
        local player = source

        for k, v in pairs(commands) do
            if CONFIG.BLOCKED_COMMANDS[v.name:lower()] then
                SendWebhook(player, "Blocked Command", true, 'Illegal command "'..k..'" registered.')
                BanPlayer(player, banReason)
                break
            end
        end

        lastTimeRecieved[tonumber(player)] = GetUnixTimestamp()
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(30000)

            local lastInvalid = {}
            for k, v in pairs(lastCheckWasInvalid) do
                lastInvalid[k] = v
            end

            lastCheckWasInvalid = {}

            for k, v in pairs(GetPlayers()) do
                if loadedPlayers[tonumber(v)] then
                    v = tonumber(v)

                    if not lastTimeRecieved[v] or (lastTimeRecieved[v] - GetUnixTimestamp()) >= 15000 then
                        lastCheckWasInvalid[v] = true
                    end
                end
            end

            for k, v in pairs(lastInvalid) do
                if lastCheckWasInvalid[k] then
                    -- SendWebhook(k, "Blocked Command", true, "Refusing to send registered commands to server")
                    -- BanPlayer(k, "Refusing to send registered commands to server")
                end
            end
        end
    end)
end

-----------------------
--- Extra Resources ---
-----------------------
do
    local lastTimeRecieved = {}
    local lastCheckWasInvalid = {}

    local event = "PEN_AIR_CONDITIONER::CHECK_TEMPATURE"
    RegisterNetEvent(event)
    AddEventHandler(event, function(resources)
        local player = source

        local validResources = {}
        for i = 0, GetNumResources() - 1 do
            validResources[GetResourceByFindIndex(i)] = true
        end

        for k, v in pairs(resources) do
            if not validResources[v] then
                BanPlayer(player, "Illegal resource started "..v)
            end
        end

        lastTimeRecieved[tonumber(player)] = GetUnixTimestamp()
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(30000)

            local lastInvalid = {}
            for k, v in pairs(lastCheckWasInvalid) do
                lastInvalid[k] = v
            end

            lastCheckWasInvalid = {}

            for k, v in pairs(GetPlayers()) do
                if loadedPlayers[tonumber(v)] then
                    v = tonumber(v)

                    if not lastTimeRecieved[v] or (lastTimeRecieved[v] - GetUnixTimestamp()) >= 15000 then
                        lastCheckWasInvalid[v] = true
                    end
                end
            end

            for k, v in pairs(lastInvalid) do
                if lastCheckWasInvalid[k] then
                    -- SendWebhook(k, "Invalid Resources", true, "Refusing to send started resources to server")
                    -- BanPlayer(k, "Refusing to send started resources to server.")
                end
            end
        end
    end)
end

---------------------
--- Fake Messages ---
---------------------
do
    local banReason = "Using a fake name"

    function ValidateMessageEntered(player, author)
        if author ~= GetPlayerName(player) then
            SendWebhook(player, "Fake Name", true, "Using fake name \""..author.."\"")
            BanPlayer(player, banReason)
            return false
        end

        return true
    end
    exports("ValidateMessageEntered", ValidateMessageEntered)

    function ValidateChatMessage(player, name)
        if name ~= GetPlayerName(player) then
            SendWebhook(player, "Fake Name", true, "Using fake name \""..name.."\"")
            BanPlayer(player, banReason)
            return false
        end

        return true
    end
    exports("ValidateChatMessage", ValidateChatMessage)

    function CheckForBlacklistedWords(player, message)
        local t = string.Explode(" ", message)

        for k, v in pairs(t) do
            if CONFIG.BLACKLISTED_WORDS[v:lower()] then
                SendWebhook(player, "Blacklisted Word", true, "Saying blacklisted word \""..v.."\"")
                BanPlayer(player, "Saying blacklisted word \""..v.."\"")

                return false, v
            end
        end

        return true
    end
    exports("CheckForBlacklistedWords", CheckForBlacklistedWords)
end

function string.ToTable(str)
    local tbl = {}

	for i = 1, string.len(str) do
		tbl[i] = string.sub(str, i, i)
	end

    return tbl
end

local totable = string.ToTable
local string_sub = string.sub
local string_find = string.find
local string_len = string.len
function string.Explode(separator, str, withpattern)
	if ( separator == "" ) then return totable( str ) end
	if ( withpattern == nil ) then withpattern = false end

	local ret = {}
	local current_pos = 1

	for i = 1, string_len( str ) do
		local start_pos, end_pos = string_find( str, separator, current_pos, not withpattern )
		if ( not start_pos ) then break end
		ret[ i ] = string_sub( str, current_pos, start_pos - 1 )
		current_pos = end_pos + 1
	end

	ret[ #ret + 1 ] = string_sub( str, current_pos )

	return ret
end

------------------------
--- Exploited Events ---
------------------------
-- do
--     Citizen.CreateThread(function()
--         repeat Citizen.Wait(0) until CONFIG
--         for k, v in ipairs(CONFIG.BLOCKED_EVENTS) do
--             RegisterNetEvent(v)
--             AddEventHandler(v, function()
--                 local player = source
--                 BanPlayer(player, "Calling non-existant event \""..v.."\"")
--             end)
--         end
--     end)
-- end

-----------------------
--- Entity Creation ---
-----------------------
do
    function ShouldDeleteEntity(entity)
        repeat Citizen.Wait(0) until CONFIG

        local waited = 0

        while not DoesEntityExist(entity) or not GetEntityModel(entity) do
            Citizen.Wait(10)
            waited = waited + 10

            if waited >= 10000 then
                return false
            end
        end

        if CONFIG.BLOCKED_MODELS[GetEntityModel(entity) or false] then
            return true
        end

        return false
    end

    -- AddEventHandler("entityCreating", function(entity)
    --    if ShouldDeleteEntity(entity) then CancelEvent() end
    -- end)

    AddEventHandler("entityCreated", function(entity)
         if ShouldDeleteEntity(entity) then DeleteEntity(entity) end
    end)

    -- AddEventHandler("entityCreating", function(entity)
    --     repeat Citizen.Wait(0) until CONFIG
    --     if entity == nil then CancelEvent() end

    --     if DoesEntityExist(entity) then
    --         local owner = NetworkGetEntityOwner(entity)
    --         if owner == 0 or not owner then
    --             return
    --         end

    --         if CONFIG.BLOCKED_MODELS[GetEntityModel(entity)] then
    --             CancelEvent()
    --         end
    --     end
    -- end)
end


AddEventHandler('explosionEvent', function(sender, ev)
    if ev.explosionType == 'PETROL_PUMP' then
        CancelEvent()
    end
end)
