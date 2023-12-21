sx, sy = guiGetScreenSize()

local zoom = math.min(1, 0.75 + (sx - 1024) * (1 - 0.75) / (1600 - 1024))
function res(value) return value * zoom end
function resFont(value) return math.floor(res(value)) end

function getFont(name, size)
    return exports.oFont:getFont(name, size)
end

local panel = {
    size = res(Vector2(1114, 591)),
    visible = false,
    hovered = false,
}
panel.position = Vector2(sx / 2 - panel.size.x / 2, sy / 2 - panel.size.y / 2)

local currentPage = 3
local pages = {
    [1] = {
        name = 'info',
        visibleName = 'Tagok'
    },
    [2] = {
        name = 'property',
        visibleName = 'Vagyon'
    },
    [3] = {
        name = 'settings',
        visibleName = 'Beállítások'
    }
}

local currentShop = false

local scrollHover = false
local memberScroll = 0
local currentPickup = false
local lastClick = getTickCount()
local currentShopMarker = false
local carshopVehicles = {}

local markerScroll = 0
local selectedMarker = 1

addEventHandler('onClientElementDataChange', localPlayer, function(dataName, oldValue, newValue)
    if localPlayer.type == 'player' then 
        if dataName == 'user:loggedin' then
            local now = getRealTime().timestamp 
            localPlayer:setData('joinTime', now)

            triggerServerEvent("updateMemberData", localPlayer, localPlayer, 'lastLogin', now)
        end

        if dataName == 'char:name' then 
            triggerServerEvent("updateMemberData", localPlayer, localPlayer, 'charName', newValue)
        end
    end
end)

