local waitingLoads = {}
local allSkins = getValidPedModels()
local availableSkins = {}

for k,v in ipairs(allSkins) do
	availableSkins[v] = true
end

disabledModels = exports.oJSON:loadDataFromJSONFile("loader_disabled_models", false) or {}

local counters = {
    ["object"] = {0,0,0},
    ["skin"] = {0,0,0},
    ["vehicle"] = {0,0,0},
}

local loadedModels = 0
local loadErros = 0

local loadingState = 1
availableLoadingStates = {"textures", "models", "cols", "replace"}

local tick = getTickCount()

font1 = dxCreateFont("p_ba.ttf", 15)
font2 = dxCreateFont("p_li.ttf", 15)

function startModelLoading()
    for k, v in ipairs(models) do 
        engineRestoreModel(v[5])
    end

    for k, v in ipairs(models_objects) do 
        engineRestoreModel(v[5])
    end

    loadBuilding() -- ez ne legyen kikommentezve
    --loadModels() -- ezt ki kell kommentezni
    
    if not getElementData(localPlayer, "user:loggedin") then 
      --  setElementFrozen(localPlayer,true)
        setElementData(localPlayer, "model:isLoading", true)
        outputChatBox(color.."["..serverName.." - ModelLoader]: #ffffffA modellek betöltése elkezdődött!",255,255,255,true)
        outputChatBox(color.."["..serverName.." - ModelLoader]: #ffffffA betöltés ideje alatt nem fogsz tudni bejelentkezni.",255,255,255,true)
    else
        setElementFrozen(localPlayer,true)
        outputChatBox(color.."["..serverName.." - ModelLoader]: #ffffffA modellek betöltése elkezdődött!",255,255,255,true)
        outputChatBox(color.."["..serverName.." - ModelLoader]: #ffffffA betöltés ideje alatt nem fogsz tudni mozogni.",255,255,255,true)
    end
    addEventHandler("onClientRender", root, renderLoadingScreen, true, "low-999")

    loadedModels = 0
end

addCommandHandler("getskins", function()
    if getElementData(localPlayer, "user:admin") >= 9 then
        outputChatBox("Consoleba listázva", 255,255,255)
        local str = ""
        for k,v in pairs(availableSkins) do
            if v then
                str = str..", "..k
            end
        end
        outputConsole("Szabad skinek: "..str)
    end
end)

local loadTick = getTickCount()

addEventHandler("onClientResourceStop", resourceRoot, function()
    for k, v in ipairs(models) do 
        engineRestoreModel(v[5])
    end
end)

addEventHandler("onClientPlayerQuit", localPlayer, function()
    if source == localPlayer then
        for k, v in ipairs(models) do 
            engineRestoreModel(v[5])
        end
    end
end)

local compiler = exports.oCompiler

local nextBuilding, allBuilding = 1, #models_objects
local startTime = nil
function loadBuilding()
    startTime = getTickCount()

    --outputChatBox("load started: "..nextBuilding)
    local v = models_objects[nextBuilding] 
    local folder = v.folder or ""
                    
    if string.len(folder) > 0 then
        folder = folder.."/"
    end

    if v.key then
        local txdFile = "txd.originalmodel"

        if v.txdNotComplied then 
            txdFile = ".txd"
        end

        if v[4] then 
            if not fileExists("models/objects/"..folder..v[4]..txdFile) then
                k = "error"
                outputDebugString("Nem található TXD fájl! (Lista ID:"..k.."; Fájl név:"..v[4]..txdFile.."; Típus: OBJECT)",0,220,0,0)
                loadErros = loadErros + 1
                counters["object"][2] = counters["object"][2] + 1
                return 
            end
        end 

        if not fileExists("models/objects/"..folder..v[3].."dff.originalmodel") then
            outputDebugString("Nem található DFF fájl! (Lista ID:"..(k or 0).."; Fájl név:"..v[3]..".dff; Típus: OBJECT)",0,220,0,0)
            loadErros = loadErros + 1

            counters["object"][2] = counters["object"][2] + 1
            return 
        end

        if not (colLoad_disallowdFolders[v.folder]) then 
            if not fileExists("models/objects/"..folder..v[3].."col.originalmodel") then
                outputDebugString("Nem található COL fájl! (Lista ID:"..k.."; Fájl név:"..v[3]..".dff; Típus: OBJECT)",0,220,0,0)
                loadErros = loadErros + 1

                counters["object"][2] = counters["object"][2] + 1
                return 
            end

            local glass = v.transparent or false

            if v[4] then 
                compiler:loadCompliedModel(v[5], v.key, ":oModelLoader/models/objects/"..folder..v[3].."dff.originalmodel", ":oModelLoader/models/objects/"..folder..v[4]..txdFile, ":oModelLoader/models/objects/"..folder..v[3].."col.originalmodel", glass, _, true)
            else
                compiler:loadCompliedModel(v[5], v.key, ":oModelLoader/models/objects/"..folder..v[3].."dff.originalmodel", _, ":oModelLoader/models/objects/"..folder..v[3].."col.originalmodel", glass, _, true)
            end
        else
            local glass = v.transparent or false

            if v[4] then 
                compiler:loadCompliedModel(v[5], v.key, ":oModelLoader/models/objects/"..folder..v[3].."dff.originalmodel", ":oModelLoader/models/objects/"..folder..v[4]..txdFile, _, glass, _, true)
            else
                compiler:loadCompliedModel(v[5], v.key, ":oModelLoader/models/objects/"..folder..v[3].."dff.originalmodel", _, _, glass, _, true)
            end
        end
    end

    counters["object"][1] = counters["object"][1] +1
