core = exports.oCore
color, r, g, b = core:getServerColor()
inventory = exports.oInventory
chat = exports.oChat

entryPos = {1382.2159423828, -1196.9642333984, 80.638771057129}

defaultOfficePrice = 500000

hotBill = 250

function RealTime(t)
    local time = getRealTime(t)
    local year = time.year
    local month = time.month+1
    local day = time.monthday
    local hours = time.hour
    local minutes = time.minute
    local seconds = time.second
    if(month < 10) then
        month = "0"..month
    end
    if(day < 10) then
        day = "0"..day
    end
    if (hours < 10) then
        hours = "0"..hours
    end
    if (minutes < 10) then
        minutes = "0"..minutes
    end
    if (seconds < 10) then
        seconds = "0"..seconds
    end
    return 1900+year, month, day, hours, minutes, seconds
end

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

firstNames = {
    "James",
    "Junior",
    "Silva", 
    "Robert",
    "Robertson",
}

lastNames = {
    "White",
    "Black",
    "Hudson", 
    "Silver",
    "Gold",
}

rates = {
    "Igényes a munkájára.",
    "Sokszor kedvetlen,\nde munkája kiváló.",
    "Munkája pontos.", 
    "Néha pontatlan,\nde kiváló szakember.",
    "Nem a legjobb szakember,\nde kedves.",
}

takeMoney = {250, 260, 270, 280, 290}