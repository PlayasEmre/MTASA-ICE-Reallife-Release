--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Gluecksrad - Server                            ||
--\\                                                  //

local GR_SPIN_DURATION = 6000   -- muss mit dem Client uebereinstimmen
local GR_COOLDOWN      = 20      -- Sekunden Sperre zwischen zwei Drehungen ( 0 = aus )
local GR_TICKET_PRICE  = 2500   -- Preis pro Ticket

-- Das Limit haengt am Ticketkauf, nicht am Drehen: pro Zeitraum lassen sich
-- nur GR_TICKETS_PER_PERIOD Tickets kaufen. Gewonnene Tickets zaehlen nicht
-- dagegen - wer eines erdreht, bekommt also eine echte Zusatzdrehung.
--   604800 = eine Woche, 86400 = ein Tag, 259200 = drei Tage.
local GR_TICKETS_PER_PERIOD = 3

local GR_PERIOD_SECONDS = 604800

-- Hauptgewinn: Fahrzeugmodell und wo es dem Gewinner hingestellt wird.
-- Jede Woche steht ein anderes Fahrzeug am Podest. Der Server bestimmt es
-- allein und schickt es an die Clients - so koennen Ausstellung und
-- tatsaechlicher Gewinn nicht auseinanderlaufen.
-- Nur Modelle, die NICHT in carprices stehen ( carsys/carhouses/
-- carhousesettings.lua ) - also im Autohaus nicht kaufbar sind. Sonst waere
-- der Hauptgewinn etwas, das man sich ohnehin einfach kaufen kann.
local GR_CAR_LIST = {
	451,   -- Turismo
	477,   -- ZR-350
	480,   -- Comet
	494,   -- Hotring Racer
	502,   -- Hotring Racer A
	558,   -- Uranus
	567,   -- Savanna
}
local GR_CAR_PERIOD = 604800   -- Wechsel alle 7 Tage, unabhaengig vom Ticketzeitraum
local GR_CAR_SPAWN = { -1988.0, 90.0, 27.7, 0 }         -- x, y, z, Drehung
local GR_CAR_TROST = 250000                             -- Ersatz, falls die Uebergabe nicht moeglich ist

-- Premiumpaket, das ein Gewinner bekommt, wenn er noch keines hat.
-- 1 = Bronze, 2 = Silber, 3 = Gold, 4 = Platin, 5 = TOP DONATOR
local GR_PREMIUM_PAKET = 3

-- Gewinnarten:
--   money   - Bargeld
--   data    - beliebiges Item ueber seinen Element-Data-Schluessel
--   ticket  - eine zusaetzliche Drehung
--   premium - verlaengert den Premiumstatus um "wert" Tage
--   jackpot - wie money, wird aber serverweit angekuendigt
--   none    - Niete
grSegments = {
	{ art = "money",   wert = 500,    chance = 1150 },
	{ art = "premium", wert = 7,      chance = 50 },   -- wert = Tage
	{ art = "none",    wert = 0,      chance = 1800 },
	{ art = "data",    wert = 5,      chance = 1100, key = "benzinkannister", name = "Benzinkanister" },
	{ art = "money",   wert = 1000,   chance = 1100 },
	{ art = "data",    wert = 10,     chance = 850,  key = "zigaretten",      name = "Zigaretten" },
	{ art = "money",   wert = 2500,   chance = 950 },
	{ art = "data",    wert = 1,      chance = 800,  key = "presents",        name = "Geschenk" },
	{ art = "data",    wert = 1000,   chance = 800,  key = "casinoChips",     name = "Casino Chips" },
	{ art = "money",   wert = 5000,   chance = 600 },
	{ art = "ticket",  wert = 1,      chance = 400 },
	{ art = "money",   wert = 10000,  chance = 88 },
	{ art = "data",    wert = 500,    chance = 300,  key = "coins",           name = "Coins" },
	{ art = "jackpot", wert = 500000, chance = 10 },
	{ art = "car",     wert = 0,      chance = 2 },
}

-- Zwischenspeicher der Spielerdaten, damit nicht jede Menueoeffnung eine
-- Abfrage ausloest. Geschrieben wird dagegen sofort, damit ein Absturz keine
-- Tickets verschluckt.
local grData = {}      -- [UID] = { tickets, periode, gekauft, letzte }

