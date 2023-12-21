local streamedTreeElements = {}
local lastFall = 0

addEventHandler("onClientColShapeHit", resourceRoot, function(element, mdim)
    if element == localPlayer then 
        if getElementData(source, "wood:isCol") then 
            if getElementData(getElementData(source, "wood:col:tree"), "tree:danger") then 
                if lastFall + 3000 < getTickCount() then 
                    chat:sendLocalDoAction("rádőlt egy fa.")
                    lastFall = getTickCount()

                    setElementHealth(localPlayer, getElementHealth(localPlayer) - math.random(10, 50))
                    setElementData(localPlayer, "char:health", getElementHealth(localPlayer))

                    local occupiedVehicle = getPedOccupiedVehicle(localPlayer)
                    if occupiedVehicle then 
                        setElementHealth(occupiedVehicle, getElementHealth(occupiedVehicle) - math.random(100, 300))
                    end
                end
            end
        elseif getElementData(source, "fire:isFireColShape") then 
            if not (getElementData(thePlayer, "char:duty:faction") == fireFactionID) then 
                setPedOnFire(localPlayer, true)
            end
        end
    end
end)

local sx, sy = guiGetScreenSize()
local myX, myY = 1600, 900

local texture = dxCreateTexture(1, 1)
local shader = dxCreateShader("files/ped_shader.fx")
dxSetShaderValue(shader, "reTexture", texture)
engineApplyShaderToWorldTexture(shader, "bloodpool_64")

addEventHandler("onClientPedDamage", resourceRoot, function(attacker, weapon, _, loss)
    if getElementData(source, "wood:isWoodElement") then 
        if getElementData(getElementData(source, "wood:woodElement:tree"), "tree:falled") then 
            if weapon == 9 then 
                local px, py, pz = getElementPosition(source)
                local playerX, playerY, playerZ = getElementPosition(attacker)
                fxAddWood(px, py, getGroundPosition(px, py, pz), playerX, playerY, playerZ, 50)

                --[[setElementHealth(source, getElementHealth(source)+loss-1)

                if getElementHealth(source) <= 0 then 
                    killPed(source)
                end]]
            else
                cancelEvent()
            end
        else   
            cancelEvent()
        end
    end
end)

addEventHandler("onClientPlayerDamage", root, function(attacker, weapon, _, loss)
    if source == localPlayer then
        if weapon == 42 or weapon == 9 then 
            cancelEvent()
        end  
    end
end)

-- Fire 
local createdFires = {}

engineSetModelLODDistance(fireObj, 9999)
addEventHandler("onClientElementStreamIn", resourceRoot, function()
    if getElementModel(source) == fireObj then 
        if getElementData(source, "fire:isFireObj") then 
            local pos = Vector3(getElementPosition(source))

            local effect = createEffect("fire_large", pos.x, pos.y, pos.z)

            createdFires[getElementData(source, "fire:fireObjCol")] = effect
        end
    elseif getElementData(source, "wood:isWoodElement") then 
        streamedTreeElements[source] = source
    end
end)

addEventHandler("onClientElementStreamOut", resourceRoot, function()
    if getElementModel(source) == fireObj then 
        if getElementData(source, "fire:isFireObj") then 
            if createdFires[getElementData(source, "fire:fireObjCol")] then 
                destroyElement(createdFires[getElementData(source, "fire:fireObjCol")])
                createdFires[getElementData(source, "fire:fireObjCol")] = false
            end
        end
    elseif getElementData(source, "wood:isWoodElement") then 
        streamedTreeElements[source] = false
    end
end)

addEventHandler("onClientElementDestroy", resourceRoot, function()
    if getElementModel(source) == fireObj then 
        if getElementData(source, "fire:isFireObj") then 
            if createdFires[getElementData(source, "fire:fireObjCol")] then 
                destroyElement(createdFires[getElementData(source, "fire:fireObjCol")])
                createdFires[getElementData(source, "fire:fireObjCol")] = false
            end
        end
    elseif getElementData(source, "wood:isWoodElement") then 
        streamedTreeElements[source] = false
    end
end)

local lastTrigger = 0
local occupiedFireCol = false
addEventHandler("onClientPlayerWeaponFire", root, function(weapon, _, _, _, _, _, element)
    if isElement(occupiedFireCol) then
        if weapon == 42 then 
            if core:getDistance(occupiedFireCol, localPlayer) < 3 then 
                if lastTrigger + 200 < getTickCount() then 
                    setElementData(occupiedFireCol, "fire:hp", getElementData(occupiedFireCol, "fire:hp")-(0.4*core:getDistance(occupiedFireCol, localPlayer)/10)) -- 0.35

                    if getElementData(occupiedFireCol, "fire:hp") <= 0 then 
                        lastTrigger = getTickCount()


                        triggerServerEvent("factionScripts > fire > exhaustFireOnServer", resourceRoot, getElementData(occupiedFireCol, "fire:fireObj")) 
                        return 
                    end
                end
            end
        end
    end
end)

addEventHandler("onClientColShapeHit", resourceRoot, function(player, mdim)
    if player == localPlayer and mdim then 
        if getElementData(source, "fire:isFireExhaustColShape") then 
            occupiedFireCol = source
        end
    end
end)

addEventHandler("onClientColShapeLeave", resourceRoot, function(player, mdim)
    if player == localPlayer and mdim then 
        if getElementData(source, "fire:isFireExhaustColShape") then 
            occupiedFireCol = false
        end
    end
end)

-- render 

