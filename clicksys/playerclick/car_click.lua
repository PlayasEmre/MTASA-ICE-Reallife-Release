--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function SubmitFahrzeugAbbrechenBtn(button)
	if button == "left" then
		if gWindows["vehinteraktion"] then
			dgsSetInputMode ( "allow_binds" )
			dgsSetVisible ( gWindows["vehinteraktion"], false )
			if gWindow["vehCarAdminWin"] then
				dgsSetVisible ( gWindow["vehCarAdminWin"], false )
			end
			if gWindow["vehKeyPanel"] then
				dgsSetVisible ( gWindow["vehKeyPanel"], false )
			end
			showCursor ( false )
			setElementClicked ( false )
		end
	end
end

function _createCarmenue_func ( veh )
	-- Ohne das landen Tastendruecke beim Tippen (z.B. im Loeschgrund-Textfeld
	-- weiter unten) gleichzeitig bei den global gebundenen Tasten - dadurch
	-- wirkte es so, als kaeme im Textfeld nichts an.
	dgsSetInputMode ( "no_binds_when_editing" )
	showCursor ( true )

	-- Der Kofferraum gehoert nicht zum Auto-Menue.
	if isElement ( gWindow["trunkClick"] ) then
		dgsSetVisible ( gWindow["trunkClick"], false )
	end

	if gWindows["vehinteraktion"] then
		dgsSetVisible ( gWindows["vehinteraktion"], true )
		dgsBringToFront ( gWindows["vehinteraktion"] )
		-- Adminrechte erneut pruefen: das Fenster wird nur einmal gebaut und
		-- bliebe nach einer Degradierung sonst weiter sichtbar.
		if isElement ( gWindow["vehCarAdminWin"] ) then
			local istAdmin = ( tonumber ( getElementData ( localPlayer, "adminlvl" ) ) or 0 ) >= 2
			dgsSetVisible ( gWindow["vehCarAdminWin"], istAdmin )
			if istAdmin then
				dgsBringToFront ( gWindow["vehCarAdminWin"] )
			end
		end
		if gWindow["vehKeyPanel"] then
			dgsSetVisible ( gWindow["vehKeyPanel"], false )
		end
	else
		if getElementData ( localPlayer, "adminlvl" ) >= 2 then
			gWindow["vehCarAdminWin"] = dgsCreateWindow(0,screenheight/2-132/2,151,137,"Admin Panel",false)
			dgsBringToFront(gWindow["vehCarAdminWin"])
			dgsWindowSetCloseButtonEnabled(gWindow["vehCarAdminWin"], false)
			dgsWindowSetSizable(gWindow["vehCarAdminWin"],false)
			dgsWindowSetMovable(gWindow["vehCarAdminWin"],false)
			gButton["vehCarAdminDelBtn"] = dgsCreateButton(0.0596,0.1000,0.3974,0.2555,"Loeschen",true,gWindow["vehCarAdminWin"])
			dgsSetAlpha(gButton["vehCarAdminDelBtn"],1)
			gButton["vehCarAdminRespBtn"] = dgsCreateButton(0.4901,0.1000,0.457,0.2555,"Respawnen",true,gWindow["vehCarAdminWin"])
			dgsSetAlpha(gButton["vehCarAdminRespBtn"],1)
			gLabel["vehCarAdminInfo1"] = dgsCreateLabel(0.0596,0.3891,0.3113,0.1387,"Grund:",true,gWindow["vehCarAdminWin"])
			dgsSetAlpha(gLabel["vehCarAdminInfo1"],1)
			dgsLabelSetColor(gLabel["vehCarAdminInfo1"],63,160,224)
			dgsLabelSetVerticalAlign(gLabel["vehCarAdminInfo1"],"top")
			dgsLabelSetHorizontalAlign(gLabel["vehCarAdminInfo1"],"left",false)
			dgsSetFont(gLabel["vehCarAdminInfo1"],"default-bold")
			gMemo["vehCarAdminReason"] = dgsCreateMemo(0.0996,0.5300,0.7808,0.2258,"",true,gWindow["vehCarAdminWin"])
			dgsSetAlpha(gMemo["vehCarAdminReason"],1)
			
			addEventHandler("onDgsMouseClickUp", gButton["vehCarAdminRespBtn"], 
				function(button,state)
				if button == "left" then
					local veh = vioClientGetElementData ( "clickedVehicle" )
					local towcar = getElementData ( veh, "carslotnr_owner" )
					local pname = getElementData ( veh, "owner" )
					triggerServerEvent ( "respawnVeh", localPlayer, towcar, pname, veh )
					SubmitFahrzeugAbbrechenBtn("left")
				end	
			end,false)
			
			addEventHandler("onDgsMouseClickUp", gButton["vehCarAdminDelBtn"],
					function(button,state)
					if button == "left" then
						local veh = vioClientGetElementData ( "clickedVehicle" )
						local towcar = getElementData ( veh, "carslotnr_owner" )
						local pname = getElementData ( veh, "owner" )
						if not pname then
							triggerServerEvent ( "moveVehicleAway", lp, veh )
						else
							triggerServerEvent ( "deleteVeh", lp, towcar, pname, veh, dgsGetText ( gMemo["vehCarAdminReason"] ) )
						end
						SubmitFahrzeugAbbrechenBtn("left")
					end
				end,false)
			end
			
			gWindows["vehinteraktion"] = dgsCreateWindow(screenwidth/2-224/2,screenheight/2-260/2,240,260,"Fahrzeug Panel",false)
			dgsBringToFront(gWindows["vehinteraktion"])
			dgsWindowSetCloseButtonEnabled(gWindows["vehinteraktion"], false)
			dgsWindowSetSizable(gWindows["vehinteraktion"],false)
			dgsWindowSetMovable(gWindows["vehinteraktion"],false)
			gButtons["vehabschliessen"] = dgsCreateButton(0.0402,0.04,0.442,0.20,"Abschliessen",true,gWindows["vehinteraktion"])
			dgsSetAlpha(gButtons["vehabschliessen"],1)
			gButtons["vehrespawn"] = dgsCreateButton(0.52,0.04,0.442,0.20,"Respawnen",true,gWindows["vehinteraktion"])
			dgsSetAlpha(gButtons["vehrespawn"],1)
			gButtons["vehinfo"] = dgsCreateButton(0.0402,0.36,0.442,0.20,"Infos",true,gWindows["vehinteraktion"])
			dgsSetAlpha(gButtons["vehinfo"],1)
			gButtons["vehkey"] = dgsCreateButton(0.52,0.36,0.442,0.20,"Schlüssel",true,gWindows["vehinteraktion"])
			dgsSetAlpha(gButtons["vehkey"],1)
			gButtons["vehcancel"] = dgsCreateButton(0.0402,0.68,0.9196,0.20,"Abbrechen",true,gWindows["vehinteraktion"])
			dgsSetAlpha(gButtons["vehcancel"],1)

			addEventHandler("onDgsMouseClickUp",gButtons["vehcancel"],SubmitFahrzeugAbbrechenBtn,false)
			
			addEventHandler("onDgsMouseClickUp", gButtons["vehrespawn"],function(button,state)
				if button == "left" then
					local veh = vioClientGetElementData ( "clickedVehicle" )
					if veh then
						-- Läuft über respawnVehClick statt respawnPrivVehClick, damit auch
						-- Schlüssel-Inhaber (nicht nur der Besitzer) respawnen können; der
						-- Server prüft Besitzer ODER Schlüssel.
						triggerServerEvent ( "respawnVehClick", localPlayer, localPlayer, veh )
					end
				end
			end,false)
			
			addEventHandler("onDgsMouseClickUp", gButtons["vehabschliessen"],
				function (button,state)
				if button == "left" then
					local veh = vioClientGetElementData ( "clickedVehicle" )
					if veh then
						-- Läuft über lockVehClick statt lockPrivVehClick, damit auch
						-- Schlüssel-Inhaber (nicht nur der Besitzer) das Fahrzeug hier
						-- auf-/zuschließen können; der Server prüft Besitzer ODER Schlüssel.
						triggerServerEvent ( "lockVehClick", localPlayer, localPlayer, veh )
					end
				end
			end,false)
			
			addEventHandler("onDgsMouseClickUp", gButtons["vehinfo"], 
				function (button,state)
				if button == "left" then
					local veh = vioClientGetElementData ( "clickedVehicle" )
						if veh then
							local owner = getElementData ( veh, "owner" )
							if not owner or owner == "console" then
								owner = "Niemand"
							end
							local stunings = sTuningsToString ( veh )
							outputChatBox ( "Fahrzeug Modell: "..getVehicleName (veh)..", Besitzer: "..owner, 0, 120, 200 )
							outputChatBox ( "Tunings: "..stunings, 0, 120, 200 )
						end
					end
			end,false)

			addEventHandler("onDgsMouseClickUp", gButtons["vehkey"],
				function (button,state)
				if button == "left" then
					dgsSetVisible ( gWindows["vehinteraktion"], false )
					showVehKeyPanel ()
				end
			end,false)
	end
