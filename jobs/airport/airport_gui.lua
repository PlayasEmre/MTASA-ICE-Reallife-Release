--/////////////////////////--
--/////// (c) 2010 ////////--
--/////// by Zipper ///////--
--/ and Vio MTA:RL Crew ///--
--/////////////////////////--

addEvent ( "stopAirportJob", true )
local baggageNumber = {}

local function clickOnAirportGUI(btn)
	if btn ~= "left" then return end
	if source == gButton["airportClose"] then
		dgsSetVisible ( gWindow["airportJob"], false )
		guiSetInputMode("allow_binds")
		showCursor(false)
		triggerServerEvent ( "cancel_gui_server", lp )
	elseif source == gButton["airportTakeJob"] then
		local labeltext = dgsGetText ( gLabel["airportInfo3"] )
		if labeltext == "Koffertransporteur" then
			if vioClientGetElementData ( "carlicense" ) == 1 then
				hideAllMarkersAirport()
				triggerServerEvent ( "airportjobDimFix", lp )
				setElementPosition ( lp, -1262.0727539063, 33, 13.84 )
				dgsSetVisible ( gWindow["airportJob"], false )
				guiSetInputMode("allow_binds")
				showCursor(false)
				setElementClicked ( false )
				triggerServerEvent ( "cancel_gui_server", lp )
				count = 0
				showDeliverPoints()
			else
				outputChatBox ( "Du brauchst einen Führerschein!", 125, 0, 0 )
			end
		elseif labeltext == "Insektenvernichter" then
			if tonumber ( vioClientGetElementData ( "airportlvl" ) ) >= 10 then
				if vioClientGetElementData ( "planelicensea" ) == 1 then
					hideAllMarkersAirport()
					triggerServerEvent ( "airportJobInsektenvernichter", lp )
					dgsSetVisible ( gWindow["airportJob"], false )
					guiSetInputMode("allow_binds")
					showCursor(false)
					triggerServerEvent ( "cancel_gui_server", lp )
					count = 0
					showCropdusterPoints()
				else
					outputChatBox ( "Du braucht einen Flugschein Klasse A!", 125, 0, 0 )
				end
			else
				outputChatBox ( "Dein Flughafen-Level ist nicht hoch genug - erst ab Level 10 verfuegbar!", 125, 0, 0 )
			end
		elseif labeltext == "Leichter Flug" then
			if tonumber ( vioClientGetElementData ( "airportlvl" ) ) >= 20 then
				if vioClientGetElementData ( "planelicensea" )  == 1 then
					if dgsRadioButtonGetSelected ( gRadio["dodo"] ) then
						startFreightMission ( 593 )
					elseif dgsRadioButtonGetSelected ( gRadio["beagle"] ) then
						startFreightMission ( 511 )
					else
						outputChatBox ( "Bitte wähle einen gueltigen Flugzeugtypen aus!", 125, 0, 0 )
					end
				else
					outputChatBox ( "Du braucht einen Flugschein Klasse A!", 125, 0, 0 )
				end
			else
				outputChatBox ( "Dein Flughafen-Level ist nicht hoch genug - erst ab Level 20 verfuegbar!", 125, 0, 0 )
			end
		elseif labeltext == "Mittlerer Flug" then
			if tonumber ( vioClientGetElementData ( "airportlvl" ) ) >= 30 then
				if dgsRadioButtonGetSelected ( gRadio["nevada"] ) then
					if vioClientGetElementData ( "planelicensea" )  == 1 then
						startFreightMission ( 553 )
					else
						outputChatBox ( "Du braucht einen Flugschein Klasse A!", 125, 0, 0 )
					end
				elseif dgsRadioButtonGetSelected ( gRadio["shamal"] ) then
					if vioClientGetElementData ( "planelicenseb" )  == 1 then
						startFreightMission ( 519 )
					else
						outputChatBox ( "Du braucht einen Flugschein Klasse B!", 125, 0, 0 )
					end
				else
					outputChatBox ( "Bitte wähle einen gueltigen Flugzeugtypen aus!", 125, 0, 0 )
				end
			else
				outputChatBox ( "Dein Flughafen-Level ist nicht hoch genug - erst ab Level 30 verfuegbar!", 125, 0, 0 )
			end
		elseif labeltext == "Schwerer Flug" then
			if tonumber ( vioClientGetElementData ( "airportlvl" ) ) >= 40 then
				if vioClientGetElementData ( "planelicenseb" )  == 1 then
					if dgsRadioButtonGetSelected ( gRadio["at400"] ) then
						startFreightMission ( 577 )
					elseif dgsRadioButtonGetSelected ( gRadio["andromada"] ) then
						startFreightMission ( 592 )
					else
						outputChatBox ( "Bitte wähle einen gueltigen Flugzeugtypen aus!", 125, 0, 0 )
					end
				else
					outputChatBox ( "Du braucht einen Flugschein Klasse B!", 125, 0, 0 )
				end
			else
				outputChatBox ( "Dein Flughafen-Level ist nicht hoch genug - erst ab Level 40 verfuegbar!", 125, 0, 0 )
			end
		end
	else
		local selectedRow = dgsGridListGetSelectedItem ( gGrid["airportChoose"] )
		if selectedRow == -1 then return end
		local row = dgsGridListGetItemText ( gGrid["airportChoose"], selectedRow, 1 )
		if row == "Kofferpacker" then
			dgsSetText ( gLabel["airportInfo3"], "Koffertransporteur" )
			dgsSetText ( gLabel["airportInfo2"], "Als Koffertransporteur ist es\ndeine Aufgabe, das Gepäck\nzu den Flugzeugen zu bringen." )
			dgsSetText ( gLabel["airportInfo7"], "Baggage" )
		elseif row == "Insektenkiller" then
			dgsSetText ( gLabel["airportInfo3"], "Insektenvernichter" )
			dgsSetText ( gLabel["airportInfo2"], "Als Pestizit-Flugzeug-Pilot ist\nes dein Job, Pestiziede\nueber den Feldern zu verteilen.\nVorraussetzung:\nFlugschein Klasse A!" )
			dgsSetText ( gLabel["airportInfo7"], "Cropduster" )
		elseif row == "Leichter Flug" then
			dgsSetText ( gLabel["airportInfo3"], "Leichter Flug" )
			dgsSetText ( gLabel["airportInfo2"], "Als Pilot eines kleinen Flug-\nzeugs ist es dein Job, kleinere\nLieferungen zu uebernehmen und\nPersonen zu transportieren.\nVorraussetzung:\nFlugschein Klasse A!" )
			dgsSetText ( gLabel["airportInfo7"], "Dodo/Beagle" )
		elseif row == "Mittlerer Flug" then
			dgsSetText ( gLabel["airportInfo3"], "Mittlerer Flug" )
			dgsSetText ( gLabel["airportInfo2"], "Als Pilot eines größeren Flug-\n zeugs ist es dein Job,\nkleine und Mittlere Lieferungen und\nTransporte zu erfuellen.\nVorraussetzung: Flugschein Klasse\nA/B (Je Flugzeug)!" )
			dgsSetText ( gLabel["airportInfo7"], "Nevada/Shamal" )
		elseif row == "Schwerer Flug" then
			dgsSetText ( gLabel["airportInfo3"], "Schwerer Flug" )
			dgsSetText ( gLabel["airportInfo2"], "Als Pilot eines größeren Flug-\n zeugs ist es dein Job,\nriesige Ladungen und Personengruppen\nvon A nach B zu transportieren.\nVorraussetzung: Flugschein Klasse B!" )
			dgsSetText ( gLabel["airportInfo7"], "AT-400/Andromada" )
		end
	end
