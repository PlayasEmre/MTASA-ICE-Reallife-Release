--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

loadstring(exports.DGS:dgsImportFunction())()

jobTexts = {}
 jobTexts[1] = "\"Las Venturas Bau Co.\" braucht fleißige Arbeiter,\ndie ihr Geld auf ehrliche\nArt und Weise verdienen wollen!\nGebraucht wird für den Anfang nichts."
 jobTexts[2] = "\"San Andreas Fishing Co.\" sucht fähige See-\nleute, die auch bei Sturm und Regen\nnicht aufgeben. Bezahlt wird nach\nFangmenge, jeder mit Angel -\nund Motorbootschein ist willkommen!"
 jobTexts[3] = "\"Ammunation San Fierro\" sucht Mitarbeiter\nfuer die Strasse, jedoch ist ein Waffenschein\nPflicht."
 jobTexts[4] = "Du willst dir mit (mehr oder weniger) legaler\nArbeit etwas Geld verdienen?\nDann melde dich!"
 -- 5 war der Taxifahrer, der Job wurde entfernt. Die Liste wird mit pairs
 -- durchlaufen, die Luecke stoert die uebrigen Jobs also nicht.
 jobTexts[6] = "Du bist ein guter Fahrer, der\nsich viel Geld bei kleinem\nRisiko verdienen will?\nDann melde dich an\nden Docks!"
 jobTexts[7] = "Wenn dir der Geruch von altem Frittenfett\nund ein paar verdorbene Maegen\nnichts anhaben koennen, dann bist\ndu hier richtig! Freie Mitarbeiter\nwerden immer gesucht.\nBenötigt: Führerschein"
 jobTexts[8] = "Vom Kofferpacker bis zum Frachtpilot\n- Fang bei 0 an und arbeite dich hoch!\nBenötigt: Führerschein"
 jobTexts[9] = "Ein schmutziges Geschaeft: Vom Pfand-\nflaschensammler bis zum Muellwagenfahrer\nist alles moeglich!"
 jobTexts[10] = "Einfache Arbeit, die gutes Geld\neinbringt - spaeter auch mit dem Traktor\noder Mähdrescher."
 jobTexts[11] = "gabelstablerjob"
jobNames = {}
 jobNames[1] = "Bauarbeiter"
 jobNames[2] = "Fischer"
 jobNames[3] = "Waffendealer"
 jobNames[4] = "Dealer"
 jobNames[6] = "Transporteur"
 jobNames[7] = "Hotdogverkaeufer"
 jobNames[8] = "Flughafen"
 jobNames[9] = "Strassenreinigung"
 jobNames[10] = "Farmer"
 jobNames[11] = "gabelstablerjob"

jobInfo = {}
 jobInfo[1] = "Nein"
 jobInfo[2] = "Nein"
 jobInfo[3] = "Ja"
 jobInfo[4] = "Ja"
 jobInfo[5] = "Ja"
 jobInfo[6] = "Nein"
 jobInfo[7] = "Ja"
 jobInfo[8] = "Nein"
 jobInfo[9] = "Nein"
 jobInfo[10] = "Nein"
 jobInfo[11] = "Nein"

function killcityhallmarker_func ()

	if jobBlipCityhall then destroyElement ( jobBlipCityhall ) end
end
addEvent ( "killcityhallmarker", true )
addEventHandler ( "killcityhallmarker", getRootElement(), killcityhallmarker_func )

function showJobGui_func ()

	showJobGUI ()
end
addEvent ( "showJobGui", true )
addEventHandler ( "showJobGui", getRootElement(), showJobGui_func )

function hideJobGui ( btn, state )

	if btn == "left" and gWindow["jobs"] then
		dgsSetVisible(gWindow["jobs"], false)
		dgsSetInputMode ( "allow_binds" )
		showCursor(false)
		triggerServerEvent ( "cancel_gui_server", localPlayer )
	end
end

function refreshJobInfo ()


end

function anzeigenJobGui ( btn, state )

	if btn ~= "left" then return end
	if state == "up" then
		dgsSetVisible(gWindow["jobs"], false)
		dgsSetInputMode ( "allow_binds" )
		showCursor(false)
		triggerServerEvent ( "cancel_gui_server", localPlayer )
		outputChatBox ( "Die Position des Arbeitgebers wird dir nun auf der Karte angezeigt. Tippe /job um den Marker zu löschen.",  0, 125, 0 )
		if jobnr == 1 then
			jobBlipCityhall = createBlip ( 820.48828125,857.15643310547,12.005271911621, 41, 1 )			-- Bauarbeiter
		elseif jobnr == 2 then
			jobBlipCityhall = createBlip ( -1724.9904785156, 1461.3231201172, 7, 41, 1 )					-- Fischer
		elseif jobnr == 3 then
			jobBlipCityhall = createBlip ( -2627.5083007813, 209.36631774902, 4.1959328651428, 41, 1 )		-- Waffendealer
		elseif jobnr == 4 then
			jobBlipCityhall = createBlip ( -1868.9344482422, -144.03060913086, 11.665347099304, 41, 1 ) 	-- Dealer
		elseif jobnr == 6 then
			jobBlipCityhall = createBlip ( -1828.4, 99.5, 14.76, 41, 1 )		                            -- Transporteur
		elseif jobnr == 7 then
			jobBlipCityhall = createBlip ( -1706.1116943359, 13.159648895264, 3.2039132118225, 41, 1 )		-- Hotdogverkaeufer
		elseif jobnr == 8 then
			jobBlipCityhall = createBlip ( -1414.8072509766, -299.4963684082, 5.8523507118225, 41, 1 )		-- Flughafenarbeiter
		elseif jobnr == 9 then
			jobBlipCityhall = createBlip ( -1897.1510009766, -1671.5749511719, 22.66, 41, 1 )				-- Strassenreinigung
		elseif jobnr == 10 then
			jobBlipCityhall = createBlip ( -1058.36, -1195.6, 128.83, 41, 1 )				-- Farmer
		elseif jobnr == 11 then
			jobBlipCityhall = createBlip ( -2965.4443359375,1232.98828125,5.0010261535645, 41, 1 )				-- gabelstablerjob
		end
	end
