local dashcamActive = false
local bodycamActive = false
local cctvactive = false

local attached = nil
local clockedin = false
local done = false
local activeLeo

local DashcamMenuUnits = {}
local BodycamMenuUnits = {}
local CCTVMenu = {}

local cameraHandle = nil
local attachedVehicle = nil
local attachedPlayer = nil
local cameraReverse = false
local disable = false
local alteredRotation


-- LOOPS

--[[Citizen.CreateThread(function()
    while true do
        Citizen.Wait(7500) -- every 2.5 secs for less lag and shit
        local state = LocalPlayer.state.clockin
        clockedin = state.isLeo
        -- registering active leo from server
        lib.callback('pen-dashcam:getActiveLEO', false, function(count)
            activeLeo = count
        end)
    end
end)]]--

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- every 2.5 secs for less lag and shit
        if disable then
            disableShit(true)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if dashcamActive then
            if DoesEntityExist(attachedVehicle) then
                if IsControlJustPressed(1, 38) then
                    DisableDash()
                end
            else
                DisableDash()
            end
        end

        if bodycamActive then
            if DoesEntityExist(attachedPlayer) and not IsEntityDead(attachedPlayer) then
                if IsControlJustPressed(1, 38) then
                    DisableBody()
                end
            else
                DisableBody()
            end
        end

        if cctvactive then
            if IsControlJustPressed(1, 38) then
                DisableCCTV()
            end
        end


        if dashcamActive and not cameraReverse then
            local bonPos = GetWorldPositionOfEntityBone(attachedVehicle, GetEntityBoneIndexByName(attachedVehicle, "windscreen"))
            local vehRot = GetEntityRotation(attachedVehicle, 0)
            SetCamCoord(cameraHandle, bonPos.x, bonPos.y, bonPos.z)
            SetCamRot(cameraHandle, vehRot.x, vehRot.y, vehRot.z, 0)
            --print(bonPos)
            SetCamFov(cameraHandle, 70.0)
            --print('attaching')
        elseif dashcamActive and cameraReverse then
            local bonPos = GetWorldPositionOfEntityBone(attachedVehicle, GetEntityBoneIndexByName(attachedVehicle, "windscreen"))
            local vehRot = GetEntityRotation(attachedVehicle, 0)
            SetCamCoord(cameraHandle, bonPos.x, bonPos.y, bonPos.z)
            SetCamRot(cameraHandle, vehRot.x, vehRot.y, vehRot.z+180, 0)
            SetCamFov(cameraHandle, 85.0)
            --print('reverse')
        end

        if bodycamActive and not dashcamActive then
            local bonPos = GetWorldPositionOfEntityBone(attachedPlayer, GetPedBoneIndex(attachedPlayer, 31086))
            local vehRot = GetEntityRotation(attachedPlayer, 0)
            SetCamCoord(cameraHandle, bonPos.x, bonPos.y, bonPos.z)
            SetCamRot(cameraHandle, vehRot.x, vehRot.y, vehRot.z, 0)
            SetCamFov(cameraHandle, 70.0)
        end

        if cctvactive and not dashcamActive and not bodycamActive then
            local rotation = GetCamRot(cameraHandle, 2)
            local fov = GetCamFov(cameraHandle, 2)

            if IsDisabledControlPressed(1, 108) then -- Num 4 (Rotate Left)
                SetCamRot(cameraHandle, rotation.x, 0.0, rotation.z + 0.3, 2)
            --end
            end

            if IsDisabledControlPressed(1, 107) then -- Num 6 (Rotate Right)
                SetCamRot(cameraHandle, rotation.x, 0.0, rotation.z - 0.3, 2)
            end

            if IsDisabledControlPressed(1, 111) then -- Num 8 (Up)
                if rotation.x <= 0.0 then
                    SetCamRot(cameraHandle, rotation.x + 0.3, 0.0, rotation.z, 2)
                end
            end

            if IsDisabledControlPressed(1, 110) then -- Num 5 (Down)
                if rotation.x <= 50.0 and rotation.x >= -88.0 then
                    SetCamRot(cameraHandle, rotation.x - 0.3, 0.0, rotation.z, 2)
                end
            end

            if IsDisabledControlPressed(1, 118) then -- Num 9 (Zoom)
                SetCamFov(cameraHandle, fov-0.1)
            end
            if IsDisabledControlPressed(1, 117) then -- Num 7 (UnZoom)
                SetCamFov(cameraHandle, fov+0.1)
            end
            --print(rotation)
        end
        Citizen.Wait(0)
    end
