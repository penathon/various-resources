
function IsVisionBlocked(targetCoords)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local rayHandle = StartShapeTestRay(playerCoords.x, playerCoords.y, playerCoords.z, targetCoords.x, targetCoords.y, targetCoords.z, -1, playerPed, 0)
    
    local _, hit, _, _, _ = GetShapeTestResult(rayHandle)
    
    return hit == 1
end

exports('isVisionBlocked', IsVisionBlocked)