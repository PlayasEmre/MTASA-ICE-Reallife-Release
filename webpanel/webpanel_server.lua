--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Web-Panel Schnittstelle (CP2-Reallife)         ||
--||   Version: 1.0                                   ||
--\\                                                  //
--
-- Diese Datei stellt die Funktionen bereit, die das User-Panel
-- (CP2-Reallife) per HTTP aufruft. Ohne sie funktionieren im Panel
-- die Live-Adminfunktionen nicht (Spielerliste, Kick, Screenshot, Logs).
--
-- Alle Funktionen sind in der meta.xml mit http="true" exportiert.
-- Aufrufweg: Panel -> http://<ip>:22005/ICE/call/<funktion>
--
-- WICHTIG:
--   * In der mtaserver.conf muessen <http_dos_exclude> und
--     <auth_serial_http_ip_exceptions> die IP des Webservers enthalten.
--   * Der im Panel eingetragene MTA-Account (MTA_USER / MTA_PASS)
--     braucht in der ACL das Recht, Funktionen dieser Resource aufzurufen.
--
-- Rueckgabewerte sind bewusst Strings:
--   "true"        = Aktion erfolgreich
--   alles andere  = Fehlermeldung, die das Panel direkt anzeigt


-- ####################################################################
-- Hilfsfunktionen
-- ####################################################################

-- Adminlevel eines Spielers aus der Datenbank lesen (auch wenn er offline ist).
local function webGetAdminlevel ( name )
	if not name or name == "" then return 0 end

	local uid = playerUID[name]
	if not uid then
		local res = dbPoll ( dbQuery ( handler, "SELECT UID FROM players WHERE Name=?", name ), -1 )
		if not ( res and res[1] ) then return 0 end
		uid = tonumber ( res[1]["UID"] )
	end

	local res = dbPoll ( dbQuery ( handler, "SELECT Adminlevel FROM userdata WHERE UID=?", uid ), -1 )
	if res and res[1] then
		return tonumber ( res[1]["Adminlevel"] ) or 0
	end
	return 0
end

-- UID zu einem Namen holen (auch offline).
local function webGetUID ( name )
	if not name or name == "" then return false end
	if playerUID[name] then return playerUID[name] end

	local res = dbPoll ( dbQuery ( handler, "SELECT UID FROM players WHERE Name=?", name ), -1 )
	if res and res[1] then
		return tonumber ( res[1]["UID"] )
	end
	return false
end

