removeWorldModel(5400, 50, 1878.4299316406,-1363.4552001953,14.640625)


local controlledCrane = nil

local attachCols = {}
local createdObjects = 0
local currentDropPlaceCol = nil
local attachedObject = nil
local selectedCamera = 1

local enterMarker = nil

local sx, sy = guiGetScreenSize()
local myX, myY = 1768, 992

local craneHeads = {}

local sounds = {
    ["q_e"] = false,
}

function createCranes()
    for k, v in ipairs(cranes) do 
        local elements = {}
        for k2, v2 in pairs(v.objects) do 
            elements[k2] = createObject(v2[1], v.position[1] + v2[2], v.position[2] + v2[3], v.position[3] + v2[4])

            if k2 == "camera_pos_1" or k2 == "camera_pos_2" or k2 == "check1" or k2 == "check2" or k2 == "check3" or k2 == "check4" or k2 == "check11" or k2 == "check22" or k2 == "check33" or k2 == "check44" then 
                setElementAlpha(elements[k2], 0)
                setElementCollisionsEnabled(elements[k2], false)
            end
        end

        attachElements(elements["hook"], elements["head"], 0, 35, -10)
        attachElements(elements["connector"], elements["head"], 0, 35, 3.2, 0, 0, 0)
        attachElements(elements["camera_pos_1"], elements["head"], 0, 2, 2, 0, 0, 0)
        attachElements(elements["camera_pos_2"], elements["hook"], 10, 10, 2, 0, 0, 0)

        detachElements( elements["hook"])
        
        attachElements(elements["check1"], elements["hook"], -5, 0, -1, 0, 0, 0)
        attachElements(elements["check11"], elements["hook"], -2, 0, -1, 0, 0, 0)
        attachElements(elements["check2"], elements["hook"], 5, 0, -1, 0, 0, 0)
        attachElements(elements["check22"], elements["hook"], 2, 0, -1, 0, 0, 0)
        attachElements(elements["check3"], elements["hook"], 0, -5, -1, 0, 0, 0)
        attachElements(elements["check33"], elements["hook"], 0, -2, -1, 0, 0, 0)
        attachElements(elements["check4"], elements["hook"], 0, 5, -1, 0, 0, 0)
        attachElements(elements["check44"], elements["hook"], 0, 2, -1, 0, 0, 0)

        setElementData(elements["head"], "crane:connector", elements["connector"])
        setElementData(elements["head"], "crane:hook", elements["hook"])
        setElementData(elements["head"], "crane:cameraPos", {elements["camera_pos_1"], elements["camera_pos_2"]})
        setElementData(elements["head"], "crane:checkObjects", {elements["check1"], elements["check2"], elements["check3"], elements["check4"], elements["check11"], elements["check22"], elements["check33"], elements["check44"]})
        setElementData(elements["head"], "crane:dimensions", {v.craneHeight, v.craneWidth})
        setElementData(elements["head"], "crane:paymentMultiplyer", v.paymentMultiplyer)
        setElementData(elements["head"], "crane:defHookPosition", {getElementPosition(elements["hook"])})
        
        table.insert(craneHeads, elements["head"])

        --controlledCrane = elements["head"] -- ezt majd ki kell szedni
    end
end

addEventHandler("onClientRender", root, function()
    for k, crane in ipairs(craneHeads) do 
        if isElementStreamedIn(crane) then
            if core:getDistance(localPlayer, crane) < 200 then
                local cx, cy, cz = getElementPosition(getElementData(crane, "crane:connector"))
                local hx, hy, hz = getElementPosition(getElementData(crane, "crane:hook"))
                dxDrawLine3D(cx, cy, cz, hx, hy, hz + 1, tocolor(0, 0, 0, 255), 10)    
            end
        end
    end
end)

local needToSetRot = false

