local shops = {}
local connection = mysql:getDBConnection()
local shopsById = {}

addEventHandler("onResourceStart",resourceRoot,
    function()
        local qh = dbQuery(connection, 'SELECT * FROM shops')
        local result = dbPoll(qh, 150)

        if result then 
            for rid, row in ipairs (result) do 
                createOneShopPed(row["pos"], row["skin"], row["name"], row["items"], row["id"], row["private"], row["cost"], row["money"], row["owner"], fromJSON(row["orders"]), fromJSON(row["deliveryArea"]))
            end
        end

        generateRandomBusinessPrices()

        setTimer(generateRandomBusinessPrices, core:minToMilisec(60), 0)
    end 
)

function generateRandomBusinessPrices()
    for k, v in pairs(businessBuyableItems) do 
        setElementData(resourceRoot, "shop:businessItemPrice:"..v[1], math.max(math.random(v[2], v[3]), 1))
    end
end

addEventHandler("onResourceStop",resourceRoot,
    function()
        for k, v in ipairs(shops) do 
            if isElement(v) then
                local items = getElementData(v, "shop:ped:items") or {}
                local orders = getElementData(v, "shop:orders") or {}
                local owner = getElementData(v, "shop:owner") or 0
                local money = getElementData(v, "shop:money") or 0
                local business = getElementData(v, "shop:private") or 0
            
                local shopID = getElementData(v, "shop:id")

                if business == 0 then
                    items = toJSON(items)
                    orders = toJSON(orders)
                    dbExec(connection, "UPDATE shops SET items = ?, owner = ?, money = ?, orders = ? WHERE id = ?", items, owner, money, orders, shopID)

                else
                    if #items <= 0 then 
                        dbExec(connection, "UPDATE shops SET owner = ?, money = ?, orders = ? WHERE id = ?", owner, money, orders, shopID)
                    else
                        items = toJSON(items)
                        orders = toJSON(orders)

                        dbExec(connection, "UPDATE shops SET items = ?, owner = ?, money = ?, orders = ? WHERE id = ?", items, owner, money, orders, shopID)
                    end
                end
            end
        end
    end 
)

addEvent("setShopPedItems", true)
addEventHandler("setShopPedItems", resourceRoot, function(dealer,items)
    local shopID = getElementData(dealer, "shop:id")

    setElementData(dealer,"shop:ped:items",items)

 

end)


addEvent("shop > buyShopItem", true)
addEventHandler("shop > buyShopItem", resourceRoot, function(itemID, price, type, shopElement)
    inventory = exports.oInventory
    
    local buyedItemWeight = inventory:getItemWeight(itemID) 
    if (inventory:getElementItemsWeight(client) + buyedItemWeight) <= 20 then 
        if inventory:getFreeSlot(client) then
            setElementData(client, "char:money", getElementData(client, "char:money") - price)

            inventory:giveItem(client, itemID, (itemDefValue[itemID] or 1), 1, 0)
            
            outputChatBox(core:getServerPrefix("green-dark", "Bolt", 2).."Sikeres vásárlás!", client, 255, 255, 255, true)

            if (type or "") == "business" then 
                local items = getElementData(shopElement, "shop:ped:items")

                items[tostring(itemID)][1] = items[tostring(itemID)][1] - 1
                setElementData(shopElement, "shop:ped:items", items)

                setElementData(shopElement, "shop:money", getElementData(shopElement, "shop:money") + price)
            end
        else
           outputChatBox(core:getServerPrefix("red-dark", "Bolt", 2).."Nincs az inventorydban elegendő hely! (Slot)", client, 255, 255, 255, true)
        end
    else
        outputChatBox(core:getServerPrefix("red-dark", "Bolt", 2).."Nincs az inventorydban elegendő hely! (Súly)", client, 255, 255, 255, true)
    end
end)

