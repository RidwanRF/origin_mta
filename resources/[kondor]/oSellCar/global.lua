loadedShops = {}


sColor2 = '#e97619'
sColor = {getColorFromString(sColor2)}

red2 = '#CD5C5C'
red = {getColorFromString(red2)}

green2 = '#228B22'
green = {getColorFromString(green2)}

syntax = sColor2 .. '[OriginalRoleplay - CarShop]#FFFFFF '

performanceTunings = {
    engine = 'Motor',
    gear = 'Váltó',
    brake = 'Fékek',
    turbo = 'Turbó',
    ecu = 'ECU',
    wloss = 'Súlycsökkentés'
}

tuningLevels = {
    [0] = '#922929Nincs',
    [1] = 'Alap',
    [2] = '#41459bVerseny',
    [3] = 'Profi',
    [4] = '#97853fPrémium'
}

function havePlayerShop(player)
    local result = false

    local charId = player:getData('char:id') or -1
    if charId > 0 then
        for shopId, shop in pairs(loadedShops) do 
            for memberId, member in pairs(shop.members) do 
                if member.charId == charId then 
                    result = {
                        shopId = shopId,
                        memberId = memberId
                    }
                    break
                end
            end

            if result then 
                break
            end
        end
    end

    return result;
end

function isPlayerInShop(player, shopId)
    local charId = player:getData('char:id') or -1
    if charId > 0 and (loadedShops[shopId] and loadedShops[shopId].members) then 
        for memberId, member in pairs(loadedShops[shopId].members) do 
            if member.charId == charId then 
                return memberId
            end
        end
        return false
    end
    return false
end

function isOnline(charId)
    local result = false

    for _, player in pairs(Element.getAllByType('player')) do 
        local _charId = player:getData('char:id') or -1
        if _charId > 0 and charId == _charId then
            result = player
            break
        end 
    end

    return result
end

function findMember(shopId, charId)
    if loadedShops[shopId] then
        local members = loadedShops[shopId].members
        
        for memberId, member in pairs(members) do 
            if member.charId == charId then 
                return memberId
            end
        end
    end
    return false
end

function findCar(vehId)
    for _, vehicle in pairs(Element.getAllByType('vehicle')) do 
        if (vehicle:getData('veh:id') or 0) == vehId then
            return vehicle
        end
    end

    return false
end