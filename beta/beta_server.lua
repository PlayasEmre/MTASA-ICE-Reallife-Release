--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--\\                                                  //

-- Beta-Zugangscode-System. Greift VOR dem Login/Registrieren ( siehe der
-- Aufruf in register_login_server.lua, addEventHandler "regcheck" ), gebunden
-- an den MTA-Serial statt an den Account - so funktioniert es auch fuer noch
-- unregistrierte Spieler, bei denen es ja noch kein UID gibt.

-- Prueft, ob dieser Serial bereits dauerhaften Beta-Zugang hat.
function hatBetaZugang ( serial )
	local ergebnis = dbQueryCoro ( "SELECT Serial FROM beta_zugang WHERE ??=?", "Serial", serial )
	return ergebnis and ergebnis[1] and true or false
end

-- Wird von regcheck_func (register_login_server.lua) vor dem eigentlichen
-- Login/Registrieren aufgerufen. Gibt true zurueck, wenn der Spieler HIER
-- blockiert wird ( Beta-Code-Fenster wurde gezeigt, regcheck_func darf nicht
-- weiterlaufen ). Gibt false zurueck, wenn er normal weiter darf.
function pruefeBetaSperre ( player )
	if not event.isBeta then return false end
	if not isElement ( player ) then return true end

	local serial = getPlayerSerial ( player )
	if hatBetaZugang ( serial ) then return false end

	setElementFrozen ( player, true )
	toggleAllControls ( player, false )
	triggerClientEvent ( player, "ShowBetaCodeWindow", getRootElement() )
	return true
end

-- Serverseitige Bremse: das Client-GUI ( beta/beta_client.lua ) sperrt den
-- Knopf zwar schon selbst kurz, aber ein manipulierter Client kann
-- "betaCodeEinloesen" trotzdem beliebig oft direkt per triggerServerEvent
-- ansprechen ( addEvent(...,true) erlaubt genau das, das ist so gewollt -
-- sonst koennte das echte GUI den Server gar nicht erreichen ). Ohne eigene
-- Bremse liesse sich der Server so mit Datenbankabfragen fluten. Der riesige
-- Codeschluessel ( 33^8, siehe unten ) macht reines Erraten zwar praktisch
-- aussichtslos, die Drosselung schuetzt aber trotzdem vor Spam/DoS und macht
-- ungewoehnlich viele Fehlversuche fuer Admins sichtbar.
local letzterVersuch = {}   -- Spieler -> Tickcount des letzten Versuchs
local fehlversuche = {}     -- Spieler -> { anzahl = n, seit = Tickcount }
local BETA_MIN_ABSTAND = 1500        -- ms zwischen zwei Versuchen
local BETA_MAX_FEHLVERSUCHE = 5      -- danach kurzzeitig gesperrt
local BETA_SPERRDAUER = 60000        -- ms

-- Admins testen den Beta-Code-Ablauf oft mehrfach schnell hintereinander
-- ( Code erstellen, einloesen, naechsten testen, ... ) und laufen dabei
-- leicht in die Drosselung/Sperre oben hinein. An dieser Stelle im Ablauf
-- ( VOR dem eigentlichen Login, siehe pruefeBetaSperre ) ist "adminlvl" noch
-- nicht geladen - isAdminLevel waere hier also immer false. Deshalb wird der
-- Account stattdessen direkt per Namen in der DB nachgeschlagen.
local function istBetaAdmin ( player )
	if not isElement ( player ) then return false end
	local pname = getPlayerName ( player )
	if not playerUID[pname] then return false end
	local ergebnis = dbQueryCoro ( "SELECT Adminlevel FROM userdata WHERE ??=?", "UID", playerUID[pname] )
	local level = ergebnis and ergebnis[1] and tonumber ( ergebnis[1]["Adminlevel"] ) or 0
	return level >= 3
end

