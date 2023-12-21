local txd =	engineLoadTXD("tunin.txd")
			engineImportTXD(txd, 5397)
local dff = engineLoadDFF("tunin.dff", 5397)
			engineReplaceModel(dff, 5397, true)
local col = engineLoadCOL ("tunin.col" )
			engineReplaceCOL ( col, 5397)


			createObject(5397, 1924.4473876953, -1716.3414306641, 99.586517333984)