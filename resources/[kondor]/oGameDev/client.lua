local sx, sy = guiGetScreenSize()

zoom = math.min(1,0.75 + (sx - 1024) * (1 - 0.75) / (1600 - 1024))
function res(value) return value * zoom end
function resFont(value) return math.floor(res(value)) end
function getFont(name, size)
    return exports.oFont:getFont(name, size)
end
function drawText(text, x, y, w, h, ...)
    if not text or not x or not y or not w or not h then return false end
    return dxDrawText(text, x, y, (x + w), (y + h), ...)
end


local smallfont = dxCreateFont("files/fonts/RobotoL.ttf",resFont(10))
local smallfont2 = dxCreateFont("files/fonts/RobotoL.ttf",resFont(8))
local smallfont3 = dxCreateFont("files/fonts/RobotoL.ttf",resFont(12))
local showPanelState = 0
local officeID = 0
local officeOwner = "Nincs"
local showLaptopToolTip = false

-- Marker render
local tick = getTickCount()
addEventHandler("onClientRender",getRootElement(),function()
    local pX,pY,pZ = getElementPosition(localPlayer)
    for k, v in pairs(getElementsByType("marker", resourceRoot, true)) do
        if (getElementData(v,"or:officemarker") or getElementData(v,"or:mainmarker")) then
            local scale, zplus = interpolateBetween(0.4, 1.2, 0, 0.55, 1.7, 0, (getTickCount() - tick) / 5000, "CosineCurve")
            local markX,markY,markZ = getElementPosition(v)
            local x, y = getScreenFromWorldPosition(markX, markY, (markZ-0.6)+zplus)  

            if x and y then
                local distance = core:getDistance(localPlayer,v)
                if distance < 40 then    
                   
                    local r, g, b = getMarkerColor(v)
                    local size = interpolateBetween(40,0,0, 40 - distance/1.4,0,0, distance, "Linear")
                    exports.o3DElements:dxDrawCircle3D(markX, markY, (markZ - 0.6) +0.6, scale, tocolor(r, g, b, 150 - (2 * 30)), 3)
                    exports.o3DElements:dxDrawCircle3D(markX, markY, (markZ - 0.6) +0.75, scale, tocolor(r, g, b, 150 - (3 * 30)), 2)
                    exports.o3DElements:dxDrawCircle3D(markX, markY, (markZ - 0.6) +0.9, scale, tocolor(r, g, b, 150 - (4 * 30)), 1)
                    if isLineOfSightClear (pX, pY, pZ, markX, markY, markZ + 0.6, true, true, false, true) then    
                        dxDrawImage(x-size/2,y-size/2,size,size,"files/interior/icon.png",0,0,90, tocolor(r, g, b, 200),false)
                    end  
                end 
            end
        end
    end
end)

-- Panel
setElementData(localPlayer,"inmarker",false)