end

addEvent("modelLoader > buildingLoaded", true)
addEventHandler("modelLoader > buildingLoaded", root, function()
    --outputChatBox("load completed: "..getTickCount()-startTime.."ms")
    nextBuilding = nextBuilding + 1

    if nextBuilding == allBuilding then 
        --outputChatBox("minden épület betöltve")
        setTimer(loadModels, 3000, 1)

    else
        loadBuilding()
    end
end)

function loadModels()

    nextWaitingTime = 0

    setTimer(function()
        for k, v in ipairs(models) do 
            if not core:tableContains(disabledModels, v[5]) then
                nextWaitingTime = nextWaitingTime + math.random(waiting_time * 0.8, waiting_time)

                setTimer(function() 
                    tick = getTickCount()

                    loadTick = getTickCount()
                    if v[2] == "object" then 
                        local folder = v.folder or ""
                        
                        if string.len(folder) > 0 then
                            folder = folder.."/"
                        end
        
                        if v.key then
                            -- átrakva máshova
                        else
                            if fileExists("models/objects/"..folder..v[4]..".txd") then
                                local txd = engineLoadTXD("models/objects/"..folder..v[4]..".txd")
                                if not engineImportTXD(txd, v[5]) then 
                                    outputDebugString("Ismeretlen hiba a TXD fájl betöltése közben! :( (Lista ID:"..k.."; Fájl név:"..v[4]..".txd; Típus: OBJ)",0,200,0,0)
                                    loadErros = loadErros + 1

                                    counters["skin"][3] = counters["skin"][3] + 1
                                    return 
                                end
                            else
                                outputDebugString("Nem található TXD fájl! (Lista ID:"..k.."; Fájl név:"..v[4]..".txd; Típus: SKIN)",0,220,0,0)
                                loadErros = loadErros + 1

                                counters["skin"][2] = counters["skin"][2] + 1
                                return 
                            end
            
                            if fileExists("models/objects/"..folder..v[3]..".dff") then
                                local dff = engineLoadDFF("models/objects/"..folder..v[3]..".dff")
                                if not engineReplaceModel(dff, v[5]) then 
                                    outputDebugString("Ismeretlen hiba a DFF fájl betöltése közben! :( (Lista ID:"..k.."; Fájl név:"..v[3]..".dff; Típus: OBJ)",0,200,0,0)
                                    loadErros = loadErros + 1

                                    counters["skin"][3] = counters["skin"][3] + 1
                                    return 
                                end
                            else
                                outputDebugString("Nem található DFF fájl! (Lista ID:"..k.."; Fájl név:"..v[3]..".dff; Típus: SKIN)",0,220,0,0)
                                loadErros = loadErros + 1

                                counters["skin"][2] = counters["skin"][2] + 1
                                return 
                            end
                        end
        
                        counters["object"][1] = counters["object"][1] +1

                    elseif v[2] == "skin" then 
                        if fileExists("models/skins/"..v[4]..".txd") then
                            local txd = engineLoadTXD("models/skins/"..v[4]..".txd")
                            if not engineImportTXD(txd, v[5]) then 
                                outputDebugString("Ismeretlen hiba a TXD fájl betöltése közben! :( (Lista ID:"..k.."; Fájl név:"..v[4]..".txd; Típus: SKIN)",0,200,0,0)
                                loadErros = loadErros + 1

                                counters["skin"][3] = counters["skin"][3] + 1
                                return 
                            end
                        else
                            outputDebugString("Nem található TXD fájl! (Lista ID:"..k.."; Fájl név:"..v[4]..".txd; Típus: SKIN)",0,220,0,0)
                            loadErros = loadErros + 1

                            counters["skin"][2] = counters["skin"][2] + 1
                            return 
                        end
        
                        if fileExists("models/skins/"..v[3]..".dff") then
                            local dff = engineLoadDFF("models/skins/"..v[3]..".dff")
                            if not engineReplaceModel(dff, v[5]) then 
                                outputDebugString("Ismeretlen hiba a DFF fájl betöltése közben! :( (Lista ID:"..k.."; Fájl név:"..v[3]..".dff; Típus: SKIN)",0,200,0,0)
                                loadErros = loadErros + 1

                                counters["skin"][3] = counters["skin"][3] + 1
                                return 
                            end
                        else
                            outputDebugString("Nem található DFF fájl! (Lista ID:"..k.."; Fájl név:"..v[3]..".dff; Típus: SKIN)",0,220,0,0)
                            loadErros = loadErros + 1

                            counters["skin"][2] = counters["skin"][2] + 1
                            return 
                        end
                        availableSkins[v[5]] = false
                        --outputDebugString("Skin: "..v[3].." betöltése sikeres!",0,0,220,0)
                        counters["skin"][1] = counters["skin"][1] +1
                    elseif v[2] == "vehicle" then 
                        loadVehicle(v[4], v[3], v[5])
                        counters["vehicle"][1] = counters["vehicle"][1] +1
                    else
                        outputDebugString("Ismeretlen modell típus! (Lista ID:"..k.."; Típus:"..v[2]..")",0,200,0,0)
                        loadErros = loadErros + 1

                    end
                    loadedModels = loadedModels + 1
                end, nextWaitingTime, 1)
            end
        end
    
        --setTimer(loadEnd, nextWaitingTime,1)
    end, 1000, 1)
