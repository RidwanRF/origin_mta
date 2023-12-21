local OilDepoMarker = createMarker(1810.9615478516, -2060.8774414062, 12.576280593872,"cylinder",2,69, 69, 69,200)
local FuelDepoMarker = createMarker(1807.9615478516, -2060.8774414062, 12.576280593872,"cylinder",2,160, 45, 45,100)

for k, v in ipairs(getElementsByType("vehicle")) do 
    setElementData(v, "vehicle:mechanicLiftLevel", 0)
end

addEvent("factionScripts > mechanic > installVehComponent", true)
addEventHandler("factionScripts > mechanic > installVehComponent", resourceRoot, function(veh, componentIndex)
    if vehicleMechanicComponents[componentIndex].panelID then 
        setVehiclePanelState(veh, vehicleMechanicComponents[componentIndex].panelID, 0)
    elseif vehicleMechanicComponents[componentIndex].doorID then 
        setVehicleDoorState(veh, vehicleMechanicComponents[componentIndex].doorID, 1)
    elseif vehicleMechanicComponents[componentIndex].wheelID then 
        local wheels = {getVehicleWheelStates(veh)}
        wheels[vehicleMechanicComponents[componentIndex].wheelID] = 0
        setVehicleWheelStates(veh, unpack(wheels))
    end

    setElementData(client, "char:money", getElementData(client, "char:money")-vehicleMechanicComponents[componentIndex].price)
end)

addEvent("factionScripts > mechanic > dismountVehComponent", true)
addEventHandler("factionScripts > mechanic > dismountVehComponent", resourceRoot, function(veh, componentIndex)
    if vehicleMechanicComponents[componentIndex].panelID then 
        setVehiclePanelState(veh, vehicleMechanicComponents[componentIndex].panelID, 3)
    elseif vehicleMechanicComponents[componentIndex].doorID then 
        setVehicleDoorState(veh, vehicleMechanicComponents[componentIndex].doorID, 4)

        outputChatBox(getVehicleDoorState(veh, vehicleMechanicComponents[componentIndex].doorID).." "..vehicleMechanicComponents[componentIndex].doorID)
    end
end)

addEvent("factionScripts > mechanic > setAnimation", true)
addEventHandler("factionScripts > mechanic > setAnimation", resourceRoot, function(animGroup, animName, frozen)
    local player = client
    setElementFrozen(client, frozen)
    setElementData(client, "inMechanicWork", frozen)
    setPedAnimation(client, animGroup, animName, -1, true, false)
end)

addEvent("factionScripts > mechanic > freezeVehicle", true)
addEventHandler("factionScripts > mechanic > freezeVehicle", resourceRoot, function(veh, frozen)
    setElementFrozen(veh, frozen)
    setElementData(veh, "vehInService", frozen)

    setTimer(function()
        setElementData(veh,"vehInService",false)
    end,15000,1)
end)

addEvent("factionScripts > mechanic > fixVehEngine", true)
addEventHandler("factionScripts > mechanic > fixVehEngine", resourceRoot, function(veh)
    setElementHealth(veh, 1000)
end)

addEvent("factionScripts > mechanic > fixVehicle", true)
addEventHandler("factionScripts > mechanic > fixVehicle", resourceRoot, function(veh)
    fixVehicle(veh)
end)

addEvent("factionScripts > mechanic > fixVehicleBUG", true)
addEventHandler("factionScripts > mechanic > fixVehicleBUG", resourceRoot, function(veh)
    fixVehicle(veh)
    for k, v in pairs(getElementsByType("player")) do
        if getElementData(v, "user:admin") > 1 then
            outputChatBox("#276ce3[Adminisztrátor - LOG]: #db3535"..getPlayerName(client).."#557ec9 használta a #db3535/fixvehbug #557ec9parancsot. ("..getElementModel(veh)..")", v, 255, 255, 255, true)
        end
    end
end)

