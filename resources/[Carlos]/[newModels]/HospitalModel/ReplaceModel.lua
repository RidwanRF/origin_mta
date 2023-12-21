local s = engineLoadCOL ( "Model.col" )
engineReplaceCOL ( s, 16564 )
local s = engineLoadTXD ( "Model.txd" )
engineImportTXD ( s, 16564 )
local s = engineLoadDFF ( "Model.dff" )
engineReplaceModel ( s, 16564, true )

setOcclusionsEnabled( false )

