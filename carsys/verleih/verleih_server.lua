--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Fahrzeugverleih - Server                       ||
--\\                                                  //

-- Standort und Ausgabestelle vom alten Rollerverleih am Bahnhof SF
-- uebernommen ( carsys/fahrzeugverleih ), den dieses System ersetzt.
local VL_STATION = { -1982.475, 168.459, 27.6875 }
local VL_SPAWN   = { -1986.185, 170.829, 27.6875, 90 }   -- x, y, z, Drehung

local VL_MIETDAUER  = 1800   -- Sekunden pro Mietabschnitt ( 30 Minuten )
local VL_WARNUNG    = 300    -- so lange vorher wird gewarnt ( 5 Minuten )
local VL_CHECK_TIME = 10000  -- wie oft geprueft wird

-- Guenstige Alltagsfahrzeuge. Der Fuehrerschein wird ueber hasPlayerLicense
-- geprueft, damit der Verleih die Fahrschule nicht aushebelt.
-- Fuehrerscheine laut settings.lua:
--   BMX und Faggio  - keiner noetig
--   Blista, Tampa   - Autoschein
--   FCR-900         - Motorradschein
verleihCars = {
	{ modell = 481, name = "BMX",             preis = 10 },
	-- Preis vom alten Rollerverleih uebernommen, damit Neulinge nicht
	-- ploetzlich mehr zahlen als bisher.
	{ modell = 462, name = "Faggio",          preis = 30 },
	{ modell = 496, name = "Blista Compact",  preis = 200 },
	{ modell = 521, name = "FCR-900",         preis = 250 },
	{ modell = 549, name = "Tampa",           preis = 300 },
}

local vlRentals = {}   -- [player] = { fahrzeug, name, preis, ablauf, gewarnt }

---------------------------------------------------------------------
-- Hilfsfunktionen
---------------------------------------------------------------------

local function findeAngebot ( index )
	index = tonumber ( index )
	if not index then
		return
	end
	return verleihCars[math.floor ( index )]
end

-- Hinweis: Es gibt bewusst keine Statusmeldung an den Client mehr. Das
-- Fenster zeigt nur noch Fahrzeuge und Preise, alles Weitere läuft ueber
-- Chat und Infobox. Wuerde hier gesendet, ohne dass der Client einen
-- Empfaenger hat, meldet MTA "event is not added clientside".

-- Gibt das Fahrzeug frei. Sass der Spieler noch darin, wird er daneben
-- abgesetzt - sonst faende er sich in der Luft oder im Nirgendwo wieder.
function verleihBeenden ( player, grund )
	local miete = vlRentals[player]
	if not miete then
		return false
	end

	vlRentals[player] = nil

	-- Sass der Spieler noch drin, wird er dort abgesetzt, wo das Fahrzeug
	-- stand. Ein fester Rueckkehrpunkt hatte ihn in eine Wand gestellt -
	-- und die Stelle unter dem Fahrzeug ist immer begehbarer Boden.
	local sassDrin, fx, fy, fz = false, nil, nil, nil

	if isElement ( miete.fahrzeug ) then
		if isElement ( player ) and getPedOccupiedVehicle ( player ) == miete.fahrzeug then
			sassDrin = true
			fx, fy, fz = getElementPosition ( miete.fahrzeug )
			removePedFromVehicle ( player )
		end
		-- Verzoegert loeschen: verleihBeenden wird unter anderem aus
		-- onVehicleExplode heraus aufgerufen, und ein Element mitten in
		-- seinem eigenen Ereignis zu zerstoeren ist in MTA heikel.
		setTimer ( function ( veh )
			if isElement ( veh ) then
				destroyElement ( veh )
			end
		end, 50, 1, miete.fahrzeug )
	end

	if isElement ( player ) then
		if sassDrin and fx then
			-- Etwas seitlich und leicht erhoeht, damit er nicht genau im
			-- Fahrzeugmittelpunkt und damit halb im Boden landet.
			setElementPosition ( player, fx + 1.5, fy, fz + 0.6 )
		end

		if grund then
			infobox ( player, grund, 6000, 200, 200, 0 )
		end
	end

	return true
