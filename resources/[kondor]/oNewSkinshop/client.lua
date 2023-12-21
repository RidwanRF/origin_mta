local sx, sy = guiGetScreenSize()
local myX, myY = 1768, 992
local markerCache = {}

_dxDrawText = dxDrawText
local dxDrawText = function(text, x, y, w, h, ...)
    return _dxDrawText(text, x, y, x + w, y + h, ...)
end

local selectedSkin, selectedType = 1, false 
local tempPed = nil
local startCam = {}
local walkEnabled, rotateEnabled = false, false
local pedPos = {}

local isSelectedPanel = false

-- Fk Skins
local skinTable = skinTableG
local choseSkins = false
local selectedFactionId = 0

function drawTextWithIcon(icon, text, x, y, w, h, color, size, align)
    if align == "left" then 
        dxDrawText(icon, x, y, w, h, color, size, fonts:getFont("fontawesome2", 12/myX*sx), align, "center")
        dxDrawText(text, x + dxGetTextWidth(icon, size, fonts:getFont("fontawesome2", 12/myX*sx)) + 4/myX*sx, y, w, h, color, size, fonts:getFont("condensed", 12/myX*sx), align, "center")
    elseif align == "right" then 
        dxDrawText(text, x, y, w, h, color, size, fonts:getFont("condensed", 12/myX*sx), align, "center")
        dxDrawText(icon, x + w, y, w, h, color, size, fonts:getFont("fontawesome2", 12/myX*sx), align, "center")
    end
end

function loadSkinshops()
    for k, v in ipairs(skinShops) do 
        local marker = cmarker:createCustomMarker(v[1], v[2], v[3], 3.0, skinShopDatas[v[4]][1], skinShopDatas[v[4]][2], skinShopDatas[v[4]][3], skinShopDatas[v[4]][4], skinShopDatas[v[4]][5], "circle")
        table.insert(markerCache, marker)

        setElementData(marker, "skinshop:type", v[4])
        setElementData(marker, "skinshop:ped", v.viewPed)
        setElementData(marker, "skinshop:campos", v.viewCamPos)
        setElementData(marker, "skinshop:dim", v.dim)
        setElementData(marker, "skinshop:int", v.int)

        setElementDimension(marker, v.dim)
        setElementInterior( marker, v.int )
    end
end
loadSkinshops()

addEventHandler("onClientResourceStop", resourceRoot, function()
    for k, v in ipairs(markerCache) do 
        if isElement(v) then destroyElement(v) end
    end
end)

local screenX, screenY = guiGetScreenSize()
local selectW, selectH = sx*0.3, 285
local selectX, selectY = sx/2 - selectW/2, sy/2 - selectH/2
local factions = {}
local minLines = 1
local maxLines = 8

local allowedType = {
    [4] = true,
    [5] = true,
}