-- Beide Sperren werden im Event-Handler gesetzt, also noch bevor die erste
-- Datenbankabfrage die Coroutine unterbrechen kann. Wuerde man sie erst in
-- der Arbeitsfunktion setzen, koennten zwei schnell hintereinander gesendete
-- Events beide an der Pruefung vorbeilaufen und z.B. zweimal drehen oder
-- zweimal kaufen, waehrend nur einmal abgebucht wird.
local grSpinLock = {}
local grBuyLock = {}

-- Nur ein Spieler darf gleichzeitig am Rad drehen. Ohne das koennten zwei
-- Spieler zeitgleich "startGluecksradSpin" bekommen und sich beide Ergebnisse
-- ueberlagern (Sound/Ticken auf dem Client, sowie zwei parallele Auszahlungs-
-- Timer). "grCurrentSpinner" ist der Spieler, dem das Rad gerade "gehoert".
local grCurrentSpinner = nil

---------------------------------------------------------------------
-- Datenbank
---------------------------------------------------------------------

-- Die Tabelle `gluecksrad` steht in mysql/db_schema.lua und wird von
-- mysql_start.lua angelegt, zusammen mit allen anderen Tabellen.
-- SpinPeriode haelt den Beginn des Zeitraums, SpinAnzahl die in diesem
-- Zeitraum gekauften Tickets.
addEventHandler ( "onResourceStart", resourceRoot, function ()
	-- Sicherheitsnetz: Verrutscht beim Anpassen eine Gewichtung, faellt es
	-- sofort auf, statt still die letzten Segmente unerreichbar zu machen.
	local sum = 0
	for i = 1, #grSegments do
		sum = sum + grSegments[i].chance
	end

	if sum ~= 10000 then
		local warnung = "[Gluecksrad] Summe der Chancen ist "..sum.." statt 10000 - bitte die Gewinntabelle pruefen!"
		outputDebugString ( warnung, 1 )
		-- Zusaetzlich ins Server-Log und an Online-Admins: outputDebugString
		-- sieht nur, wer gerade /debugscript offen hat - das faellt sonst leicht
		-- niemandem auf, bis Spieler sich ueber unerreichbare Segmente wundern.
		outputServerLog ( warnung )
		if meldeAdmins then
			meldeAdmins ( warnung )
		end
	end

end )

