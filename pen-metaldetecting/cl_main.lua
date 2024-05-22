local currBurrows = {}
local created = false
local holding = false
local maxDistance = 50.0
local minBeepInterval = 0.1
local maxBeepInterval = 2.0
local waitTimer = 5000

Citizen.CreateThread(function()
    requestBurrows()
end)

function requestBurrows()
    TriggerServerEvent('pen-metaldetecting:server:requestBurrows')
end

function foundBurrow(id)
    if hasTrowel() then
        if lib.progressBar({
            duration = 10000,
            label = 'Digging',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true
            },
            anim = {
                dict = 'amb@world_human_gardener_plant@female@base',
                clip = 'base_female'
            },
            prop = {
                model = `prop_cs_trowel`,
                pos = vec3(0.03, 0.03, 0.02),
                rot = vec3(0.0, 0.0, -1.5)
            },
        }) then print('do something') else return end
        TriggerServerEvent('pen-metaldetecting:server:foundBurrows', id)
    end
end

RegisterNetEvent('pen-metaldetecting:client:sendBurrows', function(data)
    currBurrows = data
    createZones()
end)

RegisterNetEvent('pen-metaldetecting:client:removeBurrows', function(id, data)
    currBurrows = data
    removeZones(id)
end)

function createZones()
    for k,v in ipairs(currBurrows) do

        local correctZ = getZ(v.x, v.y)

        exports.ox_target:addSphereZone({
            coords = vec3(v.x, v.y, correctZ),
            radius = 3,
            debug = true,
            drawSprite = true,
            name = '' .. v.id .. '',
            options = {
                {
                    onSelect = function(args)
                        foundBurrow(v.id)
                    end,
                    icon = 'fa-solid fa-circle',
                    label = '' .. v.id .. '',
                }
            }
        })
    end
end

function getZ(x, y)
    local ground_check = 0.0
    SetFocusPosAndVel(x, y, ground_check)
    local ground, z = GetGroundZFor_3dCoord(x, y, 999.0, 0)
    while not ground and ground_check <= 800.0 do
        ground_check = ground_check + 40.0
        SetFocusPosAndVel(x, y, ground_check)
        ground, z = GetGroundZFor_3dCoord(x, y, 999.0, 1)
        Citizen.Wait(10)
    end
    ClearFocus()
    return z
end

function removeZones(id)
    exports.ox_target:removeZone('' .. id .. '')
end

local function getBeepInterval(distance)
    if distance >= maxDistance then
        return maxBeepInterval
    else
        return minBeepInterval + ((distance / maxDistance) * (maxBeepInterval - minBeepInterval))
    end
end

local function getClosestTargetDistance(playerCoords)
    local closestDistance = maxDistance + 1
    for _, targetCoords in ipairs(currBurrows) do
        local targetCoord = vec3(targetCoords.x, targetCoords.y, targetCoords.z)
        local distance = #(playerCoords - targetCoord)
        if distance < closestDistance then
            closestDistance = distance
        end
    end
    return closestDistance
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(waitTimer)

        if not holdingDetector() then return else waitTimer = 0 end

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local closestDistance = getClosestTargetDistance(playerCoords)

        if closestDistance <= maxDistance then
            local beepInterval = getBeepInterval(closestDistance)
            
            PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
            
            Citizen.Wait(beepInterval * 1000)
        else
            Citizen.Wait(1000)
        end
    end
end)

local test = false

function hasTrowel()
    return test
end

function holdingDetector()
    return test
end

RegisterCommand('pen-metaldetecting:metaldetect-test', function()
    test = not test
end)