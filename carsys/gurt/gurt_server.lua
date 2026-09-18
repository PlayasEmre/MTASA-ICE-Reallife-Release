--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Anschnallsystem - Server                       ||
--\\                                                  //

-- Ab diesem Tempo kann ein Aufprall den Fahrer hinausschleudern. Bewusst
-- deutlich ueber Stadttempo: darunter ist es ein Blechschaden, kein Unfall.
-- Der Client prueft zusaetzlich Aufprallwucht UND Tempoverlust, siehe
-- GURT_KRAFT und GURT_MIN_ABFALL in gurt_client.lua.
local GURT_MIN_TEMPO = 70     -- km/h
local GURT_SCHADEN   = 25     -- Lebenspunkte beim Herausfliegen
local GURT_SCHUB     = 1.35   -- wie stark man weitergeschleudert wird

-- Ab dieser Fahrzeug-Gesundheit haelt der Gurt niemanden mehr fest ( GTA laesst
-- Fahrzeuge ab ca. 250 brennen ) - sonst waere er im brennenden Auto toedlich.
local GURT_NOTAUSSTIEG_HP = 400

-- Zweiraeder ohne Gurt. "bikes" ( settings.lua ) kennt Faggio (462) und
-- Pizzaboy (448) nicht. 481/509/510 sind die Fahrraeder.
local GURT_EXTRA_ZWEIRAEDER = { [448] = true, [462] = true, [481] = true, [509] = true, [510] = true }

local function istZweirad ( model )
	return ( bikes and bikes[model] ) or GURT_EXTRA_ZWEIRAEDER[model] or false
end

-- Nach dem Sturz bleibt der Spieler kurz liegen. GTA SA hat leider KEINE
-- durchgehende "krampft/windet sich vor Schmerz"-Animation im Standardpaket -
-- nur kurze, statische Sturz-Reaktionen aus dem Block "ped". Um trotzdem einen
-- krampfenden Eindruck zu erzeugen, wird periodisch zwischen mehreren dieser
-- Reaktionen gewechselt statt eine einzige starre Pose zu halten.
local GURT_LIEGE_MS    = 15000

-- Jeder Eintrag ist { Block, Animation }.
local GURT_KRAMPF_ANIMS = {
	{ "CRACK", "crckdeth2" },
	{ "ped",   "FLOOR_hit" },
	{ "ped",   "FLOOR_hit_f" },
}
local GURT_KRAMPF_INTERVALL = 900   -- ms zwischen den Animationswechseln

-- Wartezeit nach dem Herausschleudern, bevor die Liege-Animation gesetzt wird
-- - der Wurfimpuls (setElementVelocity) braucht diese Zeit noch, um den
-- Spieler tatsaechlich vom Fahrzeug wegzutragen bzw. GTA's eigene Sturz-
-- Reaktion muss erst abklingen, sonst ueberschreibt sie unsere Animation
-- sofort wieder.
local GURT_FREEZE_DELAY     = 500    -- ms, Standard-/Bike-Fall (GTA hat den Wurf schon VOR unserer Erkennung erledigt)
local GURT_CAR_FREEZE_DELAY = 1200   -- ms, Auto-Unfall (wir werfen hier selbst noch per setElementVelocity - braucht mehr Zeit zum Landen)

-- Wie oft waehrend der Liegezeit die Geschwindigkeit auf 0 gesetzt wird, statt
-- den Spieler hart einzufrieren. setElementFrozen() hat sich als Ursache
-- dafuer herausgestellt, dass die Animation NICHT sichtbar war - offenbar
-- setzt Einfrieren die sichtbare Pose auf die Standard-Steh-Haltung zurueck
-- und blockiert laufende Custom-Animationen. Das sanfte "Tempo staendig auf 0
-- setzen" haelt den Spieler ungefaehr an Ort und Stelle, ohne dieses Problem.
local GURT_ANTIDRIFT_MS = 200

