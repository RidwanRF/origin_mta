addEvent("weaponShop > buyItem", true)
addEventHandler("weaponShop > buyItem", resourceRoot, function(id, count, price)
    setElementData(client, "char:money", getElementData(client, "char:money") - price)
    inventory:giveItem(client, id, 100, count, 0)
end)