--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

loadstring(exports.DGS:dgsImportFunction())()

local isshown = false

-- Nach einem Resource-Neustart (oder wenn ein Fenster zerstoert wurde) bleibt
-- der Eintrag in gWindow bestehen, zeigt aber auf ein totes Element. Jedes
-- dgsSetVisible darauf wirft "failed to call 'DGS:dgsSetVisible'" und bricht
-- den kompletten Button-Handler ab. Deshalb ueberall ueber diese Helfer gehen.
local function windowValid ( key )
	return gWindow[key] ~= nil and isElement ( gWindow[key] )
end

local function hideWindow ( key )
	if windowValid ( key ) then
		dgsSetVisible ( gWindow[key], false )
	else
		gWindow[key] = nil
	end
end

function hideAllSecPlayerClickWindows ()
	hideWindow ( "itemsGive" )
	hideWindow ( "waffendealer" )
	hideWindow ( "drogenverkauf" )
	hideWindow ( "sellHotdog" )
	hideWindow ( "playerInteraktionShow" )
	hideWindow ( "stateInteraction" )
end

function hideAllPlayerClickWindows ( btn )

	if btn ~= nil and btn ~= "left" then return end
	hideAllSecPlayerClickWindows ()
	hideWindow ( "playerInteraktion" )
	triggerServerEvent ( "cancel_gui_server", lp )
	dgsSetInputMode ( "allow_binds" )
	showCursor ( false )
end

-- Von items_geben_click.lua mitbenutzt, damit auch dort die tote Referenz
-- erkannt und das Fenster sauber neu gebaut wird.
function isPlayerClickWindowValid ( key )
	return windowValid ( key )
end

function showJobMenues(button)
	if button == "left" then
		local job = vioClientGetElementData ( "job" )
		if job == "wdealer" then
			hideAllSecPlayerClickWindows ()
			wDealerWindow()
		elseif job == "dealer" then
			hideAllSecPlayerClickWindows ()
			showDrugMenue()
		elseif job == "hotdog" then
			hideAllSecPlayerClickWindows ()
			giveHotDogGui()
		else
			outputChatBox ( "Du hast einen ungueltigen Beruf!", 125, 0, 0 )
		end
	end
end

