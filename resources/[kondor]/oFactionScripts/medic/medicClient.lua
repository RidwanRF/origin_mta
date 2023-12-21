local txd = engineLoadTXD("files/medic.txd")
engineImportTXD(txd, 2919)

local minigameValue = 0
local minigameTime = 1
local last = getTickCount()

local lastRectangle = {0.5, 0.65, 0.03, 0.05}
lastRectangle[1] = math.random(440, 530)/1000
lastRectangle[2] = math.random(645, 785)/1000
lastRectangle[3] = math.random(20, 30)/1000
lastRectangle[4] = math.random(20, 30)/1000

local clickPlus = 0.02
local timeMinus = 0.0005

local revivificatedPlayer

local oldX, oldY, oldW, oldH = 0, 0, 0, 0
local oldvalue = 0

local tick = getTickCount()
local tick2 = getTickCount()

function renderMinigame()

    local renderX, renderY, renderW, renderH
    if  oldX > 0 and oldX > 0 and oldY > 0 and oldW > 0 and oldH > 0 then 
        renderX, renderY = interpolateBetween(oldX, oldY, 0, lastRectangle[1], lastRectangle[2], 0, (getTickCount() - tick)/250, "Linear")
        renderW, renderH = interpolateBetween(oldW, oldH, 0, lastRectangle[3], lastRectangle[4], 0, (getTickCount() - tick)/250, "Linear")
    else
        renderX, renderY, renderW, renderH = lastRectangle[1], lastRectangle[2], lastRectangle[3], lastRectangle[4]
    end

    showCursor(true)

    if minigameTime > 0 then 
        minigameTime = minigameTime - timeMinus
    else
        endMinigame(false)
    end

    dxDrawRectangle(sx*0.5-200/myX*sx/2, sy*0.64, 200/myX*sx, 180/myY*sy, tocolor(35, 35, 35, 255))
    dxDrawRectangle(sx*0.5-200/myX*sx/2+2/myX*sx, sy*0.64+2/myY*sy, 200/myX*sx-4/myX*sx, 180/myY*sy-4/myY*sy, tocolor(40, 40, 40, 255))

    dxDrawRectangle(sx*0.5-200/myX*sx/2, sy*0.845, 200/myX*sx, 10/myY*sy, tocolor(35, 35, 35, 255))
    dxDrawRectangle(sx*0.5-200/myX*sx/2+1.5/myX*sx, sy*0.845+2/myY*sy, 200/myX*sx-4/myX*sx, 10/myY*sy-4/myY*sy, tocolor(40, 40, 40, 255))

    local value = interpolateBetween(oldvalue, 0, 0, minigameValue, 0, 0, (getTickCount() - tick2)/150, "Linear")

    dxDrawRectangle(sx*0.5-200/myX*sx/2+1.5/myX*sx, sy*0.845+2/myY*sy, (200/myX*sx-4/myX*sx)*value, 10/myY*sy-4/myY*sy, tocolor(r, g, b, 200))

    dxDrawRectangle(sx*0.5-200/myX*sx/2, sy*0.858, 200/myX*sx, 10/myY*sy, tocolor(35, 35, 35, 255))
    dxDrawRectangle(sx*0.5-200/myX*sx/2+1.5/myX*sx, sy*0.858+2/myY*sy, 200/myX*sx-4/myX*sx, 10/myY*sy-4/myY*sy, tocolor(40, 40, 40, 255))
    dxDrawRectangle(sx*0.5-200/myX*sx/2+1.5/myX*sx, sy*0.858+2/myY*sy, (200/myX*sx-4/myX*sx)*minigameTime, 10/myY*sy-4/myY*sy, tocolor(224, 70, 70, 200))

    dxDrawRectangle(sx*renderX, sy*renderY, sx*renderW, sy*renderH, tocolor(33, 33, 33, 255))
end

function keyMinigame(key, state)
    if key == "mouse1" and state then 
        if core:isInSlot(sx*lastRectangle[1], sy*lastRectangle[2], sx*lastRectangle[3], sy*lastRectangle[4]) then 
            oldvalue = minigameValue
            minigameValue = minigameValue + clickPlus
            tick2 = getTickCount()

            tick = getTickCount()
            oldX, oldY, oldW, oldH = lastRectangle[1], lastRectangle[2], lastRectangle[3], lastRectangle[4]

            lastRectangle[1] = math.random(4400, 5300)/10000
            lastRectangle[2] = math.random(6450, 7850)/10000
            lastRectangle[3] = math.random(200, 300)/10000
            lastRectangle[4] = math.random(200, 300)/10000

            if minigameValue >= 1 then 
                endMinigame("success")
            end
        end
    end
