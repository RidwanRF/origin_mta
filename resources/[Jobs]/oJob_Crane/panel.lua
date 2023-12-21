sx, sy = guiGetScreenSize()
myX, myY = 1768, 992

local alpha = 0
local tick, state = 0, "close"

inJob = false

function renderPanel()
    if state == "open" then 
        if core:getDistance(epitesvezetoPed, localPlayer) > 3 then
            closePanel()
        end

        alpha = interpolateBetween(alpha, 0, 0, 1, 0, 0, (getTickCount() - tick) / 500, "Linear")
    else
        alpha = interpolateBetween(alpha, 0, 0, 0, 0, 0, (getTickCount() - tick) / 500, "Linear")
    end

    local playerName = getPlayerName(localPlayer):gsub("_", " ")
    local xp, level = getElementData(localPlayer, "craneJob:xp") or 0, getElementData(localPlayer, "craneJob:level") or 0

    core:drawWindow(sx*0.25, sy*0.35, sx*0.5, sy*0.4 + 10/myY*sy, "Darukezelő - Munka elvállalása", alpha)

    dxDrawRectangle(sx*0.25 + 6/myX*sx, sy*0.395, sx*0.5 - 12/myX*sx, sy*0.02, tocolor(25, 25, 25, 150 * alpha))
    dxDrawRectangle(sx*0.25 + 8/myX*sx, sy*0.395 + 2/myY*sy, (sx*0.5 - 16/myX*sx ), sy*0.02 - 4/myY*sy, tocolor(40, 40, 40, 50 * alpha))
    dxDrawRectangle(sx*0.25 + 8/myX*sx, sy*0.395 + 2/myY*sy, (sx*0.5 - 16/myX*sx ) * (xp / xpToLevelUp), sy*0.02 - 4/myY*sy, tocolor(r, g, b, 150 * alpha))

    dxDrawText(playerName .. ": " .. color.. xp .. " #ffffffXP | Szint: " .. color.. level, sx*0.25 + 6/myX*sx, sy*0.375, sx*0.745, sy*0.40, tocolor(255, 255, 255, 255 * alpha), 1, font:getFont("p_m", 15/myX*sx), "right", "bottom", false, false, false, true)
    dxDrawText("Darukezelő szint", sx*0.25 + 6/myX*sx, sy*0.375, sx*0.745, sy*0.40, tocolor(255, 255, 255, 255 * alpha), 1, font:getFont("p_bo", 15/myX*sx), "left", "bottom", false, false, false, true)

    local startX = sx*0.25 + 6/myX*sx
    for i = 1, 3 do 

        dxDrawRectangle( startX, sy*0.42, sx*0.1625, sy*0.323 + 10/myY*sy, tocolor(25, 25, 25, 150 * alpha))
        dxDrawImage( startX + 4/myX*sx, sy*0.42 + 4/myX*sx, 25/myX*sx, 25/myX*sx, "files/crane.png", 0, 0, 0, tocolor(255, 255, 255, 255 * alpha))
        dxDrawText(cranes[i].name, startX + sx*0.02, sy*0.42, startX + sx*0.1625, sy*0.4 + sy*0.06, tocolor(255, 255, 255, 255 * alpha), 1, font:getFont("bebasneue", 15/myX*sx), "left", "center")

        dxDrawImage( startX + sx*0.1625 - 29/myX*sx, sy*0.42 + 4/myX*sx, 25/myX*sx, 25/myX*sx, "files/star.png", 0, 0, 0, tocolor(245, 197, 66, 50 * alpha))
        dxDrawText(cranes[i].minLevel, startX + sx*0.1625 - 29/myX*sx, sy*0.42 + 4/myX*sx, startX + sx*0.1625 - 29/myX*sx + 27/myX*sx, sy*0.42 + 4/myX*sx + 30/myX*sx, tocolor(245, 197, 66, 255 * alpha), 1, font:getFont("p_bo", 15/myX*sx), "center", "center")

        dxDrawImage( startX + 4/myX*sx, sy*0.42 + 45/myY*sy, 280/myX*sx, 280/myY*sy, "files/cranes/"..i..".png", 0, 0, 0, tocolor(255, 255, 255, 255 * alpha))

        dxDrawText("Minimum fizetés: #85e075" .. (cranes[i].paymentMultiplyer * defPayment * 4).."$", startX + 4/myX*sx, sy*0.448, startX + sx*0.1625, sy*0.42 + sy*0.323, tocolor(255, 255, 255, 255 * alpha), 0.8, font:getFont("p_m", 15/myX*sx), "left", "top", false, false, false, true)

        if level >= cranes[i].minLevel then
            if core:isInSlot(startX, sy*0.42, sx*0.1625, sy*0.323 + 10/myY*sy) then 
                core:dxDrawOutLine(startX, sy*0.42, sx*0.1625, sy*0.323 + 10/myY*sy, tocolor(r, g, b, 150 * alpha), 2)
            end
        else
            dxDrawRectangle( startX, sy*0.42, sx*0.1625, sy*0.323 + 10/myY*sy, tocolor(25, 25, 25, 200 * alpha))
            dxDrawText(cranes[i].minLevel, startX, sy*0.42, startX + sx*0.1625, sy*0.42 + sy*0.323, tocolor(245, 66, 66, 100 * alpha), 1, font:getFont("p_bo", 50/myX*sx), "center", "bottom")

            dxDrawImage( startX + sx*0.16252/2 - 30/myX*sx, sy*0.42 + 80/myY*sy, 60/myX*sx, 60/myX*sx, "files/crane.png", 0, 0, 0, tocolor(245, 66, 66, 255 * alpha))
            dxDrawText("Még nem érted el a \nszükséges szintet!", startX, sy*0.55, startX + sx*0.1625, sy*0.63, tocolor(245, 66, 66, 255 * alpha), 1, font:getFont("p_bo", 15/myX*sx), "center", "bottom")
        end

        startX = startX + sx*0.1625 + 4/myX*sx
    end
