--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--\\                                                  //

loadstring(exports.DGS:dgsImportFunction())()

local screenwidth, screenheight = guiGetScreenSize ()

local ACC_N, ACC_H, ACC_P = tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255)

local BREITE      = 340
local TITELHOEHE  = 26   -- DGS schiebt Kind-Elemente um die Titelleiste nach unten,
                         -- rechnet sie aber NICHT in die Fensterhoehe ein.
local RAND        = 20
local BUTTONHOEHE = 38
local EDITHOEHE   = 34

local fenster, editFeld

local function schliesseDialog ()
	if isElement ( fenster ) then destroyElement ( fenster ) end
	fenster, editFeld = nil, nil
	dgsSetInputMode ( "allow_binds" )
	showCursor ( false )
end
-- Wird vom Interaktionsmenue und von trauungAbgeschlossen mitbenutzt.
function closeAllHochzeitFenster () schliesseDialog () end

local function zeilen ( text )
	local n = 1
	for _ in tostring(text):gmatch ( "\n" ) do n = n + 1 end
	return n
end

-- Baut ein Dialogfenster: Text, optionales Eingabefeld, 1-2 Buttons nebeneinander.
-- Die Fensterhoehe ergibt sich aus dem Inhalt, damit nichts unten herausragt.
-- knoepfe = { { "Beschriftung", handler }, ... }; der handler bekommt den Text des
-- Eingabefeldes und kann false zurueckgeben, um den Dialog offen zu lassen.
local function dialog ( titel, text, knoepfe, mitEdit )
	schliesseDialog ()

	local textHoehe = math.max ( 60, zeilen ( text ) * 20 )
	local textY     = RAND
	local editY     = textY + textHoehe + 12
	local buttonY   = mitEdit and ( editY + EDITHOEHE + 16 ) or editY
	local hoehe     = TITELHOEHE + buttonY + BUTTONHOEHE + RAND

	fenster = dgsCreateWindow ( screenwidth/2-BREITE/2, screenheight/2-hoehe/2, BREITE, hoehe,
		titel, false, nil,nil,nil,nil,nil, tocolor(16,29,61,255), nil, true )
	dgsWindowSetMovable ( fenster, false )
	dgsWindowSetSizable ( fenster, false )
	dgsBringToFront ( fenster )

	local label = dgsCreateLabel ( RAND, textY, BREITE-2*RAND, textHoehe, text, false, fenster )
	dgsSetFont ( label, "default-bold" )
	dgsLabelSetHorizontalAlign ( label, "center" )
	dgsLabelSetVerticalAlign ( label, "center" )

	if mitEdit then
		editFeld = dgsCreateEdit ( RAND, editY, BREITE-2*RAND, EDITHOEHE, "", false, fenster )
	end

	local anzahl = #knoepfe
	local breite = ( BREITE - 2*RAND - ( anzahl-1 ) * 10 ) / anzahl

	for i, knopf in ipairs ( knoepfe ) do
		local btn = dgsCreateButton ( RAND + (i-1)*(breite+10), buttonY, breite, BUTTONHOEHE,
			knopf[1], false, fenster, _,_,_,_,_,_, ACC_N, ACC_H, ACC_P )
		addEventHandler ( "onDgsMouseClickUp", btn, function ( taste, status )
			if taste ~= "left" or status ~= "up" then return end
			local eingabe = isElement ( editFeld ) and dgsGetText ( editFeld ) or nil
			if knopf[2] ( eingabe ) ~= false then schliesseDialog () end
		end, false )
	end

	dgsSetInputMode ( "no_binds" )
	showCursor ( true )
end

-- Kurzform fuer die haeufigste Form: Ja/Nein an ein Server-Event.
local function frage ( titel, text, event, jaText, neinText )
	dialog ( titel, text, {
		{ jaText or "Annehmen", function () triggerServerEvent ( event, localPlayer, true ) end },
		{ neinText or "Ablehnen", function () triggerServerEvent ( event, localPlayer, false ) end },
	} )
end

---------------------------------------------------------------------
-- Ablauf: Antrag -> Annahme -> Nachname -> Bestaetigung -> Trauung
--         (Trauzeuge sagt zu) -> verheiratet
---------------------------------------------------------------------

-- 1) Antrag stellen (aus dem Interaktionsmenue heraus)
function showHeiratsantragFenster ( zielName )
	if not zielName then return end
	dialog ( "Heiratsantrag", "Moechtest du "..tostring(zielName).."\neinen Heiratsantrag machen?", {
		{ "Ja", function () triggerServerEvent ( "heiratsantragGUI", localPlayer, zielName ) end },
		{ "Nein", function () end },
	} )
end

-- 2) Antrag erhalten
addEvent ( "heiratsantragEmpfangen", true )
addEventHandler ( "heiratsantragEmpfangen", root, function ( antragsteller )
	frage ( "Heiratsantrag erhalten", tostring(antragsteller).." hat dir einen\nHeiratsantrag gemacht!", "heiratsantragAntwortGUI" )
end )

