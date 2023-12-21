-- Stinger
addEvent("factionScripts > pd > getStingerFromVeh", true)
addEventHandler("factionScripts > pd > getStingerFromVeh", resourceRoot, function(veh)
    setElementData(veh, "pd:stingerCount", (getElementData(veh, "pd:stingerCount") or 1) - 1)

    local bag = createObject(1575, getElementPosition(client))

    for k, v in ipairs(carryToggleControlls) do 
        toggleControl(client, v, false)
    end

    setPedAnimation(client, "CARRY", "crry_prtial", 0, true, false, true, true)

    exports.oBone:attachElementToBone(bag, client, 12, 0.15, -0.05, 0.1, 90, 90, 70)
    setElementData(client, "pdBag", bag)
end)

addEvent("factionScripts > pd > putDownStinger", true)
addEventHandler("factionScripts > pd > putDownStinger", resourceRoot, function(veh)
    local bag = getElementData(client, "pdBag")

    if isElement(bag) then
        destroyElement(bag)
    end

    setElementData(client, "pdBag", false)
    for k, v in ipairs(carryToggleControlls) do 
        toggleControl(client, v, true)
    end

    setPedAnimation(client, "", "")
end)

addEvent("factionScripts > pd > putDownStingerServer", true)
addEventHandler("factionScripts > pd > putDownStingerServer", resourceRoot, function(posX, posY, posZ, rotX, rotY, rotZ)
    local obj = createObject(2892, posX, posY, posZ, rotX, rotY, rotZ)

    local colPosX, colPosY, colPosZ = getPositionFromElementOffset(obj, -0.25, 4.5, 0.5)

    local cols = {}
    for i = 1, 7 do 
        local col = createColTube(colPosX, colPosY, colPosZ-0.5, 1, 2)
        colPosX, colPosY, colPosZ = getPositionFromElementOffset(obj, -0.25, 5-i*1.5, 0.5)
        table.insert(cols, col)
        setElementData(col, "pdIsStingerCol", true)
        setElementData(col, "pdStingerColObj", obj)
    end
    
    setElementData(obj, "pdStingerCols", cols)
end)

addEvent("factionScripts > pd > pickUpStinger", true)
addEventHandler("factionScripts > pd > pickUpStinger", resourceRoot, function(col)
    local bag = createObject(1575, getElementPosition(client))

    for k, v in ipairs(carryToggleControlls) do 
        toggleControl(client, v, false)
    end

    setPedAnimation(client, "CARRY", "crry_prtial", 0, true, false, true, true)

    exports.oBone:attachElementToBone(bag, client, 12, 0.15, -0.05, 0.1, 90, 90, 70)
    setElementData(client, "pdBag", bag)

    if col then 
        local obj = getElementData(col, "pdStingerColObj")
        local cols = getElementData(obj, "pdStingerCols")
        destroyElement(obj)

        for k, v in pairs(cols) do 
            destroyElement(v)
        end
    end
end)

addEvent("factionScripts > pd > adelStinger", true)
addEventHandler("factionScripts > pd > adelStinger", resourceRoot, function(col)
    if col then 
        triggerClientEvent("sendMessageToAdmins", getRootElement(), client, "törölt egy szögesdrótot.")
        local obj = getElementData(col, "pdStingerColObj")
        local cols = getElementData(obj, "pdStingerCols")
        destroyElement(obj)

        for k, v in pairs(cols) do 
            destroyElement(v)
        end
    end
end)

addEvent("factionScripts > pd > putStingeerToCar", true)
addEventHandler("factionScripts > pd > putStingeerToCar", resourceRoot, function(car)
    local bag = getElementData(client, "pdBag")

    if isElement(bag) then
        destroyElement(bag)
    end

    setElementData(client, "pdBag", false)
    for k, v in ipairs(carryToggleControlls) do 
        toggleControl(client, v, true)
    end

    setPedAnimation(client, "", "")

    setElementData(car, "pd:stingerCount", (getElementData(car, "pd:stingerCount") or 1) + 1)
end)

addEventHandler("onColShapeHit", root, function(element, mdim)
    if getElementType(element) == "vehicle" then 
        if mdim then 
            if getElementData(source, "pdIsStingerCol") then 
                setVehicleWheelStates(element, 1, 1, 1, 1)
            end
        end
    end
end)
-- Stinger vége

addEvent("factionScripts > pd > putDownRBS", true)
addEventHandler("factionScripts > pd > putDownRBS", resourceRoot, function(model, posX, posY, posZ, rotX, rotY, rotZ)
    local obj = createObject(model, posX, posY, posZ, rotX, rotY, rotZ)
    setElementData(obj, "pdIsRBS", true)
    setObjectBreakable(obj, false)
end)

