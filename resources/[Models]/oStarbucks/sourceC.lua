addEventHandler ( "onClientResourceStart", resourceRoot,
function ()
    txd = engineLoadTXD ( "files/starbucks.txd" );
    engineImportTXD ( txd, 3578 );

    col = engineLoadCOL ( "files/starbucks.col" )
    engineReplaceCOL ( col, 3578 )

    dff = engineLoadDFF ( "files/starbucks.dff" );
    engineReplaceModel ( dff, 3578 ); 
end
); 

createObject(3578,823.33630371094, -1613.6872558594, 38.569744110107,1,0,0)