function renderSkinshopPanel()
    showCursor(true)
    if isSelectedPanel then 
        core:drawWindow(selectX, selectY, selectW, selectH, "Kérlek válaszd ki a frakciót!")
        startY = selectY + 25
        for i=minLines, maxLines do
            local factionId = factions[i]
            if factionId then
                if allowedType[exports["oDashboard"]:getFactionType(factionId)] then 
                    dxDrawImage(selectX+5, startY, selectW-10, 30, ":oInteriors/files/test.png", 0, 0, 0, tocolor(r,g,b,50))
                    dxDrawText("Frakció neve:\n"..color..exports["oDashboard"]:getFactionName(factionId), selectX + 10, startY, selectX, 0, tocolor(255,255,255,255), 1, fonts:getFont("condensed", 10/myX*sx), "left", "top", false, false, false, true)
                    core:dxDrawButton(selectX+selectW-125, startY, 120, 30, r, g, b, 150, "Kiválasztás", tocolor(255,255,255,255),1,fonts:getFont("condensed", 10/myX*sx), true) 
                end
            end
            startY = startY + 35
        end
    else
        dxDrawRectangle(sx*0.4, sy*0.8, sx*0.2, sy*0.15, tocolor(35, 35, 35, 100))
        dxDrawRectangle(sx*0.4 + 2/myX*sx, sy*0.8 + 2/myY*sy, sx*0.2 - 4/myX*sx, sy*0.15 - 4/myY*sy, tocolor(35, 35, 35, 255))
        dxDrawRectangle(sx*0.4 + 2/myX*sx, sy*0.8 + 2/myY*sy, sx*0.2 - 4/myX*sx, sy*0.024, tocolor(30, 30, 30, 255))

        dxDrawText("Ruhabolt "..skinShopDatas[selectedType][7].."("..skinShopDatas[selectedType][6]..")", sx*0.4 + 2/myX*sx, sy*0.8 + 2/myY*sy, sx*0.2 - 4/myX*sx, sy*0.024, tocolor(255, 255, 255, 100), 1, fonts:getFont("condensed", 10/myX*sx), "center", "center", false, false, false, true)

        if core:isInSlot(sx*0.4 + 6/myX*sx, sy*0.924, sx*0.06, sy*0.024) or rotateEnabled then 
            drawTextWithIcon("", "Skin forgatása", sx*0.4 + 6/myX*sx, sy*0.924, sx*0.1, sy*0.024, tocolor(r, g, b, 255), 0.8, "left")
        else
            drawTextWithIcon("", "Skin forgatása", sx*0.4 + 6/myX*sx, sy*0.924, sx*0.1, sy*0.024, tocolor(255, 255, 255, 255), 0.8, "left")
        end

        if core:isInSlot(sx*0.4 + 10/myX*sx, sy*0.9, sx*0.07, sy*0.024) or walkEnabled then 
            drawTextWithIcon("", "Séta bekapcsolása", sx*0.4 + 10/myX*sx, sy*0.9, sx*0.1, sy*0.024, tocolor(r, g, b, 255), 0.8, "left")
        else
            drawTextWithIcon("", "Séta bekapcsolása", sx*0.4 + 10/myX*sx, sy*0.9, sx*0.1, sy*0.024, tocolor(255, 255, 255, 255), 0.8, "left")
        end
        if selectedType == "faction" then 
            if core:isInSlot(sx*0.54, sy*0.924, 100/myX*sx, sy*0.024) then 
                drawTextWithIcon("", "Kiválasztás", sx*0.573, sy*0.924, 20/myX*sx, sy*0.024, tocolor(106, 199, 88, 255), 0.8, "right")
            else
                drawTextWithIcon("", "Kiválasztás", sx*0.573, sy*0.924, 20/myX*sx, sy*0.024, tocolor(255, 255, 255, 255), 0.8, "right")
            end
        else 
            if core:isInSlot(sx*0.54, sy*0.924, 100/myX*sx, sy*0.024) then 
                drawTextWithIcon("", "Megvásárlás", sx*0.573, sy*0.924, 20/myX*sx, sy*0.024, tocolor(106, 199, 88, 255), 0.8, "right")
            else
                drawTextWithIcon("", "Megvásárlás", sx*0.573, sy*0.924, 20/myX*sx, sy*0.024, tocolor(255, 255, 255, 255), 0.8, "right")
            end
        end

        if core:isInSlot(sx*0.555, sy*0.9, 70/myX*sx, sy*0.024) then 
            drawTextWithIcon("", "Kilépés", sx*0.573, sy*0.9, 20/myX*sx, sy*0.024, tocolor(252, 63, 63, 255), 0.8, "right")
        else
            drawTextWithIcon("", "Kilépés", sx*0.573, sy*0.9, 20/myX*sx, sy*0.024, tocolor(255, 255, 255, 255), 0.8, "right")
        end

        if core:isInSlot(sx*0.41, sy*0.84, sx*0.02, sy*0.05) then
            dxDrawText("", sx*0.41, sy*0.84, sx*0.01, sy*0.05, tocolor(255, 255, 255, 200), 1, fonts:getFont("fontawesome2", 24/myX*sx), "center", "center")
        else
            dxDrawText("", sx*0.41, sy*0.84, sx*0.01, sy*0.05, tocolor(255, 255, 255, 100), 1, fonts:getFont("fontawesome2", 22/myX*sx), "center", "center")
        end

        if core:isInSlot(sx*0.57, sy*0.84, sx*0.02, sy*0.05) then
            dxDrawText("", sx*0.58, sy*0.84, sx*0.01, sy*0.05, tocolor(255, 255, 255, 200), 1, fonts:getFont("fontawesome2", 24/myX*sx), "center", "center")
        else
            dxDrawText("", sx*0.58, sy*0.84, sx*0.01, sy*0.05, tocolor(255, 255, 255, 100), 1, fonts:getFont("fontawesome2", 22/myX*sx), "center", "center")
        end

        if selectedType == "faction" then 
            dxDrawText("Skin ID: "..color..skinTable[selectedType][selectedSkin], sx*0.4 + 2/myX*sx, sy*0.83, sx*0.2 - 4/myX*sx, sy*0.065, tocolor(255, 255, 255, 100), 1, fonts:getFont("condensed", 12/myX*sx), "center", "center", false, false, false, true)
        else
            dxDrawText("Skin ID: "..color..skinTable[selectedType][selectedSkin][1].." #ffffff| Ár: #6ac758"..skinTable[selectedType][selectedSkin][2].."$", sx*0.4 + 2/myX*sx, sy*0.83, sx*0.2 - 4/myX*sx, sy*0.065, tocolor(255, 255, 255, 100), 1, fonts:getFont("condensed", 12/myX*sx), "center", "center", false, false, false, true)
        end

        if rotateEnabled then 
            local a1,a2,newRot = getElementRotation(tempPed)
            local newRot = newRot + 1
            if newRot > 360 then
                newRot = 0
            end
            setElementRotation(tempPed, 0, 0, newRot, "default", true)
        end
    end
