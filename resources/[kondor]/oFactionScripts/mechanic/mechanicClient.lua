local progressBarAnimType = "open"
local progressBarAnimTick = getTickCount()
local progressBarText = ""
local progressTime = 0
local tick = getTickCount()

local inWork = false

local mechanicCol = createColSphere(1745.4721679688, -2039.2677001953, 13.9296875, 60)

local sounds = {}

local selectedVehicleLift = nil
local selectedDoorOpener = nil

addEventHandler("onClientElementDataChange", root, function(key, old, new)
    if key == "inMechanicWork" then 
        if new then
            local x, y, z = getElementPosition(source)
            sounds[source] = playSound3D("files/wrench.wav", x, y, z, true) 
            setSoundMaxDistance(sounds[source], 10)
            setSoundVolume(sounds[source], 2)
        else
            if isElement(sounds[source]) then 
                destroyElement(sounds[source])
                sounds[source] = false
            end
        end
    end
end)

local fixNeededComps = 0
addEventHandler("onClientRender", root, function()
    if getElementData(localPlayer, "char:duty:faction") == mechanicFactionID then 
        exports.o3DElements:render3DZone(1805.0140380859,-2037.4639892578,13, 3, 2.4, 235, 74, 42, 200, 10, 4, true)
        if isElementWithinColShape(localPlayer, mechanicCol) then 
            local veh = getNearestVehicle(localPlayer, 4)
            if veh then 
                if not (veh == getPedOccupiedVehicle(localPlayer)) then 
                    local liftLevel = getElementData(veh, "vehicle:mechanicLiftLevel") or 0

                    fixNeededComps = 0

                    for k2, v2 in pairs(getVehicleComponents(veh)) do 
                        local componentAllowed = false
                        local componentIndex = 0
                        for k3, v3 in ipairs(vehicleMechanicComponents) do 
                            if v3.gtaName == k2 then 
                                if v3.componentVisible then 
                                    componentAllowed = true 
                                    componentIndex = k3
                                end
                                break
                            end
                        end

                        if componentAllowed then 
                            if getComponentState(veh, componentIndex) then 
                                fixNeededComps = fixNeededComps + 1

                                local x, y, z = getVehicleComponentPosition(veh, k2, "world")

                                local renderX, renderY = getScreenFromWorldPosition(x, y, z)
                                if renderX and renderY then 
                                    local text = vehicleMechanicComponents[componentIndex].name or "nan"
                                    local width = dxGetTextWidth(text, 0.8/myX*sx, fonts["condensed-12"]) + sx*0.02

                                    if vehicleMechanicComponents[componentIndex].liftLevel == liftLevel then
                                        if core:isInSlot(renderX-width/2+2/myX*sx, renderY+2/myY*sy, sx*0.05-4/myX*sx, sy*0.03-4/myY*sy) then 
                                            core:dxDrawShadowedText(text, renderX-width/2+2/myX*sx, renderY+2/myY*sy, renderX-width/2+2/myX*sx+width-4/myX*sx, renderY+2/myY*sy+sy*0.03-4/myY*sy, tocolor(r, g, b, 255), tocolor(0, 0, 0, 255), 0.8/myX*sx, fonts["condensed-12"], "center", "center")
                                        else
                                            core:dxDrawShadowedText(text, renderX-width/2+2/myX*sx, renderY+2/myY*sy, renderX-width/2+2/myX*sx+width-4/myX*sx, renderY+2/myY*sy+sy*0.03-4/myY*sy, tocolor(255, 255, 255, 255), tocolor(0, 0, 0, 255), 0.8/myX*sx, fonts["condensed-12"], "center", "center")
                                        end
                                    end
                                end
                            end
                        end
                    end

                    --print(fixNeededComps)

                    if not isElement(selectedVehicleLift) then 
                        if getElementHealth(veh) < 990 and liftLevel == 0 then 
                            dxDrawRectangle(sx*0.895, sy*0.5-sy*0.02, sx*0.1, sy*0.04, tocolor(35, 35, 35, 255))
                            dxDrawRectangle(sx*0.895+2/myX*sx, sy*0.5-sy*0.02+2/myY*sy, sx*0.1-4/myX*sx, sy*0.04-4/myY*sy, tocolor(40, 40, 40, 255))

                            --if fixNeededComps then 
                                if core:isInSlot(sx*0.895+2/myX*sx, sy*0.5-sy*0.02+2/myY*sy, sx*0.1-4/myX*sx, sy*0.04-4/myY*sy) then 
                                    dxDrawText("Motor szerelése", sx*0.895+2/myX*sx, sy*0.5-sy*0.02+2/myY*sy, sx*0.895+2/myX*sx+sx*0.1-4/myX*sx, sy*0.5-sy*0.02+2/myY*sy+sy*0.025-4/myY*sy, tocolor(r, g, b, 255), 0.9/myX*sx, fonts["condensed-10"], "center", "center")
                                else
                                    dxDrawText("Motor szerelése", sx*0.895+2/myX*sx, sy*0.5-sy*0.02+2/myY*sy, sx*0.895+2/myX*sx+sx*0.1-4/myX*sx, sy*0.5-sy*0.02+2/myY*sy+sy*0.025-4/myY*sy, tocolor(220, 220, 220, 255), 0.9/myX*sx, fonts["condensed-10"], "center", "center")
                                end
                                dxDrawText("Állapota: "..math.floor(getElementHealth(veh)/10).."%", sx*0.895+2/myX*sx, sy*0.5-sy*0.02+2/myY*sy, sx*0.895+2/myX*sx+sx*0.1-4/myX*sx, sy*0.5-sy*0.02+2/myY*sy+sy*0.06-4/myY*sy, tocolor(220, 220, 220, 255), 0.8/myX*sx, fonts["condensed-10"], "center", "center")
                            --else
                            --   dxDrawText("Motor szerelése", sx*0.895+2/myX*sx, sy*0.5-sy*0.02+2/myY*sy, sx*0.895+2/myX*sx+sx*0.1-4/myX*sx, sy*0.5-sy*0.02+2/myY*sy+sy*0.025-4/myY*sy, tocolor(220, 220, 220, 100), 0.9/myX*sx, fonts["condensed-10"], "center", "center")
                            --   dxDrawText("Állapota: "..math.floor(getElementHealth(veh)/10).."%", sx*0.895+2/myX*sx, sy*0.5-sy*0.02+2/myY*sy, sx*0.895+2/myX*sx+sx*0.1-4/myX*sx, sy*0.5-sy*0.02+2/myY*sy+sy*0.06-4/myY*sy, tocolor(220, 220, 220, 100), 0.8/myX*sx, fonts["condensed-10"], "center", "center")
                            --end

                        end

                        if not (getElementData(veh, "veh:lastFuelType") == getElementData(veh, "veh:fuelType")) then 
                            if liftLevel == 2 then
                                dxDrawRectangle(sx*0.895, sy*0.5-sy*0.02 + sy*0.05, sx*0.1, sy*0.04, tocolor(35, 35, 35, 255))
                                dxDrawRectangle(sx*0.895+2/myX*sx, sy*0.5-sy*0.02+2/myY*sy + sy*0.05, sx*0.1-4/myX*sx, sy*0.04-4/myY*sy, tocolor(40, 40, 40, 255))

                                if core:isInSlot(sx*0.895+2/myX*sx, sy*0.5-sy*0.02+2/myY*sy + sy*0.05, sx*0.1-4/myX*sx, sy*0.04-4/myY*sy) then 
                                    dxDrawText("Üzemanyag leengedése", sx*0.895+2/myX*sx, sy*0.5-sy*0.02+2/myY*sy + sy*0.05, sx*0.895+2/myX*sx+sx*0.1-4/myX*sx, sy*0.5-sy*0.02+2/myY*sy+sy*0.04-4/myY*sy+ sy*0.05, tocolor(r, g, b, 255), 0.9/myX*sx, fonts["condensed-10"], "center", "center")
                                else
                                    dxDrawText("Üzemanyag leengedése", sx*0.895+2/myX*sx, sy*0.5-sy*0.02+2/myY*sy + sy*0.05, sx*0.895+2/myX*sx+sx*0.1-4/myX*sx, sy*0.5-sy*0.02+2/myY*sy+sy*0.04-4/myY*sy+ sy*0.05, tocolor(220, 220, 220, 255), 0.9/myX*sx, fonts["condensed-10"], "center", "center")
                                end
                            end
                        end


                        if getVehicleLightState(veh, 0) == 1 or getVehicleLightState(veh, 1) == 1 or getVehicleLightState(veh, 2) == 1 or getVehicleLightState(veh, 3) == 1 then
                            dxDrawRectangle(sx*0.895, sy*0.5-sy*0.065, sx*0.1, sy*0.04, tocolor(35, 35, 35, 255))
                            dxDrawRectangle(sx*0.895+2/myX*sx, sy*0.5-sy*0.065+2/myY*sy, sx*0.1-4/myX*sx, sy*0.04-4/myY*sy, tocolor(40, 40, 40, 255))
                            if core:isInSlot(sx*0.895, sy*0.5-sy*0.065, sx*0.1, sy*0.04) then 
                                dxDrawText("Lámpa szerelése", sx*0.895, sy*0.5-sy*0.065, sx*0.895+sx*0.1, sy*0.5-sy*0.065+sy*0.04, tocolor(r, g, b, 255), 0.9/myX*sx, fonts["condensed-10"], "center", "center")
                            else
                                dxDrawText("Lámpa szerelése", sx*0.895, sy*0.5-sy*0.065, sx*0.895+sx*0.1, sy*0.5-sy*0.065+sy*0.04, tocolor(220, 220, 220, 255), 0.9/myX*sx, fonts["condensed-10"], "center", "center")
                            end
                        end
                    end
                end
            end
        end

        if isElement(selectedVehicleLift) then 
            core:drawWindow(sx*0.89, sy*0.45, sx*0.1, sy*0.14, "Emelő", 1)
            dxDrawRectangle(sx*0.895, sy*0.48, sx*0.09, sy*0.04, tocolor(30, 30, 30, 255))
            dxDrawText(getElementData(selectedVehicleLift, "mechanic:vehicleLiftLevel"), sx*0.895, sy*0.48, sx*0.895+sx*0.09, sy*0.48+sy*0.04, tocolor(255, 255, 255, 150), 0.9/myX*sx, fonts["condensed-10"], "center", "center")

            if getElementData(selectedVehicleLift, "mechanic:liftInMove") then 
                core:dxDrawButton(sx*0.895, sy*0.527, sx*0.09, sy*0.025, r, g, b, 50, "FEL", tocolor(255, 255, 255, 100), 0.9/myX*sx, fonts["condensed-10"], false)
                core:dxDrawButton(sx*0.895, sy*0.56, sx*0.09, sy*0.025, r, g, b, 50, "LE", tocolor(255, 255, 255, 100), 0.9/myX*sx, fonts["condensed-10"], false)
            else
                core:dxDrawButton(sx*0.895, sy*0.527, sx*0.09, sy*0.025, r, g, b, 200, "FEL", tocolor(255, 255, 255, 255), 0.9/myX*sx, fonts["condensed-10"], false)
                core:dxDrawButton(sx*0.895, sy*0.56, sx*0.09, sy*0.025, r, g, b, 200, "LE", tocolor(255, 255, 255, 255), 0.9/myX*sx, fonts["condensed-10"], false)
            end
        end

        if isElement(selectedDoorOpener) then 
            core:drawWindow(sx*0.89, sy*0.45, sx*0.1, sy*0.09, "Garázs ajtó", 1)
           
            core:dxDrawButton(sx*0.895, sy*0.475, sx*0.09, sy*0.025, r, g, b, 200, "NYITÁS", tocolor(255, 255, 255, 255), 0.9/myX*sx, fonts["condensed-10"], false)
            core:dxDrawButton(sx*0.895, sy*0.505, sx*0.09, sy*0.025, r, g, b, 200, "ZÁRÁS", tocolor(255, 255, 255, 255), 0.9/myX*sx, fonts["condensed-10"], false)
        end
    end
end)

