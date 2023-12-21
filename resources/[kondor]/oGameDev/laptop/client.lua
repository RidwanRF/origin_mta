local sx, sy = guiGetScreenSize()
local laptopSize = Vector2(res(1350),res(785))
local panelPos = Vector2(sx/2-laptopSize.x/2,sy/2-laptopSize.y/2)

function getFont(name, size)
    return exports.oFont:getFont(name, size)
end

function drawText(text, x, y, w, h, ...)
    if not text or not x or not y or not w or not h then return false end
    return dxDrawText(text, x, y, (x + w), (y + h), ...)
end

local showPanels = 0
local showDetPanels = 0


local hotGuiName = GuiEdit(-1000, -1000, 0, 0, "", false)
hotGuiName.maxLength = 2
local hotactivatedBoxes = {hotGuiName}
local hotdefaultBoxText = {"Hőfok °C"}

local bankGuiName = GuiEdit(-1000, -1000, 0, 0, "", false)
bankGuiName.maxLength = 10
local bankactivatedBoxes = {bankGuiName}
local bankdefaultBoxText = {"Összeg"}

addEventHandler("onClientElementDataChange", root, function(data, old, new)
	if data == "showLaptop" then
		if new == false then
			showPanels = 0
		end
	end
end)

function renderLaptop()
	if getElementData(localPlayer,"showLaptop") then--if getPlayerName(localPlayer) == "kondor" then--if getElementData(localPlayer,"showLaptop") then
		local year, month, day, hours, minutes, seconds = RealTime(getRealTime()["timestamp"])
		dxDrawImage(panelPos.x+res(146), panelPos.y+res(45), res(1058), res(646),"files/images/laptop/wallpapper.png",0,0,0,tocolor(255,255,255,255))
		dxDrawImage(panelPos.x, panelPos.y, laptopSize.x, laptopSize.y,"files/images/laptop/bg.png",0,0,0,tocolor(255,255,255,255), true)

		drawText(hours..":"..minutes,panelPos.x+res(175), panelPos.y+res(655), laptopSize.x+res(575), res(12),tocolor(200,200,200,255),1,getFont('condensed', res(10)),"center","center",false,false,true,true)
    	drawText(year.."."..month.."."..day,panelPos.x+res(175), panelPos.y+res(655), laptopSize.x+res(575), res(40),tocolor(200,200,200,255),1,getFont('condensed', res(10)),"center","center",false,false,true,true)

    	drawText("Cégkezelés",panelPos.x+res(190),panelPos.y+res(110),res(54),res(77),tocolor(200,200,200,255),1,getFont('condensed', res(12)),"center","center",false,false,true,true)
    	dxDrawImage(panelPos.x+res(195),panelPos.y+res(70),res(50),res(50),"files/images/laptop/ocode.png",0,0,0,tocolor(255,255,255,255), true) -- fejlesztés
    	
    	drawText("Bútorok",panelPos.x+res(290),panelPos.y+res(110),res(54),res(77),tocolor(200,200,200,255),1,getFont('condensed', res(12)),"center","center",false,false,true,true)
    	dxDrawImage(panelPos.x+res(290),panelPos.y+res(70),res(50),res(50),"files/images/laptop/ocode.png",0,0,0,tocolor(255,255,255,255), true) -- bútorok
    	
    	drawText("Netbank",panelPos.x+res(390),panelPos.y+res(110),res(54),res(77),tocolor(200,200,200,255),1,getFont('condensed', res(12)),"center","center",false,false,true,true)
    	dxDrawImage(panelPos.x+res(390),panelPos.y+res(70),res(50),res(50),"files/images/laptop/ocode.png",0,0,0,tocolor(255,255,255,255), true) -- bank
    	
    	drawText("Fűtés/Hűtés",panelPos.x+res(510),panelPos.y+res(110),res(54),res(77),tocolor(200,200,200,255),1,getFont('condensed', res(12)),"center","center",false,false,true,true)
    	dxDrawImage(panelPos.x+res(510),panelPos.y+res(70),res(50),res(50),"files/images/laptop/ocode.png",0,0,0,tocolor(255,255,255,255), true) -- fűtés
	end
end
addEventHandler("onClientRender", root, renderLaptop)

