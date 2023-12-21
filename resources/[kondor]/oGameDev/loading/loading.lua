local sx,sy = guiGetScreenSize()
zoom = math.min(1,0.75 + (sx - 1024) * (1 - 0.75) / (1600 - 1024))
function res(value) return value * zoom end
function resFont(value) return math.floor(res(value)) end
function drawText(text, x, y, w, h, ...)
    if not text or not x or not y or not w or not h then return false end
    return dxDrawText(text, x, y, (x + w), (y + h), ...)
end
local tick = getTickCount()
local tick2 = getTickCount()
local font = dxCreateFont("files/fonts/RobotoL.ttf",resFont(12))
local count = 0
local removecount = 0

function render()
    local progress = ( getTickCount() - tick )/ 1900000
    local progress2 = ( getTickCount() - tick )/ 2000
    local progress3 = ( getTickCount() - tick )/ 1000
    local alpha = interpolateBetween(360000, 0, 0, 0, 0, 0, progress, "Linear")
    local alpha2 = interpolateBetween(220, 0, 0, 255, 0, 0, progress2, "SineCurve")
    if alpha <= removecount then
        alpha3 = interpolateBetween(200, 0, 0, 0, 0, 0, progress3, "Linear")
        if alpha3 == 0 then
            setElementFrozen(localPlayer,false)
            removeEventHandler("onClientRender",root,render)
        end
    else
        alpha3 = interpolateBetween(0, 0, 0, 200, 0, 0, progress3, "Linear")
    end
    dxDrawRectangle(0,0,sx,sy,tocolor(233, 118, 25,255),true)
    dxDrawRectangle(0,0,sx,sy,tocolor(32,32,32,alpha2),true)
    dxDrawImage(sx/2-res(100)/2,sy/2-res(100)/2,res(100),res(100),"loading/smallspin.png",0,0,0,tocolor(23,23,23,alpha3),true)
    dxDrawImage(sx/2-res(100)/2,sy/2-res(100)/2,res(100),res(100),"loading/spin.png",alpha,0,0,tocolor(233, 118, 25,alpha3),true)
    if getElementDimension(localPlayer) == 0 then
        drawText("Kilépés folyamatban...",0,res(80),sx,sy,tocolor(200,200,200,alpha3),1,font,"center","center",false,false,true,true)
    else
        drawText("Betöltés folyamatban...",0,res(80),sx,sy,tocolor(200,200,200,alpha3),1,font,"center","center",false,false,true,true)
        if alpha <= count then
            drawText("Üdvözöllek, #e97619"..getPlayerName(localPlayer).."#c8c8c8\nJó munkát!",0,res(115),sx,sy,tocolor(200,200,200,alpha3),1,font,"center","center",false,false,true,true)
        end
    end
end

addEvent("load >> loading",true)
addEventHandler("load >> loading",root,function(player)
    if not isEventHandlerAdded("onClientRender", root, render) then
        count = 358900
        removecount = count - math.random(180,400)
        addEventHandler("onClientRender",root,render)
        tick = getTickCount()
        tick2 = getTickCount()
    end
end)