local doorButtonPressed = false

local fuelOffMarker = nil

addEventHandler("onClientKey", root, function(key, state)
    if getElementData(localPlayer, "char:duty:faction") == mechanicFactionID then 
        if isElementWithinColShape(localPlayer, mechanicCol) then 
            if key == "mouse1" and state then 
                local veh = getNearestVehicle(localPlayer, 4)
                if veh then 
                    if not veh == getPedOccupiedVehicle(localPlayer) then 
                        local liftLevel = getElementData(veh, "vehicle:mechanicLiftLevel") or 0

                        for k2, v2 in pairs(getVehicleComponents(veh)) do 
                            local componentAllowed = false
                            local componentIndex = 0
                            for k3, v3 in ipairs(vehicleMechanicComponents) do 
                                if v3.gtaName == k2 then 
                                    if v3.componentVisible then 
                                        componentAllowed = true 
                                        componentIndex = k3
                                    end
                                    break
                                end
                            end
                
                            if componentAllowed then 
                                if getComponentState(veh, componentIndex) then 
                                    local x, y, z = getVehicleComponentPosition(veh, k2, "world")
                
                                    local renderX, renderY = getScreenFromWorldPosition(x, y, z)
                                    if renderX and renderY then 
                                        local text = vehicleMechanicComponents[componentIndex].name or "nan"
                                        local width = dxGetTextWidth(text, 0.8/myX*sx, fonts["condensed-12"]) + sx*0.02
                
                                        if core:isInSlot(renderX-width/2+2/myX*sx, renderY+2/myY*sy, sx*0.05-4/myX*sx, sy*0.03-4/myY*sy) then 
                                            if not inWork then 
                                                if not getElementData(veh, "vehInService") then 
                                                    if getElementData(localPlayer, "char:money") >= vehicleMechanicComponents[componentIndex].price then
                                                        local state = getComponentState(veh, componentIndex)
                                                        if state == "fix" then
                                                            inWork = true
                                                            progressTime = math.random(8000, 15000)
                                                            progressBarText = text.." javítása"
                                                            progressBarAnimType = "open"
                                                            tick = getTickCount()
                                                            progressBarAnimTick = getTickCount()
                                                            addEventHandler("onClientRender", root, renderProgressBar)
                                                            triggerServerEvent("factionScripts > mechanic > setAnimation", resourceRoot, "BOMBER", "BOM_Plant", true)
                                                            triggerServerEvent("factionScripts > mechanic > freezeVehicle", resourceRoot, veh, true)
                                                            setTimer(function()
                                                                progressBarAnimType = "close"
                                                                progressBarAnimTick = getTickCount()
                                                                setTimer(function() 
                                                                    
                                                                    triggerServerEvent("factionScripts > mechanic > setAnimation", resourceRoot, "", "", false)
                                                                    triggerServerEvent("factionScripts > mechanic > freezeVehicle", resourceRoot, veh, false)
                                                                    removeEventHandler("onClientRender", root, renderProgressBar) 
                                                                    chat:sendLocalMeAction("megszerelt egy "..text.." elemet.")
                                                                    inWork = false
                                                                end, 250, 1)
                                                                triggerServerEvent("factionScripts > mechanic > installVehComponent", resourceRoot, veh, componentIndex)
                                                            end, progressTime, 1)
                                                        elseif state == "missing" then 
                                                            inWork = true
                                                            progressTime = math.random(1500, 20000)
                                                            progressBarText = text.." szerelése"
                                                            progressBarAnimType = "open"
                                                            tick = getTickCount()
                                                            progressBarAnimTick = getTickCount()
                                                            addEventHandler("onClientRender", root, renderProgressBar)
                                                            triggerServerEvent("factionScripts > mechanic > setAnimation", resourceRoot, "BOMBER", "BOM_Plant", true)
                                                            triggerServerEvent("factionScripts > mechanic > freezeVehicle", resourceRoot, veh, true)
                                                            setTimer(function()
                                                                progressBarAnimType = "close"
                                                                progressBarAnimTick = getTickCount()
                                                                setTimer(function() 
                                                                    --setVehicleComponentVisible(veh, k2, true)
                                                                    triggerServerEvent("factionScripts > mechanic > setAnimation", resourceRoot, "", "", false)
                                                                    triggerServerEvent("factionScripts > mechanic > freezeVehicle", resourceRoot, veh, false)
                                                                    chat:sendLocalMeAction("felszerelt egy "..text.." elemet.")
                                                                    removeEventHandler("onClientRender", root, renderProgressBar) 
                                                                    inWork = false
                                                                end, 250, 1)
                                                                triggerServerEvent("factionScripts > mechanic > installVehComponent", resourceRoot, veh, componentIndex)
                                                            end, progressTime, 1)
                                                        end
                                                    else
                                                        infobox:outputInfoBox("Nincs elegendő pénzed!", "error")
                                                    end
                                                else
                                                    outputChatBox(core:getServerPrefix("red-dark", "Mechanic", 2).."Ezt a járművet éppen szerelik.", 255, 255, 255, true)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        if not isElement(selectedVehicleLift) then 
                            if getElementHealth(veh) < 990 and liftLevel == 0 then 
                                if core:isInSlot(sx*0.895+2/myX*sx, sy*0.5-sy*0.02+2/myY*sy, sx*0.1-4/myX*sx, sy*0.04-4/myY*sy) then 
                                    --if fixNeededComps then 
                                        if not getElementData(veh, "vehInService") then 
                                            inWork = true
                                            progressTime = math.random(6500, 13000)
                                            progressBarText = "Motor javítása"
                                            progressBarAnimType = "open"
                                            tick = getTickCount()
                                            progressBarAnimTick = getTickCount()
                                            addEventHandler("onClientRender", root, renderProgressBar)
                                            triggerServerEvent("factionScripts > mechanic > setAnimation", resourceRoot, "BOMBER", "BOM_Plant", true)
                                            triggerServerEvent("factionScripts > mechanic > freezeVehicle", resourceRoot, veh, true)
                                            setTimer(function()
                                                progressBarAnimType = "close"
                                                progressBarAnimTick = getTickCount()
                                                setTimer(function() 
                                                    --setVehicleComponentVisible(veh, k2, false)
                                                    triggerServerEvent("factionScripts > mechanic > setAnimation", resourceRoot, "", "", false)
                                                    triggerServerEvent("factionScripts > mechanic > freezeVehicle", resourceRoot, veh, false)
                                                    removeEventHandler("onClientRender", root, renderProgressBar) 
                                                    chat:sendLocalMeAction("megjavította a motort.")
                                                    inWork = false
                                                end, 250, 1)
                                                triggerServerEvent("factionScripts > mechanic > fixVehEngine", resourceRoot, veh)
                                            end, progressTime, 1)
                                        else
                                            outputChatBox(core:getServerPrefix("red-dark", "Mechanic", 2).."Ezt a járművet éppen szerelik.", 255, 255, 255, true)
                                        end
                                    --else
                                    --    outputChatBox(core:getServerPrefix("red-dark", "Mechanic", 2).."Előbb szereld meg a jármű további részeit.", 255, 255, 255, true)
                                    --end
                                end
                            end

                            if not (getElementData(veh, "veh:lastFuelType") == getElementData(veh, "veh:fuelType")) then 
                                if liftLevel == 2 then
                                    if core:isInSlot(sx*0.895+2/myX*sx, sy*0.5-sy*0.02+2/myY*sy + sy*0.05, sx*0.1-4/myX*sx, sy*0.04-4/myY*sy) then 
                                        if not getElementData(veh, "vehInService") then 
                                            if not isElement(fuelOffMarker) then
                                                inWork = true

                                                local x, y, z = getElementPosition(veh)
                                                fuelOffMarker = createMarker(x, y, getGroundPosition(x, y, z) - 2.5, "cylinder", 1.0, r, g, b, 50)
                                            else
                                            end
                                            --[[progressTime = math.random(6500, 13000)
                                            progressBarText = "Üzemanyag leengedése"
                                            progressBarAnimType = "open"
                                            tick = getTickCount()
                                            progressBarAnimTick = getTickCount()
                                            addEventHandler("onClientRender", root, renderProgressBar)
                                            triggerServerEvent("factionScripts > mechanic > setAnimation", resourceRoot, "BOMBER", "BOM_Plant", true)
                                            triggerServerEvent("factionScripts > mechanic > freezeVehicle", resourceRoot, veh, true)
                                            setTimer(function()
                                                progressBarAnimType = "close"
                                                progressBarAnimTick = getTickCount()
                                                setTimer(function() 
                                                    --setVehicleComponentVisible(veh, k2, false)
                                                    triggerServerEvent("factionScripts > mechanic > setAnimation", resourceRoot, "", "", false)
                                                    triggerServerEvent("factionScripts > mechanic > freezeVehicle", resourceRoot, veh, false)
                                                    removeEventHandler("onClientRender", root, renderProgressBar) 
                                                    --chat:sendLocalMeAction("leengedte a jármű üzemanyagát.")

                                                    setElementData(veh, "veh:lastFuelType", getElementData(veh, "veh:fuelType"))
                                                    setElementData(veh, "veh:fuel", 0)
                                                    
                                                    inWork = false
                                                end, 250, 1)
                                            end, progressTime, 1)]]
                                        else
                                            outputChatBox(core:getServerPrefix("red-dark", "Mechanic", 2).."Ezt a járművet éppen szerelik.", 255, 255, 255, true)
                                        end
                                    end
                                end
                            end
                      

                            --if buggedVehicles[getElementModel(veh)] and liftLevel == 0 then
                                if core:isInSlot(sx*0.895, sy*0.5-sy*0.065, sx*0.1, sy*0.04) then 
                                    if not getElementData(veh, "vehInService") then 
                                        if fixNeededComps == 0 then
                                            --if getElementHealth(veh) >= 999 then
                                                if getElementData(localPlayer, "char:money") >= 250 then
                                                    inWork = true
                                                    progressTime = math.random(6500, 13000)
                                                    progressBarText = "Lámpa kicserélése"
                                                    progressBarAnimType = "open"
                                                    tick = getTickCount()
                                                    progressBarAnimTick = getTickCount()
                                                    addEventHandler("onClientRender", root, renderProgressBar)
                                                    triggerServerEvent("factionScripts > mechanic > setAnimation", resourceRoot, "BOMBER", "BOM_Plant", true)
                                                    triggerServerEvent("factionScripts > mechanic > freezeVehicle", resourceRoot, veh, true)
                                                    setTimer(function()
                                                        progressBarAnimType = "close"
                                                        progressBarAnimTick = getTickCount()
                                                        setTimer(function() 
                                                            triggerServerEvent("factionScripts > mechanic > setAnimation", resourceRoot, "", "", false)
                                                            triggerServerEvent("factionScripts > mechanic > freezeVehicle", resourceRoot, veh, false)
                                                            removeEventHandler("onClientRender", root, renderProgressBar) 
                                                            chat:sendLocalMeAction("megjavította a jármű lámpáját.")
                                                            
                                                            inWork = false
                                                        end, 250, 1)
                                                        
                                                        triggerServerEvent("factionScripts > mechanic > lampfixVehicle", resourceRoot, veh)
                                                    end, progressTime, 1)

                                                    setElementData(localPlayer, "char:money", getElementData(localPlayer, "char:money") - 250)
                                                else
                                                    outputChatBox(core:getServerPrefix("red-dark", "Mechanic", 2).."Nincs elég pénzed a javításhoz. "..color.."(250$)", 255, 255, 255, true)
                                                end
                                            --else
                                                --outputChatBox(core:getServerPrefix("red-dark", "Mechanic", 2).."Előbb szereld meg a jármű motorját.", 255, 255, 255, true)
                                            --end
                                        else
                                            outputChatBox(core:getServerPrefix("red-dark", "Mechanic", 2).."Előbb szereld meg a jármű egyéb elemeit.", 255, 255, 255, true)
                                        end
                                    else
                                        outputChatBox(core:getServerPrefix("red-dark", "Mechanic", 2).."Ezt a járművet éppen szerelik.", 255, 255, 255, true)
                                    end
                                end
                            --end
                        end
                    end
                end
            end
        end

        if key == "mouse1" and state then 
            if isElement(selectedVehicleLift) then 
                if not getElementData(selectedVehicleLift, "mechanic:liftInMove") then 
                    if core:isInSlot(sx*0.895, sy*0.527, sx*0.09, sy*0.025) then -- fel
                        if getElementData(selectedVehicleLift, "mechanic:vehicleLiftLevel") < 2 then
                            triggerServerEvent("factionScripts > mechanic > lift > move", resourceRoot, selectedVehicleLift, 1.1, 1)
                            --chat:sendLocalMeAction("megnyom egy gombot az emelő oldalán.")
                        end
                    end

                    if core:isInSlot(sx*0.895, sy*0.56, sx*0.09, sy*0.025) then -- le 
                        if getElementData(selectedVehicleLift, "mechanic:vehicleLiftLevel") > 0 then

                            local checkCol = getElementData(selectedVehicleLift, "mechanic:vehicleLiftDownCol")

                            if (#getElementsWithinColShape(checkCol) - 5) <= 0 then
                                triggerServerEvent("factionScripts > mechanic > lift > move", resourceRoot, selectedVehicleLift, -1.1, -1)
                                --chat:sendLocalMeAction("megnyom egy gombot az emelő oldalán.")
                            else
                                outputChatBox(core:getServerPrefix("red-dark", "Emelő", 2).."Nem engedheted le az emelőt mivel van valami alatta.", 255, 255, 255, true)
                            end
                        end
                    end
                end
            end

            if isElement(selectedDoorOpener) then 
                if core:isInSlot(sx*0.895, sy*0.475, sx*0.09, sy*0.025) then 
                    if not getElementData(selectedDoorOpener, "factionScripts:mechanic:doorOpener:inUse") then 
                        doorButtonPressed = true
                        triggerServerEvent("factionScripts > mechanic > openDoor", resourceRoot, "open")
                    end
                end

                if core:isInSlot(sx*0.895, sy*0.505, sx*0.09, sy*0.025) then 
                    if not getElementData(selectedDoorOpener, "factionScripts:mechanic:doorOpener:inUse") then 
                        doorButtonPressed = true
                        triggerServerEvent("factionScripts > mechanic > openDoor", resourceRoot, "close")
                    end
                end
            end
        end

        if key == "mouse1" and not state then 
            if isElement(selectedDoorOpener) then 
                doorButtonPressed = false
                triggerServerEvent("factionScripts > mechanic > stopMoving", resourceRoot)
            end
        end
    end
end)

local fluids = {}
function renderFluids()
    for k, v in ipairs(fluids) do 
        exports.o3DElements:renderLiquid(unpack(v))
    end
end
addEventHandler("onClientRender", root, renderFluids)

addEventHandler("onClientMarkerHit", resourceRoot, function(player, mdim)
    if player == localPlayer then 
        if mdim and source == fuelOffMarker then 
            if getElementData(localPlayer, "dollyUsedByPlayer") then 
                local dolly = getElementData(localPlayer, "dollyUsedByPlayer")
                detachElements(dolly)
                local mx, my, mz = getElementPosition(source)
                setElementPosition(dolly, mx, my, mz + 0.5)
                setElementRotation(dolly, 0, 0, 0)

                mx, my, mz = getElementPosition(getElementData(dolly, "dolly:drum"))
                table.insert(fluids, {mx, my, mz+1.5, 163, 105, 39})
                destroyElement(source)
            end
        end
    end
end)

addEventHandler("onClientColShapeHit", resourceRoot, function(element, mdim)
    if element == localPlayer and mdim then 
        if getElementData(source, "mechanic:vehicleLift") then 
            selectedVehicleLift = source
        elseif getElementData(source, "factionScripts:mechanic:doorOpener") then 
            selectedDoorOpener = source
        end
    end
end)

addEventHandler("onClientColShapeLeave", resourceRoot, function(element, mdim)
    if element == localPlayer and mdim then 
        if getElementData(source, "mechanic:vehicleLift") then 
            selectedVehicleLift = nil

        elseif getElementData(source, "factionScripts:mechanic:doorOpener") then 
            selectedDoorOpener = nil
        end
    else 
        if getElementType(element) == "vehicle" then 
            veh = element

            if veh then 
                if getElementData(veh,"oilRefuelCol") then 
                    setElementData(veh,"oilRefuelCol",false)
                end 
            end
        end 
    end
end)

function renderProgressBar()
    local alpha
    
    if progressBarAnimType == "open" then 
        alpha = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount() - progressBarAnimTick)/250, "Linear")
    else
        alpha = interpolateBetween(1, 0, 0, 0, 0, 0, (getTickCount() - progressBarAnimTick)/250, "Linear")
    end

    local line_height = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount() - tick)/progressTime, "Linear")

    dxDrawRectangle(sx*0.4, sy*0.85, sx*0.2, sy*0.025, tocolor(40, 40, 40, 255*alpha))
    dxDrawRectangle(sx*0.401, sy*0.852, (sx*0.2-sx*0.002), sy*0.025-sy*0.004, tocolor(35, 35, 35, 255*alpha))
    dxDrawRectangle(sx*0.401, sy*0.852, (sx*0.2-sx*0.002)*line_height, sy*0.025-sy*0.004, tocolor(r, g, b, 255*alpha))

    dxDrawText(progressBarText, sx*0.4, sy*0.85, sx*0.4+sx*0.2, sy*0.85+sy*0.025, tocolor(35, 35, 35, 255*alpha), 0.8/myX*sx, fonts["condensed-10"], "center", "center", false, false, false, true)
