--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Importiert alle dgsCreate*/dgsSet*/...-Funktionen der externen DGS-
-- Ressource als globale Funktionen, falls sie in dieser Ressource noch
-- nicht global verfuegbar sind (defensiv, siehe vio_gui_client.lua).
if not dgsCreateWindow then
	local dgsOk, dgsErr = pcall(function()
		loadstring(exports.DGS:dgsImportFunction())()
	end)
	if not dgsOk then
		outputDebugString("[ICE] Konnte DGS nicht importieren - ist die Ressource 'DGS' gestartet? Fehler: "..tostring(dgsErr), 1)
	end
end

function gangGewaehlterEintrag ( grid, column )
	if not isElement ( grid ) then
		return nil
	end
	local row = dgsGridListGetSelectedItem ( grid )
	if not row or row < 0 then
		return nil
	end
	local text = dgsGridListGetItemText ( grid, row, column )
	if type ( text ) ~= "string" or text == "" then
		return nil
	end
	return text
end

function gangFensterSchliessen ()
	if isElement ( gWindow["gangMenue"] ) then
		destroyElement ( gWindow["gangMenue"] )
	end
	gWindow["gangMenue"] = nil
	setElementClicked ( false )
	showCursor ( false )
	guiSetInputEnabled ( true )
end