end

local walkTimer = nil

function skinshopKey(key, state)
    if key == "backspace" and state then 
        if isSelectedPanel then 
            --setElementFrozen(localPlayer, false)
            --selectedFactionId = 
            factions = {}
            isSelectedPanel = false
            removeEventHandler("onClientRender", root, renderSkinshopPanel)
            removeEventHandler("onClientKey", root, skinshopKey)
            showCursor(false)
        end
    end
    if key == "mouse1" and state then 
        if isSelectedPanel then 
            startY = selectY + 25
            for i=minLines, maxLines do
                local factionId = factions[i]
                if factionId then
                    if core:isInSlot(selectX+selectW-125, startY, 120, 30) then 
                        selectedFactionId = factionId
                        selectedType = getElementData(marker, "skinshop:type")
                        skinTableG.faction = exports["oDashboard"]:getAllowedSkinsFaction(factionId)
                        if not skinTableG.faction or #skinTableG.faction == 0 then 
                            exports.oInfobox:outputInfoBox("Ehhez a frakcióhoz nincs skin beállítva!", "error")
                        else
                            setTimer(function()
                                isSelectedPanel = false
                                selectedType = getElementData(marker, "skinshop:type")
                                startCam = {getCameraMatrix(localPlayer)}
                                pedPos = getElementData(marker, "skinshop:ped")
                                tempPed = createPed(skinTable[selectedType][selectedSkin], unpack(pedPos))     
                                setElementDimension(tempPed, getElementData(marker, "skinshop:dim"))
                                setElementInterior(tempPed, getElementData(marker, "skinshop:int"))
                                
                                local campos = getElementData(marker, "skinshop:campos")
                                smoothMoveCamera(startCam[1], startCam[2], startCam[3], startCam[4], startCam[5], startCam[6], unpack(campos))
                                setElementFrozen(localPlayer, true)
                    
                                showChat(false)
                                exports.oInterface:toggleHud(true)
                            end, 50, 1)
                        end
                    end
                end
                startY = startY + 35
            end
        end
        if core:isInSlot(sx*0.41, sy*0.84, sx*0.02, sy*0.05) then
            if selectedSkin > 1 then 
                selectedSkin = selectedSkin - 1 
            else
                selectedSkin = #skinTable[selectedType]
            end
            updateTempSkin()
        end

        if core:isInSlot(sx*0.57, sy*0.84, sx*0.02, sy*0.05) then
            if selectedSkin < #skinTable[selectedType] then 
                selectedSkin = selectedSkin + 1 
            else
                selectedSkin = 1
            end
            updateTempSkin()
        end

        if core:isInSlot(sx*0.4 + 6/myX*sx, sy*0.924, sx*0.06, sy*0.024) then
            rotateEnabled = not rotateEnabled 
        end 

        if core:isInSlot(sx*0.4 + 10/myX*sx, sy*0.9, sx*0.07, sy*0.024) then
            walkEnabled = not walkEnabled

            if walkEnabled then 
                setPedControlState(tempPed, "walk", true)
                setPedControlState(tempPed, "forwards", true)
            else
                setPedControlState(tempPed, "walk", false)
                setPedControlState(tempPed, "forwards", false)
            end

            setElementFrozen(tempPed, walkEnabled)
        end 

        if core:isInSlot(sx*0.555, sy*0.9, 70/myX*sx, sy*0.024) then 
            closeShop()
        end
        if selectedType == "faction" then 
            if core:isInSlot(sx*0.54, sy*0.924, 100/myX*sx, sy*0.024) then
                triggerServerEvent("skinshop > buySkin", resourceRoot, skinTable[selectedType][selectedSkin])
                closeShop()
            end
        else
            if core:isInSlot(sx*0.54, sy*0.924, 100/myX*sx, sy*0.024) then 
                local price = skinTable[selectedType][selectedSkin][2]

                if getElementData(localPlayer, "char:money") >= skinTable[selectedType][selectedSkin][2] then 
                    if getElementModel(localPlayer) == skinTable[selectedType][selectedSkin][1] then 
                        exports.oInfobox:outputInfoBox("Jelenleg is ez a skin van rajtad!", "error")
                    else
                        setElementData(localPlayer, "char:money", getElementData(localPlayer, "char:money") - skinTable[selectedType][selectedSkin][2])
                        triggerServerEvent("skinshop > buySkin", resourceRoot, skinTable[selectedType][selectedSkin][1])
                        closeShop()
                    end
                else
                    exports.oInfobox:outputInfoBox("Nincs elegendő pénzed a skin megvásárlásához!", "error")
                end
            end
        end
    end
