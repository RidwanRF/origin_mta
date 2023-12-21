connection = exports.oMysql:getDBConnection()
business = {}

function sendMessageToAdmins(player, msg)
    triggerClientEvent("sendMessageToAdmins", getRootElement(), player, msg, 8)
end

addEventHandler("onResourceStart", resourceRoot, function()
    local loadCount = 0
    dbQuery(function(qh)
        local res, rows, err = dbPoll(qh, 0)
        if rows > 0 then
            for k, row in pairs(res) do
                loadDevs(row["id"])
                loadCount = loadCount+1
            end
        end
    end,connection,"SELECT * FROM gamedev_businesses")

    for k,v in pairs(getElementsByType("player")) do
        setElementData(v, "inOffice", false)
    end
end)

-- Biztonsági kihelyezés
addEventHandler( "onResourceStop", getRootElement( ),function(res)
    if res == getThisResource() then
        for k,v in pairs(getElementsByType("player")) do
            if getElementData(v,"inOffice") then
                setElementPosition(v, 1417.4208984375, -1177.7359619141, 25.9921875)
                setElementDimension(v, 0)
                outputChatBox(core:getServerPrefix("green-dark", "Játékfejlesztő", 3).."A rendszer leállt, vagy újraindul, ezért biztonsági okokból az irodaház elé kerültél!", v, 255, 255, 255, true)
            end
        end
    end
end)

-- Számla ellenőrzés
addEventHandler("onElementDataChange", root, function(data, old, new)
    if data == "user:loggedin" then  
        if new == true then    
            for k, v in pairs(getElementsByType("marker")) do
                if getElementData(v,"or:mainmarker") then
                    if getElementData(v,"or:markerowner") == getElementData(source,"user:id") then
                        ownmarkers = v
                    end
                end
            end
            if getElementData(ownmarkers,"or:hotterbill") > 0 then
                setElementData(source,"char:money",getElementData(source,"char:money")-getElementData(ownmarkers,"or:hotterbill"))
                outputChatBox(core:getServerPrefix("green-dark", "Játékfejlesztő", 3).."Ameddig nem voltál fent, a játékcégedben a fűtés tevékenykedett! Ennek az ára: "..getElementData(ownmarkers,"or:hotterbill").."$", source, 255, 255, 255, true)
            end
        end
    end
end)

-- Betöltés
function loadDevs(id)
    dbQuery(function(qh)
        local res, rows, err = dbPoll(qh, 0)
        if rows > 0 then
            for k, row in pairs(res) do

                local x,y,z,rx,ry,rz = unpack(fromJSON(row["colPos"]))
                local owner =  tonumber(row["accid"])

                devsobj = createObject(8551,1377.7629394531, -1210.7016601562, 82.623146057129,0,0,0)
                setElementDimension(devsobj, row["accid"]) 

                laptopCol = createColSphere(1385.2562255859,-1222.0832519531,80.638771057129, 1)
                setElementDimension(laptopCol, row["accid"]) 
                setElementData(laptopCol,"laptopCol",true)

                bossCol = createColCuboid(1381.4478027344, -1222.9486083984, 79.638771057129, 7.6, 4.5, 3)
                setElementDimension(bossCol, row["accid"]) 
                setElementData(bossCol,"bossCol",true)

                devsmarkerout = createMarker(x, y, z-1, "cylinder", 0.7, 187, 96, 214, 0)
                setElementData(devsmarkerout,"or:mainmarker",true)

                devsmarkerin = createMarker(entryPos[1], entryPos[2], entryPos[3]-1, "cylinder", 0.7, 187, 96, 214, 0)
                setElementData(devsmarkerin,"or:officemarker", true)
                setElementDimension(devsmarkerin, row["accid"])
                
                setElementData(devsmarkerout,"markerid",row["id"]) -- biznisz id
                setElementData(devsmarkerout,"other",devsmarkerin)
                setElementData(devsmarkerout,"or:markerowner",row["accid"]) -- tulaj acc id
                setElementData(devsmarkerout,"or:markerownername",row["ownerName"]) -- tulaj neve
                setElementData(devsmarkerout,"or:businessname",row["businessName"]) -- neve
                setElementData(devsmarkerout,"or:businessmoney",row["businessMoney"]) -- pénze a cégnek
                
                setElementData(devsmarkerout,"or:temperature", tonumber(row["temperature"])) -- hőfok
                setElementData(resourceRoot,"or:temperature", tonumber(row["temperature"]))

                setElementData(devsmarkerout,"or:hotter", row["hotter"]) -- fűtés
                setElementData(devsmarkerout,"or:hotterbill", row["hotterBill"]) -- fűtés számla

                --local temperature = getElementData(devsmarkerout,"or:temperature")

               -- if not business[owner] then
                       -- business[owner] = {}
               -- end

                --table.insert(business[owner], temperature)
            end
        end
    end,connection,"SELECT * FROM gamedev_businesses WHERE id=?",id)