----/commands/-----
--[[addCommandHandler("makeshop",
    function(player,cmd,name,skin,private,cost,money)
        if name and skin then 
            skin = tonumber(skin)
            name = tostring(name)
            type = tonumber(type)

            local x,y,z = getElementPosition(player)
            local rotX,rotY,rotZ = getElementRotation(player)

            local interior = getElementInterior(player)
            local dimension = getElementDimension(player)

            local pos = toJSON({x, y, z, rotZ, interior, dimension})

            private = private or 0 
            cost = cost or 0

            dbExec(connection, "INSERT INTO shops (pos,name,skin,items,private,cost,money,owner) VALUES (?,?,?,?,?,?,?,?)", pos, name, skin, toJSON({}), private, cost, 0, 0)

            dbQuery(function(qh)
                local result, rows = dbPoll(qh, 0)
                if rows > 0 then
                    createOneShopPed(pos,skin,name,toJSON({}),result[1]["id"],private,cost,money,0,{})
                    local pX,pY,pZ = getElementPosition(player)

                    if result[1]["private"] then
                        exports.oAdmin:sendMessageToAdmins(player, "létrehozott egy ELADÓ boltot. (Itt: #db3535"..getZoneName(pX,pY,pZ).."#557ec9, ID: #db3535"..result[1]["id"].."#557ec9)")
                    else
                        exports.oAdmin:sendMessageToAdmins(player, "létrehozott egy boltot. (Itt: #db3535"..getZoneName(pX,pY,pZ).."#557ec9, ID: #db3535"..result[1]["id"].."#557ec9)")
                    end
                end
            end, connection, "SELECT * FROM shops WHERE id=LAST_INSERT_ID()")

        else 
            outputChatBox(core:getServerPrefix("server", "Használat", 3).."/"..cmd.." [Név] [Skin] [Biznisz (0, 1)] [Ára]",player,255,255,255,true)
        end
    end 
)]]

addEvent("shop > makeShop", true)
addEventHandler("shop > makeShop", resourceRoot, function(name,skin,pos,private,cost,money, deliveryArea)
    local player = client
    dbExec(connection, "INSERT INTO shops (pos,name,skin,items,private,cost,money,owner,deliveryArea) VALUES (?,?,?,?,?,?,?,?,?)", pos, name, skin, toJSON({}), private, cost, 0, 0, toJSON(deliveryArea))

    dbQuery(function(qh)
        local result, rows = dbPoll(qh, 0)
        if rows > 0 then
            createOneShopPed(pos,skin,name,toJSON({}),result[1]["id"],private,cost,money,0,{}, deliveryArea)
            local pX,pY,pZ = getElementPosition(player)

            if result[1]["private"] then
                exports.oAdmin:sendMessageToAdmins(player, "létrehozott egy ELADÓ boltot. (Itt: #db3535"..getZoneName(pX,pY,pZ).."#557ec9, ID: #db3535"..result[1]["id"].."#557ec9)")
            else
                exports.oAdmin:sendMessageToAdmins(player, "létrehozott egy boltot. (Itt: #db3535"..getZoneName(pX,pY,pZ).."#557ec9, ID: #db3535"..result[1]["id"].."#557ec9)")
            end
        end
    end, connection, "SELECT * FROM shops WHERE id=LAST_INSERT_ID()")
end)

addCommandHandler("delshop",
    function(player,cmd,id)
        if getElementData(player, "user:admin") >= 7 then
            if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

            if id then
                local volt = false
                id = tonumber(id)
                for k,v in ipairs(getElementsByType("ped")) do 
                    if not volt then 
                        local shopId = getElementData(v,"shop:id") or 0 

                        if shopId == id then 
                            dbExec(connection, "DELETE FROM shops WHERE id=?", id)

                            local eX,eY,eZ = getElementPosition(v)
                            exports.oAdmin:sendMessageToAdmins(player, "törölt egy boltot. (Itt: #db3535"..getZoneName(eX,eY,eZ).."#557ec9, ID: #db3535"..id.."#557ec9)")

                            if getElementData(v, "shop:deliveryArea") then 
                                destroyElement(getElementData(v, "shop:deliveryArea"))
                            end

                            destroyElement(v)
                            volt = true 
                        end
                    end
                end 
            else
                outputChatBox(core:getServerPrefix("server", "Használat", 3).."/"..cmd.." [ID]",player,255,255,255,true) 
            end
        end
    end 
)

