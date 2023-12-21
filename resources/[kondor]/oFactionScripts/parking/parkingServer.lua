--[[faction_cp = createMarker(1993.6374511719, -2194.4987792969, 13.546875,'cylinder', 2, 233, 118, 25)
faction_id = 1




function towAttach(veh)
    if (getElementData(veh,'veh:isFactionVehice') == 1)  then --( getElementData(veh,'veh:owner') == faction_id )
        setElementData(source, "veh:handbrake", false)
        --setElementData(source, "vehIsBooked",1)
        setElementFrozen(source, false)
    end
end
addEventHandler("onTrailerAttach", getRootElement(),towAttach)

--[[function handleTow(veh)
    if (getElementType(veh) == 'vehicle') then
        local town = getVehicleTowedByVehicle(veh)
        if town then
            if (getElementData(veh,'veh:isFactionVehice') == 1) and ( getElementData(veh,'veh:owner') == faction_id ) then
                setElementPosition(town, 1997.4197998047, -2195.2687988281, 13.546875)
                setElementData(town, "vehIsBooked",1)
                setElementDimension(town, math.random(1,65534))
                setElementFrozen(town, true)
                setVehicleDamageProof(town, false)
            end
        end
    end
end
addEventHandler("onMarkerHit", faction_cp, handleTow)]]---