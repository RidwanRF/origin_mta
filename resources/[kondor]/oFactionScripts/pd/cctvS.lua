addEvent("factionScripts > cctv > sendMessage", true)
addEventHandler("factionScripts > cctv > sendMessage", root, function(msg, msg2, msg3)
    triggerClientEvent(root, "factionScripts > cctv > recieveCameraMessage", root, msg, msg2, msg3)
end)