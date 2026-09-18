--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Anschnallsystem - Client                       ||
--\\                                                  //

-- "j" ist bei ICE als einzige sinnvolle Buchstabentaste noch frei.
-- Alternativ gibt es den Befehl /gurt.
local GURT_TASTE = "j"

-- Ab welcher Aufprallstaerke ein Unfall gemeldet wird. Der Wert stammt aus
-- onClientVehicleCollision und ist ungefaehr die Wucht des Aufpralls.
-- Kleine Rempler liegen deutlich darunter.
local GURT_KRAFT = 0.75

-- Wieviel km/h der Aufprall mindestens vernichtet haben muss. Das ist der
-- eigentliche Unterschied zwischen "irgendwo entlanggeschrammt" und "frontal
-- gegen die Wand": nur ein echter Crash bremst schlagartig ab. Ohne diese
-- Pruefung reichte schon ein Streifen an der Leitplanke bei Stadttempo.
local GURT_MIN_ABFALL = 35

-- Zweiraeder ohne Gurt. Die Tabelle "bikes" ( settings.lua ) kennt Faggio (462)
-- und Pizzaboy (448) nicht - bikefalloff.lua und tuning_server.lua ergaenzen sie
-- ebenfalls einzeln. 481/509/510 sind die Fahrraeder.
local GURT_EXTRA_ZWEIRAEDER = { [448] = true, [462] = true, [481] = true, [509] = true, [510] = true }

local function istZweirad ( model )
	return ( bikes and bikes[model] ) or GURT_EXTRA_ZWEIRAEDER[model] or false
end

-- Tempo des eigenen Fahrzeugs beim letzten Messpunkt, um den Abfall messen zu
-- koennen. Beim Aufprall selbst ist die Geschwindigkeit bereits eingebrochen.
local letztesTempo = 0

-- Nicht bei jedem Blechschaden melden, sonst prasseln bei einer Karambolage
-- Dutzende Events auf den Server ein.
local GURT_PAUSE = 1500
local letzterUnfall = 0

local function istAngeschnallt ()
	return ( tonumber ( vioClientGetElementData ( "gurt" ) ) or 0 ) == 1
end

bindKey ( GURT_TASTE, "down", function ()
	if isPedInVehicle ( localPlayer ) then
		triggerServerEvent ( "toggleGurt", localPlayer )
	end
end )

addEventHandler ( "onClientVehicleCollision", root, function ( _, force )
	-- Nur das eigene Fahrzeug, und nur wenn man selbst darin sitzt.
	if getPedOccupiedVehicle ( localPlayer ) ~= source then
		return
	end

	-- Motorraeder/Fahrraeder haben ohnehin keinen Gurt (siehe toggleGurt im
	-- Server) und werden bereits ueber GTA's eigenes setPedCanBeKnockedOffBike
	-- (carsys/bikefalloff.lua) realistisch vom Sitz geworfen. Wuerde dieses
	-- System zusaetzlich eingreifen, ueberlagern sich beide Effekte und der
	-- Sturz wirkt doppelt so hart/haeufig wie im Auto.
	if istZweirad ( getElementModel ( source ) ) then
		return
	end

	if not force or force < GURT_KRAFT then
		return
	end

	if istAngeschnallt () then
		return
	end

	-- Tempoverlust pruefen: letztes Tempo vor dem Aufprall gegen das jetzige.
	local vx, vy = getElementVelocity ( source )
	local jetzigesTempo = ( vx*vx + vy*vy ) ^ 0.5 * 180
	if letztesTempo - jetzigesTempo < GURT_MIN_ABFALL then
		return
	end

	local jetzt = getTickCount ()
	if jetzt - letzterUnfall < GURT_PAUSE then
		return
	end
	letzterUnfall = jetzt

	-- Das Tempo prueft der Server selbst nach, hier geht es nur um die Meldung.
	triggerServerEvent ( "gurtUnfall", localPlayer )
end )

