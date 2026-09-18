--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //
--
-- Tabelle "loggedin": hier steht, wer gerade im Spiel eingeloggt ist.
-- Das User-Panel (CP2-Reallife) liest daraus die Online-Liste.
--
-- BEHOBENER FEHLER (26.07.2026):
-- setPlayerLoggedIn machte nur ein UPDATE. Die Zeile fuer den Spieler wurde
-- aber nie angelegt - die dafuer vorgesehene Funktion
-- insertPlayerIntoLoggedIn ( mysql/mysql_functions.lua, Zeile 402 ) wird im
-- ganzen Script an keiner Stelle aufgerufen. Ein UPDATE auf eine nicht
-- vorhandene Zeile macht nichts, ohne Fehlermeldung.
--
-- Folge: die Tabelle blieb immer leer und im Panel stand
--   * "0 Spieler online", obwohl Spieler im Spiel waren
--   * bei den Fraktionen ueberall eine 0
--   * in den Einstellungen "Status im Spiel: Offline"
--
-- Jetzt wird die Zeile angelegt, falls sie fehlt (loggedin.UID ist
-- PRIMARY KEY, daher ON DUPLICATE KEY UPDATE).


function setPlayerLoggedIn ( name )

	local uid = playerUID[name]
	if not uid then return false end

	-- IP und Serial mitschreiben, wenn der Spieler erreichbar ist.
	local ip = "0.0.0.0"
	local serial = "ABCD1234ABCD1234"

	local spieler = getPlayerFromName ( name )
	if isElement ( spieler ) then
		ip = getPlayerIP ( spieler ) or ip
		serial = getPlayerSerial ( spieler ) or serial
	end

	local abfrage = "INSERT INTO loggedin (UID, Serial, IP, Loggedin) VALUES (?,?,?,?) "..
		"ON DUPLICATE KEY UPDATE Serial=VALUES(Serial), IP=VALUES(IP), Loggedin=VALUES(Loggedin)"

	if not dbExec ( handler, abfrage, uid, serial, ip, 1 ) then
		outputDebugString ( "[loggedin] Eintrag fuer "..tostring ( name ).." konnte nicht geschrieben werden.", 2 )
		return false
	end

	return true
end


function removePlayerFromLoggedIn ( name )

	local uid = playerUID[name]
	if not uid then return false end

	dbExec ( handler, "DELETE FROM loggedin WHERE UID=?", uid )
	return true
end


function deleteAllFromLoggedIn ()
	dbExec ( handler, "TRUNCATE TABLE loggedin" )
end
deleteAllFromLoggedIn ()


--[[
	Sicherheitsnetz:

	Verlaesst ein Spieler den Server auf einem Weg, bei dem
	removePlayerFromLoggedIn nicht aufgerufen wird (Absturz, Timeout,
	Server-Stop), bliebe er im Panel fuer immer "online".
	Deshalb wird hier bei jedem Verlassen zusaetzlich aufgeraeumt.
]]
addEventHandler ( "onPlayerQuit", getRootElement(),
	function ()
		local name = getPlayerName ( source )
		if playerUID[name] then
			dbExec ( handler, "DELETE FROM loggedin WHERE UID=?", playerUID[name] )
		end
	end
)