-- Fahrzeug der laufenden Woche. Aus dem Zeitstempel abgeleitet, dadurch auf
-- allen Clients identisch und ohne gespeicherten Zustand.
function getGluecksradCar ()
	local woche = math.floor ( getRealTime ().timestamp / GR_CAR_PERIOD )
	return GR_CAR_LIST[( woche % #GR_CAR_LIST ) + 1]
end

-- Beim Laden auf das aktuelle Fahrzeug gesetzt. Stuende hier nil, wuerde der
-- erste Timerdurchlauf einen Wechsel erkennen, der gar keiner ist, und bei
-- jedem Serverstart faelschlich "Am Podest steht jetzt ein ..." melden.
local grLastAnnouncedCar = nil

local function broadcastCar ( target )
	local modell = getGluecksradCar ()
	triggerClientEvent ( target or getRootElement(), "recieveGluecksradCar", getRootElement(), modell )
	return modell
end

-- Ausgangsstand merken. Bewusst OHNE Versand: beim Ressourcenstart sind die
-- Client-Skripte noch nicht geladen, der Empfaenger existiert dort also noch
-- gar nicht ( "event is not added clientside" ). Die Clients fragen das
-- Fahrzeug selbst ab, sobald sie bereit sind.
addEventHandler ( "onResourceStart", resourceRoot, function ()
	grLastAnnouncedCar = getGluecksradCar ()
end )

addEvent ( "requestGluecksradCar", true )
addEventHandler ( "requestGluecksradCar", getRootElement(), function ()
	if isElement ( client ) then
		broadcastCar ( client )
	end
end )

-- Prueft regelmaessig, ob die Woche gewechselt hat, und meldet das neue
-- Fahrzeug an alle. Ohne das haetten Spieler mit langer Sitzung noch das
-- alte Auto vor sich stehen.
setTimer ( function ()
	local modell = getGluecksradCar ()
	if modell == grLastAnnouncedCar then
		return
	end

	grLastAnnouncedCar = modell
	broadcastCar ()

	outputChatBox ( "Gluecksrad: Am Podest steht jetzt ein "..
					( getVehicleNameFromModel ( modell ) or "neues Fahrzeug" ).."!", getRootElement(), 250, 200, 0 )
end, 60000, 0 )

local function loadData ( uid )
	if grData[uid] then
		return grData[uid]
	end

	local result = dbQueryCoro ( "SELECT ??, ??, ??, ?? FROM ?? WHERE ??=?",
								 "Tickets", "SpinPeriode", "SpinAnzahl", "LetzteDrehung", "gluecksrad", "UID", uid )

	-- Die Abfrage haelt die Coroutine an. In dieser Zeit kann ein zweiter
	-- Aufruf dieselben Daten schon geladen haben. Dann dessen Tabelle nehmen,
	-- sonst arbeiten beide auf verschiedenen Kopien und Aenderungen des einen
	-- werden vom anderen ueberschrieben.
	if grData[uid] then
		return grData[uid]
	end

	if result and result[1] then
		grData[uid] = {
			tickets = tonumber ( result[1]["Tickets"] ) or 0,
			periode = tonumber ( result[1]["SpinPeriode"] ) or 0,
			gekauft = tonumber ( result[1]["SpinAnzahl"] ) or 0,
			letzte  = tonumber ( result[1]["LetzteDrehung"] ) or 0,
		}
	else
		grData[uid] = { tickets = 0, periode = 0, gekauft = 0, letzte = 0 }
		dbExec ( handler, "INSERT IGNORE INTO ?? (??) VALUES (?)", "gluecksrad", "UID", uid )
	end

	return grData[uid]
end

local function saveData ( uid )
	local data = grData[uid]
	if not data then
		return
	end

	dbExec ( handler, "UPDATE ?? SET ??=?, ??=?, ??=?, ??=? WHERE ??=?", "gluecksrad",
			 "Tickets", data.tickets, "SpinPeriode", data.periode, "SpinAnzahl", data.gekauft,
			 "LetzteDrehung", data.letzte, "UID", uid )
end

-- Der Ticketstand wird in Element-Data gespiegelt, damit das Inventar ihn
-- anzeigen kann. Gespeichert wird weiterhin nur in unserer eigenen Tabelle -
-- der zentrale Speicherzyklus von ICE bleibt dadurch unberuehrt.
local function syncTickets ( player, data )
	if isElement ( player ) then
		MtxSetElementData ( player, "gluecksradTickets", data.tickets )
	end
end

---------------------------------------------------------------------
-- Zeitraum
---------------------------------------------------------------------

-- Der Zeitraum laeuft pro Spieler, nicht nach Kalender: er beginnt mit dem
-- ersten Ticketkauf und endet GR_PERIOD_SECONDS spaeter.
local function isPeriodOver ( data )
	if data.periode <= 0 then
		return true
	end

	return getRealTime ().timestamp >= data.periode + GR_PERIOD_SECONDS
end

local function getPeriodReset ( data )
	if isPeriodOver ( data ) then
		return 0
	end

	return ( data.periode + GR_PERIOD_SECONDS ) - getRealTime ().timestamp
end

local function getTicketsLeft ( data )
	if GR_TICKETS_PER_PERIOD <= 0 then
		return -1
	end

	if isPeriodOver ( data ) then
		return GR_TICKETS_PER_PERIOD
	end

	return math.max ( 0, GR_TICKETS_PER_PERIOD - data.gekauft )
end

-- "5 Tagen" / "3 Stunden" / "12 Minuten", je nach Groessenordnung.
local function formatDuration ( seconds )
	if seconds >= 86400 then
		local tage = math.ceil ( seconds / 86400 )
		return ( tage == 1 ) and "einem Tag" or ( tage.." Tagen" )
	end

	if seconds >= 3600 then
		local stunden = math.ceil ( seconds / 3600 )
		return ( stunden == 1 ) and "einer Stunde" or ( stunden.." Stunden" )
	end

	if seconds >= 60 then
		local minuten = math.ceil ( seconds / 60 )
		return ( minuten == 1 ) and "einer Minute" or ( minuten.." Minuten" )
	end

	-- Kurze Sperren ( z.B. GR_COOLDOWN = 20 ) muessen in Sekunden stehen.
	-- Vorher wurde immer auf Minuten gerundet und daraus "in 1 Minuten".
	local sekunden = math.max ( 1, math.ceil ( seconds ) )
	return ( sekunden == 1 ) and "einer Sekunde" or ( sekunden.." Sekunden" )
end

---------------------------------------------------------------------
-- Hilfsfunktionen
---------------------------------------------------------------------

local function getRemainingCooldown ( data )
	if GR_COOLDOWN <= 0 or data.letzte <= 0 then
		return 0
	end

	local remaining = ( data.letzte + GR_COOLDOWN ) - getRealTime ().timestamp
	return remaining > 0 and remaining or 0
end

local function sendStatus ( player, data )
	if not isElement ( player ) then
		return
	end

	syncTickets ( player, data )

	triggerClientEvent ( player, "recieveGluecksradStatus", player,
						 getRemainingCooldown ( data ), data.tickets, GR_TICKET_PRICE,
						 getTicketsLeft ( data ), GR_TICKETS_PER_PERIOD, getPeriodReset ( data ) )
end

-- Liefert UID und Daten, oder nichts, wenn der Spieler nicht spielbereit ist.
local function getPlayerData ( player )
	if not isElement ( player ) or MtxGetElementData ( player, "loggedin" ) ~= 1 then
		return
	end

	local uid = playerUID[getPlayerName ( player )]
	if not uid then
		return
	end

	local data = loadData ( uid )
	if not isElement ( player ) then
		return
	end

	return uid, data
end

-- Das Ergebnis wird bewusst hier gezogen und nicht auf dem Client.
-- Der Client bekommt nur den Segment-Index und dreht das Rad passend dorthin.
local function pickSegment ()
	local rnd = math.random ( 1, 10000 )
	local sum = 0

	for i = 1, #grSegments do
		sum = sum + grSegments[i].chance
		if rnd <= sum then
			return i
		end
	end

	return #grSegments
end

-- Vergibt das Hauptgewinn-Fahrzeug.
--
-- Bewusst ueber die vorhandene carbuy-Funktion aus carsys statt selbst
-- gebaut: dort haengen Slotvergabe, allPrivateCars, SaveCarData, Farben,
-- Antrieb und der Datenbankeintrag zusammen. Ein Nachbau wuerde frueher oder
-- spaeter davon abweichen.
--
-- everyCarBuyableForFree wird nur fuer den Aufruf gesetzt und danach exakt
-- auf den alten Wert zurueckgestellt - sonst haette der Gewinner dauerhaft
-- Gratisfahrzeuge.
function giveGluecksradCar ( player )
	if not isElement ( player ) or MtxGetElementData ( player, "loggedin" ) ~= 1 then
		return false
	end

	local modell = getGluecksradCar ()

	if MtxGetElementData ( player, "maxcars" ) <= MtxGetElementData ( player, "curcars" ) then
		outputChatBox ( "Gluecksrad: Du hast keinen freien Fahrzeugslot - du bekommst stattdessen "..
						formNumberToMoneyString ( GR_CAR_TROST )..".", player, 200, 200, 0 )
		return false
	end

	if not hasPlayerLicense ( player, modell ) then
		outputChatBox ( "Gluecksrad: Dir fehlt der noetige Fuehrerschein - du bekommst stattdessen "..
						formNumberToMoneyString ( GR_CAR_TROST )..".", player, 200, 200, 0 )
		return false
	end

	local vorher = MtxGetElementData ( player, "everyCarBuyableForFree" )
	MtxSetElementData ( player, "everyCarBuyableForFree", 1 )

	-- Sicherheitsnetz: setzt das Gratis-Flag auch dann zurueck, wenn carbuy
	-- mit einem Fehler abbricht und die Zeile darunter nie erreicht wird.
	-- Bliebe es gesetzt, haette der Spieler dauerhaft kostenlose Fahrzeuge.
	--
	-- Kein pcall an dieser Stelle: carbuy nutzt dbQueryCoro und muss dabei die
	-- Coroutine anhalten. In Lua 5.1 laesst sich aus einem pcall heraus nicht
	-- anhalten, der Aufruf wuerde mit "attempt to yield across a C-call
	-- boundary" scheitern und die Fahrzeugvergabe komplett lahmlegen.
	setTimer ( function ()
		if isElement ( player ) then
			MtxSetElementData ( player, "everyCarBuyableForFree", vorher or 0 )
		end
	end, 5000, 1 )

	local ok = carbuy ( player, 0, modell,
						GR_CAR_SPAWN[1], GR_CAR_SPAWN[2], GR_CAR_SPAWN[3],
						0, 0, GR_CAR_SPAWN[4] )

	if isElement ( player ) then
		MtxSetElementData ( player, "everyCarBuyableForFree", vorher or 0 )
	end

	if not ok then
		outputChatBox ( "Gluecksrad: Die Fahrzeugvergabe hat nicht geklappt - du bekommst stattdessen "..
						formNumberToMoneyString ( GR_CAR_TROST )..".", player, 200, 200, 0 )
		outputDebugString ( "[Gluecksrad] carbuy fuer "..getPlayerName ( player ).." fehlgeschlagen ( Modell "..modell.." ).", 1 )
		return false
	end

	outputChatBox ( "Gluecksrad: "..getPlayerName ( player ).." hat am Gluecksrad einen "..
					( getVehicleNameFromModel ( modell ) or "Wagen" ).." gewonnen!", getRootElement(), 250, 200, 0 )
	outputLog ( getPlayerName ( player ).." hat am Gluecksrad ein Fahrzeug gewonnen ( "..
				( getVehicleNameFromModel ( modell ) or modell ).." )", "vehicle" )
	return true
end

local function payOutSegment ( player, uid, data, index )
	if not isElement ( player ) or MtxGetElementData ( player, "loggedin" ) ~= 1 then
		return
	end

	local segment = grSegments[index]
	if not segment then
		return
	end

	if segment.art == "money" then
		MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) + segment.wert )
		infobox ( player, "Gluecksrad:\nDu gewinnst\n"..formNumberToMoneyString ( segment.wert ).."!", 5000, 0, 125, 0 )
		outputChatBox ( "Gluecksrad: Du hast "..formNumberToMoneyString ( segment.wert ).." gewonnen!", player, 0, 200, 0 )

	elseif segment.art == "jackpot" then
		MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) + segment.wert )
		infobox ( player, "JACKPOT!\nDu gewinnst\n"..formNumberToMoneyString ( segment.wert ).."!", 8000, 250, 200, 0 )
		outputChatBox ( "Gluecksrad: "..getPlayerName ( player ).." hat den JACKPOT geknackt und gewinnt "..
						formNumberToMoneyString ( segment.wert ).."!", getRootElement(), 250, 200, 0 )

	elseif segment.art == "car" then
		infobox ( player, "HAUPTGEWINN!\nDu gewinnst\nein Fahrzeug!", 8000, 250, 200, 0 )

		-- carbuy nutzt dbQueryCoro, laeuft also nur in einer Coroutine.
		runAsync ( function ()
			if not giveGluecksradCar ( player ) then
				if isElement ( player ) then
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) + GR_CAR_TROST )
				end
			end
		end )

	elseif segment.art == "premium" then
		-- Laeuft bereits Premium, wird verlaengert statt ueberschrieben - und
		-- ein hoeheres Paket bleibt erhalten, damit ein Gold-Spieler nicht
		-- versehentlich auf Bronze zurueckgestuft wird.
		local now = getRealTime ().timestamp
		local aktuell = tonumber ( MtxGetElementData ( player, "PremiumData" ) ) or 0
		local basis = ( aktuell > now ) and aktuell or now
		local neu = basis + segment.wert * 86400

		local paket = tonumber ( MtxGetElementData ( player, "Paket" ) ) or 0
		if paket < 1 then
			paket = GR_PREMIUM_PAKET
		end

		MtxSetElementData ( player, "PremiumData", neu )
		MtxSetElementData ( player, "Paket", paket )
		MtxSetElementData ( player, "premium", true )

		dbExec ( handler, "UPDATE ?? SET ??=?, ??=? WHERE ??=?", "userdata",
				 "PremiumPaket", paket, "PremiumData", neu, "UID", uid )

		infobox ( player, "Gluecksrad:\nDu gewinnst\n"..segment.wert.." Tage\nPremium!", 8000, 250, 200, 0 )
		outputChatBox ( "Gluecksrad: Du hast "..segment.wert.." Tage Premium ( "..
						( vipPackageName[paket] or paket ).." ) gewonnen!", player, 0, 200, 0 )

	elseif segment.art == "ticket" then
		-- Gewonnene Tickets laufen ueber unsere eigenen Daten, damit sie nicht
		-- gegen das Kauflimit zaehlen.
		data.tickets = data.tickets + segment.wert
		saveData ( uid )
		syncTickets ( player, data )

		infobox ( player, "Gluecksrad:\nDu gewinnst\n"..segment.wert.." Freidrehung"..( segment.wert > 1 and "en" or "" ).."!", 5000, 0, 125, 0 )
		outputChatBox ( "Gluecksrad: Du hast "..segment.wert.." zusaetzliches Ticket gewonnen!", player, 0, 200, 0 )

	elseif segment.art == "data" and segment.key then
		local current = MtxGetElementData ( player, segment.key ) or 0
		MtxSetElementData ( player, segment.key, current + segment.wert )

		local label = segment.wert.." "..( segment.name or segment.key )
		infobox ( player, "Gluecksrad:\nDu gewinnst\n"..label.."!", 5000, 0, 125, 0 )
		outputChatBox ( "Gluecksrad: Du hast "..label.." gewonnen!", player, 0, 200, 0 )

	else
		infobox ( player, "Gluecksrad:\nLeider eine Niete -\nversuch es gleich\nnoch einmal!", 5000, 200, 200, 0 )
	end
