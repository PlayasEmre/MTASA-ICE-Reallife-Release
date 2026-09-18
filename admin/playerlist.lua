--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


respawnCMDs = { ["faggio"]="faggio",
 ["sfpd"]="sfpd",
 ["mafia"]="mafia",
 ["triaden"]="triaden",
 ["news"]="news",
 ["terror"]="terror",
 ["fbi"]="fbi",
 ["aztecas"]="aztecas",
 ["army"]="army",
 ["biker"]="biker",
 ["fishing"]="fishing",
 ["hotdog"]="hotdog"
}

function showAdminMenue ()

	showCursor ( true )
	if gWindow["plistadmin"] then
		dgsSetVisible ( gWindow["plistadmin"], true )
		dgsBringToFront ( gWindow["plistadmin"] )
	else
		gWindow["plistadmin"] = dgsCreateWindow(screenwidth/2-568/2,120,568,615,"Adminmenue",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true)
		dgsBringToFront ( gWindow["plistadmin"] )
		dgsSetProperty(gWindow["plistadmin"], "image", false)
		dgsWindowSetMovable ( gWindow["plistadmin"], true )
		dgsWindowSetSizable ( gWindow["plistadmin"], false )

		gButton["adminMenueClose"] = dgsCreateButton(568-33,6,24,19,"x",false,gWindow["plistadmin"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton["adminMenueClose"],
			function ( btn )
				if btn ~= "left" then return end
				dgsSetVisible ( gWindow["plistadmin"], false )
				showCursor ( false )
				guiSetInputMode ( "allow_binds" )
			end
		)

		gGrid["plistadmin"] = dgsCreateGridList(9,27,229,543,false,gWindow["plistadmin"])
		dgsGridListSetSelectionMode(gGrid["plistadmin"],1)
		gColumn["adminName"] = dgsGridListAddColumn(gGrid["plistadmin"],"Spieler",0.6)
		gColumn["adminPing"] = dgsGridListAddColumn(gGrid["plistadmin"],"Ping",0.2)

		addEventHandler ( "onDgsMouseClickUp", gGrid["plistadmin"], function ( btn, state, x, y )
			if btn ~= "left" then return end
			local gx, gy = dgsGetPosition ( gGrid["plistadmin"], false, true )
			local columnHeight = dgsGetProperty ( gGrid["plistadmin"], "columnHeight" ) or 0
			local rowHeight = dgsGetProperty ( gGrid["plistadmin"], "rowHeight" ) or 0
			local leading = dgsGetProperty ( gGrid["plistadmin"], "leading" ) or 0
			local rowMoveOffset = dgsGetProperty ( gGrid["plistadmin"], "rowMoveOffset" ) or 0
			local rowHeightLeading = rowHeight + leading
			if rowHeightLeading <= 0 then return end
			local relY = y - gy - columnHeight - rowMoveOffset
			if relY < 0 then return end
			local row = math.floor ( relY / rowHeightLeading ) + 1
			local rowCount = dgsGridListGetRowCount ( gGrid["plistadmin"] )
			if row < 1 or row > rowCount then return end
			dgsGridListSetSelectedItem ( gGrid["plistadmin"], row, gColumn["adminName"] )
		end, false )

		gTabPanel["adminMenue"] = dgsCreateTabPanel(241,29,318,541,false,gWindow["plistadmin"])

		gTab[1] = dgsCreateTab("Basis",gTabPanel["adminMenue"])
		gImage[1] = dgsCreateImage(5,7,76,43,":"..getResourceName(getThisResource()).."/images/colors/c_red.jpg",false,gTab[1])
		gLabel[1] = dgsCreateLabel(8,7,57,29,"Notfallab-\nschaltung",false,gImage[1])
		dgsLabelSetColor(gLabel[1],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[1],"top")
		dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
		dgsSetFont(gLabel[1],"default-bold")
		gCheck[1] = dgsCreateCheckBox(87,18,198,18,"Wirklich dauerhaft abschalten?",false,false,gTab[1])
		dgsSetFont(gCheck[1],"default-bold")
		addEventHandler ( "onDgsMouseClickUp", gImage[1],
			function (btn)
				if btn ~= "left" then return end
				if source == gImage[1] or source == gLabel[1] then
					if dgsCheckBoxGetSelected ( gCheck[1] ) then
						triggerServerEvent ( "executeAdminServerCMD", lp, "shut" )
					else
						outputChatBox ( "Bitte aktiviere das Kontrollkaestchen!", 125, 0, 0 )
					end
				end
			end
		)

		gGrid["respawnList"] = dgsCreateGridList(107,336,179,162,false,gTab[1])
		dgsGridListSetSelectionMode(gGrid["respawnList"],0)
		gColumn["respawnList"] = dgsGridListAddColumn(gGrid["respawnList"],"Spieler",0.8)

		for key, index in pairs ( respawnCMDs ) do
			local row = dgsGridListAddRow ( gGrid["respawnList"] )
			dgsGridListSetItemText ( gGrid["respawnList"], row, gColumn["respawnList"], key, false, false )
		end

		gButton["adminRespawn"] = dgsCreateButton(4,394,79,38,"Respawnen",false,gTab[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton["adminRespawn"],
			function ( btn, state )
				if btn ~= "left" then return end
				if state == "up" then

					if dgsGetText( gEdit[15] ) ~= "" then

						triggerServerEvent ( "executeAdminServerCMD", lp, "crespawn", tonumber(dgsGetText( gEdit[15] )) )

					else

						row, column = dgsGridListGetSelectedItem(gGrid["respawnList"])
						if row == -1 then return end
						veh = dgsGridListGetItemText ( gGrid["respawnList"], row, column )
						triggerServerEvent ( "executeAdminServerCMD", lp, "respawn", veh )

					end

				end
			end,
		false)

		gButton[1] = dgsCreateButton(4,62,79,38,"Kick",false,gTab[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[1],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "rkick", player.." "..dgsGetText ( gMemo[1] ) )
			end,
		false )
		gButton[2] = dgsCreateButton(5,106,79,38,"Ban",false,gTab[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[2],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "rban", player.." "..dgsGetText ( gMemo[1] ) )
			end,
		false )
		gButton[3] = dgsCreateButton(5,149,79,38,"Warn",false,gTab[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[3],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])

				-- Ohne Auswahl liefert DGS -1, und -1 ist in Lua wahr.
				if not row or row < 0 then
					player = dgsGetText ( gEdit[2] )
				else
					player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				end
				triggerServerEvent ( "warn", lp, player, dgsGetText ( gEdit[1] ), dgsGetText ( gMemo[1] ) )
			end,
		false )
		gButton[4] = dgsCreateButton(6,193,79,38,"Timeban",false,gTab[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[4],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "tban", player.." "..dgsGetText ( gEdit[1] ).." "..dgsGetText ( gMemo[1] ) )
			end,
		false )
		gMemo[1] = dgsCreateMemo(92,78,212,110,"",false,gTab[1])
		gLabel[2] = dgsCreateLabel(119,61,39,17,"Grund:",false,gTab[1])
		dgsLabelSetColor(gLabel[2],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[2],"top")
		dgsLabelSetHorizontalAlign(gLabel[2],"left",false)
		dgsSetFont(gLabel[2],"default-bold")
		gEdit[1] = dgsCreateEdit(174,192,86,41,"",false,gTab[1])
		gLabel[3] = dgsCreateLabel(141,204,29,16,"Zeit:",false,gTab[1])
		dgsLabelSetColor(gLabel[3],200,00,0)
		dgsLabelSetVerticalAlign(gLabel[3],"top")
		dgsLabelSetHorizontalAlign(gLabel[3],"left",false)
		dgsSetFont(gLabel[3],"default-bold")
		gLabel[4] = dgsCreateLabel(264,202-15,48,55,"Stunden\n(TBan)\nTage\n(Warn)",false,gTab[1])
		dgsLabelSetColor(gLabel[4],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[4],"top")
		dgsLabelSetHorizontalAlign(gLabel[4],"left",false)
		dgsSetFont(gLabel[4],"default-bold")
		gButton[5] = dgsCreateButton(6,236,79,38,"Entbannen",false,gTab[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[5],
			function (btn)
				if btn ~= "left" then return end
				triggerServerEvent ( "executeAdminServerCMD", lp, "unban", dgsGetText ( gEdit[2] ) )
			end,
		false )
		gButton["playerToCheckWarns"] = dgsCreateButton(6,236+15+34,79,38,"Warns\nPrüfen",false,gTab[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton["playerToCheckWarns"],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])

				if not row or row < 0 then
					player = dgsGetText ( gEdit[2] )
				else
					player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				end
				triggerServerEvent ( "checkwarns", lp, player )
			end,
		false )
		gButton["playerToCheckIP"] = dgsCreateButton(6,236+15*2+34*2,79,38,"IP\nPrüfen",false,gTab[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton["playerToCheckIP"],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])

				if not row or row < 0 then
					player = dgsGetText ( gEdit[2] )
				else
					player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				end
				triggerServerEvent ( "getip", lp, lp, "getip", player )
			end,
		false )
		gLabel[5] = dgsCreateLabel(92,244,104,29,"Spielername:",false,gTab[1])
		dgsLabelSetColor(gLabel[5],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[5],"top")
		dgsLabelSetHorizontalAlign(gLabel[5],"left",false)
		dgsSetFont(gLabel[5],"default-bold")
		gEdit[2] = dgsCreateEdit(175,238,92,34,"",false,gTab[1])
		gTab[2] = dgsCreateTab("Raeumlich",gTabPanel["adminMenue"])
		gButton[6] = dgsCreateButton(4,6,81,39,"Zum Spieler teleportieren",false,gTab[2], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[6],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "goto", player )
			end,
		false )
		gButton[7] = dgsCreateButton(4,52,81,39,"Spieler her teleportieren",false,gTab[2], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[7],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "gethere", player )
			end,
		false )

		gButton["move_left"] = dgsCreateButton(100,100,20,20,"*",false,gTab[2], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton["move_left"],
			function (btn)
				if btn ~= "left" then return end
				triggerServerEvent ( "move", lp, lp, "move", "left" )
			end,
		false )
		gButton["move_up"] = dgsCreateButton(120,80,20,20,"*",false,gTab[2], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton["move_up"],
			function (btn)
				if btn ~= "left" then return end
				triggerServerEvent ( "move", lp, lp, "move", "up" )
			end,
		false )
		gButton["move_right"] = dgsCreateButton(140,100,20,20,"*",false,gTab[2], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton["move_right"],
			function (btn)
				if btn ~= "left" then return end
				triggerServerEvent ( "move", lp, lp, "move", "right" )
			end,
		false )
		gButton["move_down"] = dgsCreateButton(120,120,20,20,"*",false,gTab[2], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton["move_down"],
			function (btn)
				if btn ~= "left" then return end
				triggerServerEvent ( "move", lp, lp, "move", "down" )
			end,
		false )
		gButton["move_higher"] = dgsCreateButton(100,80,20,20,"+",false,gTab[2], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton["move_higher"],
			function (btn)
				if btn ~= "left" then return end
				triggerServerEvent ( "move", lp, lp, "move", "higher" )
			end,
		false )
		gButton["move_lower"] = dgsCreateButton(140,80,20,20,"-",false,gTab[2], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton["move_lower"],
			function (btn)
				if btn ~= "left" then return end
				triggerServerEvent ( "move", lp, lp, "move", "lower" )
			end,
		false )


		gButton[8] = dgsCreateButton(5,97,81,39,"Markierung setzen",false,gTab[2], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[8],
			function (btn)
				if btn ~= "left" then return end
				triggerServerEvent ( "executeAdminServerCMD", lp, "mark" )
			end,
		false )
		gButton[9] = dgsCreateButton(6,143,81,39,"Zur Markierung gehen",false,gTab[2], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[9],
			function (btn)
				if btn ~= "left" then return end
				triggerServerEvent ( "executeAdminServerCMD", lp, "gotomark" )
			end,
		false )
		gButton[10] = dgsCreateButton(6,188,151,30,"Interior/Dimension setzen",false,gTab[2], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[10],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "intdim", player.." "..dgsGetText(gEdit[3]).." "..dgsGetText(gEdit[4]) )
			end,
		false )
		gEdit[3] = dgsCreateEdit(162,188,58,32,"",false,gTab[2])
		gEdit[4] = dgsCreateEdit(226,188,58,32,"",false,gTab[2])
		gLabel[6] = dgsCreateLabel(166,173,50,16,"Interior:",false,gTab[2])
		dgsLabelSetColor(gLabel[6],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[6],"top")
		dgsLabelSetHorizontalAlign(gLabel[6],"left",false)
		dgsSetFont(gLabel[6],"default-bold")
		gLabel[7] = dgsCreateLabel(224,173,64,15,"Dimension:",false,gTab[2])
		dgsLabelSetColor(gLabel[7],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[7],"top")
		dgsLabelSetHorizontalAlign(gLabel[7],"left",false)
		dgsSetFont(gLabel[7],"default-bold")
		gTab[3] = dgsCreateTab("Spieler",gTabPanel["adminMenue"])
		gButton[11] = dgsCreateButton(4,8,78,38,"Beobachten",false,gTab[3], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[11],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "spec", player )
			end,
		false )
		gButton[12] = dgsCreateButton(4,52,78,38,"Checken",false,gTab[3], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[12],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "check", player )
			end,
		false )
		gButton[13] = dgsCreateButton(5,96,78,38,"Freezen",false,gTab[3], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[13],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "freeze", player )
			end,
		false )
		gButton[14] = dgsCreateButton(6,141,78,38,"Slapen",false,gTab[3], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[14],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				if dgsCheckBoxGetSelected ( gCheck[2] ) then
					triggerServerEvent ( "executeAdminServerCMD", lp, "slap", player.." ja" )
				else
					triggerServerEvent ( "executeAdminServerCMD", lp, "slap", player )
				end
			end,
		false )
		gButton[15] = dgsCreateButton(7,186,78,38,"Skydiven",false,gTab[3], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[15],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "skydive", player )
			end,
		false )
		gButton[16] = dgsCreateButton(8,229,78,38,"Zum Leader machen",false,gTab[3], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[16],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "makeleader", player.." "..dgsGetText(gEdit[5]) )
			end,
		false )
		gButton[17] = dgsCreateButton(8,275,78,38,"Passwort aendern",false,gTab[3], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[17],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "pwchange", dgsGetText(gEdit[6]).." "..dgsGetText(gEdit[7]) )
			end,
		false )


		gButton["offlineban"] = dgsCreateButton(115,395,78,38,"Offlineban",false,gTab[3], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton["offlineban"],
			function (btn)
				if btn ~= "left" then return end
				triggerServerEvent ( "executeAdminServerCMD", lp, "ban", dgsGetText(gEdit[6]).." "..dgsGetText(gMemo["offlineReason"]) )
			end,
		false )

		gMemo["offlineReason"] = dgsCreateMemo(199,369,106,45,"",false,gTab[3])
		gLabel["offlineReason"] = dgsCreateLabel(228,349,45,16,"Grund:",false,gTab[3])
		dgsLabelSetColor(gLabel["offlineReason"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["offlineReason"],"top")
		dgsLabelSetHorizontalAlign(gLabel["offlineReason"],"left",false)
		dgsSetFont(gLabel["offlineReason"],"default-bold")

		gCheck[2] = dgsCreateCheckBox(86,151,92,21,"Anzuenden?",false,false,gTab[3])
		dgsSetFont(gCheck[2],"default-bold")
		gEdit[5] = dgsCreateEdit(149,234,31,31,"",false,gTab[3])
		gLabel[8] = dgsCreateLabel(91,240,53,20,"Fraktion:",false,gTab[3])
		dgsLabelSetColor(gLabel[8],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[8],"top")
		dgsLabelSetHorizontalAlign(gLabel[8],"left",false)
		dgsSetFont(gLabel[8],"default-bold")
		gEdit[6] = dgsCreateEdit(95,298,68,33,"",false,gTab[3])
		gLabel[9] = dgsCreateLabel(107,276,45,16,"Spieler:",false,gTab[3])
		dgsLabelSetColor(gLabel[9],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[9],"top")
		dgsLabelSetHorizontalAlign(gLabel[9],"left",false)
		dgsSetFont(gLabel[9],"default-bold")
		gEdit[7] = dgsCreateEdit(192,298,68,33,"",false,gTab[3])
		gLabel[10] = dgsCreateLabel(180,276,96,17,"Neues Passwort:",false,gTab[3])
		dgsLabelSetColor(gLabel[10],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[10],"top")
		dgsLabelSetHorizontalAlign(gLabel[10],"left",false)
		dgsSetFont(gLabel[10],"default-bold")
		gLabel[11] = dgsCreateLabel(12,352,94,138,"Fraktions-IDs:\n\n1 = SFPD\n2 = Mafia\n3 = Triaden\n4 = Terroristen\n5 = LTR\n6 = FBI\n7 = Los Aztecas\n8 = Army",false,gTab[3])
		dgsLabelSetColor(gLabel[11],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[11],"top")
		dgsLabelSetHorizontalAlign(gLabel[11],"left",false)
		dgsSetFont(gLabel[11],"default-bold")
		gTab[4] = dgsCreateTab("Rang 3/4",gTabPanel["adminMenue"])
		gButton[18] = dgsCreateButton(6,21,84,46,"Query ausfuehren",false,gTab[4], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		dgsSetFont(gButton[18],"default-bold")
		addEventHandler ( "onDgsMouseClickUp", gButton[18],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "query", dgsGetText(gMemo[2]) )
			end,
		false )
		gMemo[2] = dgsCreateMemo(93,9,217,77,"",false,gTab[4])
		gButton[19] = dgsCreateButton(5,104,87,48,"Restart",false,gTab[4], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[19],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "gmx", dgsGetText(gEdit[8]) )
			end,
		false )
		dgsSetFont(gButton[19],"default-bold")
		gEdit[8] = dgsCreateEdit(120,109,59,37,"",false,gTab[4])
		gLabel[12] = dgsCreateLabel(100,120,12,17,"in",false,gTab[4])
		dgsLabelSetColor(gLabel[12],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[12],"top")
		dgsLabelSetHorizontalAlign(gLabel[12],"left",false)
		dgsSetFont(gLabel[12],"default-bold")
		gLabel[13] = dgsCreateLabel(185,120,53,19,"Minuten",false,gTab[4])
		dgsLabelSetColor(gLabel[13],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[13],"top")
		dgsLabelSetHorizontalAlign(gLabel[13],"left",false)
		dgsSetFont(gLabel[13],"default-bold")
		gButton[20] = dgsCreateButton(6,169,87,48,"Haus anlegen",false,gTab[4], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[20],
			function (btn)
				if btn ~= "left" then return end
				local preis = dgsGetText(gEdit[9])
				local playtime = dgsGetText(gEdit[11])
				local int = dgsGetText(gEdit[10])
				triggerServerEvent ( "executeAdminServerCMD", lp, "newhouse", preis.." "..playtime.." "..int )
			end,
		false )
		dgsSetFont(gButton[20],"default-bold")
		gEdit[9] = dgsCreateEdit(99,185,72,32,"",false,gTab[4])
		gLabel[14] = dgsCreateLabel(103,165,60,18,"Preis:",false,gTab[4])
		dgsLabelSetColor(gLabel[14],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[14],"top")
		dgsLabelSetHorizontalAlign(gLabel[14],"left",false)
		dgsSetFont(gLabel[14],"default-bold")
		gEdit[10] = dgsCreateEdit(176,185,33,32,"",false,gTab[4])
		gLabel[15] = dgsCreateLabel(156,165,71,16,"Innenraum:",false,gTab[4])
		dgsLabelSetColor(gLabel[15],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[15],"top")
		dgsLabelSetHorizontalAlign(gLabel[15],"left",false)
		dgsSetFont(gLabel[15],"default-bold")
		gEdit[11] = dgsCreateEdit(215,185,77,32,"",false,gTab[4])
		gLabel[16] = dgsCreateLabel(227,153,59,31,"Mindest-\nSpielzeit:",false,gTab[4])
		dgsLabelSetColor(gLabel[16],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[16],"top")
		dgsLabelSetHorizontalAlign(gLabel[16],"left",false)
		dgsSetFont(gLabel[16],"default-bold")
		gButton[21] = dgsCreateButton(8,232,87,48,"Tuningteil-\nID*",false,gTab[4], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[21],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "tunecar", dgsGetText(gEdit[12]) )
			end,
		false )
		dgsSetFont(gButton[21],"default-bold")
		gEdit[12] = dgsCreateEdit(106,242,75,28,"",false,gTab[4])
		gLabel[17] = dgsCreateLabel(7,491,61,17,"*s.h. Wiki",false,gTab[4])
		dgsLabelSetColor(gLabel[17],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[17],"top")
		dgsLabelSetHorizontalAlign(gLabel[17],"left",false)
		dgsSetFont(gLabel[17],"default-bold")
		gButton[22] = dgsCreateButton(8,290,87,48,"Innenraum\nansehen",false,gTab[4], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[22],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "iraum", dgsGetText(gEdit[13]) )
			end,
		false )
		dgsSetFont(gButton[22],"default-bold")
		gEdit[13] = dgsCreateEdit(105,296,75,28,"",false,gTab[4])
		gTab[5] = dgsCreateTab("Chat",gTabPanel["adminMenue"])
		gMemo[3] = dgsCreateMemo(91,29,220,231,"",false,gTab[5])
		gLabel[18] = dgsCreateLabel(180,13,34,16,"Text:",false,gTab[5])
		dgsLabelSetColor(gLabel[18],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[18],"top")
		dgsLabelSetHorizontalAlign(gLabel[18],"left",false)
		dgsSetFont(gLabel[18],"default-bold")
		gButton[23] = dgsCreateButton(5,28,82,41,"O-Chat",false,gTab[5], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[23],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "o", dgsGetText(gMemo[3]) )
			end,
		false )
		gButton[24] = dgsCreateButton(4,75,82,41,"A-Chat",false,gTab[5], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[24],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "a", dgsGetText(gMemo[3]) )
			end,
		false )
		gButton[25] = dgsCreateButton(6,122,82,41,"Fluestern",false,gTab[5], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[25],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "w", dgsGetText(gEdit[14]).." "..dgsGetText(gMemo[3]) )
			end,
		false )
		gLabel[19] = dgsCreateLabel(7,166,43,20,"An ID:",false,gTab[5])
		dgsLabelSetColor(gLabel[19],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[19],"top")
		dgsLabelSetHorizontalAlign(gLabel[19],"left",false)
		dgsSetFont(gLabel[19],"default-bold")
		gButton[26] = dgsCreateButton(5,216,82,41,"PM",false,gTab[5], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[26],
			function (btn)
				if btn ~= "left" then return end
				row, column = dgsGridListGetSelectedItem(gGrid["plistadmin"])
				if row == -1 then return end
				player = dgsGridListGetItemText ( gGrid["plistadmin"], row, column )
				triggerServerEvent ( "executeAdminServerCMD", lp, "pm", player.." "..dgsGetText(gMemo[3]) )
			end,
		false )
		gEdit[14] = dgsCreateEdit(14,185,66,27,"",false,gTab[5])

		gButton[28] = dgsCreateButton(8,316,82,41,"Chat leeren",false,gTab[5], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton[28],
			function (btn)
				if btn ~= "left" then return end
				triggerServerEvent ( "executeAdminServerCMD", lp, "cleartext" )
			end,
		false )
	end
	dgsGridListClear ( gGrid["plistadmin"] )
	local players = getElementsByType("player")
	for i=1, #players do
		local row = dgsGridListAddRow ( gGrid["plistadmin"] )
		dgsGridListSetItemText ( gGrid["plistadmin"], row, gColumn["adminName"], getPlayerName ( players[i] ), false, false )
		dgsGridListSetItemText ( gGrid["plistadmin"], row, gColumn["adminPing"], "  "..tostring(getPlayerPing ( players[i] )), true, false )
	end

	-------------------------
	gLabel[20] = dgsCreateLabel(4,438,43,20,"Radius:",false,gTab[1])
	gEdit[15] = dgsCreateEdit(4,458,79,38,"",false,gTab[1])
	gButton[30] = dgsCreateButton(8,414,87,48,"Skin\nannehmen",false,gTab[4], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gButton[29] = dgsCreateButton(8,352,87,48,"Wetter-\nändern*",false,gTab[4], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gEdit[16] = dgsCreateEdit(105,420,75,28,"",false,gTab[4])

	addEventHandler ( "onDgsMouseClickUp", gButton[29],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "executeAdminServerCMD", lp, "aweather" )
		end,
	false )

	addEventHandler ( "onDgsMouseClickUp", gButton[30],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "executeAdminServerCMD", lp, "askin", tonumber(dgsGetText(gEdit[16])) )
		end,
	false )
	-------------------------
	gButton[31] = dgsCreateButton( 6, 230, 151, 30, "zum Wagen teleportieren", false, gTab[2], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255) )

	gEdit[17] = dgsCreateEdit( 162, 235, 58, 32, "", false, gTab[2] )

	gEdit[18] = dgsCreateEdit( 226, 235, 58, 32, "", false, gTab[2] )

	gLabel[21] = dgsCreateLabel( 166, 220, 50, 16, "Name:", false, gTab[2] )
	dgsLabelSetColor( gLabel[21], 255, 255, 255 )
	dgsLabelSetVerticalAlign( gLabel[21], "top" )
	dgsLabelSetHorizontalAlign( gLabel[21], "left", false )
	dgsSetFont( gLabel[21], "default-bold" )

	gLabel[22] = dgsCreateLabel( 224, 220, 64, 15, "Slot:", false, gTab[2] )
	dgsLabelSetColor( gLabel[22], 255, 255, 255 )
	dgsLabelSetVerticalAlign( gLabel[22], "top" )
	dgsLabelSetHorizontalAlign( gLabel[22], "left", false )
	dgsSetFont( gLabel[22], "default-bold" )

	addEventHandler ( "onDgsMouseClickUp", gButton[31],
		function (btn)
			if btn ~= "left" then return end

			local gotocarname = dgsGetText(gEdit[17])
			local gotocarslot = dgsGetText(gEdit[18])

			if gotocarname ~= "" and gotocarslot ~= "" then

				triggerServerEvent ( "executeAdminServerCMD", lp, "gotocar", gotocarname.." "..gotocarslot )

			else

				outputChatBox ( "Beide Felder muessen ausgefuellt sein!", 255, 0, 0 )

			end

		end, false )

end