-- 3) Antrag angenommen -> Nachnamen vorschlagen
addEvent ( "heiratsantragAngenommen", true )
addEventHandler ( "heiratsantragAngenommen", root, function ()
	dialog ( "Gemeinsamer Nachname", "Schlage euren gemeinsamen\nNachnamen vor:", {
		{ "Vorschlagen", function ( eingabe )
			if not eingabe or eingabe == "" or eingabe:find ( "%s" ) then
				outputChatBox ( "Bitte einen Nachnamen ohne Leerzeichen eingeben!", 255, 150, 0 )
				return false
			end
			triggerServerEvent ( "nachnameGUI", localPlayer, eingabe )
		end },
	}, true )
end )

-- 4) Nachname vorgeschlagen -> bestaetigen
addEvent ( "nachnameEmpfangen", true )
addEventHandler ( "nachnameEmpfangen", root, function ( nachname )
	frage ( "Nachname vorgeschlagen", "Euer vorgeschlagener Nachname:\n\""..tostring(nachname).."\"", "nachnameAntwortGUI" )
end )

-- 5) Beide bereit -> Trauung am Altar ausloesen
addEvent ( "bereitZurTrauung", true )
addEventHandler ( "bereitZurTrauung", root, function ()
	dialog ( "Trauung", "Geht gemeinsam an den Altar\nin der Kirche und bestaetigt\nhier die Trauung.\n\nDanach waehlt ihr 1 bis 2\nTrauzeugen aus den Spielern\nam Altar aus - erst wenn alle\nzugesagt haben, seid ihr\nverheiratet.\n\nKosten: 50.000$ (25.000$ pro Person).", {
		{ "Trauung", function () triggerServerEvent ( "trauungGUI", localPlayer ) end },
	} )
end )

-- 5b) Trauzeugen auswaehlen: Liste aller Spieler am Altar, 1 bis max. 2 anklicken.
addEvent ( "trauzeugenAuswahlOeffnen", true )
addEventHandler ( "trauzeugenAuswahlOeffnen", root, function ( kandidaten, maximum )
	schliesseDialog ()

	local hoehe = TITELHOEHE + RAND + 40 + math.min ( #kandidaten, 8 ) * 22 + 20 + BUTTONHOEHE + RAND

	fenster = dgsCreateWindow ( screenwidth/2-BREITE/2, screenheight/2-hoehe/2, BREITE, hoehe,
		"Trauzeugen waehlen", false, nil,nil,nil,nil,nil, tocolor(16,29,61,255), nil, true )
	dgsWindowSetMovable ( fenster, false )
	dgsWindowSetSizable ( fenster, false )
	dgsBringToFront ( fenster )

	local hinweis = dgsCreateLabel ( RAND, RAND, BREITE-2*RAND, 34,
		"Waehlt 1 bis "..maximum.." Trauzeugen aus\n(Strg gedrueckt halten fuer zwei):", false, fenster )
	dgsSetFont ( hinweis, "default-bold" )
	dgsLabelSetHorizontalAlign ( hinweis, "center" )

	local listenHoehe = math.min ( #kandidaten, 8 ) * 22 + 20

	local liste = dgsCreateGridList ( RAND, RAND+40, BREITE-2*RAND, listenHoehe, false, fenster )
	dgsGridListSetSelectionMode ( liste, 1 )              -- 1 = zeilenweise
	dgsGridListSetMultiSelectionEnabled ( liste, true )   -- mehrere Zeilen erlaubt
	local spalte = dgsGridListAddColumn ( liste, "Spieler am Altar", 0.9 )

	for _, name in ipairs ( kandidaten ) do
		local zeile = dgsGridListAddRow ( liste )
		dgsGridListSetItemText ( liste, zeile, spalte, name, false, false )
	end

	local bestaetigen = dgsCreateButton ( RAND, RAND+40+listenHoehe+12,
		BREITE-2*RAND, BUTTONHOEHE, "Trauzeugen anfragen", false, fenster, _,_,_,_,_,_, ACC_N, ACC_H, ACC_P )

	addEventHandler ( "onDgsMouseClickUp", bestaetigen, function ( taste, status )
		if taste ~= "left" or status ~= "up" then return end

		-- dgsGridListGetSelectedItems liefert { {row=..., column=...}, ... };
		-- bei einer Spalte ist das genau ein Eintrag je markierter Zeile.
		local gewaehlt = {}
		for _, eintrag in ipairs ( dgsGridListGetSelectedItems ( liste ) or {} ) do
			-- Ohne Auswahl liefert DGS row = -1, und -1 ist in Lua wahr.
			if type ( eintrag.row ) == "number" and eintrag.row > 0 then
				local name = dgsGridListGetItemText ( liste, eintrag.row, spalte )
				if name and name ~= "" then
					gewaehlt[#gewaehlt+1] = name
				end
			end
		end

		if #gewaehlt < 1 then
			return outputChatBox ( "Waehle mindestens einen Trauzeugen aus der Liste!", 255, 150, 0 )
		end
		if #gewaehlt > maximum then
			return outputChatBox ( "Hoechstens "..maximum.." Trauzeugen moeglich!", 255, 150, 0 )
		end

		triggerServerEvent ( "trauzeugenGewaehltGUI", localPlayer, gewaehlt )
		schliesseDialog ()
	end, false )

	dgsSetInputMode ( "no_binds" )
	showCursor ( true )
end )

-- 5c) Anfrage an einen Dritten am Altar
addEvent ( "trauzeugeAnfrageEmpfangen", true )
addEventHandler ( "trauzeugeAnfrageEmpfangen", root, function ( name1, name2 )
	frage ( "Trauzeuge gesucht", tostring(name1).." und "..tostring(name2).."\nmoechten heiraten.\n\nMoechtest du ihr Trauzeuge sein?", "trauzeugeAntwortGUI" )
end )

-- 6) Fertig
addEvent ( "trauungAbgeschlossen", true )
addEventHandler ( "trauungAbgeschlossen", root, schliesseDialog )

-- 7) Ehe-Verwaltung (aus dem Interaktionsmenue, wenn man verheiratet ist)
function showEheVerwaltungFenster ()
	local trauzeuge = getElementData ( localPlayer, "trauzeuge" )
	if not trauzeuge or trauzeuge == "" then trauzeuge = "unbekannt" end

	local text = "Verheiratet mit:\n"..tostring ( getElementData ( localPlayer, "marwith" ) or "?" )
		.."\n\nGemeinsamer Nachname:\n"..tostring ( getElementData ( localPlayer, "nachname" ) or "?" )
		.."\n\nTrauzeuge:\n"..trauzeuge

	dialog ( "Ehe-Verwaltung", text, {
		{ "Scheiden lassen", function () triggerServerEvent ( "scheidungAntragGUI", localPlayer ) end },
		{ "Schliessen", function () end },
	} )