-- Laesst den Spieler ein paar Sekunden liegen bleiben ( KO-Animation ). Wird
-- sowohl beim Auto-Unfall ( nach Wurf/Schaden ) als auch beim Motorrad-Sturz
-- ( wo GTA den Wurf/Schaden schon selbst erledigt hat ) benutzt, damit diese
-- Logik nur an einer Stelle steht.
-- "verzoegerung" ist einstellbar, weil der Auto-Unfall den Spieler selbst
-- noch per setElementVelocity durch die Luft wirft ( GURT_SCHUB ) - da braucht
-- es mehr Zeit, bis er tatsaechlich gelandet ist, als beim Motorrad-Sturz, wo
-- GTA den Wurf schon VOR unserer Erkennung erledigt hat. Setzen wir die
-- Animation zu frueh (noch mitten im Flug), "friert" ihn die Anti-Drift-
-- Geschwindigkeitssperre direkt in der Luft/auf halbem Weg stehend ein.
-- Laufende Liege-Timer je Spieler. Ohne diese Verwaltung liefen die Timer nach
-- einem Skinwechsel, Adminmodus, Tod oder einem zweiten Unfall einfach weiter
-- und setzten Animation und Tempo immer wieder neu - der Spieler landete dann
-- scheinbar grundlos erneut am Boden.
local liegeTimer = {}

-- Beendet das Liegen sofort: alle Timer weg, Steuerung zurueck, Animation
-- geloest. Global, damit andere Skripte (Skinwechsel, Adminmodus) das ebenfalls
-- aufrufen koennen.
function beendeGurtLiegen ( player )
	if liegeTimer[player] then
		for i = 1, #liegeTimer[player] do
			if isTimer ( liegeTimer[player][i] ) then
				killTimer ( liegeTimer[player][i] )
			end
		end
		liegeTimer[player] = nil
	end

	if isElement ( player ) then
		toggleAllControls ( player, true, true, true )
		if getElementHealth ( player ) > 0 and not isPedInVehicle ( player ) then
			setPedAnimation ( player )
		end
	end
end