addEventHandler("onClientRender", root, function()
    if getElementData(localPlayer, "char:duty:faction") == fireFactionID then 
        for k, v in pairs(streamedTreeElements) do 
            if isElement(k) then
                if getElementData(getElementData(k, "wood:woodElement:tree"), "tree:falled") then 
                    if core:getDistance(k, localPlayer) < 10 then 
                        drawX, drawY = getScreenFromWorldPosition(getElementPosition(k))

                        if drawX and drawY then
                            dxDrawRectangle(drawX-sx*0.05, drawY, sx*0.1, sy*0.01, tocolor(35, 35, 35, 255))
                            dxDrawRectangle(drawX-sx*0.05+sx*0.001, drawY+sy*0.002, sx*0.1-sx*0.002, sy*0.01-sy*0.004, tocolor(40, 40, 40, 255))
                            dxDrawRectangle(drawX-sx*0.05+sx*0.001, drawY+sy*0.002, (sx*0.1-sx*0.002)*getElementHealth(k)/100, sy*0.01-sy*0.004, tocolor(r, g, b, 255))
                        end
                    end
                end
            end
        end

        for k, v in pairs(createdFires) do 
            if isElement(k) then
                if core:getDistance(k, localPlayer) < 10 then 
                    local x, y, z = getElementPosition(k)
                    z = z + 1 
                    drawX, drawY = getScreenFromWorldPosition(x, y, z)

                    if drawX and drawY then
                        dxDrawRectangle(drawX-sx*0.05, drawY, sx*0.1, sy*0.01, tocolor(35, 35, 35, 255))
                        dxDrawRectangle(drawX-sx*0.05+sx*0.001, drawY+sy*0.002, sx*0.1-sx*0.002, sy*0.01-sy*0.004, tocolor(40, 40, 40, 255))
                        dxDrawRectangle(drawX-sx*0.05+sx*0.001, drawY+sy*0.002, (sx*0.1-sx*0.002)*getElementData(k, "fire:hp")/100, sy*0.01-sy*0.004, tocolor(r, g, b, 255))
                    end
                end
            end
        end
    end
end)

-- fire hidrant
local pipeLines = {}
local posTimer = nil 
local playersLastPos = {}
local pipeLenght = 0
local pipeColor, pipeWidth = {245, 194, 66}, 7

function connectHose(hidrant)
    if not pipeLines[localPlayer] then 
        pipeLines[localPlayer] = {}
    end

    pipeLines[localPlayer] = {connected = false}

    table.insert(pipeLines[localPlayer], 1, {getElementPosition(hidrant)})
    playersLastPos = {}
    posTimer = setTimer(syncWaterPipes, 80, 0)

    setElementData(localPlayer, "hoseInHand", true)
end

function unConnectHose(hidrant)
    if isTimer(posTimer) then killTimer(posTimer) end 
    playersLastPos = {}
    pipeLines[localPlayer] = false
    setElementData(localPlayer, "hoseInHand", false)
end

function connectHoseToVeh(veh)
    if isTimer(posTimer) then killTimer(posTimer) end 
    playersLastPos = {}
    pipeLines[localPlayer].connected = true
    setElementData(veh, "veh:ConnectedToFireHidrant", true)
    setElementData(localPlayer, "hoseInHand", false)
end

function unConnectHoseFromVeh(veh)
    playersLastPos = {}
    posTimer = setTimer(syncWaterPipes, 80, 0)
    pipeLines[localPlayer].connected = false
    setElementData(veh, "veh:ConnectedToFireHidrant", false)
    setElementData(localPlayer, "hoseInHand", true)
end

local rendercount = 0
function renderWaterPipes()
    rendercount = 0
    for k, v in pairs(pipeLines) do 
        if v then
            for k2, v2 in ipairs(v) do 
                if v[k2 - 1] then 
                    local x, y, z = getScreenFromWorldPosition(v[k2 - 1][1], v[k2 - 1][2], v[k2 - 1][3])
                    local x2, y2, z2 = getScreenFromWorldPosition(v2[1], v2[2], v2[3])

                    if (x and y and z) or (x2 and y2 and z2) then
                        dxDrawLine3D(v[k2 - 1][1], v[k2 - 1][2], v[k2 - 1][3], v2[1], v2[2], v2[3], tocolor(unpack(pipeColor)), pipeWidth)
                        rendercount = rendercount + 1
                    end
                else
                    dxDrawLine3D(v2[1], v2[2], v2[3], v2[1], v2[2], v2[3], tocolor(unpack(pipeColor)), pipeWidth)
                    rendercount = rendercount + 1
                end
            end

            if not v.connected then
                local boneX, boneY, boneZ = getPedBonePosition(k, 25)

                dxDrawLine3D(v[#v][1], v[#v][2], v[#v][3], boneX, boneY, boneZ, tocolor(unpack(pipeColor)), pipeWidth)
            end
        end
    end
    dxDrawText(rendercount, 0, 0, 0, 0)
end
--addEventHandler("onClientPreRender", root, renderWaterPipes)

function syncWaterPipes()
    local v = localPlayer

    local playerX, playerY, playerZ = core:getPositionFromElementOffset(v, 0.5, -0.25, 1)
    playerZ = getGroundPosition(playerX, playerY, playerZ)
    playerZ = playerZ + 0.04

    if not playersLastPos[v] then 
        playersLastPos[v] = {math.floor(playerX*10), math.floor(playerY*10), math.floor(playerZ*10)}
        table.insert(pipeLines[v], {playerX, playerY, playerZ})
    else
        if not (playersLastPos[v][1] == math.floor(playerX*10) and playersLastPos[v][2] == math.floor(playerY*10) and playersLastPos[v][3] == math.floor(playerZ*10)) then
            playersLastPos[v] = {math.floor(playerX*10), math.floor(playerY*10), math.floor(playerZ*10)}
            table.insert(pipeLines[v], {playerX, playerY, playerZ})
        end
    end
end