addEvent("factionScripts > pd > delRBS", true)
addEventHandler("factionScripts > pd > delRBS", resourceRoot, function(obj, isAdmin)
    destroyElement(obj)

    if isAdmin then 
        triggerClientEvent("sendMessageToAdmins", getRootElement(), client, "törölt egy roadblockot.")
    end
end)

-- Jail 
addEventHandler("onResourceStart", resourceRoot, function()
    createJails()
end)

function createJails()
    for k, v in pairs(pdJailPositions) do 
        local index = 1

        local col1, col2

        for key, value in pairs(v) do
            if index == 1 then 
                col1 = createColTube(value[1].x, value[1].y, value[1].z-1, value[2], 2.2)
                setElementDimension(col1, v.dim)
                setElementInterior(col1, v.int)
            elseif index == 2 then 
                col2 = createColSphere(value[1].x, value[1].y, value[1].z-1, value[2])
                setElementDimension(col2, v.dim)
                setElementInterior(col2, v.int)
            end

            index = index + 1 
        end

        setElementData(col1, "jailInCol", col2)
        setElementData(col2, "jailOutCol", col1)
        setElementData(col1, "colIsPdJail", true)
    end
end

addEvent("factionScripts > pd > playerToPrison", true)
addEventHandler("factionScripts > pd > playerToPrison", resourceRoot, function(thePlayer, time, reason, newpos)
    for k, player in ipairs(getElementsByType("player")) do 
        local factions = faction:getPlayerAllFactions(player)

        local benneVan = false
        if #factions > 0 then 
            for k2, v2 in ipairs(factions) do 
                local factiontype = faction:getFactionType(v2)

                if factiontype == 1 or getElementData(player, "user:aduty") then 
                    benneVan = true
                end
            end
        end

        if benneVan then 
            outputChatBox(core:getServerPrefix("blue-light-2", "Börtön", 2)..color..getPlayerName(client):gsub("_", " ").." #ffffffbörtönbe helyezte "..color..getPlayerName(thePlayer):gsub("_", " ").." #ffffffnevű játékost.", player, 255, 255, 255, true)
            outputChatBox(core:getServerPrefix("blue-light-2", "Börtön", 2).."Idő: "..color..time.." #ffffffperc | Indok: "..color..reason, player, 255, 255, 255, true)
        end
    end

    setElementPosition(thePlayer, unpack(newpos))

    setElementData(thePlayer, "pd:jailDatas", {time, reason})
    setElementData(thePlayer, "pd:jailTime", time)
    setElementData(thePlayer, "pd:jail", true)

    outputChatBox(core:getServerPrefix("blue-light-2", "Börtön", 2)..color..getPlayerName(client):gsub("_", " ").." #ffffffbörtönbe helyezett téged!", thePlayer, 255, 255, 255, true)
    outputChatBox(core:getServerPrefix("blue-light-2", "Börtön", 2).."Idő: "..color..time.." #ffffffperc | Indok: "..color..reason, thePlayer, 255, 255, 255, true)
end)

addEvent("factionScripts > pd > jail > quit", true)
addEventHandler("factionScripts > pd > jail > quit", resourceRoot, function()
    setElementData(client, "pd:jail", false)
    setElementInterior(client, 0)
    setElementDimension(client, 0)
    setElementPosition(client, 1548.6007080078, -1669.1861572266, 13.566025733948)

    for k, player in ipairs(getElementsByType("player")) do 
        local factions = faction:getPlayerAllFactions(player)

        local benneVan = false
        if #factions > 0 then 
            for k2, v2 in ipairs(factions) do 
                local factiontype = faction:getFactionType(v2)

                if factiontype == 1 or getElementData(player, "user:aduty") then 
                    benneVan = true
                end
            end
        end

        if benneVan then 
            outputChatBox(core:getServerPrefix("blue-light-2", "Börtön", 2)..color..getPlayerName(client):gsub("_", " ").." #ffffffkiszabadult a börtönből.", player, 255, 255, 255, true)
        end
    end
end)