end

function closeShop()
    local nowcam = {getCameraMatrix(localPlayer)}
    smoothMoveCamera(nowcam[1], nowcam[2], nowcam[3], nowcam[4], nowcam[5], nowcam[6], startCam[1], startCam[2], startCam[3], startCam[4], startCam[5], startCam[6])
    setTimer(function()
        setCameraTarget(localPlayer, localPlayer)
    end, 1500, 1)

    destroyElement(tempPed)
    if selectedType == "faction" then 
        selectedFactionId = 0
    end
    removeEventHandler("onClientRender", root, renderSkinshopPanel)
    removeEventHandler("onClientKey", root, skinshopKey)
    showCursor(false)
    factions = {}
    showChat(true)
    exports.oInterface:toggleHud(false)
    walkEnabled = false

    setElementFrozen(localPlayer, false)
end

addEventHandler("onClientMarkerLeave", getRootElement(), function(player, mdim)
    if player == localPlayer and mdim then 
        if (getElementData(source, "skinshop:type") or false) then 
            if getElementData(source, "skinshop:type") == "faction" then 
                isSelectedPanel = false
                factions = {}
                selectedFactionId = 0
                removeEventHandler("onClientRender", root, renderSkinshopPanel)
                showCursor(false)
                removeEventHandler("onClientKey", root, skinshopKey)
            end
        end
    end
end)