function renderCrane()
    local hook = getElementData(controlledCrane, "crane:hook")
    local connector = getElementData(controlledCrane, "crane:connector")
    local cameraPos = getElementData(controlledCrane, "crane:cameraPos")[selectedCamera]

    local cameraX, cameraY, cameraZ = getElementPosition(cameraPos)

    local cX, cY, cZ = getElementPosition(connector)
    local hX, hY, hZ = getElementPosition(hook)
    local craneX, craneY, craneZ = getElementPosition(controlledCrane)

    local rx, ry, rz = getElementRotation(controlledCrane)


    local hRotY = (cX - hX) * 8

    if (rz > 90) and (rz < 270) then 
        hRotY = (hX - cX) * 8
    end


    local hRotX = (cY - hY) * 8

    local playCraneSound = false


    --print(rz)

    local check1, check2, check3, check4, check11, check22, check33, check44 = unpack(getElementData(controlledCrane, "crane:checkObjects"))

    local groundDifference = 1

    if isElement(attachedObject) then 
        groundDifference = objectsAttachOffsets[getElementModel(attachedObject)] * 1.5
    end

    local craneDimensions = getElementData(controlledCrane, "crane:dimensions")


    -- dashboard 

    exports.oCore:dxDrawButton(sx*0.01, sy*0.01,sx*0.05,sy*0.025,245, 66, 66,200, "Kilépés", tocolor(255, 255, 255, 255), 0.6, exports.oFont:getFont("bebasneue", 15/myX*sx), false, tocolor(0, 0, 0, 255))

    dxDrawImage(sx*0.7,sy*0.63, 500/myX*sx, 326/myY*sy, "files/dash.png")

    dxDrawImage(sx*0.83,sy*0.695, 20/myX*sx, 20/myY*sy, "files/arrow.png", 0, 0, 0, tocolor(0, 0, 0, 100))
    dxDrawImage(sx*0.814,sy*0.695, 20/myX*sx, 20/myY*sy, "files/arrow.png", 180, 0, 0, tocolor(0, 0, 0, 100))

    dxDrawImage(sx*0.734,sy*0.85, 20/myX*sx, 20/myY*sy, "files/arrow.png", 180, 0, 0, tocolor(0, 0, 0, 100))
    dxDrawImage(sx*0.765,sy*0.85, 20/myX*sx, 20/myY*sy, "files/arrow.png", 0, 0, 0, tocolor(0, 0, 0, 100))

    dxDrawImage(sx*0.83,sy*0.765, 20/myX*sx, 20/myY*sy, "files/arrow.png", 90, 0, 0, tocolor(0, 0, 0, 100))
    dxDrawImage(sx*0.83,sy*0.74, 20/myX*sx, 20/myY*sy, "files/arrow.png", 270, 0, 0, tocolor(0, 0, 0, 100))


    if isElement(attachedObject) then 
        dxDrawImage(sx*0.814,sy*0.84, 40/myX*sx, 40/myY*sy, "files/package.png", 0, 0, 0, tocolor(0, 0, 0, 140))
    else
        dxDrawImage(sx*0.814,sy*0.84, 40/myX*sx, 40/myY*sy, "files/package.png", 0, 0, 0, tocolor(0, 0, 0, 70))
    end

    dxDrawText("Balra/Jobbra: [A]/[D] \nElőre/Hátra: [W]/[S] \nFel/Le: [Q]/[E]\nFelcsatolás/Lecsatolás: [Space]\nKamera váltás: nyilak", sx*0.845, sy*0.7, sx*0.97, sy*0.91, tocolor(255, 255, 255, 255), 1, exports.oFont:getFont("p_m", 15/myX*sx), "right", "center", false, false, false, true)

    -- Control
    -- MŰKÖDIK, IGEN RONDA, DE HA HOZZÁNYÚLSZ AKKOR ELROMLIK!!
    local check1x, check1y = getElementPosition(check1)
    local check11x, check11y = getElementPosition(check11)
    --dxDrawLine3D(check11x, check11y, hZ - (groundDifference * 0.5), check1x, check1y, hZ - (groundDifference * 0.5), tocolor( 255, 100, 0), 10)
    local moveA_available = isLineOfSightClear(check11x, check11y, hZ - (groundDifference * 0.5), check1x, check1y, hZ - (groundDifference * 0.5), true, true, true, true, true, false, false, attachedObject)

    local check2x, check2y = getElementPosition(check2)
    local check22x, check22y = getElementPosition(check22)
    --dxDrawLine3D(check22x, check22y, hZ - (groundDifference * 0.5), check2x, check2y, hZ - (groundDifference * 0.5), tocolor( 255, 255, 0), 10)
    local moveD_available = isLineOfSightClear(check22x, check22y, hZ - (groundDifference * 0.5), check2x, check2y, hZ - (groundDifference * 0.5), true, true, true, true, true, false, false, attachedObject)

    local check3x, check3y = getElementPosition(check3)
    local check33x, check33y = getElementPosition(check33)
    --dxDrawLine3D(check33x, check33y, hZ - (groundDifference * 0.5), check3x, check3y, hZ - (groundDifference * 0.5), tocolor( 255, 255, 0), 10)
    local moveS_available = isLineOfSightClear(check33x, check33y, hZ - (groundDifference * 0.5), check3x, check3y, hZ - (groundDifference * 0.5), true, true, true, true, true, false, false, attachedObject)

    local check4x, check4y = getElementPosition(check4)
    local check44x, check44y = getElementPosition(check44)
    --dxDrawLine3D(check44x, check44y, hZ - (groundDifference * 0.5), check4x, check4y, hZ - (groundDifference * 0.5), tocolor( 255, 255, 0), 10)
    local moveW_available = isLineOfSightClear(check44x, check44y, hZ - (groundDifference * 0.5), check4x, check4y, hZ - (groundDifference * 0.5), true, true, true, true, true, false, false, attachedObject)

    local voltrot = false
    local underControl = false
    if (getKeyState("a")) then 
        if (underControl == "a" or not underControl) then
            if moveA_available then
                dxDrawImage(sx*0.734,sy*0.85, 20/myX*sx, 20/myY*sy, "files/arrow.png", 180, 0, 0, tocolor(r, g, b, 255))
                needToSetRot = true
                setElementRotation(controlledCrane, rx, ry, rz + craneSpeed)
                underControl = "a"
        
                setElementRotation(hook, rx, hRotY, rz + craneSpeed) -- pozíció ellenőrzés miatt a hookot is forgatni kell, ha kiszeded akkor az objecteket bele lehet mozgatni a falba
                playCraneSound = true
                voltrot = true
            else
                dxDrawImage(sx*0.734,sy*0.85, 20/myX*sx, 20/myY*sy, "files/arrow.png", 180, 0, 0, tocolor(230, 50, 50, 255))
            end
        end
    end 
    
    if (getKeyState("d")) then 
        if (underControl == "d" or not underControl) then
            if moveD_available then
                dxDrawImage(sx*0.765,sy*0.85, 20/myX*sx, 20/myY*sy, "files/arrow.png", 0, 0, 0, tocolor(r, g, b, 255))
                needToSetRot = true
                setElementRotation(controlledCrane, rx, ry, rz - craneSpeed)
                underControl = "d"

                    setElementRotation(hook, rx, hRotY, rz + craneSpeed) -- pozíció ellenőrzés miatt a hookot is forgatni kell, ha kiszeded akkor az objecteket bele lehet mozgatni a falba
                    playCraneSound = true

                voltrot = true
            else
                dxDrawImage(sx*0.765,sy*0.85, 20/myX*sx, 20/myY*sy, "files/arrow.png", 0, 0, 0, tocolor(230, 50, 50, 255))
            end
        end
    end

    if (getKeyState("s")) then
        if (underControl == "s" or not underControl) then
            local x, y, z, rx, ry, rz = getElementAttachedOffsets(connector) -- get the offsets
            if y > 5 and moveS_available then
                needToSetRot = false
                dxDrawImage(sx*0.814,sy*0.695, 20/myX*sx, 20/myY*sy, "files/arrow.png", 180, 0, 0, tocolor(r, g, b, 255))
                underControl = "s"

                --setElementRotation(hook, -hRotX, 0, rz)
                voltrot = true
                playCraneSound = true

                setElementAttachedOffsets(connector, x, y - craneSpeed * 0.7, z, rx, ry, rz) -- update offsets
            else
                dxDrawImage(sx*0.83,sy*0.695, 20/myX*sx, 20/myY*sy, "files/arrow.png", 0, 0, 0, tocolor(230, 50, 50, 255))
            end
        end
    end

    if (getKeyState("w")) then
        if (underControl == "w" or not underControl) then
            local x, y, z, rx, ry, rz = getElementAttachedOffsets(connector) -- get the offsets
            if y < craneDimensions[2] and moveW_available then
                needToSetRot = false
                dxDrawImage(sx*0.83,sy*0.695, 20/myX*sx, 20/myY*sy, "files/arrow.png", 0, 0, 0, tocolor(r, g, b, 255))
                underControl = "w"
                --setElementRotation(hook, -hRotX, 0, rz)
                voltrot = true
                playCraneSound = true

                setElementAttachedOffsets(connector, x, y + craneSpeed * 0.7, z, rx, ry, rz) -- update offsets
            else
                dxDrawImage(sx*0.83,sy*0.695, 20/myX*sx, 20/myY*sy, "files/arrow.png", 0, 0, 0, tocolor(230, 50, 50, 255))
            end
        end
    end

    if not voltrot then
        setElementRotation(hook, -hRotX, hRotY, rz - craneSpeed)
    end

    --Camera:
    setCameraMatrix(cameraX, cameraY, cameraZ, hX, hY, hZ)
 
    if needToSetRot then
        local rasdx, rasy, rasdz = getElementRotation(hook)
        setElementRotation(hook, rasdx, hRotY, rasdz)
    end
 
    -- Hook physic

    if ((cX - hX) < 0) then 
        hX = hX - craneSpeed*hookPhysicMultiplier
    end

    if ((cY - hY) < 0) then 
        hY = hY - craneSpeed*hookPhysicMultiplier
    end

    if ((cX - hX) > 0) then 
        hX = hX + craneSpeed*hookPhysicMultiplier
    end

    if ((cY - hY) > 0) then 
        hY = hY + craneSpeed*hookPhysicMultiplier
    end

 
    local gZ = getGroundPosition( hX, hY, hZ - groundDifference)
    --dxDrawLine3D(hX, hY, hZ - groundDifference - 0.1, hX, hY, hZ - groundDifference + 0.1, tocolor( 0, 0, 255), 10)
    --dxDrawLine3D(hX, hY, gZ - 0.5, hX, hY, gZ + 1, tocolor( 255, 0, 0), 10)



    if (getKeyState("e")) then 
        
        if hZ < craneDimensions[1] then
            
            hZ = hZ + craneSpeed * 2
            dxDrawImage(sx*0.83,sy*0.74, 20/myX*sx, 20/myY*sy, "files/arrow.png", 270, 0, 0, tocolor(r, g, b, 255))

            playCraneSound = true

        else
            dxDrawImage(sx*0.83,sy*0.74, 20/myX*sx, 20/myY*sy, "files/arrow.png", 270, 0, 0, tocolor(230, 50, 50, 255))

          
        end
   
    end

    if (getKeyState("q")) then 
        
        --print(hZ, gZ)
        if hZ > (gZ + (groundDifference * 1.2)) and (not (gZ == 0)) then
            hZ = hZ - craneSpeed * 2
            dxDrawImage(sx*0.83,sy*0.765, 20/myX*sx, 20/myY*sy, "files/arrow.png", 90, 0, 0, tocolor(r, g, b, 255))

            playCraneSound = true

        else
            dxDrawImage(sx*0.83,sy*0.765, 20/myX*sx, 20/myY*sy, "files/arrow.png", 90, 0, 0, tocolor(230, 50, 50, 100))
   
          
        end
  
    end

    local oldx, oldy, oldz = getElementPosition(hook)
    moveObject(hook, 80, cX, cY, hZ)
    --setElementPosition(hook, hX , hY, hZ)

    if (playCraneSound) then 
        if not isElement(sounds["q_e"]) then 
            sounds["q_e"] = playSound("files/up_down.mp3", true)
            setSoundVolume(sounds["q_e"], 0.5)
        end
    else
        if isElement(sounds["q_e"]) then 
            destroyElement(sounds["q_e"])
        end
    end

    

    -- csomag felcsatolása / lecsatolása
    for k, v in ipairs(attachCols) do
        if isElement(v) then
            if isElementWithinColShape(hook, v) then 
                --print("asd")
             
                    if not getElementData(v, "craneObj:attached") then 
                        if not isElement(attachedObject) then
                            dxDrawImage(sx*0.814,sy*0.84, 40/myX*sx, 40/myY*sy, "files/package.png", 0, 0, 0, tocolor(r, g, b, 160))

                            if getKeyState("space") then 
                                local _, _, rotHZ = getElementRotation(hook)
                                local _, _, rotOZ = getElementRotation(getElementData(v, "craneObj:obj"))
                                attachElements(getElementData(v, "craneObj:obj"), hook, 0, 0, -objectsAttachOffsets[getElementModel(getElementData(v, "craneObj:obj"))] + 0.5, 0, 0, rotOZ - rotHZ)
                                setElementData(v, "craneObj:attached", true)
                                destroyElement(getElementData(v, "craneObj:indicator"))
                                attachedObject = getElementData(v, "craneObj:obj")
                                playSound("files/drop.mp3")
                            end
                        end
                    else
                        if isElement(currentDropPlaceCol) then
                            if isElementWithinColShape(getElementData(v, "craneObj:obj"), currentDropPlaceCol) then 
                                dxDrawImage(sx*0.814,sy*0.84, 40/myX*sx, 40/myY*sy, "files/package.png", 0, 0, 0, tocolor(100, 222, 106, 160))

                                if getKeyState("space") then
                                    local cranedObj = getElementData(v, "craneObj:obj")
                                    destroyElement(v)
                                    detachElements(cranedObj)
                                    destroyElement(cranedObj)
                                    attachedObject = nil


                                    createdObjects = createdObjects - 1

                                    local payment = math.floor(math.random(defPayment * getElementData(controlledCrane, "crane:paymentMultiplyer"), defPayment * getElementData(controlledCrane, "crane:paymentMultiplyer") * 1.5))
                                    if exports.oJob:isJobHasDoublePaymant(8) then 
                                        payment = payment * 2
                                    end

                                    outputChatBox(core:getServerPrefix("server", "Darukezelő", 2).."Kaptál: "..color..payment.."#ffffff$-t.", 255, 255, 255, true)

                                    if createdObjects > 0 then
                                        outputChatBox(core:getServerPrefix("server", "Darukezelő", 2).."Maradék daruzandó tárgyak: "..color..createdObjects.."#ffffffdb.", 255, 255, 255, true)
                                    else 
                                        triggerServerEvent("craneJob > setPlayerAlpha", resourceRoot, 255)
                                        setElementCollisionsEnabled(localPlayer,true)

                                        --setElementAlpha(localPlayer, 255)

                                        local payment2 = math.floor(defPayment * getElementData(controlledCrane, "crane:paymentMultiplyer") * 2.5)

                                        if exports.oJob:isJobHasDoublePaymant(8) then 
                                            payment2 = payment2 * 2
                                        end

                                        if isElement(sounds["q_e"]) then 
                                            destroyElement(sounds["q_e"])
                                        end

                                        outputChatBox(core:getServerPrefix("green-dark", "Darukezelő", 2).."Végeztél a munkával, ezért kaptál #80de68"..payment2.."#ffffff$-t és "..color.."10#ffffffXP-t.", 255, 255, 255, true)
                                        outputChatBox(core:getServerPrefix("server", "Darukezelő", 2).."Ha folytatni szeretnéd a munkát, akkor beszélj újra az építésvezetővel!", 255, 255, 255, true)
                                        setElementData(localPlayer, "craneJob:xp", (getElementData(localPlayer, "craneJob:xp") or 0) + 10)

                                        setElementData(localPlayer, "char:money",  getElementData(localPlayer, "char:money") + payment2)
                                        removeEventHandler("onClientRender", root, renderCrane)
                                        setElementFrozen(localPlayer, false)
                                        setCameraTarget(localPlayer, localPlayer)

                                        showChat(true)
                                        exports.oInterface:toggleHud(false)
                                

                                        setElementRotation(controlledCrane, 0, 0, 0)

                                        inJob = false

                                        setTimer(function()
                                            setElementPosition(getElementData(controlledCrane, "crane:hook"), unpack(getElementData(controlledCrane, "crane:defHookPosition")))
                                            setElementAttachedOffsets(getElementData(controlledCrane, "crane:connector"), 0, 35, 3.2)
                                            controlledCrane = false
                                        end, 200, 1)                                      

                                        if isElement(enterMarker) then destroyElement( enterMarker ) end
                                        if isElement(currentDropPlaceCol) then destroyElement( currentDropPlaceCol ) end
                                    end

                                    setElementData(localPlayer, "char:money", getElementData(localPlayer, "char:money") + payment)

                                    playSound("files/drop.mp3")

                                end
                            end
                        end
                    end
                
            end
        end
    end

    -- drop place render 
    if not (currentDropPlaceCol == nil) then 
        if isElement(currentDropPlaceCol) then
            local colX, colY, colZ = getElementPosition(currentDropPlaceCol)
            local w, h = getColShapeSize(currentDropPlaceCol)
            o3d:render3DZone(colX, colY, colZ + 0.1, w, h, 255, 255, 255, 150, 20, 5, true)
        end
    end
