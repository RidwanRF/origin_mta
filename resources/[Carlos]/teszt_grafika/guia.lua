GUIEditor_Window = {}
GUIEditor_Button = {}
GUIEditor_Label = {}

GUIEditor_Window[1] = guiCreateWindow(0.3875,0.2833,0.16,0.6117,"System of Trains",true)
guiWindowSetMovable(GUIEditor_Window[1],false)
GUIEditor_Button[1] = guiCreateButton(15,50,131,40,"Go to Ls",false,GUIEditor_Window[1])
GUIEditor_Button[2] = guiCreateButton(14,111,131,40,"Go to Sf",false,GUIEditor_Window[1])
GUIEditor_Button[3] = guiCreateButton(14,175,131,40,"Go to LV",false,GUIEditor_Window[1])
GUIEditor_Label[1] = guiCreateLabel(20,287,156,23,"-------------------------",false,GUIEditor_Window[1])
guiLabelSetColor(GUIEditor_Label[1],255,255,0)
guiSetFont(GUIEditor_Label[1],"default-bold-small")
GUIEditor_Button[4] = guiCreateButton(17,313,126,41,"Cancel",false,GUIEditor_Window[1])
 
guiSetVisible(GUIEditor_Window[1], false)
showCursor(false)
  
local marker2 = createMarker(1743.13477, -1944.71582, 12, "cylinder", 1.5, 255,255,255,70)
local marker3 = createMarker(-1974.03125, 117.88158, 26, "cylinder", 1.5, 255,255,255,70)
local marker1lv = createMarker(2843.67261, 1290.56396, 10, "cylinder", 1.5, 255,255,255,70)
local marker2lv = createMarker(1433.62939, 2652.80322, 10, "cylinder", 1.5, 255,255,255,70)
createBlipAttachedTo ( marker2, 42 )
createBlipAttachedTo ( marker3, 42 )
createBlipAttachedTo ( marker1lv, 42 )
createBlipAttachedTo ( marker2lv, 42 )

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
    triggerServerEvent ( "qd", getLocalPlayer() )
        elseif ( source == GUIEditor_Button[2] ) then
   triggerServerEvent ( "qd2", getLocalPlayer() )
           elseif ( source == GUIEditor_Button[3] ) then
   triggerServerEvent ( "qd4", getLocalPlayer() )
        elseif ( source == GUIEditor_Button[4] ) then
            guiSetVisible ( GUIEditor_Window[1], false )
            showCursor ( false )
        end
    end
)