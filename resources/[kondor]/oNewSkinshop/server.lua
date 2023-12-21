local factionSkins = {}

addEvent("skinshop > buySkin", true)
addEventHandler("skinshop > buySkin", resourceRoot, function(skin)
    setElementModel(client, skin)
    --print(skin)
end)

addEvent("skinshop > getFactionSkinsFromServer", true)
addEventHandler("skinshop > getFactionSkinsFromServer", resourceRoot, function(openPanel)
    triggerClientEvent(client, "skinshop > sendFactionSkinsToClient", client, factionSkins, openPanel)
end)

addEvent("saveFactionDutySkins", true)
addEventHandler("saveFactionDutySkins", getRootElement(), function(player, factionId, dutySkin)
    triggerEvent("faction > setPlayerDutySkin",player, player, factionId, dutySkin)
end)

addEvent("skinshop > updateFactionSkinTable", true)
addEventHandler("skinshop > updateFactionSkinTable", resourceRoot, function(table)
    --print(toJSON(table))
    factionSkins = table
    --setElementData(resourceRoot, "skinshop:skinTable", factionSkins)
    --print(toJSON(table))
end)

addEventHandler("onResourceStop", resourceRoot, function()
    exports.oJSON:saveDataToJSONFile(toJSON(factionSkins), "fkskins", false)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    factionSkins = fromJSON(exports.oJSON:loadDataFromJSONFile("fkskins", false)) or {}
   -- setElementData(resourceRoot, "skinshop:skinTable", factionSkins)
end)