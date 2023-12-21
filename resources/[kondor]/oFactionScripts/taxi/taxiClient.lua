local taximeterX, taximeterY, taximeterW, taximeterH = sx/2 - sx*0.15/2, sy*0.8, sx*0.15, sy*0.097
local moveing = false

taxiFont = dxCreateFont("files/digital.ttf", 20) 

local taxiMeterType = "passenger"

local taxiCounter = nil
local lastTaxiPos = false

local lastTaxibutton = 0

function renderTaxiMeter()
    if not getPedOccupiedVehicle(localPlayer) then setTaxiMeterState(false) return end
    dxDrawRectangle(taximeterX, taximeterY, taximeterW, taximeterH, tocolor(30, 30, 30, 150))
    dxDrawRectangle(taximeterX + 2/myX*sx, taximeterY + 2/myY*sy, taximeterW - 4/myX*sx, taximeterH - 4/myY*sy, tocolor(35, 35, 35, 255))
    dxDrawRectangle(taximeterX + 2/myX*sx, taximeterY + 2/myY*sy, taximeterW - 4/myX*sx, sy*0.02, tocolor(30, 30, 30, 255))
    dxDrawText("Taxióra", taximeterX + 2/myX*sx, taximeterY + 2/myY*sy, taximeterX + 2/myX*sx+taximeterW - 4/myX*sx, taximeterY + 2/myY*sy+sy*0.02, tocolor(255, 255, 255, 100), 1, font:getFont("condensed", 9/myX*sx), "center", "center")

    dxDrawRectangle(taximeterX + 4/myX*sx, taximeterY + sy*0.02 + 6/myY*sy, taximeterW - 8/myX*sx, sy*0.03, tocolor(30, 30, 30, 255))
    
    dxDrawText("$", taximeterX + 8/myX*sx, taximeterY + sy*0.02 + 6/myY*sy, taximeterX + 4/myX*sx + taximeterW - 8/myX*sx - 4/myX*sx, taximeterY + sy*0.02 + 6/myY*sy + sy*0.027, tocolor(255, 255, 255, 50), 0.8/myX*sx, taxiFont, "right", "center")
    dxDrawText("000000000000", taximeterX + 8/myX*sx, taximeterY + sy*0.02 + 6/myY*sy, taximeterX + 4/myX*sx + taximeterW - 8/myX*sx - 20/myX*sx, taximeterY + sy*0.02 + 6/myY*sy + sy*0.027, tocolor(255, 255, 255, 50), 0.8/myX*sx, taxiFont, "right", "center")
    
    local occupiedVeh = getPedOccupiedVehicle(localPlayer)
    local taxiPrice = getElementData(occupiedVeh, "taxiMeter:price") or 0

    if taxiPrice <= 0 then 
        taxiPrice = ""
    end

    dxDrawText(taxiPrice, taximeterX + 8/myX*sx, taximeterY + sy*0.02 + 6/myY*sy, taximeterX + 4/myX*sx + taximeterW - 8/myX*sx - 20/myX*sx, taximeterY + sy*0.02 + 6/myY*sy + sy*0.027, tocolor(r, g, b, 255), 0.8/myX*sx, taxiFont, "right", "center")

    if taxiMeterType == "driver" then
        if getElementData(occupiedVeh, "taxiMeter:state") then
            core:dxDrawButton(taximeterX + 4/myX*sx, taximeterY + sy*0.055 + 6/myY*sy, sx*0.093, sy*0.03, r, g, b, 200, "Megállítás", tocolor(255, 255, 255, 255), 1, font:getFont("condensed", 9/myX*sx), true, tocolor(0, 0, 0, 50))
        else
            core:dxDrawButton(taximeterX + 4/myX*sx, taximeterY + sy*0.055 + 6/myY*sy, sx*0.093, sy*0.03, r, g, b, 200, "Indítás", tocolor(255, 255, 255, 255), 1, font:getFont("condensed", 9/myX*sx), true, tocolor(0, 0, 0, 50))
        end

        core:dxDrawButton(taximeterX + 4/myX*sx + sx*0.093 + 3/myX*sx, taximeterY + sy*0.055 + 6/myY*sy, sx*0.05, sy*0.03, 237, 55, 55, 200, "Nullázás", tocolor(255, 255, 255, 255), 1, font:getFont("condensed", 9/myX*sx), true, tocolor(0, 0, 0, 50))
    else
        if getElementData(occupiedVeh, "taxiMeter:state") then
            core:dxDrawButton(taximeterX + 4/myX*sx, taximeterY + sy*0.055 + 6/myY*sy, taximeterW - 8/myX*sx, sy*0.03, r, g, b, 50, "Fizetés", tocolor(255, 255, 255, 50), 1, font:getFont("condensed", 9/myX*sx), true, tocolor(0, 0, 0, 50))
        else
            core:dxDrawButton(taximeterX + 4/myX*sx, taximeterY + sy*0.055 + 6/myY*sy, taximeterW - 8/myX*sx, sy*0.03, r, g, b, 200, "Fizetés", tocolor(255, 255, 255, 255), 1, font:getFont("condensed", 9/myX*sx), true, tocolor(0, 0, 0, 50))
        end
    end

    if moveing then 
        local cx, cy = getCursorPosition()
        cx, cy = cx * sx, cy*sy

        cx, cy = cx - moveing[1], cy - moveing[2]

        taximeterX, taximeterY = cx, cy
    end
