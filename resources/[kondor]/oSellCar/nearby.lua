local nearbyMarkers = {
    show = false,

    render = function()
        local myPos = localPlayer.position

        for _, marker in pairs(Element.getAllByType('marker', resourceRoot, true)) do 
            local shopId = marker:getData('usedCarshop')
            if shopId and loadedShops[shopId] then 
                local markerPos = marker.position + Vector3(0, 0, 1)
                if getDistanceBetweenPoints3D(myPos, markerPos) < 10 then 
                    local x, y = getScreenFromWorldPosition(markerPos)
                    if x and y then 
                        local markerId = marker:getData('marker.id') or 0

                        local text = 'Kereskedés név: ' .. loadedShops[shopId].name .. '\nKereskedés ID: ' .. shopId .. '\nMarker ID: ' .. markerId

                        dxDrawText(text, Vector2(x + 1, y + 1), Vector2(), tocolor(0, 0, 0), 1, getFont('condensed', res(13)), 'center', 'center')
                        dxDrawText(text, Vector2(x, y), Vector2(), tocolor(255, 255, 255), 1, getFont('condensed', res(13)), 'center', 'center')
                    end
                end
            end
        end
    end
}

addCommandHandler('nearbyshopmarkers', function(cmd)
    if (getElementData(localPlayer, "user:admin") or 0) >= 1 then
        nearbyMarkers.show = not nearbyMarkers.show
        removeEventHandler('onClientRender', root, nearbyMarkers.render)

        if nearbyMarkers.show then 
            addEventHandler('onClientRender', root, nearbyMarkers.render)
        end
    end
end)