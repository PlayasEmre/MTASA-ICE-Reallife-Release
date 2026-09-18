--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

wantedpc={gridlist={},window={},button={},}

-- dgsGridListGetSelectedItem liefert -1, wenn nichts markiert ist. Ungeprueft an
-- dgsGridListGetItemText weitergereicht wirft das einen Fehler. Hier kommt dann
-- "" zurueck - genau das, worauf die Aufrufer unten ohnehin schon pruefen.
local function ausgewaehlterText ( gridlist, spalte )
	if not gridlist then return "" end
	local zeile = dgsGridListGetSelectedItem ( gridlist )
	if not zeile or zeile < 0 then return "" end
	return dgsGridListGetItemText ( gridlist, zeile, spalte ) or ""
end

wantedReason={
	{ "Verweigerung zur Durchsuchung", 1 },
	{ "Beamtenbehinderung", 1 },
	{ "Beamtenbelästigung", 1 },
	{ "Beleidigung", 1 },
	{ "Befehlsverweigerung", 1 },
	{ "Materialbesitz ( 10-49 )", 1 },
	{ "Drogenbesitz ( 10-49 )", 1 },
	{ "Versuchter Diebstahl", 1 },
	{ "starke Sachbeschädigung", 1 },
	{ "starke Sachbeschädigung", 1 },
	{ "illegale Werbung", 1 },
	{ "Waffennutzung", 1 },
	{ "Vortäuschen falscher Tatsachen", 1 },
	{ "Körperverletzung", 1 },
	{ "Einfluss unter Drogen", 1 },
	{ "Drogenkonsum", 1 },
	{ "Fahren ohne Führerschein", 1 },
	
	-- 2 --
	{ "Flucht vor/aus Kontrolle", 2 },
	{ "Beihilfe zur Flucht", 2 },
	{ "Körperverletzung durch Schusswaffen", 2 },
	{ "Beschuss", 2 },
	{ "Materialbesitz ( 50-149 )", 2 },
	{ "Drogenbesitz ( 50-149 )", 2 },
	{ "Bestechungsversuch", 2 },
	{ "illegaler Verkauf von Waffen/Drogen/Mats", 2 },
	{ "Diebstahl", 2 },
	{ "Drogen Anbau/Abbau", 2 },
	{ "Drogen/Mats wegwerfen", 2 },
	{ "Erpressung / Drohung", 2 },
	{ "Vandalismus", 2 },
	
	-- 3 --
	{ "Materialbesitz ( 150+ )", 3 },
	{ "Drogenbesitz ( 150+ )", 3 },
	{ "Matstruck", 3 },
	{ "Drogentruck", 3 },
	{ "Carrob", 3 },
	{ "Betreten des Bundeswehrgebiets (Feldweg)", 3 },
	{ "Betreten des SFPD/LVPD Parkplatzes (Hinterhof)", 3 },
	{ "Mord", 3 },
	
	-- 4 --
	{ "Bankraub", 4 },
	{ "Geiselnahme", 4 },
	{ "Museumraub", 4 },
	{ "Sniper-Nutzung", 4 },
	{ "Betreten der Polizeiwache", 4 },
	
	-- 6 --	
	{ "Betreten des Flugzeugträgers", 6 },
	{ "Betreten der FBI Basis", 6 },
	{ "Einbruch in die Area51", 6 },
	{ "Raketenwerfer-Nutzung", 6 },
}

stvoReason={
{"Bournout (Reifen durchdrehen lassen)",1},
{"Halten auf der Strasse",1},
{"Falschparken",1},
{"Sachbeschädigung von Objekten",2},
{"Missachtung der Vorfahrtsregeln",2},
{"Mit einem Fluggerät auf der Straße landen",3},
{"Nichtbeachten der Einbahnstrassen",3},
{"Missachtung der Fahrverbote",3},
{"Verursachen eines Unfalls",4},
{"Abseitsfahren der Straße",4},
{"Verwendung von Nitro",4},
{"Rasen innerhalb der Stadt (80 km/h)",5},
{"An- und Überfahren von Passanten",6},
{"Geisterfahrten",6},
}

