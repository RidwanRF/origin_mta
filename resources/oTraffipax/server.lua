local lastTicket = {}

local mysql = exports.oMysql:getDBConnection()

addEvent("traffipax > moneyminus", true)
addEventHandler("traffipax > moneyminus", resourceRoot, function(money)

    local vehPlate = getVehiclePlateText(getPedOccupiedVehicle(client))

    if not lastTicket[client] then 
        lastTicket[client] = getTickCount()
        dbExec(mysql, "INSERT INTO mdclogs SET reason=?, other=?, owner=?", "Gyorshajtás", money .. "$", vehPlate)
    elseif getTickCount() - lastTicket[client] > 3600000 then 
        lastTicket[client] = getTickCount()
        dbExec(mysql, "INSERT INTO mdclogs SET reason=?, other=?, owner=?", "Gyorshajtás", money .. "$", vehPlate)
    end
    
    setElementData(client, "char:money", getElementData(client, "char:money")-money)
    exports.oDashboard:setFactionBankMoney(1, math.floor(money*0.2), "add")
end)
