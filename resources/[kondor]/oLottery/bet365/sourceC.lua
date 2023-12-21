sx, sy = guiGetScreenSize();
zoom = math.min(1,0.75 + (sx - 1024) * (1 - 0.75) / (1600 - 1024))
function res(value) return value * zoom end
function resFont(value) return math.floor(res(value)) end

local showBetLaptop = false
local showBetWebSite = false

local googleGuiName = GuiEdit(-1000, -1000, 0, 0, "", false)
googleGuiName.maxLength = 10
local activatedBoxes = {googleGuiName}
local defaultBoxText = {"Keresés..."}

local betGuiName = GuiEdit(-1000, -1000, 0, 0, "", false)
betGuiName.maxLength = 5
local betactivatedBoxes = {betGuiName}
local betdefaultBoxText = {"Összeg"}

function getFont(name, size)
    return exports.oFont:getFont(name, size)
end

function drawText(text, x, y, w, h, ...)
    if not text or not x or not y or not w or not h then return false end
    return dxDrawText(text, x, y, (x + w), (y + h), ...)
end

local betTime = math.random(120,240)


function renderBetLaptop()
    if showBetLaptop then
        local panelSize = Vector2(res(1350),res(785))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)

        dxDrawImage(panelPos.x,panelPos.y,panelSize.x,panelSize.y,"files/laptop.png")
        dxDrawImage(panelPos.x+res(146),panelPos.y+res(45),res(1058),res(646),"files/laptop_wallpapper.png")
        
        dxDrawRectangle(panelPos.x+res(570),panelPos.y+res(370),res(200),res(25),tocolor(255,255,255))        

        if core:isInSlot(panelPos.x+res(1180),panelPos.y+res(45),res(20),res(20)) then
            dxDrawRectangle(panelPos.x+res(1181),panelPos.y+res(45),res(20),res(20),tocolor(182, 36, 36,100))
        end 

        if activatedBoxes[1].text == "" then
            drawText(defaultBoxText[1], panelPos.x+res(420), panelPos.y+res(324), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        else
            drawText(activatedBoxes[1].text, panelPos.x+res(540), panelPos.y+res(324), res(300), res(25), tocolor(0,0,0,220), 1.0, getFont('condensed', res(10)), "left", "center")
        end

        exports.oCore:dxDrawButton(panelPos.x+res(550),panelPos.y+res(370),res(250),res(30), r, g, b, 170, "Keresés", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)
    end
end

addEventHandler("onClientClick", root, function(key, state, _, _, _, _, _, element)
    if key == "right" and state == "down" then 
        if element then 
            if getElementData(element, "bet365:laptop") then
                if core:getDistance(localPlayer, element) < 2 then
                    showBetLaptop = true
                    removeEventHandler("onClientRender",root,renderBetLaptop)
                    addEventHandler("onClientRender",root,renderBetLaptop)
                    exports.oInterface:toggleHud(true)
                    showChat(false)
                    activatedBoxes[1].text = ""
                    setElementData(localPlayer,"bet365:bet",0)
                end
            end
        end
    end
    if key == "left" and state == "down" then
        if showBetLaptop then
            local panelSize = Vector2(res(1350),res(785))
            local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
            if core:isInSlot(panelPos.x+res(1180),panelPos.y+res(45),res(20),res(20)) then
                removeEventHandler("onClientRender",root,renderBetLaptop)
                exports.oInterface:toggleHud(false)
                showChat(true)
                showBetLaptop = false
                toggleControl("chatbox",true)
                setElementData(localPlayer,"bet365:bet",0)
            end
            if core:isInSlot(panelPos.x+res(520),panelPos.y+res(324),res(200),res(25)) then
                activatedBoxes[1]:bringToFront()
                toggleControl("chatbox",false)
            end
            if core:isInSlot(panelPos.x+res(550),panelPos.y+res(370),res(250),res(30)) then 
                if tostring(activatedBoxes[1].text) == "bet365" then
                    showBetLaptop = false
                    showBetWebSite = true
                    toggleControl("chatbox",true)
                    removeEventHandler("onClientRender",root,renderBetLaptop)
                    removeEventHandler("onClientRender",root,renderBetWebsite)
                    addEventHandler("onClientRender",root,renderBetWebsite)
                    fullRandomTeam = generateFullRandomTeam()
                else
                    exports.oInfobox:outputInfoBox("A keresett oldal nem található!","error")
                end
            end
        end
        if showBetWebSite then
            local panelSize = Vector2(res(1350),res(785))
            local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
            if core:isInSlot(panelPos.x+res(1180),panelPos.y+res(45),res(20),res(20)) then
                removeEventHandler("onClientRender",root,renderBetWebsite)
                exports.oInterface:toggleHud(false)
                showChat(true)
                showBetWebSite = false
                toggleControl("chatbox",true)
                setElementData(localPlayer,"bet365:bet",0)
            end
            if core:isInSlot(panelPos.x+res(400),panelPos.y+res(290),res(200),res(25)) then
                betactivatedBoxes[1]:bringToFront()
                toggleControl("chatbox",false)
            end
            if core:isInSlot(panelPos.x+res(375),panelPos.y+res(340),res(250),res(25)) then
                if tonumber(betactivatedBoxes[1].text) then
                    if getElementData(localPlayer,"char:money") >= tonumber(betactivatedBoxes[1].text) then
                        if tonumber(betactivatedBoxes[1].text) >= 100 then
                            setElementData(localPlayer,"bet365:bet",tonumber(betactivatedBoxes[1].text))
                            setElementData(localPlayer,"char:money",getElementData(localPlayer,"char:money")-tonumber(betactivatedBoxes[1].text))
                            exports.oInfobox:outputInfoBox("Sikeresen feltetted a téted!","success")
                            betactivatedBoxes[1].text = ""
                            toggleControl("chatbox",true)
                        else
                            exports.oInfobox:outputInfoBox("A minimum tét 100 dollár!","error")
                        end
                    else
                        exports.oInfobox:outputInfoBox("Nincs elegendő pénzed!","error") 
                    end
                else
                    exports.oInfobox:outputInfoBox("A tét csak szám lehet!","error")
                end
            end
            if core:isInSlot(panelPos.x+res(830),panelPos.y+res(218),res(100),res(30)) then
                setElementData(localPlayer,"bet365:bet:team",getElementData(resourceRoot,"match1TeamA"))
                setElementData(localPlayer,"bet365:bet:odd1",getElementData(resourceRoot,"match1TeamAOdd"))
            end
            if core:isInSlot(panelPos.x+res(830),panelPos.y+res(278),res(100),res(30)) then
                setElementData(localPlayer,"bet365:bet:team",getElementData(resourceRoot,"match1TeamB"))
                setElementData(localPlayer,"bet365:bet:odd1",getElementData(resourceRoot,"match1TeamBOdd"))
            end
            if core:isInSlot(panelPos.x+res(830),panelPos.y+res(398),res(100),res(30)) then
                setElementData(localPlayer,"bet365:bet:team",getElementData(resourceRoot,"match2TeamA"))
                setElementData(localPlayer,"bet365:bet:odd2",getElementData(resourceRoot,"match2TeamAOdd"))
            end
            if core:isInSlot(panelPos.x+res(830),panelPos.y+res(458),res(100),res(30)) then
                setElementData(localPlayer,"bet365:bet:team",getElementData(resourceRoot,"match2TeamB"))
                setElementData(localPlayer,"bet365:bet:odd2",getElementData(resourceRoot,"match2TeamBOdd"))
            end
            if core:isInSlot(panelPos.x+res(800),panelPos.y+res(340),res(150),res(20)) then -- első részes fogadás
                if getElementData(localPlayer,"bet365:bet") > 0 then
                    if getElementData(localPlayer,"bet365:bet:team") then         
                        if betTime >= 10 then    
                            setElementData(localPlayer,"bet365:bet:bet",getElementData(localPlayer,"bet365:bet"))
                            setElementData(localPlayer,"bet365:bet",0)
                            exports.oInfobox:outputInfoBox("Sikeres fogadás!","success")
                        else
                            exports.oInfobox:outputInfoBox("Sajnos lekésted ezt a meccset!","error")
                        end
                    else
                        exports.oInfobox:outputInfoBox("Előbb válassz csapatot!","error")
                    end
                else
                   exports.oInfobox:outputInfoBox("Előbb adj hozzá tétet!","error") 
                end 
            end
            if core:isInSlot(panelPos.x+res(800),panelPos.y+res(520),res(150),res(20)) then -- második részes fogadás
                if getElementData(localPlayer,"bet365:bet") > 0 then
                    if getElementData(localPlayer,"bet365:bet:team") then 
                        if betTime >= 10 then    
                            setElementData(localPlayer,"bet365:bet:bet",getElementData(localPlayer,"bet365:bet"))
                            setElementData(localPlayer,"bet365:bet",0)
                            exports.oInfobox:outputInfoBox("Sikeres fogadás!","success")
                        else
                            exports.oInfobox:outputInfoBox("Sajnos lekésted ezt a meccset!","error")
                        end
                    else
                        exports.oInfobox:outputInfoBox("Előbb válassz csapatot!","error")
                    end
                else
                   exports.oInfobox:outputInfoBox("Előbb adj hozzá tétet!","error") 
                end 
            end
        end
    end
end)

function renderBetWebsite()
    if showBetWebSite then
        local panelSize = Vector2(res(1350),res(785))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        dxDrawImage(panelPos.x,panelPos.y,panelSize.x,panelSize.y,"files/laptop.png")
        dxDrawImage(panelPos.x+res(146),panelPos.y+res(45),res(1058),res(646),"files/laptop_bet.png")

        -- Hirdető rész
        drawText("Nyerj nálunk nagyobb téttel\nés vedd meg Te, az új autókat!", panelPos.x+res(280), panelPos.y+res(180), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "left", "center")
        dxDrawImage(panelPos.x+res(520),panelPos.y+res(157),res(200),res(80),"files/laptop_kocsi.png") -- kép helye (autó)

        -- Előző nyertesek listája
        drawText("Nyerteseink", panelPos.x+res(60), panelPos.y+res(160), res(300), res(25), tocolor(r,g,b,255), 1.0, getFont('condensed', res(11)), "center", "center")
        for i = 1, 10 do 
            drawText(vorNames[0+i].." "..lastNames[0+i], panelPos.x+res(60), panelPos.y+res(200) + ((i - 1) * 50), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        end

        -- Kiemelt ajánlatok rész
        drawText("Kiemelt ajánlatok", panelPos.x+res(965), panelPos.y+res(160), res(300), res(25), tocolor(r,g,b,255), 1.0, getFont('condensed', res(11)), "center", "center")
        drawText("Fogadj te is a\n"..fullRandomTeam.." csapatra,\nmert a nyerési\naránya eszméletlen!", panelPos.x+res(965), panelPos.y+res(220), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        drawText("A következő maraton\nhamarosan indul!\nTöltsd fel magad,\nmert nem lesz meccs\nmentes nap!", panelPos.x+res(965), panelPos.y+res(350), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")

        -- Elérhetőségek rész
        drawText("Kapcsolat", panelPos.x+res(965), panelPos.y+res(460), res(300), res(25), tocolor(r,g,b,255), 1.0, getFont('condensed', res(11)), "center", "center")
        drawText("www.originalrp.eu", panelPos.x+res(965), panelPos.y+res(490), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        drawText("forum.originalrp.eu", panelPos.x+res(965), panelPos.y+res(520), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        drawText("facebook.com/OriginalRoleplay", panelPos.x+res(965), panelPos.y+res(550), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(9)), "center", "center")
        drawText("A felelőség teljes\njáték mindennél fontosabb!", panelPos.x+res(965), panelPos.y+res(600), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        drawText("Minden jog fenntartva 2022", panelPos.x+res(965), panelPos.y+res(660), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(9)), "center", "center")
    
        -- Zöld és szürke csík karakterinfók
        drawText("bet365", panelPos.x+res(160), panelPos.y+res(125), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(15)), "left", "center")
        drawText("& OriginalRoleplay", panelPos.x+res(228), panelPos.y+res(125), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(11)), "left", "center")
        drawText("Egyenleg: "..getElementData(localPlayer,"char:money").."$", panelPos.x+res(890), panelPos.y+res(92), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "right", "center")
        drawText("Név: "..getElementData(localPlayer,"char:name"), panelPos.x+res(890), panelPos.y+res(125), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "right", "center")        
        drawText("Jelenlegi tét: "..(getElementData(localPlayer,"bet365:bet") or 0).."$", panelPos.x+res(150), panelPos.y+res(92), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "left", "center")

        drawText("Idő a következő meccsek indulásáig: "..betTime.." másodperc", panelPos.x+res(300), panelPos.y+res(92), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "left", "center")
        -- Meccsek
        drawText("Elkövetkező meccsek", panelPos.x+res(730), panelPos.y+res(160), res(300), res(25), tocolor(r,g,b,255), 1.0, getFont('condensed', res(11)), "center", "center")

        if core:isInSlot(panelPos.x+res(830),panelPos.y+res(218),res(100),res(30)) then
            drawText(getElementData(resourceRoot,"match1TeamA"), panelPos.x+res(730), panelPos.y+res(220), res(300), res(25), tocolor(230,230,230,255), 1.0, getFont('condensed', res(10)), "center", "center")
        else
            drawText(getElementData(resourceRoot,"match1TeamA"), panelPos.x+res(730), panelPos.y+res(220), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        end
        drawText("Odds: "..getElementData(resourceRoot,"match1TeamAOdd"), panelPos.x+res(730), panelPos.y+res(250), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        if core:isInSlot(panelPos.x+res(830),panelPos.y+res(278),res(100),res(30)) then
            drawText(getElementData(resourceRoot,"match1TeamB"), panelPos.x+res(730), panelPos.y+res(280), res(300), res(25), tocolor(230,230,230,255), 1.0, getFont('condensed', res(10)), "center", "center")
        else
            drawText(getElementData(resourceRoot,"match1TeamB"), panelPos.x+res(730), panelPos.y+res(280), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        end
        drawText("Odds: "..getElementData(resourceRoot,"match1TeamBOdd"), panelPos.x+res(730), panelPos.y+res(310), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        exports.oCore:dxDrawButton(panelPos.x+res(800),panelPos.y+res(340),res(150),res(20), r, g, b, 170, "Fogadás", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        if core:isInSlot(panelPos.x+res(830),panelPos.y+res(398),res(100),res(30)) then
            drawText(getElementData(resourceRoot,"match2TeamA"), panelPos.x+res(730), panelPos.y+res(400), res(300), res(25), tocolor(230,230,230,255), 1.0, getFont('condensed', res(10)), "center", "center")
        else
            drawText(getElementData(resourceRoot,"match2TeamA"), panelPos.x+res(730), panelPos.y+res(400), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        end
        drawText("Odds: "..getElementData(resourceRoot,"match2TeamAOdd"), panelPos.x+res(730), panelPos.y+res(430), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        
        if core:isInSlot(panelPos.x+res(830),panelPos.y+res(458),res(100),res(30)) then 
            drawText(getElementData(resourceRoot,"match2TeamB"), panelPos.x+res(730), panelPos.y+res(460), res(300), res(25), tocolor(230,230,230,255), 1.0, getFont('condensed', res(10)), "center", "center")
        else
            drawText(getElementData(resourceRoot,"match2TeamB"), panelPos.x+res(730), panelPos.y+res(460), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        end
        drawText("Odds: "..getElementData(resourceRoot,"match2TeamBOdd"), panelPos.x+res(730), panelPos.y+res(490), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        exports.oCore:dxDrawButton(panelPos.x+res(800),panelPos.y+res(520),res(150),res(20), r, g, b, 170, "Fogadás", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        drawText("A szolgáltatásainkat csakis\n18.életévét betöltött\nállampolgár veheti igénybe.", panelPos.x+res(730), panelPos.y+res(640), res(300), res(25), tocolor(r,g,b,255), 1.0, getFont('condensed', res(10)), "center", "center")

        -- Fogadási tét rész
        drawText("Fogadási tét", panelPos.x+res(350), panelPos.y+res(250), res(300), res(25), tocolor(r,g,b,255), 1.0, getFont('condensed', res(15)), "center", "center")

        dxDrawRectangle(panelPos.x+res(400),panelPos.y+res(290),res(200),res(25),tocolor(39,39,39,200)) 
        if betactivatedBoxes[1].text == "" then
            drawText(betdefaultBoxText[1], panelPos.x+res(350), panelPos.y+res(290), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(10)), "center", "center")
        else
            drawText(betactivatedBoxes[1].text, panelPos.x+res(350), panelPos.y+res(290), res(300), res(25), tocolor(200,200,200,220), 1.0, getFont('condensed', res(10)), "center", "center")
        end
        exports.oCore:dxDrawButton(panelPos.x+res(375),panelPos.y+res(340),res(250),res(25), r, g, b, 170, "Megadás", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

        -- Statisztikák
        drawText("Statisztikáid", panelPos.x+res(350), panelPos.y+res(400), res(300), res(25), tocolor(r,g,b,255), 1.0, getFont('condensed', res(15)), "center", "center")
        
        local todayWins = (getElementData(localPlayer,"todayWins") or 0)
        drawText("Ma nyert fogadásaid", panelPos.x+res(200), panelPos.y+res(450), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(11)), "center", "center")
        dxDrawRectangle(panelPos.x+res(280),panelPos.y+res(490),res(350),res(20),tocolor(255, 255, 255,100))
        dxDrawRectangle(panelPos.x+res(280),panelPos.y+res(490),res(350)/350*todayWins,res(20),tocolor(r, g, b,100))
        drawText(todayWins, panelPos.x+res(300),panelPos.y+res(488), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(11)), "center", "center")

        local loseWins = (getElementData(localPlayer,"loseWins") or 0)
        drawText("Ma vesztett fogadásaid", panelPos.x+res(250), panelPos.y+res(530), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(11)), "center", "center")
        dxDrawRectangle(panelPos.x+res(280),panelPos.y+res(570),res(350),res(20),tocolor(255, 255, 255,100))
        dxDrawRectangle(panelPos.x+res(280),panelPos.y+res(570),res(350)/350*loseWins,res(20),tocolor(r, g, b,100))
        drawText(loseWins, panelPos.x+res(300),panelPos.y+res(568), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(11)), "center", "center")

        local allWins = (getElementData(localPlayer,"allWins") or 0)
        drawText("Összes fogadásod", panelPos.x+res(210), panelPos.y+res(610), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(11)), "center", "center")
        dxDrawRectangle(panelPos.x+res(280),panelPos.y+res(650),res(350),res(20),tocolor(255, 255, 255,100))
        dxDrawRectangle(panelPos.x+res(280),panelPos.y+res(650),res(350)/350*allWins,res(20),tocolor(r, g, b,100))
        drawText(allWins, panelPos.x+res(300),panelPos.y+res(648), res(300), res(25), tocolor(200,200,200,255), 1.0, getFont('condensed', res(11)), "center", "center")
    end
end


function generateMatch()
    betTime = math.random(120,240)
    local match1TeamA = generateTeamA("hungary")
    setElementData(resourceRoot,"match1TeamA",match1TeamA)
    local match1TeamAOdd = generateRandomOdds()
    setElementData(resourceRoot,"match1TeamAOdd", match1TeamAOdd)

    local match1TeamB = generateTeamB("hungary")
    setElementData(resourceRoot,"match1TeamB",match1TeamB)
    local match1TeamBOdd = generateRandomOdds()
    setElementData(resourceRoot,"match1TeamBOdd", match1TeamBOdd)

    local match2TeamA = generateTeamA("spain")
    setElementData(resourceRoot,"match2TeamA",match2TeamA)
    local match2TeamAOdd = generateRandomOdds()
    setElementData(resourceRoot,"match2TeamAOdd", match2TeamAOdd)

    local match2TeamB = generateTeamB("spain")
    setElementData(resourceRoot,"match2TeamB",match2TeamB)
    local match2TeamBOdd = generateRandomOdds()
    setElementData(resourceRoot,"match2TeamBOdd", match2TeamBOdd)
end
generateMatch()

function makeWinnerMatch1()
    local winnernum = math.random(1,2)
    if winnernum == 1 then
        setElementData(resourceRoot,"bet365:bet:winnerteammatch1",getElementData(resourceRoot,"match1TeamA"))
    else
        setElementData(resourceRoot,"bet365:bet:winnerteammatch1",getElementData(resourceRoot,"match1TeamB"))
    end
end

function searchWinnerMatch1()
    if getElementData(resourceRoot,"bet365:bet:winnerteammatch1") == getElementData(localPlayer,"bet365:bet:team") then
        local winAmount = getElementData(localPlayer,"bet365:bet:bet")*getElementData(localPlayer,"bet365:bet:odd1")
        setElementData(localPlayer,"char:money",getElementData(localPlayer,"char:money")+winAmount)
        exports.oInfobox:outputInfoBox("Az egyik tipped bejött! Győztes: "..getElementData(resourceRoot,"bet365:bet:winnerteammatch1").." Nyeremény: "..winAmount,"success")
        setElementData(localPlayer,"todayWins",getElementData(localPlayer,"todayWins")+1)

        setElementData(localPlayer,"bet365:bet:team","Nincs")
        setElementData(localPlayer,"bet365:bet:odd1",0)
        setElementData(localPlayer,"bet365:bet:odd2",0)
    else
        exports.oInfobox:outputInfoBox("Sajnos ez a tipped nem jött be!","warning")
        setElementData(localPlayer,"loseWins",getElementData(localPlayer,"loseWins")+1)

        setElementData(localPlayer,"bet365:bet:team","Nincs")
        setElementData(localPlayer,"bet365:bet:odd1",0)
        setElementData(localPlayer,"bet365:bet:odd2",0)
    end
end

function makeWinnerMatch2()
    local winnernum2 = math.random(1,2)
    if winnernum2 == 1 then
        setElementData(resourceRoot,"bet365:bet:winnerteammatch2",getElementData(resourceRoot,"match2TeamA"))
    else
        setElementData(resourceRoot,"bet365:bet:winnerteammatch2",getElementData(resourceRoot,"match2TeamB"))
    end
end

function searchWinnerMatch2()
    if getElementData(resourceRoot,"bet365:bet:winnerteammatch2") == getElementData(localPlayer,"bet365:bet:team") then
        local winAmount = getElementData(localPlayer,"bet365:bet:bet")*getElementData(localPlayer,"bet365:bet:odd2")
        setElementData(localPlayer,"char:money",getElementData(localPlayer,"char:money")+winAmount)
        exports.oInfobox:outputInfoBox("Az egyik tipped bejött! Győztes: "..getElementData(resourceRoot,"bet365:bet:winnerteammatch2").." Nyeremény: "..winAmount,"success")
        setElementData(localPlayer,"todayWins",getElementData(localPlayer,"todayWins")+1)
        
        setElementData(localPlayer,"bet365:bet:team","Nincs")
        setElementData(localPlayer,"bet365:bet:odd1",0)
        setElementData(localPlayer,"bet365:bet:odd2",0)
    else
        exports.oInfobox:outputInfoBox("Sajnos ez a tipped nem jött be!","warning")
        setElementData(localPlayer,"loseWins",getElementData(localPlayer,"loseWins")+1)
        
        setElementData(localPlayer,"bet365:bet:team","Nincs")
        setElementData(localPlayer,"bet365:bet:odd1",0)
        setElementData(localPlayer,"bet365:bet:odd2",0)
    end
end

setTimer(function()
    if showBetWebSite then
        betTime = betTime - 1
        if betTime < 1 then 
            betTime = 0
            
            makeWinnerMatch1()
            searchWinnerMatch1()

            makeWinnerMatch2()
            searchWinnerMatch2()

            generateMatch()

            betTime = math.random(120,240)
        end 
    end
end,1000,0)