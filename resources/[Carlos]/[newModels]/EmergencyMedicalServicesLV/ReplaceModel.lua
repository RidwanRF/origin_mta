local s = engineLoadCOL ( "Model.col" )
engineReplaceCOL ( s, 8495 )
local s = engineLoadTXD ( "Model.txd" )
engineImportTXD ( s, 8495 )
local s = engineLoadDFF ( "Model.dff" )
engineReplaceModel ( s, 8495, true )

setOcclusionsEnabled( false )
