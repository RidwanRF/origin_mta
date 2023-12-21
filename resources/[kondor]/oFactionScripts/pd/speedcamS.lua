addEvent("factionScripts > pd > putDownSpeedcam", true)
addEventHandler("factionScripts > pd > putDownSpeedcam", resourceRoot, function(x, y, z, rx, ry, rz, veh)
    if veh then  
        local cam = createObject(17094, x, y, z, rx, ry, rz)
        setElementCollisionsEnabled(cam, false)
        attachElements(cam, veh, 0.8, 0.3, -1, 0, 0, -90)
    else
        local cam = createObject(17094, x, y, z, rx, ry, rz)
        setElementData(cam, "pd:speedcam", true)
    end
    
end)

addEvent("factionScripts > pd > deleteSpeedcam", true)
addEventHandler("factionScripts > pd > deleteSpeedcam", resourceRoot, function(cam)
    destroyElement(cam)
end)

addEvent("factionScripts > pd > createSpeedImage", true)
addEventHandler("factionScripts > pd > createSpeedImage", resourceRoot, function(driver, veh, limit)
    triggerClientEvent(driver, "traffipax > checkAtlepes", driver, limit, veh, 0, false)
end)