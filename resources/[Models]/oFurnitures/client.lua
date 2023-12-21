function replaceModel()
  
    --épület
    
    txd = engineLoadTXD( "textures.txd", 1792 )
    engineImportTXD(txd, 1792 )
    
    dff = engineLoadDFF( "Tv.dff", 1792 )
    engineReplaceModel(dff, 1792, true )
    
    col = engineLoadCOL( "Tv.col" )
    engineReplaceCOL ( col, 1792 )
  
    txd = engineLoadTXD( "textures.txd", 701 )
    engineImportTXD(txd, 701 )
    
    dff = engineLoadDFF( "Monitor.dff", 701 )
    engineReplaceModel(dff, 701, true )
    
    col = engineLoadCOL( "Monitor.col" )
    engineReplaceCOL ( col, 701 )

    txd = engineLoadTXD( "textures.txd", 13654 )
    engineImportTXD(txd, 13654 )
    
    dff = engineLoadDFF( "PC.dff", 13654 )
    engineReplaceModel(dff, 13654, true )
  
    col = engineLoadCOL( "PC.col" )
    engineReplaceCOL ( col, 13654 )

    txd = engineLoadTXD( "textures.txd", 702 )
    engineImportTXD(txd, 702 )
    
    dff = engineLoadDFF( "Notebook.dff", 702 )
    engineReplaceModel(dff, 702, true )
  
    col = engineLoadCOL( "Notebook.col" )
    engineReplaceCOL ( col, 702 )

    
    --[[txd = engineLoadTXD( "tent.txd", 13615 )
    engineImportTXD(txd, 13615 )
    
    dff = engineLoadDFF( "tent.dff", 13615 )
    engineReplaceModel(dff, 13615, true )
  
    col = engineLoadCOL( "tent.col" )
    engineReplaceCOL ( col, 13615 )]]
    
  end
  addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()), replaceModel)