end

function getComponentState(vehicle, componentIndex)
    if vehicleMechanicComponents[componentIndex].panelID then 
        if getVehiclePanelState(vehicle, vehicleMechanicComponents[componentIndex].panelID) > 0 then 
            if getVehiclePanelState(vehicle, vehicleMechanicComponents[componentIndex].panelID) == 3 then 
                return "missing"
            else
                return "fix"
            end
        else
            return false
        end
    elseif vehicleMechanicComponents[componentIndex].doorID then 
        if getVehicleDoorState(vehicle, vehicleMechanicComponents[componentIndex].doorID) >= 2 then 
            if getVehicleDoorState(vehicle, vehicleMechanicComponents[componentIndex].doorID) == 4 then 
                return "missing"
            else
                return "fix"
            end
        else
            return false
        end
    elseif vehicleMechanicComponents[componentIndex].wheelID then 
        local wheelStates = {getVehicleWheelStates(vehicle)}

        if wheelStates[vehicleMechanicComponents[componentIndex].wheelID] == 1 then 
            return "missing"
        elseif wheelStates[vehicleMechanicComponents[componentIndex].wheelID] == 2 then 
            return "missing"
        else
            return false
        end
    else
        return false
    end
end

addEvent("factionScripts > mechanic > playVehLiftSound", true)
addEventHandler("factionScripts > mechanic > playVehLiftSound", root, function(lift)
    if isElementStreamedIn(lift) then 
        local x, y, z = getElementPosition(lift)
        local sound = playSound3D("files/vehlift.mp3", x, y, z, false)
        setSoundMaxDistance(sound, 15)
        setTimer(function()
            if isElement(sound) then destroyElement(sound) end
        end, 10000, 1)
    end
end)

