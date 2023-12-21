local handUsed = false

local tempCam = nil

local traffipaxCol = nil

for k, v in ipairs(getElementsByType("vehicle")) do 
    setElementData(v, "veh:police:hasSpeedcam", 1)
end

local kivetel = 0

function getSpeedcamFromVehicle(veh)

    if getElementInterior(localPlayer) > 0 then return outputChatBox(core:getServerPrefix("red-dark", "Traffipax", 3).."Interiorban nem lehetséges!", 255, 255, 255, true) end

    local pFaction = getElementData(localPlayer, "char:duty:faction") or 0

    if pFaction > 0 then 
        if faction:getFactionType(pFaction) == 1 then 
            if not (handUsed) then
                if (getElementData(veh, "veh:police:hasSpeedcam") or 1) >= 1 then 
                    kivetel = getTickCount()
                    chat:sendLocalMeAction("kivesz egy traffipaxot a járműből.")
                    setElementData(veh, "veh:police:hasSpeedcam", 0)
                    handUsed = true

                    tempCam = createObject(17094, getElementPosition(localPlayer))
                    setElementAlpha(tempCam, 50)
                    attachElements(tempCam, localPlayer, 0, 0.8, -1, 0, 0, -90)
                    setElementCollisionsEnabled(tempCam, false)
                    outputChatBox(core:getServerPrefix("server", "Traffipax", 3).."A traffipax lehelyezéséhez nyomd meg az "..color.."[ALT]#ffffff gombot vagy ülj be egy autó anyósülésére.", 255, 255, 255, true)
                    outputChatBox(core:getServerPrefix("server", "Traffipax", 3).."Ahhoz, hogy visszatedd a járműbe kattints rá a"..color.."[Bal]#ffffff klikkel.", 255, 255, 255, true)
                    bindKey("lalt", "up", placeTraffipax)

                else
                    outputChatBox(core:getServerPrefix("red-dark", "Traffipax", 3).."Nincs a kocsiban Traffipax.", 255, 255, 255, true) 
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", "Traffipax", 3).."A kezed már használatban van.", 255, 255, 255, true) 
            end
        else
            outputChatBox(core:getServerPrefix("red-dark", "Traffipax", 3).."Nem vagy rendvédelmi szervezet tagja, vagy nem vagy szolgálatban.", 255, 255, 255, true) 
        end
    else
        outputChatBox(core:getServerPrefix("red-dark", "Traffipax", 3).."Nem vagy rendvédelmi szervezet tagja, vagy nem vagy szolgálatban.", 255, 255, 255, true) 
    end
end

function placeTraffipax()
    local x, y, z = getElementPosition(tempCam)
    local rx, ry, rz = getElementRotation(tempCam)


    triggerServerEvent("factionScripts > pd > putDownSpeedcam", resourceRoot, x, y, z, rx, ry, rz, false)
    destroyElement(tempCam)
    tempCam = nil

    handUsed = false

    unbindKey("lalt", "up", placeTraffipax)
end

addEventHandler("onClientVehicleStartEnter", root, function(player, seat, door)
    if handUsed then
        if player == localPlayer then 
            --[[if seat == 1 then
                destroyElement(tempCam)
                tempCam = nil
            
                handUsed = false
            
                unbindKey("lalt", "up", placeTraffipax)


                chat:sendLocalMeAction("beszerel egy traffipaxot az anyósülésre.")
                triggerServerEvent("factionScripts > pd > putDownSpeedcam", resourceRoot, 0, 0, 0, 0, 0, 0, source)
            else]]
                cancelEvent()
                outputChatBox(core:getServerPrefix("red-dark", "Traffipax", 3).."Traffipaxal nem ülhetsz autóba!", 255, 255, 255, true) 
            --end
        end
    end
end)

