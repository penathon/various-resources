local cachedData = {}

RegisterNetEvent( 'pen_util:PermissionsUpdated', function() end )

Citizen.CreateThread(function()
    --repeat Citizen.Wait(0) until NetworkIsPlayerActive(PlayerId())

    TriggerServerEvent "pen_util:PlayerReady"
end)

RegisterNetEvent('pen-util::cacheDataClient')
AddEventHandler('pen-util::cacheDataClient', function(data)
    cachedData = data
    print('^2[Info]^7 caching discord data')
end)

function IsRolePresent(role)
    if not Config.Roles[role] then return false end

    local roles = cachedData
    if roles == false then return false end

    for k, v in pairs(roles) do
        if v == Config.Roles[role] then
            return true
        end
    end

    return false
end

function IsStaff()
	for k, v in pairs( Config.StaffRoles ) do
		if IsRolePresent(k) then
			return true
		end
	end

	return false
end

exports( "IsRolePresent", IsRolePresent )
exports( "IsStaff", IsStaff )