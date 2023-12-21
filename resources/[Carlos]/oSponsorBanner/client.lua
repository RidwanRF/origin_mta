local sx, sy = guiGetScreenSize()
local myX, myY = 1768, 992

local tick1 = getTickCount()
local tick2 = getTickCount() + 200
local tick3 = getTickCount() - 100
local tick4 = getTickCount() + 800

addEventHandler("onClientRender", root, function()
    dxDrawImage(0, sy*0.02, sx, sy, "src/banner_bg.png", 0, 0, 0, tocolor(255, 255, 255, 200), true) 

    local a1 = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount() - tick1) / 5000, "SineCurve")
    local a2 = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount() - tick2) / 6000, "SineCurve")
    local a3 = interpolateBetween(1, 0, 0, 0, 0, 0, (getTickCount() - tick3) / 3500, "SineCurve")
    local a4 = interpolateBetween(1, 0, 0, 0, 0, 0, (getTickCount() - tick4) / 2000, "SineCurve")

    dxDrawImage(0, sy*0.02, sx, sy, "src/1.png", 0, 0, 0, tocolor(255, 255, 255, 255 * a1), true) 
    dxDrawImage(0, sy*0.02, sx, sy, "src/2.png", 0, 0, 0, tocolor(255, 255, 255, 255 * a2), true) 
    dxDrawImage(0, sy*0.02, sx, sy, "src/3.png", 0, 0, 0, tocolor(255, 255, 255, 255 * a3), true) 
    dxDrawImage(0, sy*0.02, sx, sy, "src/4.png", 0, 0, 0, tocolor(255, 255, 255, 255 * a4), true) 

    dxDrawImage(0, sy*0.105, sx*0.9, sy*0.9, "src/text_1.png", 0, 0, 0, tocolor(255, 255, 255, 255), true) 
    dxDrawImage(sx*0.2, sy*0.2, sx*0.8, sy*0.8, "src/text_2.png", 0, 0, 0, tocolor(255, 255, 255, 255), true) 

    dxDrawText("Egri Dobó István Gimnázium", 0, 0, sx, sy*0.08, tocolor(255, 255, 255, 255), 1, exports.oFont:getFont("p_bo", 16/myX*sx), "center", "center")
    dxDrawText("Szavazz a #fa880f11A#ffffff-ra!", 0, 0, sx, sy*0.09, tocolor(255, 255, 255, 255), 1, exports.oFont:getFont("p_ba", 30/myX*sx), "center", "bottom", false, false, false, true)
end)    

function printInfos()
    outputChatBox("", 255, 255, 255, true)
    outputChatBox("A játék lehetőségét és szervert az #fa880fOriginalRoleplay #ffffffbiztosítja.", 255, 255, 255, true)
    outputChatBox("Csatlakozz #fa880fMagyarország egyik legismertebb #ffffffRP közösségéhez még ma: ", 255, 255, 255, true)
    outputChatBox("- #fa880fDiscord:#ffffff https://dc.originalrp.eu", 255, 255, 255, true)
    outputChatBox("- #fa880fFacebook:#ffffff https://www.facebook.com/OriginalRoleplayOfficial", 255, 255, 255, true)
    outputChatBox("- #fa880fInstagram:#ffffff https://www.instagram.com/originalrp2k20/", 255, 255, 255, true)
    outputChatBox("- #fa880fTiktok:#ffffff https://www.tiktok.com/@originalroleplaymtasa", 255, 255, 255, true)
    outputChatBox("- #fa880fWeb:#ffffff https://originalrp.eu", 255, 255, 255, true)
    outputChatBox("")
end
printInfos()

setTimer(printInfos, 1000 * 60 * 10, 0)

addCommandHandler( "infos", printInfos )