end
addEvent ( "_createCarmenue", true )
addEventHandler ( "_createCarmenue", getRootElement(), _createCarmenue_func )

-- Schlüsselverwaltung: eigenen Fahrzeug-Slot per Namen + Slotnummer an einen
-- anderen Spieler vergeben (oder wieder entziehen). Ein Spieler kann so
-- Schlüssel zu mehreren eigenen Fahrzeugen gleichzeitig weitergeben, da jeder
-- Slot unabhängig seinen eigenen Schlüssel-Empfänger speichert.
function showVehKeyPanel ()
	-- Ohne das hier landen Tastendrücke beim Tippen des Namens/der Slotnummer
	-- gleichzeitig bei den global gebundenen Tasten (z.B. l, x fürs Fahrzeug) -
	-- dadurch wirkte es so, als würde die Eingabe im Feld nicht ankommen.
	-- Zusaetzlich zur DGS-eigenen Funktion auch die native setzen, da DGS in
	-- diesem Server nicht ueber meta.xml eingebunden ist und dgsSetInputMode
	-- dadurch nicht zuverlaessig bis zur nativen Tastatureingabe durchgreift.
	dgsSetInputMode ( "no_binds_when_editing" )
	showCursor ( true )

	if gWindow["vehKeyPanel"] then
		dgsSetVisible ( gWindow["vehKeyPanel"], true )
		dgsBringToFront ( gWindow["vehKeyPanel"] )
		dgsSetText ( gEdit["vehKeyName"], "" )
		dgsSetText ( gEdit["vehKeySlot"], "" )
		return
	end

	gWindow["vehKeyPanel"] = dgsCreateWindow(screenwidth/2-240/2,screenheight/2-210/2,240,210,"Schlüssel vergeben",false)
	dgsBringToFront(gWindow["vehKeyPanel"])
	dgsWindowSetCloseButtonEnabled ( gWindow["vehKeyPanel"], false )
	dgsWindowSetSizable ( gWindow["vehKeyPanel"], false )
	dgsWindowSetMovable ( gWindow["vehKeyPanel"], false )

	gLabel["vehKeyNameLabel"] = dgsCreateLabel(0.0385,0.07,0.9,0.09,"Spielername:",true,gWindow["vehKeyPanel"])
	dgsSetAlpha ( gLabel["vehKeyNameLabel"], 1 )
	dgsLabelSetColor ( gLabel["vehKeyNameLabel"], 63, 160, 224 )
	dgsLabelSetVerticalAlign ( gLabel["vehKeyNameLabel"], "top" )
	dgsLabelSetHorizontalAlign ( gLabel["vehKeyNameLabel"], "left", false )
	dgsSetFont ( gLabel["vehKeyNameLabel"], "default-bold" )

	gEdit["vehKeyName"] = dgsCreateEdit(0.0385,0.17,0.923,0.12,"",true,gWindow["vehKeyPanel"])

	gLabel["vehKeySlotLabel"] = dgsCreateLabel(0.0385,0.33,0.9,0.09,"Slot-Nummer:",true,gWindow["vehKeyPanel"])
	dgsSetAlpha ( gLabel["vehKeySlotLabel"], 1 )
	dgsLabelSetColor ( gLabel["vehKeySlotLabel"], 63, 160, 224 )
	dgsLabelSetVerticalAlign ( gLabel["vehKeySlotLabel"], "top" )
	dgsLabelSetHorizontalAlign ( gLabel["vehKeySlotLabel"], "left", false )
	dgsSetFont ( gLabel["vehKeySlotLabel"], "default-bold" )

	gEdit["vehKeySlot"] = dgsCreateEdit(0.0385,0.43,0.923,0.12,"",true,gWindow["vehKeyPanel"])

	gButton["vehKeyGive"] = dgsCreateButton(0.0385,0.59,0.44,0.12,"Geben",true,gWindow["vehKeyPanel"],nil,nil,nil,nil,nil,nil,tocolor(46,110,255,255),tocolor(123,163,255,255),tocolor(24,74,199,255))
	dgsSetAlpha ( gButton["vehKeyGive"], 1 )
	gButton["vehKeyClear"] = dgsCreateButton(0.5215,0.59,0.44,0.12,"Entfernen",true,gWindow["vehKeyPanel"])
	dgsSetAlpha ( gButton["vehKeyClear"], 1 )
	gButton["vehKeyBack"] = dgsCreateButton(0.0385,0.80,0.923,0.10,"Zurück",true,gWindow["vehKeyPanel"])
	dgsSetAlpha ( gButton["vehKeyBack"], 1 )

	addEventHandler ( "onDgsMouseClickUp", gButton["vehKeyGive"],
		function ( button, state )
			if button == "left" then
				local targetName = dgsGetText ( gEdit["vehKeyName"] )
				local slot = tonumber ( dgsGetText ( gEdit["vehKeySlot"] ) )
				if targetName == "" or not slot then
					outputChatBox ( "Bitte Spielername und Slot-Nummer eingeben!", 125, 0, 0 )
				else
					triggerServerEvent ( "onClientGiveKey", localPlayer, targetName, slot )
				end
			end
		end, false )

	addEventHandler ( "onDgsMouseClickUp", gButton["vehKeyClear"],
		function ( button, state )
			if button == "left" then
				local slot = tonumber ( dgsGetText ( gEdit["vehKeySlot"] ) )
				if not slot then
					outputChatBox ( "Bitte Slot-Nummer eingeben!", 125, 0, 0 )
				else
					triggerServerEvent ( "onClientClearKey", localPlayer, slot )
				end
			end
		end, false )

	addEventHandler ( "onDgsMouseClickUp", gButton["vehKeyBack"],
		function ( button, state )
			if button == "left" then
				dgsSetInputMode ( "allow_binds" )
				dgsSetVisible ( gWindow["vehKeyPanel"], false )
				if gWindows["vehinteraktion"] then
					dgsSetVisible ( gWindows["vehinteraktion"], true )
					dgsBringToFront ( gWindows["vehinteraktion"] )
				end
			end
		end, false )
