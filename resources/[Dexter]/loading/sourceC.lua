local screenX, screenY = guiGetScreenSize()
local sp1W, sp1H = 100,100
local posX,posY = screenX/2 - sp1W/2, screenY/2 - sp1H/2

local mainText = "Valami"
local subText = "Valami2"

loadingConfig = {
    mainText = "Valami",
    subText = "Valami2",
    time = 3000,
    eventName = "eventName"
}
local alphaTick = getTickCount()
local rotTick = getTickCount()
local alphaAnimState = "up"
local zoomOut = false
local zoom = 0

local bebasBold = dxCreateFont("fonts/bebasBold.otf", 24)

function startLoadingScreen(text, text2, time, eventName)
    loadingConfig.mainText = text
    loadingConfig.subText = text2
    loadingConfig.time = time
    loadingConfig.eventName = eventName
    alphaTick = getTickCount()
    rotTick = getTickCount()
    zoom = 0
    setTimer(function()
        loadingConfig.subText = "Előkészítés"
        setTimer(function()
            endingScene()
        end, time, 1)
    end, time, 1)
end

function endingScene()
    loadingConfig.subText = false
    zoomOut = getTickCount()
    alphaAnimState = "down"
    alphaTick = getTickCount()
end

addEventHandler("onClientRender", getRootElement(), function()
    if alphaAnimState == "up" then 
        alpha = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount() - alphaTick)/500, "Linear")
    elseif alphaAnimState == "down" then 
        alpha = interpolateBetween(1, 0, 0, 0, 0, 0, (getTickCount() - alphaTick)/500, "Linear")
    end
    rot = interpolateBetween(0,0,0,360,0,0,(getTickCount() - rotTick)/1000, "Linear")
    if rot >= 360 then 
        rotTick = getTickCount()
        rot = 0
    end
    if zoomOut then
        zoom = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount() - zoomOut) / 500, "InOutQuad")
    end
    dxDrawImage(0,0,screenX, screenY, "img/1.png",0,0,0,tocolor(255,255,255,255*alpha))
    dxDrawImage(posX - (2/sp1W*screenX*zoom),posY - (2/sp1W*screenX*zoom),100 + (4/sp1W*screenX*zoom), 100+ (4/sp1W*screenX*zoom), "img/sp2.png",0,0,0,tocolor(0,0,0,100*alpha))
    dxDrawImage(posX- (2/sp1W*screenX*zoom),posY- (2/sp1W*screenX*zoom),100 + (4/sp1W*screenX*zoom), 100 + (4/sp1W*screenX*zoom), "img/sp1.png",-rot,0,0,tocolor(255,255,255,255*alpha))
    dxDrawText(loadingConfig.mainText, screenX/2, posY+150, screenX/2, posY + 100 + (4/sp1W*screenX*zoom), tocolor(255,255,255,255*alpha),0.85 + (35/sp1W*zoom), bebasBold, "center", "center")
    if loadingConfig.subText then 
        dxDrawText(loadingConfig.subText, screenX/2, posY+200, screenX/2 , posY + 120, tocolor(255,255,255,255*alpha),0.55, bebasBold, "center", "center")
    end
    
end)

startLoadingScreen("Interior betöltése", "Objectek betöltése", 5000, "nextSubText")