end

-- Parancsok
addCommandHandler("creategamedev", function(thePlayer)
    if getElementData(thePlayer,"user:admin") >= 8 then
        local x, y, z = getElementPosition(thePlayer)
        local dim = getElementDimension(thePlayer)
        local int = getElementInterior(thePlayer) 
        dbQuery(function(qh)
            local query, query_lines, id = dbPoll(qh, 150)
            local id = tonumber(id)
            if id > 0 then
                sendMessageToAdmins(thePlayer, "létrehozott egy játékfejlesztő céget. #db3535("..id..")")
                loadDevs(id)
            end
        end,connection,"INSERT INTO gamedev_businesses SET accid=?,ownerName=?,businessName=?,colPos=?,hotter=?,hotterBill=?,satisfaction=?,development=?,temperature=?", 0, "Nincs", "Eladó iroda",toJSON({x,y,z,0,0,0}),0,0,0,0,0)
    end
end)

addCommandHandler("deletegamedev",function(player,cmd,id)
    if getElementData(player,"user:admin") >= 8 then   
        if id then
            if (tostring(type(tonumber(id))) == "number") then
                for k, v in pairs(getElementsByType("marker")) do
                    if getElementData(v,"or:mainmarker") then
                        dbQuery(function(qh)
                            local res, rows, err = dbPoll(qh, 0)
                            if rows > 0 then
                                sendMessageToAdmins(player, "törölt egy játékfejlesztő céget. #db3535("..tonumber(getElementData(v,"markerid"))..")")
                                outputChatBox(exports.oCore:getServerPrefix("green-dark", "Business", 2).."Sikeresen töröltél egy játékfejlesztő céget! ID: #7cc576"..id, player, 255, 255, 255, true)
                                local other = getElementData(v,"other")
                                destroyElement(other)
                                destroyElement(v)
                            end
                        end, connection,"DELETE FROM gamedev_businesses WHERE id = ?",tonumber(id))
                    end
                end
            end
        else
            outputChatBox(exports.oCore:getServerPrefix("green-dark", "Business", 2).."/"..cmd.." [ID]", player, 255, 255, 255, true)
        end
    end
end)

-- Iroda belépés
addEvent("teleport >> office", true)
addEventHandler("teleport >> office", root, function(player)
    if getElementData(devsmarkerout,"or:markerowner") > 0 then    
        setElementPosition(player,entryPos[1],entryPos[2],entryPos[3])
        local gotodim = getElementData(devsmarkerout,"or:markerowner")
        setElementDimension(player,gotodim)

        setElementData(player,"inOffice", true)
    end
end)

-- Iroda kilépés
addEvent("teleport >> world", true)
addEventHandler("teleport >> world", root, function(player)
    local x, y, z = getElementPosition(devsmarkerout)
    setElementPosition(player,x, y, z+1)
    setElementDimension(player,0)

    setElementData(player,"inOffice", false)
end)

-- Iroda vásárlása rendszertől
addEvent("business >> buy >> system", true)
addEventHandler("business >> buy >> system", root, function(player, markerid)
    if getElementData(devsmarkerout,"or:markerowner") == 0 then
        if getElementData(player,"char:money") >= 500000 then
            setElementData(player,"char:money",getElementData(player,"char:money")-500000)
            setElementData(devsmarkerout,"or:markerowner",getElementData(player,"user:id"))
            setElementData(devsmarkerout,"or:markerownername",getPlayerName(player))
            setElementData(devsmarkerout,"or:businessname","Iroda")
            dbExec(connection, "UPDATE `gamedev_businesses` SET `accid`=? WHERE `id`=?", getElementData(player,"user:id"), markerid);
            dbExec(connection, "UPDATE `gamedev_businesses` SET `ownerName`=? WHERE `id`=?", getPlayerName(player), markerid);
            dbExec(connection, "UPDATE `gamedev_businesses` SET `businessName`=? WHERE `id`=?", "Iroda", markerid);
            outputChatBox(exports.oCore:getServerPrefix("green-dark", "Játékfejlesztő", 2).."Sikeresen megvásároltad a céget!", player, 255, 255, 255, true)
        else
            outputChatBox(exports.oCore:getServerPrefix("red-dark", "Játékfejlesztő", 2).."Sajnos nincs elég pénzed! Hiányzik még: "..(500000-getElementData(player,"char:money")).." dollár.", player, 255, 255, 255, true)
        end
    end
end)