end

---------------------------------------------------------------------
-- Events
---------------------------------------------------------------------

function requestGluecksradStatus ( player )
	local uid, data = getPlayerData ( player )
	if not uid then
		return
	end

	sendStatus ( player, data )
end
addEvent ( "requestGluecksradStatus", true )
addEventHandler ( "requestGluecksradStatus", getRootElement(), function ()
	local player = client
	runAsync ( requestGluecksradStatus, player )
end )

function requestGluecksradTicket ( player, amount )
	local uid, data = getPlayerData ( player )
	if not uid then
		grBuyLock[player] = nil
		return
	end

	amount = tonumber ( amount )
	if not amount then
		grBuyLock[player] = nil
		return
	end

	amount = math.floor ( math.abs ( amount ) )
	if amount < 1 or amount > 10 then
		grBuyLock[player] = nil
		return
	end

	-- Neuer Zeitraum: Kaufzaehler beginnt von vorn.
	if isPeriodOver ( data ) then
		data.periode = 0
		data.gekauft = 0
	end

	local left = getTicketsLeft ( data )
	if left >= 0 and amount > left then
		if left == 0 then
			infobox ( player, "Du hast deine\n"..GR_TICKETS_PER_PERIOD.." Tickets schon\ngekauft - in\n"..formatDuration ( getPeriodReset ( data ) ).."\ngibt es neue!", 5000, 125, 0, 0 )
		else
			infobox ( player, "Du kannst aktuell\nnur noch "..left.." Ticket"..( left > 1 and "s" or "" ).."\nkaufen!", 5000, 200, 200, 0 )
		end
		sendStatus ( player, data )
		grBuyLock[player] = nil
		return
	end

	local price = GR_TICKET_PRICE * amount
	local money = MtxGetElementData ( player, "money" )

	if money < price then
		infobox ( player, "Du hast nicht genug\nGeld fuer "..amount.." Ticket"..( amount > 1 and "s" or "" ).."!", 5000, 125, 0, 0 )
		sendStatus ( player, data )
		grBuyLock[player] = nil
		return
	end

	-- Der erste Kauf eines Zeitraums startet dessen Uhr.
	if data.periode <= 0 then
		data.periode = getRealTime ().timestamp
	end

	MtxSetElementData ( player, "money", money - price )
	data.tickets = data.tickets + amount
	data.gekauft = data.gekauft + amount
	saveData ( uid )

	infobox ( player, "Du hast "..amount.." Ticket"..( amount > 1 and "s" or "" ).."\nfuer "..formNumberToMoneyString ( price ).."\ngekauft!", 5000, 0, 125, 0 )
	sendStatus ( player, data )
	grBuyLock[player] = nil