end

-- 7b) Eheregister: das Buch in der Kirche listet alle geschlossenen Ehen.
addEvent ( "eheregisterOeffnen", true )
addEventHandler ( "eheregisterOeffnen", root, function ( eintraege )
	schliesseDialog ()

	local w, h = 620, 420
	fenster = dgsCreateWindow ( screenwidth/2-w/2, screenheight/2-h/2, w, h,
		"Eheregister", false, nil,nil,nil,nil,nil, tocolor(16,29,61,255), nil, true )
	dgsWindowSetMovable ( fenster, false )
	dgsWindowSetSizable ( fenster, false )
	dgsBringToFront ( fenster )

	local kopf = dgsCreateLabel ( RAND, 12, w-2*RAND, 24,
		#eintraege == 1 and "1 geschlossene Ehe" or ( #eintraege.." geschlossene Ehen" ), false, fenster )
	dgsSetFont ( kopf, "default-bold" )
	dgsLabelSetHorizontalAlign ( kopf, "center" )

	local liste = dgsCreateGridList ( RAND, 44, w-2*RAND, h-TITELHOEHE-44-BUTTONHOEHE-24, false, fenster )
	local sDatum    = dgsGridListAddColumn ( liste, "Datum",    0.16 )
	local sPaar     = dgsGridListAddColumn ( liste, "Ehepaar",  0.34 )
	local sNachname = dgsGridListAddColumn ( liste, "Nachname", 0.20 )
	local sZeugen   = dgsGridListAddColumn ( liste, "Trauzeugen", 0.26 )

	for _, e in ipairs ( eintraege ) do
		local zeile = dgsGridListAddRow ( liste )
		dgsGridListSetItemText ( liste, zeile, sDatum,    e.datum,    false, false )
		dgsGridListSetItemText ( liste, zeile, sPaar,     e.paar,     false, false )
		dgsGridListSetItemText ( liste, zeile, sNachname, e.nachname, false, false )
		dgsGridListSetItemText ( liste, zeile, sZeugen,   e.zeugen,   false, false )
	end

	local zu = dgsCreateButton ( RAND, h-TITELHOEHE-BUTTONHOEHE-12, w-2*RAND, BUTTONHOEHE,
		"Buch zuklappen", false, fenster, _,_,_,_,_,_, ACC_N, ACC_H, ACC_P )
	addEventHandler ( "onDgsMouseClickUp", zu, function ( taste, status )
		if taste == "left" and status == "up" then schliesseDialog () end
	end, false )

	dgsSetInputMode ( "no_binds" )
	showCursor ( true )
end )

-- 8) Scheidungsantrag erhalten
addEvent ( "scheidungAntragEmpfangen", true )
addEventHandler ( "scheidungAntragEmpfangen", root, function ( partnerName )
	frage ( "Scheidungsantrag erhalten", tostring(partnerName).." moechte sich\nvon dir scheiden lassen.", "scheidungAntwortGUI" )
end )