addEvent("factionScripts > mechanic > lampfixVehicle", true)
addEventHandler("factionScripts > mechanic > lampfixVehicle", resourceRoot, function(veh)
    setVehicleLightState(veh, 0, 0)
    setVehicleLightState(veh, 1, 0)
    setVehicleLightState(veh, 2, 0)
    setVehicleLightState(veh, 3, 0)
end)

function registerEvent(name, _function)
    addEvent(name, true)
    addEventHandler(name, resourceRoot, _function)
end

function createCarLifts()
    for k, v in ipairs(carlifts) do 
        local lift = createObject(1548, v[1], v[2], v[3], 0, 0, v[4])
        local controlCol = createColTube(v[1], v[2], v[3]-1, 1, 3)
        local liftCol = createColSphere(v[1], v[2], v[3], 3)

        local liftDownCol = createColTube(v[1], v[2], v[3], 3, 2)
        attachElements(liftCol, lift, -1.75, 0, 0)
        attachElements(liftDownCol, lift, -1.75, 0, -2.2)

        setElementData(controlCol, "mechanic:vehicleLift", lift)
        setElementData(controlCol, "mechanic:vehicleLiftCol", liftCol)
        setElementData(controlCol, "mechanic:vehicleLiftDownCol", liftDownCol)
        setElementData(controlCol, "mechanic:vehicleLiftLevel", 0)
        setElementData(controlCol, "mechanic:liftInMove", false)

        

    end
end
createCarLifts()

function createDollys()
    for k, v in ipairs(mechanicDollys) do 
        local dolly = createObject(10955, v[1], v[2], v[3], 0, 0, v[4])

        setElementData(dolly, "isMechanicDolly", true)

        setElementData(dolly, "dollyInUse", false)
        setElementData(dolly, "dollyObject", nil)
        setElementData(dolly, "dollyInProgress", false)
        setElementData(dolly, "dollyInMove", false)
        setElementData(dolly, "dollyAttachedPlayer", false)
    end

    for k, v in ipairs(fuelDrums) do 
        local fueldrum = createObject(3632, v[1], v[2], v[3], 0, 0, v[4])

        setElementData(fueldrum, "isFuelDrum", true)
        setElementData(fueldrum, "Fueldrum:liquid", 0)
        setElementData(fueldrum, "Fueldrum:color", "#00aaff")
        setElementData(fueldrum, "Fueldrum:icon", "asd")
        setElementData(fueldrum, "Fueldrum:inUse", false)
        setElementData(fueldrum, "Fueldrum:defaultPos", {v[1], v[2], v[3]})

        setElementData(fueldrum, "drum:fuelLevel",0)
        setElementData(fueldrum, "drum:fuelMaxLevel",100)
    end

    for k, v in ipairs(oilDrums) do 
        local oildrum = createObject(935, v[1], v[2], v[3], 0, 0, v[4])
        
        setElementData(oildrum, "isOilDrum", true)
        setElementData(oildrum, "drum:liquid", 0)
        setElementData(oildrum, "drum:color", "#00aaff")
        setElementData(oildrum, "drum:icon", "asd")
        setElementData(oildrum, "drum:inUse", false)
        setElementData(oildrum, "drum:defaultPos", {v[1], v[2], v[3]})

        setElementData(oildrum, "drum:oilLevel",0)
        setElementData(oildrum, "drum:oilMaxLevel",100)
    end 
end
createDollys()

local liftMoveTime = 9900
local oilCol = {}
local fuelCol = {}
local oilRefuelCol = {}

addEventHandler("onElementDataChange", root, function(key,oldValue,newValue)
    if key == "oilRefuelCol" and newValue == false then 
        col = getElementData(source,"veh>oilRefuelCol")
        destroyElement(col)
    end 
end)

