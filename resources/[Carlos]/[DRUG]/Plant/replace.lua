txd = engineLoadTXD ("models/model.txd", 14672) 
dff = engineLoadDFF ("models/model.dff", 14672) 
col = engineLoadCOL ("models/model.col") 
engineImportTXD(txd, 14672)
engineReplaceModel(dff, 14672, true)
engineReplaceCOL(col,14672)

txd = engineLoadTXD ("models/model.txd", 1830) 
dff = engineLoadDFF ("models/plant01.dff", 1830) 
col = engineLoadCOL ("models/plant.col") 
engineImportTXD(txd, 1830)
engineReplaceModel(dff, 1830)
engineReplaceCOL(col,1830)

txd = engineLoadTXD ("models/model.txd", 1831) 
dff = engineLoadDFF ("models/plant02.dff", 1831) 
col = engineLoadCOL ("models/plant.col") 
engineImportTXD(txd, 1831)
engineReplaceModel(dff, 1831)
engineReplaceCOL(col,1831)

txd = engineLoadTXD ("models/model.txd", 1832) 
dff = engineLoadDFF ("models/plant03.dff", 1832) 
col = engineLoadCOL ("models/plant.col") 
engineImportTXD(txd, 1832)
engineReplaceModel(dff, 1832)
engineReplaceCOL(col,1832)

txd = engineLoadTXD ("models/model.txd", 1833) 
dff = engineLoadDFF ("models/plant04.dff", 1833) 
col = engineLoadCOL ("models/plant.col") 
engineImportTXD(txd, 1833)
engineReplaceModel(dff, 1833)
engineReplaceCOL(col,1833)

txd = engineLoadTXD ("models/model.txd", 2091) 
dff = engineLoadDFF ("models/gate.dff", 2091) 
col = engineLoadCOL ("models/gate.col") 
engineImportTXD(txd, 2091)
engineReplaceModel(dff, 2091)
engineReplaceCOL(col,2091)

txd = engineLoadTXD ("models/model.txd", 14814) 
dff = engineLoadDFF ("models/craftingtable.dff", 14814) 
col = engineLoadCOL ("models/craftingtable.col") 
engineImportTXD(txd, 14814)
engineReplaceModel(dff, 14814)
engineReplaceCOL(col,14814)

txd = engineLoadTXD ("models/model.txd", 2153) 
dff = engineLoadDFF ("models/laptop.dff", 2153) 
col = engineLoadCOL ("models/laptop.col") 
engineImportTXD(txd, 2153)
engineReplaceModel(dff, 2153)
engineReplaceCOL(col,2153)


setOcclusionsEnabled( false )






  