function showZeigenMenue ( btn )

	if btn ~= nil and btn ~= "left" then return end
	hideAllSecPlayerClickWindows ()
	if windowValid ( "playerInteraktionShow" ) then
		dgsSetVisible ( gWindow["playerInteraktionShow"], true )
		dgsBringToFront ( gWindow["playerInteraktionShow"] )
	else
		gWindow["playerInteraktionShow"] = dgsCreateWindow(screenwidth/2-190/2,215,190,90,"Zeigen",false)
		dgsWindowSetSizable ( gWindow["playerInteraktionShow"], false )
		dgsWindowSetMovable ( gWindow["playerInteraktionShow"], false )
		dgsBringToFront ( gWindow["playerInteraktionShow"] )

		gButton["playerInteractionShowLicenses"] = dgsCreateButton(8,8,85,40,"Scheine",false,gWindow["playerInteraktionShow"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["playerInteractionShowGWD"] = dgsCreateButton(97,8,85,40,"GWD-Note",false,gWindow["playerInteraktionShow"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		addEventHandler ( "onDgsMouseClickUp", gButton["playerInteractionShowLicenses"],
			function ( btn, state )
				if btn ~= "left" then return end
				if state == "up" then
					triggerServerEvent ( "showLicenses", lp, lp )
				end
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["playerInteractionShowGWD"],
			function ( btn, state )
				if btn ~= "left" then return end
				if state == "up" then
					triggerServerEvent ( "showGWD", lp, lp )
				end
			end,
		false )
	end
end

function showFactionMenue ()
	if windowValid ( "stateInteraction" ) then
		dgsSetVisible ( gWindow["stateInteraction"], true )
		dgsBringToFront ( gWindow["stateInteraction"] )
	else
		gWindow["stateInteraction"] = dgsCreateWindow(screenwidth/2-200/2,215,200,190,"Staatsfraktion",false)
		dgsBringToFront ( gWindow["stateInteraction"] )

		gButton["stateInteractionCuff"] = dgsCreateButton(8,8,90,40,"Fesseln",false,gWindow["stateInteraction"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["stateInteractionTakeWeapons"] = dgsCreateButton(102,8,90,40,"Entwaffnen",false,gWindow["stateInteraction"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["stateInteractionTakeIllegal"] = dgsCreateButton(8,52,90,40,"Illegales\nAbnehmen",false,gWindow["stateInteraction"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["stateInteractionFrisk"] = dgsCreateButton(102,52,90,40,"Durchsuchen",false,gWindow["stateInteraction"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["stateInteractionDrugTest"] = dgsCreateButton(8,96,90,40,"Drogen / Alkohol\nTest",false,gWindow["stateInteraction"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["stateInteractionTakeGunlicense"] = dgsCreateButton(102,96,90,40,"Waffenschein\nabnehmen",false,gWindow["stateInteraction"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		addEventHandler ( "onDgsMouseClickUp", gButton["stateInteractionCuff"],
			function ( btn, state )
				if btn ~= "left" then return end
				if state == "up" then
					triggerServerEvent ( "cuffGUI", lp, lp, "cuff", vioClientGetElementData("curclicked") )
				end
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["stateInteractionTakeWeapons"],
			function ( btn, state )
				if btn ~= "left" then return end
				if state == "up" then
					triggerServerEvent ( "takeweapons", lp, lp, "takeweapons", vioClientGetElementData("curclicked") )
				end
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["stateInteractionFrisk"],
			function ( btn, state )
				if btn ~= "left" then return end
				if state == "up" then
					triggerServerEvent ( "friskGUI", lp, lp, "frisk", vioClientGetElementData("curclicked") )
				end
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["stateInteractionTakeIllegal"],
			function ( btn, state )
				if btn ~= "left" then return end
				if state == "up" then
					triggerServerEvent ( "takeillegalGUI", lp, lp, "takeillegal", vioClientGetElementData("curclicked") )
				end
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["stateInteractionDrugTest"],
			function ( btn, state )
				if btn ~= "left" then return end
				if state == "up" then
					triggerServerEvent ( "test", lp, lp, "test", vioClientGetElementData("curclicked") )
				end
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["stateInteractionTakeGunlicense"],
			function ( btn, state )
				if btn ~= "left" then return end
				if state == "up" then
					triggerServerEvent ( "takegunlicenseGUI", lp, vioClientGetElementData("curclicked") )
				end
			end,
		false )
	end
end

function ShowInteraktionsguiGui_func ()

	showCursor ( true )
	-- Waehrend in einem Eingabefeld der Klick-GUI getippt wird, duerfen die
	-- Tasten keine Binds ausloesen. Zurueckgesetzt in hideAllPlayerClickWindows ().
	dgsSetInputMode ( "no_binds_when_editing" )
	if windowValid ( "playerInteraktion" ) then
		dgsSetVisible ( gWindow["playerInteraktion"], true )
		dgsBringToFront ( gWindow["playerInteraktion"] )
	else
		gWindow["playerInteraktion"] = dgsCreateWindow(screenwidth/2-240/2,0,240,200,"Interaktion",false)
		-- Kein X: es raeumt nicht auf, dafuer gibt es "Schliessen".
		dgsWindowSetCloseButtonEnabled ( gWindow["playerInteraktion"], false )
		dgsBringToFront ( gWindow["playerInteraktion"] )

		gButton["playerInteraktionShow"] = dgsCreateButton(8,38,68,34,"Zeigen",false,gWindow["playerInteraktion"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["playerInteraktionGive"] = dgsCreateButton(86,38,68,34,"Geben",false,gWindow["playerInteraktion"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["playerInteraktionFriendlist"] = dgsCreateButton(164,38,68,34,"Zur\nFriendlist",false,gWindow["playerInteraktion"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["playerInteraktionJob"] = dgsCreateButton(8,78,68,34,"Job",false,gWindow["playerInteraktion"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["playerInteraktionFaction"] = dgsCreateButton(86,78,68,34,"Fraktion",false,gWindow["playerInteraktion"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["playerInteraktionClose"] = dgsCreateButton(164,78,68,34,"Schliessen",false,gWindow["playerInteraktion"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["playerInteraktionHeiraten"] = dgsCreateButton(8,118,224,34,"Heiraten",false,gWindow["playerInteraktion"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		gLabel["playerInteraktionInfo1"] = dgsCreateLabel(8,8,120,22,"Name des Spielers:",false,gWindow["playerInteraktion"])
		dgsLabelSetColor(gLabel["playerInteraktionInfo1"],200,200,000,255)
		dgsLabelSetVerticalAlign(gLabel["playerInteraktionInfo1"],"top")
		dgsLabelSetHorizontalAlign(gLabel["playerInteraktionInfo1"],"left",false)
		dgsSetFont(gLabel["playerInteraktionInfo1"],"default-bold")

		gLabel["playerInteraktionClickedPlayer"] = dgsCreateLabel(132,8,100,22,"",false,gWindow["playerInteraktion"])
		dgsLabelSetColor(gLabel["playerInteraktionClickedPlayer"],125,200,200,255)
		dgsLabelSetVerticalAlign(gLabel["playerInteraktionClickedPlayer"],"top")
		dgsLabelSetHorizontalAlign(gLabel["playerInteraktionClickedPlayer"],"left",false)
		dgsSetFont(gLabel["playerInteraktionClickedPlayer"],"default-bold")

		addEventHandler ( "onDgsMouseClickUp", gButton["playerInteraktionClose"], hideAllPlayerClickWindows, false )
		addEventHandler ( "onDgsMouseClickUp", gButton["playerInteraktionShow"], showZeigenMenue, false )
		addEventHandler ( "onDgsMouseClickUp", gButton["playerInteraktionJob"], showJobMenues, false )
		addEventHandler ( "onDgsMouseClickUp", gButton["playerInteraktionFaction"],
			function ( btn, state )
				if btn ~= "left" then return end
				if getElementData ( lp, "fraktion" ) == 1 or getElementData ( lp, "fraktion" ) == 6 or getElementData ( lp, "fraktion" ) == 8 then
					showFactionMenue()
				else
					outputChatBox ( "Du bist in keiner gueltigen Fraktion!", 125, 0, 0 )
				end
			end,
		false )

		addEventHandler ( "onDgsMouseClickUp", gButton["playerInteraktionFriendlist"],
			function ( btn, state )
				if btn ~= "left" then return end
				if state == "up" then
					triggerServerEvent ( "addFriend", getRootElement(), lp, vioClientGetElementData("curclicked") )
				end
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["playerInteraktionGive"],
			function ( btn, state )
				if btn ~= "left" then return end
				if state == "up" then
					hideAllSecPlayerClickWindows ()
					showItemGiveList()
				end
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["playerInteraktionHeiraten"],
			function ( btn, state )
				if btn ~= "left" then return end
				if state == "up" then
					hideAllSecPlayerClickWindows ()
					if getElementData ( localPlayer, "married" ) == 1 then
						if showEheVerwaltungFenster then
							showEheVerwaltungFenster ()
						end
					elseif showHeiratsantragFenster then
						showHeiratsantragFenster ( vioClientGetElementData ( "curclicked" ) )
					end
				end
			end,
		false )
	end
	if isElement ( gLabel["playerInteraktionClickedPlayer"] ) then
		dgsSetText ( gLabel["playerInteraktionClickedPlayer"], tostring ( vioClientGetElementData("curclicked") ) )
	end
end
addEvent ( "ShowInteraktionsguiGui", true )
addEventHandler ( "ShowInteraktionsguiGui", getRootElement(), ShowInteraktionsguiGui_func )