GlobalState.towCount = 0
local clockedin = {}

RegisterNetEvent('pen-repair::changeStatus')
AddEventHandler('pen-repair::changeStatus', function(status)

    local src = source

    if status then
        clockedin[src] = {
            time = os.time()
        }
        GlobalState.towCount = GlobalState.towCount + 1
    elseif not status then
        clockedin[src] = nil
        GlobalState.towCount = GlobalState.towCount - 1
    end
    print(GlobalState.towCount)
end)

AddEventHandler( 'playerDropped', function(reason)

    local src = source

    if clockedin[src] then
        clockedin[src] = nil
        GlobalState.towCount = GlobalState.towCount - 1
    end
    print(GlobalState.towCount)
end)