end)

-- FUNCTIONS

function GetStreetAndZone(ped)
    local plyPos = GetEntityCoords(ped,  true)
    local s1, s2 = Citizen.InvokeNative( 0x2EB41072B4C1E4C0, plyPos.x, plyPos.y, plyPos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)
    zone = tostring(GetNameOfZone(plyPos.x, plyPos.y, plyPos.z))
    local playerStreetsLocation = GetLabelText(zone)
    local street = street1 .. ", " .. playerStreetsLocation
    return street
end

function GetStreetAndZoneCoords(coords)
    local plyPos = coords
    local s1, s2 = Citizen.InvokeNative( 0x2EB41072B4C1E4C0, plyPos.x, plyPos.y, plyPos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)
    zone = tostring(GetNameOfZone(plyPos.x, plyPos.y, plyPos.z))
    local playerStreetsLocation = GetLabelText(zone)
    local street = street1 .. ", " .. playerStreetsLocation
    return street
end

function serverIdCheck(id)
    local p = GetPlayerServerId(PlayerId())
    if id == p then
        return true
    else
        return false
    end
end


function registerMenu()
    for _, data in ipairs(activeLeo) do
        local ifOwnServerId = serverIdCheck(tonumber(data.serverid))
        local ped = GetPlayerFromServerId(tonumber(data.serverid))
        --local pedVehicle = GetVehiclePedIsIn(GetPlayerPed(ped), true)
        --local playerPed = GetPlayerPed(ped)
        local playerPed = NetToPed(data.pedNetId)  
        local pedVehicle = GetVehiclePedIsIn(NetToPed(data.pedNetId), true)      

        --if not ifOwnServerId then
            if pedVehicle ~= 0 then
                local vehData = getVehicleData(pedVehicle)
                local speed = getSpeed(pedVehicle)
                local street = GetStreetAndZone(pedVehicle)
                local vehType = GetDisplayNameFromVehicleModel(GetEntityModel(pedVehicle))
                local postal = exports["pen-nearestpostal"]:getPostalPed(pedVehicle)
                table.insert(DashcamMenuUnits, {
                    title = 'Officer: ' .. data.name .. ' - Available', 
                    description = 'Location: ' .. street .. '',
                    onSelect = function(args)
                        if not dashcamActive then
                            EnableDash(pedVehicle)
                        else
                            DisableDash(pedVehicle)
                        end
                        DashcamMenuUnits = {}
                        BodycamMenuUnits = {}
                        CCTVMenu = {}
                    end,
                    metadata = {
                        {label = 'Speed', value = '' .. speed .. 'MPH'},
                        {label = 'Plate', value = vehData.plate},
                        {label = 'Vehicle', value = vehType},
                        {label = 'Postal', value = postal},
                    } 
                })
            else
                table.insert(DashcamMenuUnits, {
                    title = 'Officer: ' .. data.name .. ' - Unavailable', 
                    description = 'Unit: ' .. data.serverid ..''
                })
            end

            -- BODYCAM
            --print(playerPed, data.name)
            local ownPed = PlayerPedId()
            if ownPed ~= playerPed then
                if playerPed ~= 0 and not IsEntityDead(playerPed) then
                        local street = GetStreetAndZone(playerPed)
                        local postal = exports["pen-nearestpostal"]:getPostalPed(playerPed)
                        table.insert(BodycamMenuUnits, {
                            title = 'Officer: ' .. data.name .. ' - Available', 
                            description = 'Location: ' .. street .. '',
                            onSelect = function(args)
                                if not bodycamActive then
                                    EnableBody(playerPed)
                                else
                                    DisableBody(playerPed)
                                end
                                BodycamMenuUnits = {}
                                DashcamMenuUnits = {}
                                CCTVMenu = {}
                            end,
                            metadata = {
                                {label = 'Postal', value = postal},
                            } 
                        })
                else
                    table.insert(BodycamMenuUnits, {
                        title = 'Officer: ' .. data.name .. ' - Unresponsive', 
                        description = 'Unit: ' .. data.serverid ..''
                    })
                end
            else
                table.insert(BodycamMenuUnits, {
                    title = 'Officer: ' .. data.name .. ' - Unresponsive', 
                    description = 'Unit: ' .. data.serverid ..''
                })
            end
        --end
    end

    -- CCTV

    for k, v in ipairs(Config.CCTV) do
        local street = GetStreetAndZoneCoords(v.coords)
        local postal = exports["pen-nearestpostal"]:GetNearestPostal(v.coords)
        table.insert(CCTVMenu, {
            title = v.name, 
            description = 'Location: ' .. street .. ' - Postal: ' .. postal ..'',
            onSelect = function(args)
                if not dashcamActive then
                    EnableCCTV(v.coords, v.rotation)
                else
                    DisableCCTV(v.coords)
                end
                DashcamMenuUnits = {}
                BodycamMenuUnits = {}
                CCTVMenu = {}
            end
        })
    end

    lib.registerContext({
        id = 'cam_menu',
        title = 'Available Cams',
        onExit = function()
            DashcamMenuUnits = {}
            BodycamMenuUnits = {}
            CCTVMenu = {}
            SetTablet(false)
            changeCulling(false)
            --print('[Dashcam] Cleared Options')
        end,
        options =  {
            {
                title = 'Dashcams',
                description = 'View all available vehicle dashcams',
                arrow = true,
                menu = 'dashcam',
            },
            {
                title = 'Bodycams',
                description = 'View all available bodycams',
                arrow = true,
                menu = 'bodycam',
            },
            {
                title = 'CCTV Cameras',
                description = 'View all available CCTV',
                arrow = true,
                menu = 'cctv',
            },
        },
        {
            id = 'dashcam',
            title = 'Dashcams',
            onExit = function()
                DashcamMenuUnits = {}
                BodycamMenuUnits = {}
                CCTVMenu = {}
                SetTablet(false)
                changeCulling(false)
                print('[Dashcam] Cleared Options')
            end,
            menu = 'cam_menu',
            options = DashcamMenuUnits
        },
        {
            id = 'bodycam',
            title = 'Bodycams',
            onExit = function()
                DashcamMenuUnits = {}
                BodycamMenuUnits = {}
                CCTVMenu = {}
                SetTablet(false)
                changeCulling(false)
                print('[Dashcam] Cleared Options')
            end,
            menu = 'cam_menu',
            options = BodycamMenuUnits
        },
        {
            id = 'cctv',
            title = 'CCTV',
            onExit = function()
                DashcamMenuUnits = {}
                BodycamMenuUnits = {}
                CCTVMenu = {}
                SetTablet(false)
                changeCulling(false)
                print('[Dashcam] Cleared Options')
            end,
            menu = 'cam_menu',
            options = CCTVMenu
        }
    })

    --[[lib.registerContext({
        id = 'main_menu2',
        title = 'Dashcams',
        onExit = function()
            DashcamMenuUnits = {}
            BodycamMenuUnits = {}
            print('[Dashcam] Cleared Options')
        end,
        options = DashcamMenuUnits
    })]]--
    print('[Dashcam] Dashcam Menu Registered')
