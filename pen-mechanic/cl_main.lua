local repairClockedIn = false
local waitTimer = 1
local selectedMarker = {}
local enableMarker = false

RegisterCommand('mechanic', function()
    if exports["pen-util"]:IsRolePresent("Benny's") then
        local status = not repairClockedIn
        changeClockIn(status)
    end
end)

-- threads

--[[Citizen.CreateThread(function()
    while true do
        
    end
end)]]--

-- functions

function changeClockIn(status)
    if status then
        repairClockedIn = status
        TriggerServerEvent('pen-repair::changeStatus', status)
        TriggerEvent('showmythic', "Clocked in as mechanic")
        addRepairVehicle()
    elseif not status then
        repairClockedIn = false
        TriggerServerEvent('pen-repair::changeStatus', status)
        TriggerEvent('showmythic', "Clocked out as mechanic")
        removeRepairVehicle()
    end
end

function createVanZone()
end

function addRepairVehicle()
    exports.ox_target:addGlobalVehicle({
        {
            name = 'pen-repair:repair',
            icon = 'fa-solid fa-wrench',
            label = "Repair Vehicle",
            bones = 'bonnet',
            canInteract = function(entity, distance, coords, name, boneId)
                if GetVehicleDoorAngleRatio(entity, 4) == 0.0 then return end
                if GetVehicleDoorLockStatus(entity) > 1 then return end
                if IsVehicleDoorDamaged(entity, 4) then return end
                return #(coords - GetEntityBonePosition_2(entity, boneId)) < 0.9
            end,
            onSelect = function(data)
                beginRepair(data.entity)
            end
        }
    })
end

function removeRepairVehicle()
    exports.ox_target:removeGlobalVehicle("pen-repair:repair")
end

function beginRepair(entity)
    if lib.progressBar({
        duration = 20000,
        label = 'Repairing Vehicle',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            sprint = true
        },
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped'
        },
    }) then repairVehicle(entity, true) end
end

function repairVehicle(entity, notify)
    SetVehicleFixed(entity)
	SetVehicleDeformationFixed(entity)
	SetVehicleUndriveable(entity, false)
    if notify then
        TriggerEvent('showmythic', "Vehicle Repaired")
    end
end



Citizen.CreateThread(function()
	for location, data in pairs(Config.Locations) do
		for i, spot in ipairs(data.zones) do
			local newSpot = BoxZone:Create(spot.coords, spot.length+20, spot.width+20, {
				name = 'repairShop',
				debugPoly = spot.debug,
				heading = spot.heading,
				minZ = spot.minZ,
				maxZ = spot.maxZ,
			})
            
            --addRepairBlip(spot.repairMarker.x, spot.repairMarker.y, spot.repairMarker.z, 'Repair Shop', 0, 446)

			newSpot:onPlayerInOut(function(isPointInside, _)
				if isPointInside then
                    checkRepairMarker()
                    selectedMarker = spot.repairMarkers
					if repairClockedIn then
                        addRepairVehicle()
                    else
                        removeRepairVehicle()
                    end
				else
                    --destroyRepairMarker()
                    --destroyClockIn()
                    enableMarker = false
                    selectedMarker = {}
					if repairClockedin then
                        removeRepairVehicle()
                    else
                        removeRepairVehicle()
                    end
				end
			end)
		end
	end
end)

function checkRepairMarker()
    --print(GlobalState.towCount)
    if GlobalState.towCount == 0 then
        enableMarker = true
    end
end

function addRepairBlip(x, y, z, Name, Colour, Sprite)
    StationBlip = AddBlipForCoord(x, y, z)
    SetBlipSprite(StationBlip, Sprite)
    SetBlipDisplay(StationBlip, 2)
    SetBlipScale(StationBlip, 0.8)
    SetBlipColour(StationBlip, Colour)
    SetBlipAsShortRange(StationBlip, true)
        
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Name)
    EndTextCommandSetBlipName(StationBlip)
end

local repaired = false

Citizen.CreateThread(function()
    while true do
        if enableMarker then
            for k,v in ipairs(selectedMarker) do
                DrawMarker(1, v.x, v.y, v.z-2.50, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 4.0, 255, 60, 120, 155, false, true, 2, nil, nil, false)
                DrawMarker(36, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 255, 60, 120, 155, false, true, 2, nil, nil, false)
                local c = GetEntityCoords(PlayerPedId())
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                local locVector = vector3(v.x, v.y, v.z)
                if Vdist2(c, locVector) < 4.0*1.12 and GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then
                    if not repaired then
                        repaired = true
                        repairVehicle(veh, false)
                    end
                else
                    repaired = false
                end
            end
            waitTimer = 1
        else
            waitTimer = 1000
        end
        Citizen.Wait(waitTimer)
    end
end)