end

function keyTaximeter(key, state)
    if state and key == "mouse1" then 
        if taxiMeterType == "driver" then
            if getElementData(localPlayer, "char:duty:faction") == taxiFactionID then 
                if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    if lastTaxibutton + 1000 < getTickCount() then
                        if core:isInSlot(taximeterX + 4/myX*sx + sx*0.093 + 3/myX*sx, taximeterY + sy*0.055 + 6/myY*sy, sx*0.05, sy*0.03) then 
                            local occupiedveh = getPedOccupiedVehicle(localPlayer)

                            if getElementData(occupiedveh, "taxiMeter:price") == 0 then return end

                            setElementData(occupiedveh, "taxiMeter:price", 0)
                            lastTaxibutton = getTickCount()
                            chat:sendLocalMeAction("megnyom egy gombot a taxiórán.")
                            playSound("files/button.mp3")
                        end

                        if core:isInSlot(taximeterX + 4/myX*sx, taximeterY + sy*0.055 + 6/myY*sy, sx*0.093, sy*0.03) then 
                            local occupiedveh = getPedOccupiedVehicle(localPlayer)
                            local taxiState = getElementData(occupiedveh, "taxiMeter:state")

                            if taxiState then 
                                stopTaxiCounter()
                                chat:sendLocalMeAction("megállítja a taxiórát.")
                            else
                                startTaxiCounter()
                                chat:sendLocalMeAction("elindítja a taxiórát.")
                            end

                            lastTaxibutton = getTickCount()

                            setElementData(occupiedveh, "taxiMeter:state", not taxiState)
                        end
                    end
                end
            end
        else
            if core:isInSlot(taximeterX + 4/myX*sx + sx*0.093 + 3/myX*sx, taximeterY + sy*0.055 + 6/myY*sy, sx*0.05, sy*0.03) then 
                local occupiedveh = getPedOccupiedVehicle(localPlayer)
                local taxiState = getElementData(occupiedveh, "taxiMeter:state")
                local taxiPrice = getElementData(occupiedveh, "taxiMeter:price") or 0

                if not taxiState then
                    if taxiPrice > 0 then
                        if getElementData(localPlayer, "char:money") >= taxiPrice then
                            triggerServerEvent("factionScripts > taxi > > payTaxi", resourceRoot, getPedOccupiedVehicle(localPlayer), taxiPrice)
                        else
                            infobox:outputInfoBox("Nincs elegendő pénzed! ("..taxiPrice.."$)", "error")
                        end
                    end
                end
            end
        end 

        if core:isInSlot(taximeterX + 2/myX*sx, taximeterY + 2/myY*sy, taximeterW - 4/myX*sx, sy*0.02) then 
            local cx, cy = getCursorPosition()
            cx, cy = cx*sx, cy*sy 

            cx = cx - taximeterX
            cy = cy - taximeterY

            moveing = {cx, cy}
        end
    end

    if key == "mouse1" and not state then 
        if moveing then 
            moveing = false 
        end
    end
end