local function lassLiegen ( player, verzoegerung )
	if not isElement ( player ) then
		return
	end

	-- Ein zweiter Unfall waehrend des Liegens wuerde sonst eine zweite
	-- Timerkette starten, die nach dem Aufstehen weiterlaeuft.
	beendeGurtLiegen ( player )
	liegeTimer[player] = {}

	verzoegerung = verzoegerung or GURT_FREEZE_DELAY

	toggleAllControls ( player, false, true, false )

	-- Die Animation NICHT sofort setzen: GTA's eigene Sturz-/Ragdoll-Reaktion
	-- laeuft im selben Moment und ueberschreibt eine sofort gesetzte Animation
	-- meist wieder, bevor sie ueberhaupt sichtbar wird.
	--
	-- "Krampfen": statt einer einzigen, starr gehaltenen Pose wird alle
	-- GURT_KRAMPF_INTERVALL ms zufaellig zwischen mehreren kurzen Sturz-
	-- Reaktionen gewechselt ( jede einzeln OHNE loop, kurz genug um vor dem
	-- naechsten Wechsel durchzulaufen ) - das erzeugt ein zuckendes, unruhiges
	-- Bild statt einer reglosen Leiche. setTimer kann keine abweichende erste
	-- Verzoegerung vor einer Wiederholungsserie - deshalb erst ein einmaliger
	-- Timer fuer "verzoegerung", der danach die eigentliche Wiederhol-Serie
	-- im GURT_KRAMPF_INTERVALL-Takt startet.
	liegeTimer[player][#liegeTimer[player]+1] = setTimer ( function ( p )
		if not ( isElement ( p ) and getElementHealth ( p ) > 0 ) then
			return
		end

		local function naechsteKrampfPose ( pp )
			if isElement ( pp ) and getElementHealth ( pp ) > 0 then
				local eintrag = GURT_KRAMPF_ANIMS[ math.random ( 1, #GURT_KRAMPF_ANIMS ) ]
				setPedAnimation ( pp, eintrag[1], eintrag[2], GURT_KRAMPF_INTERVALL, false, false, false )
			end
		end

		naechsteKrampfPose ( p )   -- sofort die erste Pose, nicht erst nach einem weiteren Intervall

		local krampfLaeufe = math.ceil ( ( GURT_LIEGE_MS - verzoegerung ) / GURT_KRAMPF_INTERVALL ) - 1
		if krampfLaeufe > 0 and liegeTimer[p] then
			liegeTimer[p][#liegeTimer[p]+1] = setTimer ( naechsteKrampfPose, GURT_KRAMPF_INTERVALL, krampfLaeufe, p )
		end
	end, verzoegerung, 1, player )

	-- Anti-Drift statt hartem Einfrieren, siehe Kommentar oben bei
	-- GURT_ANTIDRIFT_MS. Laeuft parallel zur Animation, damit der liegende
	-- Spieler nicht langsam wegrutscht, aber sichtbar liegen bleibt. Startet
	-- bewusst zeitgleich mit der Animation (nicht frueher), damit der
	-- Auto-Wurf vorher noch fertig ausfliegen kann.
	local antiDriftLaeufe = math.ceil ( ( GURT_LIEGE_MS - verzoegerung ) / GURT_ANTIDRIFT_MS )
	liegeTimer[player][#liegeTimer[player]+1] = setTimer ( function ( p )
		if isElement ( p ) and getElementHealth ( p ) > 0 and not isPedInVehicle ( p ) then
			setElementVelocity ( p, 0, 0, 0 )
		end
	end, verzoegerung + GURT_ANTIDRIFT_MS, antiDriftLaeufe, player )

	liegeTimer[player][#liegeTimer[player]+1] = setTimer ( function ( p )
		beendeGurtLiegen ( p )
	end, GURT_LIEGE_MS, 1, player )
end

-- Sobald der Spieler stirbt, neu spawnt, wieder einsteigt oder das Spiel
-- verlaesst, ist das Liegen vorbei. Ohne diese Haken liefen die Timer weiter
-- und warfen ihn spaeter erneut zu Boden.
addEventHandler ( "onPlayerWasted", getRootElement(), function () beendeGurtLiegen ( source ) end )
addEventHandler ( "onPlayerSpawn", getRootElement(), function () beendeGurtLiegen ( source ) end )
addEventHandler ( "onPlayerVehicleEnter", getRootElement(), function () beendeGurtLiegen ( source ) end )
addEventHandler ( "onPlayerQuit", getRootElement(), function () liegeTimer[source] = nil end )

-- Der Gurtzustand haengt am Spieler und wird als Element-Data gespiegelt,
-- damit der Tacho ihn anzeigen kann. Der Schluessel "gurt" steht dafuer in
-- der Sync-Liste in core/data.lua.
local function setzeGurt ( player, an )
	if not isElement ( player ) then
		return
	end

	MtxSetElementData ( player, "gurt", an and 1 or 0 )
end

---------------------------------------------------------------------
-- An- und Abschnallen
---------------------------------------------------------------------

function toggleGurt ( player )
	if not isElement ( player ) or MtxGetElementData ( player, "loggedin" ) ~= 1 then
		return
	end

	local veh = getPedOccupiedVehicle ( player )
	if not veh then
		outputChatBox ( "Du sitzt in keinem Fahrzeug.", player, 125, 0, 0 )
		return
	end

	-- Auf Zweiraedern und Fahrraedern gibt es nichts zum Anschnallen.
	if istZweirad ( getElementModel ( veh ) ) then
		outputChatBox ( "Hier gibt es keinen Gurt.", player, 125, 0, 0 )
		return
	end

	local an = ( tonumber ( MtxGetElementData ( player, "gurt" ) ) or 0 ) == 0
	setzeGurt ( player, an )

	if an then
		infobox ( player, "Angeschnallt.", 3000, 0, 125, 0 )
	else
		infobox ( player, "Gurt gelöst.", 3000, 200, 200, 0 )
	end
end
addCommandHandler ( "gurt", toggleGurt )

addEvent ( "toggleGurt", true )
addEventHandler ( "toggleGurt", getRootElement(), function ()
	toggleGurt ( client )
end )

---------------------------------------------------------------------
-- Unfall
---------------------------------------------------------------------

-- Der Client meldet einen harten Aufprall. Alles Weitere wird hier geprueft:
-- ein manipulierter Client koennte sonst andere Spieler herausschleudern
-- oder den eigenen Sturz vortaeuschen.
addEvent ( "gurtUnfall", true )
addEventHandler ( "gurtUnfall", getRootElement(), function ()
	local player = client
	if not isElement ( player ) or MtxGetElementData ( player, "loggedin" ) ~= 1 then
		return
	end

	if ( tonumber ( MtxGetElementData ( player, "gurt" ) ) or 0 ) == 1 then
		return
	end

	local veh = getPedOccupiedVehicle ( player )
	if not veh then
		return
	end

	-- Tempo hier selbst nachrechnen statt dem Client zu glauben. Bewusst nur
	-- die horizontale Geschwindigkeit (vx/vy), OHNE vz: sonst zaehlt ein
	-- simpler Sturz (hohe Fallgeschwindigkeit beim Aufprall) faelschlich als
	-- "schneller Aufprall" und schleudert den Spieler auch bei niedrigem
	-- Ortstempo heraus.
	local vx, vy, vz = getElementVelocity ( veh )
	local tempo = ( vx*vx + vy*vy ) ^ 0.5 * 180

	if tempo < GURT_MIN_TEMPO then
		return
	end

	local px, py, pz = getElementPosition ( player )

	removePedFromVehicle ( player )
	setElementPosition ( player, px, py, pz + 0.7 )
	setElementVelocity ( player, vx * GURT_SCHUB, vy * GURT_SCHUB, math.abs ( vz ) * GURT_SCHUB + 0.12 )

	local leben = getElementHealth ( player )
	setElementHealth ( player, math.max ( 5, leben - GURT_SCHADEN ) )

	-- Laengere Verzoegerung als beim Bike-Sturz, weil der Wurf hier gerade
	-- erst per setElementVelocity gestartet wurde und noch ausfliegen muss.
	lassLiegen ( player, GURT_CAR_FREEZE_DELAY )

	infobox ( player, "Du warst nicht\nangeschnallt!", 5000, 200, 0, 0 )
	outputChatBox ( "Du wurdest aus dem Fahrzeug geschleudert, weil du nicht angeschnallt warst.", player, 200, 0, 0 )
end )

---------------------------------------------------------------------
-- Motorrad-/Fahrrad-Sturz ( GTA hat den Fahrer bereits selbst vom Sitz
-- geworfen - hier wird nur die Liege-Animation nachgezogen, OHNE nochmal
-- Schaden oder Wurf zu verteilen )
---------------------------------------------------------------------

addEvent ( "gurtBikeSturz", true )
addEventHandler ( "gurtBikeSturz", getRootElement(), function ()
	local player = client
	if not isElement ( player ) or MtxGetElementData ( player, "loggedin" ) ~= 1 then
		return
	end

	-- Der Spieler ist zu diesem Zeitpunkt bereits ausgestiegen ( im
	-- Gegensatz zu gurtUnfall oben, wo er noch im Fahrzeug sitzt ) - hier gibt
	-- es also bewusst KEINE getPedOccupiedVehicle-Pruefung.
	lassLiegen ( player )

	infobox ( player, "Du bist vom\nMotorrad gestuerzt!", 5000, 200, 0, 0 )
	outputChatBox ( "Du bist vom Motorrad gestürzt!", player, 200, 0, 0 )
end )

---------------------------------------------------------------------
-- Angeschnallt = weniger Aufprallschaden
---------------------------------------------------------------------

local GURT_SCHADEN_FAKTOR = 0.4   -- angeschnallt bleiben 40 % des Schadens

addEventHandler ( "onPlayerDamage", getRootElement(), function ( attacker, weapon, bodypart, verlust )
	if not verlust or verlust <= 0 then
		return
	end
	if ( tonumber ( MtxGetElementData ( source, "gurt" ) ) or 0 ) ~= 1 then
		return
	end
	if not getPedOccupiedVehicle ( source ) then
		return
	end
	-- Schuesse und Schlaege federt kein Gurt ab.
	if isElement ( attacker ) and getElementType ( attacker ) == "player" then
		return
	end
	-- Nicht mit dem Sanitaeter-Transport ins Gehege kommen ( medic_server.lua ).
	if MtxGetElementData ( source, "medicTransportBy" ) then
		return
	end

	cancelEvent ()
	setElementHealth ( source, math.max ( 1, getElementHealth ( source ) - verlust * GURT_SCHADEN_FAKTOR ) )
end )

---------------------------------------------------------------------
-- Aussteigen nur ohne Gurt
---------------------------------------------------------------------

-- Damit die Meldung beim Gedruecktenhalten der Aussteigetaste nicht in
-- Dauerschleife im Chat landet.
local letzteMeldung = {}
local MELDE_PAUSE = 2000

addEventHandler ( "onVehicleStartExit", getRootElement(), function ( player, seat, jacker )
	if not isElement ( player ) then
		return
	end

	-- Wird jemand herausgezogen, greift der Gurt nicht. Sonst waere er ein
	-- Schutzschild gegen Carjacking, und das ist nicht sein Zweck.
	if jacker then
		return
	end

	if ( tonumber ( MtxGetElementData ( player, "gurt" ) ) or 0 ) ~= 1 then
		return
	end

	-- Notausstieg: brennendes/fast zerstoertes Fahrzeug haelt niemanden fest.
	if isElement ( source ) and getElementHealth ( source ) <= GURT_NOTAUSSTIEG_HP then
		setzeGurt ( player, false )
		infobox ( player, "Notausstieg!\nDer Gurt ist geloest.", 4000, 200, 100, 0 )
		return
	end

	cancelEvent ()

	local jetzt = getTickCount ()
	if ( jetzt - ( letzteMeldung[player] or 0 ) ) < MELDE_PAUSE then
		return
	end
	letzteMeldung[player] = jetzt

	infobox ( player, "Du bist angeschnallt.\nLoese zuerst den Gurt.", 4000, 200, 200, 0 )
end )

addEventHandler ( "onPlayerQuit", getRootElement(), function ()
	letzteMeldung[source] = nil
end )

---------------------------------------------------------------------
-- Zuruecksetzen
---------------------------------------------------------------------

-- Beim Aussteigen ist der Gurt selbstverstaendlich wieder offen. Ohne das
-- bliebe er beim naechsten Einsteigen faelschlich angelegt.
addEventHandler ( "onPlayerVehicleExit", getRootElement(), function ()
	setzeGurt ( source, false )
end )

addEventHandler ( "onPlayerWasted", getRootElement(), function ()
	setzeGurt ( source, false )
end )

---------------------------------------------------------------------
-- Gurtkontrolle der Staatsfraktionen
---------------------------------------------------------------------

local GURT_STRAFE         = 250   -- Bußgeld
local GURT_STVO_PUNKTE    = 1
local GURT_KONTROLL_WEITE = 12

local function gurtkontrolle ( player )
	if not isElement ( player ) or MtxGetElementData ( player, "loggedin" ) ~= 1 then
		return
	end
	if not isOnDuty ( player ) then
		outputChatBox ( "Nur im Dienst möglich.", player, 125, 0, 0 )
		return
	end

	-- Naechsten Spieler suchen, der in einem Fahrzeug sitzt.
	local px, py, pz = getElementPosition ( player )
	local ziel, beste = nil, GURT_KONTROLL_WEITE
	for _, p in ipairs ( getElementsByType ( "player" ) ) do
		if p ~= player and getPedOccupiedVehicle ( p ) then
			local x, y, z = getElementPosition ( p )
			local d = getDistanceBetweenPoints3D ( px, py, pz, x, y, z )
			if d < beste then
				ziel, beste = p, d
			end
		end
	end

	if not ziel then
		outputChatBox ( "Niemand in einem Fahrzeug in deiner Nähe.", player, 125, 0, 0 )
		return
	end

	local name = getPlayerName ( ziel )

	if istZweirad ( getElementModel ( getPedOccupiedVehicle ( ziel ) ) ) then
		outputChatBox ( name.." sitzt auf einem Zweirad - dort gibt es keinen Gurt.", player, 200, 200, 0 )
		return
	end

	if ( tonumber ( MtxGetElementData ( ziel, "gurt" ) ) or 0 ) == 1 then
		outputChatBox ( name.." ist angeschnallt.", player, 0, 150, 0 )
		outputChatBox ( getPlayerName ( player ).." hat deinen Gurt kontrolliert - alles in Ordnung.", ziel, 0, 150, 0 )
		return
	end

	takePlayerSaveMoney ( ziel, GURT_STRAFE )
	outputChatBox ( name.." war nicht angeschnallt - "..GURT_STRAFE.." "..Tables.waehrung.." Bußgeld.", player, 0, 150, 0 )
	outputChatBox ( "Du warst nicht angeschnallt! Bußgeld: "..GURT_STRAFE.." "..Tables.waehrung..".", ziel, 200, 0, 0 )

	-- StVO-Punkte nur mit Fuehrerschein, wie beim Blitzer ( speedcamera/server.lua ).
	if tonumber ( MtxGetElementData ( ziel, "carlicense" ) ) == 1 then
		local punkte = ( tonumber ( MtxGetElementData ( ziel, "stvo_punkte" ) ) or 0 ) + GURT_STVO_PUNKTE
		MtxSetElementData ( ziel, "stvo_punkte", punkte )
		if punkte >= 15 then
			outputChatBox ( "Du hast "..punkte.." StVO-Punkte, dein Führerschein wurde dir entzogen. Du musst die Führerscheinprüfung nun bei der Fahrschule wiederholen.", ziel, 200, 0, 0 )
			MtxSetElementData ( ziel, "stvo_punkte", 0 )
			MtxSetElementData ( ziel, "carlicense", 0 )
		end
	end
end
addCommandHandler ( "gurtkontrolle", gurtkontrolle )
addCommandHandler ( "gk", gurtkontrolle )