--[[
	Base64 fuer den Screenshot.

	MTA hat base64Encode entfernt ("no longer works, please manually change
	this to encodeString"). Neue Syntax: encodeString("base64", daten, {}).
	Das dritte Argument (options-Tabelle) ist bei encodeString Pflicht,
	auch wenn es fuer "base64" leer bleibt.
]]
function webBase64 ( daten )
	if not daten then return "" end

	local ergebnis = encodeString ( "base64", daten, {} )
	if ergebnis then return ergebnis end

	outputDebugString ( "[Web-Panel] Base64 nicht verfuegbar - Screenshot kann nicht uebertragen werden.", 2 )
	return ""
end

-- Schreibt die Aktion in ICE's eigenes Adminlog (vio_stored_files/logs/admin.log).
local function webLog ( text )
	if outputAdminLog then
		outputAdminLog ( "[Web-Panel] "..tostring ( text ) )
	end
end

-- Prueft, ob der Admin existiert und genug Rechte hat.
-- Rueckgabe: true  oder  false + Fehlermeldung
local function webCheckAdmin ( adminName, benoetigtesLevel )
	local lvl = webGetAdminlevel ( adminName )
	if lvl <= 0 then
		return false, "Der Account \""..tostring ( adminName ).."\" ist kein Admin."
	end
	if lvl < benoetigtesLevel then
		return false, "Dafuer wird Adminlevel "..benoetigtesLevel.." benoetigt (du hast "..lvl..")."
	end
	return true
end


-- ####################################################################
-- Spielerliste
-- ####################################################################

-- Das Panel erwartet "Name1|Name2|Name3|" und schneidet das letzte
-- Zeichen ab. Es werden nur eingeloggte Spieler ausgegeben.
function listAllPlayers ()

	local liste = ""
	for _, spieler in ipairs ( getElementsByType ( "player" ) ) do
		local eingeloggt = true
		if MtxGetElementData then
			eingeloggt = ( MtxGetElementData ( spieler, "loggedin" ) == 1 )
		end
		if eingeloggt then
			liste = liste..getPlayerName ( spieler ).."|"
		end
	end

	return liste
end


-- ####################################################################
-- Kick
-- ####################################################################

function kickPlayerWeb ( adminName, playerName, reason )

	local ok, fehler = webCheckAdmin ( adminName, 1 )
	if not ok then return fehler end

	if not reason or reason == "" then return "Es wurde kein Grund angegeben." end

	if string.lower ( playerName ) == string.lower ( adminName ) then
		return "Du kannst dich nicht selbst kicken."
	end

	local ziel = getPlayerFromName ( playerName )
	if not isElement ( ziel ) then return "Dieser Spieler ist nicht online." end

	if webGetAdminlevel ( playerName ) >= webGetAdminlevel ( adminName ) then
		return "Dieser Spieler hat ein gleich hohes oder hoeheres Adminlevel."
	end

	outputChatBox ( playerName.." wurde von "..adminName.." gekickt! (Grund: "..reason..")", getRootElement(), 255, 0, 0 )
	webLog ( adminName.." hat "..playerName.." gekickt. Grund: "..reason )
	kickPlayer ( ziel, "Gekickt von "..adminName..": "..reason )

	return "true"
end


-- ####################################################################
-- Permanenter Ban
-- ####################################################################

function permaBanWeb ( adminName, playerName, reason )

	local ok, fehler = webCheckAdmin ( adminName, 2 )
	if not ok then return fehler end

	if not reason or reason == "" then return "Es wurde kein Grund angegeben." end

	if string.lower ( playerName ) == string.lower ( adminName ) then
		return "Du kannst dich nicht selbst bannen."
	end

	local uid = webGetUID ( playerName )
	if not uid then return "Diesen Spieler gibt es nicht." end

	if webGetAdminlevel ( playerName ) >= webGetAdminlevel ( adminName ) then
		return "Dieser Spieler hat ein gleich hohes oder hoeheres Adminlevel."
	end

	local adminUID = webGetUID ( adminName ) or 0
	local ziel = getPlayerFromName ( playerName )

	local ip = "0.0.0.0"
	local serial = ""
	if isElement ( ziel ) then
		ip = getPlayerIP ( ziel )
		serial = getPlayerSerial ( ziel )
	else
		local res = dbPoll ( dbQuery ( handler, "SELECT IP, Serial FROM players WHERE UID=?", uid ), -1 )
		if res and res[1] then
			ip = res[1]["IP"] or "0.0.0.0"
			serial = res[1]["Serial"] or ""
		end
	end

	-- ban.UID ist PRIMARY KEY -> vorhandenen Eintrag ueberschreiben.
	-- (MTA benutzt Lua 5.1, dort gibt es keine Zeilenfortsetzung in Strings,
	--  deshalb wird die Abfrage mit .. zusammengesetzt.)
	local banQuery = "INSERT INTO ban (UID, AdminUID, Grund, Datum, IP, Serial, STime) VALUES (?,?,?,?,?,?,?) "..
		"ON DUPLICATE KEY UPDATE AdminUID=VALUES(AdminUID), Grund=VALUES(Grund), Datum=VALUES(Datum), "..
		"IP=VALUES(IP), Serial=VALUES(Serial), STime=VALUES(STime)"

	dbExec ( handler, banQuery, uid, adminUID, string.sub ( reason, 1, 100 ), timestamp(), ip, serial, 0 )

	outputChatBox ( playerName.." wurde von "..adminName.." permanent gebannt! (Grund: "..reason..")", getRootElement(), 255, 0, 0 )
	webLog ( adminName.." hat "..playerName.." permanent gebannt. Grund: "..reason )

	if isElement ( ziel ) then
		kickPlayer ( ziel, "Permanent gebannt von "..adminName..": "..reason )
	end

	return "true"
end


-- ####################################################################
-- Zeitban
-- ####################################################################

function timeBanWeb ( adminName, playerName, time, reason )

	local ok, fehler = webCheckAdmin ( adminName, 2 )
	if not ok then return fehler end

	if not reason or reason == "" then return "Es wurde kein Grund angegeben." end

	local stunden = tonumber ( time )
	if not stunden or stunden <= 0 then return "Ungueltige Ban-Zeit." end

	if string.lower ( playerName ) == string.lower ( adminName ) then
		return "Du kannst dich nicht selbst zeitbannen."
	end

	local uid = webGetUID ( playerName )
	if not uid then return "Diesen Spieler gibt es nicht." end

	if webGetAdminlevel ( playerName ) >= webGetAdminlevel ( adminName ) then
		return "Dieser Spieler hat ein gleich hohes oder hoeheres Adminlevel."
	end

	local adminUID = webGetUID ( adminName ) or 0
	local ziel = getPlayerFromName ( playerName )

	local serial = ""
	local res = dbPoll ( dbQuery ( handler, "SELECT Serial FROM players WHERE UID=?", uid ), -1 )
	if res and res[1] then serial = res[1]["Serial"] or "" end

	-- STime: gleiche Rechnung wie /timeban ingame (usefull/utility.lua)
	local sec = getSecTime ( stunden )

	local banQuery = "INSERT INTO ban (UID, AdminUID, Grund, Datum, IP, Serial, STime) VALUES (?,?,?,?,?,?,?) "..
		"ON DUPLICATE KEY UPDATE AdminUID=VALUES(AdminUID), Grund=VALUES(Grund), Datum=VALUES(Datum), "..
		"IP=VALUES(IP), Serial=VALUES(Serial), STime=VALUES(STime)"

	dbExec ( handler, banQuery, uid, adminUID, string.sub ( reason, 1, 100 ), timestamp(), '0.0.0.0', serial, sec )

	outputChatBox ( playerName.." wurde von "..adminName.." fuer "..stunden.." Stunden gebannt! (Grund: "..reason..")", getRootElement(), 255, 0, 0 )
	webLog ( adminName.." hat "..playerName.." fuer "..stunden.." Stunden gebannt. Grund: "..reason )

	if isElement ( ziel ) then
		kickPlayer ( ziel, "Gebannt von "..adminName.." fuer "..stunden.." Stunden: "..reason )
	end

	return "true"
end


-- ####################################################################
-- Entbannen
-- ####################################################################

function unbanWeb ( adminName, playerName )

	local ok, fehler = webCheckAdmin ( adminName, 3 )
	if not ok then return fehler end

	local uid = webGetUID ( playerName )
	if not uid then return "Diesen Spieler gibt es nicht." end

	local vorhanden = dbPoll ( dbQuery ( handler, "SELECT UID FROM ban WHERE UID=?", uid ), -1 )
	if not ( vorhanden and vorhanden[1] ) then
		return "Fuer diesen Spieler liegt kein Ban vor."
	end

	dbExec ( handler, "DELETE FROM ban WHERE UID=?", uid )
	webLog ( adminName.." hat "..playerName.." entbannt." )

	return "true"
end


-- ####################################################################
-- Screenshot
-- ####################################################################

local screenErgebnis = nil
local screenSpieler = nil

function makePlayerScreenshot ( playerName )

	local ziel = getPlayerFromName ( playerName )
	if not isElement ( ziel ) then return "Dieser Spieler ist nicht online." end

	screenErgebnis = nil
	screenSpieler = playerName

	-- 1024x768, Qualitaet 40 - reicht fuer die Anzeige im Panel.
	takePlayerScreenShot ( ziel, 1024, 768, "webpanel", 40 )

	-- Genau dieser Text wird vom Panel erwartet, damit es zu pollen beginnt.
	return "Einen moment..."
end

addEventHandler ( "onPlayerScreenShot", getRootElement(),
	function ( theResource, status, imageData, timeStamp, tag )

		if tag ~= "webpanel" then return end

		if status == "ok" and imageData and imageData ~= "" then
			screenErgebnis = "img|"..webBase64 ( imageData )
			webLog ( "Screenshot von "..getPlayerName ( source ).." erstellt." )
		elseif status == "disabled" then
			screenErgebnis = "err|Der Spieler hat Screenshots in seinen Einstellungen deaktiviert."
		elseif status == "minimized" then
			screenErgebnis = "err|Das Spielfenster des Spielers ist minimiert."
		else
			screenErgebnis = "err|Screenshot fehlgeschlagen ("..tostring ( status )..")."
		end
	end
)

function getScreenResult ()

	-- Noch kein Ergebnis -> leerer String, das Panel fragt dann erneut.
	if not screenErgebnis then return "" end

	local ergebnis = screenErgebnis
	screenErgebnis = nil
	screenSpieler = nil
	return ergebnis
end


-- ####################################################################
-- Beta-Code erstellen
-- ####################################################################

-- Nutzt dieselbe Erzeugungsfunktion wie /beta code im Spiel
-- ( beta/beta_server.lua:erstelleEinenBetaCode ) - kein duplizierter Code.
-- Erfordert event.isBeta = true ( settings/settings.lua ), sonst gibt es
-- gar nichts einzuloesen.
function createBetaCodeWeb ( adminName )

	local ok, fehler = webCheckAdmin ( adminName, 3 )
	if not ok then return fehler end

	if not event or not event.isBeta then
		return "Die Beta ist gerade nicht aktiv (event.isBeta = false) - es wird kein Code benoetigt."
	end

	if not erstelleEinenBetaCode then
		return "Beta-System nicht geladen (beta/beta_server.lua fehlt?)."
	end

	local code = erstelleEinenBetaCode ( adminName )
	if not code then
		return "Fehler beim Erstellen des Codes."
	end

	webLog ( adminName.." hat per Web-Panel den Beta-Code "..code.." erstellt." )

	return "true|"..code
end


-- ####################################################################
-- Nachrichten
-- ####################################################################

function sendMsgToAdmins ( msg )

	if not msg or msg == "" then return "Keine Nachricht angegeben." end

	local anzahl = 0
	for _, spieler in ipairs ( getElementsByType ( "player" ) ) do
		if webGetAdminlevel ( getPlayerName ( spieler ) ) > 0 then
			outputChatBox ( "[Web-Panel] "..msg, spieler, 255, 194, 14 )
			anzahl = anzahl + 1
		end
	end

	return "true"
end

function sendMsgToPlayer ( adminName, playerName, msg )

	local ok, fehler = webCheckAdmin ( adminName, 1 )
	if not ok then return fehler end

	if not msg or msg == "" then return "Keine Nachricht angegeben." end

	local ziel = getPlayerFromName ( playerName )
	if not isElement ( ziel ) then return "Dieser Spieler ist nicht online." end

	outputChatBox ( "[Admin "..adminName.."] "..msg, ziel, 255, 194, 14 )
	webLog ( adminName.." hat "..playerName.." geschrieben: "..msg )

	return "true"
end


-- ####################################################################
-- Logs auslesen
-- ####################################################################

-- ICE schreibt seine Logs als Dateien nach vio_stored_files/logs/<name>.log
-- (admin/allround_log.lua). Hier werden die letzten Zeilen zurueckgegeben.
function getLogContent ( logname )

	if not logname or logname == "" then return "Kein Log angegeben." end

	-- Nur Buchstaben, Zahlen und - _ zulassen (kein ../ o.ae.)
	if string.find ( logname, "[^%w%-_]" ) then
		return "Ungueltiger Logname."
	end

	local pfad = "/vio_stored_files/logs/"..logname..".log"
	if not fileExists ( pfad ) then
		return "Fuer \""..logname.."\" existiert noch keine Logdatei."
	end

	local datei = fileOpen ( pfad, true )
	if not datei then return "Die Logdatei konnte nicht geoeffnet werden." end

	local groesse = fileGetSize ( datei )
	local maximal = 200000 -- ~200 KB, damit die Antwort nicht zu gross wird

	if groesse > maximal then
		fileSetPos ( datei, groesse - maximal )
	end

	local inhalt = fileRead ( datei, maximal )
	fileClose ( datei )

	if not inhalt or inhalt == "" then return "Das Log ist leer." end

	-- Neueste Zeilen zuerst anzeigen.
	local zeilen = split ( inhalt, string.byte ( "\n" ) )
	local umgedreht = {}
	for i = #zeilen, 1, -1 do
		umgedreht[#umgedreht+1] = zeilen[i]
	end

	return table.concat ( umgedreht, "\n" )
end


-- ####################################################################
-- Live-Daten fuer das Web-Panel
-- ####################################################################

--[[
	Warum das noetig ist:

	ICE haelt alle Spielerdaten waehrend des Spielens im Speicher
	(MtxSetElementData) und schreibt sie erst beim Ausloggen in die
	Datenbank (datasave_remote in register_login_server.lua).

	Das Web-Panel liest aber die Datenbank. Ergebnis: wer gerade spielt,
	hatte im Panel veraltete Werte - z.B. "keine Fraktion", altes Geld,
	alte Spielzeit.

	Dieser Timer ruft in regelmaessigen Abstaenden ICE's eigene
	Speicherfunktion fuer alle eingeloggten Spieler auf. Danach stimmen die
	Werte im Panel. Es wird nichts Neues geschrieben, was ICE nicht
	sowieso beim Ausloggen schreiben wuerde.
]]

WEBPANEL_SYNC_SEKUNDEN = 150		-- Abstand in Sekunden (Panel-Daten duerfen ein paar Minuten alt sein, spart pro Zyklus mehrere DB-Roundtrips je Online-Spieler)

--[[
	Stellt sicher, dass der Spieler in der Tabelle "loggedin" als eingeloggt
	steht. Normalerweise macht das setPlayerLoggedIn (loggedin_mysql.lua).

	Das hier ist nur das Sicherheitsnetz: Spieler, die schon vor einem
	Script-Neustart eingeloggt waren, oder ein verpasster Eintrag landen so
	trotzdem in der Online-Liste des Panels.
]]
function webpanelLoggedinSichern ( spieler )

	local name = getPlayerName ( spieler )
	local uid = playerUID[name]
	if not uid then return false end

	local ip = getPlayerIP ( spieler ) or "0.0.0.0"
	local serial = getPlayerSerial ( spieler ) or "ABCD1234ABCD1234"

	local abfrage = "INSERT INTO loggedin (UID, Serial, IP, Loggedin) VALUES (?,?,?,?) "..
		"ON DUPLICATE KEY UPDATE Serial=VALUES(Serial), IP=VALUES(IP), Loggedin=VALUES(Loggedin)"

	dbExec ( handler, abfrage, uid, serial, ip, 1 )
	return true
end

function webpanelSyncJetzt ()

	local anzahl = 0
	for _, spieler in ipairs ( getElementsByType ( "player" ) ) do

		local eingeloggt = false
		if MtxGetElementData then
			eingeloggt = ( tonumber ( MtxGetElementData ( spieler, "loggedin" ) ) == 1 )
		end

		if eingeloggt then
			-- 1) Online-Status fuer die Panel-Liste
			pcall ( webpanelLoggedinSichern, spieler )

			-- 2) Spielerdaten (Fraktion, Geld, Spielzeit, ...) in die Datenbank
			-- pcall: ein Fehler bei einem Spieler soll den Timer nicht stoppen.
			if datasave_remote then
				local ok, fehler = pcall ( datasave_remote, spieler )
				if not ok then
					outputDebugString ( "[Web-Panel] Sync-Fehler bei "..getPlayerName ( spieler )..": "..tostring ( fehler ), 2 )
				end
			end

			anzahl = anzahl + 1
		end
	end

	return anzahl
