local connection = exports.oMysql:getDBConnection()

local shopMarkers = {}

--[[
    elementDatas:
    char:id -- character id

    sql:
    id
    name
    members
    markers
    bank
    position
]]

addEventHandler('onResourceStart', resourceRoot, function()
    for _, player in pairs(Element.getAllByType('player')) do 
        if player:getData('user:loggedin') and not player:getData('joinTime') then 
            player:setData('joinTime', getRealTime().timestamp)
        end
    end

    connection:query(function(qh)
        local result = qh:poll(0)
        for _, row in pairs(result) do 
            loadShop(row)
        end

        triggerClientEvent(root, 'receiveUsedCarshops', root, loadedShops)
    end, 'SELECT * FROM usedcarshops')
end)

function updateMemberData(player, dataName, value)
    local charId = player:getData('char:id')

    local find = false
    local shop = havePlayerShop(player)
    if shop and loadedShops[shop.shopId] and loadedShops[shop.shopId].members then 
        if loadedShops[shop.shopId].members[shop.memberId] then 
            loadedShops[shop.shopId].members[shop.memberId][dataName] = value

            connection:exec('UPDATE usedcarshops SET members=? WHERE id=?', toJSON(loadedShops[shop.shopId].members), shop.shopId)
            triggerClientEvent(root, 'receiveUsedCarshops', root, loadedShops)
        end
    end
end
addEvent("updateMemberData", true)
addEventHandler("updateMemberData", resourceRoot, updateMemberData)

function loadShop(row, trigger)
    local dbId = tonumber(row.id)

    local posData = fromJSON(row.position)
    local pos = posData.xyz

    local pickup = Pickup(pos.x, pos.y, pos.z, 3, 1274)
    pickup.dimension = posData.dimension
    pickup.interior = posData.interior   
    pickup:setData('usedCarshop', dbId)
    addEventHandler('onPickupHit', pickup, function()
        cancelEvent()
    end)

    local markers = fromJSON(row.markers)

   -- iprint(dbId, row.members)

    loadedShops[dbId] = {
        name = row.name,
        members = fromJSON(row.members),
        markers = markers,
        bank = tonumber(row.bank),

        pickup = pickup,
    }


    for markerId, value in ipairs(markers) do 
        createShopMarker(dbId, markerId, value, row.name)
    end

    if trigger then 
        triggerClientEvent(root, 'receiveUsedCarshops', root, loadedShops)
    end
end

function createShopMarker(dbId, markerId, position, name)
    local pos = position.xyz
    local marker = Marker(pos.x, pos.y, pos.z, 'cylinder', 1.5, sColor[1], sColor[2], sColor[3], 50)
    marker.dimension = position.dimension
    marker.interior = position.interior
    marker:setData('usedCarshop', dbId)
    marker:setData('marker.id', markerId)
    marker:setData('marker.name', name)

    if not shopMarkers[dbId] then 
        shopMarkers[dbId] = {}
    end

    shopMarkers[dbId][markerId] = marker

    return marker
end

addCommandHandler('createcarshop', function(player, cmd, ...)
    if (getElementData(player, "user:admin") or 0) >= 10 then
        if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

        if not (...) then 
            outputChatBox(syntax .. '/' .. cmd .. ' [Név]', player, 255, 255, 255, true)
            return
        end

        --[[
            id
            name
            members
            markers
            bank
            position
        ]]

        local name = table.concat({...}, ' ')
        if name:len() > 0 then
            local pos = player.position
            local position = {
                xyz = {x = pos.x, y = pos.y, z = pos.z},
                dimension = player.dimension,
                interior = player.interior
            }
            
            connection:exec('INSERT INTO usedcarshops SET name=?, members=?, markers=?, position=?', name, toJSON({}), toJSON({}), toJSON(position))

            connection:query(function(qh)
                local result = qh:poll(0)
                loadShop(result[1], true)
            end, 'SELECT * FROM usedcarshops WHERE id=LAST_INSERT_ID()')

            outputChatBox(syntax .. 'Sikeres autókereskedés létrehozás!', player, 255, 255, 255, true)
        else 
            outputChatBox(syntax .. 'Hibás a megadott név!', player, 255, 255, 255, true)
        end
    end
end)

