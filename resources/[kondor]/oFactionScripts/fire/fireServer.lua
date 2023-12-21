local createdTrees = {}
local treePosCache = treesTable

function createOneTree(model, pos)
    local x, y, z = unpack(pos)

    local obj = createObject(model, x, y, z)
    setElementDoubleSided(obj, true)

    table.insert(createdTrees, obj)

    local colCount = treesColCount[model] or 1

    local cols = {}
    local peds = {}
    for i = 1, colCount do 
        table.insert(cols, createColSphere(x, y, z, 1))
        table.insert(peds, createPed(1, x, y, z))


        attachElements(cols[#cols], obj, 0, 0, 1.5*(i))
        setElementData(cols[#cols], "wood:col:tree", obj)
        setElementData(cols[#cols], "wood:isCol", true)

        attachElements(peds[#peds], obj, 0, 0, 1.5*(i))
        setElementData(peds[#peds], "wood:isWoodElement", true)
        setElementData(peds[#peds], "ped:damageable", true)
        setElementData(peds[#peds], "wood:woodElement:tree", obj)
        setElementAlpha(peds[#peds], 0)
    end

    setElementData(obj, "tree:cols", cols)
    setElementData(obj, "tree:danger", false)
    setElementData(obj, "tree:allElement", colCount)
    setElementData(obj, "tree:falled", false)
end

function createTrees()
    for k, v in ipairs(treePosCache) do 
        createOneTree(v[1], {v[2], v[3], v[4]})
    end
end 
--createTrees()

function createRandomTree()
    if #treePosCache > 0 then 
        local randNumber = math.random(#treePosCache)
        local random = treePosCache[randNumber]
        table.remove(treePosCache, randNumber)

        createOneTree(655, {random[1], random[2], random[3]})
    end
end

setTimer(function()
    treePosCache = treesTable
   -- for i = 1, math.random(1, 10) do createRandomTree() end
    --setTimer(createRandomTree, core:minToMilisec(60), 0)
end, 2000, 1)

local rands = {90, 270}
function fallRandomTree()
    if #createdTrees > 0 then 
        local randomNumber = math.random(#createdTrees)
        local randomTree = createdTrees[randomNumber]
        local x, y, z = getElementPosition(randomTree)

        local randrot = math.random(0, 360)

        moveObject(randomTree, 3000, x, y, z, 0, 90, randrot, "Linear")

        setElementData(randomTree, "tree:danger", true)

        table.remove(createdTrees, randomNumber)

        local blip = createBlip(x, y, z, 39)
        setElementData(blip, "blip:name", "Kidőlt fa")

        local zoneName = getZoneName(x, y, z)
        local success = math.random(1, 2)
        for k, v in ipairs(getElementsByType("player")) do 
            if getElementData(v, "char:duty:faction") == fireFactionID then 
                if success == 1 then 
                    outputChatBox(core:getServerPrefix("red-light", "Központ", 3).."Figyelem! Kidőlt egy fa "..color..zoneName.." #ffffffterületén!", v, 255, 255, 255, true)
                else
                    outputChatBox(core:getServerPrefix("red-light", "Központ", 3).."F**ye***! K*d**t *g* ** "..color.."**********".." #ffffff*er**e***!", v, 255, 255, 255, true)
                end
            end
        end

        setElementData(randomTree, "tree:blip", blip)

        setTimer(function()
            setElementData(randomTree, "tree:danger", false)

            moveObject(randomTree, 500, x, y, z, 0, -3, 0, "Linear")
            setTimer(function()
                moveObject(randomTree, 250, x, y, z, 0, 3, 0, "Linear")

                setElementData(randomTree, "tree:falled", true)
            end, 500, 1)
        end, 3000, 1)
    end
end
--setTimer(fallRandomTree, core:minToMilisec(90), 0)

addEventHandler("onPedWasted", resourceRoot, function()
    if getElementData(source, "wood:isWoodElement") then 
        local tree = getElementData(source, "wood:woodElement:tree")
        setElementData(tree, "tree:allElement", getElementData(tree, "tree:allElement")-1)

        if getElementData(tree, "tree:allElement") <= 0 then 
            for k, v in ipairs(getElementData(tree, "tree:cols")) do 
                destroyElement(v)
            end

            local posx, poy, posz = getElementPosition(tree)
            posz = posz + 1
            table.insert(treePosCache, {getElementModel(tree), posx, poy, posz})
            destroyElement(getElementData(tree, "tree:blip"))
            destroyElement(tree)
            faction:setFactionBankMoney(fireFactionID, 5000, "add")
        end

        destroyElement(source)
    end
end)

-- Fire 
local fireExists = false 
local allFires = 0
local fireBlip = false

function createRandomFire()
    if not fireExists then 
        fireExists = true
        local random = math.random(#firePositions)
        allFires = #firePositions[random]

        for k, v in ipairs(firePositions[random]) do 
            if k == 1 then 
                fireBlip = createBlip(v[1], v[2], v[3], 38)
                setElementData(fireBlip, "blip:name", "Tűz")

                local zoneName = getZoneName(v[1], v[2], v[3])
                local success = math.random(1, 2)
                for k, v in ipairs(getElementsByType("player")) do 
                    if faction:isPlayerInFaction(v, fireFactionID) then 
                        if success == 1 then 
                            outputChatBox(core:getServerPrefix("red-light", "Központ", 3).."Figyelem! Tűz van "..color..zoneName.." #ffffffterületén!", v, 255, 255, 255, true)
                        else
                            outputChatBox(core:getServerPrefix("red-light", "Központ", 3).."F**ye***! **z v*n "..color.."**********".." #ffffff*er**e***!", v, 255, 255, 255, true)
                        end
                    end
                end
            end

            local fireObj = createObject(fireObj, v[1], v[2], v[3]-0.4)
            setElementCollisionsEnabled(fireObj, false)
            setElementAlpha(fireObj, 0)

            setElementData(fireObj, "fire:isFireObj", true)

            local colShape = createColTube(v[1], v[2], v[3]-1, 1.5, 2)
            setElementData(colShape, "fire:isFireColShape", true)

            local colShape2 = createColTube(v[1], v[2], v[3]-1, 3, 2)
            setElementData(colShape2, "fire:isFireExhaustColShape", true)
            setElementData(colShape2, "fire:fireObj", fireObj)
            setElementData(colShape2, "fire:hp", 100)

            setElementData(fireObj, "fire:fireObjCol", colShape2)

            setElementData(fireObj, "fire:fireCol", colShape)
            setElementData(fireObj, "fire:fireExhaustCol", colShape2)
        end
    end
end
setTimer(createRandomFire, core:minToMilisec(80), 0)
--createRandomFire()

addEvent("factionScripts > fire > exhaustFireOnServer", true)
addEventHandler("factionScripts > fire > exhaustFireOnServer", resourceRoot, function(fireObject)
    local col1, col2 = getElementData(fireObject, "fire:fireCol"), getElementData(fireObject, "fire:fireExhaustCol")
    destroyElement(fireObject)
    destroyElement(col1)
    destroyElement(col2)

    allFires = allFires - 1 

    if allFires == 0 then 
        destroyElement(fireBlip)
        fireExists = false
        faction:setFactionBankMoney(fireFactionID, 10000, "add")
    end
end)

-- Water tank
function createWaterTanks()
    for k, v in ipairs(waterTanks) do 
        local fireHidrant = createObject(1211, v[1], v[2], v[3]-0.6, 0, 0, v[4])
        setElementCollisionsEnabled(fireHidrant, false)
        local col = createObject(9131, v[1], v[2], v[3]-1.2, 0, 0, v[4])
        setElementAlpha(col, 0)
        setElementData(fireHidrant, "isFireHidrant", true)
        setElementData(col, "fireHidrantObj", fireHidrant)
    end
end
createWaterTanks()