end

setTimer ( webpanelSyncJetzt, WEBPANEL_SYNC_SEKUNDEN * 1000, 0 )

--[[
	Sofort reagieren, statt bis zum naechsten Timer zu warten.

	"loggedin" = 1  -> der Spieler hat sich gerade im Spiel angemeldet.
	                   Dann sofort die Online-Liste und die Spielerdaten
	                   schreiben, damit das Panel ihn direkt anzeigt.
	"fraktion" / "rang" / "premium" -> Werte, die man im Panel sofort
	                   sehen will (Fraktionswechsel, Premium gekauft).
]]
addEventHandler ( "onElementDataChange", getRootElement(),
	function ( datenName, alterWert )

		-- Dieser Handler haengt an root und laeuft damit bei JEDER Datenaenderung
		-- an JEDEM Element im Spiel. Deshalb zuerst der billige Namensvergleich -
		-- getElementType lief vorher im Normalfall statt in der Ausnahme.
		if datenName ~= "loggedin" and datenName ~= "fraktion" and datenName ~= "rang"
			and datenName ~= "premium" and datenName ~= "PremiumData" then
			return
		end

		if not isElement ( source ) then return end
		if getElementType ( source ) ~= "player" then return end

		if datenName == "loggedin" then
			if tonumber ( MtxGetElementData ( source, "loggedin" ) ) == 1 then
				pcall ( webpanelLoggedinSichern, source )
				if datasave_remote then pcall ( datasave_remote, source ) end
			end
			return
		end

		if datenName ~= "fraktion" and datenName ~= "rang"
			and datenName ~= "premium" and datenName ~= "PremiumData" then
			return
		end

		if MtxGetElementData and tonumber ( MtxGetElementData ( source, "loggedin" ) ) == 1 then
			if datasave_remote then pcall ( datasave_remote, source ) end
		end
	end
)

-- Manuell ausloesbar: /websync  (nur fuer Admins)
addCommandHandler ( "websync",
	function ( spieler )
		if webGetAdminlevel ( getPlayerName ( spieler ) ) < 1 then
			return
		end
		local anzahl = webpanelSyncJetzt ()
		outputChatBox ( "#4da3ff[Web-Panel] #ffffffDaten von "..anzahl.." Spieler(n) in die Datenbank geschrieben.", spieler, 255, 255, 255, true )
	end
)


outputDebugString ( "[Web-Panel] Schnittstelle geladen (Spielerliste, Kick, Ban, Screenshot, Logs, Live-Sync alle "..WEBPANEL_SYNC_SEKUNDEN.."s)." )