function renderPanels()
	if showPanels == 1 then
		core:drawWindow(panelPos.x+res(530),panelPos.y+res(280),res(300),res(230), "Fűtés/hűtés kezelése", 1)
		drawText("A rendszer itt fogja tartani a hőfokot:",panelPos.x+res(530),panelPos.y+res(220),res(300),res(200),tocolor(200,200,200,255),1,getFont('condensed', res(10)),"center","center",false,false,true,true)
		drawText("Az óránkénti díj "..hotBill.."$/óra",panelPos.x+res(530),panelPos.y+res(390),res(300),res(200),tocolor(200,200,200,255),1,getFont('condensed', res(10)),"center","center",false,false,true,true)

		dxDrawRectangle(panelPos.x+res(605), panelPos.y+res(350), res(150), res(30), tocolor(60,60,60))

		if hotactivatedBoxes[1].text == "" then
            drawText(hotdefaultBoxText[1], panelPos.x+res(605), panelPos.y+res(350), res(150), res(30), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        else
            drawText(hotactivatedBoxes[1].text, panelPos.x+res(605), panelPos.y+res(350), res(150), res(30), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        end

        core:dxDrawButton(panelPos.x+res(540), panelPos.y+res(400), res(280), res(30), r, g, b, 170, "Beállít", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)
		core:dxDrawButton(panelPos.x+res(540), panelPos.y+res(440), res(280), res(30), r, g, b, 170, "Kikapcsolás", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)

    elseif showPanels == 2 then
    	for k, v in pairs(getElementsByType("marker")) do
    		if getElementData(v,"or:mainmarker") then
    			if getElementData(v,"or:markerowner") == getElementData(localPlayer,"user:id") then
    				businessMoney = tonumber(getElementData(v, "or:businessmoney"))
    			end
    		end
    	end

    	core:drawWindow(panelPos.x+res(470),panelPos.y+res(220),res(400),res(300), "OTP - Netbank", 1)
    	drawText("Jelenlegi összeg a cég számláján: ",panelPos.x+res(330),panelPos.y+res(70),res(500),res(400),tocolor(200,200,200,255),1,getFont('condensed', res(10)),"center","center",false,false,true,true)
		drawText(businessMoney,panelPos.x+res(680),panelPos.y+res(70),res(500),res(400),tocolor(200,200,200,255),1,getFont('condensed', res(10)),"left","center",false,false,true,true)
		
		dxDrawRectangle(panelPos.x+res(545), panelPos.y+res(320), res(250), res(40), tocolor(60,60,60))

		if bankactivatedBoxes[1].text == "" then
            drawText(bankdefaultBoxText[1], panelPos.x+res(545), panelPos.y+res(320), res(250), res(40), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        else
            drawText(bankactivatedBoxes[1].text, panelPos.x+res(545), panelPos.y+res(320), res(250), res(40), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
        end

		core:dxDrawButton(panelPos.x+res(495), panelPos.y+res(400), res(350), res(40), r, g, b, 170, "Kivétel", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)
		core:dxDrawButton(panelPos.x+res(495), panelPos.y+res(450), res(350), res(40), r, g, b, 170, "Berakás", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)
	elseif showPanels == 3 then
		core:drawWindow(panelPos.x+res(170),panelPos.y+res(170),res(1007),res(470), "Cégkezelés", 1)

		core:dxDrawButton(panelPos.x+res(180), panelPos.y+res(205), res(200), res(40), r, g, b, 170, "Fejlesztők felvétele", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)
		core:dxDrawButton(panelPos.x+res(180), panelPos.y+res(255), res(200), res(40), r, g, b, 170, "Fejlesztők kezelése", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)
		core:dxDrawButton(panelPos.x+res(180), panelPos.y+res(305), res(200), res(40), r, g, b, 170, "Fejlesztés kezelése", tocolor(200, 200, 200, 255), 1, getFont('condensed', res(10)), false)
	end
end
addEventHandler("onClientRender", root, renderPanels)

function renderDetailsPanels()
	if showDetPanels == 1 then
		dxDrawRectangle(panelPos.x+res(410),panelPos.y+res(205),res(750),res(420), tocolor(60,60,60))
		drawText("Munkavállalók listája", panelPos.x+res(410),panelPos.y+res(10),res(750),res(420), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")

		dxDrawRectangle(panelPos.x+res(465),panelPos.y+res(270),res(200),res(220), tocolor(80,80,80))
		drawText(devname1, panelPos.x+res(465),panelPos.y+res(180),res(200),res(220), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
		drawText(devmoney1.."$/óra", panelPos.x+res(465),panelPos.y+res(320),res(200),res(220), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
		drawText(showrates1, panelPos.x+res(465),panelPos.y+res(350),res(200),res(220), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
		

		dxDrawRectangle(panelPos.x+res(685),panelPos.y+res(270),res(200),res(220), tocolor(80,80,80))
		drawText(devname2, panelPos.x+res(685),panelPos.y+res(180),res(200),res(220), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
		drawText(devmoney2.."$/óra", panelPos.x+res(685),panelPos.y+res(320),res(200),res(220), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
		drawText(showrates2, panelPos.x+res(685),panelPos.y+res(350),res(200),res(220), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
		

		dxDrawRectangle(panelPos.x+res(905),panelPos.y+res(270),res(200),res(220), tocolor(80,80,80))
		drawText(devname3, panelPos.x+res(905),panelPos.y+res(180),res(200),res(220), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
		drawText(devmoney3.."$/óra", panelPos.x+res(905),panelPos.y+res(320),res(200),res(220), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
		drawText(showrates3, panelPos.x+res(905),panelPos.y+res(350),res(200),res(220), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
		

		drawText("A fejlesztők bére a cég számlájáról kerül levonásra. Ahhoz, hogy a dolgozóid\nmegmaradjanak mindig kell legyen elegendő pénz a számlán. Ellenkező esetben\na kedvük romlik meg, majd eltávoznak a cégtől!", panelPos.x+res(410),panelPos.y+res(370),res(750),res(420), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
	elseif showDetPanels == 2 then
		dxDrawRectangle(panelPos.x+res(410),panelPos.y+res(205),res(750),res(420), tocolor(60,60,60))
		drawText("Munkavállalóid listája", panelPos.x+res(410),panelPos.y+res(10),res(750),res(420), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
	elseif showDetPanels == 3 then
		dxDrawRectangle(panelPos.x+res(410),panelPos.y+res(205),res(750),res(420), tocolor(60,60,60))
		drawText("Fejlesztésed információi", panelPos.x+res(410),panelPos.y+res(10),res(750),res(420), tocolor(200,200,200,200), 1.0, getFont('condensed', res(10)), "center", "center")
	end
end
addEventHandler("onClientRender", root, renderDetailsPanels)

function generateDeveloperDetails()
	showrates1 = rates[math.random(1,5)]
	showrates2 = rates[math.random(1,5)]
	showrates3 = rates[math.random(1,5)]
	devmoney1 = takeMoney[math.random(1,5)]
	devmoney2 = takeMoney[math.random(1,5)]
	devmoney3 = takeMoney[math.random(1,5)]
	devname1 = firstNames[math.random(1,5)].." "..lastNames[math.random(1,5)]
	devname2 = firstNames[math.random(1,5)].." "..lastNames[math.random(1,5)]
	devname3 = firstNames[math.random(1,5)].." "..lastNames[math.random(1,5)]
end
generateDeveloperDetails()

addEventHandler("onClientClick", root, function(button, state)
	if button == "left" and state == "down" then
		if getElementData(localPlayer,"showLaptop") then 	
			if core:isInSlot(panelPos.x+res(510),panelPos.y+res(70),res(50),res(50)) then -- Hőfok rész megnyitása
				if showPanels == 1 then
					showPanels = 0
				else
					showPanels = 1
					hotactivatedBoxes[1].text = ""
				end
			elseif core:isInSlot(panelPos.x+res(605), panelPos.y+res(350), res(150), res(30)) then -- Hőfok
				if showPanels == 1 then
					hotactivatedBoxes[1]:bringToFront()
	            	toggleControl("chatbox",false)
	            end
	        elseif core:isInSlot(panelPos.x+res(540), panelPos.y+res(400), res(280), res(30)) then -- Hőfok állítás
				if showPanels == 1 then
					for k, v in pairs(getElementsByType("marker")) do
    					if getElementData(v,"or:mainmarker") then
    						if getElementData(v,"or:markerowner") == getElementData(localPlayer,"user:id") then
    							hotmarker = v
    						end
    					end
    				end
					triggerServerEvent("set >> temperature", localPlayer, localPlayer, hotmarker, hotactivatedBoxes[1].text)
					hotactivatedBoxes[1].text = ""
	            	toggleControl("chatbox",true)
	            end    
	        elseif core:isInSlot(panelPos.x+res(540), panelPos.y+res(440), res(280), res(30)) then -- Hőfok kikapcs
				if showPanels == 1 then
					for k, v in pairs(getElementsByType("marker")) do
    					if getElementData(v,"or:mainmarker") then
    						if getElementData(v,"or:markerowner") == getElementData(localPlayer,"user:id") then
    							hotmarker = v
    						end
    					end
    				end
					triggerServerEvent("off >> temperature", localPlayer, localPlayer, hotmarker)
					hotactivatedBoxes[1].text = ""
	            	toggleControl("chatbox",true)
	            end    
	        elseif core:isInSlot(panelPos.x+res(390),panelPos.y+res(70),res(50),res(50)) then -- Banki rész megnyitása
				if showPanels == 2 then
					showPanels = 0
				else
					showPanels = 2
					bankactivatedBoxes[1].text = ""
				end
			elseif core:isInSlot(panelPos.x+res(545), panelPos.y+res(320), res(250), res(40)) then -- Pénzösszeg
				if showPanels == 2 then
					bankactivatedBoxes[1]:bringToFront()
	            	toggleControl("chatbox",false)
	            end
			elseif core:isInSlot(panelPos.x+res(495), panelPos.y+res(400), res(350), res(40)) then -- kivétel
				if showPanels == 2 then
					for k, v in pairs(getElementsByType("marker")) do
    					if getElementData(v,"or:mainmarker") then
    						if getElementData(v,"or:markerowner") == getElementData(localPlayer,"user:id") then
    							bankmarker = v
    						end
    					end
    				end
    				
					triggerServerEvent("take >> money >> business", localPlayer, localPlayer, bankmarker, tonumber(bankactivatedBoxes[1].text))
					bankactivatedBoxes[1].text = ""
					toggleControl("chatbox",true)
				end
			elseif core:isInSlot(panelPos.x+res(495), panelPos.y+res(450), res(350), res(40)) then -- berakás
				if showPanels == 2 then
					for k, v in pairs(getElementsByType("marker")) do
    					if getElementData(v,"or:mainmarker") then
    						if getElementData(v,"or:markerowner") == getElementData(localPlayer,"user:id") then
    							bankmarker = v
    						end
    					end
    				end
    				
					triggerServerEvent("give >> money >> business", localPlayer, localPlayer, bankmarker, tonumber(bankactivatedBoxes[1].text))
					bankactivatedBoxes[1].text = ""
					toggleControl("chatbox",true)
				end
			elseif core:isInSlot(panelPos.x+res(195),panelPos.y+res(70),res(50),res(50)) then -- Fejlesztői rész megnyitása
				if showPanels == 3 then
					showPanels = 0
				else
					showPanels = 3
				end
			elseif core:isInSlot(panelPos.x+res(180), panelPos.y+res(205), res(200), res(40)) then -- Fejlesztők felvétele megnyitása
				if showPanels == 3 then
					if showDetPanels == 1 then
						showDetPanels = 0
					else
						showDetPanels = 1
					end
				end
			elseif core:isInSlot(panelPos.x+res(180), panelPos.y+res(255), res(200), res(40)) then -- Fejlesztők kezelésének megnyitása
				if showPanels == 3 then
					if showDetPanels == 2 then
						showDetPanels = 0
					else
						showDetPanels = 2
					end
				end
			elseif core:isInSlot(panelPos.x+res(180), panelPos.y+res(305), res(200), res(40)) then -- Fejlesztés kezelésének megnyitása
				if showPanels == 3 then
					if showDetPanels == 3 then
						showDetPanels = 0
					else
						showDetPanels = 3
					end
				end
			end
		end
	end
end)
