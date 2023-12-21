local streamedVehs = {}

addEventHandler("onClientResourceStart", resourceRoot, function()
    for k, v in ipairs(getElementsByType("vehicle", root, true)) do 
        if getElementModel(v) == 451 then 
            streamedVehs[v] = v
        elseif getElementModel(v) == 410 then 
                streamedVehs[v] = v
        elseif getElementType(v) == "vehicle" then 
            if getVehicleType(v) == "Helicopter" then 
                streamedVehs[v] = v
            end
        end
    end
end)

addEventHandler("onClientElementStreamIn", root, function()
    if getElementModel(source) == 451 then 
        streamedVehs[source] = source
    elseif getElementModel(source) == 410 then 
        streamedVehs[source] = source
    elseif getElementType(source) == "vehicle" then 
        if getVehicleType(source) == "Helicopter" then 
            streamedVehs[source] = source
        end
    end
end)

addEventHandler("onClientElementStreamOut", root, function()
    if getElementModel(source) == 451 then 
        if streamedVehs[source] then 
            streamedVehs[source] = false 
        end
    elseif getElementModel(source) == 410 then 
        if streamedVehs[source] then 
            streamedVehs[source] = false 
        end    elseif getElementType(source) == "vehicle" then 
        if getVehicleType(source) == "Helicopter" then 
            streamedVehs[source] = false
        end
    end
end)

addEventHandler("onClientPreRender", root, function()
    for k, v in pairs(streamedVehs) do 
        if isElement(v) then
            if (getElementModel(v) == 451) then
                local x, y, z = getVehicleComponentRotation(v, "misc_a")

                if tonumber(x) then
                    if getElementData(v, "veh:lamp") then
                        if not (math.floor(x) == 40) then
                            setVehicleComponentRotation(v, "misc_a", x+1, y, z)
                        end
                    else
                        if not (math.floor(x) == 0) then
                            setVehicleComponentRotation(v, "misc_a", x-1, y, z)
                        end
                    end
                end
            elseif (getElementModel(v) == 410) then
                local x, y, z = getVehicleComponentRotation(v, "misc_a")

                if tonumber(x) then
                    if getElementData(v, "veh:lamp") then
                        if not (math.floor(x) == 40) then
                            setVehicleComponentRotation(v, "misc_a", x+1, y, z)
                        end
                    else
                        if not (math.floor(x) == 0) then
                            setVehicleComponentRotation(v, "misc_a", x-1, y, z)
                        end
                    end
                end
            elseif getVehicleType(v) == "Helicopter" then 
                if not getVehicleEngineState(v) then 
                    local speed = getHelicopterRotorSpeed(v)

                    if speed > 0 then
                        setHelicopterRotorSpeed(v, math.max(speed - 0.002, 0))
                    end
                end     
            end
        end
    end
end)

addCommandHandler ( "gvc",
    function ( )
        local theVehicle = getPedOccupiedVehicle ( localPlayer )
        if ( theVehicle ) then
            for k in pairs ( getVehicleComponents ( theVehicle ) ) do
                outputChatBox ( k )
            end
        end
    end
)