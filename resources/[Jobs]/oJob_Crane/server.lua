addEvent("craneJob > setPlayerAlpha", true)
addEventHandler("craneJob > setPlayerAlpha", resourceRoot, function(alpha)
    setElementAlpha(client, alpha)
end)