function getNearestVehicle(player,distance)
	local tempTable = {}
	local lastMinDis = distance-0.0001
	local nearestVeh = false
	local px,py,pz = getElementPosition(player)
	local pint = getElementInterior(player)
	local pdim = getElementDimension(player)

	for _,v in pairs(getElementsByType("vehicle")) do
		local vint,vdim = getElementInterior(v),getElementDimension(v)
		if vint == pint and vdim == pdim then
			local vx,vy,vz = getElementPosition(v)
			local dis = getDistanceBetweenPoints3D(px,py,pz,vx,vy,vz)
			if dis < distance then
				if dis < lastMinDis then 
					lastMinDis = dis
					nearestVeh = v
				end
			end
		end
	end
	
	return nearestVeh
end

-- dolly 
function attachDollyToPlayer(player, dolly)
    triggerServerEvent("factionScripts > mechanic > pickUpDolly", resourceRoot, player, dolly)
end

function deattachDollyToPlayer(player, dolly)
    triggerServerEvent("factionScripts > mechanic > takedownDolly", resourceRoot, player, dolly)
end

--oil drum

function pickupDrum(player, drum)
    triggerServerEvent("factionScripts > mechanic > pickUpDrum", resourceRoot, player, drum)
end

function takeDownDrum(player, drum)
    triggerServerEvent("factionScripts > mechanic > takeDownDrum", resourceRoot, player, drum)
