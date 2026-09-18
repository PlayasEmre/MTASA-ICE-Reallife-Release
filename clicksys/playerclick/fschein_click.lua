--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


--[[local curquestion = 0
local curwrong = 0

function showFLicenseTestWindow ()

	showCursor ( true )
	if isElement ( gWindow["FragenWindow"] ) then
		dgsSetVisible ( gWindow["FragenWindow"], true )
		dgsBringToFront ( gWindow["FragenWindow"] )
	else
		gWindow["FragenWindow"] = dgsCreateWindow(screenwidth/2-281/2, screenheight/2-284/2,281,284,"Frage 1",false)
		dgsBringToFront ( gWindow["FragenWindow"] )
		dgsWindowSetMovable(gWindow["FragenWindow"],false)
		dgsWindowSetSizable(gWindow["FragenWindow"],false)
		gButton["sendAnswere"] = dgsCreateButton(0.3061,0.82,0.3879,0.1444,"Bestätigen",true,gWindow["FragenWindow"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gLabel["frageFtest"] = dgsCreateLabel(0.0356,0.081,0.9146,0.25,"",true,gWindow["FragenWindow"])
		dgsLabelSetColor(gLabel["frageFtest"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["frageFtest"],"top")
		dgsLabelSetHorizontalAlign(gLabel["frageFtest"],"left",false)
		gRadio["FLicenseAnswere1"] = dgsCreateRadioButton(0.0391,0.3029,0.8,0.1162,"",true,gWindow["FragenWindow"])
		gRadio["FLicenseAnswere2"] = dgsCreateRadioButton(0.0391,0.3821,0.8,0.1162,"",true,gWindow["FragenWindow"])
		gRadio["FLicenseAnswere3"] = dgsCreateRadioButton(0.0391,0.4613,0.8,0.1162,"",true,gWindow["FragenWindow"])
		gRadio["FLicenseAnswere4"] = dgsCreateRadioButton(0.0391,0.5405,0.8,0.1162,"",true,gWindow["FragenWindow"])
		addEventHandler("onDgsMouseClickUp", gButton["sendAnswere"], goOnWithQuestions, true)
	end
	curquestion = 0
	curwrong = 0
	goOnWithQuestions ()
end

function goOnWithQuestions ( btn )

	if btn ~= nil and btn ~= "left" then return end
	if curquestion == 0 then
		dgsSetText ( gLabel["frageFtest"], "Wie hoch ist die Maximalgeschwindigkeit in\nder Stadt?" )
		dgsSetText ( gRadio["FLicenseAnswere1"], "80 km/h" )
		dgsSetText ( gRadio["FLicenseAnswere2"], "100 km/h" )
		dgsSetText ( gRadio["FLicenseAnswere3"], "120 km/h" )
		dgsSetText ( gRadio["FLicenseAnswere4"], "Keine" )
	elseif curquestion == 1 then
		if not dgsRadioButtonGetSelected ( gRadio["FLicenseAnswere3"] ) then
			curwrong = curwrong + 1
		end
		dgsSetText ( gLabel["frageFtest"], "Wo darf man NICHT parken?" )
		dgsSetText ( gRadio["FLicenseAnswere1"], "Auf Parkplätzen" )
		dgsSetText ( gRadio["FLicenseAnswere2"], "Auf der Straße" )
		dgsSetText ( gRadio["FLicenseAnswere3"], "Am Straßenrand" )
		dgsSetText ( gRadio["FLicenseAnswere4"], "Vor Häusern" )
	elseif curquestion == 2 then
		if not dgsRadioButtonGetSelected ( gRadio["FLicenseAnswere2"] ) then
			curwrong = curwrong + 1
		end
		dgsSetText ( gLabel["frageFtest"], "Wofür steht StVO?" )
		dgsSetText ( gRadio["FLicenseAnswere1"], "Straf Verordnung" )
		dgsSetText ( gRadio["FLicenseAnswere2"], "Staßen Verkehrs Obrigkeit" )
		dgsSetText ( gRadio["FLicenseAnswere3"], "Stammtisch Versammlung" )
		dgsSetText ( gRadio["FLicenseAnswere4"], "Straßen Verkehrs Ordnung" )
	elseif curquestion == 3 then
		if not dgsRadioButtonGetSelected ( gRadio["FLicenseAnswere4"] ) then
			curwrong = curwrong + 1
		end
		dgsSetText ( gLabel["frageFtest"], "Was darf man während des Fahrens\nNICHT?" )
		dgsSetText ( gRadio["FLicenseAnswere1"], "SMS schreiben" )
		dgsSetText ( gRadio["FLicenseAnswere2"], "Radiosender wechseln" )
		dgsSetText ( gRadio["FLicenseAnswere3"], "Licht an/aus schalten" )
		dgsSetText ( gRadio["FLicenseAnswere4"], "Verkehrsschilder lesen" )
	elseif curquestion == 4 then
		if not dgsRadioButtonGetSelected ( gRadio["FLicenseAnswere1"] ) then
			curwrong = curwrong + 1
		end
		dgsSetText ( gLabel["frageFtest"], "Was ist an einer Kreuzung\nzu beachten?" )
		dgsSetText ( gRadio["FLicenseAnswere1"], "Nichts" )
		dgsSetText ( gRadio["FLicenseAnswere2"], "Die Landschaft" )
		dgsSetText ( gRadio["FLicenseAnswere3"], "Rechts vor Links" )
		dgsSetText ( gRadio["FLicenseAnswere4"], "Schönheit vor Alter" )
	elseif curquestion == 5 then
		if not dgsRadioButtonGetSelected ( gRadio["FLicenseAnswere3"] ) then
			curwrong = curwrong + 1
		end
		dgsSetText ( gLabel["frageFtest"], "Was musst du tun, wenn ein\nPolizeifahrzeug mit Blaulicht sich nähert?" )
		dgsSetText ( gRadio["FLicenseAnswere1"], "Anhalten" )
		dgsSetText ( gRadio["FLicenseAnswere2"], "An den Rand fahren" )
		dgsSetText ( gRadio["FLicenseAnswere3"], "Weiterfahren" )
		dgsSetText ( gRadio["FLicenseAnswere4"], "Die Strasse blockieren" )
	elseif curquestion == 6 then
		if not dgsRadioButtonGetSelected ( gRadio["FLicenseAnswere2"] ) then
			curwrong = curwrong + 1
		end
		-- Ob bestanden oder nicht entscheidet allein der Server in
		-- drivingSchoolTheoryComplete_func ( carsys/drivingschool/drivingschool_server.lua ),
		-- der dann entweder die praktische Pruefung startet oder zurueckspawnt.
		-- Hier wird nur die Zahl der richtigen Antworten gemeldet.
		hideTheoryWindow ()
		triggerServerEvent ( "drivingSchoolTheoryComplete", localPlayer, 6 - curwrong )
	end
	dgsRadioButtonSetSelected ( gRadio["FLicenseAnswere1"], true )
	dgsRadioButtonSetSelected ( gRadio["FLicenseAnswere1"], false )
	curquestion = curquestion + 1
end

function hideTheoryWindow ()

	dgsSetVisible ( gWindow["FragenWindow"], false )
	dgsSetInputMode ( "allow_binds" )
	showCursor(false)
	triggerServerEvent ( "cancel_gui_server", localPlayer )
end

function showFLicenseWindow ()

	dgsSetVisible(gWindow["license"], false)
	dgsSetVisible(gWindow["rathausbg"], false)
	dgsSetInputMode ( "no_binds_when_editing" )
	showCursor ( true )
	setElementClicked ( true )
	if isElement ( gWindow["infoFscheinText"] ) then
		dgsSetVisible ( gWindow["infoFscheinText"], true )
		dgsBringToFront ( gWindow["infoFscheinText"] )
	else
		local screenwidth, screenheight = guiGetScreenSize ()

		gWindow["infoFscheinText"] = dgsCreateWindow(screenwidth/2-470/2,screenheight/2-251/2,470,251,"Informationen",false,nil,nil,nil,nil,nil,tocolor(16,29,61,255))
		dgsBringToFront ( gWindow["infoFscheinText"] )
		dgsSetProperty(gWindow["infoFscheinText"], "image", false)
		dgsWindowSetMovable(gWindow["infoFscheinText"],false)
		dgsWindowSetSizable(gWindow["infoFscheinText"],false)
		gButton["weiterInfoFlicense"] = dgsCreateButton(0.3638,0.745,0.2745,0.1873,"Weiter",true,gWindow["infoFscheinText"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gLabel["Infotext"] = dgsCreateLabel(0.0255,0.1036,0.9426,0.5936,"",true,gWindow["infoFscheinText"]) -- 10 Reihen
		dgsLabelSetColor(gLabel["Infotext"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["Infotext"],"top")
		dgsLabelSetHorizontalAlign(gLabel["Infotext"],"left",false)
		addEventHandler("onDgsMouseClickUp", gButton["weiterInfoFlicense"], nextInfoText, true)
	end
	curtext = 0
	dgsSetText ( gLabel["Infotext"], "Herzlich wilkommen bei der theoretischen Führerschein-\nPrüfung. Hier werden dir die Grundlagen beigebracht\nund anschließend abgefragt, bevor du in die\nPraxis einsteigen kannst." )
end
addEvent ( "startFLicenseTest", true )
addEventHandler ( "startFLicenseTest", getRootElement(), showFLicenseWindow )

function nextInfoText ( btn )

	if btn ~= nil and btn ~= "left" then return end
	curtext = curtext + 1
	if curtext == 1 then
		dgsSetText ( gLabel["Infotext"], "Zuerst einige Grundregeln:\nEs herrscht Rechtsfahrgebot, d.h. dass - bis auf\neinige, wenige Ausnahmen wie die Polizei - alle\nFahrer rechts fahren sollten bzw. müssen. Außerdem gibt\nes eine Geschwindigkeitsbegrenzung in der Stadt, die bei\nca. 120 km/h liegt.\nSchneller zu fahren ist ein Risiko, da z.b. an Kreuzungen\nein zu grosses Risiko besteht, übersehen zu werden." )
	elseif curtext == 2 then
		dgsSetText ( gLabel["Infotext"], "Jeder Verstoß gegen die Straßen-Verkehrs-Ordnung\n( StVO genannt ) wird von der Polizei bestraft werden -\nim Normalfall mit StVO-Punkten, in schweren Fällen sogar\nmit Wanteds. Hast du 15 Punkte, so wird dir beim nächsten\nLogin der Führerschein abgenommen.\nFalls du eine Sirene hörst, fahre bitte an die Seite -\naußerdem ist es verboten, während der Fahrt zu\ntelefonieren oder SMS zu schreiben." )
	elseif curtext == 3 then
		dgsSetVisible ( gWindow["infoFscheinText"], false )
		showFLicenseTestWindow ()
	end
end
--]]