registerEvent("factionScripts > mechanic > lift > move", function(lift, dir, levelAdd)
    local obj = getElementData(lift, "mechanic:vehicleLift")
    local col = getElementData(lift, "mechanic:vehicleLiftCol")

    local veh = getElementsWithinColShape(col, "vehicle")[1]

    if isElement(veh) then
        attachElements(veh, obj, -1.85, 0, 0.65)

        local x, y, z = getElementPosition(obj)
        local vx,vy,vz = getElementPosition(veh)
        local rx,ry,rz = getElementRotation(veh)

        moveObject(obj, liftMoveTime, x, y, z+dir)

        setElementData(lift, "mechanic:liftInMove", true)

        setTimer(function()
            setElementData(lift, "mechanic:liftInMove", false)
            setElementData(lift, "mechanic:vehicleLiftLevel", getElementData(lift, "mechanic:vehicleLiftLevel")+levelAdd)

            local newLevel = getElementData(lift, "mechanic:vehicleLiftLevel")

            if newLevel == 2 and not oilCol[veh] and not fuelCol[veh] then 
                fuelCol[veh] = createColSphere(vx,vy - 1.7,vz - 1,1.5)
                setElementData(fuelCol[veh],"isFuelCol",true)

                oilCol[veh] = createColSphere(vx,vy + 1.6,vz - 1,1.5)
                setElementData(oilCol[veh],"isOilCol",true)
                setElementData(veh,"targetVehicle",true)

                    for k,v in pairs(getElementsByType("player")) do 
                   --[[ triggerClientEvent(v,"createEffectClient",v,veh,"petrolcan","create",vx,vy + 1.5,vz + 0.5,rx + 180,ry,rz,10,true) --oil
                    triggerClientEvent(v,"createEffectClient",v,veh,"petrolcan","create",vx,vy - 1.7,vz + 0.5,rx + 180,ry,rz,10,true) --fuel]]

                    end 
            end 

            if newLevel == 1 or newLevel == 0 then 
                if fuelCol[veh] and oilCol[veh] then 
                    setElementData(oilCol[veh],"isOilCol",false)    
                    setElementData(fuelCol[veh],"isFuelCol",false)
                    destroyElement(fuelCol[veh])
                    destroyElement(oilCol[veh])
                    fuelCol[veh] = nil 
                    oilCol[veh] = nil
                    
                    for k,v in pairs(getElementsByType("player")) do 
                        --[[triggerClientEvent(v,"createEffectClient",v,veh,"petrolcan","delete")
                        triggerClientEvent(v,"createEffectClient",v,veh,"petrolcan","delete")]]
                    end 

                end 
            end 

            if newLevel == 1 or newLevel == 2 then 
                if oilRefuelCol[veh] then return destroyElement(oilRefuelCol[veh]) end
            end

            if newLevel == 0 then 
                if not oilRefuelCol[veh] then 
                    oilRefuelCol[veh] = createColSphere(vx,vy + 2.5,vz - 0.5,1)
                    setElementData(veh,"oilRefuelCol",true)
                    setElementData(veh,"veh>oilRefuelCol",oilRefuelCol[veh])
                    setElementData(veh,"targetVehicle",true)
                    setElementData(oilRefuelCol[veh],"col:oilVeh",veh)
                end 
            end 

            if newLevel == 0 then
                detachElements(veh, obj)
            end

            setElementData(veh, "vehicle:mechanicLiftLevel", newLevel)
        end, liftMoveTime, 1)

        triggerClientEvent(root, "factionScripts > mechanic > playVehLiftSound", root, obj)
    end
end)    
function pickUpDolly(player, dolly)
    setElementData(player, "dollyInMove", true)
    setElementData(dolly, "dollyAttachedPlayer", player)
    setElementData(player, "dollyUsedByPlayer", dolly)

    attachElements(dolly, player, 0, 1.15, -0.835, 0, 0, 180)
    toggleControl(player,"sprint",false)
    bindKey(player,"backspace","down",takedownDolly,player)
end
registerEvent("factionScripts > mechanic > pickUpDolly",pickUpDolly)

function takedownDolly(player)

    dolly = getElementData(player,"dollyUsedByPlayer")

    setElementData(player, "dollyInMove", false)
    removeElementData(dolly, "dollyAttachedPlayer")
    toggleControl(player,"sprint",true)
    detachElements(dolly, player)
    unbindKey( player,"backspace","down",takedownDolly)
    removeElementData(player, "dollyUsedByPlayer")