function drawPanel()
    if showPanelState == 1 then
        local panelSize = Vector2(res(300),res(100))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        local progress = ( getTickCount() - tick )/ 250
        if getElementData(localPlayer,"inmarker") then
            x,y = interpolateBetween(panelPos.x, sy, 0, panelPos.x,sy-res(200), 0, progress, "Linear")
            animation = interpolateBetween(0, 0, 0, 255, 0, 0, progress, "Linear")
        else
            x,y = interpolateBetween(panelPos.x,sy-res(200),0,panelPos.x, sy, 0, progress, "Linear")
            animation = interpolateBetween(255, 0, 0, 0, 0, 0, progress, "Linear")
            if animation == 0 then
                removeEventHandler("onClientRender",root,drawPanel)
            end
        end
        dxDrawRectangle(x,y,panelSize.x,panelSize.y,tocolor(42,42,42,animation))
        dxDrawRectangle(x+res(5),y+res(5),panelSize.x-res(200),panelSize.y-res(10),tocolor(52,52,52,animation))      
        drawText("#e97619Iroda #"..officeID.."\n#c3564aTulajdonos: "..officeOwner,x+res(110),y+res(5),panelSize.x-res(115),panelSize.y-res(35),tocolor(200,200,200,animation),1,smallfont,"center","center",false,false,false,true)
        dxDrawImage(x+res(25),y+res(18),res(57),res(67),"files/images/markericon.png",0,0,0,tocolor(200,200,200,animation))       
        dxDrawRectangle(x+res(110),y+res(75),panelSize.x-res(115),panelSize.y-res(80),tocolor(52,52,52,animation))
               
        drawText("#e97619[E] #FFFFFFbetű",x+res(110),y+res(75),panelSize.x-res(115),panelSize.y-res(80),tocolor(200,200,200,animation),1,smallfont,"center","center",false,false,false,true)  
    elseif showPanelState == 2 then
        local panelSize = Vector2(res(300),res(100))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        local progress = ( getTickCount() - tick )/ 250
        if getElementData(localPlayer,"inmarker") then
            x,y = interpolateBetween(panelPos.x, sy, 0, panelPos.x,sy-res(200), 0, progress, "Linear")
            animation = interpolateBetween(0, 0, 0, 255, 0, 0, progress, "Linear")
        else
            x,y = interpolateBetween(panelPos.x,sy-res(200),0,panelPos.x, sy, 0, progress, "Linear")
            animation = interpolateBetween(255, 0, 0, 0, 0, 0, progress, "Linear")
            if animation == 0 then
                removeEventHandler("onClientRender",root,drawPanel)
            end
        end
        dxDrawRectangle(x,y,panelSize.x,panelSize.y,tocolor(42,42,42,animation))
        dxDrawRectangle(x+res(5),y+res(5),panelSize.x-res(200),panelSize.y-res(10),tocolor(52,52,52,animation))      
        drawText("Eladó ingatlan!",x+res(110),y+res(5),panelSize.x-res(115),panelSize.y-res(35),tocolor(200,200,200,animation),1,smallfont,"center","center",false,false,false,true)
        dxDrawImage(x+res(25),y+res(18),res(57),res(67),"files/images/markericon.png",0,0,0,tocolor(200,200,200,animation))       
        dxDrawRectangle(x+res(110),y+res(75),panelSize.x-res(115),panelSize.y-res(80),tocolor(52,52,52,animation))
               
        drawText("#e97619[P] #FFFFFFbetű",x+res(110),y+res(75),panelSize.x-res(115),panelSize.y-res(80),tocolor(200,200,200,animation),1,smallfont,"center","center",false,false,false,true)  
    end
end

addEventHandler("onClientMarkerHit",getRootElement(),function(hitElement)
    if hitElement == localPlayer and getElementData(source,"or:mainmarker") then 
        officeID = getElementData(source,"markerid")
        officeOwner = getElementData(source,"or:markerownername")
        if getElementData(source,"or:markerowner") > 0 then
            showPanelState = 1
        else
            showPanelState = 2
        end
        tick = getTickCount()
        removeEventHandler("onClientRender",root,drawPanel)
        addEventHandler("onClientRender",root,drawPanel)
        setElementData(localPlayer,"inmarker",true)
        setElementData(localPlayer,"canGoInside",true)
    end
end)

addEventHandler("onClientMarkerLeave",getRootElement(),function(leaveElement)
    if leaveElement == localPlayer then 
        tick = getTickCount()
        setElementData(localPlayer,"inmarker", false)
        showPanelState = 0
    end
end)

addEventHandler("onClientMarkerHit",getRootElement(),function(hitElement)
    if hitElement == localPlayer and getElementData(source,"or:officemarker") then 
        tick = getTickCount()
        setElementData(localPlayer,"inmarker",true)
    end
end)

-- Belépés+Kilépés
addEventHandler("onClientKey",root,function(key,press)
    local ownerID = getElementData(localPlayer,"user:id")
    if getElementData(localPlayer,"inmarker") then
        if key == "e" and press then
            setElementFrozen(localPlayer,true)
            tick = getTickCount()
            animstate = true
            rightanimstate = true -- jobb panel
            tickright = getTickCount() -- jobb panel
            fadeCamera (false, 0.5, 0, 0, 0 )
            setTimer ( fadeCameraDelayed, 2000, 1)
            
            if not getElementData(localPlayer,"inOffice") then
                setTimer(function()
                    if getElementData(localPlayer,"canGoInside") then
                        triggerEvent("load >> loading",localPlayer,localPlayer)
                    else
                        fadeCamera(true, 0.5)
                        setElementFrozen(localPlayer,false)
                        outputChatBox(exports.oCore:getServerPrefix("red-dark", "Játékfejlesztő", 2).."Eladó cég ingatlanjába nem tudsz bemenni!", 255, 255, 255, true)
                    end
                    triggerServerEvent("teleport >> office",localPlayer,localPlayer)
                end,500,1)
            else
                setTimer(function()
                    triggerEvent("load >> loading",localPlayer,localPlayer)
                    triggerServerEvent("teleport >> world",localPlayer,localPlayer)
                end,600,1)
            end
        end
    end
end)

