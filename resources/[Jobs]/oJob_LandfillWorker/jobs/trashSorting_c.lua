local sx, sy = guiGetScreenSize() 
local myX, myY = 1600, 900

local fonts = {
    ["condensed-10"] = exports.oFont:getFont("condensed", 10),
    ["condensed-13"] = exports.oFont:getFont("condensed", 13),
}

local tick = getTickCount()
local tick2 = getTickCount()

local progressbar_datas = {"nan", 100}
local progressBarAnimType = "open"

setElementData(localPlayer, "player:trashbag", false)

local loading = false

addEventHandler("onClientMarkerHit", root, function(player, mdim)
    if player == localPlayer then 
        if mdim then 
            if core:getDistance(source, localPlayer) <= 3 then
                if getElementData(source, "trashbag:marker") then 
                    addEventHandler("onClientRender", root, interactionRender)
                    bindKey("e", "up", createTrashBag)
                end

                if getElementData(source, "trashSortInt:in") then 
                    addEventHandler("onClientRender", root, interactionRender)
                    bindKey("e", "up", warpToSortInterior)
                end           

                if getElementData(source, "trashSortInt:out") then 
                    addEventHandler("onClientRender", root, interactionRender)
                    bindKey("e", "up", warpOutToSortInterior)
                end                
            end
        end
    end
end)

addEventHandler("onClientMarkerLeave", root, function(player, mdim)
    if player == localPlayer then 
        if mdim then 
            if getElementData(source, "trashbag:marker") then 
                removeEventHandler("onClientRender", root, interactionRender)
                unbindKey("e", "up", createTrashBag)
            end

            if getElementData(source, "trashSortInt:in") then 
                removeEventHandler("onClientRender", root, interactionRender)
                unbindKey("e", "up", warpToSortInterior)
            end

            if getElementData(source, "trashSortInt:out") then 
                removeEventHandler("onClientRender", root, interactionRender)
                unbindKey("e", "up", warpOutToSortInterior)
            end 
        end
    end
end)

local occupiedCol
local inSorting = false
addEventHandler("onClientColShapeHit", root, function(player, mdim)
    if player == localPlayer then 
        if mdim then 
            if core:getDistance(source, localPlayer) <= 3 then
                if getElementData(source, "sortingCol") then 
                    addEventHandler("onClientRender", root, interactionRender)
                    bindKey("e", "up", startSorting)
                    occupiedCol = source
                end        
            end
        end
    end
end)

addEventHandler("onClientColShapeLeave", root, function(player, mdim)
    if player == localPlayer then 
        if mdim then 
            if getElementData(source, "sortingCol") then 
                removeEventHandler("onClientRender", root, interactionRender)
                unbindKey("e", "up", startSorting)
                occupiedCol = false
            end
        end
    end
end)

function startSorting()
    if occupiedCol then 
        if not getElementData(occupiedCol, "tableUse") then 
            if getElementData(localPlayer, "player:trashbag") then 
                if getObjectScale(getElementData(localPlayer, "player:trashbag")) >= 0.3 then 
                    if not inSorting then 
                        openTrashPanel()
                        infobox:outputInfoBox("Sikeresen elkezdted a szemét válogatását!", "success")
                    end
                else
                    infobox:outputInfoBox("Először töltsd meg a szemeteszsákodat szeméttel!", "error")
                end
            else
                infobox:outputInfoBox("Nincs nálad szemeteszsák!", "error")
            end
        else
            infobox:outputInfoBox("Ez az asztal már használatban van!", "error")
        end
    end
end

addEventHandler("onClientClick", root, function(key, state, _, _, _, _, _, element)
    if element then 
        if getElementData(element, "isTrashContainer") then 
            if state == "up" then 
                if core:getDistance(element, localPlayer) < 4 then
                    if not loading then  
                        if getElementData(localPlayer, "player:trashbag") then 
                            if getObjectScale(getElementData(localPlayer, "player:trashbag")) <= 0.3 then 
                                chat:sendLocalMeAction("megtölti a kezében lévő szemeteszsákot.")
                                setElementData(localPlayer, "player:trashbag:state", 1)

                                toggleAllControls(false)
                                progressbar_datas = {"Szemeteszsák megtöltése", collectAnimationTime}
                                tick = getTickCount()
                                tick2 = getTickCount()
                                loading = true
                                progressBarAnimType = "open"
                                addEventHandler("onClientRender", root, renderProgressBar)
                                setTimer(function() 
                                    tick2 = getTickCount()
                                    progressBarAnimType = "close"
                                    setTimer(function() removeEventHandler("onClientRender", root, renderProgressBar) end, 250, 1)
                                    toggleAllControls(true)

                                    triggerServerEvent("setTrashBagScale->OnServer", resourceRoot, "big")

                                    for k, v in ipairs(toggledControls) do 
                                        toggleControl(v, false)
                                    end
                                    loading = false
                                end, collectAnimationTime, 1)
                            else
                                outputChatBox(core:getServerPrefix("red-dark", "Szemétválogató", 3).."A kezedben lévő szemeteszsák tele van!", 255, 255, 255, true)
                            end
                        else
                            outputChatBox(core:getServerPrefix("red-dark", "Szemétválogató", 3).."Nincs a kezedben szemeteszsák!", 255, 255, 255, true)
                        end
                    end
                end
            end
        end
    end
end)