---------------------------------------------------------------------
-- Motorrad-/Fahrrad-Stuerze: Liege-Animation nachziehen
---------------------------------------------------------------------
-- Bikes werden oben bewusst von der eigenen Unfall-Erkennung ausgenommen -
-- GTA wirft den Fahrer bei einem harten Sturz bereits selbst vom Sitz
-- ( setPedCanBeKnockedOffBike in carsys/bikefalloff.lua ). MTA feuert dafuer
-- aber KEIN eigenes Event - und "onClientVehicleExit" ist beim nativen
-- Rauswurf vom Bike nachweislich unzuverlaessig (bekannter MTA-Bug, feuert
-- oft gar nicht). Deshalb wird hier stattdessen jeden Frame nachgeschaut, ob
-- der Spieler eben noch auf einem Bike sass und es jetzt ploetzlich nicht
-- mehr tut - bei ausreichendem Tempo im letzten bekannten Moment kann das nur
-- ein Sturz gewesen sein. Dann wird nur die "liegen bleiben"-Animation
-- nachgezogen ( ohne Extra-Wurf/-Schaden, das hat GTA schon selbst erledigt ).
-- Bewusst niedriger als GURT_MIN_TEMPO im Server (70): vom Motorrad fliegt man
-- realistisch schon bei geringerem Tempo, und den Wurf hat GTA hier ohnehin
-- selbst erledigt - hier kommt nur noch die Liege-Animation dazu.
local GURT_BIKE_MIN_TEMPO = 55   -- km/h
local GURT_BIKE_PAUSE     = 1500
local letzterBikeSturz    = 0

local grWarAufBike   = false
local grLetztesTempo = 0

-- Laeuft als Timer statt in onClientPreRender: die Erkennung braucht nur den
-- Wechsel "sass auf dem Bike -> sitzt nicht mehr", keine Frame-Genauigkeit.
local GURT_MESS_INTERVALL = 50   -- ms

setTimer ( function ()
	local veh = getPedOccupiedVehicle ( localPlayer )
	local istBike = false

	if veh then
		istBike = istZweirad ( getElementModel ( veh ) )
		-- Fuer den Tempoabfall beim Auto-Unfall: beim Aufprall selbst ist die
		-- Geschwindigkeit bereits eingebrochen, deshalb hier laufend merken.
		local vx, vy = getElementVelocity ( veh )
		letztesTempo = ( vx*vx + vy*vy ) ^ 0.5 * 180
	else
		letztesTempo = 0
	end

	if istBike then
		grLetztesTempo = letztesTempo
		grWarAufBike = true
		return
	end

	-- War eben noch auf einem Bike, jetzt nicht mehr - und das nicht durch
	-- normales, langsames Aussteigen ( dann waere das Tempo niedrig ).
	if grWarAufBike and grLetztesTempo >= GURT_BIKE_MIN_TEMPO then
		local jetzt = getTickCount ()
		if jetzt - letzterBikeSturz >= GURT_BIKE_PAUSE then
			letzterBikeSturz = jetzt
			-- Das Tempo prueft der Server selbst nach ( gleiche Absicherung
			-- wie beim Auto-Unfall ), hier geht es nur um die Meldung.
			triggerServerEvent ( "gurtBikeSturz", localPlayer )
		end
	end

	grWarAufBike   = false
	grLetztesTempo = 0
end, GURT_MESS_INTERVALL, 0 )

---------------------------------------------------------------------
-- Anzeige
---------------------------------------------------------------------

-- Das Gurtsymbol zeichnet der Tacho ( carsys/tacho/speedo_C.lua ), weil es
-- dort zwischen die uebrigen Statussymbole gehoert und nur die Tachodatei
-- deren Anordnung kennt. Sie liest den Zustand aus dem Element-Data "gurt".
--
-- Hier bleibt nur ein Hinweis beim Einsteigen, damit Neulinge die Taste
-- ueberhaupt erfahren.
addEventHandler ( "onClientVehicleEnter", root, function ( player, seat )
	if player ~= localPlayer or seat ~= 0 then
		return
	end

	outputChatBox ( "Anschnallen mit ["..string.upper ( GURT_TASTE ).."] oder /gurt.", 200, 200, 0 )
end )