end

function endMinigame(type)
    if type == "success" then
        local hasItem, id, value, slot = inventory:hasItem(81)
        if hasItem then 
            --outputChatBox(slot)
            --inventory:takeItem(slot)
            infobox:outputInfoBox("Sikeresen újraélesztetted a pácienst!", "success")
            triggerServerEvent("factionScripts > medic > revivificationSuccess", resourceRoot, revivificatedPlayer, id)
            chat:sendLocalMeAction("felsegítette "..getPlayerName(revivificatedPlayer):gsub("_", " ").."-t.")
        else
            infobox:outputInfoBox("Sikeresen felélesztetted a pácienst, de nem volt nálad kellő felszerelés az ellátásához!", "error")
            triggerServerEvent("factionScripts > medic > revivificationUnsuccess", resourceRoot, revivificatedPlayer)
            chat:sendLocalDoAction("nem sikerült felsegítenie "..getPlayerName(revivificatedPlayer):gsub("_", " ").."-t.")
        end
    else
        infobox:outputInfoBox("Sikertelen újraélesztés!", "error")
        triggerServerEvent("factionScripts > medic > revivificationUnsuccess", resourceRoot, revivificatedPlayer)
        chat:sendLocalDoAction("nem sikerült felsegítenie "..getPlayerName(revivificatedPlayer):gsub("_", " ").."-t.")
    end
    showCursor(false)
    removeEventHandler("onClientKey", root, keyMinigame)
    removeEventHandler("onClientRender", root, renderMinigame)
end

function startMinigame()
    oldX, oldY, oldW, oldH = 0, 0, 0, 0
    addEventHandler("onClientKey", root, keyMinigame)
    addEventHandler("onClientRender", root, renderMinigame)
end

function startPlayerRevivification(player)
    if inventory:hasItem(81) then 
        revivificatedPlayer = player
        minigameValue = 0
        minigameTime = 1
        startMinigame() 
        chat:sendLocalMeAction("elkezdte felsegíteni "..getPlayerName(player):gsub("_", " ").."-t.")
        local pFaction = getElementData(localPlayer, "char:duty:faction") or 0

        if pFaction > 0 then 
            if faction:getFactionType(pFaction) == 2 then
                clickPlus = 0.04
                timeMinus = 0.0005
            end
        end

        revivificatedPlayer = player
        minigameValue = 0
        minigameTime = 1
        startMinigame() 
    else
        outputChatBox(core:getServerPrefix("red-dark", "Felsegítés", 3).."Nincs nálad elsősegély csomag!", 255, 255, 255, true)
    end
end

local function interactionRender()
    core:dxDrawShadowedText("Gyógyítás kéréséhez nyomd meg az "..color.."[E] #ffffffgombot. "..color.."(500$)", 0, sy*0.89, sx, sy*0.89+sy*0.05, tocolor(255, 255, 255, 255), tocolor(0, 0, 0, 255), 0.8/myX*sx, fonts["condensed-12"], "center", "center", false, false, false, true)
end

local medicPed = {Vector3(1168.0991210938, -1351.8599853516, 15.4140625), 90}
local medicCol = createColTube(medicPed[1].x, medicPed[1].y, medicPed[1].z-1, 1.5, 2)
medicPed = createPed(274, medicPed[1].x, medicPed[1].y, medicPed[1].z, medicPed[2])
setElementFrozen(medicPed, true)
setElementData(medicPed, "ped:name", "Rayen Morrison")

setElementDimension(medicPed, 0)
setElementInterior(medicPed, 0)

setElementDimension(medicCol, 0)
setElementInterior(medicCol, 0)

addEventHandler("onClientColShapeHit", resourceRoot, function(player, mdim)
    if player == localPlayer then
        if mdim then
            if source == medicCol then 
                addEventHandler("onClientRender", root, interactionRender)
                bindKey("e", "up", buyHelp)
            end
        end
    end
end)

addEventHandler("onClientColShapeLeave", resourceRoot, function(player, mdim)
    if player == localPlayer then
        if mdim then 
            if source == medicCol then 
                removeEventHandler("onClientRender", root, interactionRender)
                unbindKey("e", "up", buyHelp)
            end
        end
    end
end)

function isPlayerBonedDamage()
    local torve = false
    for k, v in pairs(getElementData(localPlayer, "char:bones")) do 
        if v > 0 then 
            torve = true 
            break
        end
    end

    return torve
end