function interactionRender()
    shadowedText("Az interakcióhoz nyomd meg az "..color.."[E] #ffffffgombot.",0,sy*0.85,sx,sy*0.85+sy*0.05,tocolor(255,255,255,255),1/myX*sx,fonts["condensed-13"],"center","center", false, false, false, true)
end

function renderProgressBar()
    local alpha
    
    if progressBarAnimType == "open" then 
        alpha = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount() - tick2)/250, "Linear")
    else
        alpha = interpolateBetween(1, 0, 0, 0, 0, 0, (getTickCount() - tick2)/250, "Linear")
    end

    local line_height = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount() - tick)/progressbar_datas[2], "Linear")

    dxDrawRectangle(sx*0.4, sy*0.85, sx*0.2, sy*0.025, tocolor(40, 40, 40, 255*alpha))
    dxDrawRectangle(sx*0.401, sy*0.852, (sx*0.2-sx*0.002), sy*0.025-sy*0.004, tocolor(35, 35, 35, 255*alpha))
    dxDrawRectangle(sx*0.401, sy*0.852, (sx*0.2-sx*0.002)*line_height, sy*0.025-sy*0.004, tocolor(r, g, b, 255*alpha))

    dxDrawText(progressbar_datas[1], sx*0.4, sy*0.85, sx*0.4+sx*0.2, sy*0.85+sy*0.025, tocolor(35, 35, 35, 255*alpha), 0.8/myX*sx, fonts["condensed-10"], "center", "center", false, false, false, true)
end

function createTrashBag()
    if not getElementData(localPlayer, "player:trashbag") then
        chat:sendLocalMeAction("felvesz egy üres szemeteszsákot.")
        
        triggerServerEvent("createTrashBag->OnServer", resourceRoot)
    else
    end
end

function warpToSortInterior()
    triggerServerEvent("warpToSortInterior->OnServer", resourceRoot)
end

function warpOutToSortInterior()
    triggerServerEvent("warpOutToSortInterior->OnServer", resourceRoot)
end

function createContainers()
    for k, v in ipairs(containerPositions) do 
        local obj = createObject(18472, v[1].x, v[1].y, v[1].z, 0, 0, v[2])
        setElementData(obj, "isTrashContainer", true)
    end
end
createContainers()

local stripe = dxCreateTexture( "files/stripe.png", "dxt5")

local stripeSize = 2

addEventHandler( "onClientRender", root,
    function( )
        if getElementInterior(localPlayer) == 2 and getElementDimension(localPlayer) == 0 then 
            local playerPos = Vector3(getElementPosition(localPlayer))

            for k, v in ipairs(stripes) do 
                local pos = v.pos

                if getDistanceBetweenPoints3D(playerPos.x, playerPos.y, playerPos.z, pos.x, pos.y, pos.z) < 30 then 
                    dxDrawMaterialLine3D(pos.x, pos.y+stripeSize/2, pos.z, pos.x, pos.y, pos.z, stripe, stripeSize, tocolor(255, 255, 255), false, pos.x, pos.y, -100)
                end
            end
        end
    end
)

local alpha = 1
local maxTrashes = 0
local completeTrashes = 0
local goodTrash = 0
local badTrash = 0
local payment = 0

local trashFiles = {
    {"glass_1", "glass"},
    {"paper_1", "paper"},
    {"paper_2", "paper"},
    {"paper_3", "paper"},
    {"paper_4", "paper"},
    {"paper_5", "paper"},
    {"paper_6", "paper"},
    {"plastic_1", "plastic"},
    {"plastic_2", "plastic"},
    {"plastic_3", "plastic"},
}

local movingItem = false
local keyClick = {0, 0}

local materialMenus = {
    {"Papír", 90, 191, 237, "paper"},
    {"Műanyag", 230, 160, 69, "plastic"},
    {"Üveg", 91, 207, 99, "glass"},
    {"Fém", 158, 158, 158, "metal"},
}