addCommandHandler('addcarshopmarker', function(player, cmd, dbId)
    if (getElementData(player, "user:admin") or 0) >= 10 then
        if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

        if not dbId or not math.floor(tonumber(dbId)) then 
            outputChatBox(syntax .. '/' .. cmd .. ' [Kereskedés Id]', player, 255, 255, 255, true)
            return
        end

        dbId = math.floor(tonumber(dbId))

        if loadedShops[dbId] then 
            local pos = player.position
            local position = {
                xyz = {x = pos.x, y = pos.y, z = pos.z - 1},
                dimension = player.dimension,
                interior = player.interior
            }

            local markerId = #loadedShops[dbId].markers + 1
            loadedShops[dbId].markers[markerId] = position
            connection:exec('UPDATE usedcarshops SET markers=? WHERE id=?', toJSON(loadedShops[dbId].markers), dbId)

            createShopMarker(dbId, markerId, position)

            outputChatBox(syntax .. 'Sikeres marker létrehozás!', player, 255, 255, 255, true)
        else 
            outputChatBox(syntax .. 'Hibás a megadott Id!', player, 255, 255, 255, true)
        end
    end
end)

addCommandHandler('deletecarshopmarker', function(player, cmd, shopId, markerId)
    if (getElementData(player, "user:admin") or 0) >= 10 then
        if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

        if not tonumber(shopId) or not tonumber(markerId) then 
            outputChatBox(syntax .. '/' .. cmd .. ' [Kereskedés Id] [Marker Id]', player, 255, 255, 255, true)
            return
        end

        shopId = math.floor(tonumber(shopId))
        markerId = math.floor(tonumber(markerId))

        if loadedShops[shopId] then 
            if shopMarkers[shopId] and shopMarkers[shopId][markerId] then 
                local markData = loadedShops[shopId].markers[markerId]
                if markData.haveCar and findCar(markData.haveCar) then 
                    outputChatBox(syntax .. 'Ezen a helyen jármű van, vedd ki mielőtt törölnéd!', player, 255, 255, 255, true)
                    return
                end

                if isElement(shopMarkers[shopId][markerId]) then 
                    shopMarkers[shopId][markerId]:destroy()
                end
                shopMarkers[shopId][markerId] = nil

                loadedShops[shopId].markers[markerId] = nil
                connection:exec('UPDATE usedcarshops SET markers=? WHERE id=?', toJSON(loadedShops[shopId].markers), shopId)
            else 
                outputChatBox(syntax .. 'Hibás marker ID!', player, 255, 255, 255, true)
            end
        else 
            outputChatBox(syntax .. 'Hibás kereskedés ID!', player, 255, 255, 255, true)
        end
    end
end)

addCommandHandler('setplayercarshop', function(player, cmd, target, shopId, owner)
    if (getElementData(player, "user:admin") or 0) >= 7 then
        if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

        if not target or not tonumber(shopId) then 
            outputChatBox(syntax .. '/' .. cmd .. ' [Játékos ID] [Kereskedés Id (0-akkor kivétel.)] [Tulajdonos 0-1]', player, 255, 255, 255, true)
            return
        end

        local targetPlayer = exports.oCore:getPlayerFromPartialName(player, target)
        if targetPlayer then 
            shopId = math.floor(tonumber(shopId))
            owner = math.floor(tonumber(owner or 0)) or 0

            local playerShop = havePlayerShop(targetPlayer)

            if shopId == 0 then 
                if playerShop and loadedShops[playerShop.shopId] then
                    local member = loadedShops[playerShop.shopId].members[playerShop.memberId]
                    if member then 
                        triggerEvent('removePlayerFromShop', targetPlayer, playerShop.shopId, playerShop.memberId, member)
                       -- print('remove')
                    end
                    outputChatBox(syntax .. 'Játékos kereskedésből, kiéptetve. (' .. targetPlayer.name .. ')', player, 255, 255, 255, true)
                end
                return
            end

            if playerShop then 
                outputChatBox(syntax .. 'Játékos már tagja egy kereskedésnek!', player, 255, 255, 255, true)
                return
            end

            if loadedShops[shopId] then 
                addPlayerToShop(shopId, targetPlayer, owner == 1)

                outputChatBox(syntax .. 'Sikeresen hozzáadtad a játékost a kereskedéshez. (' .. loadedShops[shopId].name .. ')', player, 255, 255, 255, true)           
            else
                outputChatBox(syntax .. 'Hibás kereskedés ID!', player, 255, 255, 255, true)
            end
        end
    end
end)

