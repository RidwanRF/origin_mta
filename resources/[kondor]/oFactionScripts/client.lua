addEventHandler("onClientResourceStart", root, function(res)
    if getResourceName(res) == "oCore" or getResourceName(res) == "oDashboard" or getResourceName(res) == "oFont" or getResourceName(res) == "oFactionScripts" or getResourceName(res) == "oInfobox" or getResourceName(res) == "oChat" or getResourceName(res) == "oFont" or getResourceName(res) == "oVehicle" then   
        faction = exports.oDashboard
        inventory = exports.oInventory
        core = exports.oCore
        infobox = exports.oInfobox
        chat = exports.oChat
        font = exports.oFont
        vehicle = exports.oVehicle

        color, r, g, b = core:getServerColor()
    end
end)

sx, sy = guiGetScreenSize()
myX, myY = 1600, 900

fonts = {
    ["condensed-10"] = exports.oFont:getFont("condensed", 10),
    ["condensed-12"] = exports.oFont:getFont("condensed", 12),
}

function addFactionCall(type, factionID, player, sendMessages, phoneNumber)
    triggerServerEvent("factionCall > addCall", resourceRoot, type, factionID, player, sendMessages, phoneNumber)
end

addEvent("factionScripts > createAccpetedPlayerMarker", true)
addEventHandler("factionScripts > createAccpetedPlayerMarker", root, function(player, id, factionID)
    local pos = Vector3(getElementPosition(player))
    local blip = createBlip(pos.x, pos.y, pos.z, 5)
    setElementData(blip, "blip:name", "Beérkező hívás")
    local marker = createMarker(pos.x, pos.y, pos.z, "checkpoint", 4.0, r, g, b, 200)

    setElementData(marker, "factionCallBlip", blip)
    setElementData(marker, "factionCallMarkerID", id)
    setElementData(marker, "factionCallMarkerFactionID", factionID)
end)

addEventHandler("onClientMarkerHit", resourceRoot, function(player, mdim)
    if player == localPlayer then 
        if mdim then 
            if getElementData(source, "factionCallBlip") then 
                triggerServerEvent("factionScripts > factionInCallPos", resourceRoot, getElementData(source, "factionCallMarkerID"), getElementData(source, "factionCallMarkerFactionID"))
                destroyElement(getElementData(source, "factionCallBlip"))
                destroyElement(source)
                infobox:outputInfoBox("Megérkeztél a híváshoz!", "success")
            end
        end
    end
end)

local lastticket = 0
--[[addCommandHandler("ticket", function(cmd, id, price, ...)
    local factionID = 0

    for k, v in ipairs(faction:getPlayerAllFactions()) do 
        if allowedFactionsForTicket[v] then 
            factionID = v 
            break
        end
    end

    if factionID > 0 then 
        if (not id or not price) then 
            outputChatBox(core:getServerPrefix("server", "Használat", 3).."/"..cmd.." [ID / Név részlet] [Összeg] <Indok>", 255, 255, 255, true)
        else
            if lastticket + 10000 < getTickCount() then
                local target = core:getPlayerFromPartialName(localPlayer, id, false)
                if target then 
                    if not (target == localPlayer) then 
                        price = tonumber(price)

                        local reason = false
                        if ... then 
                            reason = table.concat({...}, " ")
                        end

                        if price <= 100000 then 
                            if core:getDistance(target, localPlayer) < 2 then 
                                chat:sendLocalMeAction("átad egy befizetendő számlát "..getElementData(target, "char:name"):gsub("_", " ").."-nak/nek.")
                                chat:sendLocalDoAction("Számlán szereplő összeg: "..price.."$.")

                                if reason then
                                    chat:sendLocalDoAction("Számlán szereplő szöveg: "..reason..".")
                                end

                                triggerServerEvent("factionScripts > createTicket", resourceRoot, target, price, factionID, reason)

                                lastticket = getTickCount()
                            else
                                outputChatBox(core:getServerPrefix("red-dark", "Ticket", 3).."Túl távol vagy.", 255, 255, 255, true)
                            end
                        else
                            outputChatBox(core:getServerPrefix("red-dark", "Ticket", 3).."Egyszerre maximum csak "..color.."10.000$#ffffff-t ticketelhetsz.", 255, 255, 255, true)
                        end
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Ticket", 3).."Magadat nem ticketelheted meg.", 255, 255, 255, true)
                    end
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Ticket", 3).."Nem található játékos.", 255, 255, 255, true)
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", "Ticket", 3).."Csak "..color.."10#ffffff másodpercenként ticketelhetsz.", 255, 255, 255, true)
            end
        end
    end
end)]]

-- door 
addEventHandler("onClientRender", root, function()
    local dim = getElementInterior( localPlayer )

    for k, v in ipairs(getElementsByType( "object", resourceRoot, true )) do 
        if getElementDimension( v ) == dim then
            if core:getDistance(v, localPlayer) < 2.5 then
                if getElementData(v, "door:isFactionDoor") then 
                    if getFactionDoorPermisison(localPlayer, v) then
                        local x, y, z = getPositionFromElementOffset(v, 1.4, 0, 0.9)
                        local psx, psy = getScreenFromWorldPosition(x, y, z)

                        if psx and psy then 
                            if getElementData(v, "door:state") == "close" then 
                                dxDrawImage(psx, psy, 25/myX*sx, 25/myY*sy, "files/lock.png", 0, 0, 0, tocolor(230, 57, 57, 200))
                            else
                                dxDrawImage(psx, psy, 25/myX*sx, 25/myY*sy, "files/lock.png", 0, 0, 0, tocolor(255, 255, 255, 200))
                            end
                        end
                    end
                end
            end
        end
    end
end)

addEventHandler("onClientKey", root, function(key, state)
    if key == "mouse1" and state then
        local dim = getElementInterior( localPlayer )

        for k, v in ipairs(getElementsByType( "object", resourceRoot, true )) do 
            if getElementDimension( v ) == dim then
                if core:getDistance(v, localPlayer) < 2.5 then
                    if getElementData(v, "door:isFactionDoor") then 
                        if getFactionDoorPermisison(localPlayer, v) then
                            local x, y, z = getPositionFromElementOffset(v, 1.4, 0, 0.9)
                            local psx, psy = getScreenFromWorldPosition(x, y, z)

                            if psx and psy then 
                                if core:isInSlot(psx, psy, 25/myX*sx, 25/myY*sy) then 
                                    triggerServerEvent("factinScripts > changeDoorState", resourceRoot, v)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

function getFactionDoorPermisison(player, door)
    local fkid = getElementData(door, "door:faction")
    if faction:isPlayerFactionMember(fkid) or getElementData(player, "user:aduty") then
        local leaderdoor = getElementData(door, "door:leaderDoor") 

        if leaderdoor then 
            if faction:isPlayerLeader(fkid) or getElementData(player, "user:aduty")  then 
                return true
            else
                return false
            end
        else
            return true
        end
    else
        return false
    end
end