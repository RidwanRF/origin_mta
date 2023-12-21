sx, sy = guiGetScreenSize();
zoom = math.min(1,0.75 + (sx - 1024) * (1 - 0.75) / (1600 - 1024))
function res(value) return value * zoom end
function resFont(value) return math.floor(res(value)) end

local lottoGuiName = GuiEdit(-1000, -1000, 0, 0, "", false)
lottoGuiName.maxLength = 2
local activatedBoxes = {lottoGuiName}
local defaultBoxText = {"Add le a tipped!"}


function getFont(name, size)
    return exports.oFont:getFont(name, size)
end

function drawText(text, x, y, w, h, ...)
    if not text or not x or not y or not w or not h then return false end
    return dxDrawText(text, x, y, (x + w), (y + h), ...)
end

local numberPickPanel = false
local chooseEvenOddPanel = false
local chooseUnderOverPanel = false
local tippNumPanel = false

local finishGeneratedNumber = 0

function renderNumberPickPanel()
    if numberPickPanel then    
        local panelSize = Vector2(res(300),res(400))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        
        exports.oCore:drawWindow(panelPos.x,panelPos.y,panelSize.x,panelSize.y, color.."Original#ffffffRoleplay - #7cc576Számfejtő", 1)
        exports.oCore:dxDrawButton(panelPos.x+res(10),panelPos.y+res(360),res(280),res(30), 182, 36, 36, 170, "Kilépés", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        exports.oCore:dxDrawButton(panelPos.x+res(10),panelPos.y+res(320),res(280),res(30), r, g, b, 170, "Játszom", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        drawText("A játék lényege, hogy eltaláld,\n mire gondol Alisson.\n\nA játékban 1-20 vannak a számok,\ntippelj jól, és nyerj!\n\nA játék ára: 5$", panelPos.x,panelPos.y+res(150),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
    end
end

function renderChooseEvenOdd()
    if chooseEvenOddPanel then
        local panelSize = Vector2(res(300),res(400))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        
        exports.oCore:drawWindow(panelPos.x,panelPos.y,panelSize.x,panelSize.y, color.."Original#ffffffRoleplay - #7cc576Számfejtő", 1)
        exports.oCore:dxDrawButton(panelPos.x+res(10),panelPos.y+res(360),res(280),res(30), 182, 36, 36, 170, "Kilépés", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        exports.oCore:dxDrawButton(panelPos.x+res(10),panelPos.y+res(280),res(280),res(30), r, g, b, 170, "Páros", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)
        exports.oCore:dxDrawButton(panelPos.x+res(10),panelPos.y+res(320),res(280),res(30), r, g, b, 170, "Páratlan", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        drawText("Alisson máris gondolt egy számra!\nSzerinted páros, vagy páratlan?", panelPos.x,panelPos.y+res(150),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
   end
end

function renderChooseUnderOver()
    if chooseUnderOverPanel then
        local panelSize = Vector2(res(300),res(400))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        
        exports.oCore:drawWindow(panelPos.x,panelPos.y,panelSize.x,panelSize.y, color.."Original#ffffffRoleplay - #7cc576Számfejtő", 1)
        exports.oCore:dxDrawButton(panelPos.x+res(10),panelPos.y+res(360),res(280),res(30), 182, 36, 36, 170, "Kilépés", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        exports.oCore:dxDrawButton(panelPos.x+res(10),panelPos.y+res(280),res(280),res(30), r, g, b, 170, "1-10", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)
        exports.oCore:dxDrawButton(panelPos.x+res(10),panelPos.y+res(320),res(280),res(30), r, g, b, 170, "11-20", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        drawText("Szerinted a szám 1-10 van,\nvagy 11-20?", panelPos.x,panelPos.y+res(150),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
    end
end



function renderTippNum()
    if tippNumPanel then
        local panelSize = Vector2(res(300),res(400))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        
        exports.oCore:drawWindow(panelPos.x,panelPos.y,panelSize.x,panelSize.y, color.."Original#ffffffRoleplay - #7cc576Számfejtő", 1)
        exports.oCore:dxDrawButton(panelPos.x+res(10),panelPos.y+res(360),res(280),res(30), 182, 36, 36, 170, "Kilépés", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        exports.oCore:dxDrawButton(panelPos.x+res(10),panelPos.y+res(320),res(280),res(30), r, g, b, 170, "Tippelek", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        drawText("Ha szeretnél további pénzt nyerni,\n tippelj egy pontosat!", panelPos.x,panelPos.y+res(100),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
    
        drawText("Tipp: Az utolsó tippadás ingyenes,\n fix nyereményed már jóváírva.\nEgyszerű lehetőség többlet\nösszeget szerezni.", panelPos.x,panelPos.y+res(250),res(300),res(25), tocolor(200,200,200,200), 0.8, getFont('condensed', res(10)), "center", "center")

        if core:isInSlot(panelPos.x+res(50),panelPos.y+res(180),res(200),res(25)) then
            dxDrawRectangle(panelPos.x+res(50),panelPos.y+res(180),res(200),res(25),tocolor(45,45,45,255))
        else
            dxDrawRectangle(panelPos.x+res(50),panelPos.y+res(180),res(200),res(25),tocolor(40,40,40,255))
        end

        if activatedBoxes[1].text == "" then
            drawText(defaultBoxText[1], panelPos.x,panelPos.y+res(180),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        else
            drawText(activatedBoxes[1].text, panelPos.x,panelPos.y+res(180),res(300),res(25), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        end
    end
end


addEventHandler("onClientClick", root, function(key, state, _, _, _, _, _, element)
    if key == "right" and state == "down" then 
        if element then 
            if getElementData(element, "numberpick:ped") then 
                if core:getDistance(localPlayer, element) < 2 then
                    numberPickPanel = true
                    removeEventHandler("onClientRender",root,renderNumberPickPanel)
                    addEventHandler("onClientRender",root,renderNumberPickPanel)
                end
            end
        end
    end
    if key == "left" and state == "down" then
        local panelSize = Vector2(res(300),res(400))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2) 
        if core:isInSlot(panelPos.x+res(10),panelPos.y+res(360),res(280),res(30)) then
            activatedBoxes[1].text = ""
            toggleControl("chatbox",true)
            numberPickPanel = false
            chooseEvenOddPanel = false
            chooseUnderOverPanel = false
            tippNumPanel = false
            removeEventHandler("onClientRender",root,renderNumberPickPanel)
            removeEventHandler("onClientRender",root,renderChooseEvenOdd)
            removeEventHandler("onClientRender",root,renderChooseUnderOver)
            removeEventHandler("onClientRender",root,renderTippNum)
        end

        if numberPickPanel then
            if core:isInSlot(panelPos.x+res(10),panelPos.y+res(320),res(280),res(30)) then
                if getElementData(localPlayer,"char:money") >= 5 then  
                    setElementData(localPlayer,"char:money",getElementData(localPlayer,"char:money") - 5)
                    numberPickPanel = false
                    chooseEvenOddPanel = true
                    addEventHandler("onClientRender",root,renderChooseEvenOdd)
                    removeEventHandler("onClientRender",root,renderNumberPickPanel)

                    local firstQuest = math.random(1,2)
                    if (firstQuest) == 1 then
                        setElementData(resourceRoot,"game_evenodd","even")
                        if getElementData(localPlayer,"user:admin") >= 10 then 
                            outputChatBox("#3399FF[Fejlesztőknek]: #ffffffMegoldás: páros",255,255,255,true)
                        end
                    else
                        setElementData(resourceRoot,"game_evenodd","odd")
                        if getElementData(localPlayer,"user:admin") >= 10 then 
                            outputChatBox("#3399FF[Fejlesztőknek]: #ffffffMegoldás: páratlan",255,255,255,true)
                        end
                    end
                else
                     outputChatBox(core:getServerPrefix("red-dark", "Számfejtő", 3).."Nincs elegendő pénzed a játékhoz! (5$)", 255, 255, 255, true)
                end
            end    
        elseif chooseEvenOddPanel then
            if core:isInSlot(panelPos.x+res(10),panelPos.y+res(280),res(280),res(30)) then -- páros
                if getElementData(resourceRoot,"game_evenodd") == "even" then
                    outputChatBox(core:getServerPrefix("green-dark", "Számfejtő", 3).."Sikeresen eltaláltad az első kérdést!", 255, 255, 255, true)
                    playSound("files/success.mp3")

                    local twoQuest = math.random(1,2)
                    if (twoQuest) == 1 then
                        setElementData(resourceRoot,"game_underover","over")
                        if getElementData(localPlayer,"user:admin") >= 10 then 
                            outputChatBox("#3399FF[Fejlesztőknek]: #ffffffMegoldás: 11-20",255,255,255,true)
                        end
                    else
                        setElementData(resourceRoot,"game_underover","under")
                        if getElementData(localPlayer,"user:admin") >= 10 then 
                            outputChatBox("#3399FF[Fejlesztőknek]: #ffffffMegoldás: 1-10",255,255,255,true)
                        end
                    end

                    chooseUnderOverPanel = true
                    chooseEvenOddPanel = false
                    removeEventHandler("onClientRender",root,renderChooseEvenOdd)
                    addEventHandler("onClientRender",root,renderChooseUnderOver)
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Számfejtő", 3).."Sajnos a válaszod helytelen!", 255, 255, 255, true)
                    chooseEvenOddPanel = false
                    removeEventHandler("onClientRender",root,renderChooseEvenOdd)
                end
            end
            if core:isInSlot(panelPos.x+res(10),panelPos.y+res(320),res(280),res(30)) then -- páratlan
                if getElementData(resourceRoot,"game_evenodd") == "odd" then
                    outputChatBox(core:getServerPrefix("green-dark", "Számfejtő", 3).."Sikeresen eltaláltad az első kérdést!", 255, 255, 255, true)
                    playSound("files/success.mp3")

                    local twoQuest = math.random(1,2)
                    if (twoQuest) == 1 then
                        setElementData(resourceRoot,"game_underover","over")
                        if getElementData(localPlayer,"user:admin") >= 10 then 
                            outputChatBox("#3399FF[Fejlesztőknek]: #ffffffMegoldás: 11-20",255,255,255,true)
                        end
                    else
                        setElementData(resourceRoot,"game_underover","under")
                        if getElementData(localPlayer,"user:admin") >= 10 then 
                            outputChatBox("#3399FF[Fejlesztőknek]: #ffffffMegoldás: 1-10",255,255,255,true)
                        end
                    end

                    chooseUnderOverPanel = true
                    chooseEvenOddPanel = false
                    removeEventHandler("onClientRender",root,renderChooseEvenOdd)
                    addEventHandler("onClientRender",root,renderChooseUnderOver)
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Számfejtő", 3).."Sajnos a válaszod helytelen!", 255, 255, 255, true)
                    chooseEvenOddPanel = false
                    removeEventHandler("onClientRender",root,renderChooseEvenOdd)
                end
            end
        elseif chooseUnderOverPanel then
            if core:isInSlot(panelPos.x+res(10),panelPos.y+res(280),res(280),res(30)) then -- 1-10
                if getElementData(resourceRoot,"game_underover") == "under" then
                    outputChatBox(core:getServerPrefix("green-dark", "Számfejtő", 3).."Sikeresen eltaláltad a második kérdést!", 255, 255, 255, true)
                    setElementData(localPlayer,"char:money",getElementData(localPlayer,"char:money")+20)
                    outputChatBox(core:getServerPrefix("green-dark", "Számfejtő", 3).."Mivel kettő kérdésre helyesen válaszoltál, így kétszeres összeget (10$) írtunk neked jóvá. További szorzóért tippelj pontosat!", 255, 255, 255, true)
                    playSound("files/success.mp3")

                    if getElementData(resourceRoot,"game_evenodd") == "even" then 
                        finishGeneratedNumber = evenUnderNums[math.random(1,5)]
                        if getElementData(localPlayer,"user:admin") >= 10 then 
                            outputChatBox("#3399FF[Fejlesztőknek]: #ffffffMegoldás: "..finishGeneratedNumber,255,255,255,true)
                        end
                    else
                        finishGeneratedNumber = oddUnderNums[math.random(1,5)]
                        if getElementData(localPlayer,"user:admin") >= 10 then 
                            outputChatBox("#3399FF[Fejlesztőknek]: #ffffffMegoldás: "..finishGeneratedNumber,255,255,255,true)
                        end
                    end

                    chooseUnderOverPanel = false
                    tippNumPanel = true
                    removeEventHandler("onClientRender",root,renderChooseUnderOver)
                    removeEventHandler("onClientRender",root,renderTippNum)
                    addEventHandler("onClientRender",root,renderTippNum)
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Számfejtő", 3).."Sajnos a válaszod helytelen!", 255, 255, 255, true)
                    chooseUnderOverPanel = false
                    removeEventHandler("onClientRender",root,renderChooseUnderOver)
                end
            end
            if core:isInSlot(panelPos.x+res(10),panelPos.y+res(320),res(280),res(30)) then -- 11-20
                if getElementData(resourceRoot,"game_underover") == "over" then
                    outputChatBox(core:getServerPrefix("green-dark", "Számfejtő", 3).."Sikeresen eltaláltad a második kérdést!", 255, 255, 255, true)
                    setElementData(localPlayer,"char:money",getElementData(localPlayer,"char:money")+10)
                    outputChatBox(core:getServerPrefix("green-dark", "Számfejtő", 3).."Mivel kettő kérdésre helyesen válaszoltál, így kétszeres összeget (10$) írtunk neked jóvá. További szorzóért tippelj pontosat!", 255, 255, 255, true)
                    playSound("files/success.mp3")

                    if getElementData(resourceRoot,"game_evenodd") == "even" then 
                        finishGeneratedNumber = evenOverNums[math.random(1,5)]
                       if getElementData(localPlayer,"user:admin") >= 10 then 
                            outputChatBox(finishGeneratedNumber)
                        end
                    else
                        finishGeneratedNumber = oddOverNums[math.random(1,5)]
                        if getElementData(localPlayer,"user:admin") >= 10 then 
                            outputChatBox(finishGeneratedNumber)
                        end
                    end

                    chooseUnderOverPanel = false
                    tippNumPanel = true
                    removeEventHandler("onClientRender",root,renderChooseUnderOver)
                    removeEventHandler("onClientRender",root,renderTippNum)
                    addEventHandler("onClientRender",root,renderTippNum)

                else
                    outputChatBox(core:getServerPrefix("red-dark", "Számfejtő", 3).."Sajnos a válaszod helytelen!", 255, 255, 255, true)
                    chooseUnderOverPanel = false
                    removeEventHandler("onClientRender",root,renderChooseUnderOver)
                end
            end
        elseif tippNumPanel then 
            if core:isInSlot(panelPos.x+res(50),panelPos.y+res(180),res(200),res(25)) then
                activatedBoxes[1]:bringToFront()
                toggleControl("chatbox",false)
            end
            if core:isInSlot(panelPos.x+res(10),panelPos.y+res(320),res(280),res(30)) then
                if tonumber(activatedBoxes[1].text) == finishGeneratedNumber then
                    outputChatBox(core:getServerPrefix("green-dark", "Számfejtő", 3).."A tipped tökéletes! A megoldás a(z) #7cc576"..finishGeneratedNumber.." #ffffffvolt. Nyereményed plusz 50 dollár!", 255, 255, 255, true)
                    setElementData(localPlayer,"char:money",getElementData(localPlayer,"char:money")+50)
                    playSound("files/success.mp3")

                    tippNumPanel = false
                    removeEventHandler("onClientRender",root,renderTippNum)  
                    toggleControl("chatbox",true) 
                    activatedBoxes[1].text = ""          
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Számfejtő", 3).."Sajnos a tipped nem sikerült! Ne csükkedj, próbáld újra!", 255, 255, 255, true)
                    
                    tippNumPanel = false
                    numberPickPanel = true
                    removeEventHandler("onClientRender",root,renderTippNum)
                    removeEventHandler("onClientRender",root,renderNumberPickPanel)
                    addEventHandler("onClientRender",root,renderNumberPickPanel)
                    activatedBoxes[1].text = ""
                end
            end
        end
    end
end)

    