end

function loadVehicle(txd_, dff_, model_)
    if fileExists("models/vehicles/"..txd_..".txd") then
        local txd = engineLoadTXD("models/vehicles/"..txd_..".txd")
        if not engineImportTXD(txd, model_) then 
            outputDebugString("Ismeretlen hiba a TXD fájl betöltése közben! :( (Lista ID:"..k.."; Fájl név:"..txd_..".txd; Típus: VEHICLE)",0,200,0,0)
            loadErros = loadErros + 1

            counters["vehicle"][3] = counters["vehicle"][3] + 1
            return 
        end
    else
        outputDebugString("Nem található TXD fájl! (Lista ID:"..k.."; Fájl név:"..txd_..".txd; Típus: VEHICLE)",0,220,0,0)
        loadErros = loadErros + 1

        counters["vehicle"][2] = counters["vehicle"][2] + 1
        return 
    end

    if fileExists("models/vehicles/"..dff_..".dff") then
        local dff = engineLoadDFF("models/vehicles/"..dff_..".dff")
        if not engineReplaceModel(dff, model_) then 
            outputDebugString("Ismeretlen hiba a DFF fájl betöltése közben! :( (Lista ID:"..k.."; Fájl név:"..dff_..".dff; Típus: VEHICLE)",0,200,0,0)
            loadErros = loadErros + 1

            counters["vehicle"][3] = counters["vehicle"][3] + 1
            return 
        end
    else
        outputDebugString("Nem található DFF fájl! (Lista ID:"..k.."; Fájl név:"..dff_..".dff; Típus: VEHICLE)",0,220,0,0)
        loadErros = loadErros + 1

        counters["vehicle"][2] = counters["vehicle"][2] + 1
        return 
    end

    --outputDebugString("Jármű: "..v[3].." betöltése sikeres!",0,0,220,0)

end

function loadEnd()
    removeEventHandler("onClientRender", root, renderLoadingScreen)

    displayAllModelInfo()
    compiler:clearTXDCache()

    if not getElementData(localPlayer, "user:loggedin") then 
        outputChatBox(" ")
        outputChatBox(color.."["..serverName.." - ModelLoader]: #ffffffA modellek betöltése befejeződött!",255,255,255,true)
        outputChatBox(color.."["..serverName.." - ModelLoader]: #ffffffMost már bejelentkezhetsz!",255,255,255,true)
        exports.oInfobox:outputInfoBox("A modellek betöltése befejeződött!","info")
        exports.oInfobox:outputInfoBox("Most már bejelentkezhetsz!","info")
        outputChatBox(" ")
      --  outputChatBox(color.."["..serverName.." - ModelLoader]: #ffffffMostantól újra tudsz mozogni.",255,255,255,true)
        setElementData(localPlayer, "model:isLoading", false)
    else
        setElementFrozen(localPlayer,false)
        outputChatBox(" ")
        outputChatBox(color.."["..serverName.." - ModelLoader]: #ffffffA modellek betöltése befejeződött!",255,255,255,true)
        outputChatBox(color.."["..serverName.." - ModelLoader]: #ffffffMost már újra tudsz mozogni!",255,255,255,true)
        exports.oInfobox:outputInfoBox("A modellek betöltése befejeződött!","info")
        exports.oInfobox:outputInfoBox("Most már újra tudsz mozogni!","info")
    end

end

