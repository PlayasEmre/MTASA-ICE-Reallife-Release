--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function cancelRathausMenue(button)
	if button ~= nil and button ~= "left" then return end
	if gWindow["rathausbg"] then
		dgsSetVisible(gWindow["rathausbg"], false)
		showCursor(false)
		triggerServerEvent ( "cancel_gui_server", localPlayer )
	end
end

function beantragen ( button )
	if button == "left" then
		player = localPlayer
		cancelRathausMenue ( button )
		triggerServerEvent ( "LizenzKaufen", localPlayer, player, license )
	end
end

function ShowRathausMenue_func()
	_createCityhallGui()
end
addEvent ( "ShowRathausMenue", true)
addEventHandler ( "ShowRathausMenue", localPlayer,  ShowRathausMenue_func)

function _createCityhallGui(btn)
	showCursor ( true )
	if gWindow["rathausbg"] then
		dgsSetVisible ( gWindow["rathausbg"], true )
		dgsBringToFront ( gWindow["rathausbg"] )
	else
	if btn == "left" then end
		gWindow["rathausbg"] = dgsCreateWindow(screenwidth/2-600/2,screenheight/2-351/2,600,351,"Stadthalle",false)
		dgsBringToFront ( gWindow["rathausbg"] )
		dgsWindowSetSizable ( gWindow["rathausbg"], false )
		dgsWindowSetMovable ( gWindow["rathausbg"], false )
		dgsWindowSetCloseButtonEnabled(gWindow["rathausbg"], false)
		dgsSetAlpha(gWindow["rathausbg"],1)
		gGrid["Licenses"] = dgsCreateGridList(0.0201,0.2309,0.4509,0.6773,true,gWindow["rathausbg"])
		dgsGridListSetSelectionMode(gGrid["Licenses"],0)
		gColumn["cityhallLicense"] = dgsGridListAddColumn(gGrid["Licenses"],"Schein",0.51)
		gColumn["cityhallPreis"] = dgsGridListAddColumn(gGrid["Licenses"],"Preis",0.25)
		gColumn["cityhallVorhanden"] = dgsGridListAddColumn(gGrid["Licenses"],"",0.04)
		dgsSetAlpha(gGrid["Licenses"],1)
		gLabel["cityhalInfotext1"] = dgsCreateLabel(0.0179,0.0797,0.9688,0.1753,"Herzlich wilkommen bei der Stadthalle!\nHier kannst du neue Scheine erwerben sowie dir einen neuen Job besorgen -\ndafuer schliesse dieses Fenster und begib dich zum Aktenkoffer neben an.",true,gWindow["rathausbg"])
		dgsSetAlpha(gLabel["cityhalInfotext1"],1)
		dgsLabelSetColor(gLabel["cityhalInfotext1"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["cityhalInfotext1"],"top")
		dgsLabelSetHorizontalAlign(gLabel["cityhalInfotext1"],"left",false)
		dgsSetFont(gLabel["cityhalInfotext1"],"default")
		gLabel["cityhalInfotext2"] = dgsCreateLabel(0.6228,0.3347,0.1964,0.0677,"Fuehrerschein",true,gWindow["rathausbg"])
		dgsSetAlpha(gLabel["cityhalInfotext2"],1)
		dgsLabelSetColor(gLabel["cityhalInfotext2"],63,160,224)
		dgsLabelSetVerticalAlign(gLabel["cityhalInfotext2"],"top")
		dgsLabelSetHorizontalAlign(gLabel["cityhalInfotext2"],"left",false)
		dgsSetFont(gLabel["cityhalInfotext2"],"default-bold")
		gLabel["cityhalInfotext3"] = dgsCreateLabel(0.4888,0.4024,0.4866,0.2231,"Mit einem Fuehrerschein kannst du\nalle Autos fahren, jedoch ist eine\ntheoretische und praktische Pruefung\nPflicht.",true,gWindow["rathausbg"])
		dgsSetAlpha(gLabel["cityhalInfotext3"],1)
		dgsLabelSetColor(gLabel["cityhalInfotext3"],125,125,200)
		dgsLabelSetVerticalAlign(gLabel["cityhalInfotext3"],"top")
		dgsLabelSetHorizontalAlign(gLabel["cityhalInfotext3"],"left",false)
		dgsSetFont(gLabel["cityhalInfotext3"],"default")
		gButton["beantragen"] = dgsCreateButton(0.5022,0.7729,0.140,0.100,"Beantragen",true,gWindow["rathausbg"],nil,nil,nil,nil,nil,nil,tocolor(46,110,255,255),tocolor(123,163,255,255),tocolor(24,74,199,255))
		dgsSetAlpha(gButton["beantragen"],1)
		gButton["schliessen"] = dgsCreateButton(0.75,0.7729,0.140,0.100,"Schliessen",true,gWindow["rathausbg"])
		dgsSetAlpha(gButton["schliessen"],1)
		
		addEventHandler("onDgsMouseClickUp", gButton["schliessen"], cancelRathausMenue,false)
		addEventHandler("onDgsMouseClickUp", gButton["beantragen"], beantragen,false)
		
		refreshCityhallTexts()
	end
	refreshLicenses()
end

function rathausClick ()
	if gWindow["rathausbg"] and source == gGrid["Licenses"] then 
		local rowindex = dgsGridListGetSelectedItem ( gGrid["Licenses"] )
		-- Klick neben die Eintraege liefert -1.
		if not rowindex or rowindex < 0 then return end
		local selectedText = dgsGridListGetItemText ( gGrid["Licenses"], rowindex, gColumn["cityhallLicense"] )
		if selectedText == "Flugschein B" then
			license = "planeb"
			refreshCityhallTexts()
		elseif selectedText == "Flugschein A" then
			license = "planea"
			refreshCityhallTexts()
		elseif selectedText == "Segelschein" then
			license = "raft"
			refreshCityhallTexts()
		elseif selectedText == "Personalausweis" then
			license = "perso"
			refreshCityhallTexts()
		elseif selectedText == "Angelschein" then
			license = "fishing"
			refreshCityhallTexts()
		elseif selectedText == "Waffenschein" then
			license = "wschein"
			refreshCityhallTexts()
		elseif selectedText == "Max. Fahrzeuge" then
			license = "maxveh"
			refreshCityhallTexts()
		end
	end
end
addEventHandler("onDgsMouseClick", getRootElement(), rathausClick)

function refreshLicenses()

	dgsGridListClear ( gGrid["Licenses"] )
	
	
	local row = dgsGridListAddRow ( gGrid["Licenses"] )
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallLicense"], "Flugschein A", false, false )
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallPreis"], "15.000 "..Tables.waehrung.."", false, false )
	if vioClientGetElementData ( "planelicensea" ) == 1 then fix = "✓" else fix = "X" end
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallVorhanden"], fix, false, false )
	
	local row = dgsGridListAddRow ( gGrid["Licenses"] )
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallLicense"], "Flugschein B", false, false )
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallPreis"], "34.950 "..Tables.waehrung.."", false, false )
	if vioClientGetElementData ( "planelicenseb" ) == 1 then fix = "✓" else fix = "X" end
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallVorhanden"], fix, false, false )
	
	local row = dgsGridListAddRow ( gGrid["Licenses"] )
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallLicense"], "Segelschein", false, false )
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallPreis"], "200 "..Tables.waehrung.."", false, false )
	if vioClientGetElementData ( "segellicense" ) == 1 then fix = "✓" else fix = "X" end
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallVorhanden"], fix, false, false )
	
	local row = dgsGridListAddRow ( gGrid["Licenses"] )
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallLicense"], "Waffenschein", false, false )
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallPreis"], "5000 "..Tables.waehrung.."", false, false )
	if vioClientGetElementData ( "gunlicense" ) == 1 then fix = "✓" else fix = "X" end
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallVorhanden"], fix, false, false )
	
	local row = dgsGridListAddRow ( gGrid["Licenses"] )
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallLicense"], "Angelschein", false, false )
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallPreis"], "100 "..Tables.waehrung.."", false, false )
	if vioClientGetElementData ( "fishinglicense" ) == 1 then fix = "✓" else fix = "X" end
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallVorhanden"], fix, false, false )
	
	local row = dgsGridListAddRow ( gGrid["Licenses"] )
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallLicense"], "Personalausweis", false, false )
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallPreis"], "200 "..Tables.waehrung.."", false, false )
	if vioClientGetElementData ( "perso" ) == 1 then fix = "✓" else fix = "X" end 
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallVorhanden"], fix, false, false )
	
	local row = dgsGridListAddRow ( gGrid["Licenses"] )
	local thepreis = convertNumber(fahrzeugslotprice[vioClientGetElementData( "maxcars")])
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallLicense"], "Max. Fahrzeuge", false, false )
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallPreis"], thepreis.." "..Tables.waehrung.."", false, false )
	if vioClientGetElementData ( "maxcars" ) >= 15 then fix = "✓" else fix = "X" end
	dgsGridListSetItemText( gGrid["Licenses"], row, gColumn["cityhallVorhanden"], fix, false, false )

	license = "car"
	refreshCityhallTexts()
end

function refreshCityhallTexts()

	if license == "planeb" then
		dgsSetText ( gLabel["cityhalInfotext2"], "Flugschein B" )
		dgsSetText ( gLabel["cityhalInfotext3"], "Mit einem Flugschein B kannst du\nalle Flugzeuge fliegen, egal wie goss.\nWichtig: Flugschein Klasse A wird benoetigt!" )
	elseif license == "planea" then
		dgsSetText ( gLabel["cityhalInfotext2"], "Flugschein A" )
		dgsSetText ( gLabel["cityhalInfotext3"], "Mit einem Flugschein A kannst du\nalle kleineren Flugzeuge fliegen." )
	elseif license == "raft" then
		dgsSetText ( gLabel["cityhalInfotext2"], "Segelschein" )
		dgsSetText ( gLabel["cityhalInfotext3"], "Mit einem Segelschein kannst du\nauch Schiffe mit Segel fahren.\nWichtig: Motorbootschein wird benoetigt!" )
	elseif license == "perso" then
		dgsSetText ( gLabel["cityhalInfotext2"], "Personalausweis" )
		dgsSetText ( gLabel["cityhalInfotext3"], "Ohne einen Personalausweiss kannst du\nbestimmte Locations nicht betreten." )
	elseif license == "fishing" then
		dgsSetText ( gLabel["cityhalInfotext2"], "Angelschein" )
		dgsSetText ( gLabel["cityhalInfotext3"], "Ohne Angelschein darfst du nicht fischen,\naussderm brauchst du ihn, wenn du\nals Fischer arbeiten willst." )
	elseif license == "wschein" then
		dgsSetText ( gLabel["cityhalInfotext2"], "Waffenschein" )
		dgsSetText ( gLabel["cityhalInfotext3"], "Ohne Waffenschein darfst du keine\nWaffen legal erwerben." )
	elseif license == "maxveh" then
		dgsSetText ( gLabel["cityhalInfotext2"], "Max. Fahrzeuge" )
		dgsSetText ( gLabel["cityhalInfotext3"], "Die Stadt erlaubt dir nur eine\ngewissen Anzahl von Fahrzeugen.\nDu kannst die Anzahl jedoch\nhier erhöhen." )
	end
end


function convertNumber ( number )  
	local formatted = number  
	while true do      
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')    
		if ( k==0 ) then      
			break   
		end  
	end  
	return formatted
end