function addPlayerToShop(shopId, player, owner)
    local members = loadedShops[shopId].members
    table.insert(members, { 
        charId = player:getData('char:id'),
        charName = player.name:gsub('_', ' '),
        lastLogin = player:getData('joinTime') or getRealTime().timestamp,
        owner = owner and 1 or 0,
        selledCars = 0,
    })
    loadedShops[shopId].members = members

    connection:exec('UPDATE usedcarshops SET members=? WHERE id=?', toJSON(members), shopId)
    triggerClientEvent(root, 'receiveUsedCarshops', root, loadedShops)

    exports.oInfobox:outputInfoBox('Felvettek a/az ' .. loadedShops[shopId].name .. ' autókereskedésbe!', 'info', player)
end
addEvent('addPlayerToShop', true)
addEventHandler('addPlayerToShop', root, addPlayerToShop)

addEvent('removePlayerFromShop', true)
addEventHandler('removePlayerFromShop', root, function(shopId, memberId, member)
    if loadedShops[shopId] and (loadedShops[shopId].members and loadedShops[shopId].members[memberId]) then 
        local members = loadedShops[shopId].members
        
        if members[memberId].charId == member.charId then
            table.remove(loadedShops[shopId].members, memberId)

            connection:exec('UPDATE usedcarshops SET members=? WHERE id=?', toJSON(loadedShops[shopId].members), shopId)
            triggerClientEvent(root, 'receiveUsedCarshops', root, loadedShops)

            local targetPlayer = isOnline(member.charId)
            if targetPlayer then 
                exports.oInfobox:outputInfoBox('Kirúgtak a/az ' .. loadedShops[shopId].name .. ' autókereskedésből!', 'info', targetPlayer)
            end
        end
    end
end)

addEvent('changeCarshopOwnerStatus', true)
addEventHandler('changeCarshopOwnerStatus', root, function(shopId, memberId, member)
    if loadedShops[shopId] and (loadedShops[shopId].members and loadedShops[shopId].members[memberId]) then 
        local members = loadedShops[shopId].members
        
        if members[memberId].charId == member.charId then
            local newOwner = loadedShops[shopId].members[memberId].owner == 1 and 0 or 1
            loadedShops[shopId].members[memberId].owner = newOwner

            connection:exec('UPDATE usedcarshops SET members=? WHERE id=?', toJSON(loadedShops[shopId].members), shopId)
            triggerClientEvent(root, 'receiveUsedCarshops', root, loadedShops)

            local targetPlayer = isOnline(member.charId)
            if targetPlayer then 
                exports.oInfobox:outputInfoBox('Módosították a tulajdonos rangodat a/az ' .. loadedShops[shopId].name .. ' autókereskedésben!', 'info', targetPlayer)
            end
        end
    end
end)