end

--[[function oilMarkerHit(hp,md)
    if (md) then 
        for k,v in ipairs(getElementsByType("marker")) do 
            if getElementData(v,"isFuelMarker") then 
                --triggerServerEvent("factionScripts > mechanic > oilMarker", resourceRoot, v, player)
                outputChatBox("oil")
            end 
        end 
    end
end  
addEventHandler ( "onClientMarkerHit", getRootElement(), oilMarkerHit )]]
--fuel drum 

function pickupFuelDrum(player, drum)
    triggerServerEvent("factionScripts > mechanic > pickUpFuelDrum", resourceRoot, player, drum)
end

function takeDownFuelDrum(player, drum)
    triggerServerEvent("factionScripts > mechanic > takeDownFuelDrum", resourceRoot, player, drum)
end

local sx, sy = guiGetScreenSize()

local value = {}

function createEffectClient(owner,effect,task,x,y,z,rx,ry,rz,distance,sound,type)

       if task == "create" then 
            if not x then return end 
            if not y then return end
            if not z then return end
            if not rx then return end
            if not ry then return end
            if not rz then return end
            if not distance then return end
            if not sound then return end
                if tostring(type) == "oil" then 
                    value[owner] = createEffect(effect,x,y,z,rx,ry,rz,distance,sound)
                elseif tostring(type) == "fuel" then 
                    value[owner] = createEffect(effect,x,y,z,rx,ry,rz,distance,sound)
                end 
       elseif task == "delete" then 
           destroyElement(value[owner])
       end 
    
