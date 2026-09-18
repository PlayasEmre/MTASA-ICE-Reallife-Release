--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

TankeSFDowntown = createMarker ( -1681.7896728516, 407.72265625, 5.6796879768372, "cylinder", 5, getColorFromString ( "#FF000099" ) )
TankeSFJuniperHill = createMarker ( -2415.208984375, 976.42901611328, 43.807689666748, "cylinder", 5, getColorFromString ( "#FF000099" ) )
TankeBoat = createMarker ( -1108.8315429688, -136.8196105957, 0, "cylinder", 5, getColorFromString ( "#FF000099" ) )
AirportTanke = createMarker ( -1122.7724609375, -202.25073242188, 10.893966674805, "cylinder", 50, getColorFromString ( "#FF000099" ) )
Tanke = {
	[1] = createMarker(-2244.2653808594, -2561.2934570313, 30.921875, "cylinder", 5, getColorFromString ( "#FF000099" )),
	[2] = createMarker(658.52795410156, -565.03424072266, 15.3359375, "cylinder", 5, getColorFromString ( "#FF000099" )),
	[3] = createMarker(1003.8759155273, -940.43975830078, 41.1796875, "cylinder", 5, getColorFromString ( "#FF000099" )),
	[4] = createMarker(-92.113708496094, -1171.3128662109 ,1.3799414634705, "cylinder", 5, getColorFromString ( "#FF000099" )),
	[5] = createMarker(1597.9239501953 ,2199.1923828125 ,9.8203125, "cylinder", 5, getColorFromString ( "#FF000099" )),
	[6] = createMarker(2144.8181152344 ,2748.4426269531 ,9.8203125, "cylinder", 5, getColorFromString ( "#FF000099" )),
	[7] = createMarker(2113.7553710938 ,920.28552246094 ,9.8203125, "cylinder", 5, getColorFromString ( "#FF000099" )),
	[8] = createMarker(-736.88232421875 ,2741.0732421875 ,46.224239349365, "cylinder", 5, getColorFromString ( "#FF000099" )),
	[9] = createMarker(-1326.2266845703 ,2688.9340820313 ,49.0625, "cylinder", 5, getColorFromString ( "#FF000099" )),
	[10] = createMarker(1936.3382568359 ,-1772.1337890625 ,12.3828125, "cylinder", 5, getColorFromString ( "#FF000099" )),
	[11] = createMarker(62.793960571289 ,1217.6678466797 ,17.835973739624, "cylinder", 5, getColorFromString ( "#FF000099" )),
	[12] = createMarker(-1612.5341796875 ,-2723.4165039063 ,47.5390625, "cylinder", 5, getColorFromString ( "#FF000099" )),
	[13] = createMarker(2638.4443359375 ,1106.2412109375 ,9.8203125, "cylinder", 5, getColorFromString ( "#FF000099" )),
	[14] = createMarker(2203.1423339844 ,2473.5385742188 ,9.8203125, "cylinder", 5, getColorFromString ( "#FF000099" )),
	[15] = createMarker(-2028.9000244141,158.89999389648,28, "cylinder", 5, getColorFromString("#FF000099"))
}



helicopters = { [548]=true, [425]=true, [417]=true, [487]=true, [488]=true, [497]=true, [563]=true, [447]=true, [469]=true }
planea = { [512]=true, [593]=true, [476]=true, [460]=true, [513]=true }
planeb = { [592]=true, [577]=true, [511]=true, [520]=true, [553]=true, [519]=true }