end 
registerEvent("factionScripts > mechanic > takedownDolly",takedownDolly)

--[[registerEvent("factionScripts > mechanic > takedownDolly", function(player,dolly)
    setElementData(dolly, "dollyInMove", false)
    removeElementData(dolly, "dollyAttachedPlayer")
    removeElementData(player, "dollyUsedByPlayer")

    detachElements(dolly, player)
end)]]

--oilbarell
registerEvent("factionScripts > mechanic > pickUpDrum", function(player, drum)
    if getElementData(player,"dollyUsedByPlayer") then 
        local dolly = getElementData(player, "dollyUsedByPlayer")
        setElementData(drum, "drum:inUse", true)
        setElementData(dolly, "dolly:drum", drum)
        setElementData(dolly, "dolly:oilDrumUse",true)
        setElementData(dolly, "dolly:useDrum",true)
        attachElements(drum, dolly, 0, -0.3, 0.6, 0, 0, 180)
    end 
end)

registerEvent("factionScripts > mechanic > takeDownDrum", function(player, drum)
    if getElementData(player,"dollyUsedByPlayer") then 
        local dolly = getElementData(player, "dollyUsedByPlayer")
        setElementData(dolly, "dolly:useDrum",false)
        setElementData(drum, "drum:inUse", false)
        removeElementData(dolly, "dolly:drum")
        removeElementData(dolly, "dolly:oilDrumUse")
        local x,y,z = getElementPosition(drum)
        detachElements(drum, dolly)
        setElementPosition(drum,x,y,z - 0.15)
    end 
end)
--
--fuelbarell 
registerEvent("factionScripts > mechanic > pickUpFuelDrum", function(player, Fueldrum)
    if getElementData(player,"dollyUsedByPlayer") then 
        local dolly = getElementData(player, "dollyUsedByPlayer")
        setElementData(Fueldrum, "Fueldrum:inUse", true)
        setElementData(dolly, "dolly:drum", Fueldrum)
        setElementData(dolly, "dolly:useDrum",true)
        setElementData(dolly, "dolly:fuelDrumUse",true)
        attachElements(Fueldrum, dolly, 0, -0.3, 0.6, 0, 0, 180)
    end 
end)

registerEvent("factionScripts > mechanic > takeDownFuelDrum", function(player, Fueldrum)
    if getElementData(player,"dollyUsedByPlayer") then 
        local dolly = getElementData(player, "dollyUsedByPlayer")
        setElementData(dolly, "dolly:useDrum",false)
        setElementData(Fueldrum, "Fueldrum:inUse", false)
        removeElementData(dolly, "dolly:drum")
        removeElementData(dolly, "dolly:fuelDrumUse")
        local x,y,z = getElementPosition(Fueldrum)
        detachElements(Fueldrum, dolly)
        setElementPosition(Fueldrum,x,y,z - 0.15)
    end 
end)
--
-- garage door

local garageDoor = createObject(16259, 1684.0254638672, -2024.6866699219, 13.01433467865, 0, 0, 0)
local button = createObject(2886, 1684.0252441406, -2020.9519042969, 14.470001602173, 0, 0, -90)
local openerCol = createColTube(1683.6252441406, -2020.9519042969, 13.070001602173, 0.5, 2)
setElementData(openerCol, "factionScripts:mechanic:doorOpener", true)
setElementData(openerCol, "factionScripts:mechanic:doorOpener:inUse", false)

local openerTimer = false

local moveTime = 0.05

