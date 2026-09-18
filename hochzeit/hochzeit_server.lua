--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Heiratssystem, komplett per Klick-Fenster (siehe hochzeit_client.lua):
--   Antrag -> Partner nimmt an -> Nachname vorschlagen -> Partner bestaetigt
--   -> beide an den Altar, einer loest die Trauung aus -> ein dritter Spieler
--   am Altar wird als Trauzeuge gefragt -> dessen Zusage schliesst die Ehe ab.
-- Scheidung laeuft symmetrisch: Antrag -> Partner bestaetigt.

local HEIRAT_KOSTEN        = 50000   -- gesamt, je zur Haelfte von beiden
local MIN_SPIELZEIT        = 15 * 60 -- Minuten, die beide mindestens haben muessen (15 Spielstunden)
local TRAUZEUGE_TIMEOUT_MS = 30000
local SCHEIDUNG_TIMEOUT_MS = 20000
local MAX_TRAUZEUGEN       = 2       -- mindestens 1, hoechstens so viele
local REGISTER_LIMIT       = 100     -- so viele Ehen zeigt das Buch (neueste zuerst)

-- TESTMODUS - VOR DEM LIVEBETRIEB WIEDER AUF false SETZEN!
-- Erlaubt die Hochzeit allein: Antrag an sich selbst, sich selbst als
-- Trauzeugen, keine Mindestspielzeit. Betroffene Stellen: TESTMODUS 1/4 - 4/4.
local TESTMODUS_ALLEIN_HEIRATEN = true

local xa, ya, za = 1271.948, 1297.240, 453   -- Altar
local ALTAR_RADIUS = 10

local marryinprogress = false

---------------------------------------------------------------------
-- DB-Migration
---------------------------------------------------------------------
-- Der Schema-Runner in mysql/mysql_start.lua legt nur fehlende TABELLEN an und
-- ueberspringt bestehende komplett - eine neue Spalte in db_schema.lua erreicht
-- also keine vorhandene Datenbank. handler ist hier bereits verbunden.
local NEUE_SPALTEN = {
	{ "trauzeuge",  "varchar(50) NOT NULL DEFAULT ''" },
	{ "trauzeuge2", "varchar(50) NOT NULL DEFAULT ''" },
	{ "datum",      "datetime DEFAULT NULL" },
}

if handler then
	for _, spalte in ipairs ( NEUE_SPALTEN ) do
		local name, typ = spalte[1], spalte[2]
		local da = dbPoll ( dbQuery ( handler, "SHOW COLUMNS FROM `marry` LIKE ?", name ), -1 )
		if not ( da and da[1] ) then
			local ok = dbExec ( handler, "ALTER TABLE `marry` ADD COLUMN `"..name.."` "..typ )
			outputDebugString ( "[Hochzeit] Spalte `"..name.."` "..( ok and "ergaenzt." or "FEHLGESCHLAGEN!" ), ok and 3 or 1 )
		end
	end
else
	outputDebugString ( "[Hochzeit] Kein DB-Handler - Spalten nicht geprueft!", 2 )
end

---------------------------------------------------------------------
-- Hilfsfunktionen
---------------------------------------------------------------------
local function msg ( el, text, r, g, b )
	if isElement ( el ) then outputChatBox ( text, el, r or 255, g or 150, b or 0 ) end
end

-- Schickt beiden Beteiligten dieselbe Meldung.
local function msgBeide ( el1, el2, text, r, g, bl )
	msg ( el1, text, r, g, bl )
	if el2 ~= el1 then msg ( el2, text, r, g, bl ) end
end

local function amAltar ( el )
	if not isElement ( el ) then return false end
	local x, y, z = getElementPosition ( el )
	return getDistanceBetweenPoints3D ( xa, ya, za, x, y, z ) <= ALTAR_RADIUS
end

local function setzeEhedaten ( el, verheiratet, partnerName, nachname, trauzeuge )
	if not isElement ( el ) then return end
	MtxSetElementData ( el, "married", verheiratet )
	MtxSetElementData ( el, "marwith", partnerName )
	MtxSetElementData ( el, "nachname", nachname )
	MtxSetElementData ( el, "trauzeuge", trauzeuge )
end

function resetSpawnToDefault ( player )
	if not isElement ( player ) then return end
	-- Bahnhof SF, gleicher Standort wie der Fahrzeugverleih (carsys/verleih/verleih_server.lua:8).
	MtxSetElementData ( player, "spawnpos_x", -1982.475 )
	MtxSetElementData ( player, "spawnpos_y", 168.459 )
	MtxSetElementData ( player, "spawnpos_z", 27.6875 )
	MtxSetElementData ( player, "spawnrot_x", 90 )
	MtxSetElementData ( player, "spawnint", 0 )
	MtxSetElementData ( player, "spawndim", 0 )
