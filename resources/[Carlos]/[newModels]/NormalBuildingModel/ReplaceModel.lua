local s = engineLoadCOL ( "Model.col" )
engineReplaceCOL ( s, 7494 )
local s = engineLoadTXD ( "Model.txd" )
engineImportTXD ( s, 7494 )
local s = engineLoadDFF ( "Model.dff" )
engineReplaceModel ( s, 7494, true )

local s = engineLoadTXD ( "Model.txd" )
engineImportTXD ( s, 7669 )
local s = engineLoadDFF ( "Model.dff" )
engineReplaceModel ( s, 7669, true )

setOcclusionsEnabled( false )