addEvent("factionScripts > pd > jail > removeFromJail", true)
addEventHandler("factionScripts > pd > jail > removeFromJail", resourceRoot, function(thePlayer, newpos)
    setElementData(thePlayer, "pd:jail", false)
    setElementPosition(thePlayer, unpack(newpos))

    for k, player in ipairs(getElementsByType("player")) do 
        local factions = faction:getPlayerAllFactions(player)

        local benneVan = false
        if #factions > 0 then 
            for k2, v2 in ipairs(factions) do 
                local factiontype = faction:getFactionType(v2)

                if factiontype == 1 or getElementData(player, "user:aduty") then 
                    benneVan = true
                end
            end
        end

        if benneVan then 
            outputChatBox(core:getServerPrefix("blue-light-2", "Börtön", 2)..color..getPlayerName(client):gsub("_", " ").." #ffffffkiszedbe a börtönből "..color..getPlayerName(thePlayer):gsub("_", " ").." #ffffffnevű rabot.", player, 255, 255, 255, true)
        end
    end

    outputChatBox(core:getServerPrefix("blue-light-2", "Börtön", 2)..color..getPlayerName(client):gsub("_", " ").." #ffffffkivett a börtönből!", thePlayer, 255, 255, 255, true)
end)

-- cuff/visz

for k, v in ipairs(getElementsByType("player")) do 
    if getElementData(v, "cuff:cuffed") then 
        local cuffObj = createObject(18350, getElementPosition(v))
        setElementCollisionsEnabled(cuffObj, false)
        setElementData(v, "cuff:cuffObj", cuffObj)

        exports.oBone:attachElementToBone(cuffObj, v, 11, 0, 0, 0, 0, 0, 0)
    end
end

addEvent("factionScripts > pd > setCuffState", true)
addEventHandler("factionScripts > pd > setCuffState", resourceRoot, function(cuffedPlayer, state)
    setElementData(cuffedPlayer, "cuff:cuffed", state)

    if state then 
        setElementData(cuffedPlayer, "cuff:usePlayer", client)

        local cuffObj = createObject(18350, getElementPosition(cuffedPlayer))
        setElementCollisionsEnabled(cuffObj, false)
        setElementData(cuffedPlayer, "cuff:cuffObj", cuffObj)

        local cuffObj2 = createObject(18350, getElementPosition(cuffedPlayer))
        setElementCollisionsEnabled(cuffObj2, false)
        setElementData(cuffedPlayer, "cuff:cuffObj2", cuffObj2)

        exports.oBone:attachElementToBone(cuffObj, cuffedPlayer, 11, 0, 0, 0, 90, 40, 240)
        exports.oBone:attachElementToBone(cuffObj2, cuffedPlayer, 12, 0, 0, 0, 90, 0, -50)
        
    else
        setElementData(cuffedPlayer, "cuff:usePlayer", false)
        inventory:giveItem(client, 77, 1, 1, 1)

        local cuffObj = getElementData(cuffedPlayer, "cuff:cuffObj")
        destroyElement(cuffObj)   

        local cuffObj2 = getElementData(cuffedPlayer, "cuff:cuffObj2")
        destroyElement(cuffObj2)     
                
    end
    
    for k, v in ipairs(cuffToglledControlls) do
        toggleControl(cuffedPlayer, v, not state)
    end
end)

addEventHandler("onPlayerQuit", root, function()
    if getElementData(source, "cuff:cuffObj2") then 
        local cuffObj = getElementData(source, "cuff:cuffObj")
        destroyElement(cuffObj)   

        local cuffObj2 = getElementData(source, "cuff:cuffObj2")
        destroyElement(cuffObj2)  
    end
end)

local carryDistanceTimer = {}

addEvent("factionScripts > pd > setCarryState", true)
addEventHandler("factionScripts > pd > setCarryState", resourceRoot, function(target, state)
    if state then 
        setElementData(target, "carry:followedPlayer", client)
        setElementData(client, "carry:carryedPlayer", target)

        local client = client 
        local target = target

        carryDistanceTimer[client] = setTimer(function()
            local cx,cy,cz = getElementPosition(client)
            local cuffedX,cuffedY,cuffedZ = getElementPosition(target)
            local distance = getDistanceBetweenPoints3D(cx,cy,cz,cuffedX,cuffedY,cuffedZ)
            local dim,int = getElementDimension(client),getElementDimension(client)

            if distance > 3 then 
                setElementPosition(target,cx + 0.5,cy + 0.5,cz)
                setElementInterior(target,int)
                setElementDimension(target,dim)
            end
        end, 1000, 0) --itt valami gebasz van
    else
        setElementData(target, "carry:followedPlayer", false)
        setElementData(client, "carry:carryedPlayer", false)

        if isTimer(carryDistanceTimer[client]) then killTimer(carryDistanceTimer[client]) end 
    end
end)

