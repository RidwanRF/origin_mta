txd = engineLoadTXD ("models/gun_para.txd", 5168)
engineImportTXD(txd, 5168)
dff = engineLoadDFF ("models/gun_para.dff", 5168)
engineReplaceModel(dff, 5168, true)

local obj = createObject(5168, 2355.4165039062,-1724.935546875,13.53907585144)
setElementCollisionsEnabled(obj, false)
exports.oBone:attachElementToBone(obj, localPlayer, 4, 0, 0.33, 0.155, -90, 0, 0)

setOcclusionEnabled ( false )