function createOneShopPed(position,skin,name,items,id,private,cost,money,owner,orders, deliveryArea)   
    local pos = fromJSON(position)
    skin = tonumber(skin)
    items = fromJSON(items)
    local ped = createPed(skin,pos[1],pos[2],pos[3],pos[4])

    if isElement(ped) then
        setPedFrozen(ped,true)
        setElementData(ped,"isShopPed",true)
        setElementData(ped,"shop:id",id)
        setElementData(ped,"shop:ped:items",items)
        setElementData(ped,"ped:name",name)

        setElementData(ped, "shop:isRobbable", true)
        setElementData(ped, "shop:robInProgress", false)
        setElementData(ped, "shop:robbableMoney", 0)

        setElementData(ped, "shop:private", tonumber(private))
        setElementData(ped, "shop:cost", tonumber(cost))
        setElementData(ped, "shop:money", money)
        setElementData(ped, "shop:owner", owner)
        setElementData(ped, "shop:orders", orders)

        setElementInterior(ped, pos[5])
        setElementDimension(ped, pos[6])

        table.insert(shops, #shops+1, ped)

        shopsById[id] = ped

        if #deliveryArea > 0 then
            if deliveryArea[4] < 0 then 
                deliveryArea[1] = deliveryArea[1] + deliveryArea[4]
                deliveryArea[4] = math.abs(deliveryArea[4])
            end

            if deliveryArea[5] < 0 then 
                deliveryArea[2] = deliveryArea[2] + deliveryArea[5]
                deliveryArea[5] = math.abs(deliveryArea[5])
            end

            local col = createColCuboid(deliveryArea[1], deliveryArea[2], deliveryArea[3] - 0.5, deliveryArea[4], deliveryArea[5], 5)
            setElementData(ped, "shop:deliveryArea", col)
            setElementData(col, "deliveryArea:shop", id)
            setElementData(col, "deliveryArea:position", deliveryArea)
            setElementData(col, "deliveryArea:ShopPed", ped)
        end
    end
end

addEvent("shop > business > buyShop", true)
addEventHandler("shop > business > buyShop", resourceRoot, function(shopElement)
    setElementData(shopElement, "shop:owner", getElementData(client, "char:id"))
    setElementData(client, "char:money", getElementData(client, "char:money") - getElementData(shopElement, "shop:cost"))
end)

addEvent("shop > business > makeOrder", true)
addEventHandler("shop > business > makeOrder", resourceRoot, function(shopElement, item, count, price)
    local pendingOrders = getElementData(shopElement, "shop:orders")
    table.insert(pendingOrders, {item, count})
    setElementData(shopElement, "shop:orders", pendingOrders)

    setElementData(client, "char:money", getElementData(client, "char:money") - price)
end)

for k, v in ipairs(getElementsByType("vehicle")) do 
    setElementData(v, "veh:shop:inTransportShop", 0)
    setElementData(v, "veh:shop:inTransportBoxes", {})
    setElementData(v, "veh:shop:inTransportObjects", {})
end

addEvent("shop > business > takeOrder", true)
addEventHandler("shop > business > takeOrder", resourceRoot, function(veh, order)
    local inTransportID = getElementData(veh, "veh:shop:inTransportShop") or 0
    local inTransportBoxes = getElementData(veh, "veh:shop:inTransportBoxes") or {}
    local inTransportObjects = getElementData(veh, "veh:shop:inTransportObjects") or {}

    if inTransportID == 0 or inTransportID == order[1] then 
        if #inTransportBoxes < 4 then 
            setElementData(veh, "veh:shop:inTransportShop", order[1])

            local object = createObject(1224, 0, 0, 0)
            setObjectScale(object, 0.45)
            setElementCollisionsEnabled(object, false)
            attachElements(object, veh, boxAttachPosiitons[#inTransportBoxes + 1][1], boxAttachPosiitons[#inTransportBoxes + 1][2], boxAttachPosiitons[#inTransportBoxes + 1][3])

            table.insert(inTransportBoxes, {order[3], order[4]})
            setElementData(veh, "veh:shop:inTransportBoxes", inTransportBoxes)

            table.insert(inTransportObjects, object)
            setElementData(veh, "veh:shop:inTransportObjects", inTransportObjects)

            local allOrder = getElementData(shopsById[order[1]], "shop:orders")
            for k, v in ipairs(allOrder) do
                if (v[1] == order[3]) and (v[2] == order[4]) then 
                    table.remove(allOrder, k)
                    setElementData(shopsById[order[1]], "shop:orders", allOrder)
                    break
                end 
            end
        end
    end
end)

addEvent("shop > business > completeDelivery", true)
addEventHandler("shop > business > completeDelivery", resourceRoot, function(veh, col)
    local objects = getElementData(veh, "veh:shop:inTransportObjects")

    for k, v in pairs(objects) do 
        destroyElement(v)
    end

    setElementData(veh, "veh:shop:inTransportObjects", {})

    local orders = getElementData(veh, "veh:shop:inTransportBoxes")
    local shop = getElementData(col, "deliveryArea:ShopPed")
    local items = getElementData(shop, "shop:ped:items")

    for k, v in ipairs(orders) do 
        if items[tostring(v[1])] then 
            items[tostring(v[1])][1] = items[tostring(v[1])][1] + v[2]
        else
            items[tostring(v[1])] = {v[2], 0}
        end 
    end

    setElementData(shop, "shop:ped:items", items)

    setElementData(veh, "veh:shop:inTransportBoxes", {})
    setElementData(veh, "veh:shop:inTransportShop", 0)
end)

addEvent("shop > business > setItemPrice", true)
addEventHandler("shop > business > setItemPrice", resourceRoot, function(shop, item, price)
    local items = getElementData(shop, "shop:ped:items")

    if items[tostring(item)] then 
        items[tostring(item)][2] = price
    else
        items[tostring(item)] = {0, price}
    end 

    setElementData(shop, "shop:ped:items", items)
end)

addEvent("shop > business > sellShop", true)
addEventHandler("shop > business > sellShop", resourceRoot, function(shop)
    setElementData(shop, "shop:owner", 0)
    setElementData(client, "char:money", getElementData(client, "char:money") + getElementData(shop, "shop:cost"))
    setElementData(shop, "shop:money", 0)
    outputChatBox(core:getServerPrefix("green-dark", "Bolt", 2).."Sikeresenn eladtad a boltodat! Kaptál érte: "..color..getElementData(shop, "shop:cost").."#ffffff$-t.", client, 255, 255, 255, true)
end)

function buyItemFromPrivateShop()
    for k, v in ipairs(shops) do
        if getElementData(v, "shop:private") == 1 then 
            local shopItems = getElementData(v, "shop:ped:items")
            local availableKeys = {}

            for k2, v2 in pairs(shopItems) do
                if v2[1] > 0 then 
                    if v2[2] > 0 then
                        if ((v2[2] or 0) <= ((itemPrices[tonumber(k2)] or -1) * 1.2)) then 
                            table.insert(availableKeys, k2)
                        end
                    end
                end
            end

            if #availableKeys >= 2 then
                local randomItem = math.random(#availableKeys)  

                shopItems[availableKeys[randomItem]][1] = shopItems[availableKeys[randomItem]][1]-1

                setElementData(v, "shop:ped:items", shopItems)

                setElementData(v, "shop:money", getElementData(v, "shop:money") + shopItems[availableKeys[randomItem]][2])
            end
        end
    end

    setTimer(buyItemFromPrivateShop, core:minToMilisec(math.random(8, 12)), 1)
end 
setTimer(buyItemFromPrivateShop, core:minToMilisec(math.random(2, 10)), 1)