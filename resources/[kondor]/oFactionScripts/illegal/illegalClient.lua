local inCreateOpening = false
local nowOpendCreateData = {}

addEventHandler("onClientClick", root, function(key, state, _, _, _, _, _, element)
    if key == "right" and state == "up" and element then 
        if getElementData(element, "illegal:boxType") then 
            if core:getDistance(element, localPlayer) < 2.5 then 
                if inCreateOpening then return end
                if getElementData(element, "illegal:boxIsUnderOpening") then outputChatBox(core:getServerPrefix("red-dark", "Láda", 2).."Ez a láda már kinyitás alatt áll!", 255, 255, 255, true) return end

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

                    local progressTime = boxOpingTimes[getElementData(element, "illegal:boxType")]

                    if openerItem == 163 then 
                        progressTime = progressTime*0.8
                    end

                    core:createProgressBar("Láda kinyitása..", progressTime, "factionScripts > illegal > completeCreateOpening", true)

                    outputChatBox(core:getServerPrefix("green-dark", "Láda", 2).."Elkezdted a láda kibontását!", 255, 255, 255, true)
                    infobox:outputInfoBox("Elkezdted a láda kibontását!", "success")

                    nowOpendCreateData = {progressTime, openerItem, element, getElementData(element, "illegal:boxType"), slot, value}
                    triggerServerEvent("factionScripts > illegal > startCreateOpeningOnServer", resourceRoot, element)
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Láda", 2).."Nincs megfelelő eszközöd a láda kibontásához!", 255, 255, 255, true)
                    infobox:outputInfoBox("Nincs megfelelő eszközöd a láda kibontásához!", "error")
                end
            end
        end
    end
end)    

addEvent("factionScripts > illegal > completeCreateOpening", true)
addEventHandler("factionScripts > illegal > completeCreateOpening", root, function()
    inCreateOpening = false

    if not inventory:hasItem(nowOpendCreateData[2]) then
        infobox:outputInfoBox("Nincs nálad a kinyitáshoz szükséges eszköz!", "error")
        setElementFrozen(localPlayer, false)
        triggerServerEvent("factionScripts > illegal > completeCreateOpeningOnServer", resourceRoot, nowOpendCreateData[3], nowOpendCreateData[4], false)
        return
    end

    if nowOpendCreateData[2] == 163 then 
        chat:sendLocalMeAction("kinyitott egy ládát egy fúró segítségével.")

        if (nowOpendCreateData[6]-20) <= 0 then 
            inventory:delItem(nowOpendCreateData[5], _, "bag")
        else 
            inventory:setItemValue(nowOpendCreateData[5], nowOpendCreateData[6]-20)
        end
    elseif nowOpendCreateData[2] == 164 then 
        chat:sendLocalMeAction("kinyitott egy ládát egy feszítővas segítségével.")

        if (nowOpendCreateData[6]-5) <= 0 then 
            inventory:delItem(nowOpendCreateData[5], _, "bag")
        else 
            inventory:setItemValue(nowOpendCreateData[5], nowOpendCreateData[6]-5)
        end
    else
        chat:sendLocalMeAction("kinyitott egy ládát.")
    end

    local itemValues = {0, 0}

    local randomItem = lootCreateItems[nowOpendCreateData[4]][math.random(#lootCreateItems[nowOpendCreateData[4]])]
    if nowOpendCreateData[4] == "weapon" or nowOpendCreateData[4] == "bankrob" then 
        local run = 0
        while not (math.random(0, randomItem.chance) == 1) do 
            run = run + 1
            randomItem = lootCreateItems[nowOpendCreateData[4]][math.random(#lootCreateItems[nowOpendCreateData[4]])]
            itemValues = {randomItem.id, 1, 100}

            if run == 10 then 
                break
            end
        end
    else 
        itemValues = {randomItem.id, math.random(randomItem.min, randomItem.max), 0}
    end

    setElementFrozen(localPlayer, false)

    if (inventory:getAllItemWeight() + (inventory:getItemWeight(itemValues[1])*itemValues[2])) <= 20 then 
        triggerServerEvent("factionScripts > illegal > completeCreateOpeningOnServer", resourceRoot, nowOpendCreateData[3], nowOpendCreateData[4], itemValues)

        outputChatBox(core:getServerPrefix("green-dark", "Láda", 2).."Sikeresen kinyitottál egy ládát! "..color.."(Kapott tárgy: "..inventory:getItemName(itemValues[1])..")", 255, 255, 255, true)
        infobox:outputInfoBox("Kinyitottál egy ládát! (Kapott tárgy: "..inventory:getItemName(itemValues[1])..")", "success")
    else
        triggerServerEvent("factionScripts > illegal > completeCreateOpeningOnServer", resourceRoot, nowOpendCreateData[3], nowOpendCreateData[4], false)

        outputChatBox(core:getServerPrefix("yellow", "Láda", 2).."Sikeresen kinyitottál egy ládát! "..color.."(Mivel nincs hely az inventorydban így nem kaptál egyetlen tárgyat sem!)", 255, 255, 255, true)
        infobox:outputInfoBox("Kinyitottál egy ládát! (Mivel nincs hely az inventorydban így nem kaptál egyetlen tárgyat sem!)", "warning")
    end
end)

addEvent("playHornSound", true)
addEventHandler("playHornSound", root, function(pos)
    local sound = playSound3D("files/ship_horn.mp3", unpack(pos))
    setSoundMaxDistance(sound, 250)
    setSoundVolume(sound, 1.5)
end)   

admin = exports.oAdmin
admin:addAdminCMD("delweaponship", 8, "Fegyverhajó törlése")
admin:addAdminCMD("startweaponship", 8, "Fegyverhajó létrehozása")

--watching strippers >>

addEventHandler("onClientResourceStart",resourceRoot,function()
    local dancer1 = createPed(145,1207.9470214844, -5.6191511154175, 1001.328125,268.95541381836)
    local dancer2 = createPed(63,1207.8784179688, -7.3667435646057, 1001.328125,268.95541381836)
    local dancer3 = createPed(140,1214.0065917969, -4.230016708374, 1001.328125,43.08667755127)
    local dancer4 = createPed(140,1220.8679199219, 8.2261838912964, 1001.3356323242,134.43577575684)

    setElementDimension(dancer1,138)
    setElementInterior(dancer1,2)
    setPedAnimation(dancer1,"strip","strip_a")
    setElementData(dancer1,"ped:name","Amy Rodrigez");
    setElementData(dancer1,"ped:prefix","Táncos");

    setElementDimension(dancer2,138)
    setElementInterior(dancer2,2)
    setPedAnimation(dancer2,"strip","strip_b")
    setElementData(dancer2,"ped:name","Clara Johanson");
    setElementData(dancer2,"ped:prefix","Táncos");

    setElementDimension(dancer3,138)
    setElementInterior(dancer3,2)
    setPedAnimation(dancer3,"strip","strip_g")
    setElementData(dancer3,"ped:name","Fiona Hadley");
    setElementData(dancer3,"ped:prefix","Táncos");

    setElementDimension(dancer4,138)
    setElementInterior(dancer4,2)
    setPedAnimation(dancer4,"strip","strip_g")
    setElementData(dancer4,"ped:name","Rachael Zara");
    setElementData(dancer4,"ped:prefix","Táncos");
end)