function showGangWindow_func ( msg, gangVehicleCost, money, mats, drugs, memberCount, memberString, gangname, rank1, rank2, rank3 )

	if isElement ( gWindow["gangMenue"] ) then
		destroyElement ( gWindow["gangMenue"] )
	end

	money = formNumberToMoneyString ( money )
	gWindow["gangMenue"] = dgsCreateWindow(screenwidth/2-384/2,screenheight/2-587/2,384,587,"Gangmenue",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255))
	dgsBringToFront ( gWindow["gangMenue"] )
	dgsSetProperty ( gWindow["gangMenue"], "image", false )
	dgsWindowSetCloseButtonEnabled ( gWindow["gangMenue"], false )
	dgsWindowSetMovable ( gWindow["gangMenue"], false )
	dgsWindowSetSizable ( gWindow["gangMenue"], false )

	showCursor ( true )
	setElementClicked ( true )

	gTabPanel["gangMenue"] = dgsCreateTabPanel(10,24,365,499,false,gWindow["gangMenue"])
	gTab["home"] = dgsCreateTab("Home",gTabPanel["gangMenue"])
	gMemo[1] = dgsCreateMemo(7,22,350,118,msg,false,gTab["home"])
	dgsMemoSetReadOnly(gMemo[1],true)
	gLabel[1] = dgsCreateLabel(159,4,60,15,"Pinnwand",false,gTab["home"], tocolor(0,200,0,255))
	dgsLabelSetVerticalAlign(gLabel[1],"top")
	dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
	dgsSetFont(gLabel[1],"default-bold")
	gButton["gangEquip"] = dgsCreateButton(7,152,82,41,"Ausruesten",false,gTab["home"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gLabel[2] = dgsCreateLabel(103,153,45,17,"Kosten:",false,gTab["home"], tocolor(200,0,0,255))
	dgsLabelSetVerticalAlign(gLabel[2],"top")
	dgsLabelSetHorizontalAlign(gLabel[2],"left",false)
	dgsSetFont(gLabel[2],"default-bold")
	gLabel[3] = dgsCreateLabel(114,169,33,17,costsToArm..""..Tables.waehrung.."",false,gTab["home"], tocolor(0,200,0,255))
	dgsLabelSetVerticalAlign(gLabel[3],"top")
	dgsLabelSetHorizontalAlign(gLabel[3],"left",false)
	dgsSetFont(gLabel[3],"default-bold")
	gButton["gangBuyCar"] = dgsCreateButton(165,151,82,41,"Fahrzeug\nkaufen",false,gTab["home"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetEnabled(gButton["gangBuyCar"],false)
	gLabel[4] = dgsCreateLabel(262,151,45,17,"Kosten:",false,gTab["home"], tocolor(200,0,0,255))
	dgsLabelSetVerticalAlign(gLabel[4],"top")
	dgsLabelSetHorizontalAlign(gLabel[4],"left",false)
	dgsSetFont(gLabel[4],"default-bold")
	gLabel[5] = dgsCreateLabel(274,169,61,17,"n. verfuegbar",false,gTab["home"], tocolor(0,200,0,255))
	dgsLabelSetVerticalAlign(gLabel[5],"top")
	dgsLabelSetHorizontalAlign(gLabel[5],"left",false)
	dgsSetFont(gLabel[5],"default-bold")
	gButton["gangGunBox"] = dgsCreateButton(7,209,82,41,"Waffenbox\noeffnen",false,gTab["home"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gButton["gangSkin"] = dgsCreateButton(165,209,82,41,"Gangskin\nannehmen",false,gTab["home"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gButton["gangEating"] = dgsCreateButton(250,209,82,41,"Heilen",false,gTab["home"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gNumberField["gangAmount"] = dgsCreateEdit(9,291,54,35,"0",false,gTab["home"])
	addEventHandler ( "onDgsChanged", gNumberField["gangAmount"],
		function ()
			local text = dgsGetText ( gNumberField["gangAmount"] )
			local filtered = text:gsub ( "[^%d]", "" )
			if filtered ~= text then
				dgsSetText ( gNumberField["gangAmount"], filtered )
			end
		end,
	false )
	gRadio["gangMoney"] = dgsCreateRadioButton(72,272,66,23,"Geld",false,gTab["home"])
	gRadio["gangMats"] = dgsCreateRadioButton(72,293,66,23,"Materials",false,gTab["home"])
	gRadio["gangDrugs"] = dgsCreateRadioButton(72,314,66,23,"Drogen",false,gTab["home"])
	dgsRadioButtonSetSelected(gRadio["gangDrugs"],true)
	gButton["gangTake"] = dgsCreateButton(150,272,72,32,"Nehmen",false,gTab["home"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gButton["gangStore"] = dgsCreateButton(150,308,72,32,"Lagern",false,gTab["home"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gLabel[6] = dgsCreateLabel(226,277,133,59,"Aktuell:\n"..money.."\n"..mats.." Materialien\n"..drugs.." Gramm Drogen",false,gTab["home"], tocolor(255,255,255,255))
	dgsLabelSetVerticalAlign(gLabel[6],"top")
	dgsLabelSetHorizontalAlign(gLabel[6],"left",false)
	dgsSetFont(gLabel[6],"default-bold")
	gTab["members"] = dgsCreateTab("Mitglieder",gTabPanel["gangMenue"])

	gGrid["members"] = dgsCreateGridList(5,9,190,118,false,gTab["members"])
	dgsGridListSetSelectionMode(gGrid["members"],0)
	gColumn["members"] = dgsGridListAddColumn(gGrid["members"],"Mitglied",0.6)
	gColumn["rang"] = dgsGridListAddColumn(gGrid["members"],"Rang",0.2)

	for i = 1, memberCount do
		local eintrag = gettok ( memberString, i, string.byte ( ';' ) )
		if not eintrag then break end
		eintrag = eintrag.."|"
		local a = gettok ( eintrag, 1, string.byte ( '|' ) )
		local b = gettok ( eintrag, 2, string.byte ( '|' ) )
		if not a then break end
		local row = dgsGridListAddRow ( gGrid["members"] )
		dgsGridListSetItemText ( gGrid["members"], row, gColumn["members"], a, false, false )
		dgsGridListSetItemText ( gGrid["members"], row, gColumn["rang"], b, false, false )
		if getPlayerFromName ( a ) then
			dgsGridListSetItemColor ( gGrid["members"], row, gColumn["members"], 0, 150, 0 )
			dgsGridListSetItemColor ( gGrid["members"], row, gColumn["rang"], 0, 150, 0 )
		else
			dgsGridListSetItemColor ( gGrid["members"], row, gColumn["members"], 150, 0, 0 )
			dgsGridListSetItemColor ( gGrid["members"], row, gColumn["rang"], 150, 0, 0 )
		end
	end

	gEdit["gRankToSet"] = dgsCreateEdit ( 201, 11, 28, 35, "1", false, gTab["members"] )
	addEventHandler ( "onDgsChanged", gEdit["gRankToSet"],
		function ()
			local text = dgsGetText ( gEdit["gRankToSet"] )
			local filtered = text:gsub ( "[^%d]", "" )
			if filtered ~= text then
				dgsSetText ( gEdit["gRankToSet"], filtered )
			end
		end,
	false )
	gButton["gSetRank"] = dgsCreateButton(258,10,61,37,"Als Rang setzen",false,gTab["members"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gGrid["playersOnline"] = dgsCreateGridList(5,132,191,110,false,gTab["members"])
	dgsGridListSetSelectionMode(gGrid["playersOnline"],0)
	gColumn["pname"] = dgsGridListAddColumn(gGrid["playersOnline"],"Spieler",0.8)

	local players = getElementsByType ( "player" )
	for i=1, #players do
		local row = dgsGridListAddRow ( gGrid["playersOnline"] )
		dgsGridListSetItemText ( gGrid["playersOnline"], row, gColumn["pname"], getPlayerName ( players[i] ), false, false )
	end

	gButton["gUninvite"] = dgsCreateButton(258,58,61,37,"Uninviten",false,gTab["members"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gButton["gInvite"] = dgsCreateButton(258,161,61,37,"Inviten",false,gTab["members"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gEdit["gangYChatMSG"] = dgsCreateEdit(6,287,354,43,"",false,gTab["members"])
	gButton["sendGangMSG"] = dgsCreateButton(89,335,206,47,"An Fraktionsmitglieder senden\n( Kurztaste \"Y\" )",false,gTab["members"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(gButton["sendGangMSG"],"default-bold")

	gTab[3] = dgsCreateTab("Rechte",gTabPanel["gangMenue"])
	gLabel[7] = dgsCreateLabel(3,7,360,19,"Hier kannst du die einzelnen Rechte fuer die Gang zuweisen.",false,gTab[3], tocolor(255,255,255,255))
	dgsLabelSetVerticalAlign(gLabel[7],"top")
	dgsLabelSetHorizontalAlign(gLabel[7],"left",false)
	dgsSetFont(gLabel[7],"default-bold")
	gCheck["gangDeleteSure"] = dgsCreateCheckBox(14,102,71,21,"Sicher?",false,false,gTab[3])
	dgsSetFont(gCheck["gangDeleteSure"],"default-bold")
	gButton["deleteGang"] = dgsCreateButton(6,56,83,42,"Gang aufloesen",false,gTab[3], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gLabel[8] = dgsCreateLabel(95,58,108,64,"ACHTUNG:\nKann NICHT\nRueckgaengig\ngemacht werden!",false,gTab[3], tocolor(200,0,0,255))
	dgsLabelSetVerticalAlign(gLabel[8],"top")
	dgsLabelSetHorizontalAlign(gLabel[8],"left",false)
	dgsSetFont(gLabel[8],"default-bold")
	gTab[4] = dgsCreateTab("Einstellungen",gTabPanel["gangMenue"])
	gEdit["newGangName"] = dgsCreateEdit(6,22,114,33,gangname,false,gTab[4])
	gLabel[10] = dgsCreateLabel(25,5,77,14,"Gangname",false,gTab[4], tocolor(255,255,255,255))
	dgsLabelSetVerticalAlign(gLabel[10],"top")
	dgsLabelSetHorizontalAlign(gLabel[10],"left",false)
	dgsSetFont(gLabel[10],"default-bold")
	gLabel[11] = dgsCreateLabel(132,10,226,49,"Der Name deiner Gang -\nACHTUNG: Unpassende Namen koennen\nzur Loeschung der Gang fuehren!",false,gTab[4], tocolor(255,255,255,255))
	dgsLabelSetVerticalAlign(gLabel[11],"top")
	dgsLabelSetHorizontalAlign(gLabel[11],"left",false)
	dgsSetFont(gLabel[11],"default-bold")
	gNumberfield["gangCarSlot"] = dgsCreateEdit ( 6,125,37,33,"0",false,gTab[4])
	dgsSetEnabled(gNumberfield["gangCarSlot"],false)
	gLabel[12] = dgsCreateLabel(6,108,82,15,"Fahrzeugsslot",false,gTab[4], tocolor(255,255,255,255))
	dgsLabelSetVerticalAlign(gLabel[12],"top")
	dgsLabelSetHorizontalAlign(gLabel[12],"left",false)
	dgsSetFont(gLabel[12],"default-bold")
	gLabel[13] = dgsCreateLabel(54,127,307,28,"Das hier eingetragene Fahrzeug kann von allen Gang-\nmitgliedern gekauft werden.",false,gTab[4], tocolor(255,255,255,255))
	dgsLabelSetVerticalAlign(gLabel[13],"top")
	dgsLabelSetHorizontalAlign(gLabel[13],"left",false)
	dgsSetFont(gLabel[13],"default-bold")
	gButton["setSkin"] = dgsCreateButton(6,425,118,39,"Eigenen Skin als Gang-Skin festlegen",false,gTab[4], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gButton[13] = dgsCreateButton(124,159,123,35,"Fraktionsfahrzeug aendern",false,gTab[4], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetEnabled(gButton[13],false)
	gButton["changeName"] = dgsCreateButton(114,58,123,35,"Gangname aendern",false,gTab[4], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gMemo["gangPinnboard"] = dgsCreateMemo(7,224,350/2,118,"",false,gTab[4])
	gLabel[14] = dgsCreateLabel(149/2,209,59,16,"Pinnwand",false,gTab[4], tocolor(255,255,255,255))
	dgsLabelSetVerticalAlign(gLabel[14],"top")
	dgsLabelSetHorizontalAlign(gLabel[14],"left",false)
	dgsSetFont(gLabel[14],"default-bold")
	gButton["changePinboard"] = dgsCreateButton(7,350,115,38,"Pinnwandtext aendern",false,gTab[4], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gGrid["gangWeapons"] = dgsCreateGridList(125,350,125,112,false,gTab[4])
	dgsGridListSetSelectionMode(gGrid["gangWeapons"],1)
	gColumn["gun"] = dgsGridListAddColumn(gGrid["gangWeapons"],"Waffe",0.8)

	gangWeaponRowIDs = {}
	for key, index in pairs ( validWeaponsForGang ) do
		local row = dgsGridListAddRow ( gGrid["gangWeapons"] )
		gangWeaponRowIDs[row] = key
		dgsGridListSetItemText ( gGrid["gangWeapons"], row, gColumn["gun"], weaponNames[key], false, false )
	end

	gButton["changeGangWeapon"] = dgsCreateButton(7,391,115,33,"Waffe aendern",false,gTab[4], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

	gMemo["rank1"] = dgsCreateMemo(227,350-125,85,34,rank1,false,gTab[4])
	gMemo["rank2"] = dgsCreateMemo(227,389-125,85,34,rank2,false,gTab[4])
	gMemo["rank3"] = dgsCreateMemo(227,428-125,85,34,rank3,false,gTab[4])

	gLabel[15] = dgsCreateLabel(313,357-125,43,21,"Rang 1",false,gTab[4], tocolor(255,255,255,255))
	dgsLabelSetVerticalAlign(gLabel[15],"top")
	dgsLabelSetHorizontalAlign(gLabel[15],"left",false)
	gLabel[16] = dgsCreateLabel(314,436-125,43,21,"Rang 3",false,gTab[4], tocolor(255,255,255,255))
	dgsLabelSetVerticalAlign(gLabel[16],"top")
	dgsLabelSetHorizontalAlign(gLabel[16],"left",false)
	gLabel[17] = dgsCreateLabel(313,394-125,43,21,"Rang 2",false,gTab[4], tocolor(255,255,255,255))
	dgsLabelSetVerticalAlign(gLabel[17],"top")
	dgsLabelSetHorizontalAlign(gLabel[17],"left",false)
	gButton["changeRanks"] = dgsCreateButton(250,391,90,33,"Rangnamen aendern",false,gTab[4], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gButton["closeGangWindow"] = dgsCreateButton(125,533,115,37,"Menue schliessen",false,gWindow["gangMenue"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	addEventHandler ( "onDgsMouseClickUp", gButton["closeGangWindow"],
		function (btn)
			if btn ~= "left" then return end
			gangFensterSchliessen ()
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["gSetRank"],
		function (btn)
			if btn ~= "left" then return end
			local rank = tonumber ( dgsGetText ( gEdit["gRankToSet"] ) )
			if not rank or rank < 1 or rank > 3 then
				outputChatBox ( "Ungueltiger Rang!", 125, 0, 0 )
				return
			end
			local name = gangGewaehlterEintrag ( gGrid["members"], gColumn["members"] )
			if not name then
				outputChatBox ( "Waehle zuerst ein Mitglied aus!", 125, 0, 0 )
				return
			end
			triggerServerEvent ( "gangLeaderChangeRecieve", lp, "giveRank", name, rank )
			reopenGangGUI ()
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["gangEating"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "gangEatServer", lp )
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["deleteGang"],
		function (btn)
			if btn ~= "left" then return end
			if dgsCheckBoxGetSelected ( gCheck["gangDeleteSure"] ) then
				triggerServerEvent ( "gangLeaderChangeRecieve", lp, "deleteGang" )
				gangFensterSchliessen ()
			else
				outputChatBox ( "Setze zuerst den Haken bei \"Sicher?\".", 125, 0, 0 )
			end
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["changeName"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "gangLeaderChangeRecieve", lp, "renameGang", dgsGetText ( gEdit["newGangName"] ) )
			reopenGangGUI ()
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["gUninvite"],
		function (btn)
			if btn ~= "left" then return end
			local name = gangGewaehlterEintrag ( gGrid["members"], gColumn["members"] )
			if not name then
				outputChatBox ( "Waehle zuerst ein Mitglied aus!", 125, 0, 0 )
				return
			end
			triggerServerEvent ( "gangLeaderChangeRecieve", lp, "uninvite", name )
			reopenGangGUI ()
		end,
	false )
	addEventHandler ( "onDgsMouseClickUp", gButton["gInvite"],
		function (btn)
			if btn ~= "left" then return end
			local name = gangGewaehlterEintrag ( gGrid["playersOnline"], gColumn["pname"] )
			if not name then
				outputChatBox ( "Waehle zuerst einen Spieler aus!", 125, 0, 0 )
				return
			end
			triggerServerEvent ( "gangLeaderChangeRecieve", lp, "invite", name )
			reopenGangGUI ()
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["changePinboard"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "gangLeaderChangeRecieve", lp, "pinboard", dgsGetText ( gMemo["gangPinnboard"] ) )
			reopenGangGUI ()
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["gangSkin"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "gangLeaderChangeRecieve", lp, "useSkin" )
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["setSkin"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "gangLeaderChangeRecieve", lp, "setSkin" )
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["gangEquip"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "gangLeaderChangeRecieve", lp, "equip" )
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["gangGunBox"],
		function (btn)
			if btn ~= "left" then return end
			_createGunboxMenue ()
			guiSetInputEnabled ( true )
			if isElement ( gWindow["gangMenue"] ) then
				destroyElement ( gWindow["gangMenue"] )
			end
			gWindow["gangMenue"] = nil
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["gangBuyCar"],
		function (btn)
			if btn ~= "left" then return end
			gangFensterSchliessen ()
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["gangTake"],
		function (btn)
			if btn ~= "left" then return end
			gangTakeStore ( "take" )
		end,
	false )
	addEventHandler ( "onDgsMouseClickUp", gButton["gangStore"],
		function (btn)
			if btn ~= "left" then return end
			gangTakeStore ( "store" )
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["changeRanks"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "gangLeaderChangeRecieve", lp, "renameRanks", dgsGetText ( gMemo["rank1"] ), dgsGetText ( gMemo["rank2"] ), dgsGetText ( gMemo["rank3"] ) )
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["sendGangMSG"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "gangLeaderChangeRecieve", lp, "sendMSGToGang", dgsGetText ( gEdit["gangYChatMSG"] ) )
			dgsSetText ( gEdit["gangYChatMSG"], "" )
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton["changeGangWeapon"],
		function (btn)
			if btn ~= "left" then return end
			local row = dgsGridListGetSelectedItem ( gGrid["gangWeapons"] )
			if not row or row < 0 or not gangWeaponRowIDs[row] then
				outputChatBox ( "Waehle zuerst eine Waffe aus!", 125, 0, 0 )
				return
			end
			triggerServerEvent ( "gangLeaderChangeRecieve", lp, "changeGangWeapon", gangWeaponRowIDs[row] )
		end,
	false )

	guiSetInputEnabled ( false )
end
addEvent ( "showGangWindow", true )
addEventHandler ( "showGangWindow", getRootElement(), showGangWindow_func )

function gangTakeStore ( cmd )

	local fix = ""
	if dgsRadioButtonGetSelected ( gRadio["gangMoney"] ) then
		fix = "money"
	elseif dgsRadioButtonGetSelected ( gRadio["gangMats"] ) then
		fix = "mats"
	elseif dgsRadioButtonGetSelected ( gRadio["gangDrugs"] ) then
		fix = "drugs"
	else
		return nil
	end
	triggerServerEvent ( "gangLeaderChangeRecieve", lp, cmd, fix, tonumber ( dgsGetText ( gNumberField["gangAmount"] ) ) )
	reopenGangGUI ()
end

function reopenGangGUI ()

	gangFensterSchliessen ()
	triggerServerEvent ( "showGangGUIAgain", lp )
end