end

---------------------------------------------------------------------
-- Mieten
---------------------------------------------------------------------

function requestVerleih ( player, index )
	if not isElement ( player ) or MtxGetElementData ( player, "loggedin" ) ~= 1 then
		return
	end

	local angebot = findeAngebot ( index )
	if not angebot then
		return
	end

	-- Nur ein Mietfahrzeug gleichzeitig, sonst stellt einer den Platz voll.
	if vlRentals[player] then
		infobox ( player, "Du hast bereits ein\nFahrzeug gemietet.\nVerlängern mit\n/verleihverlaengern", 6000, 200, 200, 0 )
		return
	end

	local x, y, z = getElementPosition ( player )
	if getDistanceBetweenPoints3D ( x, y, z, VL_STATION[1], VL_STATION[2], VL_STATION[3] ) > 12 then
		infobox ( player, "Du musst am Schalter\ndes Verleihs stehen.", 5000, 125, 0, 0 )
		return
	end

	-- Regel aus dem alten Verleih: mit offenen Fahndungen keine Mietwagen.
	if ( tonumber ( MtxGetElementData ( player, "wanteds" ) ) or 0 ) > 0 then
		infobox ( player, "Mit offenen Fahndungen\nvermietet dir hier\nniemand ein Fahrzeug.", 5000, 125, 0, 0 )
		return
	end

	if not hasPlayerLicense ( player, angebot.modell ) then
		infobox ( player, "Dir fehlt der noetige\nFuehrerschein fuer\nden "..angebot.name.."!", 5000, 125, 0, 0 )
		return
	end

	local geld = MtxGetElementData ( player, "money" )
	if geld < angebot.preis then
		infobox ( player, "Du hast nicht genug\nGeld fuer den\n"..angebot.name.."!", 5000, 125, 0, 0 )
		return
	end

	local fahrzeug = createVehicle ( angebot.modell, VL_SPAWN[1], VL_SPAWN[2], VL_SPAWN[3], 0, 0, VL_SPAWN[4] )
	if not fahrzeug then
		infobox ( player, "Der Verleih konnte\nkein Fahrzeug\nbereitstellen.", 5000, 125, 0, 0 )
		outputDebugString ( "[Verleih] createVehicle fuer Modell "..angebot.modell.." fehlgeschlagen.", 1 )
		return
	end

	-- Geld erst abbuchen, wenn wirklich alles geklappt hat. Der alte Verleih
	-- zog es vor der Entfernungspruefung ab - wer zu weit weg stand, zahlte
	-- und bekam nichts.
	MtxSetElementData ( player, "money", geld - angebot.preis )

	MtxSetElementData ( fahrzeug, "verleihMieter", getPlayerName ( player ) )
	MtxSetElementData ( fahrzeug, "fuelstate", 100 )
	setVehicleLocked ( fahrzeug, false )

	vlRentals[player] = {
		fahrzeug = fahrzeug,
		name     = angebot.name,
		preis    = angebot.preis,
		ablauf   = getRealTime ().timestamp + VL_MIETDAUER,
		gewarnt  = false,
	}

	warpPedIntoVehicle ( player, fahrzeug )

	-- Das Aufgabensystem belohnt das Ausleihen eines Rollers. Der alte
	-- Verleih hat das ausgeloest, also muss es hier weiterlaufen.
	if angebot.modell == 462 then
		grantIntroTaskReward ( player, "give:Roller" )
	end

	infobox ( player, "Du hast einen "..angebot.name.."\nfuer "..formNumberToMoneyString ( angebot.preis ).."\ngemietet!", 5000, 0, 125, 0 )
	outputChatBox ( "Verleih: Die Miete läuft "..math.floor ( VL_MIETDAUER / 60 ).." Minuten. Verlängern mit /verleihverlaengern.", player, 0, 200, 0 )
	outputLog ( getPlayerName ( player ).." hat einen "..angebot.name.." gemietet ( "..angebot.preis.." )", "vehicle" )
end
addEvent ( "requestVerleih", true )
addEventHandler ( "requestVerleih", getRootElement(), function ( index )
	requestVerleih ( client, index )
end )