panel.render = function()
    panel.hovered = false
    scrollHover = false

    local position = panel.position
    local size = panel.size

    if not loadedShops[currentShop] then 
        togglePanel(false)
        return
    end

    local theShop = loadedShops[currentShop]
    local isOwner = false

    for memberId, member in pairs(theShop.members) do
        if member.charId == localPlayer:getData('char:id') then 
            isOwner = member.owner == 1
            break
        end
    end

    local rightLine = res(Vector2(57, size.y))
    local topLine = res(Vector2(size.x, 50))

    dxDrawRoundedRectangle(position.x, position.y, size.x, size.y, 10, tocolor(40, 40, 40, 255), false, false) --BG
    dxDrawRoundedRectangle(position.x, position.y, rightLine.x, rightLine.y, 10, tocolor(30, 30, 30, 255), false, false) --Right line

    local iconSize = res(Vector2(32, 32))
    for key, page in pairs(pages) do 
        local pos = Vector2(position.x + ((rightLine.x / 2) - (iconSize.x / 2)), position.y + topLine.y + res(10) + ((key - 1) * (iconSize.y + res(20))))

        if isMouseInPosition(pos, iconSize) then 
            panel.hovered = 'page|' .. key
        end

        dxDrawImage(pos, iconSize, 'assets/icons/' .. page.name .. '.png', 0, 0, 0, tocolor(255, 255, 255, (panel.hovered == 'page|' .. key or currentPage == key) and 255 or 76))
    end 

    dxDrawRoundedRectangle(position.x, position.y, topLine.x, topLine.y, 10, tocolor(30, 30, 30, 255), false, false) --Top line
    dxDrawImage(position.x + res(10), position.y + res(10), res(40), res(35), "assets/logo.png") --logo

    dxDrawText(theShop.name, position + Vector2(res(60), 0), topLine, tocolor(200, 200, 200), 1, getFont("condensed", resFont(15)), 'left', 'center')

    -- dxDrawText(pages[currentPage].visibleName, position, topLine, tocolor(200, 200, 200), 1, getFont("condensed", resFont(15)), 'center', 'center')

    local closeSize = res(Vector2(32, 32))
    local closePos = Vector2(position.x + size.x - closeSize.x - res(5), position.y + (topLine.y / 2) - (closeSize.y / 2))
    if isMouseInPosition(closePos, closeSize) then 
        panel.hovered = 'closePanel'
    end
    dxDrawImage(closePos, closeSize, 'assets/close.png', 0, 0, 0, panel.hovered == 'closePanel' and tocolor(unpack(red)) or tocolor(200, 200, 200))

    size = size - Vector2(rightLine.x, topLine.y)
    position = position + Vector2(rightLine.x, topLine.y)

    if currentPage == 1 then --Tagok
        local lineH = res(35)
        for i=0, 13 do 
            local pos = Vector2(position.x + res(20), position.y + res(25) + (i * lineH))
            local size = Vector2(size.x - res(40), lineH)

            dxDrawRectangle(pos, size, i % 2 == 0 and tocolor(45, 45, 45) or tocolor(30, 30, 30))
            if isMouseInPosition(pos, size) then 
                scrollHover = 'members';
            end

            local id = 'ID'
            local name = 'Név'
            local lastLogin = 'Utolsó bejelentkezés'
            local selledCars = 'Eladott autók'

            local member = theShop.members[i == 0 and 0 or i + memberScroll]
            if i == 0 or member then 
                if member then 
                    id = member.charId or '-1'
                    name = member.charName or 'Ismeretlen'
                    lastLogin = getDate(member.lastLogin or 0, true)
                    selledCars = member.selledCars or 0
                end

                dxDrawText(id, pos + Vector2(res(20)), Vector2(res(70), lineH), tocolor(200, 200, 200), 1, getFont("condensed", resFont(10)), "center", "center")

                local nameFont = getFont('condensed', resFont(10))

                dxDrawText(name:gsub('_', ' '), pos + Vector2(res(70), 0), Vector2(res(350), lineH), tocolor(200, 200, 200), 1, nameFont, "center", "center")

                if member and member.owner == 1 then 
                    dxDrawText('', pos + Vector2(res(5)), Vector2(res(350), lineH), tocolor(200, 200, 200), 1, getFont("fontawesome2", resFont(10)), "left", "center")
                end

                dxDrawText(lastLogin, pos + Vector2(res(350), 0), Vector2(res(350), lineH), tocolor(200, 200, 200), 1, getFont("condensed", resFont(10)), "center", "center")
                dxDrawText(selledCars, pos + Vector2(res(700), 0), Vector2(res(350), lineH), tocolor(200, 200, 200), 1, getFont("condensed", resFont(10)), "center", "center")

                if member and isOwner then 
                    if isMouseInPosition(pos + Vector2(size.x - lineH, 0), Vector2(lineH, lineH)) then 
                        panel.hovered = 'removePlayer|' .. (i + memberScroll)
                    end
                    dxDrawImage(pos + Vector2(size.x - lineH, 0), Vector2(lineH, lineH), 'assets/close.png', 0, 0, 0, panel.hovered == 'removePlayer|' .. (i + memberScroll) and tocolor(unpack(red)) or tocolor(200, 200, 200))

                    local ownerPos = pos + Vector2(size.x - (lineH * 2) - res(5), 0)
                    if isMouseInPosition(ownerPos, Vector2(lineH, lineH)) then 
                        panel.hovered = 'changeOwner|' .. (i + memberScroll)
                    end
                    dxDrawText(member.owner == 1 and '' or '', ownerPos, Vector2(lineH, lineH), panel.hovered == 'changeOwner|' .. (i + memberScroll) and tocolor(unpack(sColor)) or tocolor(200, 200, 200), 1, getFont("fontawesome2", resFont(11)), "center", "center")
                end
            end
        end

        if #theShop.members > 13 then 
            drawScrollbar(position.x + size.x - res(20), position.y + res(25), res(3), size.y - res(50), memberScroll, #theShop.members, 13, tocolor(unpack(sColor)), tocolor(30, 30, 30))
        end
    elseif currentPage == 2 then --Vagyon / Járművek a shopban
        local lineH = res(35)
        for i=1, 14 do 
            local pos = Vector2(position.x + res(20), position.y + res(25) + ((i - 1) * lineH))
            local size = Vector2(res(250), lineH)

            if isMouseInPosition(pos, size) then 
                scrollHover = 'marker'
            end
            dxDrawRectangle(pos, size, i % 2 ~= 0 and tocolor(45, 45, 45) or tocolor(30, 30, 30))
            local markerId = i + markerScroll
            if theShop.markers[markerId] then
                if isMouseInPosition(pos, size) then 
                    panel.hovered = 'marker|' .. markerId
                end
                if markerId == selectedMarker then 
                    dxDrawRectangle(pos + Vector2(0, res(2)), Vector2(res(2), size.y - res(4)), tocolor(unpack(sColor)))
                end

                dxDrawText('Férőhely #' .. markerId, pos + Vector2(res(5), 0), size, tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'left',   'center')
            end
        end

        if selectedMarker then 
            local size = size - Vector2(res(320), res(50))
            local pos = Vector2(position.x + res(290), position.y + res(25))

            local markData = theShop.markers[selectedMarker]

            dxDrawRectangle(pos, size, tocolor(45, 45, 45))
            local vehicle = findCar(markData.haveCar)
            local noCar = false
            if markData.haveCar and isElement(vehicle) then 
                local shopData = vehicle:getData('inCarshop')
                if shopData then 
                    local memberId = findMember(shopData.shopId, shopData.addedBy)

                    dxDrawText('Jármű adatok:\n', pos, size, tocolor(200, 200, 200), 1, getFont('condensed', res(15)) , 'center', 'top', false, false, false, true)
                    dxDrawText('ID: ' .. vehicle:getData('veh:id') .. '\nModell: ' .. exports.oVehicle:getModdedVehicleName(vehicle) ..
                    '\nBerakta: ' .. sColor2 .. (theShop.members[memberId] and theShop.members[memberId].charName or 'Ismeretlen'), pos + Vector2(0, res(70)), size, tocolor(200, 200, 200), 1, getFont('condensed', res(11)) , 'center', 'top', false, false, false, true)
                
                    local datas = carPanel.processData(vehicle)
                    for key, value in pairs(datas) do 
                        dxDrawText(value[1] .. ' ' .. value[2], pos + Vector2(res(15), (key - 1) * res(30)), size, tocolor(200, 200, 200), 1, getFont('condensed', res(11)) , 'center', 'center', false, false, false, true)
                    end
                else 
                    noCar = true
                end
            else 
                noCar = true
            end
                
            if noCar then 
                dxDrawText('Ezen a helyen nincs jármű!', pos, size, tocolor(200, 200, 200), 1, getFont('condensed', res(12)) , 'center', 'center', false, false, false, true)
            end
        end

    elseif currentPage == 3 then --Beállítások
        position = position + res(Vector2(20, 20))
        size = size - res(Vector2(40, 40))

        dxDrawRectangle(position, size, tocolor(30, 30, 30))

        local bankSize = res(Vector2((size.x - res(60)) / 2, 140))
        local bankPos = position + res(Vector2(20, 20))
        dxDrawRectangle(bankPos, bankSize, tocolor(40, 40, 40))
        dxDrawText('Bankszámla kezelése', bankPos + Vector2(0, res(5)), bankSize, tocolor(200, 200, 200), 1, getFont('condensed', res(11)), 'center', 'top')
        dxDrawText('\nEgyenleg: ' .. (theShop.bank >= 0 and green2 or red2) .. (theShop.bank or 0) .. '#c8c8c8$', bankPos + Vector2(0, res(10)), bankSize, tocolor(200, 200, 200), 1, getFont('condensed', res(9)), 'center', 'top', false, false, false, true)

        local inputPos = bankPos + Vector2(res(20), res(50))
        local inputSize = Vector2(bankSize.x - res(40), res(30))
        if isMouseInPosition(inputPos, inputSize) then 
            panel.hovered = 'input|bank'
        end
        dxDrawRectangle(inputPos, inputSize, tocolor(30, 30, 30))
        dxDrawText(getInputText('bank'), inputPos, inputSize, tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'center', 'center')
        dxDrawText('$', inputPos - Vector2(res(10), 0), inputSize, tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'right', 'center')

        if isOwner then 
            local buttonSize = Vector2((bankSize.x - res(60)) / 2, res(30))
            local leftPos = bankPos + Vector2(res(20), res(90))
            if isMouseInPosition(leftPos, buttonSize) then 
                panel.hovered = 'bankin'
            end
            --dxDrawRectangle(leftPos, buttonSize, panel.hovered == 'bankin' and tocolor(unpack(sColor)) or tocolor(30, 30, 30))
            --dxDrawText('Befizetés', leftPos, buttonSize, panel.hovered == 'bankin' and tocolor(30, 30, 30) or tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'center', 'center')
            exports.oCore:dxDrawButton(leftPos.x, leftPos.y, buttonSize.x, buttonSize.y, 30, 30, 30, 170, "Befizetés", tocolor(200, 200, 200), 1, getFont('condensed', res(10)), false)

            local rightPos = bankPos + Vector2(bankSize.x - res(20) - buttonSize.x, res(90))
            if isMouseInPosition(rightPos, buttonSize) then 
                panel.hovered = 'bankout'
            end
           -- dxDrawRectangle(rightPos, buttonSize, panel.hovered == 'bankout' and tocolor(unpack(sColor)) or tocolor(30, 30, 30))
           -- dxDrawText('Kivétel', rightPos, buttonSize, panel.hovered == 'bankout' and tocolor(30, 30, 30) or tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'center', 'center')
           exports.oCore:dxDrawButton(rightPos.x, rightPos.y, buttonSize.x, buttonSize.y, 30, 30, 30, 170, "Kivétel", tocolor(200, 200, 200), 1, getFont('condensed', res(10)), false)
        else 
            dxDrawText('Nem vagy tulajdonos!', inputPos + Vector2(0, res(45)), inputSize, tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'center', 'center')
        end            

        local addSize = bankSize
        local addPos = Vector2(bankPos.x + bankSize.x + res(20), position.y + res(20))
        dxDrawRectangle(addPos, addSize, tocolor(40, 40, 40))
        dxDrawText('Játékos felvétele', addPos + Vector2(0, res(5)), addSize, tocolor(200, 200, 200), 1, getFont('condensed', res(11)), 'center', 'top')

        inputPos = addPos + Vector2(res(20), res(40))
        inputSize = Vector2(addSize.x - res(40), res(30))
        if isMouseInPosition(inputPos, inputSize) then 
            panel.hovered = 'input|playerAdd'
        end
        dxDrawRectangle(inputPos, inputSize, tocolor(30, 30, 30)) --input
        dxDrawText(getInputText('playerAdd'), inputPos, inputSize, tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'center', 'center')

        local buttonPos = addPos + Vector2(res(20), res(90))
        local buttonSize = Vector2(addSize.x - res(40), res(30))
        
        if isOwner then
            if isMouseInPosition(buttonPos, buttonSize) then 
                panel.hovered = 'addPlayer'
            end
            --dxDrawRectangle(buttonPos, buttonSize, panel.hovered == 'addPlayer' and tocolor(unpack(sColor)) or tocolor(30, 30, 30)) --button
            --dxDrawText('Felvétel', buttonPos, buttonSize, panel.hovered == 'addPlayer' and tocolor(30, 30, 30) or tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'center', 'center') --button
            exports.oCore:dxDrawButton(buttonPos.x, buttonPos.y, buttonSize.x, buttonSize.y, 30, 30, 30, 170, "Felvétel", tocolor(200, 200, 200), 1, getFont('condensed', res(10)), false)
        else 
            dxDrawText('Nem vagy tulajdonos!', buttonPos, buttonSize, tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'center', 'center') --button
        end
    end
end

panel.click = function(button, state, clickX, clickY)
    if button == 'left' then 
        if state == 'down' then 
            if panel.hovered then 
                local theShop = loadedShops[currentShop]

                if string.find(panel.hovered, 'page|') then 
                    local page = tonumber(split(panel.hovered, '|')[2])

                    currentPage = page
                    selectedMarker = 1
                    markerScroll = 0
                    memberScroll = 0
                    return
                end

                if string.find(panel.hovered, 'input|') then 
                    local inputName = split(panel.hovered, '|')[2]
                    setInputActive(inputName)
                    return
                end

                if string.find(panel.hovered, 'removePlayer|') then 
                    local memberId = tonumber(split(panel.hovered, '|')[2])
                    triggerServerEvent('removePlayerFromShop', localPlayer, currentShop, memberId, theShop.members[memberId])
                    return   
                end

                if string.find(panel.hovered, 'changeOwner|') then 
                    local memberId = tonumber(split(panel.hovered, '|')[2])
                    triggerServerEvent('changeCarshopOwnerStatus', localPlayer, currentShop, memberId, theShop.members[memberId])
                    return
                end

                if string.find(panel.hovered, 'marker|') then 
                    local markerId = tonumber(split(panel.hovered, '|')[2])
                    selectedMarker = markerId
                    return
                end

                if panel.hovered == 'addPlayer' then 
                    local target = getInputValue('playerAdd')
                    if target ~= '' and target:len() >= 1 then 
                        local targetPlayer = exports.oCore:getPlayerFromPartialName(localPlayer, target, 1)
                        if targetPlayer then 
                            local have = havePlayerShop(targetPlayer)
                            if have then 
                                exports.oInfobox:outputInfoBox('Játékos már tagja egy kereskedésnek!', 'error')
                                return
                            end

                            triggerServerEvent('addPlayerToShop', localPlayer, currentShop, targetPlayer)
                            exports.oInfobox:outputInfoBox('Sikeresen felvetted a játékost.', 'success')
                        else 
                            exports.oInfobox:outputInfoBox('Játékos nem található!', 'warning')
                        end
                    else 
                        exports.oInfobox:outputInfoBox('Hibás a megadott Név/ID!', 'warning')
                    end
                elseif panel.hovered == 'closePanel' then 
                    togglePanel(false)
                elseif panel.hovered == 'bankin' then
                    if lastClick + 200 > getTickCount() then 
                        return
                    end
                    local amount = tonumber(getInputValue('bank') or 0)
                    if amount and amount > 0 then 
                        if localPlayer:getData('char:money') >= amount then 
                            triggerServerEvent('updateShopBank', localPlayer, currentShop, amount, '+')
                            lastClick = getTickCount()
                        else 
                            exports.oInfobox:outputInfoBox('Nincs elég pénz nálad!', 'error')
                        end
                    else 
                        exports.oInfobox:outputInfoBox('Érvénytelen összeg!', 'error')
                    end
                elseif panel.hovered == 'bankout' then 
                    if lastClick + 200 > getTickCount() then 
                        return
                    end
                    local amount = tonumber(getInputValue('bank') or 0)
                    if amount and amount > 0 then 
                        triggerServerEvent('updateShopBank', localPlayer, currentShop, amount, '-')
                        lastClick = getTickCount()
                    else 
                        exports.oInfobox:outputInfoBox('Érvénytelen összeg!', 'error')
                    end
                end
            end
        end
    end
end

panel.onKey = function(button, state)
    if not state then 
        return
    end

    local theShop = loadedShops[currentShop]

    if button == 'mouse_wheel_down' then         
        if scrollHover == 'members' then 
            if #theShop.members > 13 then 
                memberScroll = math.min(#theShop.members - 13, memberScroll + 1)
            end
        elseif scrollHover == 'marker' then 
            if #theShop.markers > 14 then 
                markerScroll = math.min(#theShop.members - 13, markerScroll + 1)
            end
        end
    elseif button == 'mouse_wheel_up' then 
        if scrollHover == 'members' then 
            memberScroll = math.max(0, memberScroll - 1)
        elseif scrollHover == 'marker' then 
            markerScroll = math.max(0, markerScroll - 1)
        end
    end
end

function togglePanel(force, shopId)
    panel.visible = not panel.visible

    if force ~= nil then 
        panel.visible = force
    end

    removeEventHandler('onClientRender', root, panel.render)
    removeEventHandler('onClientClick', root, panel.click)
    removeEventHandler('onClientKey', root, panel.onKey)

    showCursor(panel.visible)
    showChat(not panel.visible)

    if panel.visible then 
        addEventHandler('onClientRender', root, panel.render)
        addEventHandler('onClientClick', root, panel.click)
        addEventHandler('onClientKey', root, panel.onKey)

        currentShop = shopId
        currentPage = 1
    end
end

addEventHandler('onClientResourceStop', resourceRoot, function()
    if panel.visible then 
        togglePanel(false)
    end
end)

addEvent('receiveUsedCarshops', true)
addEventHandler('receiveUsedCarshops', localPlayer, function(data)
    loadedShops = data
end)

addEventHandler('onClientPickupHit', root, function(hitElement, dim)
    if hitElement == localPlayer and dim and not localPlayer.inVehicle then 
        if source:getData('usedCarshop') then 
            currentPickup = {
                element = source,
                dbId = source:getData('usedCarshop'),
            }
            removeEventHandler('onClientRender', root, renderPickupText)
            addEventHandler('onClientRender', root, renderPickupText)

            removeEventHandler('onClientKey', root, pickupInteract)
            addEventHandler('onClientKey', root, pickupInteract)

            if isPlayerInShop(localPlayer, currentPickup.dbId) then 
                outputChatBox(syntax .. ' Kereskedés kezeléséhez nyomd meg az ' .. sColor2 .. '"E"#FFFFFF gombot.', 255, 255, 255, true)
            end
        end
    end
end)

addEventHandler('onClientPickupLeave', root, function(hitElement, dim)
    if hitElement == localPlayer and dim then 
        if source:getData('usedCarshop') then 
            closePickupInteract()

            if panel.visible then 
                togglePanel(false)
            end
        end
    end
end)

function closePickupInteract()
    removeEventHandler('onClientRender', root, renderPickupText)
    removeEventHandler('onClientKey', root, pickupInteract)
    currentPickup = false
end

function renderPickupText()
    if currentPickup then 
        local shop = loadedShops[currentPickup.dbId]

        if isElement(currentPickup.element) and shop then 
            local position = currentPickup.element.position + Vector3(-0.1,0,0.6)
            --local position = currentPickup.element.position
            local x, y = getScreenFromWorldPosition(position)
            
            if x and y then 
                if getElementData(localPlayer,"user:aduty") then
                    text = shop.name .. ' (ID: ' .. currentPickup.dbId .. ')'
                else
                    text = shop.name
                end

                local font = getFont('condensed', res(13))
                local width = font:getTextWidth(text, 1, false) + res(15)
                local height = font:getHeight(1) + res(5)

                --dxDrawRectangle(x - (width / 2), y - (height / 2), width + res(2), height + res(2), tocolor(20, 20, 20, 100))
                dxDrawRectangle(x - (width / 2), y - (height / 2), width, height, tocolor(30, 30, 30, 150))
                dxDrawText(text, Vector2(x - (width / 2), y - (height / 2)), Vector2(width, height), tocolor(200, 200, 200), 1, font, 'center', 'center')
            end
        end
    end
end

function pickupInteract(button, state)
    if button == 'e' and state then 
        if isPlayerInShop(localPlayer, currentPickup.dbId) then 
            togglePanel(true, currentPickup.dbId)
            closePickupInteract()
            cancelEvent()
        end
    end
end

addEventHandler('onClientMarkerHit', root, function(hitElement, dim)
    if hitElement == localPlayer and dim then 
        local shopId = source:getData('usedCarshop')
        if shopId and shopId > 0 then 
            local vehicle = localPlayer.vehicle
            if vehicle and (vehicle:getData('veh:owner') or -1) == (localPlayer:getData('char:id') or -1) then 
                if isPlayerInShop(localPlayer, shopId) then 
                    outputChatBox(syntax .. 'Kereskedésbe rakáshoz használd az ' .. sColor2 .. '"E"#FFFFFF gombot.', 255, 255, 255, true)
                    currentShopMarker = source
                    removeEventHandler('onClientKey', root, markerInteract)
                    addEventHandler('onClientKey', root, markerInteract)
                end
            end
        end
    end
end)

addEventHandler('onClientMarkerLeave', root, function(hitElement, dim)
    if hitElement == localPlayer and dim then 
        local shopId = source:getData('usedCarshop')
        if shopId and shopId > 0 then 
            currentShopMarker = false
            addPanel.close()
            removeEventHandler('onClientKey', root, markerInteract)
        end
    end
end)

function markerInteract(button, state)
    if button == 'e' and state then 
        addPanel.open(localPlayer.vehicle)
        cancelEvent()
    end
end

addPanel = {
    visible = false,
    hovered = false,

    render = function()
        addPanel.hovered = false

        if not isElement(addPanel.vehicle) or not localPlayer.vehicle or (localPlayer.vehicle ~= addPanel.vehicle) then 
            addPanel.close()
            return
        end

        local size = res(Vector2(350, 140))
        local pos = Vector2((sx / 2) - (size.x / 2), (sy / 2) - (size.y / 2))

        exports.oCore:drawWindow(pos.x, pos.y, size.x, size.y, "Jármű hozzáadása a kereskedésbe", 1) 
        --dxDrawRectangle(pos, size, tocolor(30, 30, 30))
        --dxDrawText('Jármű hozzáadása a kereskedésbe', pos, Vector2(size.x, res(20)), tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'center', 'center')

        --dxDrawText('Kereskedés neve: ' .. sColor2 ..currentShopMarker:getData('marker.name'), pos + Vector2(0, res(25)), Vector2(size.x, res(20)), tocolor(200, 200, 200), 1, getFont('condensed', res(8)), 'center', 'center', false, false, false, true)

        local closeSize = res(Vector2(20, 20))
        local closePos = pos + Vector2(size.x - closeSize.x, 0)
        if isMouseInPosition(closePos, closeSize) then 
            addPanel.hovered = 'close'
        end
        dxDrawImage(closePos, closeSize, 'assets/close.png', 0, 0, 0, addPanel.hovered == 'close' and tocolor(unpack(red)) or tocolor(200, 200, 200))

        local inputSize = Vector2(size.x - res(20), res(30))
        local inputPos = pos + Vector2(res(10), res(50))

        if isMouseInPosition(inputPos, inputSize) then
            addPanel.hovered = 'input|addVehicle'
        end
        dxDrawRectangle(inputPos, inputSize, tocolor(40, 40, 40))
        dxDrawText(getInputText('addVehicle'), inputPos, inputSize, tocolor(200, 200, 200), 1, getFont('condensed', res(11)), 'center', 'center')
        dxDrawText('$', inputPos, inputSize - Vector2(res(5)), tocolor(200, 200, 200), 1, getFont('condensed', res(12)), 'right', 'center')

        local buttonSize = Vector2(size.x - res(20), res(30))
        local buttonPos = pos + Vector2(res(10), res(95))
        if isMouseInPosition(buttonPos, buttonSize) then 
            addPanel.hovered = 'ok'
        end
        --dxDrawRectangle(buttonPos, buttonSize, addPanel.hovered == 'ok' and tocolor(unpack(sColor)) or tocolor(45, 45, 45))
        --dxDrawText('Berakás', buttonPos, buttonSize, addPanel.hovered == 'ok' and tocolor(30, 30, 30) or tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'center', 'center')

        exports.oCore:dxDrawButton(buttonPos.x, buttonPos.y, buttonSize.x, buttonSize.y, 30, 30, 30, 170, "Hozzáadás", tocolor(200, 200, 200), 1, getFont('condensed', res(10)), false)
    end,

    click = function(button, state)
        if button == 'left' and state == 'down' then 
            if addPanel.hovered then 
                if string.find(addPanel.hovered, 'input') then 
                    local inputName = split(addPanel.hovered, '|')[2]

                    setInputActive(inputName)                
                elseif addPanel.hovered == 'close' then 
                    addPanel.close()
                elseif addPanel.hovered == 'ok' then 
                    triggerServerEvent('addVehicleToShop', localPlayer, localPlayer.vehicle, currentShopMarker, tonumber(getInputValue('addVehicle')))
                    addPanel.close()
                end
            end
        end
    end,

    close = function()
        addPanel.vehicle = false
        addPanel.visible = false
        addPanel.hovered = false
        removeEventHandler('onClientRender', root, addPanel.render)
        removeEventHandler('onClientClick', root, addPanel.click)
    end,

    open = function(vehicle, marker)
        addPanel.close()

        addPanel.visible = true
        addPanel.vehicle = vehicle
        addEventHandler('onClientRender', root, addPanel.render)
        addEventHandler('onClientClick', root, addPanel.click)
    end
}

addEventHandler('onClientResourceStart', resourceRoot, function()
    for _, vehicle in pairs(Element.getAllByType('vehicle')) do 
        if vehicle:getData('inCarshop') then 
            carshopVehicles[vehicle] = vehicle:getData('inCarshop')
        end
    end
end)

addEventHandler('onClientElementDataChange', root, function(dataName, oldValue, newValue)
    if source.type == 'vehicle' then 
        if dataName == 'inCarshop' then 
            carshopVehicles[source] = newValue
        end
    end
end)

addEventHandler('onClientRender', root, function()
    local myPosition = localPlayer.position

    for vehicle, data in pairs(carshopVehicles) do 
        if isElement(vehicle) and data then 
            if isElementStreamedIn(vehicle) then 
                local vehiclePos = vehicle.position
                if getDistanceBetweenPoints3D(myPosition, vehiclePos) < 4 then 
                    vehicle.frozen = true

                    local x, y = getScreenFromWorldPosition(vehiclePos)
                    if x and y then 
                        local price = data.price or '-'
                        local text = exports.oVehicle:getModdedVehName(getElementModel(vehicle)) .. '\nÁr: ' .. sColor2 .. price .. '#c8c8c8$'
                        _dxDrawText(text:gsub("#%x%x%x%x%x%x", ""), x + 1, y + 1, x + 1, y + 1, tocolor(0, 0, 0), 1, getFont('condensed', res(12)), 'center', 'center', false, false, false, true)
                        _dxDrawText(text, x, y, x, y, tocolor(200, 200, 200), 1, getFont('condensed', res(12)), 'center', 'center', false, false, false, true)
                    end
                end
            end
        else
            carshopVehicles[vehicle] = nil
        end
    end
end)

carPanel = {
    visible = false,
    hovered = false,
    data = {},

    processData = function(vehicle)
        if vehicle then 
            carPanel.vehicle = vehicle
        end

        carPanel.data = {}

        local carshopData = carPanel.vehicle:getData('inCarshop')
        local tunings = carPanel.vehicle:getData("veh:engineTunings") or {}

        for key, value in pairs(tunings) do 
            local data = split(value, '-')
            tunings[data[1]] = tonumber(data[2])
        end

        for tuningName, visibleName in pairs(performanceTunings) do 
            local level = tunings[tuningName] or 0

            table.insert(carPanel.data, {visibleName .. ' Tuning: ', tuningLevels[level]})
        end

        table.insert(carPanel.data, {'Ár:', green2 .. carshopData.price .. '#c8c8c8$'})

        return carPanel.data
    end,

    close = function()
        carPanel.visible = false
        carPanel.hovered = false

        removeEventHandler('onClientRender', root, carPanel.render)
        removeEventHandler('onClientClick', root, carPanel.click)
    end,

    open = function(vehicle)
        carPanel.close()

        carPanel.vehicle = vehicle
        carPanel.processData()
        addEventHandler('onClientRender', root, carPanel.render)
        addEventHandler('onClientClick', root, carPanel.click)
    end,

    render = function()
        carPanel.hovered = false

        if not isElement(carPanel.vehicle) or carPanel.vehicle ~= localPlayer.vehicle then 
            carPanel.close()
            return
        end

        local shopData = carPanel.vehicle:getData('inCarshop')
        if not shopData then 
            carPanel.close()
            return
        end

        local size = res(Vector2(400, 280))
        local pos = Vector2(sx / 2 - (size.x / 2), sy / 2 - (size.y / 2))
        dxDrawRectangle(pos, size, tocolor(25, 25, 25))

        local topLine = res(20)
        dxDrawText('Használt autókereskedés', pos, Vector2(size.x, topLine), tocolor(200, 200, 200), 1, getFont('condensed', res(11)), 'center', 'center')

        if isMouseInPosition(pos + Vector2(size.x - topLine, 0), Vector2(topLine, topLine)) then 
            carPanel.hovered = 'close'
        end
        dxDrawImage(pos + Vector2(size.x - topLine, 0), Vector2(topLine, topLine), 'assets/close.png', 0, 0, 0, carPanel.hovered == 'close' and tocolor(unpack(red)) or tocolor(200, 200, 200)) 

        local lineH = res(30)
        local datas = carPanel.data
        for i=1, 7 do 
            local pos = Vector2(pos.x, pos.y + (i * lineH))

            dxDrawRectangle(pos, Vector2(size.x, lineH), i % 2 == 0 and tocolor(35, 35, 35) or tocolor(40, 40, 40))
            dxDrawRectangle(pos + Vector2(0, res(2)), Vector2(res(2), lineH - res(4)), tocolor(unpack(sColor)))

            if datas[i] then 
                dxDrawText(datas[i][1], pos + Vector2(res(10), 0), Vector2(size.x, lineH), tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'left', 'center', false, false, false, true)

                dxDrawText(datas[i][2], pos, Vector2(size.x - res(10), lineH), tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'right', 'center', false, false, false, true)
            end
        end

        local buttonSize = res(Vector2(200, 25))
        local buttonPos = Vector2(pos.x + (size.x / 2) - (buttonSize.x / 2), pos.y + size.y - buttonSize.y - res(8))
        if isMouseInPosition(buttonPos, buttonSize) then 
            carPanel.hovered = 'buy'
        end
        dxDrawRectangle(buttonPos, buttonSize, carPanel.hovered == 'buy' and tocolor(unpack(sColor)) or tocolor(40, 40, 40))
        dxDrawText('Vásárlás', buttonPos, buttonSize, carPanel.hovered == 'buy' and tocolor(30, 30, 30) or tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'center', 'center')


        if isPlayerInShop(localPlayer, shopData.shopId) then 
            buttonPos = buttonPos + Vector2(0, res(50))
            if isMouseInPosition(buttonPos, buttonSize) then 
                carPanel.hovered = 'out'
            end
            dxDrawRectangle(buttonPos, buttonSize, carPanel.hovered == 'out' and tocolor(unpack(sColor)) or tocolor(40, 40, 40))
            dxDrawText('Kivétel', buttonPos, buttonSize, carPanel.hovered == 'out' and tocolor(30, 30, 30) or tocolor(200, 200, 200), 1, getFont('condensed', res(10)), 'center', 'center')
        end
    end,

    click = function(button, state)
        if button == 'left' and state == 'down' then 
            if carPanel.hovered == 'close' then
                carPanel.close()
            elseif carPanel.hovered == 'buy' or carPanel.hovered == 'out' then
                local carshopData = carPanel.vehicle:getData('inCarshop')
                if carPanel.hovered == 'out' or localPlayer:getData('char:money') >= (carshopData.price or 0) then 
                    triggerServerEvent('buyVehicleFromShop', localPlayer, carPanel.vehicle, carPanel.hovered == 'out')
                    carPanel.close()
                else 
                    exports.oInfobox:outputInfoBox('Nincs elég pénzed!', 'error')
                end
            end
        end
    end
}

addEventHandler('onClientVehicleEnter', root, function(player, seat)
    if player == localPlayer and seat == 0 then 
        local shopData = source:getData('inCarshop') or false
        if shopData then 
            carPanel.open(source)
        end
    end
end)