registerEvent("factionScripts > mechanic > openDoor", function(direction)
    setElementData(openerCol, "factionScripts:mechanic:doorOpener:inUse", true)

    if direction == "open" then 
        local garageX, garageY, garageZ = getElementPosition(garageDoor)
        local distance = getDistanceBetweenPoints3D(garageX, garageY, garageZ, 1684.0254638672, -2024.6866699219, 15.5)

        if (garageZ <= 15.35) then
            moveObject(garageDoor, 6000 * distance * moveTime, 1684.0254638672, -2024.6866699219, 15.5, 0, 0, 0, "Linear")
        end

        if (garageZ >= 15.35) then 
            local garageX, garageY, garageZ = getElementPosition(garageDoor)
            local rotX, rotY, rotZ = getElementRotation(garageDoor)
            local distance2 = getDistanceBetweenPoints3D(garageX, garageY, garageZ, 1682.9180419922, -2024.6866699219, 17.5625)

            local neededRot = 0 - (rotY - 270)

            moveObject(garageDoor, 10000 * distance2 * moveTime, 1682.9180419922, -2024.6866699219, 17.5625, 0, neededRot, 0, "Linear")
        else
            openerTimer = setTimer(function()
                moveObject(garageDoor, 15000, 1682.9180419922, -2024.6866699219, 17.5625, 0, -90, 0, "Linear")
            end, 6000 * distance * moveTime, 1)
        end 
    elseif direction == "close" then 
        local garageX, garageY, garageZ = getElementPosition(garageDoor)
        local distance = getDistanceBetweenPoints3D(garageX, garageY, garageZ, 1684.0254638672, -2024.6866699219, 15.5)

        --if (garageZ <= 15.35) then
           -- moveObject(garageDoor, 6000 * distance * moveTime, 1684.0254638672, -2024.6866699219, 13.01433467865, 0, 0, 0, "Linear")
        --end

        --[[if (garageZ >= 15.35) then 
            local garageX, garageY, garageZ = getElementPosition(garageDoor)
            local rotX, rotY, rotZ = getElementRotation(garageDoor)
            local distance2 = getDistanceBetweenPoints3D(garageX, garageY, garageZ, 1682.9180419922, -2024.6866699219, 17.5625)

            local neededRot = 0 - (rotY - 270)

            moveObject(garageDoor, 10000 * distance2 * moveTime, 1682.9180419922, -2024.6866699219, 17.5625, 0, neededRot, 0, "Linear")
        else
            openerTimer = setTimer(function()
                moveObject(garageDoor, 15000, 1682.9180419922, -2024.6866699219, 17.5625, 0, -90, 0, "Linear")
            end, 6000 * distance * moveTime, 1)
        end ]]
    end
end)

registerEvent("factionScripts > mechanic > stopMoving", function(direction)
    setElementData(openerCol, "factionScripts:mechanic:doorOpener:inUse", false)

    stopObject(garageDoor)

    if isTimer(openerTimer) then 
        killTimer(openerTimer)
        openerTimer = false
    end
end)

--colfunctions 

--oil position 1757.2615966797, -2043.3973388672, 13.944440841675
--Rotáció: -0, 0, 1.1231129169464

--fuel pos 1757.2978515625, -2046.4533691406, 13.936628341675
-- rot -0, 0, 0.20652191340923