addEvent("factionScripts > pd > warpPedIntoVehicle", true)
addEventHandler("factionScripts > pd > warpPedIntoVehicle", resourceRoot, function(player, veh, seat)
    warpPedIntoVehicle(player, veh, seat)
end)

addEvent("factionScripts > pd > warpPedOutVehicle", true)
addEventHandler("factionScripts > pd > warpPedOutVehicle", resourceRoot, function(player)
    removePedFromVehicle(player)
end)

addEvent("factionScripts > pd > setCarryedPlayerIntDim", true)
addEventHandler("factionScripts > pd > setCarryedPlayerIntDim", resourceRoot, function(player, dim, int)
    setElementInterior(player, int)
    setElementDimension(player, dim)
    
    local clientX, clientY, clientZ = getElementPosition(client)
    setElementPosition(player, clientX + 1, clientY, clientZ)
end)

-- Villogo --
addEvent("factionScripts > police > addPoliceLight", true)
addEventHandler("factionScripts > police > addPoliceLight", resourceRoot, function(veh, positions)
    local x, y, z = unpack(positions)
    local obj = createObject(17098, 0, 0, 0)
    setElementCollisionsEnabled(obj, false)

    attachElements(obj, veh, x, y, z)

    removeVehicleSirens(veh)

    addVehicleSirens(veh, 1, 3, false, false, true, true)
    setVehicleSirens(veh, 1, x, y, z, 0, 0, 255, 200, 100)
    setVehicleSirensOn(veh, true)
    setElementData(veh, "veh:policeLightActive", true)
    setElementData(veh, "veh:policeLight:obj", obj)
end)

addEvent("factionScripts > police > removePoliceLight", true)
addEventHandler("factionScripts > police > removePoliceLight", resourceRoot, function(veh)
    local obj = getElementData(veh, "veh:policeLight:obj") or false

    if isElement(obj) then
        destroyElement(obj)
    end

    setVehicleSirensOn(veh, false) 
    removeVehicleSirens(veh)
    setElementData(veh, "veh:policeLightActive", false)
    setElementData(veh, "veh:policeLight:obj", false)
end)

addEventHandler("onResourceStop", resourceRoot, function()
    for k, v in ipairs(getElementsByType("vehicle")) do 
        if getElementData(v, "veh:policeLightActive") or getElementData(v, "veh:taxiLightActive") then 
            local obj = getElementData(v, "veh:policeLight:obj") or false

            if isElement(obj) then
                destroyElement(obj)
            end

            setElementData(v, "veh:policeLightActive", false)
            setElementData(v, "veh:taxiLightActive", false)
            setElementData(v, "veh:policeLight:obj", false)
            setVehicleSirensOn(v, false) 
            removeVehicleSirens(v)
        end
    end
end)
-------------

-- Sokkoló
addEvent("factionScripts > pd > shockPlayer", true)
addEventHandler("factionScripts > pd > shockPlayer", resourceRoot, function(state)
    if state then
        setPedAnimation(client, "ped", "FLOOR_hit", -1, false, false, false)

        local posX, posY, posZ = getElementPosition(client)
        triggerClientEvent(root, "factionScripts > pd > playShockSound", root, posX, posY, posZ)
    else
        setPedAnimation(client)
    end
end)

setWeaponProperty(23, "pro", "maximum_clip_ammo", 1)
setWeaponProperty(23, "std", "maximum_clip_ammo", 1)
setWeaponProperty(23, "poor", "maximum_clip_ammo", 1)

setWeaponProperty(23, "pro", "damage", 1)
setWeaponProperty(23, "std", "damage", 1)
setWeaponProperty(23, "poor", "damage", 1)

-- Lefoglalás
local bookedCarOutCols = {}

for k, v in ipairs(bookedCarsOutPositions) do 
    table.insert(bookedCarOutCols, createColSphere(v[1], v[2], v[3], 2))
end

