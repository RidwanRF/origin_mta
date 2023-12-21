local s = engineLoadCOL ( "Model.col" )
engineReplaceCOL ( s, 10505 )
local s = engineLoadTXD ( "Model.txd" )
engineImportTXD ( s, 10505 )
local s = engineLoadDFF ( "Model.dff" )
engineReplaceModel ( s, 10505, true )

local s = engineLoadTXD ( "Model.txd" )
engineImportTXD ( s, 10505 )
local s = engineLoadDFF ( "Model.dff" )
engineReplaceModel ( s, 10505, true )

setOcclusionsEnabled( false )

