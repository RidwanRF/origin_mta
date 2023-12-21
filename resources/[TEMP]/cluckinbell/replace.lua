txd = engineLoadTXD ("models/cluckinbell_3d.txd", 5168)
engineImportTXD(txd, 5168)
dff = engineLoadDFF ("models/cluckinbell_3d.dff", 5168)
engineReplaceModel(dff, 5168, true)
col = engineLoadCOL("models/cluckinbell_3d.col")
engineReplaceCOL(col, 5168)

setOcclusionEnabled ( false )