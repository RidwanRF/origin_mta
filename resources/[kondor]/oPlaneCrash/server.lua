local objects = {}
local desTimer = nil

function createRandPlaneCrash()
    objects = {}

    local rand = math.random(#planePositions)

    local plane = createObject(3270, unpack(planePositions[rand].plane))
    table.insert(objects, plane)

    local voltpos = false
    for k, v in ipairs(planePositions[rand].boxes) do 
        local box = createObject(3014, v[1], v[2], v[3] - 0.8, 0, 0, math.random(350))
        --print(v[1], v[2], v[3])
        if not voltpos then 
            voltpos = true
            print("repülő pozíciója: ", v[1], v[2], v[3])
        end
        setElementData(box, "plane:boxType", true)
        table.insert(objects, box)
    end

    desTimer = setTimer(function()
        for k, v in ipairs(objects) do 
            if isElement(v) then 
                destroyElement(v)
                print("plane destroyed")
            end
        end

        setTimer(createRandPlaneCrash, core:minToMilisec(math.random(50, 180)), 1)
    end, core:minToMilisec(40), 1)

    createExplosion(planePositions[rand].plane[1], planePositions[rand].plane[2], planePositions[rand].plane[3], 10)

end

createRandPlaneCrash()

setTimer(function()
    createRandPlaneCrash()
end, core:minToMilisec(math.random(50, 180)), 1)

addEvent("planeCrash > startCreateOpeningOnServer", true)
addEventHandler("planeCrash > startCreateOpeningOnServer", resourceRoot, function(element)
    setElementData(element, "illegal:boxIsUnderOpening", client)
    setPedAnimation(client, "bomber", "bom_plant_loop", -1, true, false, false)
end)

addEvent("planeCrash > completeCreateOpeningOnServer", true)
addEventHandler("planeCrash > completeCreateOpeningOnServer", resourceRoot, function(element, elementType, itemValues)
    destroyElement(element)
    setPedAnimation(client, "", "")
    if itemValues then 
        inventory:giveItem(client, itemValues[1], itemValues[3], itemValues[2], 0)
    end
end)