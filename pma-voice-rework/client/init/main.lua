local mutedPlayers = {}

-- we can't use GetConvarInt because its not a integer, and theres no way to get a float... so use a hacky way it is!
local volumes = {
	-- people are setting this to 1 instead of 1.0 and expecting it to work.
	['radio'] = tonumber(GetConvar('voice_defaultRadioVolume', '0.3')) + 0.0,
	['phone'] = tonumber(GetConvar('voice_defaultPhoneVolume', '0.6')) + 0.0,
}

radioEnabled, radioPressed, mode = true, false, GetConvarInt('voice_defaultVoiceMode', 2)
radioData = {}
callData = {}

--- function setVolume
--- Toggles the players volume
---@param volume number between 0 and 100
---@param volumeType string the volume type (currently radio & call) to set the volume of (opt)
function setVolume(volume, volumeType)
	type_check({volume, "number"})
	local volume = volume
	volume = volume / 100
	if volumeType then
		local volumeTbl = volumes[volumeType]
		if volumeTbl then
			LocalPlayer.state:set(volumeType, volume, true)
			volumes[volumeType] = volume
		else
			error(('setVolume got a invalid volume type %s'):format(volumeType))
		end
	else
		-- _ is here to not mess with global 'type' function
		for _type, vol in pairs(volumes) do
			volumes[_type] = volume
			LocalPlayer.state:set(_type, volume, true)
		end
	end
end

exports('setRadioVolume', function(vol)
	setVolume(vol, 'radio')
end)
exports('getRadioVolume', function()
	return volumes['radio']
end)
exports("setCallVolume", function(vol)
	setVolume(vol, 'phone')
end)
exports('getCallVolume', function()
	return volumes['phone']
end)


-- default submix incase people want to fiddle with it.
-- freq_low = 389.0
-- freq_hi = 3248.0
-- fudge = 0.0
-- rm_mod_freq = 0.0
-- rm_mix = 0.16
-- o_freq_lo = 348.0
-- 0_freq_hi = 4900.0

if gameVersion == 'fivem' then
	radioEffectId = CreateAudioSubmix('Radio')
	SetAudioSubmixEffectRadioFx(radioEffectId, 0)
	SetAudioSubmixEffectParamInt(radioEffectId, 0, GetHashKey('default'), 1)
	AddAudioSubmixOutput(radioEffectId, 0)

	phoneEffectId = CreateAudioSubmix('Phone')
	SetAudioSubmixEffectRadioFx(phoneEffectId, 1)
	SetAudioSubmixEffectParamInt(phoneEffectId, 1, GetHashKey('default'), 1)
	SetAudioSubmixEffectParamFloat(phoneEffectId, 1, GetHashKey('freq_low'), 300.0)
	SetAudioSubmixEffectParamFloat(phoneEffectId, 1, GetHashKey('freq_hi'), 6000.0)
	AddAudioSubmixOutput(phoneEffectId, 1)
end

local submixFunctions = {
	['radio'] = function(plySource)
		MumbleSetSubmixForServerId(plySource, radioEffectId)
	end,
	['phone'] = function(plySource)
		MumbleSetSubmixForServerId(plySource, phoneEffectId)
	end
}

-- used to prevent a race condition if they talk again afterwards, which would lead to their voice going to default.
local disableSubmixReset = {}
--- function toggleVoice
--- Toggles the players voice
---@param plySource number the players server id to override the volume for
---@param enabled boolean if the players voice is getting activated or deactivated
---@param moduleType string the volume & submix to use for the voice.
function toggleVoice(plySource, enabled, moduleType)
	if mutedPlayers[plySource] then return end
	logger.verbose('[main] Updating %s to talking: %s with submix %s', plySource, enabled, moduleType)
	if enabled then
		MumbleSetVolumeOverrideByServerId(plySource, enabled and volumes[moduleType])
		if GetConvarInt('voice_enableSubmix', 0) == 1 and gameVersion == 'fivem' then
			if moduleType then
				disableSubmixReset[plySource] = true
				submixFunctions[moduleType](plySource)
			else
				MumbleSetSubmixForServerId(plySource, -1)
			end
		end
	else
		if GetConvarInt('voice_enableSubmix', 0) == 1 and gameVersion == 'fivem' then
			-- garbage collect it
			disableSubmixReset[plySource] = nil
			SetTimeout(250, function()
				if not disableSubmixReset[plySource] then
					MumbleSetSubmixForServerId(plySource, -1)
				end
			end)
		end
		MumbleSetVolumeOverrideByServerId(plySource, -1.0)
	end
end