end

-- Setzt den Spawnpunkt des Ehepartners auf das aktuelle Haus von "player"
-- (oder auf den Bahnhof SF, falls "player" gerade kein Haus hat).
-- Wird auch aus housesys/housecmds.lua und housesys/housebuy.lua aufgerufen.
function updatePartnerSpawnFromHouse ( player )
	if not isElement ( player ) or MtxGetElementData ( player, "married" ) ~= 1 then return end

	local partner = getPlayerFromName ( MtxGetElementData ( player, "marwith" ) )
	if not partner then return end

	local hkey = tonumber ( MtxGetElementData ( player, "housekey" ) ) or 0
	local haus = ( hkey ~= 0 ) and houses["pickup"][math.abs ( hkey )] or nil

	if isElement ( haus ) then
		local x, y, z = getElementPosition ( haus )
		MtxSetElementData ( partner, "spawnpos_x", x + 2 )
		MtxSetElementData ( partner, "spawnpos_y", y + 2 )
		MtxSetElementData ( partner, "spawnpos_z", z )
		MtxSetElementData ( partner, "spawnint", 0 )
		MtxSetElementData ( partner, "spawndim", 0 )
		msg ( partner, "Dein Spawnpunkt wurde auf das Haus von "..getPlayerName ( player ).." gesetzt!", 0, 200, 0 )
	else
		resetSpawnToDefault ( partner )
		msg ( partner, getPlayerName ( player ).." hat noch kein Haus - dein Spawnpunkt wurde auf den Bahnhof SF gesetzt!", 0, 200, 0 )
	end
end

---------------------------------------------------------------------
-- Kirche: Ein-/Ausgang, Infopickup, Admin-Sperre
---------------------------------------------------------------------
local kircheraus = createMarker ( 1277.099, 1301.599, 453.2, "corona", 1.2, 255, 255, 255, 120 )
setElementInterior ( kircheraus, 66 )
local markerin = createMarker ( -1989.04, 1117.92, 54.2, "corona", 1.2, 255, 255, 255, 120 )
local info = createPickup ( -1987.975, 1120.550, 54.12, 3, 1239, 1, 0 )

addEventHandler ( "onMarkerHit", markerin, function ( player )
	if marryinprogress then
		msg ( player, "Man kommt nicht zu spaet zu einer Hochzeit!", 255, 0, 0 )
	elseif getElementType ( player ) == "player" and getPedOccupiedVehicle ( player ) == false then
		setElementPosition ( player, 1275.361, 1301.411, 453.084 )
		setElementInterior ( player, 66 )
	end
end )

addEventHandler ( "onMarkerHit", kircheraus, function ( player )
	setElementInterior ( player, 0 )
	setElementPosition ( player, -1986.466, 1117.362, 53.857 )
	if marryinprogress then
		msg ( player, "Die Hochzeit ist noch gar nicht zu Ende, eine Frechheit!", 255, 0, 0 )
	end
end )

addEventHandler ( "onPickupHit", info, function ( player )
	msg ( player, "Heiratsablauf: klicke einen Spieler an und waehle im Interaktionsmenue \"Heiraten\".", 255, 155, 0 )
	msg ( player, "Nach Antrag und Nachname: geht gemeinsam an den Altar und bestaetigt die Trauung.", 255, 155, 0 )
	msg ( player, "Ein dritter Spieler am Altar wird als Trauzeuge gefragt - erst seine Zusage schliesst die Ehe ab.", 255, 155, 0 )
	msg ( player, "Kosten einer Heirat: "..HEIRAT_KOSTEN.."$ ("..( HEIRAT_KOSTEN/2 ).."$ pro Person)", 255, 155, 0 )
end )

---------------------------------------------------------------------
-- Eheregister ("das Buch") - steht in der Kirche neben dem Altar und
-- listet alle geschlossenen Ehen mit Datum, Paar und Trauzeugen.
---------------------------------------------------------------------
-- Standort vor Ort eingemessen (Interior 66, Dimension 0). Der Kirchenboden
-- liegt laut SF_Kirche.map durchgehend auf z = 452.1; die gemeldete Spieler-
-- position 453.084 ist die Koerpermitte, nicht die Fuesse.
local REG_X, REG_Y = 1276.587, 1297.699
local REG_BODEN    = 452.1