function showTankenGui ( player, dim )
	
	if player == localPlayer and dim then
		local veh = getPedOccupiedVehicle ( localPlayer )
		if veh then
			if getVehicleType ( veh ) ~= "Plane" and getVehicleType ( veh ) ~= "Helicopter" then
				setElementVelocity ( veh, 0, 0, 0 )
				showCursor ( true )
				setElementClicked ( true )
				toggleAllControls ( false )
				if gWindow["tankstelle"] then
					dgsSetVisible ( gWindow["tankstelle"], true )
				else
				
					local screenwidth, screenheight = guiGetScreenSize ()
					gWindow["tankstelle"] = dgsCreateWindow(screenwidth/2-380/2,screenheight/2-246/2,378,236,"Tankstelle",false)
					dgsWindowSetCloseButtonEnabled(gWindow["tankstelle"], false)
					dgsSetAlpha(gWindow["tankstelle"],1)
					dgsWindowSetMovable(gWindow["tankstelle"],false)
					dgsWindowSetSizable(gWindow["tankstelle"],false)
					gEdit["literFill"] = dgsCreateEdit(0.3545,0.477,0.164,0.1609,"",true,gWindow["tankstelle"])
					dgsSetAlpha(gEdit["literFill"],1)
					gLabel["literText"] = dgsCreateLabel(0.5317,0.523,0.1005,0.1092,"Liter",true,gWindow["tankstelle"])
					dgsSetAlpha(gLabel["literText"],1)
					dgsLabelSetColor(gLabel["literText"],125,000,000)
					dgsLabelSetVerticalAlign(gLabel["literText"],"top")
					dgsLabelSetHorizontalAlign(gLabel["literText"],"left",false)
					dgsSetFont(gLabel["literText"],"default")
					gLabel["snackPrice"] = dgsCreateLabel(0.7804,0.5115,0.0582,0.1092,"X "..Tables.waehrung.."",true,gWindow["tankstelle"])
					dgsSetAlpha(gLabel["snackPrice"],1)
					dgsLabelSetColor(gLabel["snackPrice"],000,125,000)
					dgsLabelSetVerticalAlign(gLabel["snackPrice"],"top")
					dgsLabelSetHorizontalAlign(gLabel["snackPrice"],"left",false)
					dgsSetFont(gLabel["snackPrice"],"default")
					gLabel["pricePerLiter"] = dgsCreateLabel(0.0767,0.5172,0.2011,0.1092,"X.XX "..Tables.waehrung.." / Liter",true,gWindow["tankstelle"])
					dgsSetAlpha(gLabel["pricePerLiter"],1)
					dgsLabelSetColor(gLabel["pricePerLiter"],000,125,000)
					dgsLabelSetVerticalAlign(gLabel["pricePerLiter"],"top")
					dgsLabelSetHorizontalAlign(gLabel["pricePerLiter"],"left",false)
					dgsSetFont(gLabel["pricePerLiter"],"default")
					gLabel["kannisterPrice"] = dgsCreateLabel(0.3545,0.7069,0.1429,0.1897,"X Liter,\nX "..Tables.waehrung.."",true,gWindow["tankstelle"])
					dgsSetAlpha(gLabel["kannisterPrice"],1)
					dgsLabelSetColor(gLabel["kannisterPrice"],200,050,020)
					dgsLabelSetVerticalAlign(gLabel["kannisterPrice"],"top")
					dgsLabelSetHorizontalAlign(gLabel["kannisterPrice"],"left",false)
					dgsSetFont(gLabel["kannisterPrice"],"default")
					
					gButton["buyKannister"] = dgsCreateButton(0.0344,0.6721,0.221,0.221,"Benzinkanister\nkaufen",true,gWindow["tankstelle"])
					dgsSetAlpha(gButton["buyKannister"],1)
					gButton["volltanken"] = dgsCreateButton(0.0344,0.1724,0.291,0.2644,"Volltanken",true,gWindow["tankstelle"],_,_,_,_,_,_,tocolor(100,181,246,255),tocolor(150,205,250,255),tocolor(66,140,205,255))
					dgsSetAlpha(gButton["volltanken"],1)
					gButton["ltanken"] = dgsCreateButton(0.3519,0.1667,0.291,0.2644,"Liter tanken",true,gWindow["tankstelle"])
					dgsSetAlpha(gButton["ltanken"],1)
					gButton["snack"] = dgsCreateButton(0.6693,0.1667,0.291,0.2644,"Snack kaufen",true,gWindow["tankstelle"])
					dgsSetAlpha(gButton["snack"],1)
					gButton["closeTanke"] = dgsCreateButton(0.6825,0.6782,0.291,0.221,"Fenster schließen",true,gWindow["tankstelle"])
					dgsSetAlpha(gButton["closeTanke"],1)
					
					addEventHandler("onDgsMouseClick", gButton["closeTanke"],
						function()
							dgsSetVisible ( gWindow["tankstelle"], false )
							showCursor(false)
							setElementClicked ( false )
							triggerServerEvent ( "cancel_gui_server", localPlayer )
							toggleAllControls ( true )
						end,false
					)
					addEventHandler("onDgsMouseClick", gButton["volltanken"],
						function(button,state)
						if button == "left" and state == "down" then
							dgsSetVisible ( gWindow["tankstelle"], false )
							showCursor(false)
							setElementClicked ( false )
							toggleAllControls ( true )
							triggerServerEvent ( "cancel_gui_server", localPlayer )
							triggerServerEvent ( "fillComplete", localPlayer,localPlayer )
							end
						end,false
					)
					addEventHandler("onDgsMouseClick", gButton["ltanken"],
						function(button,state)
						if button == "left" and state == "down" then
							dgsSetVisible ( gWindow["tankstelle"], false )
							showCursor(false)
							setElementClicked ( false )
							toggleAllControls ( true )
							triggerServerEvent ( "cancel_gui_server", localPlayer )
							local liter = tonumber ( dgsGetText ( gEdit["literFill"] ) )
							if liter and liter > 0 then
								triggerServerEvent ( "fillPart", localPlayer, localPlayer, liter )
							end
						  end
						end,false
					)
					addEventHandler("onDgsMouseClick", gButton["snack"],
						function(button,state)
						if button == "left" and state == "down" then
							triggerServerEvent ( "buySnack", localPlayer, localPlayer )
						end
					end,false
					)
					
					addEventHandler("onDgsMouseClick", gButton["buyKannister"],
						function(button,state)
						if button == "left" and state == "down" then
							triggerServerEvent ( "buyKannister", localPlayer, localPlayer )
						end
					end,false
					)
				end
				dgsSetText ( gLabel["snackPrice"], snackPrice.." "..Tables.waehrung.."" )
				dgsSetText ( gLabel["pricePerLiter"], literPrice.." "..Tables.waehrung.." / Liter" )
				dgsSetText ( gLabel["kannisterPrice"], "15 Liter,\n"..math.floor(literPrice*15)+kannisterPrice.." "..Tables.waehrung.."" )
			end
		end
	end
