--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- DGS-Funktionen defensiv global verfuegbar machen, falls diese Datei vor
-- vio_gui_client.lua geladen wird bzw. eigenstaendig laeuft.
if not dgsCreateWindow then
	loadstring(exports.DGS:dgsImportFunction())()
end

gWindow = {}
gButton = {}
gLabel = {}

weaponNames = { [0]="Faust",
"Schlagring", "Golfschläger", "Schlagstock", "Messer", "Baseballschläger", "Schaufel", "Pool Cue", "Katana", "Kettensäge",
"Dildo", "Dildo", "Vibrator", "Existiert nicht", "Blumen", "Spazierstock", "Granaten", "Tränengas", "Molotov Cocktails", "Existiert nicht",
"Existiert nicht", "Existiert nicht",  "Pistole", "SD-Pistole", "Desert Eagle", "Schrotflinte", "Lupara", "SPAZ-12", "Uzi", "MP5",
"AK-47", "M4", "TEC-9", "Gewehr", "Sniper", "Raketenwerfer", "Jeveline", "Flammenwerfer", "Minigun", "Rucksackbombem",
"Satchel", "Spruehdose", "Feuerloescher", "Kamera", "Nachtsichtgeraet", "Infrarotgeraet", "Fallschirm" }

function _createGunboxMenue ()

	guiSetInputMode ( "no_binds_when_editing" )
	showCursor ( true )
	if gWindow["gunbox"] then
		dgsSetVisible ( gWindow["gunbox"], true )
		dgsBringToFront ( gWindow["gunbox"] )
	else
		local screenwidth, screenheight = guiGetScreenSize ()

		gWindow["gunbox"] = dgsCreateWindow(screenwidth/2-355/2, screenheight/2-163/2,355,163,"Waffenbox",false)
		dgsBringToFront ( gWindow["gunbox"] )
		dgsSetAlpha(gWindow["gunbox"],1)
		dgsWindowSetCloseButtonEnabled(gWindow["gunbox"], false)
		dgsWindowSetSizable(gWindow["gunbox"], false)
		dgsWindowSetMovable(gWindow["gunbox"], false)

		gLabel["gunOneText"] = dgsCreateLabel(0.0225,0.1472,0.3352,0.1534,"Waffe in Kammer 1:",true,gWindow["gunbox"])
		dgsSetAlpha(gLabel["gunOneText"],1)
		dgsLabelSetColor(gLabel["gunOneText"],200,200,000,255)
		dgsLabelSetVerticalAlign(gLabel["gunOneText"],"top")
		dgsLabelSetHorizontalAlign(gLabel["gunOneText"],"left",false)
		gLabel["gunTwoText"] = dgsCreateLabel(0.3465,0.1472,0.342,0.1185,"Waffe in Kammer 2:",true,gWindow["gunbox"])
		dgsSetAlpha(gLabel["gunTwoText"],1)
		dgsLabelSetColor(gLabel["gunTwoText"],200,200,000,255)
		dgsLabelSetVerticalAlign(gLabel["gunTwoText"],"top")
		dgsLabelSetHorizontalAlign(gLabel["gunTwoText"],"left",false)
		gLabel["gunThreeText"] = dgsCreateLabel(0.6648,0.1472,0.342,0.1185,"Waffe in Kammer 3:",true,gWindow["gunbox"])
		dgsSetAlpha(gLabel["gunThreeText"],1)
		dgsLabelSetColor(gLabel["gunThreeText"],200,200,000,255)
		dgsLabelSetVerticalAlign(gLabel["gunThreeText"],"top")
		dgsLabelSetHorizontalAlign(gLabel["gunThreeText"],"left",false)
		gLabel["Slot1Gun"] = dgsCreateLabel(0.0451,0.2577,0.2704,0.135,"-Keine-",true,gWindow["gunbox"])
		dgsSetAlpha(gLabel["Slot1Gun"],1)
		dgsLabelSetColor(gLabel["Slot1Gun"],150,180,255,255)
		dgsLabelSetVerticalAlign(gLabel["Slot1Gun"],"top")
		dgsLabelSetHorizontalAlign(gLabel["Slot1Gun"],"left",false)
		gLabel["Slot2Gun"] = dgsCreateLabel(0.3521,0.2577,0.254,0.1043,"-Keine-",true,gWindow["gunbox"])
		dgsSetAlpha(gLabel["Slot2Gun"],1)
		dgsLabelSetColor(gLabel["Slot2Gun"],150,180,255,255)
		dgsLabelSetVerticalAlign(gLabel["Slot2Gun"],"top")
		dgsLabelSetHorizontalAlign(gLabel["Slot2Gun"],"left",false)
		gLabel["Slot3Gun"] = dgsCreateLabel(0.6732,0.2577,0.254,0.1043,"-Keine-",true,gWindow["gunbox"])
		dgsSetAlpha(gLabel["Slot3Gun"],1)
		dgsLabelSetColor(gLabel["Slot3Gun"],150,180,255,255)
		dgsLabelSetVerticalAlign(gLabel["Slot3Gun"],"top")
		dgsLabelSetHorizontalAlign(gLabel["Slot3Gun"],"left",false)
		gButton["action1"] = dgsCreateButton(0.0451,0.5153,0.3042,0.1656,"Einlagern",true,gWindow["gunbox"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		dgsSetAlpha(gButton["action1"],1)
		gButton["action2"] = dgsCreateButton(0.3521,0.5153,0.3042,0.1656,"Einlagern",true,gWindow["gunbox"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		dgsSetAlpha(gButton["action2"],1)
		gButton["action3"] = dgsCreateButton(0.6732,0.5153,0.3042,0.1656,"Einlagern",true,gWindow["gunbox"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		dgsSetAlpha(gButton["action3"],1)
		gLabel["ammoSlot1"] = dgsCreateLabel(0.093,0.3558,0.2225,0.0982,"9 Schuss",true,gWindow["gunbox"])
		dgsSetAlpha(gLabel["ammoSlot1"],1)
		dgsLabelSetColor(gLabel["ammoSlot1"],125,200,120,255)
		dgsLabelSetVerticalAlign(gLabel["ammoSlot1"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammoSlot1"],"left",false)
		gLabel["ammoSlot2"] = dgsCreateLabel(0.4028,0.3558,0.209,0.0988,"9 Schuss",true,gWindow["gunbox"])
		dgsSetAlpha(gLabel["ammoSlot2"],1)
		dgsLabelSetColor(gLabel["ammoSlot2"],125,200,120,255)
		dgsLabelSetVerticalAlign(gLabel["ammoSlot2"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammoSlot2"],"left",false)
		gLabel["ammoSlot3"] = dgsCreateLabel(0.7099,0.3558,0.209,0.0988,"9 Schuss",true,gWindow["gunbox"])
		dgsSetAlpha(gLabel["ammoSlot3"],1)
		dgsLabelSetColor(gLabel["ammoSlot3"],125,200,120,255)
		dgsLabelSetVerticalAlign(gLabel["ammoSlot3"],"top")
		dgsLabelSetHorizontalAlign(gLabel["ammoSlot3"],"left",false)
		gButton["close"] = dgsCreateButton(0.907,0.7607,0.0704,0.1595,"X",true,gWindow["gunbox"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		dgsSetAlpha(gButton["close"],1)
		gLabel["infotext"] = dgsCreateLabel(0.0225,0.6994,0.8648,0.2515,"Hier kannst du deine Waffen lagern und zu einem\nspaeteren Zeitpunkt wieder mitnehmen.",true,gWindow["gunbox"])
		dgsSetAlpha(gLabel["infotext"],1)
		dgsLabelSetColor(gLabel["infotext"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["infotext"],"top")
		dgsLabelSetHorizontalAlign(gLabel["infotext"],"left",false)

		addEventHandler("onDgsMouseClickUp", gButton["action1"],
			function (btn)
				if btn ~= "left" then return end
				if source == gButton["action1"] then
					if dgsGetText ( gButton["action1"] ) == "Einlagern" then
						triggerServerEvent ( "exchangeWeaponsWithBox", localPlayer, localPlayer, 1, "in", getPedWeapon ( localPlayer ), getPedTotalAmmo ( localPlayer ) )
					elseif dgsGetText ( gButton["action1"] ) == "Herausnehmen" then
						triggerServerEvent ( "exchangeWeaponsWithBox", localPlayer, localPlayer, 1, "ex" )
					else
						outputChatBox ( "Du hast keine Waffe in der Hand!", 125, 0, 0 )
					end
				end
			end
		)
		addEventHandler("onDgsMouseClickUp", gButton["action2"],
			function (btn)
				if btn ~= "left" then return end
				if source == gButton["action2"] then
					if dgsGetText ( gButton["action2"] ) == "Einlagern" then
						triggerServerEvent ( "exchangeWeaponsWithBox", localPlayer, localPlayer, 2, "in", getPedWeapon ( localPlayer ), getPedTotalAmmo ( localPlayer ) )
					elseif dgsGetText ( gButton["action2"] ) == "Herausnehmen" then
						triggerServerEvent ( "exchangeWeaponsWithBox", localPlayer, localPlayer, 2, "ex" )
					else
						outputChatBox ( "Du hast keine Waffe in der Hand!", 125, 0, 0 )
					end
				end
			end
		)
		addEventHandler("onDgsMouseClickUp", gButton["action3"],
			function (btn)
				if btn ~= "left" then return end
				if source == gButton["action3"] then
					if dgsGetText ( gButton["action3"] ) == "Einlagern" then
						triggerServerEvent ( "exchangeWeaponsWithBox", localPlayer, localPlayer, 3, "in", getPedWeapon ( localPlayer ), getPedTotalAmmo ( localPlayer ) )
					elseif dgsGetText ( gButton["action3"] ) == "Herausnehmen" then
						triggerServerEvent ( "exchangeWeaponsWithBox", localPlayer, localPlayer, 3, "ex" )
					else
						outputChatBox ( "Du hast keine Waffe in der Hand!", 125, 0, 0 )
					end
				end
			end
		)

		addEventHandler("onDgsMouseClickUp", gButton["close"],
			function (btn)
				if btn ~= "left" then return end
				dgsSetVisible ( gWindow["gunbox"], false )
				guiSetInputMode ( "allow_binds" )
				showCursor(false)
				triggerServerEvent ( "crateUnfreezePed", localPlayer, localPlayer )
				triggerServerEvent ( "cancel_gui_server", localPlayer )
			end
		)
	end
	refreshData()
end
addEvent ( "gunCrateMenue", true )
addEventHandler ( "gunCrateMenue", getRootElement(), _createGunboxMenue )

function refreshData ()

	if getPedWeapon ( localPlayer ) == 0 then
		dgsSetText ( gButton["action1"], "" )
		dgsSetText ( gButton["action2"], "" )
		dgsSetText ( gButton["action3"], "" )
	else
		dgsSetText ( gButton["action1"], "Einlagern" )
		dgsSetText ( gButton["action2"], "Einlagern" )
		dgsSetText ( gButton["action3"], "Einlagern" )
	end
	local player = localPlayer
	local slot1, slot2, slot3 = vioClientGetElementData ( "gunboxa" ), vioClientGetElementData ( "gunboxb" ),vioClientGetElementData ( "gunboxc" )
	local gun1, ammo1 = gettok ( slot1, 1, string.byte('|') ), gettok ( slot1, 2, string.byte('|') )
	local gun2, ammo2 = gettok ( slot2, 1, string.byte('|') ), gettok ( slot2, 2, string.byte('|') )
	local gun3, ammo3 = gettok ( slot3, 1, string.byte('|') ), gettok ( slot3, 2, string.byte('|') )
	if tonumber(gun1) ~= 0 then
		dgsSetText ( gLabel["Slot1Gun"], weaponNames[tonumber(gun1)] )
		dgsSetText ( gButton["action1"], "Herausnehmen" )
	else
		dgsSetText ( gLabel["Slot1Gun"], "-Keine-" )
	end
	if tonumber(gun2) ~= 0 then
		dgsSetText ( gLabel["Slot2Gun"], weaponNames[tonumber(gun2)] )
		dgsSetText ( gButton["action2"], "Herausnehmen" )
	else
		dgsSetText ( gLabel["Slot2Gun"], "-Keine-" )
	end
	if tonumber(gun3) ~= 0 then
		dgsSetText ( gLabel["Slot3Gun"], weaponNames[tonumber(gun3)] )
		dgsSetText ( gButton["action3"], "Herausnehmen" )
	else
		dgsSetText ( gLabel["Slot3Gun"], "-Keine-" )
	end
	if tonumber(ammo1) <= 1 then
		dgsSetText ( gLabel["ammoSlot1"], "" )
	else
		dgsSetText ( gLabel["ammoSlot1"], ammo1.." Schuss" )
	end
	if tonumber(ammo2) <= 1 then
		dgsSetText ( gLabel["ammoSlot2"], "" )
	else
		dgsSetText ( gLabel["ammoSlot2"], ammo2.." Schuss" )
	end
	if tonumber(ammo3) <= 1 then
		dgsSetText ( gLabel["ammoSlot3"], "" )
	else
		dgsSetText ( gLabel["ammoSlot3"], ammo3.." Schuss" )
	end
end
addEvent ( "refreshGunCrateBox", true )
addEventHandler ( "refreshGunCrateBox", getRootElement(), refreshData )
