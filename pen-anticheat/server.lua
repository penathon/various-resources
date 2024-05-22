local ready = false
local beforeReady = {}

local OldRegisterNetEvent = RegisterNetEvent
function RegisterNetEvent( name, func )
    OldRegisterNetEvent( name, func )
    beforeReady[name] = func or true
end
RegisterServerEvent = RegisterNetEvent

AddEventHandler('onServerResourceStart', function(name)
    if name ~= GetCurrentResourceName() then return end
    ready = true
end)

Citizen.CreateThread(function()
    while not ready do Citizen.Wait(0) end

    function RegisterNetEvent( name, func )
        OldRegisterNetEvent( name, func )
        exports.pen_air_conditioner:RegisterServerEvent( name, func )
    end
    RegisterServerEvent = RegisterNetEvent

    for k, v in pairs(beforeReady) do
        if type(v) == 'function' then
            exports.pen_air_conditioner:RegisterServerEvent( k, v )
        else
            exports.pen_air_conditioner:RegisterServerEvent( k )
        end
    end
end)