end

function getSpeed(vehicle)
    local currSpeed = GetEntitySpeed(vehicle)
    local speed = currSpeed*2.23694

    local finalspeed = math.ceil(speed)

    return finalspeed
end

function getVehicleData(vehicle)
    local data = lib.getVehicleProperties(vehicle)

    return data
end

function round(number, decimals)
    local power = 10^decimals
    return math.floor(number * power) / power
end

-- Dashcam

function EnableDash(vehicle)
    voiceThing(GetEntityCoords(vehicle))
    dashcamActive = not dashcamActive
    attachedVehicle = vehicle
    SetTimecycleModifier("scanline_cam_cheap")
    SetTimecycleModifierStrength(1.2)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    RenderScriptCams(1, 0, 0, 1, 1)
    SetFocusEntity(vehicle)
    cameraHandle = cam
    disable = not disable
    FreezeEntityPosition(PlayerPedId(), true)
    showInfo()
end

function DisableDash()
    voiceThingRemove(GetEntityCoords(attachedVehicle))
    dashcamActive = not dashcamActive
    ClearTimecycleModifier("scanline_cam_cheap")
    RenderScriptCams(0, 0, 1, 1, 1)
    DestroyCam(cameraHandle, false)
    SetFocusEntity(GetPlayerPed(PlayerId()))
    attachedVehicle = nil
    cameraReverse = false
    disable = not disable
    disableShit(false)
    FreezeEntityPosition(PlayerPedId(), false)
    SetTablet(false)
    changeCulling(false)