local activeSpeedcam = false
function onClick(b, s, _, _, _, _, _, e)
    if isElement(e) then 
        if s == "up" and b == "right" then 
            if getElementData(e, "pd:speedcam") then
                if not getElementData(e, "pd:speedcam:usedPlayer") then
                    local pFaction = getElementData(localPlayer, "char:duty:faction") or 0

                    if pFaction > 0 then 
                        if faction:getFactionType(pFaction) == 1 then 
                            if core:getDistance(localPlayer, e) < 2 then
                                activeSpeedcam = e
                                setElementData(e, "pd:speedcam:usedPlayer", localPlayer)
                                setCamera()
                                setElementFrozen(localPlayer, true)
                                showChat(false)
                                exports.oInterface:toggleHud(true)
                                addEventHandler("onClientRender", root, renderTraffipax)
                                addEventHandler("onClientKey", root, panelKey)
                            end
                        end
                    end
                end
            end
        elseif s == "up" and b == "left" then 
            if handUsed then 
                if (getElementData(e, "veh:police:hasSpeedcam") or 1) == 0 then 
                    if kivetel + 1000 < getTickCount() then
                        chat:sendLocalMeAction("visszatettél egy traffipaxot a járműbe.")
                        destroyElement(tempCam)
                        tempCam = nil

                        setElementData(e, "veh:police:hasSpeedcam", 1)

                        handUsed = false

                        unbindKey("lalt", "up", placeTraffipax)
                    end
                end
            end
        end
    end
end
addEventHandler("onClientClick", root, onClick)

local sx, sy = guiGetScreenSize()
function setCamera()
    local test = createObject(17094, getElementPosition(activeSpeedcam))
    attachElements(test, activeSpeedcam, -15, 0, 0)
    detachElements(test)
    local x, y, z = getElementPosition(test)
    destroyElement(test)

    local x1, y1, z1 = getElementPosition(activeSpeedcam)
    setCameraMatrix( x1, y1, z1+1.5, x, y, z+1.5)

    traffipaxCol = createColSphere(x, y, z, 15)
end

pd_font = dxCreateFont("files/digital.ttf", 20) 
pd_font_b = dxCreateFont("files/digital.ttf", 30) 

local limit = 50

