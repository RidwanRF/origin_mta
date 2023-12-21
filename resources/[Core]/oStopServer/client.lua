local sx, sy = guiGetScreenSize()
local myX, myY = 1768, 992

local core = exports.oCore

function serverStopBanner()
    core:dxDrawShadowedText("SZERVER ÚJRAINDÍTÁS", 0, 0, sx, sy*0.05, tocolor(250, 67, 57), tocolor(0, 0, 0, 255), 1/myX*sx, exports.oFont:getFont("condensed", 15), "center", "center")
    
    local time = getElementData(resourceRoot, "timeToRestart")
    core:dxDrawShadowedText(string.format("%02d:%02d", time[1], time[2]), 0, 0, sx, sy*0.12, tocolor(250, 67, 57), tocolor(0, 0, 0, 255), 1/myX*sx, exports.oFont:getFont("condensed", 22), "center", "center")
    core:dxDrawShadowedText("A szerver hamarosan újraindul. A jelenlegi tevékenységedet mihamarabb fejezd be!", 0, 0, sx, sy*0.1, tocolor(250, 67, 57), tocolor(0, 0, 0, 255), 0.8/myX*sx, exports.oFont:getFont("condensed", 15), "center", "bottom")
end

addEvent("setServerRestartState", true)
addEventHandler("setServerRestartState", resourceRoot, function(state)
    if state then 
        addEventHandler("onClientRender", root, serverStopBanner)
    else
        removeEventHandler("onClientRender", root, serverStopBanner)
    end
end)