--- function playerTargets
---Adds players voices to the local players listen channels allowing
---Them to communicate at long range, ignoring proximity range.
---@param targets table expects multiple tables to be sent over
function playerTargets(...)
	local targets = {...}
	local addedPlayers = {
		[playerServerId] = true
	}

	for i = 1, #targets do
		for id, _ in pairs(targets[i]) do
			-- we don't want to log ourself, or listen to ourself
			if addedPlayers[id] and id ~= playerServerId then
				logger.verbose('[main] %s is already target don\'t re-add', id)
				goto skip_loop
			end
			if not addedPlayers[id] then
				logger.verbose('[main] Adding %s as a voice target', id)
				addedPlayers[id] = true
				MumbleAddVoiceTargetPlayerByServerId(voiceTarget, id)
			end
			::skip_loop::
		end
	end
end

--- function playMicClicks
---plays the mic click if the player has them enabled.
---@param clickType boolean whether to play the 'on' or 'off' click. 
function playMicClicks(clickType)
	if micClicks ~= 'true' then return end
	sendUIMessage({
		sound = (clickType and "audio_on" or "audio_off"),
		volume = (clickType and (volumes["radio"]) or 0.05)
	})
end

--- toggles the targeted player muted
---@param source number the player to mute
function toggleMutePlayer(source)
	if mutedPlayers[source] then
		mutedPlayers[source] = nil
		MumbleSetVolumeOverrideByServerId(source, -1.0)
	else
		mutedPlayers[source] = true
		MumbleSetVolumeOverrideByServerId(source, 0.0)
	end
end
exports('toggleMutePlayer', toggleMutePlayer)

--- function setVoiceProperty
--- sets the specified voice property
---@param type string what voice property you want to change (only takes 'radioEnabled' and 'micClicks')
---@param value any the value to set the type to.
function setVoiceProperty(type, value)
	if type == "radioEnabled" then
		radioEnabled = value
		sendUIMessage({
			radioEnabled = value
		})
	elseif type == "micClicks" then
		local val = tostring(value)
		micClicks = val
		SetResourceKvp('pma-voice_enableMicClicks', val)
	end
end
exports('setVoiceProperty', setVoiceProperty)
-- compatibility
exports('SetMumbleProperty', setVoiceProperty)
exports('SetTokoProperty', setVoiceProperty)


-- cache their external servers so if it changes in runtime we can reconnect the client.
local externalAddress = ''
local externalPort = 0
CreateThread(function()
	while true do
		Wait(500)
		-- only change if what we have doesn't match the cache
		if GetConvar('voice_externalAddress', '') ~= externalAddress or GetConvarInt('voice_externalPort', 0) ~= externalPort then
			externalAddress = GetConvar('voice_externalAddress', '')
			externalPort = GetConvarInt('voice_externalPort', 0)
			MumbleSetServerAddress(GetConvar('voice_externalAddress', ''), GetConvarInt('voice_externalPort', 0))
		end
	end
end)


if gameVersion == 'redm' then
	CreateThread(function()
		while true do
			if IsControlJustPressed(0, 0xA5BDCD3C --[[ Right Bracket ]]) then
				ExecuteCommand('cycleproximity')
			end
			if IsControlJustPressed(0, 0x430593AA --[[ Left Bracket ]]) then
				ExecuteCommand('+radiotalk')
			elseif IsControlJustReleased(0, 0x430593AA --[[ Left Bracket ]]) then
				ExecuteCommand('-radiotalk')
			end

			Wait(0)
		end
	end)
end

-- PEN ADD ON SHIT MEOW

submixactive = false

