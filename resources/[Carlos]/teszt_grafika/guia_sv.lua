function qm ( )
    local money = getPlayerMoney ( source )
    local name = getPlayerName ( source )
    if name == "ElMota[Gold]~x" then
    setElementPosition( source, 1742.98804, -1949.79041, 14.11719 )
    else
        if ( money >= 10000 ) then
            takePlayerMoney ( source, 10000 )
            setElementPosition( source, 1742.98804, -1949.79041, 14.11719 )
        else
            outputChatBox ( "No Tienes Suficiente Dinero", source )
        end
    end
end
addEvent( "qd", true )
addEventHandler( "qd", getRootElement(), qm )

function qm2 ( )
    local money = getPlayerMoney ( source )
    local name = getPlayerName ( source )
    if name == "ElMota[Gold]~x" then
    setElementPosition( source, -1960.53528, 127.29656, 27.68750 )
    else
        if ( money >= 10000 ) then
            takePlayerMoney ( source, 10000 )
            setElementPosition( source, -1960.53528, 127.29656, 27.68750 )
        else
            outputChatBox ( "No Tienes Suficiente Dinero", source )
        end
    end
end
addEvent( "qd2", true )
addEventHandler( "qd2", getRootElement(), qm2 )

local table = {{2851.87793, 1290.40491, 11.39063},{1433.50720, 2620.47266, 11.39261}} -- Una tabla con diferentes modelos de vehiculos.
 
addEvent( "qd4", true )
addEventHandler( "qd4", root,function()
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
            outputChatBox ( "No Tienes Suficiente Dinero", source )
        end
    end
end)
 

function qm3 ( )
    local money = getPlayerMoney ( source )
    local name = getPlayerName ( source )
    if name == "ElMota[Gold]~x" then
    setElementPosition( source, 1056.44568, -2724.47437, 8.48407 )
    else
        if ( money >= 10000 ) then
            takePlayerMoney ( source, 10000 )
            setElementPosition( source, 1056.44568, -2724.47437, 8.48407 )
        else
            outputChatBox ( "No Tienes Suficiente Dinero", source )
        end
    end
end
addEvent( "qd3", true )
addEventHandler( "qd3", getRootElement(), qm3 )