-- Vásárlás rendszertől
addEventHandler("onClientMarkerHit",getRootElement(),function(hitElement)
    if hitElement == localPlayer and getElementData(source,"or:mainmarker") then 
        if getElementData(source,"or:markerowner") == 0 then
            setElementData(localPlayer,"canBuyBySystem",true)
            local mid = getElementData(source,"markerid")
            setElementData(localPlayer,"canBuyMarkerID",mid)
            outputChatBox(exports.oCore:getServerPrefix("green-dark", "Játékfejlesztő", 2).."Ez az iroda jelenleg eladó! Ára: 500.000 dollár! Megvételhez [P] betű!", 255, 255, 255, true)
            setElementData(localPlayer,"canGoInside", false)
        end
    end
end)

addEventHandler("onClientMarkerLeave",getRootElement(),function(leaveElement)
    if leaveElement == localPlayer and getElementData(source,"or:mainmarker") then 
        if getElementData(source,"or:markerowner") == 0 then
            setElementData(localPlayer,"canBuyBySystem",false)
            showPanelState = 0
        end
    end
end)

addEventHandler("onClientKey",root,function(key,press)
    if getElementData(localPlayer,"canBuyBySystem") then
        if key == "p" and press then
            local markerid = getElementData(localPlayer,"canBuyMarkerID")
            triggerServerEvent("business >> buy >> system",localPlayer,localPlayer, markerid)
        end
    end
end)

-- Eladás rendszernek
addEventHandler("onClientMarkerHit",getRootElement(),function(hitElement)
    if hitElement == localPlayer and getElementData(source,"or:mainmarker") then 
        local mid = getElementData(source,"markerid")
        setElementData(localPlayer,"canSellMarkerID",mid)
        setElementData(localPlayer,"canSellToSystem",true)
    end
end)

addEventHandler("onClientMarkerLeave",getRootElement(),function(leaveElement)
    if leaveElement == localPlayer and getElementData(source,"or:mainmarker") then 
        setElementData(localPlayer,"canSellToSystem",false) 
    end
end)

addCommandHandler("sellpropertygamedev", function()
    if getElementData(localPlayer,"canSellToSystem") then
        local markerid = getElementData(localPlayer,"canSellMarkerID")
        triggerServerEvent("business >> sell >> system",localPlayer,localPlayer, markerid)
    end
end)

-- Laptophoz leülés
function drawLaptopToolTip()
    if getElementData(localPlayer,"laptopColIn") then
        local panelSize = Vector2(res(300),res(100))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        if not getElementData(localPlayer,"laptopSit") then
            drawText("A laptop kezeléséhez [E] betű!",panelPos.x+res(35),panelPos.y+res(450),panelSize.x-res(115),panelSize.y-res(80),tocolor(200,200,200),1,smallfont3,"center","center",false,false,false,true)  
        else
            drawText("A laptopból kilépéshez [backspace] gomb!",panelPos.x+res(35),panelPos.y+res(450),panelSize.x-res(115),panelSize.y-res(80),tocolor(200,200,200),1,smallfont3,"center","center",false,false,false,true)  
        end
    end
end
addEventHandler("onClientRender",root,drawLaptopToolTip)

addEventHandler("onClientColShapeHit", root, function(player)
    if player == localPlayer then     
        if getElementData(source,"laptopCol") then 
            setElementData(localPlayer,"laptopColIn", true)
        end
    end
end)

addEventHandler("onClientColShapeLeave", root, function(player)
    if player == localPlayer then     
        if getElementData(source,"laptopCol") then 
            setElementData(localPlayer,"laptopColIn", false)
        end
    end
end)

