voiceData = {}
radioData = {}
callData = {}

function defaultTable(source)
	handleStateBagInitilization(source)
	return {
		radio = 0,
		call = 0,
		lastRadio = 0,
		lastCall = 0
	}
end

function handleStateBagInitilization(source)
	local plyState = Player(source).state
	if not plyState.pmaVoiceInit then 
		plyState:set('radio', tonumber(GetConvar('voice_defaultRadioVolume', '0.3')), true)
		plyState:set('phone', tonumber(GetConvar('voice_defaultPhoneVolume', '0.6')), true)
		plyState:set('proximity', {}, true)
		plyState:set('callChannel', 0, true)
		plyState:set('radioChannel', 0, true)
		plyState:set('voiceIntent', 'speech', true)
		-- We want to save voice inits because we'll automatically reinitalize calls and channels
		plyState:set('pmaVoiceInit', true, false)
	end
end

-- temp fix before an actual fix is added
Citizen.CreateThreadNow(function()

	local plyTbl = GetPlayers()
	for i = 1, #plyTbl do
		local ply = tonumber(plyTbl[i])
		voiceData[ply] = defaultTable(plyTbl[i])
	end

	Wait(5000)

	local nativeAudio = GetConvar('voice_useNativeAudio', 'false')
	local _3dAudio = GetConvar('voice_use3dAudio', 'false')
	local _2dAudio = GetConvar('voice_use2dAudio', 'false')
	local sendingRangeOnly = GetConvar('voice_useSendingRangeOnly', 'false')
	local gameVersion = GetConvar('gamename', 'fivem')

	-- handle no convars being set (default drag n' drop)
	if
		nativeAudio == 'false'
		and _3dAudio == 'false'
		and _2dAudio == 'false'
	then
		if gameVersion == 'fivem' then
			SetConvarReplicated('voice_useNativeAudio', 'true')
			if sendingRangeOnly == 'false' then
				SetConvarReplicated('voice_useSendingRangeOnly', 'true')
			end
			logger.info('No convars detected for voice mode, defaulting to \'setr voice_useNativeAudio true\' and \'setr voice_useSendingRangeOnly true\'')
		else
			SetConvarReplicated('voice_use3dAudio', 'true')
			if sendingRangeOnly == 'false' then
				SetConvarReplicated('voice_useSendingRangeOnly', 'true')
			end
			logger.info('No convars detected for voice mode, defaulting to \'setr voice_use3dAudio true\' and \'setr voice_useSendingRangeOnly true\'')
		end
	elseif sendingRangeOnly == 'false' then
		logger.warn('It\'s recommended to have \'voice_useSendingRangeOnly\' set to true you can do that with \'setr voice_useSendingRangeOnly true\', this prevents players who directly join the mumble server from broadcasting to players.')
	end

	if GetConvar('gamename', 'fivem') == 'rdr3' then
		if nativeAudio == 'true' then
			logger.warn("RedM doesn't currently support native audio, automatically switching to 3d audio. This also means that submixes will not work.")
			SetConvarReplicated('voice_useNativeAudio', 'false')
			SetConvarReplicated('voice_use3dAudio', 'true')
		end
	end
end)

AddEventHandler('playerJoining', function()
	if not voiceData[source] then
		voiceData[source] = defaultTable(source)
	end
end)

AddEventHandler("playerDropped", function()
	local source = source
	if voiceData[source] then
		local plyData = voiceData[source]

		if plyData.radio ~= 0 then
			removePlayerFromRadio(source, plyData.radio)
		end

		if plyData.call ~= 0 then
			removePlayerFromCall(source, plyData.call)
		end

		voiceData[source] = nil
	end
end)

if GetConvarInt('voice_externalDisallowJoin', 0) == 1 then
	AddEventHandler('playerConnecting', function(_, _, deferral)
		deferral.defer()
		Wait(0)
		deferral.done('This server is not accepting connections.')
	end)
end

-- only meant for internal use so no documentation
function isValidPlayer(source)
	return voiceData[source]
end
exports('isValidPlayer', isValidPlayer)

function getPlayersInRadioChannel(channel)
	local returnChannel = radioData[channel]
	if returnChannel then
		return returnChannel
	end
	-- channel doesnt exist
	return {}
end
exports('getPlayersInRadioChannel', getPlayersInRadioChannel)
exports('GetPlayersInRadioChannel', getPlayersInRadioChannel)

RegisterNetEvent('pen:addsubmixsrv')
AddEventHandler('pen:addsubmixsrv', function(source)
	TriggerClientEvent('pen:addsubmix', -1, source)
end)

RegisterNetEvent('pen:removesubmixsrv')
AddEventHandler('pen:removesubmixsrv', function(source)
	TriggerClientEvent('pen:removesubmix', -1, source)
end)

--[[local activeDispatchers = {}

RegisterCommand('911on', function(source)
	local _source = source
	local phonenumber = exports.npwd:getPhoneNumber(_source)

	table.insert(activeDispatchers, {
		number = phonenumber,
		id = _source
	})

	print(json.encode(activeDispatchers, {indent=true}))
end)

exports.npwd:onCall("911", function(ctx)

	local localphonenumber = exports.npwd:getPhoneNumber(source)

	for _, phone in pairs(activeDispatchers) do
		if phone.number ~= localphonenumber then
        	ctx.forward(phone.number)
		end
    end
end)]]--