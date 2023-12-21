dxDrawRoundedRectangle = function(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end

_dxDrawText = dxDrawText
dxDrawText = function(text, position, size, ...)
    return _dxDrawText(text, position.x, position.y, position.x + size.x, position.y + size.y, ...)
end

getMousePosition = function()
    if not isCursorShowing() then 
        return false, false
    end

    local cursorX, cursorY = getCursorPosition()

    return cursorX * sx, cursorY * sy
end

isMouseInPosition = function(position, size)
    if not isCursorShowing() then 
        return false
    end

    local sx, sy = guiGetScreenSize()
    local cursorX, cursorY = getMousePosition()

    return (cursorX >= position.x and cursorX <= (position.x + size.x)) and (cursorY >= position.y and cursorY <= (position.y + size.y))
end

drawScrollbar = function(x, y, w, h, currentScroll, contentCount, showContent, color, bgColor)
                                --jelenlegi scroll, Mennyi érték van, mennyi látszhat
    bgColor = bgColor or tocolor(40, 40, 40)

    dxDrawRectangle(x, y, w, h, bgColor) --BG

    local scrollBar = (h / contentCount) * showContent
    dxDrawRectangle(x, y + ((scrollBar / showContent) * currentScroll), w, math.min(scrollBar, h), color)
end

getDate = function(timestamp, formated)
    local rt = getRealTime(timestamp)
    local minute = rt.minute
    local hour = rt.hour
    local second = rt.second

    if minute < 10 then 
        minute = "0" .. minute
    end
    if hour < 10 then 
        hour = "0" .. hour
    end
    if second < 10 then 
        second = "0" .. second 
    end
    
    local temp = split(string.format("%04d|%02d|%02d|%02d|%02d|%02d", rt.year + 1900, rt.month + 1, rt.monthday, hour, minute, second),"|")
    
    return formated and tostring(temp[1].."-"..temp[2].."-"..temp[3].." "..temp[4]..":"..temp[5]..":"..temp[6]) or temp
end