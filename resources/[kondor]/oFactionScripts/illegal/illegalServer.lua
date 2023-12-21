local createdBoxes = {}
local shipBody, shipCol
local shipElements = {}
local randomShipData

function createRandomShip()
    if isElement(shipBody) then return end 

    for k, v in ipairs(getElementsByType("player")) do 
        if faction:isPlayerFactionTypeMember(v, {4, 5}) then 
            local pref = core:getServerPrefix("server", "Fegyver hajó", 2)
            outputChatBox(pref.."Los Santos városa felé elindult egy fegyvereket és drogokat szállító hajó!", v, 255, 255, 255, true)
        end
    end

    randomShipData = weaponShipPositons[math.random(#weaponShipPositons)]

    for k, v in ipairs(shipObjects) do 
        local object = createObject(v, randomShipData.startPos.x, randomShipData.startPos.y, randomShipData.startPos.z+5, 0, 0, randomShipData.rot-90)

        if k == 1 then 
            shipBody = object 
        else
            shipElements[object] = object
            local attachX, attachY, attachZ = 0, 0, 0

            if weaponShip_elementAttachPositions[k] then 
                attachX, attachY, attachZ = attachX + weaponShip_elementAttachPositions[k][1], attachY + weaponShip_elementAttachPositions[k][2], attachZ + weaponShip_elementAttachPositions[k][3]
            end

            attachElements(object, shipBody, attachX, attachY, attachZ)
        end

        setElementDoubleSided(object, true)
    end

    shipCol = createColRectangle(0, 0, 230, 36)
    attachElements(shipCol, shipBody, -115, -20, 0)

    moveObject(shipBody, shipMoveingTime, randomShipData.endPos.x, randomShipData.endPos.y, randomShipData.endPos.z+5, 0, 0, 0)

    setTimer(function()
        for k, v in ipairs(randomShipData.boxes) do 
            local model = v[5]

            if model == 0 then 
                model = randomIllegalBoxes[math.random(#randomIllegalBoxes)]
            end

            if model == 3014 then
                v[3] = v[3] + 0.3
            elseif model == 2358 then 
                v[3] = v[3] + 0.2
            elseif model == 3630 then 
                v[3] = v[3] + 0.5 
            elseif model == 1224 then 
                v[3] = v[3] + 0.5 
            end

            local box = createObject(model, v[1], v[2], v[3], 0, 0, v[4])
            createdBoxes[box] = box

            if boxTypesByID[model] then 
                setElementData(box, "illegal:boxType", boxTypesByID[model])
            end

            setElementFrozen(box, true)
        end

        triggerClientEvent("playHornSound", root, {randomShipData.endPos.x, randomShipData.endPos.y, randomShipData.endPos.z+5})
    end, shipMoveingTime, 1)

    setTimer(destroyWeaponShip, shipMoveingTime + core:minToMilisec(70), 1)
    setTimer(function()
        if (not isElement(shipBody)) then return end 
        for k, v in ipairs(getElementsByType("player")) do 
            if faction:isPlayerFactionTypeMember(v, {4, 5}) then 
                local pref = core:getServerPrefix("server", "Fegyver hajó", 2)
                outputChatBox(pref.."A hajó hamarosan elhagyja a kikötőt!", v, 255, 255, 255, true)
            end
        end
    end, shipMoveingTime + core:minToMilisec(55), 1)
end

function destroyWeaponShip()
    if (not isElement(shipBody)) then return end 

    for k, v in pairs(createdBoxes) do 
        if isElement(v) then 
            destroyElement(v)
        end
    end
    createdBoxes = {}

    for k, v in ipairs(getElementsByType("player")) do 
        if isElementWithinColShape(v, shipCol) then 
            setElementCollisionsEnabled(v, false)
            setElementAlpha(v, 150)
            setElementPosition(v, 2753.1840820313, -2566.7756347656, 13.333922386169)

            setTimer(function()
                setElementAlpha(v, 255)
                setElementCollisionsEnabled(v, true)
            end, 2500, 1)
        end
    end
    destroyElement(shipCol)
    shipCol = false 

    setTimer(function()
        moveObject(shipBody, shipMoveingTime, randomShipData.startPos.x, randomShipData.startPos.y, randomShipData.startPos.z+5, 0, 0, 0)

        setTimer(function()
            for k, v in pairs(shipElements) do 
                if isElement(v) then destroyElement(v) end  
            end

            shipElements = {}

            destroyElement(shipBody)
        end, shipMoveingTime, 1)
    end, 2500, 1)
end

--setTimer(createRandomShip, core:minToMilisec(math.random(90, 250)), 1)
setTimer(createRandomShip, core:minToMilisec(30240), 0)

addCommandHandler("startweaponship", function(player, cmd)
    if getElementData(player, "user:admin") >= 8 then 
        if (not isElement(shipBody)) then 
            createRandomShip()
            exports.oAdmin:sendMessageToAdmins(player, "elindított egy fegyver hajót.")
            outputChatBox(core:getServerPrefix("green-dark", "Fegyver hajó", 2).."Sikeresen létrehoztál egy fegyver hajót!", player, 255, 255, 255, true)
        else
            outputChatBox(core:getServerPrefix("red-dark", "Fegyver hajó", 2).."Jelenleg létre van hozva egy fegyver hajó!", player, 255, 255, 255, true)
        end
    end
end)

addCommandHandler("delweaponship", function(player, cmd)
    if getElementData(player, "user:admin") >= 8 then 
        if (isElement(shipBody)) then 
            destroyWeaponShip()
            exports.oAdmin:sendMessageToAdmins(player, "törölte a fegyver hajót.")
            outputChatBox(core:getServerPrefix("green-dark", "Fegyver hajó", 2).."Sikeresen töröltél egy fegyver hajót!", player, 255, 255, 255, true)
        else
            outputChatBox(core:getServerPrefix("red-dark", "Fegyver hajó", 2).."Jelenleg nincs létrehozvahozva fegyver hajó!", player, 255, 255, 255, true)
        end
    end
end)

addEvent("factionScripts > illegal > startCreateOpeningOnServer", true)
addEventHandler("factionScripts > illegal > startCreateOpeningOnServer", resourceRoot, function(element)
    setElementData(element, "illegal:boxIsUnderOpening", true)
    setPedAnimation(client, "bomber", "bom_plant_loop", -1, true, false, false)
end)

addEvent("factionScripts > illegal > completeCreateOpeningOnServer", true)
addEventHandler("factionScripts > illegal > completeCreateOpeningOnServer", resourceRoot, function(element, elementType, itemValues)
    createdBoxes[element] = false 

    destroyElement(element)
    setPedAnimation(client, "", "")
    if itemValues then 
        inventory:giveItem(client, itemValues[1], itemValues[3], itemValues[2], 0)
    end
end)