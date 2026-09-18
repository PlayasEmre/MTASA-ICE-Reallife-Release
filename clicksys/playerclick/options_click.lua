--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Aktualisiert den Autologin-Button-Text passend zum aktuellen Zustand -
-- eigene Funktion, weil er sowohl beim Erstellen als auch bei jeder
-- serverseitigen Aenderung ( z.B. nach dem Login neu gesetzt ) aufgerufen wird.
local function aktualisiereAutologinButton ()
	if not isElement ( gButton["autologin"] ) then return end
	local aus = getElementData ( localPlayer, "autologinAus" ) == true
	dgsSetText ( gButton["autologin"], aus and "Autologin: AUS" or "Autologin: AN" )
end

addEventHandler ( "onClientElementDataChange", localPlayer, function ( key )
	if key == "autologinAus" then
		aktualisiereAutologinButton ()
	end
end )

function showSettingsMenue ()
	hideall ()
	if not isElement ( gWindow["settings"] ) then
		gWindow["settings"] = dgsCreateWindow(screenwidth/2-285/2,120,285,316+56*2,"Optionsmenü",false)
		dgsWindowSetCloseButtonEnabled(gWindow["settings"], false)
		dgsSetAlpha(gWindow["settings"],1)
		dgsWindowSetMovable ( gWindow["settings"], false )
		dgsWindowSetSizable ( gWindow["settings"], false )

		gButton["bonusMenue"] = dgsCreateButton(9,24,101,42,"Bonuspunkte",false,gWindow["settings"])
		dgsSetAlpha(gButton["bonusMenue"],1)
		dgsSetFont(gButton["bonusMenue"],"default-bold")

		gButton["firstPerson"] = dgsCreateButton(9,80,101,42,"First Person",false,gWindow["settings"])
		dgsSetAlpha(gButton["firstPerson"],1)
		dgsSetFont(gButton["firstPerson"],"default-bold")
		gButton["socialState"] = dgsCreateButton(9,135,101,42,"Sozialer Status",false,gWindow["settings"])
		dgsSetAlpha(gButton["socialState"],1)
		dgsSetFont(gButton["socialState"],"default-bold")
		gButton["spawnPoint"] = dgsCreateButton(9,190,101,42,"Spawnpunkt",false,gWindow["settings"])
		dgsSetAlpha(gButton["spawnPoint"],1)
		dgsSetFont(gButton["spawnPoint"],"default-bold")
		gButton["autologin"] = dgsCreateButton(9,245,101,42,"Autologin: AN",false,gWindow["settings"])
		dgsSetAlpha(gButton["autologin"],1)
		dgsSetFont(gButton["autologin"],"default-bold")
		aktualisiereAutologinButton ()

		--gButton["closeSettings"] = dgsCreateButton(260,-25,26,25,"×",false,gWindow["settings"],_,_,_,_,_,_,tocolor(200,50,50,255),tocolor(250,20,20,255),tocolor(150,50,50,255),true)
		--dgsSetProperty(gButton["closeSettings"],"textSize",{1.6,1.6})
		
		addEventHandler ( "onDgsMouseClickUp", gButton["bonusMenue"],
			function (button)
				if button == "left" then
					dgsSetVisible( gWindow["settings"], false )
					_createBonusmenue_func()
				end
			end,
		false )
		
		addEventHandler ( "onDgsMouseClickUp", gButton["spawnPoint"],
			function (button)
				if button == "left" then
					dgsSetVisible( gWindow["settings"], false )
					showSpawnSelection ()
				end
			end,
		false )

		addEventHandler ( "onDgsMouseClickUp", gButton["autologin"],
			function (button)
				if button == "left" then
					triggerServerEvent ( "toggleAutologin", localPlayer )
				end
			end,
		false )

		addEventHandler ( "onDgsMouseClickUp", gButton["socialState"],
			function (button)
				if button == "left" then
					dgsSetVisible( gWindow["settings"], false )
					showSocialRankWindow ()
				end
			end,
		false )
		
		addEventHandler ( "onDgsMouseClickUp", gButton["firstPerson"],
			function (button)
				if button == "left" then
					executeCommandHandler ( "ego" )
				end
			end,
		false )
		
		--[[addEventHandler ( "onDgsMouseClickUp", gButton["closeSettings"],
			function (button)
				if button == "left" then
					dgsSetVisible( gWindow["settings"], false )
				end
			end,
		false )--]]
		
		gLabel[1] = dgsCreateLabel(117,22,161,51,"Hier kannst du Bonuspunkte\nfür Verbesserungen aus-\ngeben",false,gWindow["settings"])
		dgsSetAlpha(gLabel[1],1)
		dgsLabelSetColor(gLabel[1],200,200,0)
		dgsLabelSetVerticalAlign(gLabel[1],"top")
		dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
		dgsSetFont(gLabel[1],"default-bold")
		gLabel[3] = dgsCreateLabel(117,80,162,53,"Hier kannst du die Ego-Sicht\nein- und aus schalten\n( Schnellbefehl: /ego )",false,gWindow["settings"])
		dgsSetAlpha(gLabel[3],1)
		dgsLabelSetColor(gLabel[3],200,200,0)
		dgsLabelSetVerticalAlign(gLabel[3],"top")
		dgsLabelSetHorizontalAlign(gLabel[3],"left",false)
		dgsSetFont(gLabel[3],"default-bold")
		gLabel[4] = dgsCreateLabel(117,140,162,53,"Hier kannst du deinen\nsozialen Status verwalten.",false,gWindow["settings"])
		dgsSetAlpha(gLabel[4],1)
		dgsLabelSetColor(gLabel[4],200,200,0)
		dgsLabelSetVerticalAlign(gLabel[4],"top")
		dgsLabelSetHorizontalAlign(gLabel[4],"left",false)
		dgsSetFont(gLabel[4],"default-bold")
		gLabel[5] = dgsCreateLabel(117,190,162,53,"Hier kannst du deinen Start-\npunkt auswählen.",false,gWindow["settings"])
		dgsSetAlpha(gLabel[5],1)
		dgsLabelSetColor(gLabel[5],200,200,0)
		dgsLabelSetVerticalAlign(gLabel[5],"top")
		dgsLabelSetHorizontalAlign(gLabel[5],"left",false)
		dgsSetFont(gLabel[5],"default-bold")
		gLabel[6] = dgsCreateLabel(117,245,162,53,"Ohne Autologin musst du\ndich bei diesem PC immer\nmit Passwort einloggen.",false,gWindow["settings"])
		dgsSetAlpha(gLabel[6],1)
		dgsLabelSetColor(gLabel[6],200,200,0)
		dgsLabelSetVerticalAlign(gLabel[6],"top")
		dgsLabelSetHorizontalAlign(gLabel[6],"left",false)
		dgsSetFont(gLabel[6],"default-bold")

	else
		dgsSetVisible ( gWindow["settings"], true )
	end
end