end
addEvent ( "requestGluecksradTicket", true )
addEventHandler ( "requestGluecksradTicket", getRootElement(), function ( amount )
	local player = client
	if not isElement ( player ) or grBuyLock[player] then
		return
	end

	grBuyLock[player] = true
	runAsync ( requestGluecksradTicket, player, amount )
end )

function requestGluecksradSpin ( player )
	local uid, data = getPlayerData ( player )
	if not uid then
		grSpinLock[player] = nil
		return
	end

	-- Nur ein Spieler gleichzeitig am Rad. Wird VOR dem Ticketabzug geprueft,
	-- damit ein Spieler, der warten muss, dafuer kein Ticket verliert.
	if grCurrentSpinner and grCurrentSpinner ~= player then
		infobox ( player, "Gerade dreht "..getPlayerName ( grCurrentSpinner )..
						  "\nam Rad - bitte kurz\nwarten!", 4000, 200, 200, 0 )
		grSpinLock[player] = nil
		return
	end

	local remaining = getRemainingCooldown ( data )
	if remaining > 0 then
		infobox ( player, "Du darfst erst in\n"..formatDuration ( remaining ).."\nwieder drehen!", 5000, 125, 0, 0 )
		sendStatus ( player, data )
		grSpinLock[player] = nil
		return
	end

	-- Gedreht wird ausschliesslich gegen ein Ticket. Das Wochenlimit steckt
	-- bereits im Kauf, hier gibt es keine zusaetzliche Sperre.
	if data.tickets < 1 then
		infobox ( player, "Du brauchst ein Ticket,\num das Gluecksrad\ndrehen zu koennen!", 5000, 125, 0, 0 )
		sendStatus ( player, data )
		grSpinLock[player] = nil
		return
	end

	data.tickets = data.tickets - 1
	data.letzte = getRealTime ().timestamp
	saveData ( uid )
	syncTickets ( player, data )

	local index = pickSegment ()

	-- Rad "belegen" und den Spieler an Ort und Stelle einfrieren, solange es
	-- sich dreht - so kann er waehrenddessen weder weglaufen noch etwas
	-- anderes tun, und kein zweiter Spieler kann gleichzeitig drehen.
	grCurrentSpinner = player
	setElementFrozen ( player, true )

	triggerClientEvent ( player, "startGluecksradSpin", player, index )

	-- Auszahlung erst, wenn die Animation auf dem Client durch ist.
	setTimer ( function ()
		grSpinLock[player] = nil

		if grCurrentSpinner == player then
			grCurrentSpinner = nil
		end

		if isElement ( player ) then
			setElementFrozen ( player, false )
		end

		payOutSegment ( player, uid, data, index )
		sendStatus ( player, data )
	end, GR_SPIN_DURATION + 250, 1 )
