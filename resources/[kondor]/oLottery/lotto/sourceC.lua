local showLottoPanel = false

sx, sy = guiGetScreenSize();
zoom = math.min(1,0.75 + (sx - 1024) * (1 - 0.75) / (1600 - 1024))
function res(value) return value * zoom end
function resFont(value) return math.floor(res(value)) end

local lottoGuiName1 = GuiEdit(-1000, -1000, 0, 0, "", false)
lottoGuiName1.maxLength = 2
local activatedBoxes1 = {lottoGuiName1}
local defaultBoxText1 = {"Gépeld be a számot!"}

local lottoGuiName2 = GuiEdit(-1000, -1000, 0, 0, "", false)
lottoGuiName2.maxLength = 2
local activatedBoxes2 = {lottoGuiName2}
local defaultBoxText2 = {"Gépeld be a számot!"}

local lottoGuiName3 = GuiEdit(-1000, -1000, 0, 0, "", false)
lottoGuiName3.maxLength = 2
local activatedBoxes3 = {lottoGuiName3}
local defaultBoxText3 = {"Gépeld be a számot!"}

local lottoGuiName4 = GuiEdit(-1000, -1000, 0, 0, "", false)
lottoGuiName4.maxLength = 2
local activatedBoxes4 = {lottoGuiName4}
local defaultBoxText4 = {"Gépeld be a számot!"}

local lottoGuiName5 = GuiEdit(-1000, -1000, 0, 0, "", false)
lottoGuiName5.maxLength = 2
local activatedBoxes5 = {lottoGuiName5}
local defaultBoxText5 = {"Gépeld be a számot!"}

local defaultPanel = 0

function getFont(name, size)
    return exports.oFont:getFont(name, size)
end

function drawText(text, x, y, w, h, ...)
    if not text or not x or not y or not w or not h then return false end
    return dxDrawText(text, x, y, (x + w), (y + h), ...)
end

