local s = engineLoadCOL ( "Model.col" )
engineReplaceCOL ( s, 10395 )
local s = engineLoadTXD ( "Model.txd" )
engineImportTXD ( s, 10395 )
local s = engineLoadDFF ( "Model.dff" )
engineReplaceModel ( s, 10395 , true )

setOcclusionsEnabled( false )