addEvent("factionScripts > pd > bookVehicle", true)
addEventHandler("factionScripts > pd > bookVehicle", resourceRoot, function(occupiedVeh, veh)
    local vehOwnerID = getElementData(veh, "veh:owner")

    if getElementData(veh, "veh:isFactionVehice") == 0 then
        for k, player in ipairs(getElementsByType("player")) do 
            local factions = faction:getPlayerAllFactions(player)

            local benneVan = false
            if #factions > 0 then 
                for k2, v2 in ipairs(factions) do 
                    local factiontype = faction:getFactionType(v2)

                    if factiontype == 1 or getElementData(player, "user:aduty") then 
                        benneVan = true
                    end
                end
            end

            if benneVan then 
                outputChatBox(core:getServerPrefix("blue-light-2", "Lefoglalás", 2)..color..getPlayerName(client):gsub("_", " ").." #fffffflefoglalta a(z) "..color..getVehiclePlateText(veh).." #ffffffrendszámú járművet.", player, 255, 255, 255, true)
            end

            if getElementData(player, "char:id") == vehOwnerID then 
                outputChatBox(core:getServerPrefix("blue-light-2", "Lefoglalás", 2).."Lefoglalták a(z) "..color..getVehiclePlateText(veh).." #ffffffrendszámú járművedet.", player, 255, 255, 255, true)
            end
        end

        for k, v in ipairs(getVehicleOccupants(veh)) do 
            removePedFromVehicle(v)
        end

        detachTrailerFromVehicle(occupiedVeh)
        setElementDimension(veh, 1)
        setElementDimension(veh, getElementData(veh, "veh:id"))
        setElementData(veh, "vehIsBooked", 1)
    end
end)

addEvent("factionScripts > pd > bookedCarTriggering", true)
addEventHandler("factionScripts > pd > bookedCarTriggering", resourceRoot, function(veh)
    setElementData(client, "char:money", getElementData(client, "char:money") - bookedCarTriggeringPrice)
    faction:setFactionBankMoney(34, math.floor(bookedCarTriggeringPrice * 0.7), "add")

    setElementPosition(veh, 1948.1741943359, -2198.431640625, 13.546875)
    setElementData(veh, "vehIsBooked", 0)
    setElementDimension(veh, 0)
    setVehicleDamageProof(veh,true)
    
    for k, v in ipairs(bookedCarOutCols) do 
        if #getElementsWithinColShape(v, "vehicle") == 0 then 
            setElementFrozen(veh, true)
            setElementPosition(veh, getElementPosition(v))
            setElementRotation(veh, 0, 0, 0)
            setVehicleDamageProof(veh,false)
            return
        end
    end
end)

-- fegyverengedély
addEvent("factionScripts > pd > giveFirearmLicense", true)
addEventHandler("factionScripts > pd > giveFirearmLicense", resourceRoot, function(player)
    outputChatBox(core:getServerPrefix("green-dark", "Fegyverengedély", 2).."Kiállítottak neked egy fegyverengedélyt.", player, 255, 255, 255, true)
    inventory:createLicense(player, 3)
end)

addEvent("factionScripts > pd > giveHuntingLicense", true)
addEventHandler("factionScripts > pd > giveHuntingLicense", resourceRoot, function(player)
    outputChatBox(core:getServerPrefix("green-dark", "Vadászati engedély", 2).."Kiállítottak neked egy vadászati engedélyt.", player, 255, 255, 255, true)
    inventory:createLicense(player, 4)
end)

--álnév
addEvent("factionScripts > pd > changeName", true)
addEventHandler("factionScripts > pd > changeName", resourceRoot, function(name)
    local oldName = getElementData(client, "char:name")
    local playerID = getElementData(client, "playerid")
    for k, v in ipairs(getElementsByType("player")) do 
        if (getElementData(v, "user:admin") or 0) >= 2 then 
            outputChatBox(core:getServerPrefix("red-dark", "Adminisztrátor - Álnév", 3)..color..oldName:gsub("_", " ").." ["..playerID.."]".."#ffffff nevű játékos álnevet használ. Új neve: "..color..name:gsub("_", " ").."#ffffff.", v, 255, 255, 255, true)
        end
    end

    setElementData(client, "char:name", name)
    setPlayerName(client, name)
end)

-- toglog parancs
for k, player in pairs(getElementsByType("player")) do 
    local factions = faction:getPlayerAllFactions(player)
    local benneVan = false
    if #factions > 0 then
        for k2, v2 in ipairs(factions) do
            if v2 == 1 then
                benneVan = id
            end
        end
    end

    if benneVan then
        setElementData(player, "pd:logs", 1)                           
    end
end

addCommandHandler("togpdlogs", function(thePlayer)
    if getElementData(thePlayer, "char:duty:faction") == 1 then
        if getElementData(thePlayer, "pd:logs") == 1 then
            outputChatBox(core:getServerPrefix("server", "Log", 3).."Sikeresen kikapcsoltad a logokat. (Traffipax)", thePlayer, 255, 255, 255, true)
            setElementData(thePlayer, "pd:logs", 0)
        else
            outputChatBox(core:getServerPrefix("server", "Log", 3).."Sikeresen bekapcsoltad a logokat. (Traffipax)", thePlayer, 255, 255, 255, true)
            setElementData(thePlayer, "pd:logs", 1)
        end
    end  
end)