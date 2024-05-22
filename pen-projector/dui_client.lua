local defaultDuiUrl = 'https://media.tenor.com/NQfq1liFH-8AAAAd/byuntear-sad.gif'
local dui = nil
local duiCounter = 0
local availableDuis = {}
local duis = {}
local activeDui = defaultDuiUrl

Config = Config or {}

Config.Locations = {
	['MRPD'] = {
        zones = {
            { 
			coords = vector3(443.2839, -985.6326, 34.9702),
			length = 20.0, 
			width = 15.0, 
			debug = false,
			heading = 270.0, 
			minZ = 33.0, 
			maxZ = 50.0,
			}
        }
    }
}

function getDui(url, width, height)
    width = width or 512
    height = height or 512

    local duiSize = tostring(width) .. 'x' .. tostring(height)

    -- Check if dui with size exists
    if (availableDuis[duiSize] and #availableDuis[duiSize] > 0) then
        local n,t = pairs(availableDuis[duiSize])
        local nextKey, nextValue = n(t)
        local id = nextValue
        local dictionary = duis[id].textureDictName
        local texture = duis[id].textureName

        -- clear
        nextValue = nil
        table.remove(availableDuis[duiSize], nextKey)

        SetDuiUrl(duis[id].duiObject, url)

        return {id = id, dictionary = dictionary, texture = texture}
    end

    -- Generate a new one.
    duiCounter = duiCounter + 1
    local generatedDictName = duiSize..'-dict-'..tostring(duiCounter)
    local generatedTxtName = duiSize..'-txt-'..tostring(duiCounter)
    local duiObject = CreateDui(url, width, height)
    local dictObject = CreateRuntimeTxd(generatedDictName)
    local duiHandle = GetDuiHandle(duiObject)
    local txdObject = CreateRuntimeTextureFromDuiHandle(dictObject, generatedTxtName, duiHandle)

    duis[duiCounter] = {
        duiSize = duiSize,
        duiObject = duiObject,
        duiHandle = duiHandle,
        dictionaryObject = dictObject,
        textureObject = txdObject,
        textureDictName = generatedDictName,
        textureName = generatedTxtName
    }

    return {id = duiCounter, dictionary = generatedDictName, texture = generatedTxtName}
end

function changeDuiUrl(id, url)
    if (not duis[id]) then
        return
    end

    local settings = duis[id]
    SetDuiUrl(settings.duiObject, url)
end

function releaseDui(id)
    if (not duis[id]) then
        return
    end

    local settings = duis[id]
    local duiSize = settings.duiSize

    SetDuiUrl(settings.duiObject, 'about:blank')
    if not availableDuis[duiSize] then
      availableDuis[duiSize] = {}
    end 
    table.insert(availableDuis[duiSize], id)
end

local inZone = false

Citizen.CreateThread(function()
	for location, data in pairs(Config.Locations) do
		for i, spot in ipairs(data.zones) do
			local newSpot = BoxZone:Create(spot.coords, spot.length, spot.width, {
				name = 'DUI Zone',
				debugPoly = spot.debug,
				heading = spot.heading,
				minZ = spot.minZ,
				maxZ = spot.maxZ,
			})
			--print('creating zone')
			newSpot:onPlayerInOut(function(isPointInside, _)
				
				if isPointInside then
                    inZone = true
                    updateCurrentDui()
                else
                    inZone = false
                    updateCurrentDui()
				end
			end)
		end
	end
    TargetStuff()
end)


AddEventHandler("playerSpawned", function(spawn)
    TriggerServerEvent('pen-police:InitialduiRecieve', GetPlayerServerId(PlayerId()))
end)



RegisterNetEvent('pen-police:duiChange')
AddEventHandler('pen-police:duiChange', function(data)
    if data ~= nil then
        activeDui = data
        if inZone then
            updateCurrentDui()
        end
    end
    --print(json.encode(dui, {indent=true}))
end)

RegisterNetEvent('pen-police:InitialduiChange')
AddEventHandler('pen-police:InitialduiChange', function(data)
    if data ~= nil then
        activeDui = data
    end
    --updateCurrentDui()
end)

RegisterNetEvent('pen-police:updateDui')
AddEventHandler('pen-police:updateDui', function(data)

end)

function updateCurrentDui()
    if inZone then
        if not dui then
            dui = getDui(activeDui)
            --releaseDui(duiOld)
            AddReplaceTexture('prop_planning_b1', 'prop_base_white_01b', dui.dictionary, dui.texture)
            print('[DUI] in area and updating - ' .. activeDui)
        else
            print('[DUI] changing dui url because inside')
            changeDuiUrl(dui.id, activeDui)
        end
    else
        if not dui then
            dui = getDui(defaultDuiUrl)
            AddReplaceTexture('prop_planning_b1', 'prop_base_white_01b', dui.dictionary, dui.texture)
            print('[DUI] out of area but updating - ' .. defaultDuiUrl)
        else
            print('[DUI] changing dui url when outside to default')
            changeDuiUrl(dui.id, defaultDuiUrl)
        end
    end
end

function TargetStuff()
    exports.ox_target:addSphereZone({
        coords = vec3(439.3547, -985.9203, 35.6002),
        radius = 0.2,
        debug = false,
        options = {
            {
                name = 'url',
                --event = 'pen-jail:LockdownTrigger',
                icon = '',
                label = 'Change URL',
                distance = 2,
                onSelect = function(data)
                    openInput()
                end,
                canInteract = function(entity, coords, distance)
                    return true
                end
            }
        }
    })
end

function getDistance()
    local c2 = vector3(439.3547, -985.9203, 35.6002)
    local c = GetEntityCoords(PlayerPedId())
	local dist = #(c - c2)
	if dist < 20 then
        return true
    else
        return false
	end
end

function openInput()
    local input = lib.inputDialog('Change URL', {'URL'})
    if not input then return end
    local image = input[1]
    if image ~= nil then
        TriggerServerEvent('pen-police:duiSave', image)
    end
end

--[[function updateCurrentDuiEvent()
    TriggerServerEvent('pen-police:duiRecieve')
    if getDistance() then
        dui = getDui(activeDui)
        AddReplaceTexture('prop_planning_b1', 'prop_base_white_01b', dui.dictionary, dui.texture)
        print('in area and updating')
    end
end]]--

exports('getDui', getDui)
exports('changeDuiUrl', changeDuiUrl)
exports('releaseDui', releaseDui)