-- Tisch + Buch wie am Altar: Modell 2314 (CJ_TV_TABLE3, Skalierung 1.5) und
-- darauf 2894 (kmb_rhymesbook) - beide sind in SF_Kirche.map bereits in genau
-- dieser Kombination verbaut, die Hoehendifferenz von 0.8 stammt von dort.
local registerTisch = createObject ( 2314, REG_X, REG_Y, REG_BODEN, 0, 0, 0 )
setElementInterior ( registerTisch, 66 )
setElementDimension ( registerTisch, 0 )
setObjectScale ( registerTisch, 1.5 )

local registerBuch = createObject ( 2894, REG_X, REG_Y, REG_BODEN + 0.8, 0, 0, 0 )
setElementInterior ( registerBuch, 66 )
setElementDimension ( registerBuch, 0 )

-- Der Marker darf NICHT auf dem Tisch liegen: das Objekt hat Kollision, man
-- kaeme nie hinein. Deshalb 1.2 Einheiten davor (Richtung Kirchenschiff) und
-- knapp ueber dem Boden, damit der Zylinder sauber sichtbar ist.
local REG_MARKER_X = REG_X - 1.2
local REG_MARKER_Y = REG_Y

local registerMarker = createMarker ( REG_MARKER_X, REG_MARKER_Y, REG_BODEN + 0.1, "cylinder", 1.2, 200, 170, 60, 120 )
setElementInterior ( registerMarker, 66 )
setElementDimension ( registerMarker, 0 )

-- Laeuft ueber dbQueryCoro, damit die Abfrage den Server nicht blockiert -
-- muss deshalb immer aus runAsync heraus aufgerufen werden.
local function ladeRegister ()
	-- LIMIT darf KEIN ?-Platzhalter sein: MTA bindet ? immer als gequoteten
	-- String, und "LIMIT '100'" ist ein SQL-Syntaxfehler. dbQuery liefert dann
	-- false, der Callback feuert nie und die Coroutine haengt fuer immer -
	-- es passiert also gar nichts. Deshalb die Zahl fest einsetzen.
	local rows = dbQueryCoro (
		"SELECT pl1, pl2, nachname, trauzeuge, trauzeuge2, DATE_FORMAT(datum,'%d.%m.%Y') AS d "..
		"FROM marry ORDER BY datum DESC, pl1 ASC LIMIT "..math.floor ( tonumber ( REGISTER_LIMIT ) or 100 ) )

	if not rows then
		outputDebugString ( "[Hochzeit] Eheregister: DB-Abfrage fehlgeschlagen!", 1 )
		return nil
	end

	local liste = {}
	for _, r in ipairs ( rows ) do
		local zeugen = r["trauzeuge"] or ""
		if ( r["trauzeuge2"] or "" ) ~= "" then zeugen = zeugen.." und "..r["trauzeuge2"] end
		liste[#liste+1] = {
			datum    = r["d"] or "unbekannt",
			paar     = ( r["pl1"] or "?" ).." & "..( r["pl2"] or "?" ),
			nachname = r["nachname"] or "",
			zeugen   = zeugen ~= "" and zeugen or "-",
		}
	end
	return liste
end

local function zeigeRegister ( player )
	if not isElement ( player ) then return end
	runAsync ( function ()
		local liste = ladeRegister ()
		if not isElement ( player ) then return end
		if not liste then
			return msg ( player, "Das Eheregister konnte nicht geladen werden - bitte einem Admin melden.", 255, 0, 0 )
		end
		triggerClientEvent ( player, "eheregisterOeffnen", player, liste )
	end )
end

addEventHandler ( "onMarkerHit", registerMarker, function ( player )
	if getElementType ( player ) == "player" then zeigeRegister ( player ) end
end )

-- Damit man das Buch auch per Befehl aufschlagen kann, ohne zum Marker zu laufen.
addCommandHandler ( "eheregister", zeigeRegister )

addCommandHandler ( "lockkirche", function ( player )
	if MtxGetElementData ( player, "adminlvl" ) < 2 then
		return msg ( player, "Du bist kein Moderator!", 200, 0, 0 )
	end
	marryinprogress = not marryinprogress
	msg ( player, marryinprogress and "Kirche locked" or "Kirche unlocked", 200, 200, 0 )
end )

---------------------------------------------------------------------
-- Heiratsantrag
---------------------------------------------------------------------
-- [AntragstellerName] = { partner=Name, angenommen=bool, nachname=string|nil,
--                         nachnameAngenommen=bool, trauzeugeLaeuft=bool|nil }
local antraege = {}
local trauzeugeAnfragen = {}   -- [TrauzeugeName] = AntragstellerName
local scheidungsantraege = {}  -- [AntragstellerName] = PartnerName

