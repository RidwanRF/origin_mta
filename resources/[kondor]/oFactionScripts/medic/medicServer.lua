addEvent("factionScripts > medic > revivificationSuccess", true)
addEventHandler("factionScripts > medic > revivificationSuccess", resourceRoot, function(player, bandageSlot)
    exports.oDeath:animEnd(player)
    --inventory:takeItem(client, bandageSlot)
end)

addEvent("factionScripts > medic > revivificationUnsuccess", true)
addEventHandler("factionScripts > medic > revivificationUnsuccess", resourceRoot, function(player)
    exports.oDeath:animEnd(player)
    setElementHealth(player, 0)
    setElementData(player, "char:health", 0)
end)

addEvent("factionScripts > medic > fixPlayerHealth", true)
addEventHandler("factionScripts > medic > fixPlayerHealth", resourceRoot, function()
    setElementData(client, "char:bones", {["head"] = 0, ["body"] = 0, ["l_leg"] = 0, ["r_leg"] = 0, ["r_arm"] = 0, ["l_arm"] = 0})
    setElementData(client, "char:health", 100)
    setElementHealth(client, 100)
    setElementData(client, "char:sick", 0)
    setElementData(client, "char:money", getElementData(client, "char:money")-500)
end)

addEvent("factionScripts > medic > setPlayerHealthTo100", true)
addEventHandler("factionScripts > medic > setPlayerHealthTo100", resourceRoot, function(player)
    setElementHealth(player, 100)
end)

local stretchers = {}
local medicalbags = {}

function createStretcher(veh)
    stretchers[veh] = createObject(1997, 0, 0, 0)
    attachElements(stretchers[veh], veh, 0, -1.5, -0.5)
end

function createMedicalbag(veh)
    medicalbags[veh] = createObject(2919, 0, 0, 0)
    attachElements(medicalbags[veh], veh, 0.85, -1.5, 0.18, 0, 0, 90)
    setObjectScale(medicalbags[veh], 0.4, 0.25, 0.3)
    setElementCollisionsEnabled(medicalbags[veh], false)
end

--[[addEventHandler("onResourceStart", resourceRoot, function()
    for k, v in ipairs(getElementsByType("vehicle")) do 
        if getElementModel(v) == 416 then 
            createStretcher(v)
            createMedicalbag(v)
        end
    end
end)]]

addEventHandler("onElementDestroy", root, function()
    if getElementType(source) == "vehicle" then 
        if stretchers[source] then 
            if isElement(stretchers[source]) then 
                destroyElement(stretchers[source])
            end
            stretchers[source] = false
        end
    end
end)

setElementData(resourceRoot, "medic:serverTick", 0)
setTimer(function()
    setElementData(resourceRoot, "medic:serverTick", getTickCount())
end, 10000, 0)