end

function panelKey(key, state)
    if state then 
        if key == "backspace" then 
            closePanel()
        elseif key == "mouse1" then 
            local xp, level = getElementData(localPlayer, "craneJob:xp") or 0, getElementData(localPlayer, "craneJob:level") or 0

            local startX = sx*0.25 + 6/myX*sx
            for i = 1, 3 do 
                if level >= cranes[i].minLevel then
                    if core:isInSlot(startX, sy*0.42, sx*0.1625, sy*0.323 + 10/myY*sy) then 
                        acceptJob(i, math.random(#jobs[i]))
                        break
                    end
                end
        
                startX = startX + sx*0.1625 + 4/myX*sx
            end
        end
    end
end

panelShowing = false

function acceptJob(craneid, taskid)
    closePanel()
    inJob = {craneid, taskid}
    createJobObjects(craneid, taskid)
end

function showPanel()
    panelShowing = true
    tick, state = getTickCount(), "open"
    addEventHandler("onClientRender", root, renderPanel)
    addEventHandler("onClientKey", root, panelKey)
end

function closePanel()
    tick, state = getTickCount(), "close"
    removeEventHandler("onClientKey", root, panelKey)
    setTimer(function()
        removeEventHandler("onClientRender", root, renderPanel)
        panelShowing = false
    end, 500, 1)
end

addEventHandler("onClientClick", root, function(key, state, _, _, _, _, _, element)
    if key == "right" and state == "up" then
        if isElement(element) then 
            if element == epitesvezetoPed then 
                if core:getDistance(element, localPlayer) < 2 then
                    if not inJob then
                        if not panelShowing then
                            showPanel()
                        end
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Darukezelő", 2).."Először végezd el a folyamatban lévő feladatot.", 255, 255, 255, true)
                    end
                end
            end
        end
    end
end)