addEventHandler("onClientMarkerHit", root, function(player, mdim)
    if mdim and player == localPlayer and core:getDistance(source, localPlayer) < 2 then 
        marker = source 
        selectedSkin = 1

        if (getElementData(source, "skinshop:type") or false) then 
            if getElementData(source, "skinshop:type") == "faction" then 
                theFactions = exports["oDashboard"]:getPlayerAllFactions(localPlayer)
                for k,v in pairs(theFactions) do 
                    if allowedType[exports["oDashboard"]:getFactionType(v)] then 
                        table.insert(factions, #factions+1, v)
                    end
                end
                --iprint(exports["oDashboard"]:getFactionType(factions))
                if #factions == 0 then 
                    exports.oInfobox:outputInfoBox("Nem vagy egyetlen frakcióba sem!", "error")
                else
                    --skinTable["faction"] = getElementData(resourceRoot, "skinshop:skinTable")
                    --setElementFrozen(localPlayer, true)
                    isSelectedPanel = true
                    addEventHandler("onClientRender", root, renderSkinshopPanel)
                    addEventHandler("onClientKey", root, skinshopKey)
                end
            else
                selectedType = getElementData(marker, "skinshop:type")
                startCam = {getCameraMatrix(localPlayer)}
                pedPos = getElementData(marker, "skinshop:ped")
                local gender = getElementData(localPlayer, "char:gender")
                local genderName = "man"
                if gender == 1 then 
                    genderName = "woman"
                elseif gender == 2 then 
                    genderName = "man"
                end
                --if selectedType == genderName then
                    --print(selectedType, selectedSkin)
                    tempPed = createPed(skinTable[selectedType][selectedSkin][1], unpack(pedPos))  
                    setElementDimension(tempPed, getElementData(marker, "skinshop:dim"))
                    setElementInterior(tempPed, getElementData(marker, "skinshop:int"))
                    
                    
                    local campos = getElementData(marker, "skinshop:campos")
                    smoothMoveCamera(startCam[1], startCam[2], startCam[3], startCam[4], startCam[5], startCam[6], unpack(campos))
        
                    addEventHandler("onClientRender", root, renderSkinshopPanel)
                    addEventHandler("onClientKey", root, skinshopKey)
        
                    setElementFrozen(localPlayer, true)
        
                    showChat(false)
                    exports.oInterface:toggleHud(true)
              --  else 
                --    outputChatBox("Ez nem a te nemed!")
                --end
            end
        end
    end
end)

function updateTempSkin()
    if selectedType == "faction" then 
        setElementModel(tempPed, skinTable[selectedType][selectedSkin])
    else
        setElementModel(tempPed, skinTable[selectedType][selectedSkin][1])
    end
end

-- Edit fk skins 
local skinEditorShowing = false 
local scrollbar = 0

function renderSkinEditor()
    --skinTable["faction"] = getElementData(resourceRoot, "skinshop:skinTable")

    dxDrawRectangle(sx*0.4, sy*0.2, sx*0.2, sy*0.49, tocolor(30, 30, 30, 200))
    dxDrawRectangle(sx*0.4 + 2/myX*sx, sy*0.2 + 2/myY*sy, sx*0.2 - 4/myX*sx, sy*0.49 - 4/myY*sy, tocolor(35, 35, 35, 255))

    local lineHeight = math.min(15 / #skinTable, 1)

    dxDrawRectangle(sx*0.5965, sy*0.2 + 6/myY*sy , sx*0.002, sy*0.49 - 8/myY*sy, tocolor(r, g, b, 100))
    dxDrawRectangle(sx*0.5965, sy*0.2 + 6/myY*sy + ((sy*0.49 - 8/myY*sy) * (lineHeight * scrollbar / 15)), sx*0.002, (sy*0.49 - 8/myY*sy) * lineHeight, tocolor(r, g, b, 255))

    local startY = sy*0.2 + 6/myY*sy 

    for k, v in ipairs(skinTable) do 
        if (15 + scrollbar) >= k and scrollbar < k then
            local alpha = 200 

            if (k % 2) == 0 then 
                alpha = 150
            end

            dxDrawRectangle(sx*0.4 + 4/myX*sx, startY, sx*0.2 - 12/myX*sx, sy*0.03, tocolor(30, 30, 30, alpha))

            if core:isInSlot(sx*0.575 + 4/myX*sx, startY, sx*0.02, sy*0.03) then
                dxDrawText("", sx*0.4 + 4/myX*sx, startY, sx*0.2 - 20/myX*sx, sy*0.03, tocolor(252, 63, 63, 200), 1, fonts:getFont("fontawesome2", 13/myX*sx), "right", "center")
            else
                dxDrawText("", sx*0.4 + 4/myX*sx, startY, sx*0.2 - 20/myX*sx, sy*0.03, tocolor(255, 255, 255, 100), 1, fonts:getFont("fontawesome2", 13/myX*sx), "right", "center") 
            end

            dxDrawText("SkinID: "..color..v[1].." #ffffff| Frakció: "..color..v[2], sx*0.4 + 12/myX*sx, startY, sx*0.2 - 20/myX*sx, sy*0.03, tocolor(255, 255, 255, 255), 1, fonts:getFont("condensed", 11/myX*sx), "left", "center", false, false, false, true)

            startY = startY + sy*0.032
        end
    end

    core:dxDrawButton(sx*0.45, sy*0.74, sx*0.1, sy*0.05, r, g, b, 200, "Skin hozzáadása", tocolor(255, 255, 255, 255), 1, fonts:getFont("condensed", 11/myX*sx), true, tocolor(0, 0, 0, 100))
end

function keySkinEditor(key, state) 
    if key == "mouse1" and state then 
        local startY = sy*0.2 + 6/myY*sy 
        for k, v in ipairs(skinTable) do 
            if (15 + scrollbar) >= k and scrollbar < k then
                if core:isInSlot(sx*0.575 + 4/myX*sx, startY, sx*0.02, sy*0.03) then
                    table.remove(skinTable, k)
                    triggerServerEvent("skinshop > updateFactionSkinTable", resourceRoot, skinTable)
                end

                startY = startY + sy*0.032
            end
        end

        if core:isInSlot(sx*0.45, sy*0.74, sx*0.1, sy*0.05) then 
            local skinID, factionID = tonumber(core:getEditboxText("skineditor-skinid")), tonumber(core:getEditboxText("skineditor-factionid"))

            if skinID > 0 and factionID > 0 then 
                local error = false

                for k, v in ipairs(skinTable) do 
                    if v[1] == skinID then 
                        error = true 
                        break
                    end
                end

                if error then 
                    exports.oInfobox:outputInfoBox("Ez a skin már hozzá van adva egy frakcióhoz!", "error")
                else
                    table.insert(skinTable["faction"], {skinID, factionID})
                    core:setEditboxText("skineditor-skinid", "Skin ID")
                    core:setEditboxText("skineditor-factionid", "Frakció ID")

                    triggerServerEvent("skinshop > updateFactionSkinTable", resourceRoot, skinTable["faction"])
                end
            end
        end
    elseif key == "mouse_wheel_up" and state then 
        if scrollbar > 0 then 
            scrollbar = scrollbar - 1
        end
    elseif key == "mouse_wheel_down" and state then 
        if skinTable[scrollbar + 16] then 
            scrollbar = scrollbar + 1
        end
    end
end

addEvent("skinshop > sendFactionSkinsToClient", true)
addEventHandler("skinshop > sendFactionSkinsToClient", root, function(table, openPanel)
    skinTable["faction"] = table

    if openPanel then
        addEventHandler("onClientRender", root, renderSkinEditor)
        addEventHandler("onClientKey", root, keySkinEditor)

        core:deleteEditbox("skineditor-skinid")
        core:deleteEditbox("skineditor-factionid")
        core:createEditbox(sx*0.405, sy*0.70, sx*0.09, sy*0.03, "skineditor-skinid", "Skin ID", "text")
        core:createEditbox(sx*0.505, sy*0.70, sx*0.09, sy*0.03, "skineditor-factionid", "Frakció ID", "text")
    end
end)

--[[addCommandHandler("editfkskins", function(cmd)
    if (getElementData(localPlayer, "user:admin") or 0) >= 7 then 
        if skinEditorShowing then 
            skinEditorShowing = false
            removeEventHandler("onClientRender", root, renderSkinEditor)
            removeEventHandler("onClientKey", root, keySkinEditor)
            core:deleteEditbox("skineditor-skinid")
            core:deleteEditbox("skineditor-factionid")
        else
            skinEditorShowing = true
            triggerServerEvent("skinshop > getFactionSkinsFromServer", resourceRoot, true)
        end
    end
end)]]

-- Smooth camera 
local sm = {}
sm.moov = 0

local function removeCamHandler()
	if(sm.moov == 1)then
		sm.moov = 0
	end
end

local start
local animTime
local tempPos = {{},{}}
local tempPos2 = {{},{}}

local function camRender()
	local now = getTickCount()
	if (sm.moov == 1) then
		local x1, y1, z1 = interpolateBetween(tempPos[1][1], tempPos[1][2], tempPos[1][3], tempPos2[1][1], tempPos2[1][2], tempPos2[1][3], (now-start)/animTime, "InOutQuad")
		local x2,y2,z2 = interpolateBetween(tempPos[2][1], tempPos[2][2], tempPos[2][3], tempPos2[2][1], tempPos2[2][2], tempPos2[2][3], (now-start)/animTime, "InOutQuad")
		setCameraMatrix(x1,y1,z1,x2,y2,z2)
	else
		removeEventHandler("onClientRender",root,camRender)
		--fadeCamera(true)
	end
end

function smoothMoveCamera(x1,y1,z1,x1t,y1t,z1t,x2,y2,z2,x2t,y2t,z2t,time)
	if(sm.moov == 1) then
		killTimer(timer1)
		killTimer(timer2)
		removeEventHandler("onClientRender",root,camRender)
		--fadeCamera(true)
	end

    if not time then 
        time = 1500
    end

	--fadeCamera(true)
	sm.moov = 1
	timer1 = setTimer(removeCamHandler,time,1)
	--timer2 = setTimer(fadeCamera, time-1000, 1, false) -- 
	start = getTickCount()
	animTime = time
	tempPos[1] = {x1,y1,z1}
	tempPos[2] = {x1t,y1t,z1t}
	tempPos2[1] = {x2,y2,z2}
	tempPos2[2] = {x2t,y2t,z2t}
	addEventHandler("onClientRender",root,camRender)
	return true
end