local fileSizes = {}


local panelScroll = 0
function renderModpanel()
    core:drawWindow(sx*0.4, sy*0.2, sx*0.2, sy*0.497, "Modpanel", 1)

    local startY = sy*0.225

    for i = 1, 11 do
        v = modelsForPanel[i + panelScroll] 

        dxDrawRectangle(sx*0.402, startY, sx*0.2 - sx*0.008, sy*0.04, tocolor(30, 30, 30, 200))
        dxDrawText(exports.oVehicle:getModdedVehName(v[5]), sx*0.404, startY + sy*0.005, sx*0.404 + sx*0.2 - sx*0.008, startY + sy*0.005 + sy*0.04, tocolor(255, 255, 255, 255), 0.8/myX*sx, font1, "left", "top", false, false, true)
        dxDrawText("GTA SA Model: "..color..getVehicleNameFromModel(v[5]).." #ffffff| Model méret: "..color..(fileSizes[v[5]] or 0).."mb", sx*0.404, startY, sx*0.404 + sx*0.2 - sx*0.008, startY + sy*0.04, tocolor(255, 255, 255, 150), 0.7/myX*sx, font2, "left", "bottom", false, false, false, true)
        if core:tableContains(disabledModels, v[5]) then 
            core:dxDrawButton(sx*0.4 + sx*0.2 - sx*0.052, startY + sy*0.002, sx*0.045, sy*0.02, 235, 64, 52, 200, "Kikapcsolva", tocolor(255, 255, 255, 255), 0.6/myX*sx, font1)
        else
            core:dxDrawButton(sx*0.4 + sx*0.2 - sx*0.052, startY + sy*0.002, sx*0.045, sy*0.02, r, g, b, 200, "Bekapcsolva", tocolor(255, 255, 255, 255), 0.6/myX*sx, font1)
        end
        startY = startY + sy*0.042
    end

    core:dxDrawScrollbar(sx*0.4 + sx*0.195, sy*0.225, sx*0.002, sy*0.465, modelsForPanel, panelScroll, 11, r, g, b, 1, false)

    core:dxDrawButton(sx*0.4, sy*0.7, sx*0.09, sy*0.04, 235, 64, 52, 200, "Összes kikapcsolása", tocolor(255, 255, 255, 255), 0.7/myX*sx, font1)
    core:dxDrawButton(sx*0.51, sy*0.7, sx*0.09, sy*0.04, r, g, b, 200, "Összes bekapcsolása", tocolor(255, 255, 255, 255), 0.7/myX*sx, font1)
end 

local lastClick = 0

function modpanelKey(key, state)

    if state then 
        if key == "mouse_wheel_down" then 
            if modelsForPanel[panelScroll + 12] then
                panelScroll = panelScroll + 1
            end
        elseif key == "mouse_wheel_up" then
            if panelScroll > 0 then 
                panelScroll = panelScroll - 1
            end
        elseif key == "mouse1" then 
            local startY = sy*0.225
            for i = 1, 11 do
                v = modelsForPanel[i + panelScroll] 

                if core:isInSlot(sx*0.4 + sx*0.2 - sx*0.052, startY + sy*0.002, sx*0.045, sy*0.02) then
                    if lastClick + 1000 < getTickCount(  ) then
                        if core:tableContains(disabledModels, v[5]) then 
                            for i = 1, #disabledModels do 
                                if disabledModels[i] == v[5] then 
                                    table.remove(disabledModels, i)
                                    loadVehicle(v[4], v[3], v[5])
                                    lastClick = getTickCount(  )
                                    break
                                end
                            end
                        else
                            table.insert(disabledModels, v[5])
                            engineRestoreModel(v[5])
                            lastClick = getTickCount(  )
                        end

                        exports.oJSON:saveDataToJSONFile(disabledModels, "loader_disabled_models", false)
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Modpanel", 2).."Várj még egy kicsit!", 255, 255, 255, true)
                    end
                end

                startY = startY + sy*0.042
            end

            if core:isInSlot(sx*0.4, sy*0.7, sx*0.09, sy*0.04) then
                if lastClick + 2000 < getTickCount(  ) then
                    disabledModels = {}
                    for k, v in ipairs(modelsForPanel) do 
                        table.insert(disabledModels, v[5])
                        engineRestoreModel(v[5])
                    end

                    lastClick = getTickCount(  )
                    exports.oJSON:saveDataToJSONFile(disabledModels, "loader_disabled_models", false)
                else 
                    outputChatBox(core:getServerPrefix("red-dark", "Modpanel", 2).."Várj még egy kicsit!", 255, 255, 255, true)
                end
            end

            if core:isInSlot(sx*0.51, sy*0.7, sx*0.09, sy*0.04) then
                if lastClick + 2000 < getTickCount(  ) then
                    if #disabledModels > 0 then
                        for i = 1, #modelsForPanel do 
                            v = modelsForPanel[i]
                            loadVehicle(v[4], v[3], v[5])
                        end
                        disabledModels = {}

                        lastClick = getTickCount(  )
                        exports.oJSON:saveDataToJSONFile(disabledModels, "loader_disabled_models", false)
                    end
                else 
                    outputChatBox(core:getServerPrefix("red-dark", "Modpanel", 2).."Várj még egy kicsit!", 255, 255, 255, true)
                end
            end
        elseif key == "backspace" then 
            closePanel()
        end
    end
end

local panelOpened = false
function openPanel()
    if panelOpened then 
        closePanel()
        return
    end

    if getPedOccupiedVehicle(localPlayer) then outputChatBox(core:getServerPrefix("red-dark", "Modpanel", 2).."Járműben nem használhatod!", 255, 255, 255, true) return end 
    panelOpened = true
    for k, v in ipairs(modelsForPanel) do 
        local dff, txd = fileOpen("models/vehicles/"..v[3]..".dff"), fileOpen("models/vehicles/"..v[3]..".txd")
        local fileSize = fileGetSize(dff) + fileGetSize(txd)
        fileSize = math.floor(fileSize/100000)
        fileSizes[v[5]] = fileSize/10
        fileClose(dff)
        fileClose(txd)
    end

    addEventHandler("onClientRender", root, renderModpanel)
    addEventHandler("onClientKey", root, modpanelKey)
end

function closePanel()
    panelOpened = false
    removeEventHandler("onClientRender", root, renderModpanel)
    removeEventHandler("onClientKey", root, modpanelKey)
end

addCommandHandler("modpanel", openPanel)