-- Iroda eladása rendszernek
addEvent("business >> sell >> system", true)
addEventHandler("business >> sell >> system", root, function(player, markerid)
    if getElementData(devsmarkerout,"or:markerowner") == getElementData(player,"user:id") then
        setElementData(player,"char:money",getElementData(player,"char:money")+100000)
        setElementData(devsmarkerout,"or:markerowner",0)
        setElementData(devsmarkerout,"or:markerownername","Nincs")
        setElementData(devsmarkerout,"or:businessname","Eladó iroda")
        dbExec(connection, "UPDATE `gamedev_businesses` SET `accid`=? WHERE `id`=?", 0, markerid);
        dbExec(connection, "UPDATE `gamedev_businesses` SET `ownerName`=? WHERE `id`=?", "Nincs", markerid);
        dbExec(connection, "UPDATE `gamedev_businesses` SET `businessName`=? WHERE `id`=?", "Eladó iroda", markerid);
        outputChatBox(exports.oCore:getServerPrefix("green-dark", "Játékfejlesztő", 2).."Sikeresen eladtad a céget! A város 100.000 dollárt adott érte!", player, 255, 255, 255, true)
    else
        outputChatBox(exports.oCore:getServerPrefix("red-dark", "Játékfejlesztő", 2).."Ez a cég nem a te tulajdonod!", player, 255, 255, 255, true)
    end
end)

-- Iroda eladása embernek
addCommandHandler("sellgamedev", function(thePlayer, cmd, id, target, price)
    if getElementData(thePlayer,"canSellToSystem") then 
        if id and target and price then 
            if (tostring(type(tonumber(id))) == "number") then
                local target = core:getPlayerFromPartialName(thePlayer, target)
                local price = tonumber(price)
                if price >= 1 then
                    if core:getDistance(thePlayer, target) < 5 then    
                        if getElementData(target,"char:money") >= price then
                            if getElementData(devsmarkerout,"or:markerowner") == getElementData(thePlayer,"user:id") then
                                setElementData(target,"char:money",getElementData(target,"char:money")-price)
                                setElementData(thePlayer,"char:money",getElementData(thePlayer,"char:money")+price)
                                
                                setElementData(devsmarkerout,"or:markerowner",getElementData(target,"user:id"))
                                setElementData(devsmarkerout,"or:markerownername",getPlayerName(target))

                                dbExec(connection, "UPDATE `gamedev_businesses` SET `accid`=? WHERE `id`=?", getElementData(target,"user:id"), getElementData(thePlayer,"canSellMarkerID"));
                                dbExec(connection, "UPDATE `gamedev_businesses` SET `ownerName`=? WHERE `id`=?", getPlayerName(target), getElementData(thePlayer,"canSellMarkerID"));
                            else
                                outputChatBox(exports.oCore:getServerPrefix("red-dark", "Játékfejlesztő", 2).."A cég nem a te tulajdonod!", thePlayer, 255, 255, 255, true)
                            end
                        else
                            outputChatBox(exports.oCore:getServerPrefix("red-dark", "Játékfejlesztő", 2).."A vevőnek nincs elegendő pénze!", thePlayer, 255, 255, 255, true)
                        end
                    else
                        outputChatBox(exports.oCore:getServerPrefix("red-dark", "Játékfejlesztő", 2).."A vevő túl távol van!", thePlayer, 255, 255, 255, true)
                    end
                else
                    outputChatBox(exports.oCore:getServerPrefix("red-dark", "Játékfejlesztő", 2).."Szám legyen nagyobb mint 0!", thePlayer, 255, 255, 255, true)
                end
            end
        else
            outputChatBox("#3399FF[Használat]: #ffffff/"..cmd.." [ID] [Vevő] [Ár]", thePlayer, 255, 255, 255, true)
        end
    end
end)

-- Leülés laptophoz
addEvent("sit >> laptop", true)
addEventHandler("sit >> laptop", root, function(player)
    setElementPosition(player,1385.2255859375, -1222.0823974609, 80.638771057129)
    setElementRotation(player,-0, 0, 3.231981754303)
    setPedAnimation(player, "ped", "SEAT_idle", -1, false)
end)