function getDownMature(source)
    type = getElementData(source,"col:type")

    if type == "oil" then 
        for k,v in pairs(getElementsByType("vehicle")) do 
            if getElementData(v,"targetVehicle") then 
                if getElementData(source,"dollyUsedByPlayer") then 
                    dolly = getElementData(source,"dollyUsedByPlayer")
                    if getElementData(dolly,"dolly:oilDrumUse") then 
                        if tonumber(getElementData(v,"veh:distanceToOilChange")) > 0 then 
                            drum = getElementData(dolly,"dolly:drum")
                                if getElementData(drum,"drum:oilLevel") < 100 then
                                    chat:sendLocalMeAction(source,"elkezdi kicsavarni az olajleeresztő csavarját.")
                                    chat:sendLocalDoAction(source,"a csavar kicsavarva, az olaj szépen lassan folyik a hordóba.")
                                    setElementFrozen(source,true)
                                    toggleControl(source,"forwards",false)
                                    toggleControl(source,"backwards",false)
                                    toggleControl(source,"left",false)
                                    toggleControl(source,"right",false)
                                    local player = source
                                    local dx,dy,dz = getElementPosition(dolly)
                                    local rx,ry,rz = getElementRotation(dolly)
                                    triggerClientEvent(source,"createEffectClient",source,source,"petrolcan","create",dx,dy + 0.5,dz + 2,rx + 180,ry,rz,10,true,"oil") 
                                    takedownDolly(source)
                                    setTimer(function()
                                        setElementData(drum,"drum:oilLevel",getElementData(drum,"drum:oilLevel") + 1)
                                    end,3000,10)
                                    setTimer(function()
                                        chat:sendLocalDoAction(player,"a leereszteni kívánt olaj a hordóba csurgott.")
                                        chat:sendLocalMeAction(player,"elkezdi óvatosan visszacsavarni az olajleeresztő csavart.")
                                        triggerClientEvent(player,"createEffectClient",player,player,"petrolcan","delete")

                                            setTimer(function()
                                                chat:sendLocalDoAction(player,"az olajleeresztő csavar a helyén, az olajcsere kész.")
                                                outputChatBox(color.."[Olaj]#ffffff A hordóban lévő mennyiséget arra kattintva láthatod, leadni a konténerek mögötti szürke markerben tudod.",source,255,255,255,true)
                                                outputChatBox(color.."[Olaj]#ffffff FIGYELEM!! Az autóban jelenleg nincs olaj így ha most beleűl valaki lerobban!",source,255,255,255,true)
                                                outputChatBox(color.."[Olaj]#ffffff Az olajszintet feltölteni az autót leengedve, a motortér elé álva tudod!",source,255,255,255,true)
                                                setElementFrozen(player,false)
                                                toggleControl(player,"forwards",true)
                                                toggleControl(player,"backwards",true)
                                                toggleControl(player,"left",true)
                                                toggleControl(player,"right",true)
                                                pickUpDolly(player,dolly)
                                                setElementData(v,"veh:distanceToOilChange",0)
                                            end,8000,1)
                                    end,30000,1)
                                else 
                                    outputChatBox(color.."[Olaj]#ffffff Tele van a hordó, először ürítsd ki!",source,255,255,255,true)
                                end
                        else 
                            outputChatBox(color.."[Olaj]#ffffff Ebben az autóban nincs olaj!",source,255,255,255,true)
                        end 
                    end
                end 
            end 
        end 
    elseif type == "fuel" then 
        for k,v in pairs(getElementsByType("vehicle")) do 
            if getElementData(v,"targetVehicle") then 
                if getElementData(source,"dollyUsedByPlayer") then 
                    dolly = getElementData(source,"dollyUsedByPlayer")
                    if getElementData(dolly,"dolly:fuelDrumUse") then 
                        if tonumber(getElementData(v,"veh:fuel")) > 0 then 
                                drum = getElementData(dolly,"dolly:drum")
                                if getElementData(drum,"drum:fuelLevel") < 100 then
                                    chat:sendLocalMeAction(source,"elkezdi kicsavarni az üzemanyagtartály alján lévő biztonsági leeresztő csavart.")
                                    chat:sendLocalDoAction(source,"a csavar kicsavarva, az üzemanyag szépen lassan folyik a hordóba.")
                                    setElementFrozen(source,true)
                                    toggleControl(source,"forwards",false)
                                    toggleControl(source,"backwards",false)
                                    toggleControl(source,"left",false)
                                    toggleControl(source,"right",false)
                                    local player = source
                                    local dx,dy,dz = getElementPosition(dolly)
                                    local rx,ry,rz = getElementRotation(dolly)
                                    triggerClientEvent(source,"createEffectClient",source,source,"petrolcan","create",dx,dy + 0.5,dz + 2,rx + 180,ry,rz,10,true,"fuel") 
                                    takedownDolly(source)
                                    setTimer(function()
                                        setElementData(drum,"drum:fuelLevel",getElementData(drum,"drum:fuelLevel") + 1)
                                    end,2000,10)
                                    setTimer(function()
                                        chat:sendLocalDoAction(player,"a leereszteni kívánt üzemanyag a hordóba csurgott.")
                                        chat:sendLocalMeAction(player,"elkezdi óvatosan visszacsavarni az üzemanyagleeresztő csavart.")
                                        triggerClientEvent(player,"createEffectClient",player,player,"petrolcan","delete")
                                    
                                            setTimer(function()
                                                chat:sendLocalDoAction(player,"az üzemanyagleeresztő csavar a helyén, az üzemanyag leeresztése kész.")
                                                outputChatBox(color.."[Üzemanyag]#ffffff A hordóban lévő mennyiséget arra kattintva láthatod, leadni a konténerek mögötti piros markerben tudod.",source,255,255,255,true)
                                                outputChatBox(color.."[Üzemanyag]#ffffff FIGYELEM!! Az autóban jelenleg nincs üzemanyag így beindítani sem tudod!",source,255,255,255,true)
                                                setElementFrozen(player,false)
                                                toggleControl(player,"forwards",true)
                                                toggleControl(player,"backwards",true)
                                                toggleControl(player,"left",true)
                                                toggleControl(player,"right",true)
                                                pickUpDolly(player,dolly)
                                                setElementData(v,"veh:fuel",0)
                                            end,8000,1)
                                    end,20000,1)
                                else 
                                    outputChatBox(color.."[Üzemanyag]#ffffff Tele van a hordó, először ürítsd ki!",source,255,255,255,true)
                                end
                        else 
                            outputChatBox(color.."[Üzemanyag]#ffffff Ebben az autóban nincs üzemanyag!",source,255,255,255,true)
                        end
                    end 
                end 
            end 
        end 
    elseif type == "electric" then 
        outputChatBox(color.."[Dolly]#ffffff Elektromos autóban nincs se üzemanyag se olaj!",source,255,255,255,true)
    elseif not type then 
        outputDebugString("[MECHANIC ERROR:] getDownMature type error (nincs vagy hibás type lekérdezés)",3,255,0,0)
    end 
