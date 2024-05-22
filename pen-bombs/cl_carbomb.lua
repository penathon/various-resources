local defaultTime = nil
local bombInitiated = false
local wasBomb = false
local totalTime = nil
local MinSpeed = nil
local bombInitiatedSpeed = false

function countdown()
    --PlaySoundFrontend(-1, "5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 1)
    local p = PlayerPedId()
    local v = GetVehiclePedIsIn(PlayerPedId(), true)

    local c = GetEntityCoords(v)
    --PlaySoundFromCoord(-1, 'Beep_Red', c.x, c.y, c.z, 'DLC_HEIST_HACKING_SNAKE_SOUNDS', true, 10, true)
    PlaySoundFromEntity(-1, 'Beep_Red', v, 'DLC_HEIST_HACKING_SNAKE_SOUNDS', true, 10)
end

function startBombTimer()
    bombInitiated = true
    wasBomb = true
end

function getVehicleSpeed(pEntity)
    return GetEntitySpeed(pEntity) * 2.236936
end

function resetBombState()
    wasBomb = false
    bombInitiated = false
    bombInitiatedSpeed = false
    totalTime = nil
    defaultTime = nil
end

--[[RegisterCommand('bombtest', function(source, args)
    local time = '900'
    local speedThing = '10'
    defaultTime = tonumber(time)
    totalTime = tonumber(time)
    if speedThing ~= nil then
        MinSpeed = speedThing
        bombInitiatedSpeed = true
        TriggerEvent('showmythic', 'Keep your vehicle above ' .. MinSpeed .. 'MPH!')
    end
    startBombTimer()
end)

RegisterCommand('stopbomb', function()
    bombInitiated = false
    wasBomb = true
end)]]--

RegisterNetEvent('pen-bombs:stopClientSpeedBomb')
AddEventHandler('pen-bombs:stopClientSpeedBomb', function()
    bombInitiated = false
    wasBomb = true
    resetBombState()
end)

RegisterNetEvent('pen-bombs:clientSpeedBomb')
AddEventHandler('pen-bombs:clientSpeedBomb', function(timeserver, speedserver)
    local time = timeserver
    local speedThing = speedserver
    defaultTime = tonumber(time)
    totalTime = tonumber(time)
    if speedThing ~= nil then
        MinSpeed = speedThing
        bombInitiatedSpeed = true
        TriggerEvent('showmythic', 'Keep your vehicle above ' .. MinSpeed .. 'MPH!')
    end
    startBombTimer()
end)

-- Timer Thread

Citizen.CreateThread(function()
	while true do
		Wait(1000)
		if bombInitiated then
			if defaultTime > 0 then
				defaultTime = defaultTime - 1
                countdown()
			else
                if bombInitiatedSpeed then
                    local p = PlayerPedId()
                    local v = GetVehiclePedIsIn(PlayerPedId(), true)
                    local c = GetEntityCoords(v)
                    --PlaySoundFromCoord(-1, "Hack_Success", c.x, c.y, c.z, "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true, 10, true)
                    PlaySoundFromEntity(-1, 'Hack_Success', v, 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS', true, 10)
                    resetBombState()
                else
                    local p = GetVehiclePedIsIn(PlayerPedId(), true)
                    local c = GetEntityCoords(p)
                    resetBombState()
                    AddExplosion(c.x, c.y, c.z, 29, 30.0, true, false, true)
                end
			end
            --print(defaultTime)
        else
            if wasBomb then
                local p = PlayerPedId()
                local v = GetVehiclePedIsIn(PlayerPedId(), true)
                local c = GetEntityCoords(v)
                --PlaySoundFromCoord(-1, "Hack_Success", c.x, c.y, c.z, "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true, 10, true)
                PlaySoundFromEntity(-1, 'Hack_Success', v, 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS', true, 10)
                resetBombState()
            end
        end
	end
end)


Citizen.CreateThread(function()
    while true do
        Wait(100)
        if bombInitiated then
            --if defaultTime == math.ceil(totalTime / 2) then
                if bombInitiatedSpeed then
                    --print('here')
                    local p = GetVehiclePedIsIn(PlayerPedId(), true)
                    local c = GetEntityCoords(p)
                    local speed = math.ceil(getVehicleSpeed(p))
                    --print(speed)
                    if speed < tonumber(MinSpeed) then
                        local p = GetVehiclePedIsIn(PlayerPedId(), true)
                        local c = GetEntityCoords(p)
                        AddExplosion(c.x, c.y, c.z, 29, 30.0, true, false, true)
                        resetBombState()
                    end
                end
            --end
        end
    end
end)