function setTaxiMeterState(state)
    if state then 
        addEventHandler("onClientRender", root, renderTaxiMeter)
        addEventHandler("onClientKey", root, keyTaximeter)
    else
        removeEventHandler("onClientRender", root, renderTaxiMeter)
        removeEventHandler("onClientKey", root, keyTaximeter)
    end
end

addEventHandler("onClientVehicleEnter", root, function(ped, seat)
    if ped == localPlayer then 
        if getElementData(source, "veh:taxiLightActive") then 
            if seat == 0 then 
                taxiMeterType = "driver"
            else
                taxiMeterType = "passenger"
            end

            setTaxiMeterState(true)
        end
    end
end)

addEventHandler("onClientVehicleStartExit", root, function(ped, seat)
    if ped == localPlayer then 
        if getElementData(source, "veh:taxiLightActive") then 
            setTaxiMeterState(false)
        end
    end
end)

function startTaxiCounter()
    taxiCounter = setTimer(function()
        if lastTaxiPos then 
            local posX, posY, posZ = getElementPosition(localPlayer)

            local dis = getDistanceBetweenPoints3D(posX, posY, posZ, unpack(lastTaxiPos))
           
            local occupiedveh = getPedOccupiedVehicle(localPlayer)
            setElementData(occupiedveh, "taxiMeter:price", (getElementData(occupiedveh, "taxiMeter:price") or 0) + math.floor(dis*taxiPricePerYard))

            lastTaxiPos = {getElementPosition(localPlayer)}
        else
            lastTaxiPos = {getElementPosition(localPlayer)}
        end
    end, 1000, 0)
end

function stopTaxiCounter()
    if isTimer(taxiCounter) then killTimer(taxiCounter) end 
end

addEventHandler("onClientElementDataChange", root, function(data, old, new)
    if data == "taxiMeter:state" then 
        if source == getPedOccupiedVehicle(localPlayer) then 
            playSound("files/button.mp3")
        end
    elseif data == "veh:taxiLightActive" then 
        if source == getPedOccupiedVehicle(localPlayer) then 
            local seat = getPedOccupiedVehicleSeat(localPlayer)

            if seat == 0 then 
                taxiMeterType = "driver"
            else
                taxiMeterType = "passenger"
            end

            setTaxiMeterState(new)
        end
    end
end)

-- Taxi lámpa
local txd = engineLoadTXD("files/taxilight.txd")
engineImportTXD(txd, 10816)
local dff = engineLoadDFF("files/taxilight.dff")
engineReplaceModel(dff, 10816, true)

function applyTaxiLightToOccupiedVehicle()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return false end 
    if taxiDeniedCars[getElementModel(veh)] then return false end
    if getElementData(veh, "veh:taxiLightActive") then return end
    if getElementData(veh, "veh:policeLightActive") then return end
    if policeLightPositions[getElementModel(veh)] then 
        setElementData(veh, "taxiMeter:state", false)
        setElementData(veh, "taxiMeter:price", 0)
        triggerServerEvent("factionScripts > taxi > addTaxiLight", resourceRoot, veh, policeLightPositions[getElementModel(veh)])
        return true 
    else
        return false
    end
end

function removeTaxiLightFromOccupiedVehicle()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return false end 
    if not getElementData(veh, "veh:taxiLightActive") then return end
    if policeLightPositions[getElementModel(veh)] then 
        triggerServerEvent("factionScripts > taxi > removeTaxiLight", resourceRoot, veh)
        setElementData(veh, "taxiMeter:state", false)
        setElementData(veh, "taxiMeter:price", 0)
        stopTaxiCounter()
        return true 
    else
        return false
    end
end