end 
addCommandHandler("leereszt",getDownMature)

function oilRefuelHit( colShapeHit )
    if getElementData(source, "char:duty:faction") == getMechanicFactionID() then 
        for k,v in pairs(getElementsByType("vehicle")) do 
            if getElementData(v,"targetVehicle") then 
                if colShapeHit == oilRefuelCol[v] then 
                    if getElementData(v,"veh:distanceToOilChange") == 0 then

                        outputChatBox(color.."[Olaj]#ffffff A gépjármű olajszintjének feltöltéséhez hasznlád az inventoridban található olaj itemet!",source,255,255,255,true)
                        setElementData(source,"inRefuelCol",true)
                        setElementData(source,"player:oilCol",colShapeHit)

                    end 
                end
            end 
        end 
    end 
end 

function oilColHit( colShapeHit )
    if getElementData(source, "char:duty:faction") == getMechanicFactionID() then 
        for k,v in pairs(getElementsByType("vehicle")) do 
            if getElementData(v,"targetVehicle") then 
                if colShapeHit == oilCol[v] then 
                    if getElementModel(v) == 546 or getElementModel(v) == 496 then 
                        setElementData(source,"col:type","electric")
                    else 
                        setElementData(source,"col:type","oil")
                    end 
                end
            end 
        end 
    end 
end

function fuelColHit( colShapeHit )
    if getElementData(source, "char:duty:faction") == getMechanicFactionID() then 
        for k,v in pairs(getElementsByType("vehicle")) do 
            if getElementData(v,"targetVehicle") then 
                if colShapeHit == fuelCol[v] then 
                    if getElementModel(v) == 546 or getElementModel(v) == 496 then 
                        setElementData(source,"col:type","electric")
                    else 
                        setElementData(source,"col:type","fuel")
                    end 
                end
            end 
        end 
    end 
end