-- Hőfok állítása
addEvent("set >> temperature", true)
addEventHandler("set >> temperature", root, function(player, marker, amount)
    if marker then
        if amount then 
            setElementData(marker,"or:hotter",1)
            setElementData(marker, "or:temperature", amount)
            dbExec(connection, "UPDATE `gamedev_businesses` SET `hotter`=? WHERE `id`=?", 1, getElementData(marker,"markerid"));
            dbExec(connection, "UPDATE `gamedev_businesses` SET `temperature`=? WHERE `id`=?", amount, getElementData(marker,"markerid"));
            outputChatBox(exports.oCore:getServerPrefix("green-dark", "Játékfejlesztő", 2).."Sikeresen beállítottad a\n hőfokszabályzót "..amount.." fokra.", player, 255, 255, 255, true)
        end
    end
end)

-- Hőfokszabályzó kikapcsolása
addEvent("off >> temperature", true)
addEventHandler("off >> temperature", root, function(player, marker)
    if marker then
        setElementData(marker,"or:hotter",0)
        dbExec(connection, "UPDATE `gamedev_businesses` SET `hotter`=? WHERE `id`=?", 0, getElementData(marker,"markerid"));
        outputChatBox(exports.oCore:getServerPrefix("green-dark", "Játékfejlesztő", 2).."Sikeresen kikapcsoltad a\n hőfokszabályzót.", player, 255, 255, 255, true)
    end
end)

-- Hőfok ellenőrzés, számlagyártás
function makeHotBill()
    for k, v in pairs(getElementsByType("marker")) do
        if getElementData(v,"or:mainmarker") then 
            mainmarkers = v     
        end
    end

    for k, v in pairs(getElementsByType("player")) do
        if not getElementData(v,"user:loggedin") then
            if getElementData(mainmarkers,"or:markerowner") == getElementData(v,"user:id") then
                setElementData(mainmarkers,"or:hotterbill",getElementData(mainmarkers,"or:hotterbill")+250)
                dbExec(connection, "UPDATE `gamedev_businesses` SET `hotterBill`=? WHERE `id`=?", getElementData(mainmarkers,"or:hotterbill"), getElementData(marker,"markerid"));
            end
        else
            if getElementData(mainmarkers,"or:markerowner") == getElementData(v,"user:id") then
                setElementData(v, "char:money", getElementData(v,"char:money")-250)
                outputChatBox(exports.oCore:getServerPrefix("green-dark", "Játékfejlesztő", 2).."A fűtésszámlád: 250$.", player, 255, 255, 255, true)
            end
        end
    end
end
setTimer(makeHotBill,3600000,1)

-- Pénz kivétele a számláról
addEvent("take >> money >> business", true)
addEventHandler("take >> money >> business", root, function(player, marker, amount)
    if marker then
        if amount then
            if tonumber(amount) <= tonumber(getElementData(marker,"or:businessmoney")) then
                setElementData(player,"char:money",getElementData(player,"char:money")+amount)
                setElementData(marker, "or:businessmoney", getElementData(marker,"or:businessmoney")-amount)
                dbExec(connection, "UPDATE `gamedev_businesses` SET `businessMoney`=? WHERE `id`=?", getElementData(marker,"or:businessmoney"), getElementData(marker,"markerid"));
                outputChatBox(exports.oCore:getServerPrefix("green-dark", "Játékfejlesztő", 2).."Sikeresen kivetted a pénzt a céged számlájáról!", player, 255, 255, 255, true)
            else
                outputChatBox(exports.oCore:getServerPrefix("red-dark", "Játékfejlesztő", 2).."Nincs ekkora összeg a számlán!", player, 255, 255, 255, true)
                exports.oInfobox:outputInfoBox("Nincs ekkora összeg a számlán!","error",player)
            end
        end
    end
end)

-- Pénz betétele számlára
addEvent("give >> money >> business", true)
addEventHandler("give >> money >> business", root, function(player, marker, amount)
    if marker then
        if amount then
            if tonumber(amount) <= getElementData(player,"char:money") then
                setElementData(player,"char:money",getElementData(player,"char:money")-amount)
                setElementData(marker, "or:businessmoney", getElementData(marker,"or:businessmoney")+amount)
                dbExec(connection, "UPDATE `gamedev_businesses` SET `businessMoney`=? WHERE `id`=?", getElementData(marker,"or:businessmoney"), getElementData(marker,"markerid"));
                outputChatBox(exports.oCore:getServerPrefix("green-dark", "Játékfejlesztő", 2).."Sikeresen betetted a pénzt a céged számlájára!", player, 255, 255, 255, true)
            else
                outputChatBox(exports.oCore:getServerPrefix("red-dark", "Játékfejlesztő", 2).."Nincs ekkora összeg nálad!", player, 255, 255, 255, true)
                exports.oInfobox:outputInfoBox("Nincs ekkora össze nálad!","error",player)
            end
        end
    end
end)

-- Adatok mentése