end 
addEvent("createEffectClient",true)
addEventHandler ( "createEffectClient", root, createEffectClient )



function drumLevelDraw()
    
    if getElementData(localPlayer, "char:duty:faction") == getMechanicFactionID() then 
        zone = getZoneName(getElementPosition(localPlayer))
        if isElementWithinColShape(localPlayer,mechanicCol) then  
            for k,v in pairs(getElementsByType("object")) do 

                if isElementStreamedIn(v) then 

                    if getElementModel(v) == 935 then  -- olaj

                        local cx, cy, cz = getElementPosition(getCamera())
                        local px, py, pz = getElementPosition(v)
                        pz = pz + 0.5
                        local dis = getDistanceBetweenPoints3D(cx, cy, cz, px, py, pz + 10)
                        if dis < 10 then
                            local px, py = getScreenFromWorldPosition(px, py, pz + 0.3)
                            if px and py then
                                local size, imgSize, o = interpolateBetween(1, 96, 0, 0.5, 24, -10, dis / 30, "Linear");
                                local alpha = interpolateBetween(255, 0, 0, 0, 0, 0, dis / 40, "InQuad");
                                py = math.floor(py + o);
                                px = math.floor(px);
                                text = getElementData(v,"drum:oilLevel")
                                tNumber = getElementData(v,"drum:oilLevel")
                                text = text.."%"
                                textWidth = dxGetTextWidth(text, 0.8/myX*sx, fonts["condensed-12"])
                                dxDrawRectangle(px - sx*0.007,py,sx*0.031-textWidth/2,sy*0.0156,tocolor(0,0,0,150))
                                dxDrawRectangle(px - sx*0.005,py + sy*0.003,sx*0.0171*tNumber/100,sy*0.01,tocolor(r,g,b,200))
                                dxDrawText(text,(px -textWidth/2) + sx*0.0075,py + sy*0.0016,_,_,tocolor(255,255,255,255),0.00035*sx,fonts["condensed-12"])
                            end 
                        end 
                    elseif getElementModel(v) == 3632 then --üzemanyag
                        local cx, cy, cz = getElementPosition(getCamera())
                        local px, py, pz = getElementPosition(v)
                        pz = pz + 0.5
                        local dis = getDistanceBetweenPoints3D(cx, cy, cz, px, py, pz + 10)
                        if dis < 10 then
                            local px, py = getScreenFromWorldPosition(px, py, pz + 0.3)
                            if px and py then
                                local size, imgSize, o = interpolateBetween(1, 96, 0, 0.5, 24, -10, dis / 30, "Linear");
                                local alpha = interpolateBetween(255, 0, 0, 0, 0, 0, dis / 40, "InQuad");
                                py = math.floor(py + o);
                                px = math.floor(px);
                                text = getElementData(v,"drum:fuelLevel")
                                tNumber = getElementData(v,"drum:fuelLevel")
                                text = text.."%"
                                textWidth = dxGetTextWidth(text, 0.8/myX*sx, fonts["condensed-12"])
                                dxDrawRectangle(px - sx*0.007,py,sx*0.031-textWidth/2,sy*0.0156,tocolor(0,0,0,150))
                                dxDrawRectangle(px - sx*0.005,py + sy*0.003,sx*0.0171*tNumber/100,sy*0.01,tocolor(r,g,b,200))
                                dxDrawText(text,(px -textWidth/2) + sx*0.0075,py + sy*0.0016,_,_,tocolor(255,255,255,255),0.00035*sx,fonts["condensed-12"])
                            end 
                        end 
                    end 
                end 
            end 
        end
    end 
