local sx, sy = guiGetScreenSize() 
local myX, myY = 1600, 900

local job_elements = {
    ped = false,
    markers = {},
}

local fonts = {
    ["condensed-15"] = exports.oFont:getFont("condensed", 15),
}

local inAnimation = false
local pC1x, pC1y, pC1z, pC2x, pC2y, pC2z

local animation_tick = getTickCount() 
local animation_state = "open"

local talk_text
local talking_timers = {}

local choose_menu_showing = false
local selected_job = 0

function renderTalkPanel()
    local alpha 
    
    if animation_state == "open" then 
        alpha = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount() - animation_tick)/1000, "Linear")
    else
        alpha = interpolateBetween(1, 0, 0, 0, 0, 0, (getTickCount() - animation_tick)/1000, "Linear")
    end

    dxDrawRectangle(0, sy*0.9, sx*0.5*alpha, sy*0.1, tocolor(30, 30, 30, 255*alpha))
    dxDrawRectangle(sx-sx*0.5*alpha, sy*0.9, sx/2, sy*0.1, tocolor(30, 30, 30, 255*alpha))

    if talk_text then 
        dxDrawText(color.."[Peter]: #dcdcdc"..texts[talk_text[1]][talk_text[2]], 0, sy*0.9, sx, sy, tocolor(220, 220, 220, 255*alpha), 1/myX*sx, fonts["condensed-15"], "center", "center", false, false, false, true)
    end

    if choose_menu_showing then 
        local startx = sx*0.02
        for k, v in ipairs(jobs) do 
            if core:isInSlot(startx, sy*0.92, 60/myX*sx, 60/myY*sy) or selected_job == k then 
                dxDrawImage(startx, sy*0.92, 60/myX*sx, 60/myY*sy, "files/"..k..".png", 0, 0, 0, tocolor(r, g, b, 255*alpha))
            else
                dxDrawImage(startx, sy*0.92, 60/myX*sx, 60/myY*sy, "files/"..k..".png", 0, 0, 0, tocolor(220, 220, 220, 255*alpha))
            end

            startx = startx + 60/myX*sx + sx*0.02
        end

        local jobtext = jobs[selected_job] or "Válassz ki egy munkát!"

        if selected_job > 0 then 
            dxDrawText(jobs[selected_job],sx*0.2, sy*0.9, sx*0.2+sx*0.8, sy*0.9+sy*0.05, tocolor(220,220,220,255*alpha), 1/myX*sx, fonts["condensed-15"], "center", "center", false, false, false, true)
            dxDrawText("Ha ezt a munkát szeretnéd végezni, akkor nyomd meg az "..color.."[Enter] #dcdcdcbillentyűt!",sx*0.2, sy*0.95, sx*0.2+sx*0.8, sy*0.95+sy*0.05, tocolor(220,220,220,255*alpha), 0.8/myX*sx, fonts["condensed-15"], "center", "center", false, false, false, true)
        else
            dxDrawText("Válassz ki egy munkát, az ikonokra való kattintással.",sx*0.2, sy*0.9, sx*0.2+sx*0.8, sy*0.9+sy*0.1, tocolor(220,220,220,255*alpha), 1/myX*sx, fonts["condensed-15"], "center", "center", false, false, false, true)
        end
    end
end

function key(key, state)
    if choose_menu_showing then 
        if key == "mouse1" then 
            if state then 
                local startx = sx*0.02
                for k, v in ipairs(jobs) do 
                    if core:isInSlot(startx, sy*0.92, 60/myX*sx, 60/myY*sy) or selected_job == k then 
                        selected_job = k
                    end
        
                    startx = startx + 60/myX*sx + sx*0.02
                end
            end
        elseif key == "enter" then 
            if selected_job > 0 then 
                choose_menu_showing = false 
                talkingAnimation("job_select_"..selected_job)
            end
        end
    end
end

function click(button, state, _, _, _, _, _, element)
    if button == "right" then 
        if state == "up" then 
            if element then 
                if core:getDistance(localPlayer, element) < 2 then 
                    if element == job_elements.ped then 
                        if not inAnimation then 
                            inAnimation = true 
                            startTalkAnimation()
                        end
                    end
                end
            end
        end
    end
end
addEventHandler("onClientClick", root, click)

function startTalkAnimation()
    setElementAlpha(localPlayer, 0)
    pC1x, pC1y, pC1z, pC2x, pC2y, pC2z = getCameraMatrix()
    smoothMoveCamera(pC1x, pC1y, pC1z, pC2x, pC2y, pC2z, bossPed.pos.x, bossPed.pos.y-3, bossPed.pos.z+0.6, bossPed.pos.x, bossPed.pos.y, bossPed.pos.z+0.6, 1000)

    animation_state = "open"
    animation_tick = getTickCount() 
    addEventHandler("onClientRender", root, renderTalkPanel)
    addEventHandler("onClientKey", root, key)

    showChat(false)
    interface:toggleHud(true)

    setTimer(function() 
        setElementData(localPlayer, "user:hideWeapon", true)
        bindKey("backspace", "up", stopTalkAnimation) 
        talkingAnimation("job_start") 
    end, 1000, 1)
