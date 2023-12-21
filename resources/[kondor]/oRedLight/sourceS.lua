addEventHandler("onResourceStart", resourceRoot, function()
    for k, v in pairs(redLightsCols) do
        redLightsCol = createColCuboid(redLightsCols[k][1],redLightsCols[k][2],redLightsCols[k][3],redLightsCols[k][4],redLightsCols[k][5],redLightsCols[k][6])
        setElementData(redLightsCol,"redlihgtcol",true)
        setElementData(redLightsCol,"redlihgtcol_place",redLightsCols[k][7])
    end

    for k, v in pairs(getElementsByType("player")) do
            setElementData(v,"inRedlightcol",false)
            setElementData(v,"canpenalty",false)
    end

    setTrafficLightState("auto")

end)

function enterRedlightCol (thePlayer, matchingDimension)
    if getElementType (thePlayer) == "player" then
        if isPlayerInVehicle(thePlayer) then
            if getElementData(source,"redlihgtcol") then
                setElementData(thePlayer,"inRedlightcol",true)
            end
        end
    end
end
addEventHandler ("onColShapeHit", resourceRoot, enterRedlightCol)

function leaveRedlightCol (thePlayer, matchingDimension)
    if getElementType (thePlayer) == "player" then
        if getElementData(thePlayer,"inRedlightcol") then
            if isPlayerInVehicle(thePlayer) then
                local theVehicle = getPedOccupiedVehicle (thePlayer)
                if not getVehicleSirensOn(theVehicle) then
                    if getElementData(source,"redlihgtcol") then
                        if getElementData(source,"redlihgtcol_place") == "E" or getElementData(source,"redlihgtcol_place") == "W" then
                            if getTrafficLightState() == 0 or getTrafficLightState() == 1 or getTrafficLightState() == 2 then
                                if not getElementData(thePlayer,"canpenalty") then
                                    if getPedOccupiedVehicleSeat(thePlayer) == 0 then
                                        outputChatBox(core:getServerPrefix("red-dark", "Közlekedési Lámpa", 3).."Áthajtottál egy piros lámpán, büntetésed:#cf2935 "..penalty.."$", thePlayer, 255, 255, 255, true)
                                        setElementData(thePlayer,"char:money",getElementData(thePlayer,"char:money")-penalty)
                                        setElementData(thePlayer,"canpenalty",true)
                                        setElementData(thePlayer,"inRedlightcol",false)
                                        setTimer ( function()
                                            setElementData(thePlayer,"canpenalty",false)
                                        end, 10000, 1 )
                                    end
                                end
                            end
                        elseif getElementData(source,"redlihgtcol_place") == "N" or getElementData(source,"redlihgtcol_place") == "S" then
                            if getTrafficLightState() == 2 or getTrafficLightState() == 3 or getTrafficLightState() == 4 then
                                if not getElementData(thePlayer,"canpenalty") then
                                    if getPedOccupiedVehicleSeat(thePlayer) == 0 then
                                        outputChatBox(core:getServerPrefix("red-dark", "Közlekedési Lámpa", 3).."Áthajtottál egy piros lámpán, büntetésed:#cf2935 "..penalty.."$", thePlayer, 255, 255, 255, true)
                                        setElementData(thePlayer,"char:money",getElementData(thePlayer,"char:money")-penalty)
                                        setElementData(thePlayer,"canpenalty",true)
                                        setElementData(thePlayer,"inRedlightcol",false)
                                        setTimer ( function()
                                            setElementData(thePlayer,"canpenalty",false)
                                        end, 10000, 1 )
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
addEventHandler ("onColShapeLeave", resourceRoot, leaveRedlightCol)