-- Findet den Antrag, an dem "pname" beteiligt ist - als Antragsteller oder als
-- angefragter Partner. Gibt (Antragstellername, Antrag) zurueck.
local function findeAntrag ( pname )
	if antraege[pname] then return pname, antraege[pname] end
	for antragsteller, antrag in pairs ( antraege ) do
		if antrag.partner == pname then return antragsteller, antrag end
	end
end

local function partnerElemente ( antragsteller, antrag )
	return getPlayerFromName ( antragsteller ), getPlayerFromName ( antrag.partner )
end

addEvent ( "heiratsantragGUI", true )
addEventHandler ( "heiratsantragGUI", root, function ( partnerName )
	local player, pname = client, getPlayerName ( client )
	local partner = partnerName and getPlayerFromName ( partnerName )

	if not partner then
		return msg ( player, "Dieser Spieler ist nicht online.", 255, 0, 0 )
	end
	-- TESTMODUS 1/4: Antrag an sich selbst
	if partner == player and not TESTMODUS_ALLEIN_HEIRATEN then
		return msg ( player, "Du kannst dir nicht selbst einen Antrag machen!", 255, 0, 0 )
	end
	if MtxGetElementData ( player, "married" ) == 1 or MtxGetElementData ( partner, "married" ) == 1 then
		return msg ( player, "Einer von euch beiden ist bereits verheiratet!", 255, 0, 0 )
	end
	-- TESTMODUS 2/4: Mindestspielzeit
	if not TESTMODUS_ALLEIN_HEIRATEN
		and ( ( tonumber ( MtxGetElementData ( player, "playingtime" ) ) or 0 ) < MIN_SPIELZEIT
		or ( tonumber ( MtxGetElementData ( partner, "playingtime" ) ) or 0 ) < MIN_SPIELZEIT ) then
		return msg ( player, "Ihr braucht beide mindestens "..( MIN_SPIELZEIT/60 ).." Spielstunden, um zu heiraten." )
	end
	if findeAntrag ( pname ) then
		return msg ( player, "Du hast bereits einen offenen Heiratsantrag laufen." )
	end

	antraege[pname] = { partner = getPlayerName ( partner ), angenommen = false, nachnameAngenommen = false }

	msg ( player, "Du hast "..getPlayerName ( partner ).." einen Heiratsantrag gemacht!" )
	triggerClientEvent ( partner, "heiratsantragEmpfangen", partner, pname )
end )

addEvent ( "heiratsantragAntwortGUI", true )
addEventHandler ( "heiratsantragAntwortGUI", root, function ( akzeptiert )
	local player, pname = client, getPlayerName ( client )
	local antragsteller, antrag = findeAntrag ( pname )

	if not antrag or antrag.partner ~= pname then
		return msg ( player, "Du hast aktuell keinen offenen Heiratsantrag zum Beantworten." )
	end

	local a = getPlayerFromName ( antragsteller )

	if not akzeptiert then
		antraege[antragsteller] = nil
		msg ( player, "Du hast den Heiratsantrag abgelehnt." )
		return msg ( a, pname.." hat deinen Heiratsantrag abgelehnt.", 255, 0, 0 )
	end

	antrag.angenommen = true
	msg ( player, "Du hast den Antrag angenommen!", 0, 200, 0 )
	msg ( a, pname.." hat deinen Heiratsantrag angenommen! Schlage jetzt einen gemeinsamen Nachnamen vor.", 0, 200, 0 )
	if isElement ( a ) then triggerClientEvent ( a, "heiratsantragAngenommen", a ) end
end )

---------------------------------------------------------------------
-- Gemeinsamer Nachname
---------------------------------------------------------------------
addEvent ( "nachnameGUI", true )
addEventHandler ( "nachnameGUI", root, function ( nachname )
	local player, pname = client, getPlayerName ( client )
	local antrag = antraege[pname]

	if not antrag then
		return msg ( player, "Du hast keinen laufenden Heiratsantrag." )
	end
	if not antrag.angenommen then
		return msg ( player, "Dein Partner muss den Antrag erst annehmen." )
	end
	if type ( nachname ) ~= "string" or nachname == "" or nachname:find ( "%s" ) then
		return msg ( player, "Ungueltiger Nachname - keine Leerzeichen erlaubt." )
	end

	antrag.nachname, antrag.nachnameAngenommen = nachname, false

	msg ( player, "Du hast \""..nachname.."\" als gemeinsamen Nachnamen vorgeschlagen." )
	local p = getPlayerFromName ( antrag.partner )
	if isElement ( p ) then triggerClientEvent ( p, "nachnameEmpfangen", p, nachname ) end
end )