function buyHelp()
    local medicCount = 0

    for k, v in ipairs(getElementsByType("player")) do 
        if (getElementData(v, "char:duty:faction") or 0) == medicFactionID then 
            medicCount = medicCount + 1
        end
    end

    if (getElementHealth(localPlayer) <= 90 or isPlayerBonedDamage()) then 
        if medicCount == 0 then
            if getElementData(localPlayer, "char:money") >= 500 then 
                triggerServerEvent("factionScripts > medic > fixPlayerHealth", resourceRoot)
                infobox:outputInfoBox("Meggyógyítottak!", "success")
            else
                infobox:outputInfoBox("Nincs elegendő pénzed!", "error")
            end
        else
            infobox:outputInfoBox("Jelenleg van elérhető mentős!", "error")
        end
    else
        infobox:outputInfoBox("Nincs szükséged gyógyításra!", "error")
    end
end

-- Heal 
local lastHeal = 0
addCommandHandler("heal", function(cmd, id)
    local pFaction = getElementData(localPlayer, "char:duty:faction") or 0

    if pFaction == medicFactionID then 
        if tonumber(id) then 
            local player = core:getPlayerFromPartialName(localPlayer, tonumber(id), false, 2)
            if player then
                if not (player == localPlayer) then
                    if core:getDistance(player, localPlayer) < 3 then 
                        if lastHeal + 15000 < getTickCount() then
                            chat:sendLocalMeAction("meggyógyította "..getPlayerName(player):gsub("_", " ").."-t.")
                            triggerServerEvent("factionScripts > medic > setPlayerHealthTo100", resourceRoot, player)
                            setElementData(player, "char:bones", {["head"] = 0, ["body"] = 0, ["l_leg"] = 0, ["r_leg"] = 0, ["r_arm"] = 0, ["l_arm"] = 0})
                            setElementData(target, "char:sick", 0)
                            setElementData(localPlayer, "hit.cut", 0)
                            setElementData(localPlayer, "hit.shot", 0)
                            setElementData(localPlayer, "hit.cuttorso", 0)
                            setElementData(localPlayer, "hit.cutleftarm", 0)
                            setElementData(localPlayer, "hit.cutrightarm", 0)
                            setElementData(localPlayer, "hit.cutleftleg", 0)
                            setElementData(localPlayer, "hit.cutrightleg", 0)
                            setElementData(localPlayer, "hit.cutass", 0)
                            setElementData(localPlayer, "hit.shottorso", 0)
                            setElementData(localPlayer, "hit.shotleftarm", 0)
                            setElementData(localPlayer, "hit.shotrightarm", 0)
                            setElementData(localPlayer, "hit.shotleftleg", 0)
                            setElementData(localPlayer, "hit.shotrightleg", 0)
                            setElementData(localPlayer, "hit.shotass", 0)
                            lastHeal = getTickCount()
                        else
                            outputChatBox(core:getServerPrefix("red-dark", "Gyógyítás", 2).."Csak "..color.."15#ffffff másodpercenkén gyógyíthatsz!", 255, 255, 255, true)
                        end
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Gyógyítás", 2).."Túl távol vagy!", 255, 255, 255, true)
                    end 
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Gyógyítás", 2).."Magadat nem gyógyíthatod!", 255, 255, 255, true)
                end
            end
        else
            outputChatBox(core:getServerPrefix("server", "Használat", 3).."/"..cmd.." [Játékos ID]", 255, 255, 255, true)
        end
    end
end)

