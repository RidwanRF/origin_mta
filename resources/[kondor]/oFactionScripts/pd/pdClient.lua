-- 2892: szögesdrót
--

tooltipText = ""

local handUsed = false
local tooltipShowing = false

addEvent("faction > pd > playRadioSound", true)
addEventHandler("faction > pd > playRadioSound", root, function()
    playSound("files/radio.mp3")
end)

-- Stinger

local tempObject
local tempObjectRot = 0
local tempType = false
local tempZPlus = 0

local function interactionRender()
    core:dxDrawShadowedText(tooltipText, 0, sy*0.89, sx, sy*0.89+sy*0.05, tocolor(255, 255, 255, 255), tocolor(0, 0, 0, 255), 0.9/myX*sx, fonts["condensed-12"], "center", "center", false, false, false, true)
end

function createTempObject(objid)
    if isElement(tempObject) then destroyElement(tempObject) end

    tempObject = createObject(objid, getElementPosition(localPlayer))

    setElementAlpha(tempObject, 150)
    setElementCollisionsEnabled(tempObject, false)
end

function positioningTemporaryObject()
    if isCursorShowing() then
        local screenx, screeny, worldx, worldy, worldz = getCursorPosition()
        local px, py, pz = getCameraMatrix()
        local hit, x, y, z, elementHit = processLineOfSight(px, py, pz, worldx, worldy, worldz)

        tX, tY, tZ = x, y, z

        tZ = getGroundPosition(tX, tY, tZ)

        if tempType == "RBS" then
            tZ = tZ + tempZPlus
        end

        if getDistanceBetweenPoints3D(tX, tY, tZ, getElementPosition(localPlayer)) < 10 then
            setElementPosition(tempObject, tX, tY, tZ, false)
        end

        setElementRotation(tempObject, 0, 0, tempObjectRot)
    end
end

function rotateTempObject(key, state)
    if state then
        if key == "mouse_wheel_up" then
            tempObjectRot = tempObjectRot + 5
        elseif key == "mouse_wheel_down" then
            tempObjectRot = tempObjectRot - 5
        end
    end
end

function getStingerFromVeh(veh)
    local pFaction = getElementData(localPlayer, "char:duty:faction") or 0

    if pFaction > 0 then
        if faction:getFactionType(pFaction) == 1 then
            if not (handUsed) then
                local stingerCount = 1--getElementData(veh, "pd:stingerCount") or 1

                if stingerCount > 0 then
                    --triggerServerEvent("factionScripts > pd > getStingerFromVeh", resourceRoot, veh)
                    tooltipText = "A szögesdrót lehelyezéséhez nyomd meg az "..color.."[E] #ffffffgombot. \n A forgatáshoz használd a "..color.."[Görgőt]#ffffff."
                    addEventHandler("onClientRender", root, interactionRender)
                    handUsed = true
                    tooltipShowing = true
                    tempType = false
                    createTempObject(2892)
                    bindKey("e", "up", putStingerDown)
                    chat:sendLocalMeAction("kivesz egy szögesdrótot a járműből.")
                    addEventHandler("onClientRender", root, positioningTemporaryObject)
                    addEventHandler("onClientKey", root, rotateTempObject)
                    outputChatBox(core:getServerPrefix("server", "Szögesdrót", 2).."Ha vissza akarod tenni a járműbe a szögesdrótot akkor klikkelj a járműre a jobb gombal.", 255, 255, 255, true)
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Szögesdrót", 3).."Nincs a járműben szögesdrót.", 255, 255, 255, true)
                    infobox:outputInfoBox("A járműben nincsen  szögesdrót!", "error")
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", "Szögesdrót", 3).."A kezed már használatban van.", 255, 255, 255, true)
            end
        else
            outputChatBox(core:getServerPrefix("red-dark", "Szögesdrót", 3).."Nem vagy rendvédelmi szervezet tagja, vagy nem vagy szolgálatban.", 255, 255, 255, true)
        end
    else
        outputChatBox(core:getServerPrefix("red-dark", "Szögesdrót", 3).."Nem vagy rendvédelmi szervezet tagja, vagy nem vagy szolgálatban.", 255, 255, 255, true)
    end
end

function putStingerDown()
    local rotX, rotY, rotZ = getElementRotation(tempObject)
    local posX, posY, posZ = getElementPosition(tempObject)
    triggerServerEvent("factionScripts > pd > putDownStingerServer", resourceRoot, posX, posY, posZ, rotX, rotY, rotZ)
    chat:sendLocalMeAction("lerak egy szögesdrótot.")
    destroyElement(tempObject)

    unbindKey("e", "up", putStingerDown)
    removeEventHandler("onClientRender", root, positioningTemporaryObject)
    removeEventHandler("onClientKey", root, rotateTempObject)
    removeEventHandler("onClientRender", root, interactionRender)
    handUsed = false
    tooltipShowing = false
end

addEventHandler("onClientColShapeHit", root, function(element, mdim)
    if handUsed then return end
    if element and mdim then
        if element == localPlayer then
            if not getPedOccupiedVehicle(localPlayer) then
                if getElementData(source, "pdIsStingerCol") then
                    if getElementData(localPlayer, "user:aduty") then
                        stingerCol = source
                        tooltipText = "A szögesdrót törléséhez nyomd meg az "..color.."[E] #ffffffgombot."
                        if not tooltipShowing then
                            addEventHandler("onClientRender", root, interactionRender)
                            tooltipShowing = true
                        end
                        bindKey("e", "up", adelStinger)
                    else
                        local pFaction = getElementData(localPlayer, "char:duty:faction") or 0

                        if pFaction > 0 then
                            if faction:getFactionType(pFaction) == 1 then
                                if not (handUsed) then
                                    stingerCol = source
                                    tooltipText = "A szögesdrót felvételéhez nyomd meg az "..color.."[E] #ffffffgombot."
                                    if not tooltipShowing then
                                        addEventHandler("onClientRender", root, interactionRender)
                                        tooltipShowing = true
                                    end
                                    bindKey("e", "up", putStingerUp)
                                end
                            end
                        end
                    end
                elseif getElementData(source, "colIsPdJail") then
                    local pFaction = getElementData(localPlayer, "char:duty:faction") or 0

                    if pFaction > 0 then
                        if faction:getFactionType(pFaction) == 1 then
                            occupiedJailControllCol = source
                            openJailPanel()
                        end
                    end
                end
            end
        end
    end
end)

function adelStinger()
    removeEventHandler("onClientRender", root, interactionRender)
    unbindKey("e", "up", adelStinger)
    triggerServerEvent("factionScripts > pd > adelStinger", resourceRoot, stingerCol)
end

function putStingerUp(key)
    if not (handUsed) then
        handUsed = true
        unbindKey("e", "up", putStingerUp)
        removeEventHandler("onClientRender", root, interactionRender)
        triggerServerEvent("factionScripts > pd > pickUpStinger", resourceRoot, stingerCol)
        outputChatBox(core:getServerPrefix("server", "Szögesdrót", 2).."Ahhoz, hogy vissza tedd a járműbe a szögesdrótot klikkelj a járműre a jobb gombal.", 255, 255, 255, true)
        if not key then
            chat:sendLocalMeAction("felvesz egy szögesdrótot.")
        end
    end
end

addEvent("putStingerUp", true)
addEventHandler("putStingerUp", root, function()
    putStingerUp(true)
    destroyElement(obj)
end)

addEventHandler("onClientColShapeLeave", root, function(element, mdim)
    if handUsed then return end
    if element and mdim then
        if element == localPlayer then
            if not getPedOccupiedVehicle(localPlayer) then
                if getElementData(source, "pdIsStingerCol") then
                    if getElementData(localPlayer, "user:aduty") then
                        stingerCol = false
                        if tooltipShowing then
                            removeEventHandler("onClientRender", root, interactionRender)
                            tooltipShowing = false
                        end
                        unbindKey("e", "up", putStingerUp)
                    else
                        local pFaction = getElementData(localPlayer, "char:duty:faction") or 0

                        if pFaction > 0 then
                            if faction:getFactionType(pFaction) == 1 then
                                if not (handUsed) then
                                    stingerCol = false
                                    if tooltipShowing then
                                        removeEventHandler("onClientRender", root, interactionRender)
                                        tooltipShowing = false
                                    end
                                    unbindKey("e", "up", putStingerUp)
                                end
                            end
                        end
                    end
                elseif getElementData(source, "colIsPdJail") then
                    local pFaction = getElementData(localPlayer, "char:duty:faction") or 0

                    if pFaction > 0 then
                        if faction:getFactionType(pFaction) == 1 then
                            closeJailPanel()
                            occupiedJailControllCol = false
                        end
                    end
                end
            end
        end
    end
end)

addEventHandler("onClientClick", root, function(key, state, _, _, _, _, _, element)
    if key == "right" then
        if state == "up" then
            if element then
                if policeCars[getElementModel(element)] then
                    if (policeCars[getElementModel(element)].stingerAllowed or false) then
                        if core:getDistance(element, localPlayer) < 4 then
                            if getElementData(localPlayer, "pdBag") then
                                cancelEvent()
                                triggerServerEvent("factionScripts > pd > putStingeerToCar", resourceRoot, element)
                                handUsed = false

                                unbindKey("e", "up", putStingerDown)
                                handUsed = false
                                removeEventHandler("onClientRender", root, interactionRender)
                            end
                        end
                    end
                end
            end
        end
    end
end)
-- Stinger vége

local rbsPointer = 0
local selectedRBSLine = 1
local object3d = false
local rbsPanelShow = false
local createdRBS = false