addEvent ( "nachnameAntwortGUI", true )
addEventHandler ( "nachnameAntwortGUI", root, function ( akzeptiert )
	local player, pname = client, getPlayerName ( client )
	local antragsteller, antrag = findeAntrag ( pname )

	if not antrag or antrag.partner ~= pname or not antrag.nachname then
		return msg ( player, "Du hast keinen Nachnamen-Vorschlag zum Beantworten." )
	end

	local a = getPlayerFromName ( antragsteller )

	if not akzeptiert then
		antrag.nachname = nil
		msg ( player, "Du hast den Nachnamen abgelehnt." )
		msg ( a, pname.." hat den Nachnamen abgelehnt. Schlage einen neuen vor.", 255, 0, 0 )
		if isElement ( a ) then triggerClientEvent ( a, "heiratsantragAngenommen", a ) end
		return
	end

	antrag.nachnameAngenommen = true

	local text = "Ihr habt euch auf \""..antrag.nachname.."\" geeinigt! Geht gemeinsam an den Altar."
	msgBeide ( player, a, text, 0, 200, 0 )
	triggerClientEvent ( player, "bereitZurTrauung", player )
	if isElement ( a ) and a ~= player then triggerClientEvent ( a, "bereitZurTrauung", a ) end
end )

---------------------------------------------------------------------
-- Trauung + Trauzeuge
---------------------------------------------------------------------
-- Loescht alle offenen Trauzeugen-Anfragen zu einer Hochzeit.
local function verwerfeTrauzeugenAnfragen ( antragsteller )
	for name, besitzer in pairs ( trauzeugeAnfragen ) do
		if besitzer == antragsteller then trauzeugeAnfragen[name] = nil end
	end
end

-- Prueft alle Bedingungen ERNEUT (zwischen Anfrage und Zusage koennen 30 s
-- liegen), bucht die Kosten ab, schreibt die Ehe in die DB und setzt sie bei
-- beiden. "melde" ist der Spieler, der Fehlermeldungen bekommt.
local function vollzieheTrauung ( antragsteller, antrag, trauzeugen, melde )
	local pl1, pl2 = partnerElemente ( antragsteller, antrag )

	if not pl1 or not pl2 then
		return msg ( melde, "Einer der beiden Partner ist nicht mehr online.", 255, 0, 0 )
	end
	if not amAltar ( pl1 ) or not amAltar ( pl2 ) then
		return msg ( melde, "Das Brautpaar steht nicht mehr am Altar!" )
	end
	if MtxGetElementData ( pl1, "married" ) == 1 or MtxGetElementData ( pl2, "married" ) == 1 then
		antraege[antragsteller] = nil
		return msg ( melde, "Einer von euch beiden ist inzwischen schon anderweitig verheiratet.", 255, 0, 0 )
	end

	-- Erst pruefen, ob BEIDE zahlen koennen, bevor irgendwas abgebucht wird -
	-- sonst zahlt einer und die Heirat scheitert am Geld des anderen.
	local anteil = HEIRAT_KOSTEN / 2
	local geld1  = tonumber ( MtxGetElementData ( pl1, "money" ) ) or 0
	local geld2  = tonumber ( MtxGetElementData ( pl2, "money" ) ) or 0

	if geld1 < anteil or geld2 < anteil then
		return msg ( melde, "Das Brautpaar braucht je mindestens "..formNumberToMoneyString ( anteil ).." (gesamt "..formNumberToMoneyString ( HEIRAT_KOSTEN )..")!" )
	end

	MtxSetElementData ( pl1, "money", geld1 - anteil )
	MtxSetElementData ( pl2, "money", geld2 - anteil )

	local name1, name2 = getPlayerName ( pl1 ), getPlayerName ( pl2 )
	trauzeugen = trauzeugen or {}
	local tz1, tz2 = trauzeugen[1] or "", trauzeugen[2] or ""
	local tzText = table.concat ( trauzeugen, " und " )
	if tzText == "" then tzText = "keiner" end

	dbExec ( handler, "INSERT INTO marry (pl1,pl2,nachname,trauzeuge,trauzeuge2,datum) VALUES (?,?,?,?,?,NOW())",
		name1, name2, antrag.nachname, tz1, tz2 )
	outputChatBox ( name1.." und "..name2.." wurden getraut! Trauzeugen: "..tzText, root, 255, 150, 0 )

	giveWeapon ( pl1, 14, 1 )
	giveWeapon ( pl2, 14, 1 )
	setzeEhedaten ( pl1, 1, name2, antrag.nachname, tzText )
	setzeEhedaten ( pl2, 1, name1, antrag.nachname, tzText )
	updatePartnerSpawnFromHouse ( pl1 )
	updatePartnerSpawnFromHouse ( pl2 )

	triggerClientEvent ( pl1, "trauungAbgeschlossen", pl1 )
	triggerClientEvent ( pl2, "trauungAbgeschlossen", pl2 )

	antraege[antragsteller] = nil
	verwerfeTrauzeugenAnfragen ( antragsteller )
	return true, pl1, pl2