end

function showJobGUI()

	showCursor ( true )
	if gWindow["jobs"] then
		dgsSetVisible ( gWindow["jobs"], true )
		dgsBringToFront ( gWindow["jobs"] )
	else
		gWindow["jobs"] = dgsCreateWindow(screenwidth/2-451/2,screenheight/2-420/2,451,420,"Jobcenter",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true)
		dgsBringToFront ( gWindow["jobs"] )
		gImage["jobStar"] = dgsCreateImage(9,38,38,31,":"..getResourceName(getThisResource()).."/images/internet/star.png",false,gWindow["jobs"])
		gLabel["jobText1"] = dgsCreateLabel(49,19,394,69,"Herzlich wilkommen im Jobcenter!\nHier kannst du dich über die einzelnen Jobs informieren,\nmit denen du Geld verdienen kannst.\nFür den Anfang werden Jobs empfohlen, die nicht Spielerbasiert sind\n- also auch ohne andere Spieler funktionieren.",false,gWindow["jobs"])
		dgsLabelSetColor(gLabel["jobText1"],200,000,0,255)
		dgsLabelSetVerticalAlign(gLabel["jobText1"],"top")
		dgsLabelSetHorizontalAlign(gLabel["jobText1"],"left",false)
		dgsSetFont(gLabel["jobText1"],"default-bold")
		gGrid["joblist"] = dgsCreateGridList(9,100,177,272,false,gWindow["jobs"])
		dgsGridListSetSelectionMode(gGrid["joblist"],0)
		gColumn["job"] = dgsGridListAddColumn(gGrid["joblist"],"Job",0.8)
		gLabel["jobText2"] = dgsCreateLabel(190,101,258,225,"Bitte waehle einen Job aus der Liste aus!",false,gWindow["jobs"])
		dgsLabelSetColor(gLabel["jobText2"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["jobText2"],"top")
		dgsLabelSetHorizontalAlign(gLabel["jobText2"],"left",false)
		dgsSetFont(gLabel["jobText2"],"default-bold")
		gButtons["jobanzeigen"] = dgsCreateButton(264,328,95,45,"Position anzeigen",false,gWindow["jobs"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		dgsSetFont(gButtons["jobanzeigen"],"default-bold")
		gButtons["jobcancel"] = dgsCreateButton(424,26,15,17,"x",false,gWindow["jobs"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		addEventHandler("onDgsMouseClickUp", gButtons["jobcancel"], hideJobGui, false)
		addEventHandler("onDgsMouseClickUp", gButtons["jobanzeigen"], anzeigenJobGui, false)

		dgsWindowSetSizable ( gWindow["jobs"], false )
		dgsWindowSetMovable ( gWindow["jobs"], false )

		local row = dgsGridListAddRow ( gGrid["joblist"] )
		dgsGridListSetItemText ( gGrid["joblist"], row, gColumn["job"], "Empfohlen", true, false )
		dgsGridListSetItemColor ( gGrid["joblist"], row, gColumn["job"], 0, 200, 0, 255 )
		for key, index in pairs ( jobInfo ) do
			if index == "Nein" then
				local row = dgsGridListAddRow ( gGrid["joblist"] )
				dgsGridListSetItemText ( gGrid["joblist"], row, gColumn["job"], jobNames[key], false, false )
				addEventHandler("onDgsMouseClickUp", gGrid["joblist"],
					function (btn)
						if btn ~= "left" then return end
						local row, column = dgsGridListGetSelectedItem ( gGrid["joblist"] )
						if row == -1 then return end
						local rowtext = dgsGridListGetItemText ( gGrid["joblist"], row, column )
						for key, index in pairs ( jobNames ) do
							if rowtext == index then
								jobnr = key
								dgsSetText ( gLabel["jobText2"], jobTexts[key] )
								break
							end
						end
					end
				)
			end
		end
		local row = dgsGridListAddRow ( gGrid["joblist"] )
		dgsGridListSetItemText ( gGrid["joblist"], row, gColumn["job"], "Spielerbasiert", true, false )
		dgsGridListSetItemColor ( gGrid["joblist"], row, gColumn["job"], 200, 0, 0, 255 )
		for key, index in pairs ( jobInfo ) do
			if index == "Ja" then
				local row = dgsGridListAddRow ( gGrid["joblist"] )
				dgsGridListSetItemText ( gGrid["joblist"], row, gColumn["job"], jobNames[key], false, false )
				addEventHandler("onDgsMouseClickUp", gGrid["joblist"],
					function (btn)
						if btn ~= "left" then return end
						local row, column = dgsGridListGetSelectedItem ( gGrid["joblist"] )
						if row == -1 then return end
						local rowtext = dgsGridListGetItemText ( gGrid["joblist"], row, column )
						for key, index in pairs ( jobNames ) do
							if rowtext == index then
								jobnr = key
								dgsSetText ( gLabel["jobText2"], jobTexts[key] )
								break
							end
						end
					end
				)
			end
		end
	end
end