end 
addEventHandler("onClientRender",root,drumLevelDraw)


--[[function dxDrawTextOnElement(TheElement,text,height,distance,font,...)
	local x, y, z = getElementPosition(TheElement)
	local x2, y2, z2 = getCameraMatrix()
	local distance = distance or 20
	local height = height or 1

	if (isLineOfSightClear(x, y, z+2, x2, y2, z2, ...)) then
		local sx, sy = getScreenFromWorldPosition(x, y, z+height)
		if(sx) and (sy) then
			local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			if(distanceBetweenPoints < distance) then

                core:dxDrawShadowedText(text, sx+2, sy+2, sx, sy, tocolor(255, 255, 255, 255), tocolor(0, 0, 0, 255), 1.2/myX*sx, font, "center", "center")

			end
		end
	end
end]]

addCommandHandler("fixvehbug", function()
    if getElementData(localPlayer, "char:duty:faction") == mechanicFactionID then    
        local veh = getPedOccupiedVehicle(localPlayer)
        local vehID = getElementModel(veh)
        if veh then 
            if fixBugVehicle[vehID] then 
                triggerServerEvent("factionScripts > mechanic > fixVehicleBUG", resourceRoot, veh)
                outputChatBox(core:getServerPrefix("red-dark", "Mechanic", 2).."Sikeresen használtad a #3399FF/fixvehbug #ffffffparancsot!", 255, 255, 255, true)
            else
                outputChatBox(core:getServerPrefix("red-dark", "Mechanic", 2).."Erre a járműre nem alkalmazható a parancs!", 255, 255, 255, true)
            end
        end
    end
end)