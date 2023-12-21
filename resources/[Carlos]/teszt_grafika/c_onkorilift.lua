GUIEditor_Window = {}
GUIEditor_Button = {}
GUIEditor_Label = {}

GUIEditor_Window[1] = guiCreateWindow(0.3875,0.2833,0.16,0.6117,"Válaszd ki melyik városba mész",true)
guiWindowSetMovable(GUIEditor_Window[1],false)
--GUIEditor_Button[1] = guiCreateButton(15,50,131,40,"Las Venturas",false,GUIEditor_Window[1])
GUIEditor_Button[2] = guiCreateButton(14,111,131,40,"Los Santos",false,GUIEditor_Window[1])
GUIEditor_Button[3] = guiCreateButton(15,50,131,40,"Las Venturas",false,GUIEditor_Window[1])
---GUIEditor_Label[1] = guiCreateLabel(20,287,156,23,"-------------------------",false,GUIEditor_Window[1])
guiLabelSetColor(GUIEditor_Label[1],255,255,0)
guiSetFont(GUIEditor_Label[1],"default-bold-small")
GUIEditor_Button[4] = guiCreateButton(17,160,126,41,"Bezár",false,GUIEditor_Window[1])
 
guiSetVisible(GUIEditor_Window[1], false)
showCursor(false)
  
local marker2 = createMarker( -1973.607421875, 117.6298828125, 27.6875, "cylinder", 1.1, 255,0,0,70)
--local marker3 = createMarker( 2016.392578125, 2066.3544921875, 31.99999, "cylinder", 1.1, 255,255,255,70)
--local marker1lv = createMarker(2843.67261, 1290.56396, 10, "cylinder", 1.5, 255,255,255,70)
--local marker2lv = createMarker(1433.62939, 2652.80322, 10, "cylinder", 1.5, 255,255,255,70)
--createBlipAttachedTo ( marker2, 42 )
--createBlipAttachedTo ( marker3, 42 )
--createBlipAttachedTo ( marker1lv, 42 )
--createBlipAttachedTo ( marker2lv, 42 )

function markerHitLV (hitPlayer)
    if ( hitPlayer == localPlayer ) then
        guiSetVisible (GUIEditor_Window[1], true)
guiSetEnabled(GUIEditor_Button[3],false)
guiSetEnabled(GUIEditor_Button[4],true)
guiSetEnabled(GUIEditor_Button[1],true)
guiSetEnabled(GUIEditor_Button[2],true)
        showCursor (true)
    end
end
addEventHandler ("onClientMarkerHit", marker1lv, markerHitLV)
addEventHandler ("onClientMarkerHit", marker2lv, markerHitLV)

function markerHitSF (hitPlayer)
    if ( hitPlayer == localPlayer ) then
        guiSetVisible (GUIEditor_Window[1], true)
guiSetEnabled(GUIEditor_Button[2],false)
guiSetEnabled(GUIEditor_Button[1],true)
guiSetEnabled(GUIEditor_Button[3],true)
guiSetEnabled(GUIEditor_Button[4],true)
        showCursor (true)
    end
end
addEventHandler ("onClientMarkerHit", marker3, markerHitSF)

function markerHitLs (hitPlayer)
    if ( hitPlayer == localPlayer ) then
        guiSetVisible (GUIEditor_Window[1], true)
guiSetEnabled(GUIEditor_Button[1],false)
guiSetEnabled(GUIEditor_Button[2],true)
guiSetEnabled(GUIEditor_Button[3],true)
guiSetEnabled(GUIEditor_Button[4],true)
        showCursor (true)
    end
end
addEventHandler ("onClientMarkerHit", marker2, markerHitLs)

function markerLeave ()
        guiSetVisible (GUIEditor_Window[1], false)
        showCursor (false)
end
addEventHandler ("onClientMarkerLeave", marker2, markerLeave)
addEventHandler ("onClientMarkerLeave", marker3, markerLeave)
addEventHandler ("onClientMarkerLeave", marker1lv, markerLeave)
addEventHandler ("onClientMarkerLeave", marker2lv, markerLeave)
 
addEventHandler("onClientGUIClick", root,
    function ( )
        if ( source == GUIEditor_Button[1] ) then	
    triggerServerEvent ( "qa", getLocalPlayer() )
        elseif ( source == GUIEditor_Button[2] ) then
   triggerServerEvent ( "qa2", getLocalPlayer() )
           elseif ( source == GUIEditor_Button[3] ) then
   triggerServerEvent ( "qa3", getLocalPlayer() )
        elseif ( source == GUIEditor_Button[4] ) then
            guiSetVisible ( GUIEditor_Window[1], false )
            showCursor ( false )
        end
    end
)