function renderLottoPanel()
    if defaultPanel == 0 then    
        local panelSize = Vector2(res(300),res(400))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        
        exports.oCore:drawWindow(panelPos.x,panelPos.y,panelSize.x,panelSize.y, color.."Original#ffffffRoleplay - #7cc576Lottózó", 1)
        exports.oCore:dxDrawButton(panelPos.x+res(52),panelPos.y+res(350),res(200),res(20), 182, 36, 36, 170, "Kilépés", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        exports.oCore:dxDrawButton(panelPos.x+res(52),panelPos.y+res(320),res(200),res(20), r, g, b, 170, "Kezdés", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        drawText("A játékhoz 5 darab számot kell választanod,\n melyek 1 és 90 között vannak!\n\nA játék ára: 500$", panelPos.x,panelPos.y+res(150),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
    end
end

function renderLottoPanel1()
    if defaultPanel == 1 then    
        local panelSize = Vector2(res(300),res(400))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        
        exports.oCore:drawWindow(panelPos.x,panelPos.y,panelSize.x,panelSize.y, color.."Original#ffffffRoleplay - #7cc576Lottózó", 1)
        exports.oCore:dxDrawButton(panelPos.x+res(52),panelPos.y+res(350),res(200),res(20), 182, 36, 36, 170, "Kilépés", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        exports.oCore:dxDrawButton(panelPos.x+res(52),panelPos.y+res(320),res(200),res(20), r, g, b, 170, "Következő", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        drawText("Válassz egy számot, 1-től 90-ig!", panelPos.x,panelPos.y+res(70),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        drawText("1. szám", panelPos.x,panelPos.y+res(90),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")

        if core:isInSlot(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25)) then
            dxDrawRectangle(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25),tocolor(45,45,45,255))
        else
            dxDrawRectangle(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25),tocolor(40,40,40,255))
        end

        if activatedBoxes1[1].text == "" then
            drawText(defaultBoxText1[1], panelPos.x,panelPos.y+res(150),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        else
            drawText(activatedBoxes1[1].text, panelPos.x,panelPos.y+res(150),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        end
    end
end

function renderLottoPanel2()
    if defaultPanel == 2 then    
        local panelSize = Vector2(res(300),res(400))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        
        exports.oCore:drawWindow(panelPos.x,panelPos.y,panelSize.x,panelSize.y, color.."Original#ffffffRoleplay - #7cc576Lottózó", 1)
        exports.oCore:dxDrawButton(panelPos.x+res(52),panelPos.y+res(350),res(200),res(20), 182, 36, 36, 170, "Kilépés", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        exports.oCore:dxDrawButton(panelPos.x+res(52),panelPos.y+res(320),res(200),res(20), r, g, b, 170, "Következő", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        drawText("Válassz egy számot, 1-től 90-ig!", panelPos.x,panelPos.y+res(70),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        drawText("2. szám", panelPos.x,panelPos.y+res(90),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")

        if core:isInSlot(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25)) then
            dxDrawRectangle(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25),tocolor(45,45,45,255))
        else
            dxDrawRectangle(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25),tocolor(40,40,40,255))
        end

        if activatedBoxes2[1].text == "" then
            drawText(defaultBoxText2[1], panelPos.x,panelPos.y+res(150),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        else
            drawText(activatedBoxes2[1].text, panelPos.x,panelPos.y+res(150),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        end
    end
end

function renderLottoPanel3()
    if defaultPanel == 3 then    
        local panelSize = Vector2(res(300),res(400))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        
        exports.oCore:drawWindow(panelPos.x,panelPos.y,panelSize.x,panelSize.y, color.."Original#ffffffRoleplay - #7cc576Lottózó", 1)
        exports.oCore:dxDrawButton(panelPos.x+res(52),panelPos.y+res(350),res(200),res(20), 182, 36, 36, 170, "Kilépés", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        exports.oCore:dxDrawButton(panelPos.x+res(52),panelPos.y+res(320),res(200),res(20), r, g, b, 170, "Következő", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        drawText("Válassz egy számot, 1-től 90-ig!", panelPos.x,panelPos.y+res(70),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        drawText("3. szám", panelPos.x,panelPos.y+res(90),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")

        if core:isInSlot(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25)) then
            dxDrawRectangle(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25),tocolor(45,45,45,255))
        else
            dxDrawRectangle(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25),tocolor(40,40,40,255))
        end

        if activatedBoxes3[1].text == "" then
            drawText(defaultBoxText3[1], panelPos.x,panelPos.y+res(150),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        else
            drawText(activatedBoxes3[1].text, panelPos.x,panelPos.y+res(150),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        end
    end
end

function renderLottoPanel4()
    if defaultPanel == 4 then    
        local panelSize = Vector2(res(300),res(400))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        
        exports.oCore:drawWindow(panelPos.x,panelPos.y,panelSize.x,panelSize.y, color.."Original#ffffffRoleplay - #7cc576Lottózó", 1)
        exports.oCore:dxDrawButton(panelPos.x+res(52),panelPos.y+res(350),res(200),res(20), 182, 36, 36, 170, "Kilépés", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        exports.oCore:dxDrawButton(panelPos.x+res(52),panelPos.y+res(320),res(200),res(20), r, g, b, 170, "Következő", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        drawText("Válassz egy számot, 1-től 90-ig!", panelPos.x,panelPos.y+res(70),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        drawText("4. szám", panelPos.x,panelPos.y+res(90),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")

        if core:isInSlot(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25)) then
            dxDrawRectangle(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25),tocolor(45,45,45,255))
        else
            dxDrawRectangle(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25),tocolor(40,40,40,255))
        end

        if activatedBoxes4[1].text == "" then
            drawText(defaultBoxText4[1], panelPos.x,panelPos.y+res(150),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        else
            drawText(activatedBoxes4[1].text, panelPos.x,panelPos.y+res(150),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        end
    end
end

function renderLottoPanel5()
    if defaultPanel == 5 then    
        local panelSize = Vector2(res(300),res(400))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        
        exports.oCore:drawWindow(panelPos.x,panelPos.y,panelSize.x,panelSize.y, color.."Original#ffffffRoleplay - #7cc576Lottózó", 1)
        exports.oCore:dxDrawButton(panelPos.x+res(52),panelPos.y+res(350),res(200),res(20), 182, 36, 36, 170, "Kilépés", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        exports.oCore:dxDrawButton(panelPos.x+res(52),panelPos.y+res(320),res(200),res(20), r, g, b, 170, "Következő", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        drawText("Válassz egy számot, 1-től 90-ig!", panelPos.x,panelPos.y+res(70),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        drawText("5. szám", panelPos.x,panelPos.y+res(90),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")

        if core:isInSlot(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25)) then
            dxDrawRectangle(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25),tocolor(45,45,45,255))
        else
            dxDrawRectangle(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25),tocolor(40,40,40,255))
        end

        if activatedBoxes5[1].text == "" then
            drawText(defaultBoxText5[1], panelPos.x,panelPos.y+res(150),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        else
            drawText(activatedBoxes5[1].text, panelPos.x,panelPos.y+res(150),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        end
    end
end

addEventHandler("onClientClick", root, function(key, state, _, _, _, _, _, element)
    if key == "right" and state == "down" then 
        if element then 
            if getElementData(element, "lucky:ped") then 
                if core:getDistance(localPlayer, element) < 2 then
                    showLottoPanel = true
                    addEventHandler("onClientRender",root,renderLottoPanel)
                    setElementData(localPlayer,"selectedNum1",0)
                    setElementData(localPlayer,"selectedNum2",0)
                    setElementData(localPlayer,"selectedNum3",0)
                    setElementData(localPlayer,"selectedNum4",0)
                    setElementData(localPlayer,"selectedNum5",0)
                end
            end
        end
    end

    if key == "left" and state == "down" then
        if showLottoPanel then
            local panelSize = Vector2(res(300),res(400))
            local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
            if core:isInSlot(panelPos.x+res(52),panelPos.y+res(350),res(200),res(20)) then
                    showLottoPanel = false
                    defaultPanel = 0
                    removeEventHandler("onClientRender",root,renderLottoPanel)
            end
            if defaultPanel == 0 then
                local panelSize = Vector2(res(300),res(400))
                local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)

                if core:isInSlot(panelPos.x+res(52),panelPos.y+res(320),res(200),res(20)) then
                    removeEventHandler("onClientRender",root,renderLottoPanel)
                    defaultPanel = 1
                    removeEventHandler("onClientRender",root,renderLottoPanel1)
                    addEventHandler("onClientRender",root,renderLottoPanel1)
                end
            elseif defaultPanel == 1 then
                local panelSize = Vector2(res(300),res(400))
                local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
                if core:isInSlot(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25)) then
                    activatedBoxes1[1]:bringToFront()
                    toggleControl("chatbox",false)
                end
                if core:isInSlot(panelPos.x+res(52),panelPos.y+res(320),res(200),res(20)) then
                    if tonumber(activatedBoxes1[1].text) < 91 then
                        if tonumber(activatedBoxes1[1].text) > 0 then
                            if getElementData(localPlayer,"selectedNum1") == 0 then
                                setElementData(localPlayer,"selectedNum1",tonumber(activatedBoxes1[1].text))
                                outputChatBox(core:getServerPrefix("green-dark", "Ötöslottó", 3).."Az általad kiválasztott első szám a(z) #7cc576"..tonumber(activatedBoxes1[1].text).."#ffffff.", 255, 255, 255, true)
                                defaultPanel = 2
                                removeEventHandler("onClientRender",root,renderLottoPanel1)
                                removeEventHandler("onClientRender",root,renderLottoPanel2)
                                addEventHandler("onClientRender",root,renderLottoPanel2)
                            else
                                outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."Neked már van első számod...", 255, 255, 255, true)
                            end
                        else
                            outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."A szám legyen nagyobb mint 0!", 255, 255, 255, true)
                        end
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."A számok 1 és 90 között vannak!", 255, 255, 255, true)
                    end
                end
            elseif defaultPanel == 2 then 
                local panelSize = Vector2(res(300),res(400))
                local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
                if core:isInSlot(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25)) then
                    activatedBoxes2[1]:bringToFront()
                    toggleControl("chatbox",false)
                end
                if core:isInSlot(panelPos.x+res(52),panelPos.y+res(320),res(200),res(20)) then
                    if tonumber(activatedBoxes2[1].text) < 91 then
                        if tonumber(activatedBoxes2[1].text) > 0 then
                            if getElementData(localPlayer,"selectedNum2") == 0 then
                                    setElementData(localPlayer,"selectedNum2",tonumber(activatedBoxes2[1].text))
                                    outputChatBox(core:getServerPrefix("green-dark", "Ötöslottó", 3).."Az általad kiválasztott második szám a(z) #7cc576"..tonumber(activatedBoxes2[1].text).."#ffffff.", 255, 255, 255, true)
                                    defaultPanel = 3  
                                    removeEventHandler("onClientRender",root,renderLottoPanel2)
                                    removeEventHandler("onClientRender",root,renderLottoPanel3)
                                    addEventHandler("onClientRender",root,renderLottoPanel3)    
                            else
                                outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."Neked már van első számod...", 255, 255, 255, true)
                            end
                        else
                            outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."A szám legyen nagyobb mint 0!", 255, 255, 255, true)
                        end
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."A számok 1 és 90 között vannak!", 255, 255, 255, true)
                    end
                end     
            elseif defaultPanel == 3 then 
                local panelSize = Vector2(res(300),res(400))
                local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
                if core:isInSlot(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25)) then
                    activatedBoxes3[1]:bringToFront()
                    toggleControl("chatbox",false)
                end
                if core:isInSlot(panelPos.x+res(52),panelPos.y+res(320),res(200),res(20)) then
                    if tonumber(activatedBoxes3[1].text) < 91 then
                        if tonumber(activatedBoxes3[1].text) > 0 then
                            if getElementData(localPlayer,"selectedNum3") == 0 then
                                
                                    setElementData(localPlayer,"selectedNum3",tonumber(activatedBoxes3[1].text))
                                    outputChatBox(core:getServerPrefix("green-dark", "Ötöslottó", 3).."Az általad kiválasztott harmadik szám a(z) #7cc576"..tonumber(activatedBoxes3[1].text).."#ffffff.", 255, 255, 255, true)
                                    defaultPanel = 4  
                                    removeEventHandler("onClientRender",root,renderLottoPanel3)
                                    removeEventHandler("onClientRender",root,renderLottoPanel4)
                                    addEventHandler("onClientRender",root,renderLottoPanel4)
                                  
                            else
                                outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."Neked már van első számod...", 255, 255, 255, true)
                            end
                        else
                            outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."A szám legyen nagyobb mint 0!", 255, 255, 255, true)
                        end
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."A számok 1 és 90 között vannak!", 255, 255, 255, true)
                    end
                end     
            elseif defaultPanel == 4 then 
                local panelSize = Vector2(res(300),res(400))
                local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
                if core:isInSlot(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25)) then
                    activatedBoxes4[1]:bringToFront()
                    toggleControl("chatbox",false)
                end
                if core:isInSlot(panelPos.x+res(52),panelPos.y+res(320),res(200),res(20)) then
                    if tonumber(activatedBoxes4[1].text) < 91 then
                        if tonumber(activatedBoxes4[1].text) > 0 then
                            if getElementData(localPlayer,"selectedNum4") == 0 then
                                
                                    setElementData(localPlayer,"selectedNum4",tonumber(activatedBoxes4[1].text))
                                    outputChatBox(core:getServerPrefix("green-dark", "Ötöslottó", 3).."Az általad kiválasztott negyedik szám a(z) #7cc576"..tonumber(activatedBoxes4[1].text).."#ffffff.", 255, 255, 255, true)
                                    defaultPanel = 5  
                                    removeEventHandler("onClientRender",root,renderLottoPanel4)
                                    removeEventHandler("onClientRender",root,renderLottoPanel5)
                                    addEventHandler("onClientRender",root,renderLottoPanel5)
                              
                            else
                                outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."Neked már van első számod...", 255, 255, 255, true)
                            end
                        else
                            outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."A szám legyen nagyobb mint 0!", 255, 255, 255, true)
                        end
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."A számok 1 és 90 között vannak!", 255, 255, 255, true)
                    end
                end
            elseif defaultPanel == 5 then 
                local panelSize = Vector2(res(300),res(400))
                local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
                if core:isInSlot(panelPos.x+res(50),panelPos.y+res(150),res(200),res(25)) then
                    activatedBoxes5[1]:bringToFront()
                    toggleControl("chatbox",false)
                end
                if core:isInSlot(panelPos.x+res(52),panelPos.y+res(320),res(200),res(20)) then
                    if tonumber(activatedBoxes5[1].text) < 91 then
                        if tonumber(activatedBoxes5[1].text) > 0 then
                            if getElementData(localPlayer,"selectedNum5") == 0 then
                                setElementData(localPlayer,"selectedNum5",tonumber(activatedBoxes5[1].text))
                                outputChatBox(core:getServerPrefix("green-dark", "Ötöslottó", 3).."Az általad kiválasztott ötödik szám a(z) #7cc576"..tonumber(activatedBoxes5[1].text).."#ffffff.", 255, 255, 255, true)
                                removeEventHandler("onClientRender",root,renderLottoPanel5)
                                showLottoPanel = false
                                toggleControl("chatbox",true)
                                    
                                local szam1 = getElementData(localPlayer,"selectedNum1")
                                local szam2 = getElementData(localPlayer,"selectedNum2")
                                local szam3 = getElementData(localPlayer,"selectedNum3")
                                local szam4 = getElementData(localPlayer,"selectedNum4")
                                local szam5 = getElementData(localPlayer,"selectedNum5")
                                local value = szam1..szam2..szam3..szam4..szam5

                                triggerServerEvent("giveLottoPaper",localPlayer,localPlayer,value)   
                            else
                                outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."Neked már van első számod...", 255, 255, 255, true)
                            end
                        else
                            outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."A szám legyen nagyobb mint 0!", 255, 255, 255, true)
                        end
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Ötöslottó", 3).."A számok 1 és 90 között vannak!", 255, 255, 255, true)
                    end
                end         
            end
        end
    end
end)