function renderRBSPanel()
    dxDrawRectangle(sx*0.4, sy*0.3, sx*0.2, sy*0.395+3/myY*sy, tocolor(35, 35, 35, 255))
    dxDrawRectangle(sx*0.4+3/myX*sx, sy*0.3+3/myY*sy, sx*0.2-6/myX*sx, sy*0.2, tocolor(30, 30, 30, 255))

    local startY = sy*0.505+3/myY*sy
    for i = 1, 6 do
        local color = tocolor(30, 30, 30, 255)
        local color2 = tocolor(r, g, b, 200)

        if i % 2 == 0 then
            color = tocolor(30, 30, 30, 180)
            color2 = tocolor(r, g, b, 100)
        end

        dxDrawRectangle(sx*0.4+3/myX*sx, startY, sx*0.2-6/myX*sx, sy*0.03, color)
        if selectedRBSLine == i + rbsPointer or core:isInSlot(sx*0.4+3/myX*sx, startY, sx*0.2-6/myX*sx, sy*0.03) then
            dxDrawText(rbs[i+rbsPointer].name, sx*0.4+10/myX*sx, startY, sx*0.4+10/myX*sx+sx*0.2-6/myX*sx, startY+sy*0.03, tocolor(r, g, b, 255), 0.8/myX*sx, fonts["condensed-12"], "left", "center")
        else
            dxDrawText(rbs[i+rbsPointer].name, sx*0.4+10/myX*sx, startY, sx*0.4+10/myX*sx+sx*0.2-6/myX*sx, startY+sy*0.03, tocolor(255, 255, 255, 220), 0.8/myX*sx, fonts["condensed-12"], "left", "center")
        end

        if selectedRBSLine == i + rbsPointer then
            if core:isInSlot(sx*0.6-25/myX*sx, startY+4/myY*sy, 20/myX*sx, 20/myY*sy) then
                dxDrawImage(sx*0.6-25/myX*sx, startY+4/myY*sy, 20/myX*sx, 20/myY*sy, "files/select.png", 0, 0, 0, tocolor(r, g, b, 255))
            else
                dxDrawImage(sx*0.6-25/myX*sx, startY+4/myY*sy, 20/myX*sx, 20/myY*sy, "files/select.png")
            end
        end
        dxDrawRectangle(sx*0.4+3/myX*sx, startY, sx*0.0015, sy*0.03, color2)
        startY = startY + sy*0.031
    end

    --dxDrawRectangle(sx*0.4+3/myX*sx+sx*0.2-6/myX*sx, sy*0.505+3/myY*sy, sx*0.002, sy*0.185*(6/#rbs), tocolor(r, g, b, 255))
end

function rbsPanelKey(key, state)
    if key == "mouse1" and state then
        local startY = sy*0.505+3/myY*sy
        for i = 1, 6 do
            if core:isInSlot(sx*0.4+3/myX*sx, startY, sx*0.2-6/myX*sx, sy*0.03) then
                if not (selectedRBSLine == i+rbsPointer) then
                    selectedRBSLine = i+rbsPointer
                    replace3dobj()
                end
            end

            if selectedRBSLine == i + rbsPointer then
                if core:isInSlot(sx*0.6-25/myX*sx, startY+4/myY*sy, 20/myX*sx, 20/myY*sy) then
                    tooltipText = "A roadblock lehelyezéséhez nyomd meg az "..color.."[E] #ffffffgombot. \n A forgatáshoz használd a "..color.."[Görgőt]#ffffff."
                    addEventHandler("onClientRender", root, interactionRender)
                    handUsed = true
                    tooltipShowing = true
                    tempType = "RBS"
                    createTempObject(rbs[selectedRBSLine].obj)
                    tempZPlus = rbs[selectedRBSLine].zplus or 0.5
                    bindKey("e", "up", putRBSDown)

                    addEventHandler("onClientRender", root, positioningTemporaryObject)
                    addEventHandler("onClientKey", root, rotateTempObject)
                    chat:sendLocalMeAction("kivesz egy roadblockot a járműből.")
                    showRBSPanel()
                end
            end

            startY = startY + sy*0.031
        end
    end

    if key == "mouse_wheel_down" and state then
        if core:isInSlot(sx*0.4, sy*0.3, sx*0.2, sy*0.395+3/myY*sy) then
            if rbsPointer < #rbs - 6 then
                rbsPointer = rbsPointer + 1
            end
        end
    end

    if key == "mouse_wheel_up" and state then
        if core:isInSlot(sx*0.4, sy*0.3, sx*0.2, sy*0.395+3/myY*sy) then
            if rbsPointer > 0 then
                rbsPointer = rbsPointer - 1
            end
        end
    end
end

function putRBSDown()
    local model = getElementModel(tempObject)
    local posX, posY, posZ = getElementPosition(tempObject)
    local rotX, rotY, rotZ = getElementRotation(tempObject)
    chat:sendLocalMeAction("lerak egy roadblockot.")
    triggerServerEvent("factionScripts > pd > putDownRBS", resourceRoot, model, posX, posY, posZ, rotX, rotY, rotZ)
    destroyElement(tempObject)

    unbindKey("e", "up", putRBSDown)
    removeEventHandler("onClientRender", root, positioningTemporaryObject)
    removeEventHandler("onClientKey", root, rotateTempObject)
    removeEventHandler("onClientRender", root, interactionRender)
    handUsed = false
    tooltipShowing = false
end

function showRBSPanel()
    local pFaction = getElementData(localPlayer, "char:duty:faction") or 0

    if pFaction > 0 then
        if (faction:getFactionType(pFaction) == 1) or (pFaction == 4) then
            if not (handUsed) then
                if not rbsPanelShow then
                    object3d = createObject(rbs[selectedRBSLine].obj, 0, 0, 0)
                    setElementCollisionsEnabled(object3d, false)
                    setObjectScale(object3d, 0.7)
                    exports.oPreview:createObjectPreview(object3d, 0, 0, 0, sx*0.4+3/myX*sx, sy*0.3+3/myY*sy, sx*0.2-6/myX*sx, sy*0.2, false, true, true)
                    addEventHandler("onClientRender", root, renderRBSPanel)
                    addEventHandler("onClientKey", root, rbsPanelKey)
                    setElementFrozen(localPlayer, true)
                else
                    if isElement(object3d) then
                        exports.oPreview:destroyObjectPreview(object3d)
                        destroyElement(object3d)
                    end
                    removeEventHandler("onClientRender", root, renderRBSPanel)
                    removeEventHandler("onClientKey", root, rbsPanelKey)
                    setElementFrozen(localPlayer, false)
                end
                rbsPanelShow = not rbsPanelShow
            else
                if rbsPanelShow then
                    if isElement(object3d) then
                        exports.oPreview:destroyObjectPreview(object3d)
                        destroyElement(object3d)
                    end
                    removeEventHandler("onClientRender", root, renderRBSPanel)
                    removeEventHandler("onClientKey", root, rbsPanelKey)
                    setElementFrozen(localPlayer, false)
                    rbsPanelShow = not rbsPanelShow
                end
            end
        else
            outputChatBox(core:getServerPrefix("red-dark", "Szögesdrót", 3).."Nem vagy rendvédelmi szervezet tagja, vagy nem vagy szolgálatban.", 255, 255, 255, true)
        end
    else
        outputChatBox(core:getServerPrefix("red-dark", "Szögesdrót", 3).."Nem vagy rendvédelmi szervezet tagja, vagy nem vagy szolgálatban.", 255, 255, 255, true)
    end
end

function replace3dobj()
    if isElement(object3d) then
        exports.oPreview:destroyObjectPreview(object3d)
        destroyElement(object3d)
    end

    object3d = createObject(rbs[selectedRBSLine].obj, 0, 0, 0)
    exports.oPreview:createObjectPreview(object3d, 0, 0, 0, sx*0.4+3/myX*sx, sy*0.3+3/myY*sy, sx*0.2-6/myX*sx, sy*0.2, false, true, true)
    setObjectScale(object3d, 0.7)
end

function pickUpRBS(obj, openType)
    if openType == "admin" then
        triggerServerEvent("factionScripts > pd > delRBS", resourceRoot, obj, true)
    else
        triggerServerEvent("factionScripts > pd > delRBS", resourceRoot, obj, false)
        chat:sendLocalMeAction("felvesz egy roadblockot.")
    end
end

-- pd JAil

local renderableDatas =  {
    ["in"] = {localPlayer},
    ["out"] = {localPlayer},
}

occupiedJailControllCol = false
local jailDatasPanelShowing = false

local selectedEditbox = false

local editboxDatas = {
    ["jail-reason"] = "",
    ["jail-time"] = "",
}

local selectedPlayer = false

function renderJailPanel()
    renderableDatas = {}
    if occupiedJailControllCol then
        renderableDatas["out"] = getElementsWithinColShape(occupiedJailControllCol, "player")
        renderableDatas["in"] = getElementsWithinColShape(getElementData(occupiedJailControllCol, "jailInCol"), "player")
    else
        closeJailPanel()
    end

    local height = (#renderableDatas["in"] + #renderableDatas["out"]) * sy*0.025 + sy*0.04 + 2/myY*sy
    dxDrawRectangle(sx*0.845, sy*0.5-height/2, sx*0.15, height, tocolor(35, 35, 35, 255))

    dxDrawRectangle(sx*0.845+2/myX*sx, sy*0.5-height/2+2/myY*sy, sx*0.15-4/myX*sx, sy*0.025-4/myY*sy, tocolor(40, 40, 40, 255))
    dxDrawText("Börtönben lévő játékosok", sx*0.845+2/myX*sx, sy*0.5-height/2+2/myY*sy, sx*0.845+2/myX*sx+sx*0.15-4/myX*sx, sy*0.5-height/2+2/myY*sy+sy*0.025-4/myY*sy, tocolor(r, g, b, 255), 0.8/myX*sx, fonts["condensed-10"], "center", "center")
    local startY = sy*0.5-height/2+2/myY*sy + sy*0.025-2/myY*sy

    for k, v in ipairs(renderableDatas["in"]) do
        dxDrawRectangle(sx*0.845+2/myX*sx, startY, sx*0.15-4/myX*sx, sy*0.025-4/myY*sy, tocolor(40, 40, 40, 255))

        if core:isInSlot(sx*0.845+2/myX*sx, startY, sx*0.15-4/myX*sx, sy*0.025-4/myY*sy) then
            dxDrawText("Kivétel a börtönből", sx*0.845+2/myX*sx, startY, sx*0.845+2/myX*sx+sx*0.15-4/myX*sx, startY+sy*0.025-4/myY*sy, tocolor(214, 65, 60, 255), 0.8/myX*sx, fonts["condensed-10"], "center", "center")
        else
            dxDrawText(getPlayerName(v):gsub("_", " ").." ("..(getElementData(v, "pd:jailTime") or 0).." perc)", sx*0.845+2/myX*sx, startY, sx*0.845+2/myX*sx+sx*0.15-4/myX*sx, startY+sy*0.025-4/myY*sy, tocolor(255, 255, 255, 255), 0.8/myX*sx, fonts["condensed-10"], "center", "center")
        end

        startY = startY + sy*0.025-2/myY*sy
    end

    dxDrawRectangle(sx*0.845+2/myX*sx, startY, sx*0.15-4/myX*sx, sy*0.025-4/myY*sy, tocolor(40, 40, 40, 255))
    dxDrawText("Szabad játékosok", sx*0.845+2/myX*sx, startY, sx*0.845+2/myX*sx+sx*0.15-4/myX*sx, startY+sy*0.025-4/myY*sy, tocolor(r, g, b, 255), 0.8/myX*sx, fonts["condensed-10"], "center", "center")
    startY = startY + sy*0.025-2/myY*sy

    for k, v in ipairs(renderableDatas["out"]) do
        dxDrawRectangle(sx*0.845+2/myX*sx, startY, sx*0.15-4/myX*sx, sy*0.025-4/myY*sy, tocolor(40, 40, 40, 255))

        if core:isInSlot(sx*0.845+2/myX*sx, startY, sx*0.15-4/myX*sx, sy*0.025-4/myY*sy) then
            if not (v == localPlayer) then
                dxDrawText("Börtönbe helyezés", sx*0.845+2/myX*sx, startY, sx*0.845+2/myX*sx+sx*0.15-4/myX*sx, startY+sy*0.025-4/myY*sy, tocolor(214, 65, 60, 255), 0.8/myX*sx, fonts["condensed-10"], "center", "center")
            else
                dxDrawText("Magadat nem helyezheted börtönbe", sx*0.845+2/myX*sx, startY, sx*0.845+2/myX*sx+sx*0.15-4/myX*sx, startY+sy*0.025-4/myY*sy, tocolor(214, 65, 60, 150), 0.8/myX*sx, fonts["condensed-10"], "center", "center")
            end
        else
            dxDrawText(getPlayerName(v):gsub("_", " "), sx*0.845+2/myX*sx, startY, sx*0.845+2/myX*sx+sx*0.15-4/myX*sx, startY+sy*0.025-4/myY*sy, tocolor(255, 255, 255, 255), 0.8/myX*sx, fonts["condensed-10"], "center", "center")
        end

        startY = startY + sy*0.025-2/myY*sy
    end

    if jailDatasPanelShowing then
        dxDrawRectangle(sx*0.4, sy*0.45, sx*0.2, sy*0.1, tocolor(35, 35, 35, 255))
        dxDrawRectangle(sx*0.4+2/myX*sx, sy*0.45+2/myY*sy, sx*0.2-4/myX*sx, sy*0.1-4/myY*sy, tocolor(40, 40, 40, 255))

        dxDrawRectangle(sx*0.4+3/myX*sx, sy*0.45+4/myY*sy, sx*0.2-6/myX*sx, sy*0.03, tocolor(35, 35, 35, 255))

        if core:isInSlot(sx*0.4+3/myX*sx, sy*0.45+4/myY*sy, sx*0.2-6/myX*sx, sy*0.03) or selectedEditbox == "jail-reason" then
            core:dxDrawOutLine(sx*0.4+3/myX*sx, sy*0.45+4/myY*sy, sx*0.2-6/myX*sx, sy*0.03, tocolor(r, g, b, 200), 1)
        end

        if string.len(editboxDatas["jail-reason"]) > 0 then
            dxDrawText(editboxDatas["jail-reason"], sx*0.4+3/myX*sx, sy*0.45+4/myY*sy, sx*0.4+3/myX*sx+sx*0.2-6/myX*sx, sy*0.45+4/myY*sy+sy*0.03, tocolor(255, 255, 255, 255), 0.95/myX*sx, fonts["condensed-10"], "center", "center")
        else
            dxDrawText("Büntetés indoka", sx*0.4+3/myX*sx, sy*0.45+4/myY*sy, sx*0.4+3/myX*sx+sx*0.2-6/myX*sx, sy*0.45+4/myY*sy+sy*0.03, tocolor(255, 255, 255, 200), 0.95/myX*sx, fonts["condensed-10"], "center", "center")
        end

        dxDrawRectangle(sx*0.4+3/myX*sx, sy*0.48+6/myY*sy, sx*0.2-6/myX*sx, sy*0.03, tocolor(35, 35, 35, 255))

        if core:isInSlot(sx*0.4+3/myX*sx, sy*0.48+6/myY*sy, sx*0.2-6/myX*sx, sy*0.03) or selectedEditbox == "jail-time" then
            core:dxDrawOutLine(sx*0.4+3/myX*sx, sy*0.48+6/myY*sy, sx*0.2-6/myX*sx, sy*0.03, tocolor(r, g, b, 200), 1)
        end

        if string.len(editboxDatas["jail-time"]) > 0 then
            dxDrawText(editboxDatas["jail-time"].." perc", sx*0.4+3/myX*sx, sy*0.48+6/myY*sy, sx*0.4+3/myX*sx+sx*0.2-6/myX*sx, sy*0.48+6/myY*sy+sy*0.03, tocolor(255, 255, 255, 255), 0.95/myX*sx, fonts["condensed-10"], "center", "center")
        else
            dxDrawText("Büntetés időtartama", sx*0.4+3/myX*sx, sy*0.48+6/myY*sy, sx*0.4+3/myX*sx+sx*0.2-6/myX*sx, sy*0.48+6/myY*sy+sy*0.03, tocolor(255, 255, 255, 200), 0.95/myX*sx, fonts["condensed-10"], "center", "center")
        end

        dxDrawRectangle(sx*0.4+3/myX*sx, sy*0.51+8/myY*sy, sx*0.095-6/myX*sx, sy*0.026, tocolor(35, 35, 35, 255))
        if core:isInSlot(sx*0.4+3/myX*sx, sy*0.51+8/myY*sy, sx*0.095-6/myX*sx, sy*0.026) then
            dxDrawText("Mégsem", sx*0.4+3/myX*sx, sy*0.51+8/myY*sy, sx*0.4+3/myX*sx+sx*0.095-6/myX*sx, sy*0.51+8/myY*sy+sy*0.026, tocolor(214, 65, 60, 255), 0.8/myX*sx, fonts["condensed-10"], "center", "center")
        else
            dxDrawText("Mégsem", sx*0.4+3/myX*sx, sy*0.51+8/myY*sy, sx*0.4+3/myX*sx+sx*0.095-6/myX*sx, sy*0.51+8/myY*sy+sy*0.026, tocolor(255, 255, 255, 255), 0.8/myX*sx, fonts["condensed-10"], "center", "center")
        end

        dxDrawRectangle(sx*0.505+3/myX*sx, sy*0.51+8/myY*sy, sx*0.095-6/myX*sx, sy*0.026, tocolor(35, 35, 35, 255))
        if core:isInSlot(sx*0.505+3/myX*sx, sy*0.51+8/myY*sy, sx*0.095-6/myX*sx, sy*0.026) then
            dxDrawText("Börtönbe helyezés", sx*0.505+3/myX*sx, sy*0.51+8/myY*sy, sx*0.505+3/myX*sx+sx*0.095-6/myX*sx, sy*0.51+8/myY*sy+sy*0.026, tocolor(r, g, b, 255), 0.8/myX*sx, fonts["condensed-10"], "center", "center")
        else
            dxDrawText("Börtönbe helyezés", sx*0.505+3/myX*sx, sy*0.51+8/myY*sy, sx*0.505+3/myX*sx+sx*0.095-6/myX*sx, sy*0.51+8/myY*sy+sy*0.026, tocolor(255, 255, 255, 255), 0.8/myX*sx, fonts["condensed-10"], "center", "center")
        end
    end
end

function keyJailPanel(key, state)
    if state then
        if key == "mouse1" then
            local height = (#renderableDatas["in"] + #renderableDatas["out"]) * sy*0.025 + sy*0.04 + 2/myY*sy

            local startY = sy*0.5-height/2+2/myY*sy + sy*0.025-2/myY*sy

            for k, v in ipairs(renderableDatas["in"]) do
                if core:isInSlot(sx*0.845+2/myX*sx, startY, sx*0.15-4/myX*sx, sy*0.025-4/myY*sy) then
                    if not (v == localPlayer) then
                        if getElementData(v, "pd:jail") then
                            triggerServerEvent("factionScripts > pd > jail > removeFromJail", resourceRoot, v, {getElementPosition(occupiedJailControllCol)})
                        end
                    end
                end

                startY = startY + sy*0.025-2/myY*sy
            end

            startY = startY + sy*0.025-2/myY*sy

            for k, v in ipairs(renderableDatas["out"]) do
                if core:isInSlot(sx*0.845+2/myX*sx, startY, sx*0.15-4/myX*sx, sy*0.025-4/myY*sy) then
                    if not (v == localPlayer) then
                        selectedPlayer = v
                        jailDatasPanelShowing = true
                    end
                end

                startY = startY + sy*0.025-2/myY*sy
            end

            if core:isInSlot(sx*0.4+3/myX*sx, sy*0.45+4/myY*sy, sx*0.2-6/myX*sx, sy*0.03) then
                selectedEditbox = "jail-reason"
            end

            if core:isInSlot(sx*0.4+3/myX*sx, sy*0.48+6/myY*sy, sx*0.2-6/myX*sx, sy*0.03) then
                selectedEditbox = "jail-time"
            end

            if jailDatasPanelShowing then
                if core:isInSlot(sx*0.4+3/myX*sx, sy*0.45+4/myY*sy, sx*0.2-6/myX*sx, sy*0.03) then
                    selectedEditbox = "jail-reason"
                end

                if core:isInSlot(sx*0.4+3/myX*sx, sy*0.48+6/myY*sy, sx*0.2-6/myX*sx, sy*0.03) then
                    selectedEditbox = "jail-time"
                end


                if core:isInSlot(sx*0.4+3/myX*sx, sy*0.51+8/myY*sy, sx*0.095-6/myX*sx, sy*0.026) then
                    jailDatasPanelShowing = false
                    selectedPlayer = false
                    selectedEditbox = false
                    editboxDatas = {
                        ["jail-reason"] = "",
                        ["jail-time"] = "",
                    }
                end

                if core:isInSlot(sx*0.505+3/myX*sx, sy*0.51+8/myY*sy, sx*0.095-6/myX*sx, sy*0.026) then
                    if tonumber(editboxDatas["jail-time"]) <= maxJailTime then
                        if string.len(editboxDatas["jail-reason"]) > 0 then
                            if not getElementData(selectedPlayer, "pd:jail") then
                                triggerServerEvent("factionScripts > pd > playerToPrison", resourceRoot, selectedPlayer, tonumber(editboxDatas["jail-time"]), editboxDatas["jail-reason"], {getElementPosition(getElementData(occupiedJailControllCol, "jailInCol"))})
                                infobox:outputInfoBox("Sikeresen bebörtönözted "..getPlayerName(selectedPlayer):gsub("_", " ").." nevű játékost.", "success")

                                jailDatasPanelShowing = false
                                selectedPlayer = false
                                selectedEditbox = false
                                editboxDatas = {
                                    ["jail-reason"] = "",
                                    ["jail-time"] = "",
                                }
                            else
                                infobox:outputInfoBox("Ez a játékos már börtönben van!", "error")
                            end
                        else
                            infobox:outputInfoBox("Nem adtál meg indokot!", "error")
                        end
                    else
                        infobox:outputInfoBox("Maximum "..maxJailTime.." perc börtön engedélyezett!", "error")
                    end
                end
            end
        end

        if selectedEditbox then
            --outputChatBox(selectedEditbox)
            key = key:gsub("num_", "")
            if core:keyIsRealKeyboardLetter(key) then
                if selectedEditbox == "jail-time" then
                    if tonumber(key) then
                        if ((tonumber(editboxDatas[selectedEditbox]) or 0) + tonumber(key)) <= maxJailTime then
                            editboxDatas[selectedEditbox] = editboxDatas[selectedEditbox] .. key
                        end
                    end
                else
                    editboxDatas[selectedEditbox] = editboxDatas[selectedEditbox] .. core:getHungarianKeyboardLetter(key:gsub("num_", ""))
                end
            elseif key == "backspace" then
                editboxDatas[selectedEditbox] = editboxDatas[selectedEditbox]:gsub("[^\128-\191][\128-\191]*$", "")
            elseif key == "space" then
                editboxDatas[selectedEditbox] = editboxDatas[selectedEditbox] .. " "
            end
            cancelEvent()
        end
    end
end

function openJailPanel()
    addEventHandler("onClientRender", root, renderJailPanel)
    addEventHandler("onClientKey", root, keyJailPanel)
end

function closeJailPanel()
    removeEventHandler("onClientRender", root, renderJailPanel)
    removeEventHandler("onClientKey", root, keyJailPanel)
end

local jailDatas = {"", ""}

function renderPDJailDatas()
	core:dxDrawShadowedText("Indok: "..color..jailDatas[2], sx*0.75, sy*0.91, sx*0.75+sx*0.24, sy*0.91+sy*0.03, tocolor(255,255,255,255), tocolor(0, 0, 0, 255), 0.9/myX*sx, fonts["condensed-12"], "right", "center", false, false, false, true)
	core:dxDrawShadowedText("Idő: "..color..jailDatas[1].." #ffffffperc", sx*0.75,sy*0.935, sx*0.75+sx*0.24, sy*0.935+sy*0.03, tocolor(255,255,255,255), tocolor(0, 0, 0, 255), 0.9/myX*sx, fonts["condensed-12"], "right", "center", false, false, false, true)
end

function startJailTimeCounting()
    jailQuitTimer = setTimer(function()
        local jailTime = getElementData(localPlayer, "pd:jailTime")

        if jailTime > 0 then
            setElementData(localPlayer, "pd:jailTime", jailTime - 1)
            jailDatas[1] = jailDatas[1] - 1
            if jailDatas[1] == 0 then
                if isTimer(jailQuitTimer) then killTimer(jailQuitTimer) end

                triggerServerEvent("factionScripts > pd > jail > quit", resourceRoot)
                outputChatBox(core:getServerPrefix("blue-light-2", "Börtön", 2).."Kiszabadultál a börtönből!", 255, 255, 255, true)
            end
        else
            if isTimer(jailQuitTimer) then killTimer(jailQuitTimer) end

            triggerServerEvent("factionScripts > pd > jail > quit", resourceRoot)
            outputChatBox(core:getServerPrefix("blue-light-2", "Börtön", 2).."Kiszabadultál a börtönből!", 255, 255, 255, true)
        end
    end, core:minToMilisec(1), 0)
end

local cuffAnim = {}

addEventHandler("onClientResourceStart", resourceRoot, function()
    if getElementData(localPlayer, "pd:jail") then
        jailDatas = {getElementData(localPlayer, "pd:jailTime"), getElementData(localPlayer, "pd:jailDatas")[2]}
        addEventHandler("onClientRender", root, renderPDJailDatas)
        startJailTimeCounting()
    end

    engineLoadIFP("files/cuff_stand.ifp", "cuff_standing2") -- standing
	engineLoadIFP("files/cuff_walk.ifp", "cuff_walking") -- walking
 --   engineLoadIFP("files/walking_cuffed.ifp", "cuff_walking")
end)

addEventHandler("onClientElementDataChange", root, function(data, old, new)
    if source == localPlayer then
        if data == "pd:jail" then
            if new then
                jailDatas = {getElementData(localPlayer, "pd:jailTime"), getElementData(localPlayer, "pd:jailDatas")[2]}
                addEventHandler("onClientRender", root, renderPDJailDatas)
                startJailTimeCounting()
            else
                removeEventHandler("onClientRender", root, renderPDJailDatas)
                if isTimer(jailQuitTimer) then killTimer(jailQuitTimer) end
            end
        end
    end

    if data == "cuff:cuffAnimation" then
        local dataValue = getElementData(source, "cuff:cuffAnimation")
        if dataValue == 1 then
            setPedAnimation(source, "cuff_standing2", "standing", -1, true, false)
        elseif dataValue == 2 then
            setPedAnimation(source, "cuff_walking", "walking", -1, true, true)
        else
            setPedAnimation(source)

        end
        --print(dataValue)
        if dataValue then
            cuffAnim[source] = dataValue
        else
            cuffAnim[source] = nil
        end
    --    if type(new) == "table" then
    --        local group, anim = unpack(new)
          --  setPedAnimation(source, group, anim, _, true, true, false, true)
    --    end
    end
end)

-- / Cuff / Grab / --
local txd = engineLoadTXD("files/cuff.txd")
engineImportTXD(txd, 18350)
local dff = engineLoadDFF("files/cuff.dff")
engineReplaceModel(dff, 18350, true)

setElementData(localPlayer, "cuff:cuffObj", false)
setElementData(localPlayer, "cuff:cuffObj2", false)

function cuffPlayer(target)
    if (getElementData(localPlayer, "cuff:cuffed") or false) then return end
    if isElement(target) then
        if core:getDistance(localPlayer, target) < 3 then
            if getElementData(target, "cuff:cuffed") then
                if not (target == localPlayer) then
                    if inventory:hasItem(78) then
                        if not getElementData(target, "carry:followedPlayer") then
                            triggerServerEvent("factionScripts > pd > setCuffState", resourceRoot, target, false)
                            outputChatBox(core:getServerPrefix("server", "Bilincs", 2).."Levetted a bilincset "..color..getPlayerName(target):gsub("_", " ").." #ffffff-ról/ről.", 255, 255, 255, true)
                            chat:sendLocalMeAction("levette a bilincset "..getPlayerName(target):gsub("_", " ").."-ról/ről.")
                            setElementData(target, "cuff:cuffAnimation", false)
                            cuffAnim[target] = nil
                        else
                            outputChatBox(core:getServerPrefix("red-dark", "Bilincs", 2).."Előbb engedd el!", 255, 255, 255, true)
                        end
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Bilincs", 2).."Nincs nálad bilincs kulcs!", 255, 255, 255, true)
                    end
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Bilincs", 2).."Magadról nem veheted le a bilincset!", 255, 255, 255, true)
                end
            else
                if not getPedOccupiedVehicle(localPlayer) then
                    if not getPedOccupiedVehicle(target) then
                        if not (target == localPlayer) then
                            local van, _, _, slot = inventory:hasItem(77)

                            if van then
                                inventory:takeItem(77)
                                triggerServerEvent("factionScripts > pd > setCuffState", resourceRoot, target, true)
                                outputChatBox(core:getServerPrefix("server", "Bilincs", 2).."Megbilincselted "..color..getPlayerName(target):gsub("_", " ").." #ffffff(e)-t.", 255, 255, 255, true)
                                chat:sendLocalMeAction("megbilincselte "..getPlayerName(target):gsub("_", " ").."-(e)t.")
                                setElementData(target, "cuff:cuffAnimation", 1)
                                cuffAnim[target] = 0
                            else
                                outputChatBox(core:getServerPrefix("red-dark", "Bilincs", 2).."Nincs nálad bilincs!", 255, 255, 255, true)
                            end
                        else
                            outputChatBox(core:getServerPrefix("red-dark", "Bilincs", 2).."Magadat nem bilincselheted meg!", 255, 255, 255, true)
                        end
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Bilincs", 2).."Járműben ülő játékost nem bilincselhetsz meg.", 255, 255, 255, true)
                    end
                end
            end
        else
            outputChatBox(core:getServerPrefix("red-dark", "Bilincs", 2).."Ez a játékos túl messze van tőled.", 255, 255, 255, true)
        end
    end
end

function grabPlayer(target)
    if (getElementData(localPlayer, "cuff:cuffed") or false)  then return end
    if isElement(target) then
        if core:getDistance(localPlayer, target) < 3 then
            if getElementData(target, "cuff:cuffed") or getElementData(target,"player:bag") then
                if not (target == localPlayer) then
                    if not getElementData(target, "carry:followedPlayer") then
                        triggerServerEvent("factionScripts > pd > setCarryState", resourceRoot, target, true)
                        chat:sendLocalMeAction("elkezdte vinni "..getPlayerName(target):gsub("_", " ").."-(e)t.")
                        toggleControl("sprint", false)
                        toggleControl("jump", false)
                        if getElementData(target ,"player:bagBAG") then
                            setElementData(target, "cuff:cuffAnimation", false)
                            cuffAnim[target] = nil
                        end
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Bilincs", 2).."Ezt a játékost már viszi valaki.", 255, 255, 255, true)
                    end
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", "Bilincs", 2).."Csak olyan játékosokat vihetsz, aki meg van bilincselve vagy zsák van a fejükön.", 255, 255, 255, true)
            end
        else
            outputChatBox(core:getServerPrefix("red-dark", "Bilincs", 2).."Ez a játékos túl messze van tőled.", 255, 255, 255, true)
        end
    end
end

function unleashPlayer(target)
    if isElement(target) then
        if core:getDistance(localPlayer, target) < 3 then
            if (target == getElementData(localPlayer, "carry:carryedPlayer")) then
                triggerServerEvent("factionScripts > pd > setCarryState", resourceRoot, target, false)
                outputChatBox(core:getServerPrefix("server", "Bilincs", 2).."Elengedted "..color..getPlayerName(target):gsub("_", " ").." #ffffff(e)-t.", 255, 255, 255, true)
                chat:sendLocalMeAction("elengedte "..getPlayerName(target):gsub("_", " ").."-(e)t.")
                setElementData(target, "carry:carryedPlayer", false)
                toggleControl("sprint", true)
                toggleControl("jump", true)
                if getElementData(target ,"player:bagBAG") then
                    setElementData(target, "cuff:cuffAnimation", false)
                    cuffAnim[target] = nil
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", "Bilincs", 2).."Csak olyan embereket engedhetsz el akiket te viszel.", 255, 255, 255, true)
            end
        else
            outputChatBox(core:getServerPrefix("red-dark", "Bilincs", 2).."Ez a játékos túl messze van tőled.", 255, 255, 255, true)
        end
    end
end

local lastTrigger = 0

addEventHandler("onClientPreRender", root, function()
    for k, v in ipairs(getElementsByType("player", root, false)) do
        local carryedPlayer = getElementData(v, "carry:carryedPlayer") or false
        if carryedPlayer then
            if not isElement(carryedPlayer) then return end
            if not getPedOccupiedVehicle(carryedPlayer) then
                if core:getDistance(carryedPlayer, v) >= 1.5 then
                    local sourcePosX, sourcePosY, sourcePosZ = getElementPosition(v)
                    local targetPosX, targetPosY, targetPosZ = getElementPosition(carryedPlayer)
                    local deltaX = targetPosX - sourcePosX
                    local deltaY = targetPosY - sourcePosY

                    local sourceRotX, sourceRotY, sourceRotZ = getElementRotation(v)
                    setElementRotation(carryedPlayer, sourceRotX, sourceRotY, -math.deg(math.atan2(deltaX, deltaY)), "default", true)
                    --setElementPosition(carryedPlayer, mainPos.x+0.7, mainPos.y+0.7, mainPos.z)

                    --if not (getElementData(carryedPlayer, "cuff:walking") or false) then
                       -- setElementData(carryedPlayer, "cuff:cuffAnimation", {"cuff_walking", "walking"})
                      --  setElementData(carryedPlayer, "cuff:walking", true)
                    --end
                    --print(getElementDimension(v), getElementDimension(carryedPlayer))
                    if v == localPlayer then
                        if (getElementDimension(v) ~= getElementDimension(carryedPlayer)) or (getElementInterior(v) ~= getElementInterior(carryedPlayer)) then
                            --setElementPosition(carryedPlayer, getElementDimension(v), getElementInterior(v))
                            triggerServerEvent("factionScripts > pd > setCarryedPlayerIntDim", resourceRoot, carryedPlayer, getElementDimension(v), getElementInterior(v))
                        end
                    end

                    local sourcePosX, sourcePosY, sourcePosZ = getElementPosition(carryedPlayer)
					local targetPosX, targetPosY, targetPosZ = getElementPosition(v)

					local deltaX = targetPosX - sourcePosX
                    local deltaY = targetPosY - sourcePosY

                    local sourceRotX, sourceRotY, sourceRotZ = getElementRotation(carryedPlayer)
                    setElementRotation(carryedPlayer, sourceRotX, sourceRotY, -math.deg(math.atan2(deltaX, deltaY)), "default", true)
                  --  if cuffAnim[carryedPlayer] then
                        if cuffAnim[carryedPlayer] ~= 2 then
                            cuffAnim[carryedPlayer] = 2
                            setElementData(carryedPlayer, "cuff:cuffAnimation", 2)
                        end
                    --end
                else
                    if cuffAnim[carryedPlayer] then
                        if cuffAnim[carryedPlayer] ~= 1 then
                            cuffAnim[carryedPlayer] = 1
                            setElementData(carryedPlayer, "cuff:cuffAnimation", 1)
                        end
                    end
                    --setElementData(carryedPlayer, "cuff:cuffAnimation", {"cuff_standing2", "standing"})
                    --setElementData(carryedPlayer, "cuff:walking", false)
                    --setPedAnimation(localPlayer)
                end

                local boneX, boneY, boneZ = getPedBonePosition(carryedPlayer, 35)
                local boneX1, boneY1, bonZ1 = getPedBonePosition(v, 25)
                dxDrawLine3D(boneX, boneY, boneZ, boneX1, boneY1, bonZ1, tocolor(0, 0, 0, 255), 1)
            else
                --setElementData(carryedPlayer, "cuff:cuffAnimation", {"car", "sit_relaxed"})
            end
        end

        if isElement(getElementData(v, "cuff:cuffObj")) then
            local boneX2, boneY2, boneZ2 = core:getPositionFromElementOffset(getElementData(v, "cuff:cuffObj"), -0.04, 0, -0.03)
            local boneX3, boneY3, boneZ3 = core:getPositionFromElementOffset(getElementData(v, "cuff:cuffObj2"), -0.04, 0, -0.03)

            dxDrawLine3D(boneX2, boneY2, boneZ2, boneX3, boneY3, boneZ3, tocolor(40, 40, 40, 255), 1)
        end
    end
end)

addEventHandler("onClientVehicleEnter", root, function(player)
    if player == localPlayer then
        local carryedPlayer = getElementData(player, "carry:carryedPlayer") or false

        if carryedPlayer then
            if not getPedOccupiedVehicle(carryedPlayer) then

                local seat = 0
                for k, v in pairs(getVehicleOccupants(source)) do
                    seat = k + 1
                end

                triggerServerEvent("factionScripts > pd > warpPedIntoVehicle", resourceRoot, carryedPlayer, source, 1)
            end
        end
    end
end)

addEventHandler("onClientVehicleExit", root, function(player)
    if player == localPlayer then
        local carryedPlayer = getElementData(player, "carry:carryedPlayer") or false

        if carryedPlayer then
            if getPedOccupiedVehicle(carryedPlayer) then
                triggerServerEvent("factionScripts > pd > warpPedOutVehicle", resourceRoot, carryedPlayer)
                setTimer(function()
                    setElementData(carryedPlayer, "cuff:cuffAnimation", 2)
                    cuffAnim[carryedPlayer] = 2
                end,500,1)

            end
        end
    end
end)

addEventHandler("onClientPlayerQuit", root, function()
    if source == localPlayer then
        if getElementData(localPlayer, "carry:carryedPlayer") then
            triggerServerEvent("factionScripts > pd > setCarryState", resourceRoot, getElementData(localPlayer, "carry:carryedPlayer"), false)
        end
    end

    if getElementData(localPlayer, "cuff:usePlayer") then
        if getElementData(localPlayer, "cuff:usePlayer") == source then
            triggerServerEvent("factionScripts > pd > setCuffState", resourceRoot, localPlayer, false)
        end
    end
end)

-- Villogo --
local txd = engineLoadTXD("files/policeLight.txd")
engineImportTXD(txd, 17098)
local dff = engineLoadDFF("files/policeLight.dff")
engineReplaceModel(dff, 17098, true)

function applyPoliceLightToOccupiedVehicle()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return false end
    if getElementData(veh, "veh:policeLightActive") then return end
    if getElementData(veh, "veh:taxiLightActive") then return end
    if policeLightPositions[getElementModel(veh)] then
        triggerServerEvent("factionScripts > police > addPoliceLight", resourceRoot, veh, policeLightPositions[getElementModel(veh)])
        return true
    else
        return false
    end
end

function removePoliceLightFromOccupiedVehicle()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return false end
    if not getElementData(veh, "veh:policeLightActive") then return end
    if policeLightPositions[getElementModel(veh)] then
        triggerServerEvent("factionScripts > police > removePoliceLight", resourceRoot, veh)
        return true
    else
        return false
    end
end

-- Sokkoló --
fadeCamera(true)
setElementData(localPlayer, "char:shocked", false)

addEventHandler("onClientPlayerDamage", root, function(attacker, weapon, body, loss)
    if weapon == 23 then
        cancelEvent()

        if source == localPlayer then
            if getElementData(localPlayer, "user:aduty") then return end
            if getElementData(localPlayer, "char:shocked") then return end

            fadeCamera(false, 0.1, 255, 255, 255)
            setElementFrozen(localPlayer, true)
            setElementData(localPlayer, "char:shocked", true)
            triggerServerEvent("factionScripts > pd > shockPlayer", resourceRoot, true)

            setTimer(function()
                fadeCamera(true, 10.0, 255, 255, 255)
                setElementFrozen(localPlayer, false)

                setTimer(function()
                    setElementData(localPlayer, "char:shocked", false)
                    triggerServerEvent("factionScripts > pd > shockPlayer", resourceRoot, false)
                end, 10000, 1)
            end, 15000, 1)
        end
    end
end)

addEventHandler("onClientWorldSound", root, function(group, index, x, y, z)
    if (group == 5 and index == 76) or (group == 5 and index == 77) or (group == 5 and index == 24) then
        cancelEvent()
    end
end)

addEvent("factionScripts > pd > playShockSound", true)
addEventHandler("factionScripts > pd > playShockSound", root, function(x, y, z)
    playSound3D("files/sokkolo2.wav", x, y, z, false)
end)

local lastShot = 0
addEventHandler ("onClientPlayerWeaponFire", root, function (weapon, ammo, ammoInClip)
    local x,y,z = getElementPosition (source)
    if weapon == 23 then
        if source == localPlayer then
            if lastShot + 2500 < getTickCount() then
                lastShot = getTickCount()
            else
                cancelEvent()
            end
        end

        local sound = playSound3D("files/sokkolo1.wav", x, y, z, false)
        setSoundVolume (sound, 1)
        setSoundMaxDistance (sound, 75)
    end
end)

-- Jármű lefoglalás
local bookedCarsMarker = createMarker(2024.1899414062, -2193.2514648438, 13.546875-8, "cylinder", 8.0, 255, 43, 43, 255)
local bookedCarsPed = createPed(113, 1954.8487548828, -2181.6245117188, 13.586477279663, 270)
setElementFrozen(bookedCarsPed, true)
setElementData(bookedCarsPed, "ped:name", "Adam Gibson")
setElementData(bookedCarsPed, "ped:prefix", "Telephelyvezető")

addEventHandler("onClientClick", root, function(key, state, _, _, _, _, _, element)
    if element then
        if key == "right" and state == "up" then
            if element == bookedCarsPed then
                if core:getDistance(bookedCarsPed, localPlayer) < 3 then
                    openbC_Panel()
                end
            end
        end
    end
end)

addEventHandler("onClientMarkerHit", resourceRoot, function(player, mdim)
    if player == localPlayer and mdim then
        if source == bookedCarsMarker then
            local pFaction = getElementData(localPlayer, "char:duty:faction") or 0

            if faction:getFactionType(pFaction) == 1 then
                if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    local occupiedVeh = getPedOccupiedVehicle(localPlayer)

                    if getElementModel(occupiedVeh) == 525 then
                        local towedVeh = getVehicleTowedByVehicle(occupiedVeh)
                        if towedVeh then
                            if getElementData(towedVeh, "veh:isFactionVehice") == 0 then
                                infobox:outputInfoBox("Sikeresen lefoglaltad a járművet!", "success")
                                triggerServerEvent("factionScripts > pd > bookVehicle", resourceRoot, occupiedVeh, towedVeh)
                            else
                                infobox:outputInfoBox("Szervezethez tartozó járművet nem foglalhatsz le!", "error")
                            end
                        end
                    end
                end
            end
        end
    end
end)

local bookedCars = {}
local bookedCarsScroll = 0
local bC_PanelAlpha, bC_PanelTick, bC_PanelAnimState = 0, getTickCount(), "open"

function renderBookedCarsPanel()
    if core:getDistance(bookedCarsPed, localPlayer) > 3 then
        closebC_Panel()
    end

    if bC_PanelAnimState == "open" then
        bC_PanelAlpha = interpolateBetween(bC_PanelAlpha, 0, 0, 1, 0, 0, (getTickCount() - bC_PanelTick) / 500, "Linear")
    else
        bC_PanelAlpha = interpolateBetween(bC_PanelAlpha, 0, 0, 0, 0, 0, (getTickCount() - bC_PanelTick) / 500, "Linear")
    end

    dxDrawRectangle(sx*0.4, sy*0.3, sx*0.2, sy*0.4, tocolor(30, 30, 30, 150 * bC_PanelAlpha))
    dxDrawRectangle(sx*0.4 + 2/myX*sx, sy*0.3 + 2/myY*sy, sx*0.2 - 4/myX*sx, sy*0.4 - 4/myY*sy, tocolor(35, 35, 35, 255 * bC_PanelAlpha))

    dxDrawText("originalRoleplay", sx*0.4, sy*0.3, sx*0.4+sx*0.2, sy*0.3 + sy*0.04, tocolor(255, 255, 255, 255 * bC_PanelAlpha), 1, font:getFont("condensed", 10/myX*sx), "center", "center")
    dxDrawText("Lefoglalt járművek", sx*0.4, sy*0.3, sx*0.4+sx*0.2, sy*0.3 + sy*0.1, tocolor(r, g, b, 255 * bC_PanelAlpha), 1, font:getFont("bebasneue", 18/myX*sx), "center", "center")

    local startY = sy*0.375
    for i = 1, 7 do
        local color2 = tocolor(40, 40, 40, 200 * bC_PanelAlpha)

        if (i % 2) == 0 then
            color2 = tocolor(40, 40, 40, 100 * bC_PanelAlpha)
        end

        dxDrawRectangle(sx*0.402, startY, sx*0.19, sy*0.044, color2)

        local v = bookedCars[i + bookedCarsScroll]
        if v then
            dxDrawText(vehicle:getModdedVehicleName(v), sx*0.408, startY, sx*0.408 + sx*0.19, startY + sy*0.044, tocolor(255, 255, 255, 255 * bC_PanelAlpha), 1, font:getFont("condensed", 10/myX*sx), "left", "center")

            local buttonText = "Kiváltás"

            if core:isInSlot(sx*0.54, startY + 5/myY*sy, sx*0.05, sy*0.032) then
                buttonText = bookedCarTriggeringPrice.."$"
            end

            core:dxDrawButton(sx*0.54, startY + 5/myY*sy, sx*0.05, sy*0.032, r, g, b, 255 * bC_PanelAlpha, buttonText, tocolor(255, 255, 255, 255 * bC_PanelAlpha), 0.9, font:getFont("condensed", 10/myX*sx), true, tocolor(0, 0, 0, 50 * bC_PanelAlpha))
        end

        startY = startY + sy*0.046
    end

    dxDrawRectangle(sx*0.595, sy*0.375, sx*0.002, sy*0.32, tocolor(r, g, b, 100 * bC_PanelAlpha))

    local lineHeight = math.min(7 / (#bookedCars or 0), 1)
    dxDrawRectangle(sx*0.595, sy*0.375 + (sy*0.32 * (lineHeight * bookedCarsScroll/7)), sx*0.002, sy*0.32 * lineHeight, tocolor(r, g, b, 255 * bC_PanelAlpha))
end

function keyBookedCarsPanel(key, state)
    if state then
        if key == "mouse_wheel_up" then
            if bookedCarsScroll > 0 then
                bookedCarsScroll = bookedCarsScroll - 1
            end
        elseif key == "mouse_wheel_down" then
            if bookedCars[bookedCarsScroll + 8] then
                bookedCarsScroll = bookedCarsScroll + 1
            end
        elseif key == "mouse1" then
            local startY = sy*0.375
            for i = 1, 7 do
                local v = bookedCars[i + bookedCarsScroll]
                if v then
                    if core:isInSlot(sx*0.54, startY + 5/myY*sy, sx*0.05, sy*0.032) then
                        if getElementData(localPlayer, "char:money") >= bookedCarTriggeringPrice then
                            triggerServerEvent("factionScripts > pd > bookedCarTriggering", resourceRoot, v)
                            outputChatBox(core:getServerPrefix("green-dark", "Lefoglalt jármű", 3).."Sikeresen kiváltottad a járművedet "..color..bookedCarTriggeringPrice.."$#ffffff-ért.", 255, 255, 255, true)
                            infobox:outputInfoBox("Sikeresen kiváltottad a járművedet "..bookedCarTriggeringPrice.."$-ért.", "success")
                            table.remove(bookedCars, i + bookedCarsScroll)
                        else
                            infobox:outputInfoBox("Nincs elég pénzed a jármű kiváltásához! ("..bookedCarTriggeringPrice.."$)", "error")
                        end
                    end
                end

                startY = startY + sy*0.046
            end
        elseif key == "backspace" then
            closebC_Panel()
        end
    end
end

local bCPanelCloseing = false
function openbC_Panel()
    if bCPanelCloseing then return end
    bC_PanelAnimState = "open"
    bC_PanelTick = getTickCount()
    addEventHandler("onClientRender", root, renderBookedCarsPanel)
    addEventHandler("onClientKey", root, keyBookedCarsPanel)

    bookedCars = {}
    local charId = getElementData(localPlayer, "char:id")
    for k, v in ipairs(getElementsByType("vehicle")) do
        if getElementData(v, "veh:owner") == charId then
            if getElementData(v, "vehIsBooked") == 1 then
                table.insert(bookedCars, v)
            end
        end
    end
end

function closebC_Panel()
    if bCPanelCloseing then return end
    bCPanelCloseing = true
    bC_PanelAnimState = "close"
    bC_PanelTick = getTickCount()
    removeEventHandler("onClientKey", root, keyBookedCarsPanel)

    setTimer(function()
        bCPanelCloseing = false
        removeEventHandler("onClientRender", root, renderBookedCarsPanel)
    end, 500, 1)
end

-- Fegyverengedély
local lastFirearmLicense = 0
addCommandHandler("givefirearmlicense", function(cmd, id)
    local pFaction = getElementData(localPlayer, "char:duty:faction") or 0

    if pFaction == policeFactionID then
        if faction:isPlayerLeader(pFaction) then
            if tonumber(id) then
                local player = core:getPlayerFromPartialName(localPlayer, tonumber(id), false, 2)
                if player then
                    if core:getDistance(player, localPlayer) < 4 then
                        if lastFirearmLicense + 15000 < getTickCount() then
                            if getElementData(localPlayer, "char:money") >= 12500 then
                                setElementData(localPlayer, "char:money", getElementData(localPlayer, "char:money") - 12500)
                                outputChatBox(core:getServerPrefix("green-dark", "Fegyverengedély", 2).."Sikeresen kiállítottál egy fegyverengedélyt "..color..getPlayerName(player):gsub("_", " ").."#ffffff-nak/nek "..color.."12.500$#ffffff-ért.", 255, 255, 255, true)
                                lastFirearmLicense = getTickCount()
                                triggerServerEvent("factionScripts > pd > giveFirearmLicense", resourceRoot, player)
                            else
                                outputChatBox(core:getServerPrefix("red-dark", "Fegyverengedély", 2).."Nincs nálad elegendő pénz a fegyverengedély kiállításához! "..color.."(12.500$)", 255, 255, 255, true)
                            end
                        else
                            outputChatBox(core:getServerPrefix("red-dark", "Fegyverengedély", 2).."Csak "..color.."15#ffffff másodpercenkén tállíthatsz ki fegyverengedélyt!", 255, 255, 255, true)
                        end
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Fegyverengedély", 2).."Túl távol vagy!", 255, 255, 255, true)
                    end
                end
            else
                outputChatBox(core:getServerPrefix("server", "Használat", 3).."/"..cmd.." [Játékos ID]", 255, 255, 255, true)
            end
        end
    end
end)

addCommandHandler("givehuntinglicense", function(cmd, id)
    local pFaction = getElementData(localPlayer, "char:duty:faction") or 0

    if pFaction == policeFactionID then
        if faction:isPlayerLeader(pFaction) then
            if tonumber(id) then
                local player = core:getPlayerFromPartialName(localPlayer, tonumber(id), false, 2)
                if player then
                    if core:getDistance(player, localPlayer) < 4 then
                        if lastFirearmLicense + 15000 < getTickCount() then
                            if getElementData(localPlayer, "char:money") >= 10000 then
                                setElementData(localPlayer, "char:money", getElementData(localPlayer, "char:money") - 10000)
                                outputChatBox(core:getServerPrefix("green-dark", "Vadászati engedély", 2).."Sikeresen kiállítottál egy vadászati engedélyt "..color..getPlayerName(player):gsub("_", " ").."#ffffff-nak/nek "..color.."10.000$#ffffff-ért.", 255, 255, 255, true)
                                lastFirearmLicense = getTickCount()
                                triggerServerEvent("factionScripts > pd > giveHuntingLicense", resourceRoot, player)
                            else
                                outputChatBox(core:getServerPrefix("red-dark", "Vadászati engedély", 2).."Nincs nálad elegendő pénz a vadászati engedély kiállításához! "..color.."(10.000$)", 255, 255, 255, true)
                            end
                        else
                            outputChatBox(core:getServerPrefix("red-dark", "Vadászati engedély", 2).."Csak "..color.."15#ffffff másodpercenkén tállíthatsz ki fegyverengedélyt!", 255, 255, 255, true)
                        end
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Vadászati engedély", 2).."Túl távol vagy!", 255, 255, 255, true)
                    end
                end
            else
                outputChatBox(core:getServerPrefix("server", "Használat", 3).."/"..cmd.." [Játékos ID]", 255, 255, 255, true)
            end
        end
    end
end)

-- Álnév
local createdAlnevMarkers = {}

function createAlnevMarkers()
    for k, v in ipairs(alnevMarkers) do
        local marker = createMarker(v[1], v[2], v[3] - 1.5, "cylinder", 1.2, 245, 78, 66, 100)
        setElementInterior(marker, v[4])
        setElementDimension(marker, v[5])
        createdAlnevMarkers[marker] = true
    end
end
createAlnevMarkers()

addEventHandler("onClientRender", root, function()
    for k, v in pairs(createdAlnevMarkers) do
        if isElementStreamedIn(k) then
            local distance = core:getDistance(k, localPlayer)
            if distance < 10 then
                local markerX, markerY, markerZ = getElementPosition(k)
                markerZ = markerZ + 1.5
                local x, y = getScreenFromWorldPosition(markerX, markerY, markerZ )

                if x and y then
                    local imageSize = 100 * (1 - distance/10)
                    dxDrawImage(x - imageSize/2, y - imageSize/2, imageSize, imageSize, "files/spy.png", 0, 0, 0, tocolor(255, 255, 255, 255))
                end
            end
        end
    end
end)

local lastNameChange = 0
addCommandHandler("alnev", function(cmd, ...)
    local hasRight = false

    for k, v in pairs(createdAlnevMarkers) do
        if isElementWithinMarker(localPlayer, k) then
            hasRight = true
            break
        end
    end

    if hasRight then
        if (getElementData(localPlayer, "char:duty:faction") or 0) == detectiveFactionID then
            if lastNameChange + core:minToMilisec(5) < getTickCount() then
                if ... then
                    local name = table.concat({...}, "_")

                    if string.len(name) > 8 and string.find(name, "_") then
                        triggerServerEvent("factionScripts > pd > changeName", resourceRoot, name)
                        lastNameChange = getTickCount()
                        outputChatBox(core:getServerPrefix("green-dark", "Álnév", 2).."Sikeresen nevet változtattál. "..color.."("..name:gsub("_", " ")..")", 255, 255, 255, true)
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Álnév", 2).."A név túl rövid vagy nem megfelelő formátumú.", 255, 255, 255, true)
                    end
                else
                    outputChatBox(core:getServerPrefix("blue-light-2", "Használat", 3).."/"..cmd.." [Álnév]", 255, 255, 255, true)
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", "Álnév", 2).."Ezt a lehetőséget csak "..color.."5 #ffffffpercenként használhatod.", 255, 255, 255, true)
            end
        end
    end
end)


-- helicopter camera
local cameras = {}

function attachCamHeli(helicopter)
  if getElementModel(helicopter) == 497 then
    cameras[helicopter] = createObject(1622,0,0,0)
    attachElements(cameras[helicopter],helicopter,-0.2,3.5,-0.5,30,-60,-100)

    setObjectScale(cameras[helicopter],0.5)
  end
end
addEvent("attachCamHeli",true)
addEventHandler("attachCamHeli",root,attachCamHeli)

function detachCamHeli(helicopter)
  if getElementModel(helicopter) == 497 then
    detachElements(cameras[helicopter],helicopter)
    destroyElement(cameras[helicopter])
  end
end
addEvent("detachCamHeli",true)
addEventHandler("detachCamHeli",root,detachCamHeli)

function attachCameraToHeli()
  for k,v in pairs(getElementsByType("vehicle")) do
    if getElementModel(v) == 497 then
      attachCamHeli(v)
    end
  end
end
addEventHandler("onClientResourceStart",resourceRoot,attachCameraToHeli)

addCommandHandler("camerafix",function()
  if getElementData(localPlayer,"user:admin") >= 3 then
    for k,v in pairs(getElementsByType("vehicle")) do
      if getElementModel(v) == 497 then
        attachCamHeli(v)
      end
    end
  end
end)

addEventHandler("onClientElementDestroy", getRootElement(), function ()
	if getElementType(source) == "vehicle" and getElementModel(source) == 497 then
		detachCamHeli(source)
	end
end)

local top = sx*0.45
local left = sx*0.5
local windowOffsetX, windowOffsetY = 0, 0
local isDraggingWindow = false
local activeCamera = false

local CamrotX = 0
local CamrotY = 10

function renderCameraPanel()
  --dxDrawText(rbs[i+rbsPointer].name, sx*0.4+10/myX*sx, startY, sx*0.4+10/myX*sx+sx*0.2-6/myX*sx, startY+sy*0.03, tocolor(r, g, b, 255), 0.8/myX*sx, fonts["condensed-12"], "left", "center")
  if isCursorShowing() then
		cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX * sx, cursorY * sy
	end

	if isDraggingWindow then
		left, top = cursorX + windowOffsetX, cursorY + windowOffsetY
    vx,vy = cursorX, cursorY
	end

  if not activeCamera then
    r, g, b = 249,145,1
  else
    local time = getRealTime()
  	local hours = time.hour
  	local minutes = time.minute
  	local seconds = time.second

      local monthday = time.monthday
  	local month = time.month
  	local year = time.year

      year = year + 1900
      month = month + 1

      if month <= 9 then month = "0"..month end
      if monthday <= 9 then monthday = "0"..monthday end

    r, g, b = interpolateBetween(19,93,216, 191, 61, 61, getTickCount() / 1000, "CosineCurve");

    dxDrawImage(sx*0.0,sy*0.0,sx*0.99,sy*0.99,"files/camera.png")
    dxDrawText("✖",sx*0.48,sy*0.45,_,_,tocolor(255,255,255,255),0.0006*sx,fonts["condensed-12"])

    dxDrawText(month,sx*0.87 - dxGetTextWidth(month,0.00070*sx,fonts["condensed-12"])/2,sy*0.875,_,_,tocolor(255,255,255,255),0.00070*sx,fonts["condensed-12"])
    dxDrawText(monthday,sx*0.91 - dxGetTextWidth(monthday,0.00070*sx,fonts["condensed-12"])/2,sy*0.875,_,_,tocolor(255,255,255,255),0.00070*sx,fonts["condensed-12"])

    dxDrawText("NIGHT\nVISION", sx*0.065 - 1,sy*0.075 + 1,_,_, tocolor(0, 0, 0, 255), 0.00031*sx, fonts["condensed-12"], "center", "center",false,false,false,true)
    dxDrawText("NIGHT\nVISION", sx*0.065,sy*0.075,_,_, tocolor(255, 255, 255, 255), 0.00031*sx, fonts["condensed-12"], "center", "center",false,false,false,true)

    dxDrawText("THERMO\nVISION", sx*0.09 - 1,sy*0.075 + 1,_,_, tocolor(0, 0, 0, 255), 0.00031*sx, fonts["condensed-12"], "center", "center",false,false,false,true)
    dxDrawText("THERMO\nVISION", sx*0.09,sy*0.075,_,_, tocolor(255, 255, 255, 255), 0.00031*sx, fonts["condensed-12"], "center", "center",false,false,false,true)

    dxDrawText("OFF", sx*0.114 - 1,sy*0.075 + 1,_,_, tocolor(0, 0, 0, 255), 0.00045*sx, fonts["condensed-12"], "center", "center",false,false,false,true)
    dxDrawText("OFF", sx*0.114,sy*0.075,_,_, tocolor(255, 255, 255, 255), 0.00045*sx, fonts["condensed-12"], "center", "center",false,false,false,true)

    if exports.oCore:isInSlot(sx*0.0,sy*0.0,sx*0.9999,sy*0.05) then
      if CamrotY < 17 then
        CamrotY = CamrotY + 0.1
      end
    end

    if exports.oCore:isInSlot(sx*0.0,sy*0.93,sx*0.9999,sy*0.08) then
      if CamrotY > 10 then
        CamrotY = CamrotY - 0.1
      end
    end

    if exports.oCore:isInSlot(sx*0.0,sy*0.0,sx*0.05,sy*0.9999) then --bal
        CamrotX = CamrotX + 0.02
    end

    if exports.oCore:isInSlot(sx*0.9425,sy*0.0,sx*0.08,sy*0.9999) then --jobb
        CamrotX = CamrotX - 0.02
    end


    if isCursorShowing() then
      local posX,posY,posZ = getElementPosition(localPlayer)
      local rotX, rotY, rotZ = getElementRotation(localPlayer)

      targetX, targetZ = reMap(cursorX, 0, 1, 80, -80), reMap(cursorY, 0, 1, posZ + 10, posZ - 10)
      local angle = math.rad(rotZ + 45)
      local cornerX, cornerY = posX, posY
      local pointX, pointY = cornerX + 10, cornerY + 10
      local rotatedX = math.cos(angle + math.rad(targetX)) * (pointX - cornerX) - math.sin(angle + math.rad(targetX)) * (pointY - cornerY) + cornerX
      local rotatedY = math.sin(angle + math.rad(targetX)) * (pointX - cornerX) + math.cos(angle + math.rad(targetX)) * (pointY - cornerY) + cornerY
      local cornerX2, cornerY2 = posX, posY
      local pointX2, pointY2 = cornerX2 + 0.3, cornerY2 + 0.3
      local rotatedX2 = math.cos(angle) * (pointX2 - cornerX2) - math.sin(angle) * (pointY2 - cornerY2) + cornerX2
      local rotatedY2 = math.sin(angle) * (pointX2 - cornerX2) + math.cos(angle) * (pointY2 - cornerY2) + cornerY2

        local cx,cy,x2, y2, z2 = getCursorPosition()

        local hitState, hitX, hitY, hitZ, hitElement = processLineOfSight(rotatedX2, rotatedY2, posZ - 1, x2, y2, z2, true, true, true, true)

        if hitElement and getElementType(hitElement) == "vehicle" then
        dxDrawText(exports.oVehicle:getModdedVehicleName(hitElement),sx*0.52 - dxGetTextWidth("Rendszám: "..getVehiclePlateText(hitElement),0.00045*sx,fonts["condensed-12"])/2 - 1,sy*0.42 + 1,_,_, tocolor(0, 0, 0, 255), 0.00045*sx, fonts["condensed-12"], "center", "center",false,false,false,true)
        dxDrawText(exports.oVehicle:getModdedVehicleName(hitElement),sx*0.52 - dxGetTextWidth("Rendszám: "..getVehiclePlateText(hitElement),0.00045*sx,fonts["condensed-12"])/2,sy*0.42,_,_, tocolor(255, 255, 255, 255), 0.00045*sx, fonts["condensed-12"], "center", "center",false,false,false,true)

        dxDrawText("Rendszám: "..getVehiclePlateText(hitElement),sx*0.52 - dxGetTextWidth("Rendszám: "..getVehiclePlateText(hitElement),0.00045*sx,fonts["condensed-12"])/2 - 1,sy*0.439 + 1,_,_, tocolor(0, 0, 0, 255), 0.00045*sx, fonts["condensed-12"], "center", "center",false,false,false,true)
        dxDrawText("Rendszám: "..getVehiclePlateText(hitElement),sx*0.52 - dxGetTextWidth("Rendszám: "..getVehiclePlateText(hitElement),0.00045*sx,fonts["condensed-12"])/2,sy*0.439,_,_, tocolor(255, 255, 255, 255), 0.00045*sx, fonts["condensed-12"], "center", "center",false,false,false,true)
        end

    end

  end

  dxDrawRectangle(left, top,sx*0.037,sy*0.06,tocolor(40,40,40,255))
  dxDrawRectangle(left, top,sx*0.037,sy*0.06,tocolor(40,40,40,255))

  dxDrawRectangle(left, top,sx*0.037,sy*0.002,tocolor(r, g, b,255))

  dxDrawImage(left + sx*0.005, top + sy*0.005,sx*0.027,sy*0.05,"files/cameraIcon.png")
  dxDrawImage(left + sx*0.005, top + sy*0.005,sx*0.027,sy*0.05,"files/cameraIcon.png",0,0,0,tocolor(r,g,b,50))


  --dxDrawRectangle(sx*0.0,sy*0.0,sx*0.9999,sy*0.05,tocolor(0,0,0,150)) -- felso
  --dxDrawRectangle(sx*0.0,sy*0.93,sx*0.9999,sy*0.08,tocolor(0,0,0,150)) -- also

  --dxDrawRectangle(sx*0.0,sy*0.0,sx*0.05,sy*0.9999,tocolor(0,0,0,150)) -- bal
  --dxDrawRectangle(sx*0.9425,sy*0.0,sx*0.08,sy*0.9999,tocolor(0,0,0,150)) -- jobb


end

function reMap(value, low1, high1, low2, high2)
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

function setTargetToCamera()
  veh = getPedOccupiedVehicle(localPlayer)
  local Sx,Sy,Sz = getElementPosition (cameras[veh])
  local _,_, pR = getElementRotation (localPlayer)
  pR =  ((pR+90) * 3.141592653 * 2)/360;
  pR = pR + CamrotX
  local lookAtX, lookAtY, lookAtZ = Sx + math.cos(pR)*5, Sy + math.sin(pR)*5, Sz
  lookAtZ = lookAtZ + CamrotY
  setCameraMatrix (Sx,Sy,Sz - 2, lookAtX, lookAtY , lookAtZ - 20)


end

function Clicker(b, s, x, y)
	if b == 'left' and s == 'down' then

    if exports.oCore:isInSlot(left, top,sx*0.1,sy*0.1) then
			show = false
		end

		if x >= left and x < left + 230 and y >= top and y < top + 140 then
			windowOffsetX, windowOffsetY = (left) - x, (top) - y
			isDraggingWindow = true
		end

    if exports.oCore:isInSlot(left + sx*0.0085, top + sy*0.012,sx*0.02,sy*0.036) then
      if not activeCamera then
        activeCamera = true
        setElementData(localPlayer,"inHeliCam",activeCamera)
        addEventHandler("onClientRender",root,setTargetToCamera)
        exports.oInterface:toggleHud(true)
        showChat(false)
      else
        activeCamera = false
        setElementData(localPlayer,"inHeliCam",activeCamera)
        removeEventHandler("onClientRender",root,setTargetToCamera)
        setCameraTarget(localPlayer)
        exports.oInterface:toggleHud(false)
        showChat(true)
        setCameraGoggleEffect("normal")
      end
    elseif exports.oCore:isInSlot(sx*0.055,sy*0.063,sx*0.02,sy*0.025) then
      setCameraGoggleEffect("nightvision")
    elseif exports.oCore:isInSlot(sx*0.0795,sy*0.063,sx*0.02,sy*0.025) then
      setCameraGoggleEffect("thermalvision")
    elseif exports.oCore:isInSlot(sx*0.105,sy*0.063,sx*0.02,sy*0.025) then
      setCameraGoggleEffect("normal")
    end

	end

	if b == "left" and s == "up" and isDraggingWindow then
		isDraggingWindow = false
	end

end

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )

	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

function onHeliEnter(ped,seat)
    if getElementModel(source) == 497 then
      if seat == 1 then
        addEventHandler("onClientRender",root,renderCameraPanel)
        addEventHandler("onClientClick",root,Clicker)
        outputChatBox(core:getServerPrefix("server", "Kamera", 3).."A helikopter kamerájának használatához kattint a kis ikonra a felugró panelon.", 255, 255, 255, true)
        outputChatBox(core:getServerPrefix("server", "Kamera", 3).."A kamerába belépve ha a képernyőd szélére húzod az egered tudod azt forgatni.", 255, 255, 255, true)
        outputChatBox(core:getServerPrefix("server", "Kamera", 3).."A Night/Thermo Vision módot a bal felső sarokban tudod ki/be kapcsolni.", 255, 255, 255, true)
      end
    end
end
addEventHandler ("onClientVehicleEnter", root, onHeliEnter)

function onHeliExit(ped,seat)
    if getElementModel(source) == 497 then
      if seat == 1 then

        removeEventHandler("onClientRender",root,renderCameraPanel)
        removeEventHandler("onClientClick",root,Clicker)

        if getElementData(localPlayer,"inHeliCam") then
          removeEventHandler("onClientRender",root,setTargetToCamera)
          activeCamera = false
          setElementData(localPlayer,"inHeliCam",activeCamera)
          setCameraTarget(localPlayer)
          exports.oInterface:toggleHud(false)
          showChat(true)
          setCameraGoggleEffect("normal")
        end

      end
    end
end
addEventHandler ("onClientVehicleExit", root, onHeliExit)