---------------------------------------------------------------------
-- Verlängern und Abgeben
---------------------------------------------------------------------

function verleihVerlaengern ( player )
	local miete = vlRentals[player]
	if not miete or not isElement ( miete.fahrzeug ) then
		outputChatBox ( "Du hast kein Fahrzeug gemietet.", player, 125, 0, 0 )
		return
	end

	local geld = MtxGetElementData ( player, "money" )
	if geld < miete.preis then
		infobox ( player, "Du brauchst "..formNumberToMoneyString ( miete.preis ).."\nzum Verlängern!", 5000, 125, 0, 0 )
		return
	end

	MtxSetElementData ( player, "money", geld - miete.preis )

	-- Ab dem bisherigen Ablauf weiterrechnen, nicht ab jetzt. Wer frueh
	-- verlaengert, verliert dadurch keine bereits bezahlte Zeit.
	local jetzt = getRealTime ().timestamp
	local basis = ( miete.ablauf > jetzt ) and miete.ablauf or jetzt
	miete.ablauf = basis + VL_MIETDAUER
	miete.gewarnt = false

	infobox ( player, "Miete verlaengert!\nNoch "..math.floor ( ( miete.ablauf - jetzt ) / 60 ).." Minuten.", 5000, 0, 125, 0 )
end
addCommandHandler ( "verleihverlaengern", verleihVerlaengern )

addCommandHandler ( "verleihabgeben", function ( player )
	if not vlRentals[player] then
		outputChatBox ( "Du hast kein Fahrzeug gemietet.", player, 125, 0, 0 )
		return
	end

	verleihBeenden ( player, "Du hast das Mietfahrzeug\nabgegeben." )
	outputChatBox ( "Verleih: Fahrzeug abgegeben.", player, 0, 200, 0 )
end )

---------------------------------------------------------------------
-- Ablauf ueberwachen
---------------------------------------------------------------------

setTimer ( function ()
	local jetzt = getRealTime ().timestamp

	for player, miete in pairs ( vlRentals ) do
		if not isElement ( player ) or not isElement ( miete.fahrzeug ) then
			vlRentals[player] = nil
		else
			local rest = miete.ablauf - jetzt

			if rest <= 0 then
				verleihBeenden ( player, "Deine Mietzeit ist\nabgelaufen - das\nFahrzeug wurde\nabgeholt." )
				outputChatBox ( "Verleih: Deine Mietzeit ist abgelaufen.", player, 200, 0, 0 )

			elseif rest <= VL_WARNUNG and not miete.gewarnt then
				miete.gewarnt = true
				outputChatBox ( "Verleih: Deine Miete läuft in "..math.ceil ( rest / 60 ).." Minuten ab! Verlängern mit /verleihverlaengern ( "..
								formNumberToMoneyString ( miete.preis ).." ).", player, 255, 165, 0 )
				infobox ( player, "Mietzeit läuft ab!\nNoch "..math.ceil ( rest / 60 ).." Minuten.\n/verleihverlaengern", 8000, 255, 165, 0 )
			end
		end
	end
end, VL_CHECK_TIME, 0 )

-- Beim Ausloggen endet die Miete.
addEventHandler ( "onPlayerQuit", getRootElement(), function ()
	verleihBeenden ( source )
end )

-- Explodiert der Wagen, ist die Miete ebenfalls vorbei.
addEventHandler ( "onVehicleExplode", getRootElement(), function ()
	for player, miete in pairs ( vlRentals ) do
		if miete.fahrzeug == source then
			verleihBeenden ( player, "Dein Mietfahrzeug\nwurde zerstoert." )
			break
		end
	end
end )

-- Nur der Mieter darf fahren. Mitfahren ist erlaubt.
addEventHandler ( "onVehicleStartEnter", getRootElement(), function ( player, seat )
	local mieter = MtxGetElementData ( source, "verleihMieter" )
	if not mieter or seat ~= 0 then
		return
	end

	if getPlayerName ( player ) ~= mieter then
		cancelEvent ()
		outputChatBox ( "Das ist ein Mietfahrzeug von "..mieter..".", player, 125, 0, 0 )
	end
end )