end
addEvent ( "requestGluecksradSpin", true )
addEventHandler ( "requestGluecksradSpin", getRootElement(), function ()
	local player = client
	if not isElement ( player ) or grSpinLock[player] then
		return
	end

	grSpinLock[player] = true
	runAsync ( requestGluecksradSpin, player )
end )

-- Beim Spawn sind die Spielerdaten geladen. Dann holen wir den Ticketstand
-- einmal aus der Datenbank, damit er im Inventar steht, ohne dass der Spieler
-- vorher am Rad gewesen sein muss.
function syncGluecksradInventory ( player )
	local uid, data = getPlayerData ( player )
	if not uid then
		return
	end

	syncTickets ( player, data )
end
addEventHandler ( "onPlayerSpawn", getRootElement(), function ()
	local player = source
	runAsync ( syncGluecksradInventory, player )
end )

-- Die Einmessbefehle im Client werden erst freigeschaltet, wenn der Server
-- den Adminrang bestaetigt. Ein manipulierter Client kann sich die Freigabe
-- nicht selbst geben, weil die Entscheidung hier faellt.
local GR_DEV_LEVEL = 5

addEvent ( "requestGluecksradDev", true )
addEventHandler ( "requestGluecksradDev", getRootElement(), function ()
	local player = client
	if not isElement ( player ) or MtxGetElementData ( player, "loggedin" ) ~= 1 then
		return
	end

	if getAdminLevel ( player ) >= GR_DEV_LEVEL then
		triggerClientEvent ( player, "recieveGluecksradDev", player )
	end
end )

addEventHandler ( "onPlayerQuit", getRootElement(), function ()
	grSpinLock[source] = nil
	grBuyLock[source] = nil

	if grCurrentSpinner == source then
		grCurrentSpinner = nil
	end

	local uid = playerUID[getPlayerName ( source )]
	if uid then
		grData[uid] = nil
	end
end )