function displayAllModelInfo()
    outputDebugString("Összegzés:",0,50, 135, 168)
    outputDebugString(" Skin betöltések:",0,81, 171, 207)
    outputDebugString(" ~ Sikeres skin betöltések: " .. counters["skin"][1].. " db",0,154, 189, 109)
    outputDebugString(" ~ Sikertelen skin betöltések (Nem található fájl): " .. counters["skin"][2].. " db",0,201, 124, 89)
    outputDebugString(" ~ Sikertelen skin betöltések (Ismeretlen hiba): " ..counters["skin"][3] .." db",0,201, 124, 89)

    outputDebugString(" Object betöltések:",0,81, 171, 207)
    outputDebugString(" ~ Sikeres object betöltések: " .. counters["object"][1].. " db",0,154, 189, 109)
    outputDebugString(" ~ Sikertelen object betöltések (Nem található fájl): " .. counters["object"][2].. " db",0,201, 124, 89)
    outputDebugString(" ~ Sikertelen object betöltések (Ismeretlen hiba): " ..counters["object"][3] .." db",0,201, 124, 89)

    outputDebugString(" Jármű betöltések:",0,81, 171, 207)
    outputDebugString(" ~ Sikeres jármű betöltések: " .. counters["vehicle"][1].. " db",0,154, 189, 109)
    outputDebugString(" ~ Sikertelen jármű betöltések (Nem található fájl): " .. counters["vehicle"][2].. " db",0,201, 124, 89)
    outputDebugString(" ~ Sikertelen jármű betöltések (Ismeretlen hiba): " ..counters["vehicle"][3] .." db",0,201, 124, 89)
end

sx, sy = guiGetScreenSize()
myX, myY = 1600, 900 
local font = exports.oFont

local cubeOpacity = {0.2, 0.4, 0.6, 0.8, 0.9}
local cubeStates = {false, false, false, false, false}
local cubeTicks = {getTickCount(), getTickCount() + 200, getTickCount() + 400, getTickCount() + 600, getTickCount() + 800}

function renderLoadingScreen()
    dxDrawRectangle(0, 0, sx, sy, tocolor(30, 30, 30, 220), true)
    
    local startX = sx/2 - (2.5 * 25/myX*sx)
    for i = 1, 5 do 

        if cubeStates[i] then 
            cubeOpacity[i] = interpolateBetween(cubeOpacity[i], 0, 0, 0, 0, 0, (getTickCount() - cubeTicks[i]) / 1500 * i, "Linear")
        else
            cubeOpacity[i] = interpolateBetween(cubeOpacity[i], 0, 0, 1, 0, 0, (getTickCount() - cubeTicks[i]) / 1500 * i, "Linear")
        end

        if cubeOpacity[i] == 1 or cubeOpacity[i] == 0 then 
            if cubeTicks[i] + 100 < getTickCount() then
                cubeStates[i] = not cubeStates[i]
                cubeTicks[i] = getTickCount()
            end
        end

        dxDrawRectangle(startX, sy*0.49, 20/myX*sx, 20/myX*sx, tocolor(r, g, b, 255 * cubeOpacity[i]), true)
        startX = startX + 25/myX*sx
    end

    dxDrawText("Modellek betöltése folyamatban...", 0, sy*0.52, sx, sy, tocolor(255, 255, 255, 255), 1/myX*sx, font1, "center", "top", false, false, true)
    dxDrawText(math.floor((loadedModels / (#models - #disabledModels))*100).."%", 0, sy*0.54, sx, sy, tocolor(255, 255, 255, 150), 1/myX*sx, font2, "center", "top", false, false, true)
    --dxDrawText(loadedModels .. " | "..#models, 0, sy*0.58, sx, sy, tocolor(255, 255, 255, 150), 1/myX*sx, font2, "center", "top", false, false, true)

    
    if loadedModels == ((#models - loadErros) - #disabledModels) then 
        loadEnd()
    end

     --dxDrawRectangle(0, sy*0.985, sx * interpolateBetween(((loadedModels - 1) / #models), 0, 0, (loadedModels / #models), 0, 0, (getTickCount() - tick) / 100, "Linear"), sy*0.1, tocolor(r, g, b, 200), true)
    --dxDrawText("Modellek betöltése folyamatban: "..math.floor((loadedModels / #models)*100).."%", 0, sy*0.985, sx * interpolateBetween(((loadedModels - 1) / #models), 0, 0, (loadedModels / #models), 0, 0, (getTickCount() - tick) / 100, "Linear") - sx*0.005,  sy*0.985+sy*0.015, tocolor(255, 255, 255, 255), 0.6/myX*sx, font:getFont("condensed", 12), "right", "center", false, false, true)
end

--loadEnd()

startModelLoading()

addEventHandler("onClientResourceStop", resourceRoot, function()
    for k, v in pairs(models) do 
        engineFreeModel(v[5])
    end
end)
