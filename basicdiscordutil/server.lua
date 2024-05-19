local FormattedToken = "Bot "..Config.DiscordToken
local cache = {}

function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
		data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = FormattedToken})

    while data == nil do
        Citizen.Wait(0)
    end
	
    return data
end

function send(src, msg)
    --TriggerClientEvent('chat:addMessage', src, {
    --   args = { msg }
    --})
end

function GetUnixTimestamp()
    return os.time(os.date "!*t")
end

function LoadAcePerms()
	local endpoint = ("v9/guilds/%s/members?limit=750"):format( Config.GuildId )
	local request = DiscordRequest( "GET", endpoint, { } )

	if request.code == 200 then
		local data = json.decode( request.data )
		
		for k, v in ipairs( data ) do
			local found = {}

			for k2, v2 in ipairs( v.roles ) do
				local role = GetRoleNameFromId( v2 )
				if not role then goto continue end
				if not Config.RolesToAce[role] then goto continue end

				found[#found + 1] = role
				ExecuteCommand( "add_principal identifier.discord:" .. v.user.id .. " " .. Config.RolesToAce[role] )
	
				::continue::
			end

			if #found ~= 0 then
				local str = ""

				for k, v in ipairs( found ) do
					str = str .. v .. ", "
				end

				str = str:sub( 1, -3 )
				print( "^2[Info]^7 Found discord roles [ " .. str .. " ] on discord user `" .. v.user.username .. "`." )
			end
		end
	else
		print(request.code)
	end

	GlobalState.HasLoadedPermissions = true
end

Citizen.CreateThread( function()
	if not GlobalState.HasLoadedPermissions then
		LoadAcePerms()
	end
end )

RegisterCommand( "_reloadallperms", function( player )
	if player ~= 0 then return end
	LoadAcePerms()
end )

function GetDiscordId( user )
	for _, id in ipairs( GetPlayerIdentifiers( user ) or {} ) do
		if string.match(id, "discord:") then
			return string.gsub(id, "discord:", "")
		end
	end

	return nil
end
exports( 'GetDiscordId', GetDiscordId )

--[[function GetRoles( user, ignoreCache )
	if user == nil then return {} end

	if not ignoreCache then
		if cache[user] and cache[user].lastUpdated < GetUnixTimestamp() + 60 then
			return cache[user].roles
		end
	end

	local discordId = GetDiscordId( user )

	if discordId then
		local endpoint = ("guilds/%s/members/%s"):format(Config.GuildId, discordId)
		local member = DiscordRequest("GET", endpoint, {})
        if member.code == 200 then
			local decoded = json.decode( member.data )
            cache[user] = {
                lastUpdated = GetUnixTimestamp(),
                roles = decoded.roles,
				name = ( decoded.nick ~= '' and decoded.nick or decoded.username )
            }

            return json.decode(member.data).roles
        elseif member.code == 429 then
            print( "^1[Error]^7 ".. GetPlayerName(user) .." has been ratelimited by discord while getting permissions." )
            return false
		else
			--print( "^1[Error]^7 An error occured, maybe they arent in the discord? Code: " .. member.code .. " Error: "..member.data )
			return false
		end
	else
		--print( "^1[Error]^7 Missing Identifier" )
		return false
	end
end]]--

--test

local blacklist = {}

function GetRoles( user, ignoreCache )
	if user == nil then return {} end

	--print('^2[Info]^7 starting cache function for ' .. GetPlayerName(user) .. '')

	if cache[user] then
		--print('checking cached data!')
		--print(cache[user].roles)
		return cache[user].roles
	end

	local discordId = GetDiscordId( user )

	if not blacklist[user] then
		if not cache[user] then
			if discordId then
				local endpoint = ("guilds/%s/members/%s"):format(Config.GuildId, discordId)
				local member = DiscordRequest("GET", endpoint, {})
				if member.code == 200 then
					local decoded = json.decode( member.data )
					cache[user] = {
						lastUpdated = GetUnixTimestamp(),
						roles = decoded.roles,
						name = ( decoded.nick ~= '' and decoded.nick or decoded.username )
					}
					print('^2[Info]^7 caching discord data for ' .. GetPlayerName(user) .. '')
					TriggerClientEvent('pen-util::cacheDataClient', user, json.decode(member.data).roles)
					return json.decode(member.data).roles
				elseif member.code == 429 then
					print( "^1[Error]^7 ".. GetPlayerName(user) .." has been ratelimited by discord while getting permissions." )
					TriggerClientEvent('pen-util::cacheDataClient', user, false)
					blacklist[user] = {
						name = GetPlayerName(user)
					}
					return false
				else
					--print( "^1[Error]^7 An error occured, maybe they arent in the discord? Code: " .. member.code .. " Error: "..member.data )
					TriggerClientEvent('pen-util::cacheDataClient', user, false)
					return false
				end
			else
				--print( "^1[Error]^7 Missing Identifier" )
				TriggerClientEvent('pen-util::cacheDataClient', user, false)
				return false
			end
		end
	else
		--print( "^1[Error]^7 ".. GetPlayerName(user) .." has been blacklisted for too many requests." )
		return false
	end
end

--[[RegisterCommand('pen-util:unblacklistdiscord', function(source, person)
	if source == 0 then
		blacklist[person] = nil
	end
end)]]--

AddEventHandler('playerDropped', function(reason)
    local user = source

	cache[user] = nil
	blacklist[user] = nil
end)

function IsRolePresent(user, role)
    if not Config.Roles[role] then return false end

    local roles = GetRoles(user)
    if roles == false then return false end

    for k, v in pairs(roles) do
        if v == Config.Roles[role] then
            return true
        end
    end

    return false
end

function IsCop( player )
	for k, v in pairs( Config.CopRoles ) do
		if IsRolePresent( player, k ) then
			return true
		end
	end

	return false
end
IsPolice = IsCop

function IsFire( player )
	for k, v in pairs( Config.FireRoles ) do
		if IsRolePresent( player, k ) then
			return true
		end
	end

	return false
end

function IsStaff( player )
	for k, v in pairs( Config.StaffRoles ) do
		if IsRolePresent( player, k ) then
			return true
		end
	end

	return false
end

function IsCiv( player )
	for k, v in pairs( Config.CivRoles ) do
		if IsRolePresent( player, k ) then
			return true
		end
	end

	return false
end
IsCivilian = IsCiv

exports( "GetRoles", GetRoles )
exports( "IsRolePresent", IsRolePresent )
exports( "IsCivlian", IsCivilian )
exports( "IsPolice", IsPolice )
exports( "IsFire", IsFire )
exports( "IsCop", IsCop )
exports( "IsCiv", IsCiv )
exports( "IsStaff", IsStaff )

function AddAcePermissions( player, ignoreCache )
    local roles = GetRoles( player, ignoreCache )

    if roles then
        for k, v in pairs(roles) do
            for k2, v2 in pairs(Config.RolesToAce) do
                if Config.Roles[k2] == v then
                    print("^2[Info]^7 Found discord role `"..k2.."` on player "..GetPlayerName(player)..". Giving `"..v2.."`.")
                    for k3, v3 in pairs(GetPlayerIdentifiers(player)) do
                        ExecuteCommand("add_principal identifier."..v3.." "..v2)
						TriggerEvent( "pen_util:PlayerRolesUpdated", player )
						TriggerClientEvent( 'pen_util:PermissionsUpdated', player )
                    end
                end
            end
        end
    end
end

RegisterNetEvent "pen_util:PlayerReady"
AddEventHandler("pen_util:PlayerReady", function()
    local player = source
	--print('player is ready')
	print('^2[Info]^7 ' .. GetPlayerName(player) .. ' is ready')
    AddAcePermissions(player)
    --TriggerClientEvent("pen_util:RolesGiven", player)
	--TriggerClientEvent( 'pen_util:SendNames', player, GetAllPlayerNames() )
end)

RegisterCommand("refreshpermissions", function( player )
	cache[player] = nil
    AddAcePermissions( player, true )	
end)

function FireWebhook( key, content, callback )
	PerformHttpRequest( 
		Config.Webhooks[key], 
		callback or function() end, 
		'POST', 
		type( content ) == 'string' and content or json.encode( content ),
		{ ['Content-Type'] = 'application/json' }
	)
end
exports( 'FireWebhook', FireWebhook )

function GetWebhookAvatarUrl()
	return 'https://penathon.wtf/i/penathon/possessive-cynical-jackal.png'
end
exports( 'GetWebhookAvatarUrl', GetWebhookAvatarUrl )

local nameFromIdCache = {}
function GetRoleNameFromId( id )
	if nameFromIdCache[id] then return nameFromIdCache[id] end

	for k, v in pairs( Config.Roles ) do
		nameFromIdCache[v] = k
	end

	return nameFromIdCache[id] or false
end

function GetTierNumber( player, ignoreCache )
	if IsRolePresent( player, "Superadmin", ignoreCache ) then
		return 4
	end

	local highest = 0

	for k, v in pairs( GetRoles( player, ignoreCache ) or {} ) do
		local name = GetRoleNameFromId( v )
		local str = 'Tier '
		local len = ( str ):len()

		if name and name:sub( 1, len ) == str then
			local num = tonumber( name:sub( len, len + 1 ) ) 

			if num > highest then
				highest = num
			end
		end
	end

	return highest
end
exports( 'GetTierNumber', GetTierNumber )

local function IsSuperadmin( player )
	return IsRolePresent( player, "Superadmin" )
end
exports( 'IsSuperadmin', IsSuperadmin )
exports( 'IsSuperAdmin', IsSuperadmin )

local players = json.decode( GetResourceKvpString( 'players' ) )

if players == nil then
	players = {}
	SetResourceKvp( 'players', json.encode( {} ) )
end

function GetAllPlayerNames()
	local t = {}

	for k, v in ipairs( GetPlayers() ) do
		t[v] = GetPlayerServerName( v )
	end

	return t
end

function GetNearestPlayer( coords )
	local nearest = -1
	local distance = -1
	
	for k, v in ipairs( GetPlayers() ) do
		local p = GetPlayerPed( v )
		local position = GetEntityCoords( p )
		local d = #( coords - position ) 

		if distance == -1 or d < distance then
			nearest = v
			distance = d
		end
	end

	return nearest, distance
end
exports( 'GetNearestPlayer', GetNearestPlayer )

function GetNearestPlayerOnFoot( coords, atGetIn )
	if atGetIn == nil then atGetIn = true end

	local nearest = -1
	local distance = -1
	
	for k, v in ipairs( GetPlayers() ) do
		local p = GetPlayerPed( v )

		if not DoesEntityExist( GetVehiclePedIsIn( p, atGetIn ) ) then
			local position = GetEntityCoords( p )
			local d = #( coords - position ) 

			if distance == -1 or d < distance then
				nearest = v
				distance = d
			end
		end
	end

	return nearest, distance
end
exports( 'GetNearestPlayerOnFoot', GetNearestPlayerOnFoot )


function GetPlayerServerName( player )
	if cache[player] then
		return cache[player].name
	end

	return GetPlayerName( player )
	-- players[player] = players[player] or { callsign = '' }

	-- local name = GetPlayerName( player )
	-- local pattern = "~([rbxgtypqocmuw])~"
	-- name = name:gsub( pattern, '' )

	-- players[player].callsign = players[player].callsign or ''

	-- return players[player].callsign .. ' ' .. name
end
exports( 'GetPlayerName', GetPlayerServerName )

--[[RegisterCommand( 'setcallsign', function( player, args )
	players = players or {}

	players[player] = players[player] or {}
	players[player].callsign = table.concat( args, ' ' )

	TriggerClientEvent( 'pen_util:UpdateName', -1, player, GetPlayerServerName( player ) )
	TriggerEvent( 'pen_util:PlayerNameChanged', player, GetPlayerServerName( player ) )

	SetResourceKvp( 'players', json.encode( players ) )
end )]]--

card = '{"type":"AdaptiveCard","$schema":"http://adaptivecards.io/schemas/adaptive-card.json","version":"1.3","body":[{"type":"Image","url":"","horizontalAlignment":"Center"},{"type":"Container","items":[{"type":"TextBlock","text":"Welcome To test Roleplay","wrap":true,"fontType":"Default","size":"ExtraLarge","weight":"Bolder","color":"Light","horizontalAlignment":"Center"},{"type":"TextBlock","text":"Make sure to join our Discord and teamspeak","wrap":true,"color":"Light","size":"Medium","horizontalAlignment":"Center"},{"type":"ColumnSet","height":"stretch","minHeight":"100px","bleed":true,"horizontalAlignment":"Center","columns":[{"type":"Column","width":"stretch","items":[{"type":"ActionSet","actions":[{"type":"Action.OpenUrl","title":"Discord","url":"https://discord.alabamasrp.com","style":"positive"}],"horizontalAlignment":"Center"},{"type":"ActionSet","actions":[{"type":"Action.OpenUrl","title":"Teamspeak","url":"https://ts.alabamasrp.com","style":"positive"}],"horizontalAlignment":"Center"},{"type":"ActionSet","actions":[{"type":"Action.OpenUrl","title":"CAD","url":"https://cad.alabamasrp.com","style":"positive"}],"horizontalAlignment":"Center"}],"height":"stretch","horizontalAlignment":"Center","verticalContentAlignment":"Center"}]}],"style":"default","bleed":true,"height":"stretch"},{"type":"TextBlock","text":"You will automatically connect in 10 seconds","wrap":true,"color":"Light","size":"Small","horizontalAlignment":"Center"}]}'
if Config.Splash.Enabled then 
	AddEventHandler('playerConnecting', function(name, setKickReason, deferrals) 
		-- Player is connecting
		deferrals.defer();
		local src = source;
		local toEnd = false;
		local count = 0;
		while not toEnd do 
			deferrals.presentCard(card,
			function(data, rawData)
			end)
			Wait((1000))
			count = count + 1;
			if count == Config.Splash.Wait then 
				toEnd = true;
			end
		end
		deferrals.done();
		print('^2[Deferral]^7 Done - Player ' .. name .. ' is now joining server.')
	end)
end 

GlobalState.leoCount = 0
GlobalState.fireCount = 0
GlobalState.totalPlayers = 0

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(15000)
		updateServerStats()
	end
end)

function updateServerStats()
	local players = #GetPlayers()
    local leoCount, fireCount = 0, 0
    for k, v in ipairs( GetPlayers() ) do
		local state = Player( v ).state.clockin or { isLeo = false, isFire = false }
		if state.isLeo then leoCount = leoCount + 1 end
		if state.isFire then fireCount = fireCount + 1 end
	end

    GlobalState.leoCount = leoCount
	GlobalState.fireCount = fireCount
	GlobalState.totalPlayers = players
    --print(result)
end