end


function showAirportJobGui_func ()

	if gWindow["airportJob"] then
		dgsSetVisible ( gWindow["airportJob"], true )
		dgsBringToFront(gWindow["airportJob"])
	else
		local screenwidth, screenheight = guiGetScreenSize ()

		gWindow["airportJob"] = dgsCreateWindow(screenwidth/2-476/2,screenheight/2-279/2,476,279,"Flughafenmitarbeiter",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255))
		dgsWindowSetSizable ( gWindow["airportJob"], false )
		dgsWindowSetMovable ( gWindow["airportJob"], false )
		dgsBringToFront(gWindow["airportJob"])
		dgsSetProperty ( gWindow["airportJob"], "image", false )

		gGrid["airportChoose"] = dgsCreateGridList(0.0189,0.3154,0.3025,0.6523,true,gWindow["airportJob"])
		dgsGridListSetSelectionMode(gGrid["airportChoose"],1)
		gColumn["job"] = dgsGridListAddColumn(gGrid["airportChoose"],"Auftrag",0.65)
		gColumn["belohnung"] = dgsGridListAddColumn(gGrid["airportChoose"],""..Tables.waehrung.."",0.15)
		dgsGridListSetSelectionMode ( gGrid["airportChoose"], 1 )

		local row = dgsGridListAddRow ( gGrid["airportChoose"] )
		dgsGridListSetItemText ( gGrid["airportChoose"], row, gColumn["job"], "Kofferpacker", false, false )
		dgsGridListSetItemText ( gGrid["airportChoose"], row, gColumn["belohnung"], " 75 "..Tables.waehrung.."", false, false )
		local row = dgsGridListAddRow ( gGrid["airportChoose"] )
		dgsGridListSetItemText ( gGrid["airportChoose"], row, gColumn["job"], "Insektenkiller", false, false )
		dgsGridListSetItemText ( gGrid["airportChoose"], row, gColumn["belohnung"], "125 "..Tables.waehrung.."", false, false )
		local row = dgsGridListAddRow ( gGrid["airportChoose"] )
		dgsGridListSetItemText ( gGrid["airportChoose"], row, gColumn["job"], "Leichter Flug", false, false )
		dgsGridListSetItemText ( gGrid["airportChoose"], row, gColumn["belohnung"], "225 "..Tables.waehrung.."", false, false )
		local row = dgsGridListAddRow ( gGrid["airportChoose"] )
		dgsGridListSetItemText ( gGrid["airportChoose"], row, gColumn["job"], "Mittlerer Flug", false, false )
		dgsGridListSetItemText ( gGrid["airportChoose"], row, gColumn["belohnung"], "300 "..Tables.waehrung.."", false, false )
		local row = dgsGridListAddRow ( gGrid["airportChoose"] )
		dgsGridListSetItemText ( gGrid["airportChoose"], row, gColumn["job"], "Schwerer Flug", false, false )
		dgsGridListSetItemText ( gGrid["airportChoose"], row, gColumn["belohnung"], "500 "..Tables.waehrung.."", false, false )

		gLabel["airportInfo1"] = dgsCreateLabel(0.0231,0.1039,0.6849,0.1792,"Herzlich wilkommen am San Fierro International Airport!\n\nBitte wähle deine Tätigkeit!",true,gWindow["airportJob"])
		dgsLabelSetColor(gLabel["airportInfo1"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["airportInfo1"],"top")
		dgsLabelSetHorizontalAlign(gLabel["airportInfo1"],"left",false)
		dgsSetFont(gLabel["airportInfo1"],"default-bold")
		gLabel["airportInfo2"] = dgsCreateLabel(0.334,0.3799,0.3592,0.3,"Als Koffertransporteur ist es\ndeine Aufgabe, das Gepäck\nzu den Flugzeugen zu bringen.",true,gWindow["airportJob"])
		dgsLabelSetColor(gLabel["airportInfo2"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["airportInfo2"],"top")
		dgsLabelSetHorizontalAlign(gLabel["airportInfo2"],"left",false)
		dgsSetFont(gLabel["airportInfo2"],"default-bold")
		gLabel["airportInfo3"] = dgsCreateLabel(0.3739,0.2867,0.2836,0.0968,"Koffertransporteur",true,gWindow["airportJob"])
		dgsLabelSetColor(gLabel["airportInfo3"],200,200,000)
		dgsLabelSetVerticalAlign(gLabel["airportInfo3"],"top")
		dgsLabelSetHorizontalAlign(gLabel["airportInfo3"],"left",false)
		dgsSetFont(gLabel["airportInfo3"],"default-bold")

		gButton["airportTakeJob"] = dgsCreateButton(0.3361,0.7849,0.166,0.1685,"Auftrag\nannehmen",true,gWindow["airportJob"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["airportClose"] = dgsCreateButton(0.5189,0.7849,0.1744,0.1685,"Schliessen",true,gWindow["airportJob"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler("onDgsMouseClickUp", gButton["airportTakeJob"], clickOnAirportGUI )
		addEventHandler("onDgsMouseClickUp", gButton["airportClose"], clickOnAirportGUI )
		addEventHandler("onDgsMouseClickUp", gGrid["airportChoose"], clickOnAirportGUI )

		gMemo["airportOptic"] = dgsCreateMemo(0.71,0.073,0.0021,0.9,"",true,gWindow["airportJob"])

		gLabel["airportInfo4"] = dgsCreateLabel(0.3361,0.7,0.292,0.0717,"Aktueller Flughafenlevel:",true,gWindow["airportJob"])
		dgsLabelSetColor(gLabel["airportInfo4"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["airportInfo4"],"top")
		dgsLabelSetHorizontalAlign(gLabel["airportInfo4"],"left",false)
		dgsSetFont(gLabel["airportInfo4"],"default-bold")
		gLabel["airportInfo5"] = dgsCreateLabel(0.65,0.7,0.0441,0.0717,"",true,gWindow["airportJob"])
		dgsLabelSetColor(gLabel["airportInfo5"],120,010,0130)
		dgsLabelSetVerticalAlign(gLabel["airportInfo5"],"top")
		dgsLabelSetHorizontalAlign(gLabel["airportInfo5"],"left",false)
		dgsSetFont(gLabel["airportInfo5"],"default-bold")
		gLabel["airportInfo6"] = dgsCreateLabel(0.7227,0.0789,0.2626,0.1254,"Für diese Mission\nbenötigtes Fahrzeug:",true,gWindow["airportJob"])
		dgsLabelSetColor(gLabel["airportInfo6"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["airportInfo6"],"top")
		dgsLabelSetHorizontalAlign(gLabel["airportInfo6"],"left",false)
		dgsSetFont(gLabel["airportInfo6"],"default-bold")
		gLabel["airportInfo7"] = dgsCreateLabel(0.7878,0.2007,0.1155,0.0753,"Baggage",true,gWindow["airportJob"])
		dgsLabelSetColor(gLabel["airportInfo7"],120,000,000)
		dgsLabelSetVerticalAlign(gLabel["airportInfo7"],"top")
		dgsLabelSetHorizontalAlign(gLabel["airportInfo7"],"left",false)
		dgsSetFont(gLabel["airportInfo7"],"default-bold")
		gLabel["airportInfo8"] = dgsCreateLabel(0.7227,0.3262,0.2605,0.0609,"Fahrzeugauswahl:",true,gWindow["airportJob"])
		dgsLabelSetColor(gLabel["airportInfo8"],200,200,000)
		dgsLabelSetVerticalAlign(gLabel["airportInfo8"],"top")
		dgsLabelSetHorizontalAlign(gLabel["airportInfo8"],"left",false)
		dgsSetFont(gLabel["airportInfo8"],"default-bold")
		gLabel["airportInfo9"] = dgsCreateLabel(0.7227,0.3763,0.145,0.0573,"Boden:",true,gWindow["airportJob"])
		dgsLabelSetColor(gLabel["airportInfo9"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["airportInfo9"],"top")
		dgsLabelSetHorizontalAlign(gLabel["airportInfo9"],"left",false)
		dgsSetFont(gLabel["airportInfo9"],"default-bold")
		gLabel["airportInfo10"] = dgsCreateLabel(0.7227,0.4839,0.145,0.0573,"Luft (leicht):",true,gWindow["airportJob"])
		dgsLabelSetColor(gLabel["airportInfo10"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["airportInfo10"],"top")
		dgsLabelSetHorizontalAlign(gLabel["airportInfo10"],"left",false)
		dgsSetFont(gLabel["airportInfo10"],"default-bold")
		gLabel["airportInfo11"] = dgsCreateLabel(0.7206,0.6487,0.1618,0.0573,"Luft (mittel):",true,gWindow["airportJob"])
		dgsLabelSetColor(gLabel["airportInfo11"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["airportInfo11"],"top")
		dgsLabelSetHorizontalAlign(gLabel["airportInfo11"],"left",false)
		dgsSetFont(gLabel["airportInfo11"],"default-bold")
		gLabel["airportInfo12"] = dgsCreateLabel(0.7206,0.8065,0.1618,0.0573,"Luft (schwer):",true,gWindow["airportJob"])
		dgsLabelSetColor(gLabel["airportInfo12"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["airportInfo12"],"top")
		dgsLabelSetHorizontalAlign(gLabel["airportInfo12"],"left",false)
		dgsSetFont(gLabel["airportInfo12"],"default-bold")

		gRadio["baggage"] = dgsCreateRadioButton(0.7395,0.4265,0.1534,0.0573,"Baggage",true,gWindow["airportJob"])
		gRadio["dodo"] = dgsCreateRadioButton(0.7395,0.5341,0.1534,0.0573,"Dodo",true,gWindow["airportJob"])
		gRadio["beagle"] = dgsCreateRadioButton(0.7395,0.5914,0.1534,0.0573,"Beagle",true,gWindow["airportJob"])
		gRadio["nevada"] = dgsCreateRadioButton(0.7395,0.7025,0.1534,0.0573,"Nevada",true,gWindow["airportJob"])
		gRadio["shamal"] = dgsCreateRadioButton(0.7395,0.7599,0.1534,0.0573,"Shamal",true,gWindow["airportJob"])
		gRadio["at400"] = dgsCreateRadioButton(0.7395,0.8566,0.1534,0.0573,"AT-400",true,gWindow["airportJob"])
		gRadio["andromada"] = dgsCreateRadioButton(0.7395,0.914,0.1765,0.0538,"Andromada",true,gWindow["airportJob"])
		dgsRadioButtonSetSelected(gRadio["baggage"],true)
	end
	dgsSetText ( gLabel["airportInfo5"], vioClientGetElementData ( "airportlvl" ) )
	guiSetInputMode ( "no_binds_when_editing" )
	showCursor ( true )
	setElementClicked ( true )
end
addEvent ( "showAirportJobGui", true )
addEventHandler ( "showAirportJobGui", getRootElement(), showAirportJobGui_func )

function hideAllMarkersAirport()
	if source == localPlayer then
		if isElement(BaggageUnload1Vehicle) then
			destroyElement ( BaggageUnload1Vehicle )
		end
		if isElement(BaggageUnload2Vehicle) then
			destroyElement ( BaggageUnload2Vehicle )
		end
		if isElement(BaggageUnload3Vehicle) then
			destroyElement ( BaggageUnload3Vehicle )
		end
		if isElement(BaggageUnload1) then
			destroyElement ( BaggageUnload1 )
		end
		if isElement(BaggageUnload2) then
			destroyElement ( BaggageUnload2 )
		end
		if isElement(BaggageUnload3) then
			destroyElement ( BaggageUnload3 )
		end
		if isElement(BaggageUnload1Blip) then
			destroyElement ( BaggageUnload1Blip )
		end
		if isElement(BaggageUnload2Blip) then
			destroyElement ( BaggageUnload2Blip )
		end
		if isElement(BaggageUnload3Blip) then
			destroyElement ( BaggageUnload3Blip )
		end
		if isElement(CropdusterMarker1) then
			destroyElement ( CropdusterMarker1 )
		end
		if isElement(CropdusterMarker2) then
			destroyElement ( CropdusterMarker2 )
		end
		if isElement(CropdusterMarker3) then
			destroyElement ( CropdusterMarker3 )
		end
		if isElement(CropdusterMarker4) then
			destroyElement ( CropdusterMarker4 )
		end
		if isElement(CropdusterMarker5) then
			destroyElement ( CropdusterMarker5 )
		end
		if isElement(CropdusterMarker1Blip) then
			destroyElement ( CropdusterMarker1Blip )
		end
		if isElement(CropdusterMarker2Blip) then
			destroyElement ( CropdusterMarker2Blip )
		end
		if isElement(CropdusterMarker3Blip) then
			destroyElement ( CropdusterMarker3Blip )
		end
		if isElement(CropdusterMarker4Blip) then
			destroyElement ( CropdusterMarker4Blip )
		end
		if isElement(CropdusterMarker5Blip) then
			destroyElement ( CropdusterMarker5Blip )
		end
		if isElement(AirportTargetBlip) then
			destroyElement ( AirportTargetBlip )
		end
		if isElement(AirportTargetMarker) then
			destroyElement ( AirportTargetMarker )
		end
	end
end
addEventHandler ( "stopAirportJob", getRootElement(), hideAllMarkersAirport )

function showDeliverPoints()

	local dim = vioClientGetElementData ( "jobDimension" )
	hideDeliverPoints()
	BaggageUnload1Vehicle = createVehicle ( 577, -1338.7501220703, -223.37954711914, 14.209453582764, 0, 0, 134.99987792969 )
	BaggageUnload1 = createMarker ( -1361.6362304688, -228.25860595703, 14.143964767456, "checkpoint", 10, 125, 0, 0, 255, getRootElement() )
	BaggageUnload2Vehicle = createVehicle ( 592, -1501.3070068359, -154.43298339844, 15, 0, 0, 135 )
	BaggageUnload2 = createMarker ( -1522.2647705078, -160.74020385742, 14.1484375, "checkpoint", 10, 125, 0, 0, 255, getRootElement() )
	BaggageUnload3Vehicle = createVehicle ( 417, -1221.8127441406, -8.256688117981, 14.623241424561 )
	BaggageUnload3 = createMarker ( -1234.8166503906, -12.079794883728, 14.1484375, "checkpoint", 10, 125, 0, 0, 255, getRootElement() )
	addEventHandler ( "onClientMarkerHit", BaggageUnload1, BaggageUnloadMarkerHit )
	addEventHandler ( "onClientMarkerHit", BaggageUnload2, BaggageUnloadMarkerHit )
	addEventHandler ( "onClientMarkerHit", BaggageUnload3, BaggageUnloadMarkerHit )
	setElementDimension ( BaggageUnload1Vehicle, dim )
	setElementDimension ( BaggageUnload2Vehicle, dim )
	setElementDimension ( BaggageUnload3Vehicle, dim )
	baggageNumber[BaggageUnload1] = 1
	baggageNumber[BaggageUnload2] = 2
	baggageNumber[BaggageUnload3] = 3
	count = 0
	setElementDimension ( BaggageUnload1, dim )
	setElementDimension ( BaggageUnload2, dim )
	setElementDimension ( BaggageUnload3, dim )
	BaggageUnload1Blip = createBlip ( -1361.6362304688, -228.25860595703, 14.143964767456, 0, 2, 255, 0, 0, 255, 0, 99999.0, lp )
	BaggageUnload2Blip = createBlip ( -1522.2647705078, -160.74020385742, 14.1484375, 0, 2, 255, 0, 0, 255, 0, 99999.0, lp )
	BaggageUnload3Blip = createBlip ( -1234.8166503906, -12.079794883728, 14.1484375, 0, 2, 255, 0, 0, 255, 0, 99999.0, lp )
	setElementDimension ( BaggageUnload1Blip, dim )
	setElementDimension ( BaggageUnload2Blip, dim )
	setElementDimension ( BaggageUnload3Blip, dim )
end

function hideDeliverPoints()

	if isElement ( BaggageUnload1Vehicle ) then
		destroyElement ( BaggageUnload1Vehicle )
		destroyElement ( BaggageUnload2Vehicle )
		destroyElement ( BaggageUnload3Vehicle )
	end
	if isElement ( BaggageUnload1 ) then
		destroyElement ( BaggageUnload1 )
		destroyElement ( BaggageUnload2 )
		destroyElement ( BaggageUnload3 )
		destroyElement ( BaggageUnload1Blip )
		destroyElement ( BaggageUnload2Blip )
		destroyElement ( BaggageUnload3Blip )
	end
end

function BaggageUnloadMarkerHit ( hit, dim )

	if dim and hit == lp then
		if source == BaggageUnload1 or source == BaggageUnload2 or source == BaggageUnload3 then
			local trailer = getVehicleTowedByVehicle ( getPedOccupiedVehicle ( hit ) )
			if trailer then
				local blip = baggageNumber[source]
				destroyElement ( source	)
				destroyElement ( _G["BaggageUnload"..blip.."Blip"] )
				count = count + 1
				if count == 3 then
					triggerServerEvent ( "baggageMissionComplete", lp )
				else
					outputChatBox ( "Hol dir einen neuen Anhänger!", 10, 150, 10 )
				end
				playSoundFrontEnd ( 43 )
				triggerServerEvent ( "killTrailer", hit, trailer )
			end
		end
	end
end


function hideCropdusterPoints()

	for i = 1, 5 do
		if isElement(_G["CropdusterMarker"..i]) then
			destroyElement ( _G["CropdusterMarker"..i] )
		end
		if isElement(_G["CropdusterMarker"..i.."Blip"]) then
			destroyElement ( _G["CropdusterMarker"..i.."Blip"] )
		end
	end
end


function CropDusterMarkerHit ( hit, dim )
	if hit == lp and dim then
		local veh = getPedOccupiedVehicle ( hit )
		local i = getElementData ( source, "i" )
		destroyElement ( _G["CropdusterMarker"..i.."Blip"] )
		destroyElement ( source )
		count = count + 1
		if count == 5 then
			triggerServerEvent ( "cropdusterMissionComplete", lp )
		end
		playSoundFrontEnd ( 43 )
	end
end


function showCropdusterPoints ()

	local dim = vioClientGetElementData ( "jobDimension" )
	hideCropdusterPoints()
	CropdusterMarker1  = createMarker ( -1104.9104003906, -978.28009033203, 189.46875, "ring", 10, 125, 0, 0, 255, localPlayer )
	CropdusterMarker2  = createMarker ( -281.89483642578, -1521.7196044922, 89.01439666748, "ring", 10, 125, 0, 0, 255, localPlayer )
	CropdusterMarker3  = createMarker ( -263.64831542969, -1369.1451416016, 77.448867797852, "ring", 10, 125, 0, 0, 255, localPlayer )
	CropdusterMarker4  = createMarker ( -279.80813598633, -957.28393554688, 127.56575012207, "ring", 10, 125, 0, 0, 255, localPlayer )
	CropdusterMarker5  = createMarker ( -480.54431152344, -1359.1550292969, 93.225845336914, "ring", 10, 125, 0, 0, 255, localPlayer )
	setElementData ( CropdusterMarker1, "i", 1 )
	setElementData ( CropdusterMarker2, "i", 2 )
	setElementData ( CropdusterMarker3, "i", 3 )
	setElementData ( CropdusterMarker4, "i", 4 )
	setElementData ( CropdusterMarker5, "i", 5 )
	setElementDimension ( CropdusterMarker1, dim )
	setElementDimension ( CropdusterMarker2, dim )
	setElementDimension ( CropdusterMarker3, dim )
	setElementDimension ( CropdusterMarker4, dim )
	setElementDimension ( CropdusterMarker5, dim )
	addEventHandler ( "onClientMarkerHit", CropdusterMarker1, CropDusterMarkerHit )
	addEventHandler ( "onClientMarkerHit", CropdusterMarker2, CropDusterMarkerHit )
	addEventHandler ( "onClientMarkerHit", CropdusterMarker3, CropDusterMarkerHit )
	addEventHandler ( "onClientMarkerHit", CropdusterMarker4, CropDusterMarkerHit )
	addEventHandler ( "onClientMarkerHit", CropdusterMarker5, CropDusterMarkerHit )
	CropdusterMarker1Blip = createBlip ( -1104.9104003906, -978.28009033203, 189.46875, 0, 2, 255, 0, 0, 255, 0, 99999.0, lp )
	CropdusterMarker2Blip = createBlip ( -281.89483642578, -1521.7196044922, 89.01439666748, 0, 2, 255, 0, 0, 255, 0, 99999.0, lp )
	CropdusterMarker3Blip = createBlip ( -263.64831542969, -1369.1451416016, 77.448867797852, 0, 2, 255, 0, 0, 255, 0, 99999.0, lp )
	CropdusterMarker4Blip = createBlip ( -279.80813598633, -957.28393554688, 127.56575012207, 0, 2, 255, 0, 0, 255, 0, 99999.0, lp )
	CropdusterMarker5Blip = createBlip ( -480.54431152344, -1359.1550292969, 93.225845336914, 0, 2, 255, 0, 0, 255, 0, 99999.0, lp )
	setElementDimension ( CropdusterMarker1Blip, dim )
	setElementDimension ( CropdusterMarker2Blip, dim )
	setElementDimension ( CropdusterMarker3Blip, dim )
	setElementDimension ( CropdusterMarker4Blip, dim )
	setElementDimension ( CropdusterMarker5Blip, dim )
	outputChatBox ( "Verteile die Pestiziede über den Feldern!", 200, 200, 0 )
end

function startFreightMission ( veh )

	hideAllMarkersAirport()
	local dim = vioClientGetElementData ( "jobDimension" )
	if isElement ( AirportTargetMarker ) then
		destroyElement ( AirportTargetMarker )
		destroyElement ( AirportTargetBlip )
	end
	local rnd = math.random ( 1, 3 )
	if rnd == 1 then		-- Schrottplatz
		AirportTargetMarker = createMarker ( 393.78289794922, 2502.5717773438, 15.734373092651, "ring", 10, 125, 0, 0, 255, getRootElement() )
		AirportTargetBlip = createBlip ( 393.78289794922, 2502.5717773438, 15.734373092651, 0, 2, 255, 0, 0, 255, 0, 99999.0, lp )
		outputChatBox ( "Fliege dein Flugzeug unbeschädigt zum Flugzeugfriedhof.", 200, 200, 0 )
	elseif rnd == 2 then 	-- LV
		AirportTargetMarker = createMarker ( 1433.0295410156, 1463.6586914063, 10.8203125, "ring", 10, 125, 0, 0, 255, getRootElement() )
		AirportTargetBlip = createBlip ( 1433.0295410156, 1463.6586914063, 10.8203125, 0, 2, 255, 0, 0, 255, 0, 99999.0, lp )
		outputChatBox ( "Fliege dein Flugzeug unbeschädigt zum Las Venturas International Airport.", 200, 200, 0 )
	else					-- LS
		AirportTargetMarker = createMarker ( 1834.8217773438, -2494.7470703125, 13.554689407349, "ring", 10, 125, 0, 0, 255, getRootElement() )
		AirportTargetBlip = createBlip ( 1834.8217773438, -2494.7470703125, 13.554689407349, 0, 2, 255, 0, 0, 255, 0, 99999.0, lp )
		outputChatBox ( "Fliege dein Flugzeug unbeschädigt zum Los Santos International Airport.", 200, 200, 0 )
	end
	addEventHandler ( "onClientMarkerHit", AirportTargetMarker, hitAirportTargetMarker )
	if veh == 511 or veh == 593 then
		x, y, z = -1345.1088867188, -528.98895263672, 15.555714607239
		rot = 205
	elseif veh == 519 or veh == 553 then
		x, y, z = -1422.5704345703, -560.97271728516, 16.543201446533
		rot = 205
	elseif veh == 592 then
		x, y, z = -1626.5688476563, -476.66955566406, 23.178987503052
		rot = 45
	else
		x, y, z = -1619.9566650391, -483.23001098633, 22.035705566406
		rot = 45
	end
	setElementDimension ( AirportTargetBlip, dim )
	setElementDimension ( AirportTargetMarker, dim )
	dgsSetVisible ( gWindow["airportJob"], false )
	guiSetInputMode("allow_binds")
	showCursor(false)
	setElementClicked ( false )
	triggerServerEvent ( "cancel_gui_server", lp )
	triggerServerEvent ( "airportJobFlight", lp, veh, x, y, z, rot )
end


freightModel = { [511]=true, [593]=true, [519]=true, [553]=true, [592]=true, [577]=true }

function hitAirportTargetMarker ( hit, dim )
	if hit == lp then
		if freightModel[ getElementModel ( getPedOccupiedVehicle ( lp ) ) ] then
			destroyElement ( source )
			destroyElement ( AirportTargetBlip )
			local veh = getPedOccupiedVehicle ( hit )
			local vehid = getElementModel ( veh )
			triggerServerEvent ( "airportJobFreightFinished", lp, vehid )
			playSoundFrontEnd ( 43 )
		end
	end
end