addEvent('updateShopBank', true)
addEventHandler('updateShopBank', root, function(shopId, amount, typ)
    if not loadedShops[shopId] then 
        return
    end
    local player = client
    local myMoney = player:getData('char:money')

    if typ == '+' then 

        if myMoney >= amount then 
            player:setData('char:money', myMoney - amount)

            local newBank = (loadedShops[shopId].bank or 0) + amount
            loadedShops[shopId].bank = newBank
            connection:exec('UPDATE usedcarshops SET bank=? WHERE id=?', newBank, shopId)
            triggerClientEvent(root, 'receiveUsedCarshops', root, loadedShops)
        end
    elseif typ == '-' then 
        local bankMoney = loadedShops[shopId].bank or 0

        if bankMoney >= amount then 
            player:setData('char:money', myMoney + amount)
            local newBank = (loadedShops[shopId].bank or 0) - amount
            loadedShops[shopId].bank = newBank
            connection:exec('UPDATE usedcarshops SET bank=? WHERE id=?', newBank, shopId)
            triggerClientEvent(root, 'receiveUsedCarshops', root, loadedShops)
        else 
            exports.oInfobox:outputInfoBox('Nincs elég pénz a kereskedés számláján!', 'error', player)
        end
    end
end)

addEvent('addVehicleToShop', true)
addEventHandler('addVehicleToShop', root, function(vehicle, marker, price)
    if isElement(vehicle) and isElement(marker) then 
        local shopId = marker:getData('usedCarshop')
        if loadedShops[shopId] then 
            local markerId = marker:getData('marker.id')
            local carshopData = {
                shopId = shopId,
                markerId = markerId,
                addedBy = client:getData('char:id'),
                price = price
            }
            vehicle:setData('inCarshop', carshopData)

            setElementData(vehicle, "veh:engine", false)
            setVehicleEngineState(vehicle, false)

            connection:exec('UPDATE vehicles SET carshop=? WHERE id=?', toJSON(carshopData), vehicle:getData('veh:id'))

            loadedShops[shopId].markers[markerId].haveCar = vehicle:getData('veh:id')
            triggerClientEvent(root, 'receiveUsedCarshops', root, loadedShops)
            connection:exec('UPDATE usedcarshops SET markers=? WHERE id=?', toJSON(loadedShops[shopId].markers), shopId)

            exports.oInfobox:outputInfoBox('Sikeresen beraktad a járművet a kereskedésbe!', 'success', client)

            setElementAlpha(marker,0)
        end
    end
end)

addEvent('buyVehicleFromShop', true)
addEventHandler('buyVehicleFromShop', root, function(vehicle, onlyOut)
    local player = client
    local shopData = vehicle:getData('inCarshop') or false 

    if shopData and type(shopData) == 'table' then 
        local shopId = shopData.shopId
        local markerId = shopData.markerId
        local price = shopData.price

        if loadedShops[shopId] then
            local members = loadedShops[shopId].members
            local memberId = findMember(shopId, shopData.addedBy)

            if not onlyOut then 
                if memberId and loadedShops[shopId].members[memberId] then 
                    loadedShops[shopId].members[memberId].selledCars = loadedShops[shopId].members[memberId].selledCars + 1
                end
                loadedShops[shopId].bank = loadedShops[shopId].bank + price

                player:setData('char:money', player:getData('char:money') - price)
                exports.oInfobox:outputInfoBox('Sikeres jármű vásárlás.', 'success', player)
            else 
                exports.oInfobox:outputInfoBox('Kivetted a járművet a kerskedésből', 'info', player)
            end

         

            if loadedShops[shopId].markers[markerId] then 
                loadedShops[shopId].markers[markerId].haveCar = false
            end

            setElementAlpha(shopMarkers[shopId][markerId],50)

            connection:exec('UPDATE usedcarshops SET members=?, markers=?, bank=? WHERE id=?', toJSON(loadedShops[shopId].members), toJSON(loadedShops[shopId].markers), loadedShops[shopId].bank, shopId)
            triggerClientEvent(root, 'receiveUsedCarshops', root, loadedShops)

            --vehicle:removeData('inCarshop')
            
            setElementData(vehicle, "inCarshop", false)
            setElementFrozen(vehicle,false)
            setElementData(vehicle, "veh:engine", true)
            setVehicleEngineState(vehicle, true)

            setElementData(vehicle, "veh:owner", getElementData(player, "char:id"))
            
            --iprint('kulcs addolás: ', vehicle:getData('veh:id'))
            exports.oInventory:giveItem(player, 51, vehicle:getData('veh:id'), 1, 0)
        end
    end
end)