addEventHandler("onClientKey",root,function(key,press)
    if key == "e" and press then
        if getElementData(localPlayer,"laptopColIn") then 
            if not getElementData(localPlayer,"laptopSit") then    
                setElementData(localPlayer,"laptopSit",true)
                exports.oInterface:toggleHud(true)
                showChat(false)
                fadeCamera (false, 0.5, 0, 0, 0 )
                setTimer ( fadeCameraDelayed, 2000, 1)
                triggerServerEvent("sit >> laptop", localPlayer, localPlayer)
                setElementFrozen(localPlayer,true)
                setTimer(function()
                    fadeCamera(true, 0.5)
                    setCameraMatrix(1384.8747558594,-1222.8857421875,81.638771057129, 1385.9475097656,-1221.4114990234,80.481994628906)
                    setElementData(localPlayer,"showLaptop",true)
                    showCursor(true)
                end, 1000, 1)
            end
        end
    elseif key == "backspace" and press then
        if getElementData(localPlayer,"laptopColIn") then 
            setElementData(localPlayer,"laptopSit",false)
            setElementData(localPlayer,"showLaptop",false)
            showCursor(false)
            fadeCamera (false, 0.5, 0, 0, 0 )
            setTimer ( fadeCameraDelayed, 2000, 1)
            setTimer(function()
                fadeCamera(true, 0.5)
                setCameraTarget(localPlayer)
                setElementFrozen(localPlayer,false)
                setPedAnimation(localPlayer)
                exports.oInterface:toggleHud(false)
                showChat(true)
            end, 1000, 1)
        end
    end
end)

-- Főnöki részleghez való érkezés
function drawOfficeToolTip()
    if getElementData(localPlayer,"bossColIn") and not getElementData(localPlayer,"showLaptop") then
        local celsius = 0
        local panelSize = Vector2(res(300),res(100))
        local panelPos = Vector2(sx/2-panelSize.x/2,sy/2-panelSize.y/2)
        for k, v in pairs(getElementsByType("marker")) do
            if getElementData(v,"or:mainmarker") then
                if getElementData(v,"or:markerowner") == getElementData(localPlayer,"user:id") then
                    celsius = tonumber(getElementData(v, "or:temperature"))
                end
            end
        end
        
        local ar, ag, ab = r, g, b
        if celsius <= 15 then -- kék
            ar, ag, ab = 39, 81, 188
        elseif celsius > 15 and celsius < 20 then -- világoskék
            ar, ag, ab = 39, 148, 188
        elseif celsius > 20 and celsius < 25 then -- zöld
            ar, ag, ab = 43, 188, 39
        elseif celsius > 25 and celsius < 28 then -- halvány sárga
            ar, ag, ab = 172, 44, 44
        elseif celsius > 28 and celsius < 32 then -- sárga
            ar, ag, ab = 119, 44, 25
        elseif celsius > 32 then -- piros
            ar, ag, ab = 198, 33, 33
        end

        core:drawWindow(panelPos.x+res(830),panelPos.y+res(450),panelSize.x-res(50),panelSize.y, "Irodai információ", 1)  
        dxDrawRectangle(panelPos.x+res(845),panelPos.y+res(505),panelSize.x-res(80),panelSize.y-res(75),tocolor(60,60,60)) 
        dxDrawRectangle(panelPos.x+res(845),panelPos.y+res(505),((panelSize.x-res(80))/40)*celsius,panelSize.y-res(75),tocolor(ar, ag, ab, 200))
        drawText("Jelenlegi hőmérséklet",panelPos.x+res(845),panelPos.y+res(475),panelSize.x-res(80),panelSize.y-res(75),tocolor(200,200,200),1,smallfont,"center","center",false,false,false,true)
        drawText(celsius.." °C",panelPos.x+res(845),panelPos.y+res(505),panelSize.x-res(80),panelSize.y-res(75),tocolor(200,200,200),1,smallfont,"center","center",false,false,false,true)

    end
end
addEventHandler("onClientRender",root,drawOfficeToolTip)

addEventHandler("onClientColShapeHit", root, function(player)
    if player == localPlayer then    
        if getElementData(source,"bossCol") then 
            setElementData(localPlayer,"bossColIn", true)
        end
    end
end)

addEventHandler("onClientColShapeLeave", root, function(player)
    if player == localPlayer then     
        if getElementData(source,"bossCol") then 
            setElementData(localPlayer,"bossColIn", false)
        end
    end
end)



-- Egyebek
function fadeCameraDelayed()
    if (isElement(localPlayer)) then
          fadeCamera(true, 0.5)
    end
end