local serverInShutDownProgress = false 

local core = exports.oCore
local color, r, g, b = core:getServerColor()

setElementData(resourceRoot, "timeToRestart", false)

addEventHandler("onPlayerConnect", root, function()
    if serverInShutDownProgress then 
        --cancelEvent(true, "A szerver újraindítása folyamatban van!")
    end
end)

local stopTimer = nil
local stopTime = {}

addCommandHandler("stopserver", function(player, cmd, time)
    if (getElementData(player, "aclLogin") or false) == true then 
        if serverInShutDownProgress then 
            serverInShutDownProgress = false
            triggerClientEvent("setServerRestartState", resourceRoot, false)

            if isTimer(stopTimer) then 
                killTimer(stopTimer)
            end
        else
            if tonumber(time) then 
                serverInShutDownProgress = true 

                stopTime = {time, 0}
                setElementData(resourceRoot, "timeToRestart", stopTime)

                stopTimer = setTimer(function()
                    stopTime[2] = stopTime[2] - 1

                    if stopTime[2] <= 0 then 
                        if stopTime[1] == 0 then
                           killTimer(stopTimer)
                        else
                            stopTime[1] = stopTime[1] - 1
                            stopTime[2] = 59 
                        end
                    end

                    setElementData(resourceRoot, "timeToRestart", stopTime)
                end, 1000, 0)

                triggerClientEvent("setServerRestartState", resourceRoot, true)
                outputChatBox(core:getServerPrefix("red-dark", "Szerver leállás", 2).."A szerver "..color..time.."#ffffff perc múlva újraindul.", root, 255, 255, 255, true)
            else
                outputChatBox(core:getServerPrefix("server", "Használat", 3).."/"..cmd.." [Perc]", player, 255, 255, 255, true)
            end
        end
    end
end)