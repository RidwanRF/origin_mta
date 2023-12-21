local tick = getTickCount()

local hasSignal = false 
local noSignalSound = false
local selectedCamera = 1
local changeTimer = false

function renderCCTVDesign()
    if not hasSignal then 
       dxDrawImage(0, 0, sx, sy, "files/nosignal.jpg")
    end

    dxDrawImage(0, 0, sx, sy, "files/camera.png")
    dxDrawImage(sx*0.845, sy*0.082, 42/myX*sx, 42/myY*sy, "files/circle.png", 0, 0, 0, tocolor(235, 52, 52, 255 * interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount() - tick) / 1000, "CosineCurve")))

    dxDrawRectangle(sx*0.86, sy*0.87, sx*0.03, sy*0.05, tocolor(255, 0, 0))
    dxDrawText(core:getDate("monthday"), sx*0.86, sy*0.87, sx*0.86 + sx*0.03, sy*0.87 + sy*0.05, tocolor(255, 255, 255), 1, font:getFont("roboto-light", 30/myX*sx), "center", "center")
   dxDrawText(core:getDate("month"), sx*0.91, sy*0.87, sx*0.91 + sx*0.03, sy*0.87 + sy*0.05, tocolor(255, 255, 255), 1, font:getFont("roboto-light", 30/myX*sx), "center", "center")


    if not hasSignal then 
       dxDrawText("No signal...", sx*0.07, sy*0.082, sx*0.07 + sx*0.03, sy*0.082 + sy*0.05, tocolor(255, 255, 255), 1, font:getFont("roboto-light", 30/myX*sx), "left", "center")
    else
        dxDrawText(cctvs[selectedCamera].name, sx*0.07, sy*0.082, sx*0.07 + sx*0.03, sy*0.082 + sy*0.05, tocolor(255, 255, 255), 1, font:getFont("roboto-light", 30/myX*sx), "left", "center")
    end
end

local createdCCTVMarkers = {}

function createCCTVMarkers()
    for k, v in ipairs(cctvMarkers) do 
        local marker = createMarker(v[1], v[2], v[3] - 1.5, "cylinder", 1.2, r, g, b, 100)
        setElementInterior(marker, v[4])
        setElementDimension(marker, v[5])
        createdCCTVMarkers[marker] = true
    end
end
createCCTVMarkers()

function cameraKey(key, state)
    if key == "arrow_r" and state then 
        if not isTimer(changeTimer) then
            if selectedCamera < #cctvs then 
                selectedCamera = selectedCamera + 1
            else
                selectedCamera = 1
            end
            setCCTVPos()
        end
    elseif key == "arrow_l" and state then 
        if not isTimer(changeTimer) then
            if selectedCamera > 1 then 
                selectedCamera = selectedCamera - 1
            else
                selectedCamera = #cctvs
            end
            setCCTVPos()
        end
    elseif key == "backspace" and state then 
        closeCCTV()
        setElementFrozen(localPlayer, false)
    end
end

addEventHandler("onClientRender", root, function()
    for k, v in pairs(createdCCTVMarkers) do 
        if isElementStreamedIn(k) then 
            local distance = core:getDistance(k, localPlayer)
            if distance < 10 then
                local markerX, markerY, markerZ = getElementPosition(k)
                markerZ = markerZ + 1.5
                local x, y = getScreenFromWorldPosition(markerX, markerY, markerZ )
                
                if x and y then 
                    local imageSize = 100 * (1 - distance/10)
                    dxDrawImage(x - imageSize/2, y - imageSize/2, imageSize, imageSize, "files/cctv.png", 0, 0, 0, tocolor(255, 255, 255, 255))
                end
            end
        end
    end
end)

function openCCTV()
    addEventHandler("onClientRender", root, renderCCTVDesign)
    addEventHandler("onClientKey", root, cameraKey)
    showChat(false)
    exports.oInterface:toggleHud(true)

    setCCTVPos()
end

function closeCCTV()
    removeEventHandler("onClientRender", root, renderCCTVDesign)
    removeEventHandler("onClientKey", root, cameraKey)
    showChat(true)
    exports.oInterface:toggleHud(false)
    setCameraTarget(localPlayer, localPlayer)
end

function setCCTVPos()
    hasSignal = false 
    noSignalSound = playSound("files/nosignal.mp3", true)

    setCameraMatrix(cctvs[selectedCamera].camPos.matrix[1], cctvs[selectedCamera].camPos.matrix[2], cctvs[selectedCamera].camPos.matrix[3], cctvs[selectedCamera].camPos.matrix[4], cctvs[selectedCamera].camPos.matrix[5], cctvs[selectedCamera].camPos.matrix[6])

    changeTimer = setTimer(function()
        hasSignal = true
        destroyElement(noSignalSound)
    end, math.random(1000, 2500), 1)
end

addEventHandler("onClientMarkerHit", resourceRoot, function(player, mdim)
    if player == localPlayer and mdim then 
        if createdCCTVMarkers[source] then 
            setElementFrozen(localPlayer, true)
            openCCTV()
        end
    end
end)

local createdCCTVCols = {}

function createCCTVS()
    for k, v in ipairs(cctvs) do 
        local cctvObj = createObject(1622, v.object.pos[1], v.object.pos[2], v.object.pos[3], v.object.rot[1], v.object.rot[2], v.object.rot[3])
        local colShape = createColSphere(v.colShape.pos[1], v.colShape.pos[2], v.colShape.pos[3], 20)
        createdCCTVCols[colShape] = true
        setElementData(colShape, "cctv:name", v.name)
    end
end
addEventHandler("onClientResourceStart", resourceRoot, createCCTVS)

addEventHandler("onClientColShapeHit", getRootElement(), function(player, mdim)
    if mdim and player == localPlayer then 
        if createdCCTVCols[source] then
            if not getPedOccupiedVehicle(localPlayer) then
                local factionID = getElementData(localPlayer, "char:duty:faction") or 0
                
                if factionID > 0 then 
                    if faction:getFactionType(factionID) == 1 then 
                        return
                    end
                end

                for k, v in ipairs(illegalObjectsForCCTV) do 
                    local hasItem = {inventory:hasItem(v)}
                    if hasItem[1] then 
                        triggerServerEvent("factionScripts > cctv > sendMessage", root, core:getServerPrefix("blue-light-2", "CCTV", 2).."Egy személynél illegális fegyverek találhatóak.", core:getServerPrefix("blue-light-2", "CCTV", 2).."Riasztás helye: "..color..getElementData(source, "cctv:name").."#ffffff.")
                        break
                    end
                end
            end
        end
    end
end)

addEvent("factionScripts > cctv > recieveCameraMessage", true)
addEventHandler("factionScripts > cctv > recieveCameraMessage", root, function(msg, msg2, msg3)
    local factionID = getElementData(localPlayer, "char:duty:faction") or 0
    if getElementData(localPlayer, "pd:logs") == 1 then           
        if factionID > 0 then 
            if faction:getFactionType(factionID) == 1 then 
                outputChatBox(msg, 255, 255, 255, true)
                

                if msg2 then 
                    outputChatBox(msg2, 255, 255, 255, true)
                end
            
                if msg3 then 
                    outputChatBox(msg3, 255, 255, 255, true)
                end
            end
        end
    end
end)