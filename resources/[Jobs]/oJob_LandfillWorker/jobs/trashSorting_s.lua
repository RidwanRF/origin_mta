addEvent("createTrashBag->OnServer", true)
addEventHandler("createTrashBag->OnServer", resourceRoot, function() 
    local playerpos = Vector3(getElementPosition(client))
    local trashbag = createObject(1264, playerpos.x, playerpos.y, playerpos.z)

    setElementCollisionsEnabled(trashbag, false)
    setObjectScale(trashbag, 0.2)

    setElementData(client, "player:trashbag", trashbag)

    bone:attachElementToBone(trashbag, client, 11, 0.03, 0.02, 0.2, 180, 0, 0)
end)

addEvent("setTrashBagScale->OnServer", true)
addEventHandler("setTrashBagScale->OnServer", resourceRoot, function(scale) 
    if scale == "big" then 
        scale = 0.35
    elseif scale == "small" then 
        scale = 0.2 
    end

    setObjectScale(getElementData(client, "player:trashbag"), scale)
end)

addEvent("warpToSortInterior->OnServer", true)
addEventHandler("warpToSortInterior->OnServer", resourceRoot, function() 
    setElementInterior(client, 2)
    setElementPosition(client, 2570.3776855469, -1301.9447021484, 1044.125)
end)

addEvent("warpOutToSortInterior->OnServer", true)
addEventHandler("warpOutToSortInterior->OnServer", resourceRoot, function() 
    setElementInterior(client, 0)
    setElementPosition(client, 2209.8962402344, -2022.4278564453, 13.546875)
end)

addEvent("trashjob > endTrashSorting", true)
addEventHandler("trashjob > endTrashSorting", resourceRoot, function(money)
    setObjectScale(getElementData(client, "player:trashbag"), 0.2)
    setElementData(client, "char:money", getElementData(client, "char:money")+money)
end)

for k, v in ipairs(stripes) do 
    local col = createColSphere(v.pos.x, v.pos.y, v.pos.z, 1.5)
    setElementInterior(col, 2)
    setElementData(col, "sortingCol", true)
    setElementData(col, "tableUse", false)
end