addEvent ( "betaCodeEinloesen", true )
addEventHandler ( "betaCodeEinloesen", getRootElement(), function ( eingabe )
	local player = client
	if not isElement ( player ) then return end
	if not event.isBeta then return end

	-- Erst die billige Zeitbremse, dann erst die Admin-Abfrage: istBetaAdmin
	-- fragt die Datenbank, und stand die Abfrage vor der Bremse, liess sich
	-- der Server durch blosses Spammen dieses Events mit Abfragen fluten.
	local jetzt = getTickCount ()
	local zuSchnell = letzterVersuch[player] and ( jetzt - letzterVersuch[player] ) < BETA_MIN_ABSTAND
	local sperre = fehlversuche[player]
	local gesperrt = sperre and sperre.anzahl >= BETA_MAX_FEHLVERSUCHE and ( jetzt - sperre.seit ) < BETA_SPERRDAUER

	local istAdmin = false
	if zuSchnell or gesperrt then
		-- Nur in diesem Fall lohnt die Nachfrage, ob es ein Admin ist.
		istAdmin = istBetaAdmin ( player )
		if not isElement ( player ) then return end
	end

	if not istAdmin then
		if gesperrt then
			triggerClientEvent ( player, "BetaCodeFehler", player, "Zu viele Fehlversuche. Bitte kurz warten." )
			return
		end
		if zuSchnell then
			return
		end
		letzterVersuch[player] = jetzt
	end

	-- Zaehlt einen Fehlversuch und schickt die Meldung ans Fenster. Bei
	-- BETA_MAX_FEHLVERSUCHE greift beim naechsten Versuch die Sperre oben.
	local function fehler ( text )
		local s = fehlversuche[player]
		if not s or jetzt - s.seit > BETA_SPERRDAUER then
			s = { anzahl = 0, seit = jetzt }
			fehlversuche[player] = s
		end
		s.anzahl = s.anzahl + 1
		if s.anzahl == BETA_MAX_FEHLVERSUCHE and isElement ( player ) then
			outputLog ( getPlayerName ( player ).." haeufig falsche Beta-Codes versucht ( Serial "..getPlayerSerial ( player ).." )", "beta" )
		end
		triggerClientEvent ( player, "BetaCodeFehler", player, text )
	end

	local code = tostring ( eingabe or "" ):gsub ( "%s+", "" ):upper ()
	if #code < 4 then
		fehler ( "Bitte einen Code eingeben." )
		return
	end

	local serial = getPlayerSerial ( player )
	if hatBetaZugang ( serial ) then
		-- Zwischen Anzeige des Fensters und Absenden koennte der Serial bereits
		-- anderswo freigeschaltet worden sein ( z.B. durch einen Admin ) - dann
		-- einfach durchlassen statt einen Code zu verlangen.
		triggerClientEvent ( player, "DisableBetaCodeWindow", player )
		return
	end

	local ergebnis = dbQueryCoro ( "SELECT Code, Benutzt FROM beta_codes WHERE ??=?", "Code", code )
	local eintrag = ergebnis and ergebnis[1]

	if not eintrag then
		fehler ( "Dieser Code existiert nicht." )
		return
	end
	if tonumber ( eintrag["Benutzt"] ) == 1 then
		fehler ( "Dieser Code wurde bereits eingeloest." )
		return
	end

	-- ErstelltAm/BenutztAm/SeitWann sind DATETIME-Spalten ( echtes Datum in der
	-- DB statt einer nackten Unix-Zahl ) - NOW() steht deshalb direkt im SQL-
	-- Text statt als gebundener Wert, ein Platzhalter wuerde nur den Text
	-- "NOW()" einfuegen statt ihn auszuwerten.
	dbExec ( handler, "UPDATE beta_codes SET ??=?, ??=?, BenutztAm=NOW() WHERE ??=?",
		"Benutzt", 1, "BenutztVonSerial", serial, "Code", code )
	dbExec ( handler, "INSERT INTO beta_zugang ( Serial, SeitWann ) VALUES ( ?, NOW() )", serial )

	fehlversuche[player] = nil
	outputLog ( ( isElement ( player ) and getPlayerName ( player ) or "?" )..
		" hat den Beta-Code "..code.." eingeloest ( Serial "..serial.." )", "beta" )

	if isElement ( player ) then
		triggerClientEvent ( player, "DisableBetaCodeWindow", player )
		setElementFrozen ( player, false )
	end
end )

addEventHandler ( "onPlayerQuit", getRootElement(), function ()
	letzterVersuch[source] = nil
	fehlversuche[source] = nil
end )

-- Findet den Serial zu einem Namen: bevorzugt online ( aktuellster Serial ),
-- sonst den zuletzt in der DB gespeicherten Serial des Accounts - damit auch
-- Zugang vergeben/entzogen werden kann, waehrend der Spieler offline ist.
local function findeSerialFuerNamen ( name )
	local online = getPlayerFromName ( name )
	if online then return getPlayerSerial ( online ) end

	local ergebnis = dbQueryCoro ( "SELECT Serial FROM players WHERE ??=?", "Name", name )
	if ergebnis and ergebnis[1] and ergebnis[1]["Serial"] and ergebnis[1]["Serial"] ~= "" then
		return ergebnis[1]["Serial"]
	end
	return nil