-- Msegit 
local lastMsegit = 0--exports.oJSON:loadDataFromJSONFile("riugsdfhjfgsdfg25", true) or 0
addCommandHandler("msegit", function()
    if (exports.oDashboard:getOnlineFactionTypeMemberCount({2}) == 0) then 
        if (lastMsegit + core:minToMilisec(60)) < getElementData(resourceRoot, "medic:serverTick") then 
            if getElementHealth(localPlayer) > 0 and getElementData(localPlayer, "playerInAnim") then
                lastMsegit = getElementData(resourceRoot, "medic:serverTick")
                exports.oJSON:saveDataToJSONFile(lastMsegit, "riugsdfhjfgsdfg25", true)
                triggerServerEvent("factionScripts > medic > revivificationSuccess", resourceRoot, localPlayer)

                outputChatBox(core:getServerPrefix("green-dark", "Gyógyítás", 2).."Sikeresen felsegítetted magadat! (Legközelebb 1 óra múlva használhatod a parancsot!)", 255, 255, 255, true)
                setElementData(localPlayer, "hit.cut", 0)
                setElementData(localPlayer, "hit.shot", 0)
                setElementData(localPlayer, "hit.cuttorso", 0)
                setElementData(localPlayer, "hit.cutleftarm", 0)
                setElementData(localPlayer, "hit.cutrightarm", 0)
                setElementData(localPlayer, "hit.cutleftleg", 0)
                setElementData(localPlayer, "hit.cutrightleg", 0)
                setElementData(localPlayer, "hit.cutass", 0)
                setElementData(localPlayer, "hit.shottorso", 0)
                setElementData(localPlayer, "hit.shotleftarm", 0)
                setElementData(localPlayer, "hit.shotrightarm", 0)
                setElementData(localPlayer, "hit.shotleftleg", 0)
                setElementData(localPlayer, "hit.shotrightleg", 0)
                setElementData(localPlayer, "hit.shotass", 0)
            else
                outputChatBox(core:getServerPrefix("red-dark", "Gyógyítás", 2).."Nincs szükséged erre a lehetőségre, ugyanis nem vagy animban!", 255, 255, 255, true)
            end
        else
            outputChatBox(core:getServerPrefix("red-dark", "Gyógyítás", 2).."Óránként csak "..color.."1x #ffffffhasználhatod ezt a lehetőséget!", 255, 255, 255, true)
        end
    else
        outputChatBox(core:getServerPrefix("red-dark", "Gyógyítás", 2).."Jelenleg van szolgálatban lévő mentős!"..color.." (112)", 255, 255, 255, true)
    end
end)

setElementData(localPlayer, "hit.cut", 0)
setElementData(localPlayer, "hit.shot", 0)
setElementData(localPlayer, "hit.cuttorso", 0)
setElementData(localPlayer, "hit.cutleftarm", 0)
setElementData(localPlayer, "hit.cutrightarm", 0)
setElementData(localPlayer, "hit.cutleftleg", 0)
setElementData(localPlayer, "hit.cutrightleg", 0)
setElementData(localPlayer, "hit.cutass", 0)
setElementData(localPlayer, "hit.shottorso", 0)
setElementData(localPlayer, "hit.shotleftarm", 0)
setElementData(localPlayer, "hit.shotrightarm", 0)
setElementData(localPlayer, "hit.shotleftleg", 0)
setElementData(localPlayer, "hit.shotrightleg", 0)
setElementData(localPlayer, "hit.shotass", 0)
addEventHandler("onClientPlayerDamage", localPlayer, function(attacker, weapon, bodypart)
    if weapon == 4 or weapon == 8 then
        setElementData(localPlayer, "hit.cut", getElementData(localPlayer, "hit.cut")+1)
        if bodypart == 3 then
            setElementData(localPlayer,"hit.cuttorso", getElementData(localPlayer, "hit.cuttorso")+1)
        elseif bodypart == 4 then
            setElementData(localPlayer,"hit.cutass", getElementData(localPlayer, "hit.cutass")+1)
        elseif bodypart == 5 then
            setElementData(localPlayer,"hit.cutleftarm", getElementData(localPlayer, "hit.cutleftarm")+1)
        elseif bodypart == 6 then
            setElementData(localPlayer,"hit.cutrightarm", getElementData(localPlayer, "hit.cutrightarm")+1) 
        elseif bodypart == 7 then
            setElementData(localPlayer,"hit.cutleftleg", getElementData(localPlayer, "hit.cutleftleg")+1)
        elseif bodypart == 4 then
            setElementData(localPlayer,"hit.cutrightleg", getElementData(localPlayer, "hit.cutrightleg")+1)
        end    
    else 
        setElementData(localPlayer, "hit.shot", getElementData(localPlayer, "hit.shot")+1)
        if bodypart == 3 then
            setElementData(localPlayer,"hit.shottorso", getElementData(localPlayer, "hit.shottorso")+1)
        elseif bodypart == 4 then
            setElementData(localPlayer,"hit.shotass", getElementData(localPlayer, "hit.shotass")+1)
        elseif bodypart == 5 then
            setElementData(localPlayer,"hit.shotleftarm", getElementData(localPlayer, "hit.shotleftarm")+1)
        elseif bodypart == 6 then
            setElementData(localPlayer,"hit.shotrightarm", getElementData(localPlayer, "hit.shotrightarm")+1) 
        elseif bodypart == 7 then
            setElementData(localPlayer,"hit.shotleftleg", getElementData(localPlayer, "hit.shotleftleg")+1)
        elseif bodypart == 4 then
            setElementData(localPlayer,"hit.shotrightleg", getElementData(localPlayer, "hit.shotrightleg")+1)
        end  
    end
end)