end

addEvent ( "trauungGUI", true )
addEventHandler ( "trauungGUI", root, function ()
	local player, pname = client, getPlayerName ( client )
	local antragsteller, antrag = findeAntrag ( pname )

	if not antrag then
		return msg ( player, "Du hast keinen bestaetigten Heiratsantrag." )
	end
	if not antrag.angenommen or not antrag.nachnameAngenommen then
		return msg ( player, "Antrag und Nachname muessen von beiden bestaetigt sein." )
	end

	local pl1, pl2 = partnerElemente ( antragsteller, antrag )
	if not pl1 or not pl2 then
		return msg ( player, "Einer von euch beiden ist nicht mehr online.", 255, 0, 0 )
	end
	if not amAltar ( pl1 ) or not amAltar ( pl2 ) then
		return msg ( player, "Ihr muesst beide am Altar in der Kirche stehen!" )
	end

	if antrag.trauzeugeLaeuft then
		return msg ( player, "Es laeuft bereits eine Trauzeugen-Anfrage - wartet kurz ab." )
	end

	-- Alle Spieler am Altar, die weder Braut noch Braeutigam sind und nicht
	-- schon fuer eine andere Hochzeit angefragt wurden, zur Auswahl anbieten.
	-- TESTMODUS 3/4: Brautpaar darf selbst in der Trauzeugen-Liste stehen
	local kandidaten = {}
	for _, p in ipairs ( getElementsByType ( "player" ) ) do
		local n = getPlayerName ( p )
		local darfTrauzeugeSein = TESTMODUS_ALLEIN_HEIRATEN or ( p ~= pl1 and p ~= pl2 )
		if darfTrauzeugeSein and amAltar ( p ) and not trauzeugeAnfragen[n] then
			kandidaten[#kandidaten+1] = n
		end
	end

	if #kandidaten == 0 then
		return msg ( player, "Es steht niemand als Trauzeuge am Altar - ihr braucht mindestens einen weiteren Spieler!" )
	end

	triggerClientEvent ( player, "trauzeugenAuswahlOeffnen", player, kandidaten, MAX_TRAUZEUGEN )
end )

-- Das Brautpaar hat 1-2 Trauzeugen aus der Liste gewaehlt: beide werden gefragt,
-- und erst wenn ALLE zugesagt haben, wird die Ehe geschlossen. Lehnt einer ab,
-- platzt die Anfrage und das Paar kann neu waehlen.
addEvent ( "trauzeugenGewaehltGUI", true )
addEventHandler ( "trauzeugenGewaehltGUI", root, function ( auswahl )
	local player, pname = client, getPlayerName ( client )
	local antragsteller, antrag = findeAntrag ( pname )

	if not antrag or not antrag.nachnameAngenommen then
		return msg ( player, "Ihr seid noch nicht bereit zur Trauung." )
	end
	if antrag.trauzeugeLaeuft then
		return msg ( player, "Es laeuft bereits eine Trauzeugen-Anfrage - wartet kurz ab." )
	end
	if type ( auswahl ) ~= "table" or #auswahl < 1 or #auswahl > MAX_TRAUZEUGEN then
		return msg ( player, "Waehlt einen oder maximal "..MAX_TRAUZEUGEN.." Trauzeugen aus." )
	end

	local pl1, pl2 = partnerElemente ( antragsteller, antrag )
	if not pl1 or not pl2 or not amAltar ( pl1 ) or not amAltar ( pl2 ) then
		return msg ( player, "Ihr muesst beide am Altar in der Kirche stehen!" )
	end

	-- Auswahl gegenpruefen: der Client koennte alles schicken.
	local gewaehlt, gesehen = {}, {}
	for _, name in ipairs ( auswahl ) do
		-- TESTMODUS 4/4: Gegenpruefung der Auswahl laesst das Brautpaar zu
		local p = getPlayerFromName ( name )
		local istBrautpaar = ( p == pl1 or p == pl2 ) and not TESTMODUS_ALLEIN_HEIRATEN
		if not p or istBrautpaar or not amAltar ( p ) then
			return msg ( player, tostring ( name ).." steht nicht (mehr) als Trauzeuge am Altar." )
		end
		if trauzeugeAnfragen[name] then
			return msg ( player, tostring ( name ).." wurde bereits fuer eine andere Hochzeit angefragt." )
		end
		if gesehen[name] then
			return msg ( player, "Du hast "..tostring ( name ).." doppelt ausgewaehlt." )
		end
		gesehen[name] = true
		gewaehlt[#gewaehlt+1] = p
	end

	antrag.trauzeugeLaeuft = true
	antrag.offen   = {}   -- [Name] = true, solange die Antwort aussteht
	antrag.zusagen = {}   -- Namen in Zusage-Reihenfolge

	for _, p in ipairs ( gewaehlt ) do
		local n = getPlayerName ( p )
		trauzeugeAnfragen[n] = antragsteller
		antrag.offen[n] = true
		triggerClientEvent ( p, "trauzeugeAnfrageEmpfangen", p, getPlayerName ( pl1 ), getPlayerName ( pl2 ) )
	end

	msgBeide ( pl1, pl2, "Anfrage an "..#gewaehlt.." Trauzeuge(n) gesendet - wartet auf die Zusage.", 0, 200, 0 )

	setTimer ( function ()
		local aktuell = antraege[antragsteller]
		if not aktuell or not aktuell.trauzeugeLaeuft then return end
		aktuell.trauzeugeLaeuft, aktuell.offen, aktuell.zusagen = nil, nil, nil
		verwerfeTrauzeugenAnfragen ( antragsteller )
		msgBeide ( getPlayerFromName ( antragsteller ), getPlayerFromName ( aktuell.partner ),
			"Nicht alle Trauzeugen haben rechtzeitig zugesagt - waehlt erneut." )
	end, TRAUZEUGE_TIMEOUT_MS, 1 )
end )

addEvent ( "trauzeugeAntwortGUI", true )
addEventHandler ( "trauzeugeAntwortGUI", root, function ( akzeptiert )
	local player, pname = client, getPlayerName ( client )
	local antragsteller = trauzeugeAnfragen[pname]

	if not antragsteller then
		return msg ( player, "Du wurdest aktuell nicht als Trauzeuge angefragt." )
	end

	trauzeugeAnfragen[pname] = nil
	local antrag = antraege[antragsteller]

	if not antrag or not antrag.offen then
		return msg ( player, "Diese Hochzeit gibt es nicht mehr." )
	end

	local pl1, pl2 = partnerElemente ( antragsteller, antrag )
	antrag.offen[pname] = nil

	-- Eine einzige Absage laesst die ganze Anfrage platzen: das Paar hat sich
	-- diese Trauzeugen bewusst ausgesucht, also soll es neu waehlen koennen.
	if not akzeptiert then
		antrag.trauzeugeLaeuft, antrag.offen, antrag.zusagen = nil, nil, nil
		verwerfeTrauzeugenAnfragen ( antragsteller )
		msg ( player, "Du hast die Rolle als Trauzeuge abgelehnt." )
		return msgBeide ( pl1, pl2, pname.." hat abgelehnt, Trauzeuge zu sein - waehlt jemand anderen.", 255, 0, 0 )
	end

	antrag.zusagen[#antrag.zusagen+1] = pname
	msg ( player, "Du hast zugesagt, Trauzeuge zu sein.", 0, 200, 0 )

	-- Noch offene Zusagen? Dann erst mal warten.
	if next ( antrag.offen ) then
		return msgBeide ( pl1, pl2, pname.." hat zugesagt - es fehlt noch eine Zusage.", 0, 200, 0 )
	end

	local zeugen = antrag.zusagen
	local ok, a, b = vollzieheTrauung ( antragsteller, antrag, zeugen, player )
	if not ok then return end

	for _, name in ipairs ( zeugen ) do
		msg ( getPlayerFromName ( name ), "Du warst Trauzeuge bei der Hochzeit von "..getPlayerName ( a ).." und "..getPlayerName ( b )..".", 0, 200, 0 )
	end
end )

---------------------------------------------------------------------
-- Scheidung
---------------------------------------------------------------------
-- Gemeinsame Logik fuer GUI-Scheidung und den /acceptunmarry-Admin-Fallback:
-- loescht den DB-Eintrag anhand des Namens (egal ob als pl1 oder pl2 eingetragen)
-- und setzt die Ehedaten bei beiden zurueck.
local function vollziehScheidung ( player, partnerName )
	local pname = getPlayerName ( player )

	dbExec ( handler, "DELETE FROM marry WHERE pl1=? OR pl2=?", pname, pname )

	MtxSetElementData ( player, "unmarry", 0 )
	setzeEhedaten ( player, 0, "none", "none", "" )
	resetSpawnToDefault ( player )
	msg ( player, "Du hast dich erfolgreich von "..tostring ( partnerName ).." getrennt!" )

	local partner = partnerName and getPlayerFromName ( partnerName )
	if partner then
		MtxSetElementData ( partner, "unmarry", 0 )
		setzeEhedaten ( partner, 0, "none", "none", "" )
		resetSpawnToDefault ( partner )
		msg ( partner, pname.." hat sich von dir scheiden lassen." )
	elseif partnerName then
		offlinemsg ( pname.." hat sich von dir scheiden lassen.", "Standesamt", partnerName )
	end
end

addEvent ( "scheidungAntragGUI", true )
addEventHandler ( "scheidungAntragGUI", root, function ()
	local player, pname = client, getPlayerName ( client )

	if MtxGetElementData ( player, "married" ) ~= 1 then
		return msg ( player, "Du bist gar nicht verheiratet.", 255, 0, 0 )
	end

	local partnerName = MtxGetElementData ( player, "marwith" )
	local partner = partnerName and getPlayerFromName ( partnerName )

	if not partner then
		return msg ( player, "Dein Partner ist gerade nicht online.", 255, 0, 0 )
	end
	if scheidungsantraege[pname] then
		return msg ( player, "Du hast bereits einen offenen Scheidungsantrag laufen." )
	end

	scheidungsantraege[pname] = partnerName
	msg ( player, "Du hast "..partnerName.." um die Scheidung gebeten." )
	triggerClientEvent ( partner, "scheidungAntragEmpfangen", partner, pname )

	setTimer ( function ()
		if scheidungsantraege[pname] ~= partnerName then return end
		scheidungsantraege[pname] = nil
		msg ( getPlayerFromName ( pname ), partnerName.." hat nicht rechtzeitig reagiert - Scheidungsantrag abgelaufen." )
	end, SCHEIDUNG_TIMEOUT_MS, 1 )
end )

addEvent ( "scheidungAntwortGUI", true )
addEventHandler ( "scheidungAntwortGUI", root, function ( akzeptiert )
	local player, pname = client, getPlayerName ( client )

	local antragsteller
	for requester, ziel in pairs ( scheidungsantraege ) do
		if ziel == pname then antragsteller = requester break end
	end

	if not antragsteller then
		return msg ( player, "Du hast aktuell keinen offenen Scheidungsantrag zum Beantworten." )
	end
	scheidungsantraege[antragsteller] = nil

	if not akzeptiert then
		msg ( player, "Du hast den Scheidungsantrag abgelehnt." )
		return msg ( getPlayerFromName ( antragsteller ), pname.." hat deinen Scheidungsantrag abgelehnt.", 255, 0, 0 )
	end

	vollziehScheidung ( player, antragsteller )
end )

addCommandHandler ( "acceptunmarry", function ( player )
	if MtxGetElementData ( player, "unmarry" ) == 1 then
		vollziehScheidung ( player, MtxGetElementData ( player, "marwith" ) )
	else
		msg ( player, "Du hast keinen Scheidungsantrag.", 255, 155, 0 )
	end
end )

---------------------------------------------------------------------
-- Aufraeumen beim Verlassen
---------------------------------------------------------------------
addEventHandler ( "onPlayerQuit", root, function ()
	local pname = getPlayerName ( source )

	antraege[pname] = nil
	scheidungsantraege[pname] = nil
	trauzeugeAnfragen[pname] = nil

	for antragsteller, antrag in pairs ( antraege ) do
		if antrag.partner == pname then antraege[antragsteller] = nil end
	end
	for requester, ziel in pairs ( scheidungsantraege ) do
		if ziel == pname then scheidungsantraege[requester] = nil end
	end
	-- Anfragen, deren Hochzeit es nicht mehr gibt, verfallen mit.
	for name, besitzer in pairs ( trauzeugeAnfragen ) do
		if not antraege[besitzer] then trauzeugeAnfragen[name] = nil end
	end
end )