Citizen.CreateThread(function()
	while true do
		Wait(1000)
		
		local player = PlayerPedId()
		local srvplayer = GetPlayerServerId(PlayerId())
		local vehicle = GetVehiclePedIsIn(player, false)
		local vehicleClass = GetVehicleClass(vehicle)
		local model = GetEntityModel(vehicle)

		local shouldbedisabled = false

		if not shouldbedisabled then
			if vehicleClass == 15 or vehicleClass == 16 then
				if not submixactive then
					if vehicleClass == 15 or vehicleClass == 16 then
						aircraftSubmix(srvplayer, 1)
					else
						aircraftSubmix(srvplayer, 0)
					end
				end
			else
				if submixactive then
					if vehicleClass == 15 or vehicleClass == 16 then
						aircraftSubmix(srvplayer, 1)
					else
						aircraftSubmix(srvplayer, 0)
					end
				end
			end
		end
	end
end)

  function aircraftSubmix(player, enabled)
	if enabled == 1 then
		--print("Enabled Submix")
		submixactive = true
		submixvoice = submix
		TriggerEvent('asrp:connectatc', true)
	else
		--print("Disabled Submix")
		submixactive = false
		submixvoice = -1
		TriggerEvent('asrp:connectatc', false)
	end
	local submix = 0
	local serverid = GetPlayerServerId(PlayerId())

	SetAudioSubmixEffectRadioFx(submix, 0)
	SetAudioSubmixEffectParamInt(submix, 0, `enabled`, enabled, GetHashKey("default"), 0)
	SetAudioSubmixEffectParamFloat(submix, 0, GetHashKey('freq_low'), 10.0)
	SetAudioSubmixEffectParamFloat(submix, 0, GetHashKey('freq_hi'), 10000.0)
	SetAudioSubmixEffectParamFloat(submix, 0, GetHashKey('rm_mod_freq'), 300.0)
	SetAudioSubmixEffectParamFloat(submix, 0, GetHashKey('rm_mix'), 0.2)
	SetAudioSubmixEffectParamFloat(submix, 0, GetHashKey('fudge'), 0.0)
	SetAudioSubmixEffectParamFloat(submix, 0, GetHashKey('o_freq_lo'), 200.0)
	SetAudioSubmixEffectParamFloat(submix, 0, GetHashKey('o_freq_hi'), 5000.0)
  end


RegisterNetEvent('pen:addsubmix')
AddEventHandler('pen:addsubmix', function(id)
	phoneEffectId = CreateAudioSubmix('Phone')
	SetAudioSubmixEffectParamFloat(phoneEffectId, 0, GetHashKey('freq_low'), 10.0)
	SetAudioSubmixEffectParamFloat(phoneEffectId, 0, GetHashKey('freq_hi'), 10000.0)
	SetAudioSubmixEffectParamFloat(phoneEffectId, 0, GetHashKey('rm_mod_freq'), 300.0)
	SetAudioSubmixEffectParamFloat(phoneEffectId, 0, GetHashKey('rm_mix'), 0.2)
	SetAudioSubmixEffectParamFloat(phoneEffectId, 0, GetHashKey('fudge'), 0.0)
	SetAudioSubmixEffectParamFloat(phoneEffectId, 0, GetHashKey('o_freq_lo'), 200.0)
	SetAudioSubmixEffectParamFloat(phoneEffectId, 0, GetHashKey('o_freq_hi'), 5000.0)
	AddAudioSubmixOutput(phoneEffectId, 1)

    MumbleSetSubmixForServerId(id, phoneEffectId)

	print('[Submix] Changing Submix For ID: ' .. id ..' | Megaphone')
end)

RegisterNetEvent('pen:removesubmix')
AddEventHandler('pen:removesubmix', function(id)
	MumbleSetSubmixForServerId(id, -1)

	print('[Submix] Changing Submix For ID: ' .. id ..' | Default')
end)


canmega = false
enabled = false
sent = false
turnoff = false

Citizen.CreateThread(function()
    while true do
        local p = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
		local vehicleClass = GetVehicleClass(vehicle)

			if (vehicleClass == 15 or vehicleClass == 18) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and enabled and not canmega then
				--print "is"
				if vehicleClass == 15 then
					enableHeliMegaphone(true)
			    elseif vehicleClass == 18 then
					enableVehMegaphone(true)
				end
				canmega = true
				sent = true
			elseif not IsPedInAnyVehicle(PlayerPedId(), true) or not (vehicleClass == 15 or vehicleClass == 18) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
				if canmega and sent then
					sent = false
					--print "not"
					canmega = false
					enableVehMegaphone(false)
					enabled = false
				end
			elseif turnoff then
				enableVehMegaphone(false)
				canmega = false
				enabled = false
				turnoff = false
			end
        Citizen.Wait(0)
    end
end)


megaphone = false


function enableMegaphone()
	local srcsrv = GetPlayerServerId(PlayerId())
	if not megaphone then
        megaphone = true
        --SetPlayerFilter(pServerId, 'megaphone')
		TriggerServerEvent('pen:addsubmixsrv', srcsrv)
		setProximity(75.0)
        exports['mythicnotify']:DoHudText('inform', 'Megaphone Enabled')
        megaphoneAction('enabled')
		MumbleSetAudioInputIntent(`music`)
    elseif megaphone then
        megaphone = false
        --SetPlayerFilter(pServerId, 'default')
        TriggerServerEvent('pen:removesubmixsrv', srcsrv)
		setProximity(3.0)
        exports['mythicnotify']:DoHudText('inform', 'Megaphone Disabled')
        megaphoneAction('disabled')
		MumbleSetAudioInputIntent(`speech`)
    end
