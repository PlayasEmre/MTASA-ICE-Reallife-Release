--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function _createBonusmenue_func()
	showCursor ( true )
	if gWindow["bonusmenue"] then
		dgsSetVisible ( gWindow["bonusmenue"], true )
		dgsBringToFront ( gWindow["bonusmenue"] )
	else
		gWindow["bonusmenue"] = dgsCreateWindow ( screenwidth/2-370/2, 120, 370, 424, "Bonus menue",false)
		dgsBringToFront ( gWindow["bonusmenue"] )
		dgsWindowSetCloseButtonEnabled(gWindow["bonusmenue"], false)
		dgsWindowSetMovable ( gWindow["bonusmenue"], false )
		dgsWindowSetSizable ( gWindow["bonusmenue"], false )
		dgsSetAlpha(gWindow["bonusmenue"],1)
		gGrid["bonusliste"] = dgsCreateGridList(0.027,0.0227,0.4649,0.9104,true,gWindow["bonusmenue"])
		dgsGridListSetSelectionMode(gGrid["bonusliste"],1)
		gColumn["bonusName"] = dgsGridListAddColumn(gGrid["bonusliste"],"Bonus",0.6)
		gColumn["bonusKosten"] = dgsGridListAddColumn(gGrid["bonusliste"],"Kosten",0.2)
		dgsSetAlpha(gGrid["bonusliste"],1)
		gButton["buyBonus"] = dgsCreateButton(0.5054,0.7797,0.2216,0.0896,"",true,gWindow["bonusmenue"],_,_,_,_,_,_,tocolor(46,110,255,255),tocolor(123,163,255,255),tocolor(24,74,199,255),true)
		dgsSetAlpha(gButton["buyBonus"],1)
		gButton["cancelBonus"] = dgsCreateButton(0.7405,0.7797,0.2516,0.0896,"Menü schliessen",true,gWindow["bonusmenue"],_,_,_,_,_,_,nil,nil,nil,true)
		dgsSetAlpha(gButton["cancelBonus"],1)
		gLabel["Bonusname"] = dgsCreateLabel(0.5027,0.0637,0.4838,0.0542,"",true,gWindow["bonusmenue"])
		dgsSetAlpha(gLabel["Bonusname"],1)
		dgsLabelSetColor(gLabel["Bonusname"],125,000,000)
		dgsLabelSetVerticalAlign(gLabel["Bonusname"],"top")
		dgsLabelSetHorizontalAlign(gLabel["Bonusname"],"left",false)
		dgsSetFont(gLabel["Bonusname"],"default-bold")
		gLabel["Description"] = dgsCreateLabel(0.5,0.1179,0.4784,0.592,"Herzlich Willkommen im\n\"Bonusmenü\"\nHier kannst du deine\nBonuspunkte, die durch\nAchievments und dem\nsammeln von versteckten\nPückchen erhalten kannst,\nfür besondere Belohnungen\nausgeben.",true,gWindow["bonusmenue"])
		dgsSetAlpha(gLabel["Description"],1)
		dgsLabelSetColor(gLabel["Description"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["Description"],"top")
		dgsLabelSetHorizontalAlign(gLabel["Description"],"left",false)
		gLabel["yourPoints"] = dgsCreateLabel(0.5108,0.6382,0.3081,0.0566,"Deine Bonuspunkte:",true,gWindow["bonusmenue"])
		dgsSetAlpha(gLabel["yourPoints"],1)
		dgsLabelSetColor(gLabel["yourPoints"],63,160,224)
		dgsLabelSetVerticalAlign(gLabel["yourPoints"],"top")
		dgsLabelSetHorizontalAlign(gLabel["yourPoints"],"left",false)
		dgsSetFont(gLabel["yourPoints"],"default-bold")
		gLabel["bonusPoints"] = dgsCreateLabel(0.5324,0.6854,0.2351,0.059,"0 Punkte",true,gWindow["bonusmenue"])
		dgsSetAlpha(gLabel["bonusPoints"],1)
		dgsLabelSetColor(gLabel["bonusPoints"],000,125,020)
		dgsLabelSetVerticalAlign(gLabel["bonusPoints"],"top")
		dgsLabelSetHorizontalAlign(gLabel["bonusPoints"],"left",false)
		
		addEventHandler("onDgsMouseClickUp", gButton["cancelBonus"],
			function(button)
			if button == "left" then
				dgsSetVisible ( gWindow["bonusmenue"], false )
				showCursor ( false )
			end
		end)
		
		addEventHandler("onDgsMouseClickUp", getRootElement(),
			function(button)
			if button == "left" then
				if source == gGrid["bonusliste"] then
					-- Ohne Auswahl liefert dgsGridListGetSelectedItem -1, was
					-- dgsGridListGetItemText mit einem Fehler quittiert.
					local zeile = dgsGridListGetSelectedItem ( gGrid["bonusliste"] )
					if not zeile or zeile < 0 then return end
					local row = dgsGridListGetItemText ( gGrid["bonusliste"], zeile, 1 )
					local state = dgsGridListGetItemText ( gGrid["bonusliste"], zeile, 2 )
					if row then
						if state == " [x]" then 
							state = "Gekauft"
							if row == " Boxen" or row == " Kung-Fu" or row == " Streetfighting" or row == " Cluckin Bell" or row == " Doppel SMG" then
								dgsSetText ( gButton["buyBonus"], "Verwenden" )
								if row == " Doppel SMG" then
									if getPedStat ( lp, 75 ) == 999 then
										dgsSetText ( gButton["buyBonus"], "Deaktivieren" )
									else
										dgsSetText ( gButton["buyBonus"], "Aktivieren" )
									end
								end
							else
								dgsSetText ( gButton["buyBonus"], "" )
							end
						else
							state = "NICHT gekauft"
							dgsSetText ( gButton["buyBonus"], "Bonus kaufen" )
						end
						if row == " Lungenvolumen" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Lungenvolumen - 35 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus steigert\ndein Lungenvolumen, so dass\ndu in der Lage bist,\ndeutlich laenger zu tauchen,\nohne zu ertrinken.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
						elseif row == " Muskeln" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Muskeln - 40 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus steigert\ndeine Muskeln, so dass\ndu in der Lage bist,\ndeutlich staeker zu zu-\nschlagen und somit mehr\nSchaden verursachst.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
						elseif row == " Kondition" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Kondition - 25 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus erlaubt es\ndir, laenger zu sprinten\nohne zu erschoepfen.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
						elseif row == " Boxen" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Boxen - 25 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus erlaubt es\ndir, Boxhiebe zu verteilen.\n\nInfo: Muss erst\naktiviert werden und kann\nnicht mit anderen\nKampfkuensten kombiniert\nwerden, Status: "..state )
						elseif row == " Kung-Fu" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Kung-Fu - 35 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus lasst dich\nzu einem Meister des Kong-Fu\nwerden.\n\nInfo: Muss erst\naktiviert werden und kann\nnicht mit anderen\nKampfkuensten kombiniert\nwerden, Status: "..state )
						elseif row == " Streetfighting" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Streetfighting - 40 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus laesst dich\nunfair kaempfen.\n\nInfo: Muss erst\naktiviert werden und kann\nnicht mit anderen\nKampfkuensten kombiniert\nwerden, Status: "..state )
						elseif row == " Pistole" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Pistolenskills - 20 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus erhoeht deine\nFaehigkeiten mit der\nnormalen und der Schallge-\ndaempften Pistole.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
						elseif row == " Deagle" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Desertskills - 30 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus erhoeht deine\nFaehigkeiten mit der\nDesert Eagle.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
						elseif row == " Sturmgewehr" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Sturmgewehrskills - 30 P." )
							dgsSetText ( gLabel["Description"], "Dieser Bonus erhoehen deine\nFaehigkeiten mit der\n AK-47 und der M4.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
						elseif row == " Schrotflinten" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Schrotflintenskills - 20 P." )
							dgsSetText ( gLabel["Description"], "Dieser Bonus erhoehen deine\nFaehigkeiten mit allen Schrot-\nflinten.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
						elseif row == " MP5" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "MP5-skills - 35 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus erhoehen deine\nFaehigkeiten mit der\nMP5.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
						elseif row == " Doppel SMG" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Doppel SMG - 50 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus erlaubt es dir,\nzwei SMGs wie die Tec9 oder\ndie Uzi gleichzeitig zu tragen.\n\nInfo: Automatisch aktiv,\nkann umgestellt werden,\nStatus: "..state )
						elseif row == " Fahrzeugslots" then
							selectedBonus = row
							
							if vioClientGetElementData ( "carslotupgrade2" ) == 1 then
								cost = 75
								maxCars = 10
							elseif vioClientGetElementData ( "carslotupgrade" ) == "done" then
								cost = 60
								maxCars = 7
							else
								cost = 50
								maxCars = 5
							end
							
							dgsSetText ( gLabel["Bonusname"], "Carsloterhoehung - "..cost.." P." )
							dgsSetText ( gLabel["Description"], "Dieser Bonus erhoeht deine\nFahrzeugslots auf maximal\n"..maxCars.." moegliche Fahrzeuge.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
						elseif row == " Vortex" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Vortex - 30 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus schaltet\ndas Vortex-Luftkissenboot\nzum Kauf an den\nBonushallen frei.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
						elseif row == " Quad" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Quadbike - 30 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus schaltet\ndas Quadbike\nzum Kauf an den\nBonushallen frei.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
						elseif row == " Caddy" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Caddy - 25 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus schaltet\ndas Golfcaddy\nzum Kauf an den\nBonushallen frei.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
						elseif row == " Skimmer" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Skimmer - 50 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus schaltet\nden Skimmer\nzum Kauf an den\nBonushallen frei.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
						elseif row == " Leichenwagen" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Leichenwagen - 50 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus schaltet\nden Leichenwagen\nzum Kauf an den\nBonushallen frei.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
						elseif row == " Cluckin Bell" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Cluckin Bell - 25 Punkte" )
							dgsSetText ( gLabel["Description"], "Dieser Bonus schaltet\nden Huehnchenskin\nfrei." )
						elseif row == " Notebook" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Notebook - 25 Punkte" )
							dgsSetText ( gLabel["Description"], "Immer und ueberall\nins Internet!" )
						elseif row == " Spielekonsole" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Spielekonsole - 25 Punkte" )
							dgsSetText ( gLabel["Description"], "Immer und ueberall\nspielen! Ideal\nim Knast!" )
						elseif row == " Schachspiel" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Schachspiel - 15 Punkte" )
							dgsSetText ( gLabel["Description"], "Mit jedem und\nueberall spielen! Ideal\nim Knast!" )
						elseif row == " Fernglas" then
							selectedBonus = row
							dgsSetText ( gLabel["Bonusname"], "Fernglas - 10 Punkte" )
							dgsSetText ( gLabel["Description"], "Auch ueber grosse\nEntfernungen den Ueber-\nblick behalten." )
						end
					end
				end
			end
		end)
		
		addEventHandler("onDgsMouseClickUp", gButton["buyBonus"], 
			function(button)
			if button == "left" then
				local selectedRow, selectedColumn = dgsGridListGetSelectedItem(gGrid["bonusliste"])
				if selectedRow and selectedColumn ~= -1 then
				   selectedRow = dgsGridListGetItemText(gGrid["bonusliste"], selectedRow, selectedColumn)
				   triggerServerEvent("bonusBuy", localPlayer, localPlayer, selectedRow, selectedColumn)
				end
			end
		end)
		
		dgsGridListSetSelectionMode ( gGrid["bonusliste"], 1 )
		fillBonusList ()
	end	
end
addEvent ( "_createBonusmenue", true )
addEventHandler ( "_createBonusmenue", getRootElement(), _createBonusmenue_func )

function refreshBonus_func ( newText )

	if not newText then
		newText = ""
	end
	
	dgsSetText ( gLabel["bonusPoints"], vioClientGetElementData ("bonuspoints").." Punkte" )
	dgsSetText ( gButton["buyBonus"], newText )
	local row, column = dgsGridListGetSelectedItem ( gGrid["bonusliste"] )
	if row and row >= 0 and dgsGridListGetItemText ( gGrid["bonusliste"], row, 1 ) == " Fahrzeugslots" then
		if vioClientGetElementData ( "carslotupgrade2" ) == 1 then
			cost = 75
			maxCars = 10
		elseif vioClientGetElementData ( "carslotupgrade" ) == "done" then
			cost = 60
			maxCars = 7
		else
			cost = 50
			maxCars = 5
		end
		
		dgsSetText ( gLabel["Bonusname"], "Carsloterhoehung - "..cost.." P." )
		dgsSetText ( gLabel["Description"], "Dieser Bonus erhoeht deine\nFahrzeugslots auf maximal\n"..maxCars.." moegliche Fahrzeuge.\n\nInfo: Automatisch u. dauerhaft\naktiv, Status: "..state )
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, 2, " [x]", false, false )
	dgsGridListSetSelectedItem ( gGrid["bonusliste"], row, 1 )
end
addEvent ( "refreshBonus", true )
addEventHandler ( "refreshBonus", getRootElement(), refreshBonus_func )

function fillBonusList ()
	dgsSetText ( gButton["buyBonus"], "" )
	local player = lp
	dgsGridListClear ( gGrid["bonusliste"] )
	selectedBonus = "none"
	dgsSetText ( gLabel["bonusPoints"], vioClientGetElementData("bonuspoints").." Punkte" )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], "Körperlich", true, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Lungenvolumen", false, false )
	if vioClientGetElementData ( "lungenvol" ) ~= "none" then
		fix = " [x]"
	else
		fix = "35 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Muskeln", false, false )
	if vioClientGetElementData ( "muscle" ) ~= "none" then
		fix = " [x]"
	else
		fix = "40 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Kondition", false, false )
	if vioClientGetElementData ( "stamina" ) ~= "none" then
		fix = " [x]"
	else
		fix = "25 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], "Kampfstile", true, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Boxen", false, false )
	if vioClientGetElementData ( "boxen" ) ~= "none" then
		fix = " [x]"
	else
		fix = "25 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Kung-Fu", false, false )
	if vioClientGetElementData ( "kungfu" ) ~= "none" then
		fix = " [x]"
	else
		fix = "35 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Streetfighting", false, false )
	if vioClientGetElementData ( "streetfighting" ) ~= "none" then
		fix = " [x]"
	else
		fix = "40 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], "Waffenskills", true, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Pistole", false, false )
	if vioClientGetElementData ( "pistolskill" ) ~= "none" then
		fix = " [x]"
	else
		fix = "20 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Deagle", false, false )
	if vioClientGetElementData ( "deagleskill" ) ~= "none" then
		fix = " [x]"
	else
		fix = "30 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Sturmgewehr", false, false )
	if vioClientGetElementData ( "assaultskill" ) ~= "none" then
		fix = " [x]"
	else
		fix = "30 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Schrotflinten", false, false )
	if vioClientGetElementData ( "shotgunskill" ) ~= "none" then
		fix = " [x]"
	else
		fix = "20 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " MP5", false, false )
	if vioClientGetElementData ( "mp5skill" ) ~= "none" then
		fix = " [x]"
	else
		fix = "35 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Doppel SMG", false, false )
	if vioClientGetElementData ( "doubleSMG" ) then
		fix = " [x]"
	else
		fix = "50 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], "Fahrzeuge", true, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Fahrzeugslots", false, false )
	if vioClientGetElementData ( "carslotupgrade3" ) == 1 then
		fix = " [x]"
	elseif vioClientGetElementData ( "carslotupgrade2" ) == 1 then
		fix = " 75 P"
	elseif vioClientGetElementData ( "carslotupgrade" ) ~= "none" then
		fix = " 60 P"
	else
		fix = " 50 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Vortex", false, false )
	if vioClientGetElementData ( "vortex" ) ~= "none" then
		fix = " [x]"
	else
		fix = "30 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	-- New Boni --
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Skimmer", false, false )
	if vioClientGetElementData ( "skimmer" ) > 0 then
		fix = " [x]"
	else
		fix = "50 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Caddy", false, false )
	if vioClientGetElementData ( "golfcart" ) then
		fix = " [x]"
	else
		fix = "25 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Leichenwagen", false, false )
	if vioClientGetElementData ( "romero" ) > 0 then
		fix = " [x]"
	else
		fix = "50 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Quad", false, false )
	if vioClientGetElementData ( "quad" ) ~= "none" then
		fix = " [x]"
	else
		fix = "30 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], "Skins", true, false )
	
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Cluckin Bell", false, false )
	if vioClientGetElementData ( "bonusskin1" ) ~= "none" then
		fix = " [x]"
	else
		fix = "25 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], "Items", true, false )
	
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Notebook", false, false )
	if vioClientGetElementData ( "fruitNotebook" ) >= 1 then
		fix = " [x]"
	else
		fix = "25 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )
	
	local row = dgsGridListAddRow(gGrid["bonusliste"])
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusName"], " Fernglas", false, false )
	if vioClientGetElementData ( "fglass" ) then
		fix = " [x]"
	else
		fix = "10 P"
	end
	dgsGridListSetItemText ( gGrid["bonusliste"], row, gColumn["bonusKosten"], fix, false, false )	
end