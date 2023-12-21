-- Taxi lámpa --
addEvent("factionScripts > taxi > addTaxiLight", true)
addEventHandler("factionScripts > taxi > addTaxiLight", resourceRoot, function(veh, positions)
    local x, y, z = unpack(positions)
    local obj = createObject(10816, 0, 0, 0)
    setElementCollisionsEnabled(obj, false)

    attachElements(obj, veh, x, y, z)

    setElementData(veh, "veh:taxiLightActive", true)
    setElementData(veh, "veh:policeLight:obj", obj)
end)

addEvent("factionScripts > taxi > removeTaxiLight", true)
addEventHandler("factionScripts > taxi > removeTaxiLight", resourceRoot, function(veh)
    local obj = getElementData(veh, "veh:policeLight:obj") or false

    if isElement(obj) then
        destroyElement(obj)
    end

    setElementData(veh, "veh:taxiLightActive", false)
    setElementData(veh, "veh:policeLight:obj", false)
end)

-------------

addEvent("factionScripts > taxi > > payTaxi", true)
addEventHandler("factionScripts > taxi > > payTaxi", resourceRoot, function(veh, price)
    local driver = false
    for seat, player in pairs(getVehicleOccupants(veh)) do
        if seat == 0 then 
            driver = player 
            break
        end
    end

    if driver then
        local clientMoney = getElementData(client, "char:money") 
        if clientMoney >= price then
            setElementData(client, "char:money", clientMoney - price)
            chat:sendLocalMeAction(client, "átnyújt "..price.."$-t a sofőrnek.")
            chat:sendLocalMeAction(driver, "elveszi a pénzt.")
            chat:sendLocalDoAction(client, "kifizette a számlát.")
            setElementData(veh, "taxiMeter:price", 0)

            setElementData(driver, "char:money", getElementData(driver, "char:money") + math.floor(price*0.8))
            outputChatBox(core:getServerPrefix("server", "Taxi", 2)..color..getPlayerName(client):gsub("_", " ").."#ffffff kifizette a taxit. (Ebből te kaptál: "..color..math.floor(price*0.8).."$#ffffff-t.)", driver, 255, 255, 255, true)
            outputChatBox(core:getServerPrefix("server", "Taxi", 2).."Kifizetted a taxit. "..color.."("..price.."$)#ffffff.", client, 255, 255, 255, true)
        
            faction:setFactionBankMoney(taxiFactionID, math.floor(price*0.2), "add")
        end
    end
end)

local taxiCalls = {}
addEvent("factionScripts > taxi > callTaxi", true)
addEventHandler("factionScripts > taxi > callTaxi", resourceRoot, function(pos, zone)
    table.insert(taxiCalls, {pos, zone, client, true})
    triggerClientEvent(root, "factionScripts > taxi > sendTaxiMessage", root, 1, {pos, zone, client, #taxiCalls})
    setElementData(client, "taxi:call:number", #taxiCalls)
end)

addEvent("factionScripts > taxi > cancelTaxi", true)
addEventHandler("factionScripts > taxi > cancelTaxi", resourceRoot, function(id)
    taxiCalls[id][4] = false 

    triggerClientEvent(root, "factionScripts > taxi > sendTaxiMessage", root, 2, {id, taxiCalls[id]})
    setElementData(client, "taxi:call:number", false)
end)

addEvent("factionScripts > taxi > sendArriveMessage", true)
addEventHandler("factionScripts > taxi > sendArriveMessage", resourceRoot, function(id)
    triggerClientEvent(root, "factionScripts > taxi > sendTaxiMessage", root, 4, {id[1], client})
    setElementData(id[2], "faction:taxi:isCalledTaxi", false)
end)

addCommandHandler("accepttaxi", function(player, cmd, id)
    if getElementData(player, "char:duty:faction") == taxiFactionID then 
        if tonumber((id or 0)) > 0 then 
            id = tonumber(id)
            if taxiCalls[id] then 
                if (getElementData(player, "taxi:activefuvar") or 0) == 0 then
                    if taxiCalls[id][4] then 
                        taxiCalls[id][4] = false 
                        taxiCalls[id][5] = player 
                        triggerClientEvent(root, "factionScripts > taxi > sendTaxiMessage", root, 3, {player, id, taxiCalls[id]})
                        infobox:outputInfoBox("Elfogadták a hívásodat! A taxi már úton van!", "info", taxiCalls[id][3])
                        outputChatBox(core:getServerPrefix("server", "Taxi", 2).."Elfogadták a hívásodat! A taxi már úton van!", taxiCalls[id][3], 255, 255, 255, true)
                        outputChatBox(core:getServerPrefix("green-dark", "Taxi", 2).."Sikeresen elfogadtad a(z) "..color..id.."#ffffff számú hívást.", player, 255, 255, 255, true)
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Taxi", 2).."Ezt a hívást visszamondták vagy már elfogadták.", player, 255, 255, 255, true)
                    end
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Taxi", 2).."Már van aktív fuvarod.", player, 255, 255, 255, true)
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", "Taxi", 2).."Nincs ilyen számú hívás.", player, 255, 255, 255, true)
            end
        else
            outputChatBox(core:getServerPrefix("server", "Használat", 3).."/"..cmd.." [Hívás azonosító]", player, 255, 255, 255, true)
        end
    end
end)