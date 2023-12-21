addEvent("planeCrash > planeCreated", true)
addEventHandler("planeCrash > planeCreated", root, function(pos)
    createEffect("explosion_large", pos[1], pos[2], pos[3], _, _, _, 0, true)
end)

local inCreateOpening = false
local nowOpendCreateData = {}

function sendError(msg)
    outputChatBox(core:getServerPrefix("red-dark", "Láda", 2)..msg, 255, 255, 255, true)
    infobox:outputInfoBox(msg, "error")
end

addEventHandler("onClientClick", root, function(key, state, _, _, _, _, _, element)
    if key == "right" and state == "up" and element then 
        if getElementData(element, "plane:boxType") then 
            if core:getDistance(element, localPlayer) < 2.5 then 
                if inCreateOpening then return end
                if isElement(getElementData(element, "illegal:boxIsUnderOpening")) then outputChatBox(core:getServerPrefix("red-dark", "Láda", 2).."Ez a láda már kinyitás alatt áll!", 255, 255, 255, true) return end

                if exports.oDashboard:isPlayerFactionTypeMember({4, 5}) then
                    local openerItem = 0
                    local slot = 0
                    local value = 0

                    if inventory:hasItem(163) then
                        openerItem = 163 
                        _, _, value, slot = inventory:hasItem(163)
                    elseif inventory:hasItem(164) then 
                        openerItem = 164
                        _, _, value, slot = inventory:hasItem(164)
                    end

                    if openerItem > 0 then 
                        inCreateOpening = true 
                        setElementFrozen(localPlayer, true)

                        local progressTime = math.random(25000, 40000)

                        if openerItem == 163 then 
                            progressTime = progressTime*0.8
                        end

                        core:createProgressBar("Láda kinyitása..", progressTime, "planeCrash > completeCreateOpening", true)

                        outputChatBox(core:getServerPrefix("green-dark", "Láda", 2).."Elkezdted a láda kibontását!", 255, 255, 255, true)
                        infobox:outputInfoBox("Elkezdted a láda kibontását!", "success")

                        nowOpendCreateData = {progressTime, openerItem, element, 1, slot, value}
                        triggerServerEvent("planeCrash > startCreateOpeningOnServer", resourceRoot, element)
                    else
                        sendError("Nincs megfelelő eszközöd a láda kinyitásához!")
                    end
                else
                    sendError("Nem vagy illegális frakció tagja!")
                end
            end
        end
    end
end)    

addEvent("planeCrash > completeCreateOpening", true)
addEventHandler("planeCrash > completeCreateOpening", root, function()
    inCreateOpening = false

    if not inventory:hasItem(nowOpendCreateData[2]) then
        infobox:outputInfoBox("Nincs nálad a kinyitáshoz szükséges eszköz!", "error")
        setElementFrozen(localPlayer, false)
        triggerServerEvent("planeCrash > completeCreateOpeningOnServer", resourceRoot, nowOpendCreateData[3], nowOpendCreateData[4], false)
        return
    end

    if nowOpendCreateData[2] == 163 then 
        chat:sendLocalMeAction("kinyitott egy ládát egy fúró segítségével.")
        inventory:setItemState(nowOpendCreateData[6], nowOpendCreateData[5]-20, "bag")
    elseif nowOpendCreateData[2] == 164 then 
        chat:sendLocalMeAction("kinyitott egy ládát egy feszítővas segítségével.")
        inventory:setItemState(nowOpendCreateData[6], nowOpendCreateData[5]-5, "bag")
    else
        chat:sendLocalMeAction("kinyitott egy ládát.")
    end

    setElementFrozen(localPlayer, false)

    itemValues = {211, 1, 1}

    if (inventory:getAllItemWeight() + (inventory:getItemWeight(itemValues[1])*itemValues[2])) <= 20 then 
        triggerServerEvent("planeCrash > completeCreateOpeningOnServer", resourceRoot, nowOpendCreateData[3], nowOpendCreateData[4], itemValues)

        outputChatBox(core:getServerPrefix("green-dark", "Láda", 2).."Sikeresen kinyitottál egy ládát! "..color.."(Kapott tárgy: "..inventory:getItemName(itemValues[1])..")", 255, 255, 255, true)
        infobox:outputInfoBox("Kinyitottál egy ládát! (Kapott tárgy: "..inventory:getItemName(itemValues[1])..")", "success")
    else
        triggerServerEvent("planeCrash > completeCreateOpeningOnServer", resourceRoot, nowOpendCreateData[3], nowOpendCreateData[4], false)

        outputChatBox(core:getServerPrefix("yellow", "Láda", 2).."Sikeresen kinyitottál egy ládát! "..color.."(Mivel nincs hely az inventorydban így nem kaptál egyetlen tárgyat sem!)", 255, 255, 255, true)
        infobox:outputInfoBox("Kinyitottál egy ládát! (Mivel nincs hely az inventorydban így nem kaptál egyetlen tárgyat sem!)", "warning")
    end
end)