function renderTraffipax()
    dxDrawRectangle(0, sy*0.9, sx, sy*0.1, tocolor(35, 35, 35, 255))

    local alpha = 100
    dxDrawImage(sx*0.5-100/myX*sx, sy*0.5-100/myY*sy, 200/myX*sx, 200/myY*sy, "files/crosshair.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    camVeh = getElementsWithinColShape(traffipaxCol, "vehicle")

    local text = "NO TARGET"

    if #camVeh == 0 then
        dxDrawRectangle(sx*0.5-100/myX*sx, sy*0.5+110/myY*sy, 200/myX*sx, sy*0.05, tocolor(35, 35, 35, alpha))
        dxDrawText("NO TARGET", sx*0.5-100/myX*sx, sy*0.5+110/myY*sy, sx*0.5-100/myX*sx + 200/myX*sx, sy*0.5+110/myY*sy + sy*0.05, tocolor(255, 255, 255,alpha), 1/myX*sx, pd_font, "center", "center")
    else
        alpha = 255
        local driver = getVehicleOccupants(camVeh[1])
        local speed = math.floor(getElementSpeed(camVeh[1], "km/h"))

        speedcolor = "#7cde83"

        if speed > limit then 
            speedcolor = "#de6868"
        end

        text = getVehiclePlateText(camVeh[1]) ..speedcolor.. " ("..speed.."km/h)"

        local text_width = dxGetTextWidth(text, 1/myX*sx, pd_font, true) + sx*0.01

        dxDrawRectangle(sx*0.5 - text_width / 2, sy*0.5+110/myY*sy, text_width, sy*0.05, tocolor(35, 35, 35, alpha))
        dxDrawText(text, sx*0.5 - text_width / 2, sy*0.5+110/myY*sy, sx*0.5 - text_width / 2 + text_width, sy*0.5+110/myY*sy + sy*0.05, tocolor(255, 255, 255,alpha), 1/myX*sx, pd_font, "center", "center", false, false, false, true)
    end


    dxDrawRectangle(sx*0.02, sy*0.94, sx*0.1, sy*0.05, tocolor(30, 30, 30, 255))
    dxDrawText("SPEED LIMIT:", sx*0.02, sy*0.90, sx*0.02 + sx*0.1, sy*0.90 + sy*0.05, tocolor(255, 255, 255, 255), 0.7/myX*sx, pd_font, "left", "center")
    dxDrawText(limit, sx*0.02, sy*0.94, sx*0.02 + sx*0.1, sy*0.94 + sy*0.05, tocolor(255, 255, 255, 255), 0.9/myX*sx, pd_font, "center", "center")

    if core:isInSlot(sx*0.02, sy*0.94,sx*0.02, sy*0.05) then 
        dxDrawText("+", sx*0.02, sy*0.94, sx*0.02 + sx*0.02, sy*0.94 + sy*0.05, tocolor(255, 255, 255, 255), 1/myX*sx, pd_font_b, "center", "center")
    else
        dxDrawText("+", sx*0.02, sy*0.94, sx*0.02 + sx*0.02, sy*0.94 + sy*0.05, tocolor(255, 255, 255, 100), 1/myX*sx, pd_font_b, "center", "center")
    end

    if core:isInSlot(sx*0.1, sy*0.94, sx*0.02, sy*0.05) then 
        dxDrawText("-", sx*0.1, sy*0.94, sx*0.1 + sx*0.02, sy*0.94 + sy*0.05, tocolor(255, 255, 255, 255), 1/myX*sx, pd_font_b, "center", "center")
    else
        dxDrawText("-", sx*0.1, sy*0.94, sx*0.1 + sx*0.02, sy*0.94 + sy*0.05, tocolor(255, 255, 255, 100), 1/myX*sx, pd_font_b, "center", "center")
    end

    core:dxDrawButton(sx*0.78, sy*0.91, sx*0.1, sy*0.08, r, g, b, 220, "Kilépés", tocolor(255, 255, 255, 255), 0.9, font:getFont("condensed", 10/myX*sx), true, tocolor(0, 0, 0, 50))
    core:dxDrawButton(sx*0.89, sy*0.91, sx*0.1, sy*0.08, 222, 60, 60, 220, "Traffipax felvétele", tocolor(255, 255, 255, 255), 0.9, font:getFont("condensed", 10/myX*sx), true, tocolor(0, 0, 0, 50))
end

local lastkey = 0
function panelKey(key, state)
    if state then
        if key == "space" then 
            if lastkey + 2000 < getTickCount() then
                lastkey = getTickCount()

                fadeCamera(false, 0.1, 255, 255, 255)
                setTimer(function()
                    fadeCamera(true, 0.1)
                end, 100, 1)
                playSound(":oTraffipax/traffipax.wav")

                if camVeh[1] then
                    local driver = getVehicleOccupants(camVeh[1])

                    local speed = math.floor(getElementSpeed(camVeh[1], "km/h"))
                    if speed > limit then 
                        triggerServerEvent("factionScripts > pd > createSpeedImage", resourceRoot, driver[0], camVeh[1], limit)
                    end
                end
            end
        elseif key == "mouse1" then 
            if core:isInSlot(sx*0.78, sy*0.91, sx*0.1, sy*0.08) then 
                closeTraffipax()
            elseif core:isInSlot(sx*0.89, sy*0.91, sx*0.1, sy*0.08) then 
                triggerServerEvent("factionScripts > pd > deleteSpeedcam", resourceRoot, activeSpeedcam)
                closeTraffipax()

                setElementData(veh, "veh:police:hasSpeedcam", 0)
                handUsed = true

                tempCam = createObject(17094, getElementPosition(localPlayer))
                setElementAlpha(tempCam, 50)
                attachElements(tempCam, localPlayer, 0, 0.8, -1, 0, 0, -90)
                setElementCollisionsEnabled(tempCam, false)
                outputChatBox(core:getServerPrefix("server", "Traffipax", 3).."A traffipax lehelyezéséhez nyomd meg az "..color.."[ALT]#ffffff gombot vagy ülj be egy autó anyósülésére.", 255, 255, 255, true)
                outputChatBox(core:getServerPrefix("server", "Traffipax", 3).."Ahhoz, hogy visszatedd a járműbe kattints rá a"..color.."[Bal]#ffffff klikkel.", 255, 255, 255, true)
                bindKey("lalt", "up", placeTraffipax)
            elseif core:isInSlot(sx*0.02, sy*0.94,sx*0.02, sy*0.05) then 
                if limit < 150 then
                    limit = limit + 5
                end
            elseif core:isInSlot(sx*0.1, sy*0.94, sx*0.02, sy*0.05) then 
                if limit > 30 then
                    limit = limit - 5
                end
            end
        end
    end
end

function closeTraffipax()
    setCameraTarget(localPlayer, localPlayer)
    setElementFrozen(localPlayer, false)
    showChat(true)
    exports.oInterface:toggleHud(false)
    removeEventHandler("onClientRender", root, renderTraffipax)
    removeEventHandler("onClientKey", root, panelKey)
    setElementData(activeSpeedcam, "pd:speedcam:usedPlayer", false)
    activeSpeedcam = false
    destroyElement(traffipaxCol)
end

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and 'ignore' argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end