end

function addLabelOnClick ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
    if button == "left" and state == "down" then 
        if inJob then 
            if exports.oCore:isInSlot(sx*0.01, sy*0.01,sx*0.05,sy*0.025) then 
                endWorkRequest()
            end 
        end
    end 
end
addEventHandler ( "onClientClick", root, addLabelOnClick )

function endWorkRequest()
        triggerServerEvent("craneJob > setPlayerAlpha", resourceRoot, 255)
        setElementCollisionsEnabled(localPlayer,true)
        if isElement(sounds["q_e"]) then 
            destroyElement(sounds["q_e"])
        end

        outputChatBox(core:getServerPrefix("red-dark", "Darukezelő", 2).."Mivel félbehagytad a munkád ezért nem jár sem pénz sem XP!", 255, 255, 255, true)
        outputChatBox(core:getServerPrefix("red-dark", "Darukezelő", 2).."Amennyiben újból el szeretnéd kezdeni a munkát látogasd meg az építésvezetőt!", 255, 255, 255, true)

        removeEventHandler("onClientRender", root, renderCrane)
        setElementFrozen(localPlayer, false)
        setCameraTarget(localPlayer, localPlayer)
        setElementRotation(controlledCrane, 0, 0, 0)

		showChat(true)
		exports.oInterface:toggleHud(false)
        createdObjects = 0
        inJob = false

        setTimer(function()
            setElementPosition(getElementData(controlledCrane, "crane:hook"), unpack(getElementData(controlledCrane, "crane:defHookPosition")))
            setElementAttachedOffsets(getElementData(controlledCrane, "crane:connector"), 0, 35, 3.2)
            controlledCrane = false
        end, 200, 1)                                      

        for k, v in pairs(getElementsByType("colshape")) do 
            if getElementData(v,"craneCol") then 
                destroyElement(v)
            end 
        end  

        for k, v in pairs(getElementsByType("object")) do 
            if getElementData(v,"craneObj") then 
                destroyElement(v)
            end 
        end 
        
        for k,v in pairs(getElementsByType("marker")) do 
            if getElementData(v,"craneIndicator") then 
                destroyElement(v)
            end 
        end 
        
        destroyElement(getElementData(localPlayer,"currentCraneBlip"))
        if isElement(enterMarker) then destroyElement( enterMarker ) end
        if isElement(currentDropPlaceCol) then destroyElement( currentDropPlaceCol ) end