end



RegisterCommand('+vehmega', function()

	local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	local vehicleClass = GetVehicleClass(vehicle)

	if (vehicleClass == 15 or vehicleClass == 18) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not enabled then
		enabled = true
	elseif (vehicleClass == 15 or vehicleClass == 18) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
		enabled = false
		turnoff = true
	end
end)
if gameVersion == 'fivem' then
	RegisterKeyMapping('+vehmega', '(Voice) Vehicle Megaphone', 'keyboard', 'F12')
end

function enableVehMegaphone(status)
	local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	local vehicleClass = GetVehicleClass(vehicle)
	local srcsrv = GetPlayerServerId(PlayerId())
	if status then
		TriggerServerEvent('pen:addsubmixsrv', srcsrv)
		setProximity(30.0)
		exports['mythicnotify']:DoHudText('inform', 'Vehicle Megaphone Enabled')
		MumbleSetAudioInputIntent(`music`)
	else
		TriggerServerEvent('pen:removesubmixsrv', srcsrv)
		exports['mythicnotify']:DoHudText('inform', 'Vehicle Megaphone Disabled')
		setProximity(3.0)
		MumbleSetAudioInputIntent(`speech`)
	end
end

function enableHeliMegaphone(status)
	local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	local vehicleClass = GetVehicleClass(vehicle)
	local srcsrv = GetPlayerServerId(PlayerId())
	if status then
		TriggerServerEvent('pen:addsubmixsrv', srcsrv)
		setProximity(95.0)
		exports['mythicnotify']:DoHudText('inform', 'Vehicle Megaphone Enabled')
		MumbleSetAudioInputIntent(`music`)
	else
		TriggerServerEvent('pen:removesubmixsrv', srcsrv)
		exports['mythicnotify']:DoHudText('inform', 'Vehicle Megaphone Disabled')
		setProximity(3.0)
		MumbleSetAudioInputIntent(`speech`)
	end
end

function megaphoneAction(status)
    if status == 'enabled' then
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped)
        local animDictionary = "amb@world_human_mobile_film_shocking@female@base"
        local animName = "base"
        loadAnimDict(animDictionary)
        attachItem("megaphone")
        if not IsEntityPlayingAnim(ped, animDictionary, animName, 3) then
            TaskPlayAnim(ped, animDictionary, animName, 1.0, 1.0, GetAnimDuration(animDictionary, animName), 49, 0, 0, 0, 0)
        end
    elseif status == 'disabled' then
        local animDictionary = "amb@world_human_mobile_film_shocking@female@base"
        local animName = "base"
        local ped = PlayerPedId()
        StopAnimTask(ped, animDictionary, animName, 3.0)
        removeAttachedProp()
    end
end



function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end 



attachPropList = {

    ["megaphone"] = {
        ["model"] = "prop_megaphone_01",
        ["bone"] = 28422,
        ["x"] = 0.04,
        ["y"] = -0.01,
        ["z"] = 0.0,
        ["xR"] = 22.0,
        ["yR"] = -4.0,
        ["zR"] = 87.0,
        ["vertexIndex"] = 0
      }
}

attachedProp = 0
function removeAttachedProp()
	if DoesEntityExist(attachedProp) then
		DeleteEntity(attachedProp)
		attachedProp = 0
	end
end

function attachItem(item)
	attachProp(attachPropList[item]["model"], attachPropList[item]["bone"], attachPropList[item]["x"], attachPropList[item]["y"], attachPropList[item]["z"], attachPropList[item]["xR"], attachPropList[item]["yR"], attachPropList[item]["zR"], attachPropList[item]["vertexIndex"], attachPropList[item]["disableCollision"])
end

function attachProp(attachModelSent,boneNumberSent,x,y,z,xR,yR,zR, pVertexIndex, disableCollision)
    removeAttachedProp()
	attachModel = GetHashKey(attachModelSent)
	boneNumber = boneNumberSent
	SetCurrentPedWeapon(PlayerPedId(), 0xA2719263)
	local bone = GetPedBoneIndex(PlayerPedId(), boneNumberSent)
	--local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(), true))
	RequestModel(attachModel)
	while not HasModelLoaded(attachModel) do
		Citizen.Wait(100)
	end
	attachedProp = CreateObject(attachModel, 1.0, 1.0, 1.0, 1, 1, 0)
	if disableCollision then
		SetEntityCollision(attachedProp, false, false)
	end
	SetModelAsNoLongerNeeded(attachModel)
	AttachEntityToEntity(attachedProp, PlayerPedId(), bone, x, y, z, xR, yR, zR, 1, 1, 0, 0, pVertexIndex and pVertexIndex or 2, 1)