end

-- Bodycam

function EnableBody(ped)
    voiceThing(GetEntityCoords(ped))
    bodycamActive = not bodycamActive
    attachedPlayer = ped
    SetTimecycleModifier("scanline_cam_cheap")
    SetTimecycleModifierStrength(1.2)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    RenderScriptCams(1, 0, 0, 1, 1)
    SetFocusEntity(ped)
    cameraHandle = cam
    disable = not disable
    FreezeEntityPosition(PlayerPedId(), true)
    showInfo()
end

function DisableBody()
    voiceThingRemove(GetEntityCoords(attachedPlayer))
    bodycamActive = not bodycamActive
    ClearTimecycleModifier("scanline_cam_cheap")
    RenderScriptCams(0, 0, 1, 1, 1)
    DestroyCam(cameraHandle, false)
    SetFocusEntity(GetPlayerPed(PlayerId()))
    attachedPlayer = nil
    cameraReverse = false
    disable = not disable
    disableShit(false)
    FreezeEntityPosition(PlayerPedId(), false)
    SetTablet(false)
    changeCulling(false)
end

-- CCTV

local activeCoords

function EnableCCTV(coords, rotation)
    activeCoords = coords
    cctvactive = not cctvactive
    SetTimecycleModifier("scanline_cam_cheap")
    SetTimecycleModifierStrength(1.2)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    RenderScriptCams(1, 0, 0, 1, 1)
    SetFocusEntity(ped)
    cameraHandle = cam
    SetCamCoord(cameraHandle, coords.x, coords.y, coords.z)
    SetCamRot(cameraHandle, rotation.x, rotation.y, rotation.z, 0)
    SetCamFov(cameraHandle, 90.0)
    disable = not disable
    FreezeEntityPosition(PlayerPedId(), true)
    showInfo('cam')
    voiceThing(coords)
end

function DisableCCTV()
    cctvactive = not cctvactive
    ClearTimecycleModifier("scanline_cam_cheap")
    RenderScriptCams(0, 0, 1, 1, 1)
    DestroyCam(cameraHandle, false)
    SetFocusEntity(GetPlayerPed(PlayerId()))
    disable = not disable
    disableShit(false)
    FreezeEntityPosition(PlayerPedId(), false)
    SetTablet(false)
    changeCulling(false)
    voiceThingRemove(activeCoords)
end

function disableShit(status)
    --DisableControlAction(0,21,status) -- disable sprint
    DisableControlAction(0,24,status) -- disable attack
    DisableControlAction(0,25,status) -- disable aim
    DisableControlAction(0,47,status) -- disable weapon
    DisableControlAction(0,58,status) -- disable weapon
    DisableControlAction(0,263,status) -- disable melee
    DisableControlAction(0,264,status) -- disable melee
    DisableControlAction(0,257,status) -- disable melee
    DisableControlAction(0,140,status) -- disable melee
    DisableControlAction(0,141,status) -- disable melee
    DisableControlAction(0,142,status) -- disable melee
    DisableControlAction(0,143,status) -- disable melee
    DisableControlAction(0,75,status) -- disable exit vehicle
    DisableControlAction(27,75,status) -- disable exit vehicle
end

function showInfo(veh)
    TriggerEvent('showmythic', 'Press E to Exit')
    if veh == 'cam' then
        TriggerEvent('showmythic', 'Numpad 7 To reduce Zoom')
        TriggerEvent('showmythic', 'Numpad 9 To Zoom')

        TriggerEvent('showmythic', 'Numpad 8 To Look Up')
        TriggerEvent('showmythic', 'Numpad 5 To Look Down')
        TriggerEvent('showmythic', 'Numpad 4 To Look Left')
        TriggerEvent('showmythic', 'Numpad 6 To Look Right')
    end