end
addEventHandler ( "onClientMarkerHit", TankeSFJuniperHill, showTankenGui )
addEventHandler ( "onClientMarkerHit", TankeSFDowntown, showTankenGui )
addEventHandler ( "onClientMarkerHit", TankeBoat, showTankenGui )

for i=1, #Tanke do
	addEventHandler ( "onClientMarkerHit", Tanke[i], showTankenGui )
end

function showAirportTanke ( player, dim )

	if player == localPlayer and dim then
		if (getElementDimension ( player ) == 14) then return false end
		local veh = getPedOccupiedVehicle ( localPlayer )
		if veh then
			if ( getVehicleType ( veh ) == "Plane" or getVehicleType ( veh ) == "Helicopter" ) then
				setElementVelocity ( getPedOccupiedVehicle ( localPlayer ), 0, 0, 0 )
				showCursor ( true )
				setElementClicked ( true )
				toggleAllControls ( false )
				if gWindow["tankstelle"] then
					dgsSetVisible ( gWindow["tankstelle"], true )
				else
					local screenwidth, screenheight = dgsGetScreenSize ()
					
					gWindow["tankstelle"] = dgsCreateWindow(screenwidth/2-378/2,screenheight/2-174/2,378,174,"Tankstelle",false)
					dgsSetAlpha(gWindow["tankstelle"],1)
					dgsWindowSetMovable(gWindow["tankstelle"],false)
					dgsWindowSetSizable(gWindow["tankstelle"],false)
					gEdit["literFill"] = dgsCreateEdit(0.3545,0.477,0.164,0.1609,"",true,gWindow["tankstelle"])
					dgsSetAlpha(gEdit["literFill"],1)
					gLabel["literText"] = dgsCreateLabel(0.5317,0.523,0.1005,0.1092,"Liter",true,gWindow["tankstelle"])
					dgsSetAlpha(gLabel["literText"],1)
					dgsLabelSetColor(gLabel["literText"],125,000,000)
					dgsLabelSetVerticalAlign(gLabel["literText"],"top")
					dgsLabelSetHorizontalAlign(gLabel["literText"],"left",false)
					dgsSetFont(gLabel["literText"],"default")
					gLabel["snackPrice"] = dgsCreateLabel(0.7804,0.5115,0.0582,0.1092,"X "..Tables.waehrung.."",true,gWindow["tankstelle"])
					dgsSetAlpha(gLabel["snackPrice"],1)
					dgsLabelSetColor(gLabel["snackPrice"],000,125,000)
					dgsLabelSetVerticalAlign(gLabel["snackPrice"],"top")
					dgsLabelSetHorizontalAlign(gLabel["snackPrice"],"left",false)
					dgsSetFont(gLabel["snackPrice"],"default")
					gLabel["pricePerLiter"] = dgsCreateLabel(0.0767,0.5172,0.2011,0.1092,"X.XX "..Tables.waehrung.." / Liter",true,gWindow["tankstelle"])
					dgsSetAlpha(gLabel["pricePerLiter"],1)
					dgsLabelSetColor(gLabel["pricePerLiter"],000,125,000)
					dgsLabelSetVerticalAlign(gLabel["pricePerLiter"],"top")
					dgsLabelSetHorizontalAlign(gLabel["pricePerLiter"],"left",false)
					dgsSetFont(gLabel["pricePerLiter"],"default")
					gLabel["kannisterPrice"] = dgsCreateLabel(0.3545,0.7069,0.1429,0.1897,"X Liter,\nX "..Tables.waehrung.."",true,gWindow["tankstelle"])
					dgsSetAlpha(gLabel["kannisterPrice"],1)
					dgsLabelSetColor(gLabel["kannisterPrice"],200,050,020)
					dgsLabelSetVerticalAlign(gLabel["kannisterPrice"],"top")
					dgsLabelSetHorizontalAlign(gLabel["kannisterPrice"],"left",false)
					dgsSetFont(gLabel["kannisterPrice"],"default")
					
					gButton["buyKannister"] = dgsCreateButton(0.0344,0.6724,0.291,0.2644,"Benzinkanister\nkaufen",true,gWindow["tankstelle"])
					dgsSetAlpha(gButton["buyKannister"],1)
					gButton["volltanken"] = dgsCreateButton(0.0344,0.1724,0.291,0.2644,"Volltanken",true,gWindow["tankstelle"],_,_,_,_,_,_,tocolor(100,181,246,255),tocolor(150,205,250,255),tocolor(66,140,205,255))
					dgsSetAlpha(gButton["volltanken"],1)
					gButton["ltanken"] = dgsCreateButton(0.3519,0.1667,0.291,0.2644,"Liter tanken",true,gWindow["tankstelle"])
					dgsSetAlpha(gButton["ltanken"],1)
					gButton["snack"] = dgsCreateButton(0.6693,0.1667,0.291,0.2644,"Snack kaufen",true,gWindow["tankstelle"])
					dgsSetAlpha(gButton["snack"],1)
					gButton["closeTanke"] = dgsCreateButton(0.6825,0.6782,0.291,0.2644,"Fenster schließen",true,gWindow["tankstelle"])
					dgsSetAlpha(gButton["closeTanke"],1)
					
					addEventHandler("onDgsMouseClick", gButton["closeTanke"],
						function(btn,state)
						if btn == "left" and state == "down" then
							dgsSetVisible ( gWindow["tankstelle"], false )
							showCursor(false)
							setElementClicked ( false )
							triggerServerEvent ( "cancel_gui_server", localPlayer )
							toggleAllControls ( true )
						end
					end,false
					)
					addEventHandler("onDgsMouseClick", gButton["volltanken"],
						function(btn,state)
						 if btn == "left" and state == "down" then
							dgsSetVisible ( gWindow["tankstelle"], false )
							showCursor(false)
							setElementClicked ( false )
							triggerServerEvent ( "cancel_gui_server", localPlayer )
							triggerServerEvent ( "fillComplete", localPlayer, localPlayer, true )
						end
					end,false
					)
					addEventHandler("onDgsMouseClick", gButton["ltanken"],
						function(btn,state)
						if btn == "left" and state == "down" then
							dgsSetVisible ( gWindow["tankstelle"], false )
							showCursor(false)
							setElementClicked ( false )
							triggerServerEvent ( "cancel_gui_server", localPlayer )
							local liter = tonumber ( dgsGetText ( gEdit["literFill"] ) )
							if liter and liter > 0 then
								triggerServerEvent ( "fillPart", localPlayer, localPlayer, liter, true )
							end
							toggleAllControls ( true )
						end
					end,false
					)
					addEventHandler("onDgsMouseClick", gButton["snack"],
						function(btn,state)
						if btn == "left" and state == "down" then
							triggerServerEvent ( "buySnack", localPlayer, localPlayer )
						end	
					end,false
					)
					addEventHandler("onDgsMouseClick", gButton["buyKannister"],
						function(btn,state)
						if btn == "left" and state == "down" then
							triggerServerEvent ( "buyKannister", localPlayer, localPlayer )
						end	
					end,false
					)
				end
				dgsSetText ( gLabel["snackPrice"], snackPrice.." "..Tables.waehrung.."" )
				dgsSetText ( gLabel["pricePerLiter"], (literPrice*3).." "..Tables.waehrung.." / Liter" )
				dgsSetText ( gLabel["kannisterPrice"], "15 Liter,\n"..math.floor(literPrice*15)+kannisterPrice.." "..Tables.waehrung.."" )
			end
		end
	end
end
addEventHandler ( "onClientMarkerHit", AirportTanke, showAirportTanke )