end

function setProximity(distanceNum)
	MumbleSetTalkerProximity(distanceNum + 0.0)
	LocalPlayer.state:set('proximity', {
	distance = distanceNum,
	}, true)

	print('[Proximity] Changed To ' .. distanceNum .. '')
end

-- Poly Test Stuff Occlusion

Citizen.CreateThread(function()

	local coords = vector3(440.6988, -985.8110, 34.9703)
	local length = 2.0
	local width = 4.0
	local heading = 90.0
	local minZ = 33.0
	local maxZ = 37.0

	for location, data in pairs(Config.Locations) do
		for i, spot in ipairs(data.zones) do
			local newSpot = BoxZone:Create(spot.coords, spot.length, spot.width, {
				name = 'Microphone',
				debugPoly = spot.debug,
				heading = spot.heading,
				minZ = spot.minZ,
				maxZ = spot.maxZ,
			})
			--print('Creating Zone')
			newSpot:onPlayerInOut(function(isPointInside, _)

				local srcsrv = GetPlayerServerId(PlayerId())
				
				if isPointInside then
					setProximity(tonumber(spot.audioDistance))
					if spot.enableSubmix then
						TriggerServerEvent('pen:addsubmixsrv', srcsrv)
					end
					exports['mythicnotify']:DoHudText('inform', 'Stage Megaphone Enabled')
					MumbleSetAudioInputIntent(`music`)
				else
					setProximity(3.0)
					MumbleSetAudioInputIntent(`speech`)
					if spot.enableSubmix then
						TriggerServerEvent('pen:removesubmixsrv', srcsrv)
					end
					exports['mythicnotify']:DoHudText('inform', 'Stage Megaphone Disabled')
				end
			end)
		end
	end
end)

local models = { `v_club_roc_micstd`, `prop_table_mic_01` }

Citizen.CreateThread(function()
	local options = {
		{
			name = 'ox:option9',
			icon = 'fa-solid fa-microphone',
			label = 'Use Microphone',
			distance = 1,
			onSelect = function(data)
				--print('mic')
				createMicPoly(GetEntityModel(data.entity))
			end
		}
	}
	exports.ox_target:addModel(models, options)
end)

function createMicPoly(model)
	local c = GetEntityCoords(PlayerPedId())
	local id = GetClosestObjectOfType(c.x, c.y, c.z, 20.0, model, false, false, false)
	local coords = GetEntityCoords(id)
	local newcoords = vector3(coords.x, coords.y, coords.z)
	--print(newcoords)
	local micZone = BoxZone:Create(newcoords, 2, 1, {
		name = 'Microphone',
		debugPoly = false,
		heading = GetEntityHeading(PlayerPedId()),
		minZ = coords.z-2,
		maxZ = coords.z+2,
	})

	micZone:onPlayerInOut(function(isPointInside, _)

		local srcsrv = GetPlayerServerId(PlayerId())
		
		if isPointInside then
			setProximity(tonumber(100.0))
			TriggerServerEvent('pen:addsubmixsrv', srcsrv)
			exports['mythicnotify']:DoHudText('inform', 'Stage Megaphone Enabled')
			MumbleSetAudioInputIntent(`music`)
		else
			setProximity(3.0)
			TriggerServerEvent('pen:removesubmixsrv', srcsrv)
			MumbleSetAudioInputIntent(`speech`)
			exports['mythicnotify']:DoHudText('inform', 'Stage Megaphone Disabled')
			micZone:destroy()
		end
	end)
end

RegisterCommand('pma-voice:spawnMicrophone', function()
    local model, modelHash = 'v_club_roc_micstd', GetHashKey('v_club_roc_micstd')
    if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
        RequestModel(modelHash)

        while not HasModelLoaded(modelHash) do
            Citizen.Wait(1)
        end
    end
    local playerPed = PlayerPedId()
    local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
    local objectCoords = (coords + forward * 1.0)
    local obj = CreateObject(model, objectCoords, true, false, true)
    SetModelAsNoLongerNeeded(model)
    SetEntityHeading(obj, 54.91)
    PlaceObjectOnGroundProperly(obj)
	FreezeEntityPosition(obj, true)
end)

if exports["pen-core"]:isInventoryDisabled() then
	RegisterCommand('megaphone', function()
		enableMegaphone()
	end)
elseif not exports["pen-core"]:isInventoryDisabled() then
	exports('megaphone', function(data, slot)
		exports.ox_inventory:useItem(data, function(data)
			enableMegaphone()
		end)
	end)
end