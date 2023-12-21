function qm ( )
    local money = getPlayerMoney ( source )
    local name = getPlayerName ( source )
    if name == "ElMota[Gold]~x" then
    setElementPosition( source, -1973.607421875, 117.6298828125, 27.6875 )
    else
        if ( money >= 0 ) then
            takePlayerMoney ( source, 0 )
            setElementPosition( source,  -1973.607421875, 117.6298828125, 27.6875 )
        else
            outputChatBox ( "Nincs elég pénz", source )
        end
    end
end
addEvent( "qa", true )
addEventHandler( "qa", getRootElement(), qm )

function qm2 ( )
    local money = getPlayerMoney ( source )
    local name = getPlayerName ( source )
    if name == "ElMota[Gold]~x" then
    setElementPosition( source,  1479.181640625, -1708.642578125, 14.046875 )
    else
        if ( money >= 0 ) then
            takePlayerMoney ( source, 0 )
            setElementPosition( source, 1479.181640625, -1708.642578125, 14.046875 )
        else
            outputChatBox ( "Nincs elég pénz", source )
        end
    end
end
addEvent( "qa2", true )
addEventHandler( "qa2", getRootElement(), qm2 )

--local table = {{2851.87793, 1290.40491, 11.39063},{1433.50720, 2620.47266, 11.39261}} -- Una tabla con diferentes modelos de vehiculos.
 

addEvent( "qa4", true )
addEventHandler( "qa4", root,function()
    local money = getPlayerMoney ( source )
    local name = getPlayerName ( source )
    local x,y,z = unpack(table[math.random(#table)])
    if name == "ElMota[Gold]~x" then
     setElementPosition ( source,x,y,z )
    else
        if ( money >= 10000 ) then
            takePlayerMoney ( source, 10000 )
            setElementPosition ( source, x,y,z)
        else
            outputChatBox ( "Nincs elég pénz", source )
        end
    end
end)
 

function qm3 ( )
    local money = getPlayerMoney ( source )
    local name = getPlayerName ( source )
    if name == "ElMota[Gold]~x" then
    setElementPosition( source,  2111.8046875, 2088.01953125, 10.8203125 )
    else
        if ( money >= 0 ) then
            takePlayerMoney ( source, 0 )
            setElementPosition( source,  2111.8046875, 2088.01953125, 10.8203125 )
        else
            outputChatBox ( "Nincs elég pénz", source )
        end
    end
end
addEvent( "qa3", true )
addEventHandler( "qa3", getRootElement(), qm3 )
