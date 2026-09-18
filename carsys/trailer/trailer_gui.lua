--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

trailerMarker = createMarker ( -911.3271484375, -486.00863647461, 24.89, "cylinder", 3, 150, 0, 0, 150 )
createBlip ( -911.3271484375, -486.00863647461, 24.89, 55, 1, 0, 0, 0, 255, 0, 200 )

function showWohnwagenMenue ( hit, dim )

	if hit == localPlayer and dim then
		if not getPedOccupiedVehicle ( localPlayer ) then
			guiSetInputMode ( "no_binds_when_editing" )
			showCursor ( true )
			setElementClicked ( true )
			if gWindow["wohnwagen"] then
				dgsSetVisible ( gWindow["wohnwagen"], true )
				dgsBringToFront ( gWindow["wohnwagen"] )
			else
				gWindow["wohnwagen"] = dgsCreateWindow(screenwidth/2-307/2,screenheight/2-205/2,307,205,"Wohnwagen",false, nil, nil, nil, nil, nil, nil, nil, true)
				dgsBringToFront ( gWindow["wohnwagen"] )
				dgsWindowSetMovable ( gWindow["wohnwagen"], false )
				dgsWindowSetSizable ( gWindow["wohnwagen"], false )

				gLabel["wohnmobilInfo1"] = dgsCreateLabel(12,27,289,78,"Hier kannst du einen Wohnwagen erwerben,\nan dem du Spawnen und essen kannst.\n\nAusserdem kannst du ihm - wie jedem Fahrzeug -\neinen Kofferraum einbauen.",false,gWindow["wohnwagen"])
				dgsLabelSetColor(gLabel["wohnmobilInfo1"],200,200,0)
				dgsLabelSetVerticalAlign(gLabel["wohnmobilInfo1"],"top")
				dgsLabelSetHorizontalAlign(gLabel["wohnmobilInfo1"],"left",false)
				dgsSetFont(gLabel["wohnmobilInfo1"],"default-bold")
				gButton["trailerBuy"] = dgsCreateButton(92,125,87,44,"Kaufen",false,gWindow["wohnwagen"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
				dgsSetFont(gButton["trailerBuy"],"default-bold")
				gLabel[2] = dgsCreateLabel(20,100,44,18,"Kosten:",false,gWindow["wohnwagen"])
				dgsLabelSetColor(gLabel[2],125,0,0)
				dgsLabelSetVerticalAlign(gLabel[2],"top")
				dgsLabelSetHorizontalAlign(gLabel[2],"left",false)
				dgsSetFont(gLabel[2],"default-bold")
				gLabel[3] = dgsCreateLabel(13,114,63,15,"50.500 "..Tables.waehrung.."",false,gWindow["wohnwagen"])
				dgsLabelSetColor(gLabel[3],0,125,0)
				dgsLabelSetVerticalAlign(gLabel[3],"top")
				dgsLabelSetHorizontalAlign(gLabel[3],"left",false)
				dgsSetFont(gLabel[3],"default-bold")
				gLabel[4] = dgsCreateLabel(10,136,71,21,"Zahlen per...",false,gWindow["wohnwagen"])
				dgsLabelSetColor(gLabel[4],255,255,255)
				dgsLabelSetVerticalAlign(gLabel[4],"top")
				dgsLabelSetHorizontalAlign(gLabel[4],"left",false)
				dgsSetFont(gLabel[4],"default-bold")
				gRadio["trailerPayEC"] = dgsCreateRadioButton(9,157,68,14,"EC Karte",false,gWindow["wohnwagen"])
				dgsSetFont(gRadio["trailerPayEC"],"default-bold")
				gRadio["trailerPayBar"] = dgsCreateRadioButton(9,176,68,14,"Bargeld",false,gWindow["wohnwagen"])
				dgsRadioButtonSetSelected(gRadio["trailerPayEC"],true)
				dgsSetFont(gRadio["trailerPayBar"],"default-bold")
				gImage[1] = dgsCreateImage(193,113,95,74,":"..getResourceName(getThisResource()).."/images/gui/trailer.png",false,gWindow["wohnwagen"])
				gButton["trailerClose"] = dgsCreateButton(280,24,18,19,"x",false,gWindow["wohnwagen"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
				dgsSetFont(gButton["trailerClose"],"default-bold")

				addEventHandler ( "onDgsMouseClickUp", gButton["trailerClose"],
					function ( button )
						if button ~= "left" then return end
						dgsSetVisible ( gWindow["wohnwagen"], false )
						guiSetInputMode ( "allow_binds" )
						showCursor ( false )
						setElementClicked ( false )
					end,
				false )
				addEventHandler ( "onDgsMouseClickUp", gButton["trailerBuy"],
					function ( button )
						if button ~= "left" then return end
						dgsSetVisible ( gWindow["wohnwagen"], false )
						guiSetInputMode ( "allow_binds" )
						showCursor ( false )
						setElementClicked ( false )
						if dgsRadioButtonGetSelected ( gRadio["trailerPayEC"] ) then
							ec = true
						else
							ec = false
						end
						triggerServerEvent ( "buyTrailer", localPlayer, ec )
					end,
				false )
			end
		end
	end
end
addEventHandler ( "onClientMarkerHit", trailerMarker, showWohnwagenMenue )