end

bindKey("arrow_r", "up", function()
    if selectedCamera < 2 then
        selectedCamera = selectedCamera + 1
    else
        selectedCamera = 1
    end
end)   

bindKey("arrow_l", "up", function()
    if selectedCamera > 1 then
        selectedCamera = selectedCamera - 1
    else
        selectedCamera = 2
    end
end)   

createCranes()

function createCraneableObject(modelid, x, y, z, rotZ)
    local obj = createObject(modelid, x, y, z, 0, 0, rotZ)
    local indicator = createMarker(x, y, z + objectsAttachOffsets[modelid], "arrow", 1.0, r, g, b, 200)
    local colshape = createColSphere(x, y, z, 1.5)

    setElementData(obj,"craneObj",true)
    setElementData(indicator,"craneIndicator",true)
    setElementData(colshape,"craneCol",true)
    attachElements(colshape, obj, 0, 0, (objectsAttachOffsets[modelid] - 1))
    attachElements(indicator, obj, 0, 0, (objectsAttachOffsets[modelid]))
    setElementData(colshape, "craneObj:indicator", indicator)
    setElementData(colshape, "craneObj:obj", obj)
    setElementData(colshape, "craneObj:attached", false)

    table.insert(attachCols, colshape)
end

function createJobObjects(craneID, taskID) 
    local craneBlip = createBlip(cranes[craneID].position[1], cranes[craneID].position[2], cranes[craneID].position[3], 53)
    setElementData(craneBlip, "blip:name", "Darukezelő - " .. jobs[craneID][taskID].name)
    setElementData(localPlayer,"currentCraneBlip",craneBlip)

    outputChatBox(core:getServerPrefix("server", "Darukezelő", 2).."Sikeresen elvállaltad a "..color.."'"..jobs[craneID][taskID].name.."' #ffffffnevű feladatot.", 255, 255, 255, true)
    outputChatBox(core:getServerPrefix("server", "Darukezelő", 2).."A daru meg lett jelölve a térképen egy "..color.."narancssárga#ffffff daru ikonnal.", 255, 255, 255, true)
    currentDropPlaceCol = createColCuboid(unpack(jobs[craneID][taskID].dropPlace))

    for k, v in ipairs(jobs[craneID][taskID].objects) do 
        createCraneableObject(unpack(v))
        createdObjects = createdObjects + 1
    end

    enterMarker = exports.oCustomMarker:createCustomMarker(cranes[craneID].enterMarker[1], cranes[craneID].enterMarker[2], cranes[craneID].enterMarker[3], 2, r, g, b, 200)
    setElementData(enterMarker, "craneHead", craneHeads[craneID])