function OilDepo(Marker)
    if getElementData(source,"char:duty:faction") == getMechanicFactionID() then 
        if getElementData(source,"dollyUsedByPlayer") then 
            dolly = getElementData(source,"dollyUsedByPlayer")
            if getElementData(dolly,"dolly:oilDrumUse") then 
                drum = getElementData(dolly,"dolly:drum")
                level = getElementData(drum,"drum:oilLevel")
                if Marker == OilDepoMarker then 
                    if level > 0 then 
                        setElementFrozen(source,true)
                        chat:sendLocalMeAction(source,"elkezdi kiüríteni az olajos hordót.")
                        chat:sendLocalDoAction(source,"a hordóban "..level.." liter olaj van.")
                        local player = source 

                        returner = level 
                        timer = 10000/returner - 50

                        setTimer(function()
                            setElementData(drum,"drum:oilLevel",getElementData(drum,"drum:oilLevel") - 1)
                        end,timer,returner)

                        setTimer(function ()
                            setElementFrozen(player,false)
                            chat:sendLocalDoAction(player,"a hordó üres.")

                            money = level * 200
                            outputChatBox(color.."[Olaj Akna]#ffffff Sikeresen kiürítetted az olajos hordót a frakciód ezért "..money.."$-t kapott.",player,255,255,255,true)
                            exports["oDashboard"]:setFactionBankMoney(getMechanicFactionID(),money,"add")
                        end,10000,1)
                    else 
                        outputChatBox(color.."[Olaj Akna]#ffffff A hordó üres így nem tudsz mit kiüríteni.",source,255,255,255,true)
                    end 
                end
            end 
        end 
    end 
end 

function FuelDepo(Marker)
    if getElementData(source,"char:duty:faction") == getMechanicFactionID() then 
        if getElementData(source,"dollyUsedByPlayer") then 
            dolly = getElementData(source,"dollyUsedByPlayer")
            if getElementData(dolly,"dolly:fuelDrumUse") then 
                drum = getElementData(dolly,"dolly:drum")
                level = getElementData(drum,"drum:fuelLevel")
                if Marker == FuelDepoMarker then 
                    if level > 0 then 
                        setElementFrozen(source,true)
                        chat:sendLocalMeAction(source,"elkezdi kiüríteni az üzemanyagos hordót.")
                        chat:sendLocalDoAction(source,"a hordóban "..level.." liter üzemanyag van.")
                        local player = source 

                        returner = level 
                        timer = 10000/returner - 50

                        setTimer(function()
                            setElementData(drum,"drum:fuelLevel",getElementData(drum,"drum:fuelLevel") - 1)
                        end,timer,returner)

                        setTimer(function ()
                            setElementFrozen(player,false)
                            chat:sendLocalDoAction(player,"a hordó üres.")

                            money = level * 200
                            outputChatBox(color.."[Olaj Akna]#ffffff Sikeresen kiürítetted az üzemanyagos hordót a frakciód ezért "..money.."$-t kapott.",player,255,255,255,true)
                            exports["oDashboard"]:setFactionBankMoney(getMechanicFactionID(),money,"add")
                        end,10000,1)
                    else 
                        outputChatBox(color.."[Üzemanyag Akna]#ffffff A hordó üres így nem tudsz mit kiüríteni.",source,255,255,255,true)
                    end 
                end
            end 
        end 
    end 
end 

addEventHandler("onElementColShapeLeave",getRootElement(),function(shape,md)
    if getElementData(source, "char:duty:faction") == getMechanicFactionID() then 
        for k,v in pairs(getElementsByType("vehicle")) do 
            if getElementData(v,"targetVehicle") then 
                if colShapeHit == oilRefuelCol[v] then 
                    setElementData(source,"inRefuelCol",false)
                end
            end 
        end 
    end 
end)

addEventHandler( "onElementColShapeHit", getRootElement(), oilColHit ) 
addEventHandler( "onElementColShapeHit", getRootElement(), fuelColHit ) 
addEventHandler( "onElementColShapeHit", getRootElement(), oilRefuelHit ) 

addEventHandler( "onPlayerMarkerHit", getRootElement(), OilDepo ) 
addEventHandler( "onPlayerMarkerHit", getRootElement(), FuelDepo ) 