end

function sTuningsToString ( veh )
	if veh and getElementType (veh) == "vehicle" then
		local carstring = ""
		if getElementData ( veh, "stuning1" ) and getElementData ( veh, "stuning1" ) >= 1 then
			carstring = "Kofferraum"
		end
		if getElementData ( veh, "stuning2" ) and getElementData ( veh, "stuning2" ) >= 1 then
			if carstring == "" then
				carstring = "Panzerung"
			else
				carstring = carstring..", Panzerung"
			end
		end
		if getElementData ( veh, "stuning3" ) and getElementData ( veh, "stuning3" ) >= 1 then
			if carstring == "" then
				carstring = "Benzinersparnis"
			else
				carstring = carstring..", Benzinersparnis"
			end
		end
		if getElementData ( veh, "stuning4" ) and getElementData ( veh, "stuning4" ) >= 1 then
			if carstring == "" then
				carstring = "GPS"
			else
				carstring = carstring..", GPS"
			end
		end
		if getElementData ( veh, "stuning5" ) and getElementData ( veh, "stuning5" ) >= 1 then
			if carstring == "" then
				carstring = "Doppelreifen"
			else
				carstring = carstring..", Doppelreifen"
			end
		end
		if getElementData ( veh, "stuning6" ) and getElementData ( veh, "stuning6" ) >= 1 then
			if carstring == "" then
				carstring = "Nebelwerfer"
			else
				carstring = carstring..", Nebelwerfer"
			end
		end
		if getVehicleType ( veh ) ~= "Plane" and getVehicleType ( veh ) ~= "Helicopter" then
			local sportmotor = getElementData ( veh,"sportmotor" )
			if sportmotor and sportmotor > 0 then
				if carstring == "" then
					carstring = "Sportmotor "..sportmotor
				else
					carstring = carstring..", Sportmotor "..sportmotor
				end
			end
			local bremse = getElementData ( veh,"bremse" )
			if bremse and bremse > 0 then
				if carstring == "" then
					carstring = "Bremse "..bremse
				else
					carstring = carstring..", Bremse "..bremse
				end
			end
			local radtyp = getVehicleHandling ( veh )["driveType"]
			if radtyp == "rwd" then
				radtyp = "Heckantrieb"
			elseif radtyp == "awd" then
				radtyp = "Allradantrieb"
			else
				radtyp = "Frontantrieb"
			end
			if carstring == "" then
				carstring = radtyp
			else
				carstring = carstring..", "..radtyp
			end
		end
		if carstring == "" then
			return "Keine"
		else
			return carstring
		end
	end
end