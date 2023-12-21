local objids={1776, 1775}

for i,v in ipairs(objids) do
	TXD = engineLoadTXD( v..".txd" ) 
    engineImportTXD( TXD, v )
    DFF = engineLoadDFF( v..".dff", 0) 
    engineReplaceModel( DFF, v )
end