end

addEventHandler("onClientResourceStop", resourceRoot, function()
    if isElement(enterMarker) then destroyElement( enterMarker ) end
end)

addEventHandler("onClientMarkerHit", root, function(player, mdim)
    if source == enterMarker then 
        if player == localPlayer then 
            if not getPedOccupiedVehicle( localPlayer ) then
                if mdim then
                    controlledCrane = getElementData(enterMarker, "craneHead")
                    addEventHandler("onClientRender", root, renderCrane)
                    setElementFrozen(localPlayer, true)
                    setElementCollisionsEnabled(localPlayer,false)
                        
                    triggerServerEvent("craneJob > setPlayerAlpha", resourceRoot, 0)

                    showChat(false)
                    exports.oInterface:toggleHud(true)
                end
            end
        end
    end
end)

-- Munka felvétele üzenetek, ped létrehozása, stb
local jobelements = {}
function pickupCraneJob()
    outputChatBox(core:getServerPrefix("server", "Darukezelő", 2).."A munka megkezdéséhez menj a #f2c222sárga táska #ffffffblippel megjelölt építésvezetőhöz és beszélj vele.", 255, 255, 255, true)
    outputChatBox(core:getServerPrefix("server", "Darukezelő", 2).."Az építésvezetőhöz a régi Skate Parknál találod a dombon elhelyezett lakókocsiknál.", 255, 255, 255, true)

    local blip = createBlip(pedPos[1], pedPos[2], pedPos[3], 11)
    setElementData(blip, "blip:name", "Építésvezető")

    epitesvezetoPed = createPed(153, pedPos[1], pedPos[2], pedPos[3], pedPos[4])
    setElementData(epitesvezetoPed, "ped:name", "Bobby Wells")
    setElementData(epitesvezetoPed, "ped:prefix", "Építésvezető")
    setElementFrozen(epitesvezetoPed, true)

    table.insert(jobelements, blip)
    table.insert(jobelements, epitesvezetoPed)
end

addEventHandler("onClientElementDataChange", root, function(data, old, new)
    if source == localPlayer then 
        if data == "char:job" then 
            if old == 8 then 
                for k, v in ipairs(jobelements) do 
                    destroyElement(v)
                end
                jobelements = {}
            elseif new == 8 then 
                pickupCraneJob()
            end
        elseif data == "craneJob:xp" then -- SZINTRENDSZER
            if new >= xpToLevelUp then 
                local newLevel = getElementData(localPlayer, "craneJob:level") or 0
                newLevel = newLevel + 1
                outputChatBox(core:getServerPrefix("server", "Darukezelő", 2).."Szintet léptél! Új szinted: "..color..newLevel.."#ffffff.", 255, 255, 255, true)
                setElementData(localPlayer, "craneJob:level", newLevel)
                setElementData(localPlayer, "craneJob:xp", 0)
            end
        end
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    if getElementData(localPlayer, "char:job") == 8 then 
        pickupCraneJob()
    end
end)