addCommandHandler("seruleseim", function()
    if getElementData(localPlayer, "hit.cut") > 0 or getElementData(localPlayer, "hit.shot") > 0 then
        outputChatBox(core:getServerPrefix("red-dark", "Sérülések", 3).."A sérüléseid listája:", 255, 255, 255, true)
        if getElementData(localPlayer, "hit.cuttorso") > 0 then
            outputChatBox(core:getServerPrefix("red-dark", "Sérülések", 3).."(#858585"..getElementData(localPlayer, "hit.cuttorso").."#ffffff) "..color.."vágás #ffffffa törzsön.", 255, 255, 255, true)
        end
        if getElementData(localPlayer, "hit.cutleftarm") > 0 then
            outputChatBox(core:getServerPrefix("red-dark", "Sérülések", 3).."(#858585"..getElementData(localPlayer, "hit.cutleftarm").."#ffffff) "..color.."vágás #ffffffa balkézen.", 255, 255, 255, true)
        end
        if getElementData(localPlayer, "hit.cutrightarm") > 0 then
            outputChatBox(core:getServerPrefix("red-dark", "Sérülések", 3).."(#858585"..getElementData(localPlayer, "hit.cutleftarm").."#ffffff) "..color.."vágás #ffffffa jobbkézen.", 255, 255, 255, true)
        end
        if getElementData(localPlayer, "hit.cutleftleg") > 0 then
            outputChatBox(core:getServerPrefix("red-dark", "Sérülések", 3).."(#858585"..getElementData(localPlayer, "hit.cutleftarm").."#ffffff) "..color.."vágás #ffffffa ballábon.", 255, 255, 255, true)
        end
        if getElementData(localPlayer, "hit.cutrightleg") > 0 then
            outputChatBox(core:getServerPrefix("red-dark", "Sérülések", 3).."(#858585"..getElementData(localPlayer, "hit.cutleftarm").."#ffffff) "..color.."vágás #ffffffa jobblábon.", 255, 255, 255, true)
        end
        if getElementData(localPlayer, "hit.cutass") > 0 then
            outputChatBox(core:getServerPrefix("red-dark", "Sérülések", 3).."(#858585"..getElementData(localPlayer, "hit.cutass").."#ffffff) "..color.."vágás #ffffffa faron.", 255, 255, 255, true)
        end

        if getElementData(localPlayer, "hit.shottorso") > 0 then
            outputChatBox(core:getServerPrefix("red-dark", "Sérülések", 3).."(#858585"..getElementData(localPlayer, "hit.shottorso").."#ffffff) "..color.."lőtt seb #ffffffa törzsön.", 255, 255, 255, true)
        end
        if getElementData(localPlayer, "hit.shotleftarm") > 0 then
            outputChatBox(core:getServerPrefix("red-dark", "Sérülések", 3).."(#858585"..getElementData(localPlayer, "hit.shotleftarm").."#ffffff) "..color.."lőtt seb #ffffffa balkézen.", 255, 255, 255, true)
        end
        if getElementData(localPlayer, "hit.shotrightarm") > 0 then
            outputChatBox(core:getServerPrefix("red-dark", "Sérülések", 3).."(#858585"..getElementData(localPlayer, "hit.shotleftarm").."#ffffff) "..color.."lőtt seb #ffffffa jobbkézen.", 255, 255, 255, true)
        end
        if getElementData(localPlayer, "hit.shotleftleg") > 0 then
            outputChatBox(core:getServerPrefix("red-dark", "Sérülések", 3).."(#858585"..getElementData(localPlayer, "hit.shotleftarm").."#ffffff) "..color.."lőtt seb #ffffffa ballábon.", 255, 255, 255, true)
        end
        if getElementData(localPlayer, "hit.shotrightleg") > 0 then
            outputChatBox(core:getServerPrefix("red-dark", "Sérülések", 3).."(#858585"..getElementData(localPlayer, "hit.shotleftarm").."#ffffff) "..color.."lőtt seb #ffffffa jobblábon.", 255, 255, 255, true)
        end
        if getElementData(localPlayer, "hit.shotass") > 0 then
            outputChatBox(core:getServerPrefix("red-dark", "Sérülések", 3).."(#858585"..getElementData(localPlayer, "hit.shotass")..") "..color.."lőtt seb a faron.", 255, 255, 255, true)
        end

    else
        outputChatBox(core:getServerPrefix("red-dark", "Sérülések", 3).."Neked nincsenek sérüléseid!", 255, 255, 255, true)
    end
end)