addEvent("wantedcomputer",true)
addEventHandler("wantedcomputer",root,
function()
	if(getElementData(lp,"ElementClicked")==false)then
		showCursor(true)
		setElementData(lp,"ElementClicked",true)
		guiSetInputMode("no_binds")
		guiSetInputMode("no_binds_when_editing")
		wantedpc.window[1]=dgsCreateWindow(0,GLOBALscreenY/2-600/2,880,600,""..Tables.servername.."- Wantedcomputer",false)			dgsWindowSetCloseButtonEnabled(wantedpc.window[1],false)
		dgsMoveTo(wantedpc.window[1],GLOBALscreenX/2-880/2,GLOBALscreenY/2-600/2,false,false,"OutQuad",1500)
		dgsWindowSetSizable(wantedpc.window[1],false)
		dgsWindowSetMovable(wantedpc.window[1],false)
		wantedpc.button[1]=dgsCreateButton(854,-25,26,25,"×",false,wantedpc.window[1])
        dgsSetProperty(wantedpc.button[1],"textSize",{1.6,1.6})
		wantedpc.gridlist[1]=dgsCreateGridList(10,10,230,550,false,wantedpc.window[1],_,tocolor(50,50,50,255),tocolor(255,255,255,255),tocolor(30,30,30,255),tocolor(65,65,65,255))
		column=dgsGridListAddColumn(wantedpc.gridlist[1],"Spieler",0.5)
		wanteds=dgsGridListAddColumn(wantedpc.gridlist[1],"Wanteds",0.25)
		stvos=dgsGridListAddColumn(wantedpc.gridlist[1],"Stvos",0.2)
		wantedpc.gridlist[2]=dgsCreateGridList(250,10,310,340,false,wantedpc.window[1],_,tocolor(50,50,50,255),tocolor(255,255,255,255),tocolor(30,30,30,255),tocolor(65,65,65,255))
		wantedReasonList=dgsGridListAddColumn(wantedpc.gridlist[2],"Grund",0.8)
		wantedAnzahlList=dgsGridListAddColumn(wantedpc.gridlist[2],"Wanteds",0.18)
		wantedpc.gridlist[3]=dgsCreateGridList(570,10,300,340,false,wantedpc.window[1],_,tocolor(50,50,50,255),tocolor(255,255,255,255),tocolor(30,30,30,255),tocolor(65,65,65,255))
		stvoReasonList=dgsGridListAddColumn(wantedpc.gridlist[3],"Grund",0.8)
		stvoAnzahlList=dgsGridListAddColumn(wantedpc.gridlist[3],"StVOs",0.15)
		wantedpc.button[2]=dgsCreateButton(255,360,615,35,"Wanted(s) geben",false,wantedpc.window[1])
		wantedpc.button[3]=dgsCreateButton(255,400,615,35,"Wanted(s) löschen",false,wantedpc.window[1])
		wantedpc.button[4]=dgsCreateButton(255,440,615,35,"StVO-Punkt(e) geben",false,wantedpc.window[1])
		wantedpc.button[5]=dgsCreateButton(255,480,615,35,"StVO-Punkt(e) löschen",false,wantedpc.window[1])
		wantedpc.button[6]=dgsCreateButton(255,520,615,35,"Spieler Orten",false,wantedpc.window[1])
		
		addEventHandler("onDgsMouseClick",wantedpc.button[2],
			function(btn,state)
				if btn=="left" and state=="up" then
					player = ausgewaehlterText(wantedpc.gridlist[1],1)
					reason = ausgewaehlterText(wantedpc.gridlist[2],1)
					wanted = ausgewaehlterText(wantedpc.gridlist[2],2)
					
					if(not(player == ""))then
						triggerServerEvent("giveWanteds",lp,player,reason,wanted)
					else infobox_start_func("Wähl einen Spieler aus!",7500,255,0,0)end
				end
			end,
		false)
		
		addEventHandler("onDgsMouseClick",wantedpc.button[3],
			function(btn,state)
				if btn=="left" and state=="up" then
					player = ausgewaehlterText(wantedpc.gridlist[1],1)
					
					if(not(player == ""))then
						triggerServerEvent("deleteWanteds",lp,player)
					else infobox_start_func("Wähl einen Spieler aus!",7500,255,0,0)end
				end
			end,
		false)
		
		addEventHandler("onDgsMouseClick",wantedpc.button[4],
			function(btn,state)
				if btn=="left" and state=="up" then
					player = ausgewaehlterText(wantedpc.gridlist[1],1)
					reason = ausgewaehlterText(wantedpc.gridlist[3],1)
					stvo = ausgewaehlterText(wantedpc.gridlist[3],2)
					
					if(not(player == ""))then
						triggerServerEvent("giveStvoS",lp,player,reason,stvo)
					else infobox_start_func("Wähl einen Spieler aus!",7500,255,0,0)end
				end
			end,
		false)
		
		addEventHandler("onDgsMouseClick",wantedpc.button[5],
			function(btn,state)
				if btn=="left" and state=="up" then
					player = ausgewaehlterText(wantedpc.gridlist[1],1)
					
					if(not(player == ""))then
						triggerServerEvent("deleteStvoS",lp,player)
					else infobox_start_func("Wähl einen Spieler aus!",7500,255,0,0)end
				end
			end,
		false)
		
		addEventHandler("onDgsMouseClick",wantedpc.button[6],
			function(btn,state)
				if btn=="left" and state=="up" then
					local player=ausgewaehlterText(wantedpc.gridlist[1],1)
							
					if(not(player==""))then
						triggerServerEvent("wantedpc.orten",lp,player)
					else infobox_start_func("Wähl einen Spieler aus!",7500,255,0,0)end
				end
			end,
		false)
		
		addEventHandler("onDgsMouseClick",wantedpc.button[1],
			function(btn,state)
				if btn=="left" and state=="up" then
					dgsCloseWindow(wantedpc.window[1])
					showCursor(false)
					setElementData(lp,"ElementClicked",false)
				end
			end,
		false)
		
		for _,player in ipairs(getElementsByType("player"))do
			row=dgsGridListAddRow(wantedpc.gridlist[1])
			dgsGridListSetItemText(wantedpc.gridlist[1],row,column,getPlayerName(player),false,false)
			dgsGridListSetItemText(wantedpc.gridlist[1],row,wanteds,tonumber(getElementData(player,"wanteds")),false,false)
			dgsGridListSetItemText(wantedpc.gridlist[1],row,stvos,tonumber(getElementData(player,"stvo_punkte")),false,false)
		end
		
		for key,_ in pairs(wantedReason)do
			row=dgsGridListAddRow(wantedpc.gridlist[2])
			dgsGridListSetItemText(wantedpc.gridlist[2],row,wantedReasonList,wantedReason[key][1],false,false)
			dgsGridListSetItemText(wantedpc.gridlist[2],row,wantedAnzahlList,wantedReason[key][2],false,false)
		end
		for key,_ in pairs(stvoReason)do
			row=dgsGridListAddRow(wantedpc.gridlist[3])
			dgsGridListSetItemText(wantedpc.gridlist[3],row,stvoReasonList,stvoReason[key][1],false,false)
			dgsGridListSetItemText(wantedpc.gridlist[3],row,stvoAnzahlList,stvoReason[key][2],false,false)
		end
	end
end)


selfmadeWantedcomputer={}

addEvent("selfmadeWantedcomputer.create",true)
addEventHandler("selfmadeWantedcomputer.create",root,function(x,y,z)
	if(isElement(selfmadeWantedcomputer.ortungsBlip))then destroyElement(selfmadeWantedcomputer.ortungsBlip)end
	if(isTimer(selfmadeWantedcomputer.ortenTimer))then killTimer(selfmadeWantedcomputer.ortenTimer)end
	
	selfmadeWantedcomputer.ortungsBlip=createBlip(x,y,z,0,2,255,0,0)
	
	ortenTimer=setTimer(function()
		destroyElement(selfmadeWantedcomputer.ortungsBlip)
	end,25000,1)
end)