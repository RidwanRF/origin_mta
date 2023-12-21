for k, v in ipairs(getElementsByType("player")) do
    setElementData(v, "inFactionCall", false)
end

local factionCalls = {
    ["pd"] = {},
    ["mechanic"] = {},
    ["medic"] = {},
    ["fire"] = {}
}

addEvent("factionCall > addCall", true)
addEventHandler("factionCall > addCall", resourceRoot, function(type, id, sentPlayer, sendMessages, phoneNumber)
    table.insert(factionCalls[type], {sentPlayer, false})

    local zone = getZoneName(getElementPosition(sentPlayer))

    for k, player in ipairs(getElementsByType("player")) do
        local factions = faction:getPlayerAllFactions(player)

        local benneVan = false
        if #factions > 0 then
            for k2, v2 in ipairs(factions) do
                --local factiontype = faction:getFactionType(v2)

                if v2 == id then
                    benneVan = id
                end
            end
        end

        if benneVan then
            local prefix = factionPrefixes[id] or faction:getFactionName(id)
            outputChatBox(core:getServerPrefix(factionColors[id], prefix, 3).."Hívás érkezett! ((Elfogadáshoz "..color.."/accept"..factionCallPrefix[id].." "..#factionCalls[type].."#ffffff))", player, 255, 255, 255, true)
            outputChatBox(core:getServerPrefix(factionColors[id], prefix, 3).."Helyszín: "..color..zone, player, 255, 255, 255, true)
            if id == 1 or id == 21 or id == 19 or id == 4 then
                outputChatBox(core:getServerPrefix(factionColors[id], prefix, 3).."Bejelentő telefonszáma: "..color..phoneNumber .. " ((".. getElementData(sentPlayer, "char:name"):gsub("_", " ").."))", player, 255, 255, 255, true)
                outputChatBox(core:getServerPrefix(factionColors[id], prefix, 3).."Bejelentés szövege: "..color..sendMessages, player, 255, 255, 255, true)
            end
        end
    end
end)

addCommandHandler("gov", function(player, cmd, ...)
    local factions = faction:getPlayerAllFactions(player)

    if #factions > 0 then
        for k, v in ipairs(factions) do
            local factiontype = faction:getFactionType(v)

            if factiontype == 1 or factiontype == 2 or factiontype == 3 then
                if faction:ifPlayerLeaderOfTheFaction(v, getElementData(player, "char:id")) then
                    if ... then
                        local message = table.concat({...}, " ")
                        local govtimer = getElementData(player, "faction:govtimer") or false

                        if not isTimer(govtimer) then
                            outputChatBox(" ")
                            outputChatBox(core:getServerPrefix("red-light", faction:getFactionName(v).." felhívás", 3)..message, root, 255, 255, 255, true)
                            outputChatBox(" ")

                            setElementData(player, "faction:govtimer", setTimer(function()
                                local timer = getElementData(player, "faction:govtimer")

                                if isTimer(timer) then
                                    killTimer(timer)
                                    setElementData(player, "faction:govtimer", false)
                                end
                            end, 1000*60*2, 1))
                        else
                            outputChatBox(core:getServerPrefix("red-dark", "Frakció", 2).."Csak 2 percenként használhatod ezt a parancsot!", player, 255, 255, 255, true)
                        end
                    else
                        outputChatBox(core:getServerPrefix("server", "GOV", 3).."/"..cmd.." [Üzenet]", player, 255, 255, 255, true)
                    end
                    break
                end
            end
        end
    end
end)

addCommandHandler("d", function(thePlayer, cmd, ...)
    local factions = faction:getPlayerAllFactions(thePlayer)

    if #factions > 0 then
        for k, v in ipairs(factions) do
            local factiontype = faction:getFactionType(v)

            if factiontype == 1 or factiontype == 2 or v == 11 or v == 4 then
                if inventory:hasItem(thePlayer, 154) then
                    if ... then
                        if getElementData(thePlayer, "playerInDead") then return end
                        if (getElementData(thePlayer, "lastPdRadio") or 0) + 1000 < getTickCount() then
                            local message = table.concat({...}, " ")

                            for k, player in ipairs(getElementsByType("player")) do
                                local factions = faction:getPlayerAllFactions(player)

                                local benneVan = false
                                if #factions > 0 then
                                    for k2, v2 in ipairs(factions) do
                                        local factiontype = faction:getFactionType(v2)

                                        if factiontype == 1 or factiontype == 2 or v2 == 11 then
                                            if inventory:hasItem(player, 154) then
                                                benneVan = true
                                            end
                                        end
                                    end
                                end

                                if benneVan then
                                    local prefix = factionPrefixes[v] or faction:getFactionName(v)
                                    outputChatBox("#db2518("..prefix..") "..getPlayerName(thePlayer):gsub("_", " ").." rádióban mondja: #ed5045"..message, player, 255, 255, 255, true)
                                    triggerClientEvent(player, "faction > pd > playRadioSound", player)
                                end
                            end
                            setElementData(thePlayer, "lastPdRadio", getTickCount())
                        end
                    else
                        outputChatBox(core:getServerPrefix("server", "Sürgősségi rádió", 3).."/"..cmd.." [Üzenet]", thePlayer, 255, 255, 255, true)
                    end
                end
            end
        end
    end
end)

addCommandHandler("acceptmedic", function(thePlayer, cmd, id)
    if getElementData(thePlayer, "char:duty:faction") == 19 then
        if tonumber(id) then
            id = tonumber(id)
            if factionCalls["medic"][id] then
                if not getElementData(thePlayer, "inFactionCall") then
                    if not factionCalls["medic"][id][2] then
                        setElementData(thePlayer, "inFactionCall", true)
                        factionCalls["medic"][id][2] = true
                        triggerClientEvent(thePlayer, "factionScripts > createAccpetedPlayerMarker", thePlayer, factionCalls["medic"][id][1], id, 2)

                        for k, player in ipairs(getElementsByType("player")) do
                            local factions = faction:getPlayerAllFactions(player)

                            local benneVan = false
                            if #factions > 0 then
                                for k2, v2 in ipairs(factions) do
                                    --local factiontype = faction:getFactionType(v2)

                                    if v2 == 19 then
                                        benneVan = id
                                    end
                                end
                            end

                            if benneVan then
                                local prefix = factionPrefixes[2] or faction:getFactionName(2)
                                outputChatBox(core:getServerPrefix(factionColors[2], prefix, 3)..color..getPlayerName(thePlayer):gsub("_", " ").."#ffffff elfogadta a(z) "..color..id.." #ffffffszámú hívást.", player, 255, 255, 255, true)
                            end
                        end

                        exports.oInfobox:outputInfoBox("Elfogadták a hívásodat!", "success", factionCalls["medic"][id][1])
                    else
                        outputChatBox(core:getServerPrefix("red-dark", firstToUpper(cmd), 3).."Ezt a hívást már elfogadták!", thePlayer, 255, 255, 255, true)
                    end
                else
                    outputChatBox(core:getServerPrefix("red-dark", firstToUpper(cmd), 3).."Jelenleg már elfogadtál egy hívást!", thePlayer, 255, 255, 255, true)
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", firstToUpper(cmd), 3).."Nem érkezett hívás ilyen azonosítóval!", thePlayer, 255, 255, 255, true)
            end
        end
    end
end)

addCommandHandler("acceptpd", function(thePlayer, cmd, id)
    if getElementData(thePlayer, "char:duty:faction") == 1 then
        if tonumber(id) then
            id = tonumber(id)
            if factionCalls["pd"][id] then
                if not getElementData(thePlayer, "inFactionCall") then
                    if not factionCalls["pd"][id][2] then
                        setElementData(thePlayer, "inFactionCall", true)
                        factionCalls["pd"][id][2] = true
                        triggerClientEvent(thePlayer, "factionScripts > createAccpetedPlayerMarker", thePlayer, factionCalls["pd"][id][1], id, 1)

                        for k, player in ipairs(getElementsByType("player")) do
                            local factions = faction:getPlayerAllFactions(player)

                            local benneVan = false
                            if #factions > 0 then
                                for k2, v2 in ipairs(factions) do
                                    --local factiontype = faction:getFactionType(v2)

                                    if v2 == 1 then
                                        benneVan = id
                                    end
                                end
                            end

                            if benneVan then
                                local prefix = factionPrefixes[1] or faction:getFactionName(1)
                                outputChatBox(core:getServerPrefix(factionColors[1], prefix, 3)..color..getPlayerName(thePlayer):gsub("_", " ").."#ffffff elfogadta a(z) "..color..id.." #ffffffszámú hívást.", player, 255, 255, 255, true)
                            end
                        end

                        exports.oInfobox:outputInfoBox("Elfogadták a hívásodat!", "success", factionCalls["pd"][id][1])
                    else
                        outputChatBox(core:getServerPrefix("red-dark", firstToUpper(cmd), 3).."Ezt a hívást már elfogadták!", thePlayer, 255, 255, 255, true)
                    end
                else
                    outputChatBox(core:getServerPrefix("red-dark", firstToUpper(cmd), 3).."Jelenleg már elfogadtál egy hívást!", thePlayer, 255, 255, 255, true)
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", firstToUpper(cmd), 3).."Nem érkezett hívás ilyen azonosítóval!", thePlayer, 255, 255, 255, true)
            end
        end
    end
end)

addCommandHandler("acceptmechanic", function(thePlayer, cmd, id)
    if getElementData(thePlayer, "char:duty:faction") == 3 then
        if tonumber(id) then
            id = tonumber(id)
            if factionCalls["mechanic"][id] then
                if not getElementData(thePlayer, "inFactionCall") then
                    if not factionCalls["mechanic"][id][2] then
                        setElementData(thePlayer, "inFactionCall", true)
                        factionCalls["mechanic"][id][2] = true
                        triggerClientEvent(thePlayer, "factionScripts > createAccpetedPlayerMarker", thePlayer, factionCalls["mechanic"][id][1], id, 41)

                        for k, player in ipairs(getElementsByType("player")) do
                            local factions = faction:getPlayerAllFactions(player)

                            local benneVan = false
                            if #factions > 0 then
                                for k2, v2 in ipairs(factions) do
                                    --local factiontype = faction:getFactionType(v2)

                                    if v2 == 3 then
                                        benneVan = id
                                    end
                                end
                            end

                            if benneVan then
                                local prefix = factionPrefixes[3] or faction:getFactionName(3)
                                outputChatBox(core:getServerPrefix(factionColors[3], prefix, 3)..color..getPlayerName(thePlayer):gsub("_", " ").."#ffffff elfogadta a(z) "..color..id.." #ffffffszámú hívást.", player, 255, 255, 255, true)
                            end
                        end

                        exports.oInfobox:outputInfoBox("Elfogadták a hívásodat!", "success", factionCalls["mechanic"][id][1])

                    else
                        outputChatBox(core:getServerPrefix("red-dark", firstToUpper(cmd), 3).."Ezt a hívást már elfogadták!", thePlayer, 255, 255, 255, true)
                    end
                else
                    outputChatBox(core:getServerPrefix("red-dark", firstToUpper(cmd), 3).."Jelenleg már elfogadtál egy hívást!", thePlayer, 255, 255, 255, true)
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", firstToUpper(cmd), 3).."Nem érkezett hívás ilyen azonosítóval!", thePlayer, 255, 255, 255, true)
            end
        end
    end
end)

addCommandHandler("acceptfire", function(thePlayer, cmd, id)
    if getElementData(thePlayer, "char:duty:faction") == 4 then
        if tonumber(id) then
            id = tonumber(id)
            if factionCalls["fire"][id] then
                if not getElementData(thePlayer, "inFactionCall") then
                    if not factionCalls["fire"][id][2] then
                        setElementData(thePlayer, "inFactionCall", true)
                        factionCalls["fire"][id][2] = true
                        triggerClientEvent(thePlayer, "factionScripts > createAccpetedPlayerMarker", thePlayer, factionCalls["fire"][id][1], id, 41)

                        for k, player in ipairs(getElementsByType("player")) do
                            local factions = faction:getPlayerAllFactions(player)

                            local benneVan = false
                            if #factions > 0 then
                                for k2, v2 in ipairs(factions) do
                                    --local factiontype = faction:getFactionType(v2)

                                    if v2 == 4 then
                                        benneVan = id
                                    end
                                end
                            end

                            if benneVan then
                                local prefix = factionPrefixes[4] or faction:getFactionName(4)
                                outputChatBox(core:getServerPrefix(factionColors[4], prefix, 3)..color..getPlayerName(thePlayer):gsub("_", " ").."#ffffff elfogadta a(z) "..color..id.." #ffffffszámú hívást.", player, 255, 255, 255, true)
                            end
                        end

                        exports.oInfobox:outputInfoBox("Elfogadták a hívásodat!", "success", factionCalls["fire"][id][1])
                    else
                        outputChatBox(core:getServerPrefix("red-dark", firstToUpper(cmd), 3).."Ezt a hívást már elfogadták!", thePlayer, 255, 255, 255, true)
                    end
                else
                    outputChatBox(core:getServerPrefix("red-dark", firstToUpper(cmd), 3).."Jelenleg már elfogadtál egy hívást!", thePlayer, 255, 255, 255, true)
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", firstToUpper(cmd), 3).."Nem érkezett hívás ilyen azonosítóval!", thePlayer, 255, 255, 255, true)
            end
        end
    end
end)

addEvent("factionScripts > factionInCallPos", true)
addEventHandler("factionScripts > factionInCallPos", resourceRoot, function(callID, factionID)
    --outputChatBox(callID.." "..factionID)
    setElementData(client, "inFactionCall", false)

    for k, player in ipairs(getElementsByType("player")) do
        local factions = faction:getPlayerAllFactions(player)

        local benneVan = false
        if #factions > 0 then
            for k2, v2 in ipairs(factions) do
                --local factiontype = faction:getFactionType(v2)

                if v2 == factionID then
                    benneVan = true
                end
            end
        end

        if benneVan then
            local prefix = factionPrefixes[factionID] or faction:getFactionName(factionID)
            outputChatBox(core:getServerPrefix(factionColors[factionID], prefix, 3)..color..getPlayerName(client):gsub("_", " ").."#ffffff megérkezett a(z) "..color..callID.." #ffffffszámú híváshoz.", player, 255, 255, 255, true)
        end
    end
end)

addEvent("factionScripts > createTicket", true)
addEventHandler("factionScripts > createTicket", resourceRoot, function(target, price, factionID, reason)
    setElementData(target, "char:money", getElementData(target, "char:money") - price)

    faction:setFactionBankMoney(factionID, math.floor(price*0.7), "add")

    outputChatBox(core:getServerPrefix("server", "Ticket", 3).."Kaptál egy "..color..price.."$#ffffff-os ticketet a(z) "..color..faction:getFactionName(factionID).."#ffffff nevű frakciótól.", target, 255, 255, 255, true)

    for k, player in ipairs(getElementsByType("player")) do
        local factions = faction:getPlayerAllFactions(player)

        local benneVan = false
        if #factions > 0 then
            for k2, v2 in ipairs(factions) do
                if v2 == factionID then
                    benneVan = true
                    break
                end
            end
        end

        if benneVan then
            outputChatBox(core:getServerPrefix("blue-light-2", factionPrefixes[factionID] or "Ticket", 3)..color..getPlayerName(client):gsub("_", " ").." #ffffffkiadott egy "..color..price.."$#ffffff-os ticketet "..color..getPlayerName(target):gsub("_", " ").." #ffffffnevű játékosnak.", player, 255, 255, 255, true)

            if reason then
                outputChatBox(core:getServerPrefix("blue-light-2", factionPrefixes[factionID] or "Ticket", 3).."Indok: "..color..reason.."#ffffff.", player, 255, 255, 255, true)
            end
        end
    end
end)

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function attachServerSide(helicopter)
  triggerClientEvent(resourceRoot,"attachCamHeli",resourceRoot,helicopter)
end
addEvent("attachServerSide",true)
addEventHandler("attachServerSide",resourceRoot,attachServerSide)

function detachServerSide(helicopter)
  triggerClientEvent(resourceRoot,"detachCamHeli",resourceRoot,helicopter)
end
addEvent("detachServerSide",true)
addEventHandler("detachServerSide",resourceRoot,detachServerSide)

function createFactionDoors()
    for k, v in ipairs(factionDoors) do 
        local door = createObject(v.model, v.pos[1], v.pos[2], v.pos[3], v.rot[1], v.rot[2], v.rot[3])
        setObjectScale(door, v.scale or 1, 1, 1)
        if v.lockable then
            setElementData(door, "door:isFactionDoor", true)
            setElementData(door, "door:faction", v.factionID)
            setElementData(door, "door:leaderDoor", v.isLeaderDoor)
            setElementData(door, "door:state", "close")
            setElementData(door, "door:defRot", v.rot)
            setElementFrozen(door, true)
        end
    end
end
createFactionDoors()

addEvent("factinScripts > changeDoorState", true)
addEventHandler("factinScripts > changeDoorState", resourceRoot, function(door)
addEvent("factinScripts > changeDoorState", true)
    if getElementData(door, "door:state") == "close" then 
        setElementData(door, "door:state", "open")
        setElementFrozen(door, false)
    else
        setElementData(door, "door:state", "close")
        setElementRotation(door, unpack(getElementData(door, "door:defRot")))
        setElementFrozen(door, true)
    end
end)