end

function stopTalkAnimation()
    setElementAlpha(localPlayer, 255)
    smoothMoveCamera(bossPed.pos.x, bossPed.pos.y-3, bossPed.pos.z+0.6, bossPed.pos.x, bossPed.pos.y, bossPed.pos.z+0.6, pC1x, pC1y, pC1z, pC2x, pC2y, pC2z, 1000)

    animation_state = "close"
    animation_tick = getTickCount() 

    showChat(true)
    interface:toggleHud(false)
    unbindKey("backspace", "up", stopTalkAnimation)

    killTalkingTimers() 

    setTimer(function() 
        setElementData(localPlayer, "user:hideWeapon", false)
        setCameraTarget(localPlayer, localPlayer) 
        inAnimation = false  
        removeEventHandler("onClientRender", root, renderTalkPanel) 
        removeEventHandler("onClientKey", root, key)
        talk_text = false 
        talking_timers = {}
    end, 1000, 1)
end

function talkingAnimation(text_group)
    talking_timers = {}
    local timer_time = 0

    setPedAnimation(job_elements.ped, "GHANDS", "gsign5", -1, true, false, false, false)
    for k, v in ipairs(texts[text_group]) do 
        timer_time = timer_time + string.len(v)*text_wait

        if k == 1 then 
            talk_text = {text_group, 1}
        elseif k == #texts[text_group] then 
            local timer = setTimer(function() 
                talk_text[2] = talk_text[2] + 1

                setTimer(function() 
                    talk_text = false 
                    setPedAnimation(job_elements.ped)
                    if string.find(text_group,"job_select_") then 
                        stopTalkAnimation()
                        createJobMarkers(selected_job)
                    elseif text_group == "job_start" then 
                        choose_menu_showing = true
                    end
                end, string.len(v)*text_wait, 1)
            end, timer_time,1)

            table.insert(talking_timers, #talking_timers+1, timer)
        else
            local timer = setTimer(function() 
                talk_text[2] = talk_text[2] + 1
            end, timer_time,1)

            table.insert(talking_timers, #talking_timers+1, timer)
        end
    end
end

function killTalkingTimers()
    for k, v in ipairs(talking_timers) do 
        if isTimer(v) then 
            killTimer(v)
        end
    end

    talking_timers = {}
end

function createJobElements()
    job_elements.ped = createPed(bossPed.skin, bossPed.pos.x, bossPed.pos.y, bossPed.pos.z, bossPed.rot )

    setElementFrozen(job_elements.ped, true)

    setElementData(job_elements.ped, "ped:name", "Peter Glover")
    setElementData(job_elements.ped, "ped:prefix", "Munkavezető")
end
createJobElements()

function destroyJobElements()
    destroyElement(job_elements.ped)
    destroyJobMarkers()
end

function createJobMarkers(job)
    if job == 1 then 
        local marker = customM:createCustomMarker(2153.1306152344, -1964.5854492188, 14.046875, 4.5, 235, 143, 52, 255, "forklift", "circle")
        setElementData(marker, "forkliftCreateMarker", true)
        table.insert(job_elements.markers, #job_elements.markers+1, marker)
    elseif job == 2 then 
        local trashbag_marker = customM:createCustomMarker(2200.552734375, -1970.9992675781, 13.584131240845, 4.5, 52, 147, 235, 255, "trashbag", "circle")
        setElementData(trashbag_marker, "trashbag:marker", true)
        table.insert(job_elements.markers, #job_elements.markers+1, trashbag_marker)

        local trashSortIntIn = customM:createCustomMarker(2209.8962402344, -2022.4278564453, 13.546875, 4.5, 52, 147, 235, 255, "home", "circle")
        setElementData(trashSortIntIn, "trashSortInt:in", true)
        table.insert(job_elements.markers, #job_elements.markers+1, trashSortIntIn)

        local trashSortIntOut = customM:createCustomMarker(2570.3776855469, -1301.9447021484, 1044.125, 4.5, 52, 147, 235, 255, "home", "circle")
        setElementInterior(trashSortIntOut, 2)
        setElementData(trashSortIntOut, "trashSortInt:out", true)
        table.insert(job_elements.markers, #job_elements.markers+1, trashSortIntOut)
    elseif job == 3 then 
    end
end
createJobMarkers(2)

function destroyJobMarkers()
    for k, v in ipairs(job_elements.markers) do 
        if isElement(v) then 
            destroyElement(v)
        end
    end
end
addEventHandler("onClientResourceStop", resourceRoot, destroyJobMarkers)