end

-- Eigentuemer-Serial: darf /beta IMMER benutzen, auch ohne Adminrechte im
-- Account - z.B. falls kein Datenbankzugriff besteht, um sich selbst Admin
-- zu geben, oder das Adminlevel aus einem anderen Grund fehlt. Bewusst NUR
-- hier lokal geprueft ( nicht global in admin/admincmds.lua:isAdminLevel/
-- getAdminLevel ) - das global zu machen hatte vorher andere Stellen im Code
-- zum Abstuerzen gebracht, die "adminlvl" direkt lesen. Diese lokale Variante
-- hat darauf keinen Einfluss.
local EIGENTUEMER_SERIAL = "5902B1F77F6A4625C7E935798BD77694"

local function darfBetaBenutzen ( player )
	if isElement ( player ) and getPlayerSerial ( player ) == EIGENTUEMER_SERIAL then
		return true
	end
	return isAdminLevel ( player, 3 )
end

-- Erstellt einen einzelnen zufaelligen Beta-Code und traegt ihn in die DB
-- ein. Gibt den Code zurueck, oder nil bei einem DB-Fehler. Eigene globale
-- Funktion statt inline im Befehl, damit auch andere Aufrufer ( Web-Panel:
-- webpanel/webpanel_server.lua:createBetaCodeWeb ) dieselbe Logik nutzen,
-- statt sie zu duplizieren.
-- Bei schnell aufeinanderfolgenden Aufrufen ( z.B. Web-Panel-Button mehrfach
-- geklickt ) kann math.random() denselben Code liefern wie kurz zuvor -
-- deshalb wird VOR dem Einfuegen geprueft, ob der Code schon existiert, und
-- im Kollisionsfall einfach ein neuer gewuerfelt, statt den Fehler von
-- dbExec ( doppelter PRIMARY KEY ) ins Log laufen zu lassen.
function erstelleEinenBetaCode ( erstelltVon )
	local zeichen = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" -- ohne verwechselbare Zeichen (0/O, 1/I)

	for versuch = 1, 10 do
		local code = ""
		for i = 1, 8 do
			local pos = math.random ( 1, #zeichen )
			code = code..zeichen:sub ( pos, pos )
		end

		local vorhanden = dbQueryCoro ( "SELECT Code FROM beta_codes WHERE ??=?", "Code", code )
		if not ( vorhanden and vorhanden[1] ) then
			if dbExec ( handler, "INSERT INTO beta_codes ( Code, ErstelltVon, ErstelltAm ) VALUES ( ?, ?, NOW() )",
				code, erstelltVon ) then
				return code
			end
		end
	end

	return nil
end

-- Ein einziger Admin-Befehl fuer alles rund um die Beta statt vieler
-- einzelner ( /beta code [anzahl], /beta status, /beta grant <Name>,
-- /beta revoke <Name> ) - Level-Schwelle wie bei anderen sicherheits-
-- relevanten Admin-Befehlen ( admin/admincmds.lua:/tpto ).
addCommandHandler ( "beta", function ( player, cmd, unterbefehl, arg )
	if not darfBetaBenutzen ( player ) then
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 0, 191, 255 )
		return
	end

	unterbefehl = unterbefehl and unterbefehl:lower ()

	if unterbefehl == "code" then
		local anzahl = math.min ( tonumber ( arg ) or 1, 20 )
		local erstellt = {}

		for n = 1, anzahl do
			local code = erstelleEinenBetaCode ( getPlayerName ( player ) )
			if code then
				erstellt[#erstellt + 1] = code
			end
		end

		if #erstellt > 0 then
			outputChatBox ( "Neue"..( #erstellt > 1 and "" or "r" ).." Beta-Code"..( #erstellt > 1 and "s" or "" )..": "..table.concat ( erstellt, ", " ), player, 0, 253, 0 )
			outputChatBox ( "Jeder Code ist einmal einloesbar, ohne Ablaufdatum.", player, 200, 200, 0 )
			outputAdminLog ( getPlayerName ( player ).." hat "..#erstellt.." Beta-Code(s) erstellt: "..table.concat ( erstellt, ", " ) )
		else
			outputChatBox ( "Fehler beim Erstellen der Codes.", player, 200, 0, 0 )
		end

	elseif unterbefehl == "grant" then
		if not arg then
			outputChatBox ( "Gebrauch: /beta grant <Name>", player, 200, 200, 0 )
			return
		end
		local serial = findeSerialFuerNamen ( arg )
		if not serial then
			outputChatBox ( "Spieler/Account '"..arg.."' nicht gefunden.", player, 200, 0, 0 )
			return
		end
		if hatBetaZugang ( serial ) then
			outputChatBox ( arg.." hat bereits Beta-Zugang.", player, 200, 200, 0 )
			return
		end
		dbExec ( handler, "INSERT INTO beta_zugang ( Serial, SeitWann ) VALUES ( ?, NOW() )", serial )
		outputChatBox ( "Beta-Zugang fuer "..arg.." freigeschaltet.", player, 0, 253, 0 )
		outputAdminLog ( getPlayerName ( player ).." hat "..arg.." per /beta grant Beta-Zugang gegeben ( Serial "..serial.." )" )
		local online = getPlayerFromName ( arg )
		if online and isElement ( online ) then
			outputChatBox ( "Du hast Beta-Zugang erhalten.", online, 0, 253, 0 )
		end

	elseif unterbefehl == "revoke" then
		if not arg then
			outputChatBox ( "Gebrauch: /beta revoke <Name>", player, 200, 200, 0 )
			return
		end
		local serial = findeSerialFuerNamen ( arg )
		if not serial then
			outputChatBox ( "Spieler/Account '"..arg.."' nicht gefunden.", player, 200, 0, 0 )
			return
		end
		if not hatBetaZugang ( serial ) then
			outputChatBox ( arg.." hat sowieso keinen Beta-Zugang.", player, 200, 200, 0 )
			return
		end
		dbExec ( handler, "DELETE FROM beta_zugang WHERE ??=?", "Serial", serial )
		outputChatBox ( "Beta-Zugang fuer "..arg.." entzogen ( wirkt ab dem naechsten Verbinden ).", player, 0, 253, 0 )
		outputAdminLog ( getPlayerName ( player ).." hat "..arg.." per /beta revoke den Beta-Zugang entzogen ( Serial "..serial.." )" )
		local online = getPlayerFromName ( arg )
		if online and isElement ( online ) then
			outputChatBox ( "Dir wurde der Beta-Zugang entzogen. Das gilt erst ab deinem naechsten Verbinden.", online, 200, 0, 0 )
		end

	elseif unterbefehl == "status" or not unterbefehl then
		outputChatBox ( "=== Beta-Status ===", player, 180, 0, 220 )
		outputChatBox ( "Beta aktiv: "..( event.isBeta and "JA" or "NEIN, alle koennen normal spielen" ), player, 255, 140, 0 )
		if event.isBeta then
			local offen = dbQueryCoro ( "SELECT COUNT(*) AS n FROM beta_codes WHERE ??=?", "Benutzt", 0 )
			local benutzt = dbQueryCoro ( "SELECT COUNT(*) AS n FROM beta_codes WHERE ??=?", "Benutzt", 1 )
			local zugaenge = dbQueryCoro ( "SELECT COUNT(*) AS n FROM beta_zugang" )
			outputChatBox ( "Offene Codes: "..( offen and offen[1] and offen[1]["n"] or 0 ), player, 255, 140, 0 )
			outputChatBox ( "Eingeloeste Codes: "..( benutzt and benutzt[1] and benutzt[1]["n"] or 0 ), player, 255, 140, 0 )
			outputChatBox ( "Serials mit Zugang: "..( zugaenge and zugaenge[1] and zugaenge[1]["n"] or 0 ), player, 255, 140, 0 )
		end
		outputChatBox ( "Befehle: /beta code [anzahl] | /beta grant <Name> | /beta revoke <Name> | /beta status", player, 200, 200, 0 )

	else
		outputChatBox ( "Gebrauch: /beta code [anzahl] | /beta grant <Name> | /beta revoke <Name> | /beta status", player, 200, 200, 0 )
	end
end )

-- Erinnert einloggende Admins ( sobald ihr Adminlevel geladen ist ) daran,
-- wie das Beta-System bedient wird - damit man dafuer nicht extra nachfragen
-- muss. Nur einmal je Login, nur solange die Beta ueberhaupt aktiv ist.
addEventHandler ( "onPlayerLogin", root, function ()
	if not event.isBeta then return end
	local player = source
	setTimer ( function ()
		if isElement ( player ) and isAdminLevel ( player, 3 ) then
			outputChatBox ( "Beta ist aktiv. /beta zeigt alle Befehle dazu.", player, 255, 140, 0 )
		end
	end, 3000, 1 )
end )