-- Call
local lastCall = 0
function makeTaxiCall()
    local callState = getElementData(localPlayer, "faction:taxi:isCalledTaxi") or false 

    if getElementDimension(localPlayer) == 0 and getElementInterior(localPlayer) == 0 then
        if callState then -- visszamondás
            outputChatBox(core:getServerPrefix("green-dark", "Taxi", 2).."Sikeresen visszamondtad a taxit!", 255, 255, 255, true) 
            triggerServerEvent("factionScripts > taxi > cancelTaxi", resourceRoot, getElementData(localPlayer, "taxi:call:number"))
            setElementData(localPlayer, "faction:taxi:isCalledTaxi", not callState)

            return true
        else -- hívás
            if lastCall + core:minToMilisec(2) < getTickCount() then
                setElementData(localPlayer, "faction:taxi:isCalledTaxi", not callState)
                lastCall = getTickCount()
                outputChatBox(core:getServerPrefix("green-dark", "Taxi", 2).."Sikeresen hívtál egy taxit!", 255, 255, 255, true) 
                triggerServerEvent("factionScripts > taxi > callTaxi", resourceRoot, {getElementPosition(localPlayer)}, getZoneName(getElementPosition(localPlayer)))

                return true
            else
                outputChatBox(core:getServerPrefix("red-dark", "Taxi", 2).."Csak "..color.."2 #ffffffpercenként hívhatsz taxit!", 255, 255, 255, true)
                return false
            end
        end
    else
        outputChatBox(core:getServerPrefix("red-dark", "Taxi", 2).."Interiorban nem hívhatsz taxit!", 255, 255, 255, true)
        return false
    end
end

local utasblip, utasmarker = false, false
local activeFuvar = 0
addEvent("factionScripts > taxi > sendTaxiMessage", true)
addEventHandler("factionScripts > taxi > sendTaxiMessage", root, function(msgType, msgDatas)
    if getElementData(localPlayer, "char:duty:faction") == taxiFactionID then 
        if msgType == 1 then 
            outputChatBox(core:getServerPrefix("server", "Taxi", 2).."Hívás érkezett! Elfogadáshoz használd az "..color.."'/accepttaxi "..msgDatas[4].."' #ffffffparancsot.", 255, 255, 255, true)
            outputChatBox(core:getServerPrefix("server", "Taxi", 2).."Ügyfél: "..color..getPlayerName(msgDatas[3]):gsub("_", " ").." #ffffff| Helyszín: "..color..msgDatas[2].."#ffffff.", 255, 255, 255, true)
        elseif msgType == 2 then
            outputChatBox(core:getServerPrefix("server", "Taxi", 2).."Visszamondták a(z) "..color..msgDatas[1].." #ffffffszámú hívást!", 255, 255, 255, true) 
            
            if msgDatas[2][5] then 
                if msgDatas[2][5] == localPlayer then
                    outputChatBox(core:getServerPrefix("red-dark", "Taxi", 2).."Visszamondták azt a hívást ahova tartottál!", 255, 255, 255, true) 
                    infobox:outputInfoBox("Visszamondták azt a hívást ahova tartottál!", "warning")
                    destroyTaxiElements()
                end 
            end
        elseif msgType == 3 then 
            outputChatBox(core:getServerPrefix("server", "Taxi", 2)..color..getPlayerName(msgDatas[1]):gsub("_", " ").." #ffffffelfogadta a(z) "..color..msgDatas[2].."#ffffff számú hívást.", 255, 255, 255, true) 
            
            if msgDatas[1] == localPlayer then 
                setElementData(localPlayer, "taxi:activefuvar", msgDatas[2])
                utasblip = createBlip(msgDatas[3][1][1], msgDatas[3][1][2], msgDatas[3][1][3], 6)
                utasmarker = createMarker(msgDatas[3][1][1], msgDatas[3][1][2], msgDatas[3][1][3], "checkpoint", 4.0, r, g, b)
                setElementData(utasmarker, "taxi:call:id", {msgDatas[2], msgDatas[3][3]})
            end
        elseif msgType == 4 then 
            outputChatBox(core:getServerPrefix("server", "Taxi", 2)..color..getPlayerName(msgDatas[2]):gsub("_", " ").." #ffffffmegérkezett a(z) "..color..msgDatas[1].."#ffffff számú hívásra.", 255, 255, 255, true) 
        end
    end
end)

setElementData(localPlayer, "taxi:activefuvar", 0)
addEventHandler("onClientMarkerHit", resourceRoot, function(player, mdim)
    if player == localPlayer and mdim then 
        if source == utasmarker then 
            local fuvarid = getElementData(source, "taxi:call:id")
            destroyTaxiElements()
            triggerServerEvent("factionScripts > taxi > sendArriveMessage", resourceRoot, fuvarid)
            setElementData(localPlayer, "taxi:activefuvar", 0)
        end
    end
end)

function destroyTaxiElements()
    if isElement(utasblip) then 
        destroyElement(utasblip) 
    end

    if isElement(utasmarker) then 
        destroyElement(utasmarker) 
    end
end