function renderTrashPanel()
    showCursor(true)
    dxDrawRectangle(sx*0.35, sy*0.35, sx*0.3, sy*0.3, tocolor(35, 35, 35, 255*alpha))

    local startX, startY = sx*0.445, sy*0.355+3/myY*sy, sx*0.1, sy*0.14
    for k, v in ipairs(materialMenus) do 
        if core:isInSlot(startX, startY, sx*0.1, sy*0.14) then 
            dxDrawRectangle(startX, startY, sx*0.1, sy*0.14, tocolor(v[2], v[3], v[4], 255*alpha))
            dxDrawText(v[1], startX, startY, startX+sx*0.1, startY+sy*0.14, tocolor(40, 40, 40, 255*alpha), 1/myX*sx, fonts["condensed-13"], "center", "center")
        else
            dxDrawRectangle(startX, startY, sx*0.1, sy*0.14, tocolor(40, 40, 40, 255*alpha))
            dxDrawText(v[1], startX, startY, startX+sx*0.1, startY+sy*0.14, tocolor(v[2], v[3], v[4], 255*alpha), 1/myX*sx, fonts["condensed-13"], "center", "center")
        end

        startX = startX + sx*0.1025
        if k % 2 == 0 then 
            startY = startY + sy*0.145
            startX = sx*0.445
        end
    end

    if core:isInSlot(sx*0.35+4/myX*sx, sy*0.35+3/myY*sy, sx*0.091, sy*0.293) then 
        dxDrawRectangle(sx*0.35+4/myX*sx, sy*0.35+3/myY*sy, sx*0.091, sy*0.293, tocolor(r, g, b, 100*alpha))
    else
        dxDrawRectangle(sx*0.35+4/myX*sx, sy*0.35+3/myY*sy, sx*0.091, sy*0.293, tocolor(40, 40, 40, 255*alpha))
    end

    dxDrawText("Szemét elvétele\n "..color.."("..maxTrashes.."/"..completeTrashes..")", sx*0.35+4/myX*sx, sy*0.35+3/myY*sy, sx*0.35+4/myX*sx+sx*0.091, sy*0.35+3/myY*sy+sy*0.293, tocolor(220, 220, 220, 255*alpha), 1/myX*sx, fonts["condensed-13"], "center", "center", false, false, false, true)

    dxDrawRectangle(sx*0.35, sy*0.655, sx*0.3, sy*0.04, tocolor(35, 35, 35, 255*alpha))
    dxDrawRectangle(sx*0.35+3/myX*sx, sy*0.655+3/myY*sy, sx*0.3-6/myX*sx, sy*0.04-6/myY*sy, tocolor(40, 40, 40, 255*alpha))
    dxDrawText("Sikeres: "..color..goodTrash.."#dcdcdcdb | Sikertelen: "..color..badTrash.."#dcdcdcdb | Fizetés: "..color..payment.."$", sx*0.35, sy*0.655, sx*0.35+sx*0.3, sy*0.655+sy*0.04, tocolor(220, 220, 220, 255*alpha), 1/myX*sx, fonts["condensed-10"], "center", "center", false, false, false, true)

    if movingItem then 
        local cX, cY = getCursorPosition()

        dxDrawImage(cX*sx-75/myX*sx/2, cY*sy-75/myY*sy/2, 75/myX*sx, 75/myY*sy, "files/images/"..movingItem[1]..".png")
    end
end

function keyTrashPanel(key, state)
    if key == "mouse1" then 
        if state then -- down
            if core:isInSlot(sx*0.35+4/myX*sx, sy*0.35+3/myY*sy, sx*0.091, sy*0.293) then 
                if not movingItem then 
                    local randomMaterial = math.random(#trashFiles)

                    movingItem = trashFiles[randomMaterial]
                end 
            end       
        else -- up
            if movingItem then 
                local startX, startY = sx*0.445, sy*0.355+3/myY*sy, sx*0.1, sy*0.14
                for k, v in ipairs(materialMenus) do 
                    if core:isInSlot(startX, startY, sx*0.1, sy*0.14) then
                        completeTrashes = completeTrashes + 1  
                        if movingItem[2] == v[5] then
                            goodTrash = goodTrash + 1 
                            payment = payment + 7
                        else 
                            badTrash = badTrash + 1
                            payment = payment - 20
                        end

                        if completeTrashes == maxTrashes then 
                            endSortingJob()
                        end
                    end
            
                    startX = startX + sx*0.1025
                    if k % 2 == 0 then 
                        startY = startY + sy*0.145
                        startX = sx*0.445
                    end
                end

                movingItem = false
            end
        end
    end
end

function endSortingJob()
    removeEventHandler("onClientRender", root, renderTrashPanel)
    removeEventHandler("onClientKey", root, keyTrashPanel)
    showCursor(false)
    infobox:outputInfoBox("Elfogytak a szemetek! Fizetésül "..payment.."$-t kaptál!", "info")
    triggerServerEvent("trashjob > endTrashSorting", resourceRoot, payment)
    inSorting = false
    
    for k, v in ipairs(toggledControls) do 
        toggleControl(v, true)
    end
end

function openTrashPanel()
    maxTrashes = 0
    completeTrashes = 0
    goodTrash = 0
    badTrash = 0
    payment = 0
    addEventHandler("onClientRender", root, renderTrashPanel)
    addEventHandler("onClientKey", root, keyTrashPanel)
    maxTrashes = math.random(7, 15)
    inSorting = true
end