end

function inVehicle()
    local p = PlayerPedId()
    local v = GetVehiclePedIsIn(p, false)
    local veh = GetEntityModel(v)

    if veh == `22f550sesu` then
        return true
    else
        return false
    end
end

function SetTablet(using)
	if using then
		-- Take out the tablet.
		RequestAnimDict("amb@code_human_in_bus_passenger_idles@female@tablet@base")
		while not HasAnimDictLoaded("amb@code_human_in_bus_passenger_idles@female@tablet@base") do
				Citizen.Wait(0)
		end
		local tabletModel = GetHashKey("prop_cs_tablet")
		local bone = GetPedBoneIndex(PlayerPedId(), 60309)
		RequestModel(tabletModel)
		while not HasModelLoaded(tabletModel) do
				Citizen.Wait(100)
		end
		tabletProp = CreateObject(tabletModel, 1.0, 1.0, 1.0, 1, 1, 0)
		AttachEntityToEntity(tabletProp, PlayerPedId(), bone, 0.03, 0.002, -0.0, 10.0, 160.0, 0.0, 1, 0, 0, 0, 2, 1)
		TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
	else
		-- Put the tablet away.
		DetachEntity(tabletProp, true, true)
		DeleteObject(tabletProp)
		TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "exit", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
	end
end


-- COMMANDS

RegisterNetEvent('pen-dashcams:openMenu')
AddEventHandler('pen-dashcams:openMenu', function()
    local state = LocalPlayer.state.clockin
    clockedin = state.isLeo
    local dispatch = lib.callback.await('pen-dashcam:getCommunications', false, GetPlayerServerId(PlayerId()))
    if clockedin or dispatch then
        lib.callback('pen-dashcam:getActiveLEO', false, function(count)
            activeLeo = count
        end)
        changeCulling(true)
        Citizen.Wait(1000)
        registerMenu()
        --print(json.encode(DashcamMenuUnits, {indent=true}))
        --registerDashcamMenu()
        lib.showContext('cam_menu')
        SetTablet(true)
    else
        TriggerEvent('showmythic', 'Not Clocked In')
    end
end)

RegisterCommand('opendashcams', function(source)
    TriggerEvent('pen-dashcams:openMenu')
end)


RegisterCommand('+reverse', function()
    cameraReverse = not cameraReverse
end)

exports["pen_keybinds"]:mapkey( "+reverse", "(Dashcam) Reverse Camera", "keyboard", "")

Citizen.CreateThread(function()
    for k, v in ipairs(Config.Locations) do
        --print(v)
        --print(json.encode(v, {indent=true}))
        exports.ox_target:addSphereZone({
            coords = v.coords,
            radius = 0.25,
            --debug = drawZones,
            options = {
                {
                    name = 'cam',
                    event = 'pen-dashcams:openMenu',
                    icon = 'fa-solid fa-camera',
                    label = 'View All Cams',
                    canInteract = function(entity, coords, distance)
                        return true
                    end
                }
            }
        })
    end
end)

function voiceThing(coords)
    local p = GetPlayerServerId(PlayerId())
    for i = 0,255 do 
        MumbleAddVoiceChannelListen(i)
        --MumbleAddVoiceTargetChannel(1, i)
    end

end

function voiceThingRemove(coords)
    local p = GetPlayerServerId(PlayerId())
    for i = 0,255 do 
        MumbleRemoveVoiceChannelListen(i)
        --MumbleRemoveVoiceTargetChannel(1, i)
    end
end

function changeCulling(enable)
    local id = GetPlayerServerId(PlayerId())
    --print(enable, id)
    TriggerServerEvent('pen-dashcam:changeCulling', id, enable)
    print('[Sync] Temp changed culling')
end

function toggleDash(netId)
    local pedVehicle = NetToVeh(netId)
    --print(netId, pedVehicle)
    if not dashcamActive then
        EnableDash(pedVehicle)
    else
        DisableDash(pedVehicle)
    end
end

exports('toggleDash', toggleDash)
