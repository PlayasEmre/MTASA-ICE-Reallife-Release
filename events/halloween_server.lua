--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


-- 19320 ( "pumpkin01", ein echter Kürbis ) kommt aus der newmodels_red-
-- Resource ( siehe meta.xml: include ) - echte .dff/.txd/.col-Dateien aus dem
-- sampobj_red-Paket ( SA-MP-Objekt-ID 19320, siehe
-- newmodels_red/models/object/1337/pumpkin/ ), kein Standard-GTA-SA-Modell.
-- Deshalb ueber exports.newmodels_red:createObject statt dem normalen
-- createObject erzeugt.
local KUERBIS_MODELL = 19320
local KUERBIS_Z_VERSATZ = -0.3
local eggDeko = {}
local eggGold = {}
local GOLD_CHANCE = 8

local function zaehleLiegende ()
	local n = 0
	for i, obj in pairs ( kuerbisseInUse ) do
		if isElement ( obj ) then n = n + 1 end
	end
	return n
end

function createNewEasterEgg ()


	local rnd = math.random ( 1, #kuerbisOrte["x"] )

	if not isElement ( kuerbisseInUse[rnd] ) then
		local x, y, z = kuerbisOrte["x"][rnd], kuerbisOrte["y"][rnd], kuerbisOrte["z"][rnd]
		local gold = math.random ( 1, GOLD_CHANCE ) == 1
		eggGold[rnd] = gold

		kuerbisseInUse[rnd] = exports.newmodels_red:createObject ( KUERBIS_MODELL, x, y, z + KUERBIS_Z_VERSATZ )
		
		setElementFrozen ( kuerbisseInUse[rnd], true )
		setElementData ( kuerbisseInUse[rnd], "istKuerbis", true, true )
		if gold then
			setObjectScale ( kuerbisseInUse[rnd], 1.6 )
		end

		local r, g, b = 255, 140, 0
		if gold then r, g, b = 255, 220, 0 end
		eggDeko[rnd] = {
			createMarker ( x, y, z - 0.8, "cylinder", gold and 1.6 or 1.2, r, g, b, 100 )
		}

		local shape = createColSphere ( x, y, z, 2 )
		MtxSetElementData ( shape, "id", rnd )
		addEventHandler ( "onColShapeHit", shape, easterEggShapeHit )
	end
end


setTimer ( function ()
	for i, obj in pairs ( kuerbisseInUse ) do
		if isElement ( obj ) then
			local x, y, z = getElementPosition ( obj )
			moveObject ( obj, 5000, x, y, z, 0, 0, 180 )
		end
	end
end, 5000, 0 )

function easterEggShapeHit ( hit, dim )

	if getElementType ( hit ) == "player" and dim then
		local id = MtxGetElementData ( source, "id" )
		local gold = eggGold[id]
		local wert = gold and 5 or 1

		destroyElement ( kuerbisseInUse[id] )
		kuerbisseInUse[id] = false
		if eggDeko[id] then
			for k, el in ipairs ( eggDeko[id] ) do
				if isElement ( el ) then destroyElement ( el ) end
			end
			eggDeko[id] = nil
		end
		eggGold[id] = nil

		if gold then
			outputChatBox ( "Ein GOLDENER Kürbis! Er zählt fünffach.", hit, 255, 220, 0 )
		else
			outputChatBox ( "Du hast einen Kürbis gefunden!", hit, 0, 200, 0 )
		end
		outputChatBox ( "Einlösen kannst du ihn am Halloween-Stand beim Bahnhof San Fierro.", hit, 0, 200, 0 )
		triggerClientEvent ( hit, "achievsound", hit )
		MtxSetElementData ( hit, "kuerbisse", MtxGetElementData ( hit, "kuerbisse" ) + wert )

		outputChatBox ( "*** "..getPlayerName ( hit ).." hat einen "..( gold and "goldenen " or "" ).."Kürbis gefunden - noch "..zaehleLiegende ().." liegen draußen!", getRootElement(), 255, 140, 0 )

		destroyElement ( source )
	end
end

kuerbisseInUse = {}
kuerbisOrte = {}
	kuerbisOrte["x"] = {}
	kuerbisOrte["y"] = {}
	kuerbisOrte["z"] = {}

i = 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = 1452.2470703125, 2773.8037109375, 27.44654083252
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = 1098.533203125, 1609.5556640625, 12.546875
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = 1680.1494140625, 1447.0087890625, 14.914985656738
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = 2323.671875, 1283.1884765625, 97.617256164551
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = 2116.94921875, 1683.2900390625, 13.005955696106
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = 2092.8271484375, 2414.6416015625, 74.578598022461
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = 2729.10546875, 2685.81640625, 59.0234375
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = 2429.1806640625, 1812.7421875, 38.8203125
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = 2435.322265625, 1662.9140625, 15.645471572876
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = 2496.2763671875, 926.8359375, 16.912689208984
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = 1456.1669921875, 751.056640625, 32.739742279053
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = 619.8115234375, 886.654296875, -29.805267333984
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -18.4912109375, 1180.462890625, 31.808807373047
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -367.3916015625, 1581.171875, 76.118301391602
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -733.568359375, 1546.439453125, 38.997997283936
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -1531.625, 687.3037109375, 133.05139160156
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -1510.7578125, 1372.123046875, 3.2004470825195
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -1664.9306640625, 1380.4345703125, 7.8754863739014
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -2366.6455078125, 1536.1435546875, 2.1171875
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -2681.5517578125, 1598.189453125, 3.2226257324219
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -2819.5126953125, 1080.1904296875, 27.7421875
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -2773.7197265625, 783.8798828125, 65.715576171875
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -2346.888671875, 536.8095703125, 77.403594970703
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -2029.1767578125, 156.51953125, 33.938232421875
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -2218.2744140625, -341.935546875, 44.796802520752
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -2481.9921875, -285.6875, 40.546653747559
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -2315.6298828125, 198.23046875, 35.3984375
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -2341.3056640625, 1008.3974609375, 55.9150390625
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -1131.2314453125, 854.5361328125, 3.0703125
i = i + 1
kuerbisOrte["x"][i], kuerbisOrte["y"][i], kuerbisOrte["z"][i] = -1475.91015625, 150.751953125, 18.7734375

---------------------------------------------------------------------
-- Zombie-Nacht
---------------------------------------------------------------------
-- Wellenkampf in einer eigenen Dimension: Minigun rein, Zombies laufen auf
-- den Spieler zu, jeder fuenfte Abschuss gibt einen Kürbis. Die eigene
-- Dimension je Spieler sorgt dafuer, dass sich mehrere Laeufe nicht sehen und
-- die Zombies niemanden in der normalen Welt stoeren.
local Z_ARENA        = { 402.0, 2460.0, 17.0 }   -- Verdant Meadows, freies Feld
local Z_WELLEN       = 5
local Z_PRO_KUERBIS  = 4      -- so viele Abschuesse geben einen Kürbis
local Z_COOLDOWN     = 60 * 60 * 1000   -- 1 Stunde Cooldown nach einer Runde
local zCooldown      = {}     -- Spieler -> Zeitpunkt, ab dem er wieder darf
-- Skin-Palette aus "Zday script" ( slothman, MTA-Community-Resource 347 ),
-- 192 und 229 fehlen bewusst - Kollision mit fun/Museumraub, siehe
-- events/halloween_client.lua ( zombieNachtSkinsAn ).
local Z_MODELLE = {13,22,56,67,68,69,70,92,97,105,107,108,126,127,128,152,162,167,188,195,206,209,212,230,258,264,277,280,287}
local Z_SCHADEN      = 4      -- Lebenspunkte je Treffer eines Zombies
local Z_REICHWEITE   = 1.8    -- ab dieser Naehe schlaegt ein Zombie zu
local Z_TAKT         = 500    -- wie oft die Zombies neu ausgerichtet werden
local Z_GESCHW       = 1.4    -- Gehgeschwindigkeit in m/s - schleichend, kein Sprint

local zLauf      = {}   -- Spieler -> laufende Runde
local zBesitzer  = {}   -- Zombie  -> Spieler
local zNaechsteDim = 900

-- Global ( kein "local" ), damit anticheat/anticheat_server.lua die Minigun
-- ( Waffen-ID 38 ) nur waehrend einer laufenden Runde erlauben kann - die
-- Anti-Cheat sperrt diese Waffe sonst serverweit mit sofortigem Kick.
function istInZombieNacht ( player )
	return zLauf[player] ~= nil
end

local function zSpawneWelle ( player )

	local lauf = zLauf[player]
	if not lauf then return end

	lauf.welle = lauf.welle + 1
	if lauf.welle > Z_WELLEN then
		beendeZombieNacht ( player, true )
		return
	end

	local anzahl = 6 + lauf.welle * 3
	for i = 1, anzahl do
		local winkel = ( i / anzahl ) * math.pi * 2
		local zombie = createPed ( Z_MODELLE[math.random(1,#Z_MODELLE)],
			Z_ARENA[1] + math.cos ( winkel ) * 14,
			Z_ARENA[2] + math.sin ( winkel ) * 14,
			Z_ARENA[3] )
		setElementDimension ( zombie, lauf.dim )
		-- "Player_Sneak" laesst den Ped schleichend anrollen statt regungslos
		-- zur naechsten Position zu gleiten ( vorher fehlte jede Animation ).
		setPedAnimation ( zombie, "ped", "Player_Sneak", -1, true, true, false )
		lauf.zombies[zombie] = true
		zBesitzer[zombie] = player
		triggerClientEvent ( player, "zombieNachtStoehnen", player,
			Z_ARENA[1] + math.cos ( winkel ) * 14, Z_ARENA[2] + math.sin ( winkel ) * 14, Z_ARENA[3] )
	end

	outputChatBox ( "Welle "..lauf.welle.." von "..Z_WELLEN.." - "..anzahl.." Zombies!", player, 255, 140, 0 )
end

function starteZombieNacht ( player )

	if not event.isHalloween or zLauf[player] then return end
	if zCooldown[player] and zCooldown[player] > getTickCount () then
		local rest = math.ceil ( ( zCooldown[player] - getTickCount () ) / 60000 )
		outputChatBox ( "Zombie-Nacht: du musst noch "..rest.." Minute(n) warten, bevor du wieder rein kannst.", player, 255, 140, 0 )
		return
	end

	local x, y, z = getElementPosition ( player )
	local zurueckDim = getElementDimension ( player )
	if zurueckDim >= 900 then
		-- Der Spieler steckt schon in einer Zombie-Dimension, obwohl keine
		-- Runde bekannt ist ( Reste einer fruehreren, abgebrochenen Runde ).
		-- Als Rueckweg darf das nie gespeichert werden, sonst wandert die
		-- Kaputtheit in die naechste Runde mit. 0 ist immer sicher.
		zurueckDim = 0
	end
	local zurueckInterior = zurueckDim == 0 and 0 or getElementInterior ( player )
	zNaechsteDim = zNaechsteDim + 1

	zLauf[player] = {
		dim     = zNaechsteDim,
		zombies = {},
		welle   = 0,
		kills   = 0,
		zurueck = { x, y, z, zurueckInterior, zurueckDim }
	}

	setElementInterior ( player, 0 )
	setElementDimension ( player, zNaechsteDim )
	setElementPosition ( player, Z_ARENA[1], Z_ARENA[2], Z_ARENA[3] )
	giveWeapon ( player, 38, 3000, true )
	-- Erzwingen statt hoffen: an anderer Stelle in ICE gibt es ueber ein
	-- Dutzend Systeme ( Rathaus, Stripclub, Casino-Ueberfall, Tactic-Modus,
	-- ... ), die "fire"/"aim_weapon" abschalten und nicht in jedem Fall
	-- garantiert wieder einschalten. Damit das die Minigun hier nicht
	-- lahmlegt, werden beide Controls beim Start hart erzwungen.
	toggleControl ( player, "fire", true )
	toggleControl ( player, "aim_weapon", true )
	toggleControl ( player, "next_weapon", true )
	toggleControl ( player, "previous_weapon", true )
	MtxSetElementData ( player, "nodmzone", 0 )
	triggerClientEvent ( player, "zombieNachtSkinsAn", player )

	outputChatBox ( "Zombie-Nacht! Überlebe "..Z_WELLEN.." Wellen. Jeder "..Z_PRO_KUERBIS..". Abschuss gibt einen Kürbis.", player, 255, 140, 0 )
	zSpawneWelle ( player )
end

function beendeZombieNacht ( player, geschafft )

	local lauf = zLauf[player]
	if not lauf then return end
	zLauf[player] = nil
	zCooldown[player] = getTickCount () + Z_COOLDOWN

	for zombie in pairs ( lauf.zombies ) do
		zBesitzer[zombie] = nil
		if isElement ( zombie ) then destroyElement ( zombie ) end
	end

	if isElement ( player ) then
		takeAllWeapons ( player )
		-- Direkt danach noch auf "unbewaffnet" zwingen: takeAllWeapons allein
		-- liess in Kombination mit dem gleichzeitigen Dimensionswechsel unten
		-- die Minigun clientseitig sichtbar in der Hand haengen, obwohl der
		-- Server sie schon nicht mehr fuehrte.
		setPedWeaponSlot ( player, 0 )
		triggerClientEvent ( player, "zombieNachtSkinsAus", player )
		setElementInterior ( player, lauf.zurueck[4] )
		setElementDimension ( player, lauf.zurueck[5] )
		setElementPosition ( player, lauf.zurueck[1], lauf.zurueck[2], lauf.zurueck[3] )
		-- Harte Nachkontrolle direkt hier, nicht nur im /zombieende-Befehl -
		-- damit auch der normale Sieg ( "geschafft" ) und der Tod garantiert
		-- aus der Zombie-Dimension herauskommen, selbst wenn "zurueck" durch
		-- eine fruehere kaputte Runde einmal einen falschen Wert enthielt.
		if getElementDimension ( player ) >= 900 then
			setElementInterior ( player, 0 )
			setElementDimension ( player, 0 )
			setElementPosition ( player, STAND_X, STAND_Y, STAND_Z )
		end
		if geschafft then
			outputChatBox ( "Alle Wellen überstanden! "..lauf.kills.." Zombies erledigt.", player, 0, 200, 0 )
		else
			outputChatBox ( "Zombie-Nacht beendet. "..lauf.kills.." Zombies erledigt.", player, 200, 0, 0 )
		end

		-- Nachkontrolle mit Verzoegerung: takeAllWeapons/setPedWeaponSlot direkt
		-- beim Dimensionswechsel hat die Minigun beim Sieg-Pfad manchmal nicht
		-- entfernt ( vermutlich Race Condition mit dem clientseitigen Sync ).
		-- Nach 500ms noch einmal hart nachpruefen und entfernen.
		setTimer ( function ()
			if isElement ( player ) then
				-- takeWeapon auf eine Waffe, die der Spieler nicht ( mehr ) hat,
				-- ist ein harmloses No-Op - kein Grund, das vorher zu pruefen.
				takeWeapon ( player, 38 )
				setPedWeaponSlot ( player, 0 )
			end
		end, 500, 1 )
	end
end

-- Ein gemeinsamer Timer fuer alle laufenden Runden statt einem je Zombie.
setTimer ( function ()
	for player, lauf in pairs ( zLauf ) do
		if not isElement ( player ) then
			zLauf[player] = nil
		else
			local px, py, pz = getElementPosition ( player )
			for zombie in pairs ( lauf.zombies ) do
				if isElement ( zombie ) and getElementHealth ( zombie ) > 0 then
					local zx, zy, zz = getElementPosition ( zombie )
					local richtung = math.deg ( math.atan2 ( px - zx, py - zy ) ) * -1
					setPedRotation ( zombie, richtung )
					local abstand = ( ( px - zx )^2 + ( py - zy )^2 + ( pz - zz )^2 ) ^ 0.5
					if abstand <= Z_REICHWEITE then
						-- Nah dran: zuschlagen statt weiter auf der Stelle zu
						-- "laufen". getElementData spart ein setPedAnimation pro
						-- Takt, sobald die Schlag-Animation schon laeuft.
						if getElementData ( zombie, "greift_an" ) ~= true then
							setPedAnimation ( zombie, "ped", "kick_ped_char", -1, true, true, false )
							setElementData ( zombie, "greift_an", true, false )
						end
						local hp = getElementHealth ( player )
						if hp <= Z_SCHADEN then
							killPed ( player )
						else
							setElementHealth ( player, hp - Z_SCHADEN )
						end
					else
						if getElementData ( zombie, "greift_an" ) == true then
							setPedAnimation ( zombie, "ped", "Player_Sneak", -1, true, true, false )
							setElementData ( zombie, "greift_an", false, false )
						end
						-- setPedControlState ist eine reine Client-Funktion und
						-- existiert serverseitig nicht. GTA-Geschwindigkeitswerte
						-- fuer setElementVelocity sind nicht direkt in m/s
						-- umzurechnen, deshalb Position pro Takt direkt schrittweise
						-- Richtung Spieler versetzen - das ist vorhersagbar in m/s.
						local schritt = Z_GESCHW * ( Z_TAKT / 1000 )
						local winkel = math.rad ( richtung )
						setElementPosition ( zombie, zx - math.sin ( winkel ) * schritt, zy + math.cos ( winkel ) * schritt, zz )
					end
					-- Stoehnen: haeufiger als vorher, sonst faellt es bei ein
					-- paar Zombies kaum auf.
					if math.random ( 1, 8 ) == 1 then
						triggerClientEvent ( player, "zombieNachtStoehnen", player, zx, zy, zz )
					end
				end
			end
		end
	end
end, Z_TAKT, 0 )

addEventHandler ( "onPedWasted", getRootElement(), function ()

	local player = zBesitzer[source]
	if not player then return end
	zBesitzer[source] = nil

	local lauf = zLauf[player]
	if not lauf then return end
	lauf.zombies[source] = nil
	lauf.kills = lauf.kills + 1

	if lauf.kills % Z_PRO_KUERBIS == 0 then
		MtxSetElementData ( player, "kuerbisse", MtxGetElementData ( player, "kuerbisse" ) + 1 )
		outputChatBox ( "Kürbis erhalten! ( "..lauf.kills.." Zombies )", player, 0, 200, 0 )
	end

	-- Welle leer? Dann die naechste, nach kurzer Verschnaufpause.
	if not next ( lauf.zombies ) then
		outputChatBox ( "Welle geschafft - die nächste kommt in 5 Sekunden.", player, 255, 140, 0 )
		setTimer ( zSpawneWelle, 5000, 1, player )
	end
end )

addEventHandler ( "onPlayerWasted", getRootElement(), function ()
	beendeZombieNacht ( source, false )
end )

addEventHandler ( "onPlayerQuit", getRootElement(), function ()
	beendeZombieNacht ( source, false )
end )

addCommandHandler ( "zombieende", function ( player )
	if zLauf[player] then
		beendeZombieNacht ( player, false )
	end
	-- Nachkontrolle statt reinem Entweder-Oder: eine fruehere kaputte Runde
	-- kann als "zurueck"-Ziel selbst schon eine Zombie-Dimension gespeichert
	-- haben ( wenn z.B. ein Serverfehler zwischen zwei Versuchen lag ) - dann
	-- haette beendeZombieNacht oben gerade dorthin zurueckgesetzt. Deshalb
	-- hier IMMER hart nachpruefen und noetigenfalls zusaetzlich korrigieren.
	if getElementDimension ( player ) >= 900 then
		takeAllWeapons ( player )
		setPedWeaponSlot ( player, 0 )
		triggerClientEvent ( player, "zombieNachtSkinsAus", player )
		setElementInterior ( player, 0 )
		setElementDimension ( player, 0 )
		setElementPosition ( player, STAND_X, STAND_Y, STAND_Z )
		outputChatBox ( "Zurückgesetzt.", player, 200, 0, 0 )
	end
end )

---------------------------------------------------------------------
-- Halloween-Stand am Bahnhof San Fierro
---------------------------------------------------------------------
-- Feste Anlaufstelle zum Einlösen. Vorher fuehrte nur die Taste H ins Menue,
-- die kaum jemand kannte und die auch ausserhalb des Events belegt war.
-- Standort vom Spieler per /pos gemeldet.
STAND_X, STAND_Y, STAND_Z = -2045.624, 214.150, 35.827

-- Der Kürbis im Inventar ruft /halloween auf ( items/inventory_gui_client.lua
-- ueber events/halloween_client.lua ). Nur oeffnen, wenn der Spieler tatsaechlich
-- am Stand steht - sonst der Hinweis, wo er zu finden ist.
addEvent ( "pruefeHalloweenStandNaehe", true )
addEventHandler ( "pruefeHalloweenStandNaehe", getRootElement(), function ()
	local x, y, z = getElementPosition ( client )
	if getDistanceBetweenPoints3D ( x, y, z, STAND_X, STAND_Y, STAND_Z ) <= 5 then
		triggerClientEvent ( client, "oeffneHalloweenMenue", client )
	else
		outputChatBox ( "Der Halloween-Stand steht am Bahnhof San Fierro - er ist auf der Karte markiert.", client, 255, 140, 0 )
	end
end )

local function baueHalloweenStand ()

	-- Breite, lineare Anordnung entlang des Gehwegs statt eng im Kreis: drei
	-- Marker mit deutlichem Abstand ( 4.5 Einheiten ) nebeneinander, jeder
	-- NPC hinter seinem eigenen Marker statt davor/darauf, Deko in einer
	-- eigenen Reihe weiter hinten - nichts steht mehr im Laufweg.
	local haendler = createPed ( 155, STAND_X, STAND_Y + 1.5, STAND_Z, 180 )
	setElementFrozen ( haendler, true )
	-- ID fuer den Client: dort wird ueber dxDrawTextOnElement.lua
	-- ( dieselbe Funktion, die auch der Fahrzeugverleih & Co. nutzen )
	-- ein Text ueber dem Kopf gezeichnet.
	setElementID ( haendler, "halloweenHaendler" )
	-- Reine Deko-NPCs, kein Ziel: unverwundbar statt nur eingefroren.
	-- cancelEvent NICHT direkt als Handler ( bekommt sonst onPedDamage's
	-- eigene Parameter - z.B. den Schaden als Zahl - als sein eigenes
	-- "bool"-Argument uebergeben, das gibt eine Bad-Argument-Warnung im Log ).
	addEventHandler ( "onPedDamage", haendler, function () cancelEvent () end )

	-- Deko-Reihe deutlich hinter den Markern, mit echtem Abstand zueinander
	-- ( vorher standen Kessel/Sarg/Kürbisse fast aneinandergeklebt ).
	for i = -1, 1 do
		local deko = exports.newmodels_red:createObject ( KUERBIS_MODELL, STAND_X - 4.5 + i * 1.3, STAND_Y + 3.5, STAND_Z - 0.4 + KUERBIS_Z_VERSATZ )
		setElementFrozen ( deko, true )
		setElementData ( deko, "istKuerbis", true, true )
	end

	exports.newmodels_red:createObject ( 19527, STAND_X - 0.5, STAND_Y + 3.5, STAND_Z - 1 )             -- Cauldron1
	exports.newmodels_red:createObject ( 19622, STAND_X - 0.5, STAND_Y + 3.5, STAND_Z - 0.7, 0, 60, 0 ) -- Broom1, an den Kessel gelehnt
	exports.newmodels_red:createObject ( 19339, STAND_X + 2.0, STAND_Y + 3.5, STAND_Z - 1, 0, 0, 90 )   -- coffin01, eigener Platz statt an den Kürbissen
	exports.newmodels_red:createObject ( 19528, STAND_X + 2.0, STAND_Y + 3.5, STAND_Z + 0.3 )           -- WitchesHat1, oben auf dem Sarg

	-- Zweites Kessel/Besen- und Sarg/Hut-Paar gespiegelt an den Aussenkanten
	-- der Dekoreihe - macht den Stand voller, ohne neue Modelle zu brauchen
	-- ( nur bereits ueber newmodels_red installierte, geprueft funktionierende ).
	exports.newmodels_red:createObject ( 19527, STAND_X - 5.8, STAND_Y + 3.5, STAND_Z - 1 )             -- Cauldron2
	exports.newmodels_red:createObject ( 19622, STAND_X - 5.8, STAND_Y + 3.5, STAND_Z - 0.7, 0, 60, 180 ) -- Broom2
	exports.newmodels_red:createObject ( 19339, STAND_X + 5.3, STAND_Y + 3.5, STAND_Z - 1, 0, 0, 90 )   -- coffin02
	exports.newmodels_red:createObject ( 19528, STAND_X + 5.3, STAND_Y + 3.5, STAND_Z + 0.3 )           -- WitchesHat2

	-- Ein paar zusaetzliche Kürbisse locker um den Stand verteilt, nicht nur
	-- in der starren Dekoreihe - wirkt weniger wie eine aufgereihte Linie.
	local kuerbisStreu = {
		{ STAND_X - 3.2, STAND_Y + 0.8 },
		{ STAND_X + 3.2, STAND_Y + 0.8 },
		{ STAND_X - 1.6, STAND_Y + 4.6 },
		{ STAND_X + 1.6, STAND_Y + 4.6 },
	}
	for i = 1, #kuerbisStreu do
		local sx, sy = kuerbisStreu[i][1], kuerbisStreu[i][2]
		-- Zufaellige Drehung und leicht variierende Groesse statt lauter
		-- identischer Klone - wirkt weniger wie kopiert/eingefuegt.
		local streuDeko = exports.newmodels_red:createObject ( KUERBIS_MODELL, sx, sy, STAND_Z - 0.4 + KUERBIS_Z_VERSATZ, 0, 0, math.random ( 0, 359 ) )
		setElementFrozen ( streuDeko, true )
		setElementData ( streuDeko, "istKuerbis", true, true )
		setObjectScale ( streuDeko, 0.9 + math.random () * 0.4 )
	end

	-- Fackeln flankieren die gesamte Reihe aussen, plus ein zweites Paar
	-- weiter hinten bei der Dekoreihe fuer mehr Licht/Atmosphaere dort.
	createObject ( 3461, STAND_X - 6.0, STAND_Y - 0.5, STAND_Z )
	createObject ( 3461, STAND_X + 6.0, STAND_Y - 0.5, STAND_Z )
	createObject ( 3461, STAND_X - 6.0, STAND_Y + 3.5, STAND_Z )
	createObject ( 3461, STAND_X + 6.0, STAND_Y + 3.5, STAND_Z )

	-- Marker 1 ( lila, links ): Rangliste. Fragt live aus der Datenbank ab,
	-- nicht nur von online Spielern - "inventar.kuerbisse" wird bei jedem
	-- Speichern aktualisiert ( siehe register_login/register_login_server.lua ).
	local rangMarker = createMarker ( STAND_X - 4.5, STAND_Y - 2.0, STAND_Z - 1, "cylinder", 1.3, 180, 0, 220, 140 )
	addEventHandler ( "onMarkerHit", rangMarker, function ( hit, dim )
		if dim and getElementType ( hit ) == "player" then
			runAsync ( zeigeKuerbisRangliste, hit )
		end
	end )
	local hinweisRang = createColSphere ( STAND_X - 4.5, STAND_Y - 2.0, STAND_Z - 1, 2 )
	addEventHandler ( "onColShapeHit", hinweisRang, function ( hit, dim )
		if dim and getElementType ( hit ) == "player" then
			outputChatBox ( "Rangliste: hier siehst du, wer die meisten Kürbisse gefunden hat.", hit, 180, 0, 220 )
		end
	end )

	-- Marker 2 ( orange, Mitte ): Halloween-Menue.
	local marker = createMarker ( STAND_X, STAND_Y - 2.0, STAND_Z - 1, "cylinder", 1.3, 255, 140, 0, 120 )
	addEventHandler ( "onMarkerHit", marker, function ( hit, dim )
		if dim and getElementType ( hit ) == "player" and not isPedInVehicle ( hit ) then
			triggerClientEvent ( hit, "oeffneHalloweenMenue", hit )
		end
	end )
	local hinweisStand = createColSphere ( STAND_X, STAND_Y - 2.0, STAND_Z - 1, 2 )
	addEventHandler ( "onColShapeHit", hinweisStand, function ( hit, dim )
		if dim and getElementType ( hit ) == "player" then
			outputChatBox ( "Halloween-Stand: hier kannst du gesammelte Kürbisse gegen Belohnungen eintauschen.", hit, 255, 140, 0 )
		end
	end )

	-- Wache am Zombie-Marker: derselbe Ped-Pool wie die eigentlichen Zombies
	-- ( siehe Z_MODELLE ), aber ohne Animation - steht nur als Blickfang und
	-- Ankuendigung davor, nicht als Gegner. Hinter dem Marker, nicht davor.
	-- Boden steigt hier zur Seite hin an ( per /pos gemessen: an dieser Stelle
	-- liegt der echte Boden 0.316 hoeher als STAND_Z ) - deshalb eigener
	-- Hoehen-Ausgleich fuer diesen Bereich statt der flachen STAND_Z-Annahme.
	local ZOMBIE_BEREICH_Z = STAND_Z + 0.316
	local waechter = createPed ( 105, STAND_X + 4.5, STAND_Y + 1.0, ZOMBIE_BEREICH_Z - 0.4, 180 )
	setElementFrozen ( waechter, true )
	setPedAnimation ( waechter, "ped", "Player_Sneak", -1, true, true, false )
	setElementID ( waechter, "zombieNachtWaechter" )
	addEventHandler ( "onPedDamage", waechter, function () cancelEvent () end )

	-- Marker 3 ( rot, rechts ): Einstieg in die Zombie-Nacht.
	local zMarker = createMarker ( STAND_X + 4.5, STAND_Y - 2.0, ZOMBIE_BEREICH_Z - 1, "cylinder", 1.3, 120, 0, 0, 140 )
	addEventHandler ( "onMarkerHit", zMarker, function ( hit, dim )
		if dim and getElementType ( hit ) == "player" and not isPedInVehicle ( hit ) then
			starteZombieNacht ( hit )
		end
	end )
	local hinweisZombie = createColSphere ( STAND_X + 4.5, STAND_Y - 2.0, ZOMBIE_BEREICH_Z - 1, 2 )
	addEventHandler ( "onColShapeHit", hinweisZombie, function ( hit, dim )
		if dim and getElementType ( hit ) == "player" then
			outputChatBox ( "Zombie-Nacht: du bekommst eine Minigun und musst 5 Wellen Zombies überleben - jeder 5. Abschuss gibt einen Kürbis. Betreten startet die Runde sofort!", hit, 255, 140, 0 )
		end
	end )

end

function zeigeKuerbisRangliste ( player )
	local ergebnis = dbQueryCoro (
		"SELECT p.Name AS Name, i.kuerbisse AS kuerbisse FROM inventar i "..
		"JOIN players p ON p.UID = i.UID "..
		"WHERE i.kuerbisse > 0 ORDER BY i.kuerbisse DESC LIMIT 10"
	)
	if not ergebnis or #ergebnis == 0 then
		outputChatBox ( "Noch hat niemand einen Kürbis gefunden.", player, 200, 0, 0 )
		return
	end

	outputChatBox ( "=== Kürbis-Rangliste ===", player, 180, 0, 220 )
	for i = 1, #ergebnis do
		outputChatBox ( i..". "..ergebnis[i]["Name"].." - "..ergebnis[i]["kuerbisse"].." Kürbisse", player, 255, 140, 0 )
	end
end

-- newmodels_red ist als <include> eingebunden, startet aber nicht zwingend
-- VOR diesem Skript fertig - der Kürbis-Aufbau ( braucht dessen
-- createObject-Export ) wird deshalb um eine Sekunde verzoegert, statt sich
-- auf die reine Ladereihenfolge zu verlassen.
if event.isHalloween then
	setTimer ( function ()
		baueHalloweenStand ()

		-- Duesteres Wetter fuer die Dauer des Events. Das Zufallswetter aus
		-- environment/weather.lua ist dafuer stillgelegt, laeuft danach weiter.
		setWeather ( 8 )

		for i = 1, 30 do
			createNewEasterEgg ()
		end
		setTimer ( createNewEasterEgg, 60000, 0 )
	end, 1000, 1 )
end

function buyEasterBonus ( item )
	local player = client
	if not event.isHalloween then return end
	local eggs = MtxGetElementData ( player, "kuerbisse" )
	if item == "premium" then
		if eggs >= 60 then
		if MtxGetElementData ( player, "premium" ) == false then
			MtxSetElementData ( player, "kuerbisse", eggs - 60 )
			setPremiumData(player,30,3)
			outputChatBox ( "Du hast für 30 Tage Premium geschenkt gekriegt", player, 0, 253, 0 )
		else
			outputChatBox ( "Du hast bereits Premium", player, 200, 0, 0 )
		end
		else
		   outputChatBox ( "Du hast nicht genug Kürbisse!", player, 200, 0, 0 )
		end
	end	
	if item == "zombieskin" then
		if MtxGetElementData ( player, "hatHalloweenSkin" ) == true then
			outputChatBox ( "Du hast den Zombie-Skin schon freigeschaltet. Tippe /zombieskin zum Umschalten.", player, 200, 0, 0 )
		elseif eggs >= 40 then
			MtxSetElementData ( player, "kuerbisse", eggs - 40 )
			MtxSetElementData ( player, "hatHalloweenSkin", true )
			outputChatBox ( "Du hast den exklusiven Zombie-Skin freigeschaltet! Tippe /zombieskin zum Umschalten.", player, 0, 253, 0 )
		else
			outputChatBox ( "Du hast nicht genug Kürbisse!", player, 200, 0, 0 )
		end
    end
	if item == "titel" then
		if MtxGetElementData ( player, "hatHalloweenTitel" ) == true then
			outputChatBox ( "Du hast den Titel 'Kürbis-König' schon.", player, 200, 0, 0 )
		elseif eggs >= 20 then
			MtxSetElementData ( player, "kuerbisse", eggs - 20 )
			MtxSetElementData ( player, "hatHalloweenTitel", true )
			outputChatBox ( "Du trägst jetzt den Titel 'Kürbis-König' ueber deinem Kopf!", player, 0, 253, 0 )
		else
			outputChatBox ( "Du hast nicht genug Kürbisse!", player, 200, 0, 0 )
		end
    end
	if item == "leichenwagen" then
		if eggs >= 120 then
			if gibHalloweenFahrzeug ( player ) then
				MtxSetElementData ( player, "kuerbisse", eggs - 120 )
			end
		else
			outputChatBox ( "Du hast nicht genug Kürbisse!", player, 200, 0, 0 )
		end
    end
	if item == "Süßigkeit" then
		if eggs >= 10 then
			MtxSetElementData ( player, "kuerbisse", eggs - 10 )
			putFoodInSlot ( player, 3 )
		  else
			outputChatBox ( "Du hast nicht genug Kürbisse!", player, 200, 0, 0 )
		  end
    end
	if item == "kettensaege" then
		if eggs >= 25 then
			MtxSetElementData ( player, "kuerbisse", eggs - 25 )
			giveWeapon ( player, 9, 1 )
			outputChatBox ( "Du hast eine Kettensaege bekommen. Frohes Halloween!", player, 0, 253, 0 )
		else
			outputChatBox ( "Du hast nicht genug Kürbisse!", player, 200, 0, 0 )
		end
	end
end
addEvent ( "buyEasterBonus", true )
addEventHandler ( "buyEasterBonus", getRootElement(), buyEasterBonus )

-- Exklusiver Leichenwagen ( Modell 442 ) als seltene Halloween-Belohnung.
-- 442 ist in carsys/licenses/vehiclecheck.lua bereits als lizenzfreies
-- "bonusVehicles"-Fahrzeug eingetragen. Bewusst NICHT ueber carbuy() /
-- carprices, da das globale carprices[442]=0 setzen wuerde und den Wagen
-- damit auch ausserhalb des Events in jedem Autohaus gratis kaufbar machen
-- wuerde - stattdessen dieselben Kernschritte direkt, ohne Preis-/Lizenzpruefung.
local HALLOWEEN_FAHRZEUG = 442

function gibHalloweenFahrzeug ( player )
	local pname = getPlayerName ( player )
	if MtxGetElementData ( player, "curcars" ) >= MtxGetElementData ( player, "maxcars" ) then
		outputChatBox ( "Du hast keinen freien Fahrzeugslot! Tippe /sellcar, um eines deiner Fahrzeuge zu verkaufen.", player, 200, 0, 0 )
		return false
	end

	local slot = 0
	for i = 1, MtxGetElementData ( player, "maxcars" ) do
		if MtxGetElementData ( player, "carslot"..i ) == 0 then
			slot = i
			break
		end
	end
	if slot == 0 then return false end

	local x, y, z = getElementPosition ( player )
	local vehicle = createVehicle ( HALLOWEEN_FAHRZEUG, x, y, z, 0, 0, 0, pname )
	allPrivateCars[pname][slot] = vehicle
	MtxSetElementData ( vehicle, "owner", pname )
	MtxSetElementData ( vehicle, "name", vehicle )
	MtxSetElementData ( vehicle, "carslotnr_owner", slot )
	MtxSetElementData ( vehicle, "locked", true )
	MtxSetElementData ( vehicle, "fuelstate", 100 )
	MtxSetElementData ( vehicle, "totalschaden", 0 )
	MtxSetElementData ( vehicle, "Beschlagnahmt", 0 )
	setVehicleLocked ( vehicle, true )
	MtxSetElementData ( player, "carslot"..slot, 1 )
	MtxSetElementData ( player, "curcars", MtxGetElementData ( player, "curcars" ) + 1 )

	local Farbe1, Farbe2, Farbe3, Farbe4 = getVehicleColor ( vehicle )
	local Paintjob = getVehiclePaintjob ( vehicle )
	MtxSetElementData ( vehicle, "stuning", "0|0|0|0|0|0|" )
	local color = "|"..Farbe1.."|"..Farbe2.."|"..Farbe3.."|"..Farbe4.."|"
	MtxSetElementData ( vehicle, "color", color )
	MtxSetElementData ( vehicle, "lcolor", "|255|255|255|" )
	MtxSetElementData ( vehicle, "sportmotor", 0 )
	MtxSetElementData ( vehicle, "bremse", 0 )
	local antrieb = getVehicleHandling ( vehicle )["driveType"]
	MtxSetElementData ( vehicle, "antrieb", antrieb )

	SaveCarData ( player )
	if not dbExec ( handler, "INSERT INTO vehicles (UID, Typ, Tuning, Spawnpos_X, Spawnpos_Y, Spawnpos_Z, Spawnrot_X, Spawnrot_Y, Spawnrot_Z, Farbe, Paintjob, Benzin, Slot, Sportmotor, Bremse, Antrieb) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
		playerUID[pname], HALLOWEEN_FAHRZEUG, "|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|", x, y, z, 0, 0, 0, color, Paintjob, '100', slot, '0', '0', antrieb ) then
		outputDebugString ( "[Halloween] Fehler beim Speichern des Leichenwagens" )
		destroyElement ( vehicle )
		return false
	end

	warpPedIntoVehicle ( player, vehicle )
	outputChatBox ( "Du hast den exklusiven Halloween-Leichenwagen erhalten! Tippe /vehhelp fuer mehr Infos.", player, 0, 253, 0 )
	outputLog ( pname.." hat den Halloween-Leichenwagen erhalten", "vehicle" )
	return true
end

-- Umschalten des freigeschalteten Zombie-Skins. Nutzt dasselbe Modell/TXD-
-- Verfahren wie die Zombie-Nacht-Gegner ( events/zombienacht_assets/skins ),
-- rein kosmetisch, kein Balance-Vorteil. "skinid" ( core/data.lua ) ist der
-- persistierte echte Skin des Spielers - darauf wird zurueckgeschaltet statt
-- auf einen nur im RAM gemerkten Wert, damit ein /restart ICE mitten in
-- aktiviertem Zombie-Skin niemanden dauerhaft als Zombie zuruecklaesst.
addCommandHandler ( "zombieskin", function ( player )
	if not event.isHalloween then
		outputChatBox ( "Der Zombie-Skin ist nur während des Halloween-Events nutzbar.", player, 200, 0, 0 )
		return
	end
	if MtxGetElementData ( player, "hatHalloweenSkin" ) ~= true then
		outputChatBox ( "Du hast den Zombie-Skin noch nicht freigeschaltet ( Halloween-Stand ).", player, 200, 0, 0 )
		return
	end
	if getElementModel ( player ) == 105 then
		setElementModel ( player, tonumber ( MtxGetElementData ( player, "skinid" ) ) or 0 )
		outputChatBox ( "Zombie-Skin ausgeschaltet.", player, 0, 253, 0 )
	else
		setElementModel ( player, 105 )
		outputChatBox ( "Zombie-Skin angeschaltet.", player, 0, 253, 0 )
	end
end )

-- Sicherheitsnetz: falls das Event beim Neustart deaktiviert ist, aber noch
-- Spieler online sind, die vorher ( bei aktivem Event ) den Zombie-Skin an
-- hatten, werden sie hier hart auf ihren echten Skin zurueckgesetzt - sonst
-- blieben sie bis zum naechsten Relog als Zombie sichtbar.
if not event.isHalloween then
	for _, player in ipairs ( getElementsByType ( "player" ) ) do
		if getElementModel ( player ) == 105 then
			setElementModel ( player, tonumber ( MtxGetElementData ( player, "skinid" ) ) or 0 )
		end
	end
end

local halo_table = {}

function halloweenHouseFunction ( player )
	if event.isHalloween then
		local x, y, z = getElementPosition ( player )
		local colshape = createColSphere ( x, y, z, 1.5 )
		
		for theKey, thePickup in pairs (getElementsWithinColShape( colshape, "pickup" )) do
		
			if tonumber(houses["id"][thePickup]) then
			
				if thePickup == houses["pickup"][tonumber(houses["id"][thePickup])] then
				
					if halo_table[thePickup] == true then
						outputChatBox ( "An diesem Haus wurde 'Trick or Treat' schon gespielt!", player, 200, 0, 0 )
						outputChatBox ( "Du erhältst aber ein paar Süßigkeiten.", player, 200, 0, 0 )
						putFoodInSlot ( player, 5 )
						return
					end
				
					outputChatBox ( "Du hast einen Kürbis bekommen!", player, 0, 125, 0 )
					local eggs = MtxGetElementData ( player, "kuerbisse" )
					MtxSetElementData ( player, "kuerbisse", eggs + 1 )
					halo_table[thePickup] = true
					setTimer (
						function ( pick )
							halo_table[pick] = false
						end, 3600000, 1, thePickup )
					break
				
				end
			
			end
		
		end
	end
end
addCommandHandler ( "Kürbis", halloweenHouseFunction, false, false )

---------------------------------------------------------------------
-- Automatisches "Suesses oder Saures" an jeder Haustuer
---------------------------------------------------------------------
-- Statt den /Kürbis-Befehl tippen zu muessen: an jede Haustuer ( dieselben
-- Pickups wie beim normalen Betreten des Hauses, siehe housesys/houses_mysql.lua )
-- kommt eine eigene, etwas groessere Zone. Lief man hinein, klingelt es, und
-- nach kurzer Spannung entscheidet der Zufall - nicht mehr garantiert wie
-- beim alten /Kürbis-Befehl. Teilt sich denselben halo_table-Cooldown, damit
-- man nicht per Befehl UND per Reinlaufen an derselben Tuer doppelt kassiert.
local function suessesOderSaures ( player, pickup )
	if not event.isHalloween or halo_table[pickup] then return end
	halo_table[pickup] = true
	setTimer ( function () halo_table[pickup] = false end, 3600000, 1 )

	outputChatBox ( "Du klingelst... \"Süßes oder Saures!\"", player, 255, 140, 0 )
	-- Echte Tuerklingel ( sounds/klingel.mp3, bereits vorhanden - siehe
	-- events/halloween_client.lua: haustuerKlingel ).
	triggerClientEvent ( player, "haustuerKlingel", player )
	setTimer ( function ()
		if not isElement ( player ) then return end
		if math.random ( 1, 2 ) == 1 then
			outputChatBox ( "Die Tür geht auf - du bekommst einen Kürbis!", player, 0, 200, 0 )
			MtxSetElementData ( player, "kuerbisse", MtxGetElementData ( player, "kuerbisse" ) + 1 )
		else
			outputChatBox ( "Niemand macht auf... schade.", player, 200, 0, 0 )
		end
	end, 1500, 1 )
end

local function baueHaustuerZonen ()
	local schonGemacht = {}
	for id, pickup in pairs ( houses["pickup"] ) do
		if isElement ( pickup ) and not schonGemacht[pickup] then
			schonGemacht[pickup] = true
			local x, y, z = getElementPosition ( pickup )
			local zone = createColSphere ( x, y, z, 2 )
			addEventHandler ( "onColShapeHit", zone, function ( hit, dim )
				if dim and getElementType ( hit ) == "player" and not isPedInVehicle ( hit ) then
					suessesOderSaures ( hit, pickup )
				end
			end )
		end
	end
end

if event.isHalloween then
	-- Verzoegert, damit die 184 Haeuser ( siehe Server-Log beim Start ) sicher
	-- schon aus der Datenbank geladen sind, bevor hier ueber sie iteriert wird.
	setTimer ( baueHaustuerZonen, 2000, 1 )
end

---------------------------------------------------------------------
-- Klickbare Kürbisse in San Fierro
---------------------------------------------------------------------
-- Zweites, unabhaengiges System neben den 30 Lauf-Fundorten weiter oben:
-- feste Kürbisse in San Fierro, die per Mausklick auf das 3D-Objekt
-- eingesammelt werden. Einmal gefunden, bleibt der Kürbis fuer ALLE
-- Spieler 5 Stunden lang leer, dann erscheint er wieder - nicht wie oben
-- ein neuer Zufallsort, sondern derselbe Platz oeffnet sich erneut.
--
-- Koordinaten stammen von bereits im Skript verwendeten SF-Orten
-- ( dxDrawTextOnElement.lua: Lotto, LevelShop, Geldautomat, Waffenladen,
-- Kleidung Shop CJ, Deathmatch Arena ), damit die Hoehe nachweislich stimmt
-- statt geraten zu sein wie zuvor bei Modell 19320.
local SF_KUERBIS_RESET = 5 * 60 * 60 * 1000  -- 5 Stunden

local sfKuerbisOrte = {
	{ -1978.7, 152.8,  27.6875 },  -- neben Lotto/LevelShop
	{ -2038.0, 449.6,  34.8    },  -- beim Geldautomat
	{ -2224.8, 250.1,  35.3    },  -- Deathmatch Arena
	{ -2623.9, 207.4,  3.56    },  -- Waffenladen
	{ -2489.9, -40.9,  25.77   },  -- Kleidung Shop CJ
	{ -1983.0, 145.0,  27.6875 },  -- Bahnhofsvorplatz, gegenueber vom Stand
	{ -1649.9, 1209.8, 7.25    },  -- Otto's Autohaus
	{ -1721.3, 1359.8, 6.17    },  -- Pizzaladen
	{ -2442.6, 753.4,  34.14   },  -- Supermarkt
	{ -1967.190, 291.590, 35.262 },  -- Wang Cars Autohaus
	{ -1605.8, 710.7,  13.87   },  -- SFPD
	{ -2028.6, -106.0, 35.17   },  -- Abschlepphof
}

local sfKuerbis = {}  -- Objekt -> { offen = bool }

local function sfKuerbisOeffnen ( obj )
	local eintrag = sfKuerbis[obj]
	if not eintrag or not eintrag.offen then return end

	eintrag.offen = false
	setElementAlpha ( obj, 0 )
	setElementCollisionsEnabled ( obj, false )
	setElementData ( obj, "istKuerbis", false, true )  -- Symbol ausblenden

	setTimer ( function ()
		if isElement ( obj ) then
			eintrag.offen = true
			setElementAlpha ( obj, 255 )
			setElementCollisionsEnabled ( obj, true )
			setElementData ( obj, "istKuerbis", true, true )  -- Symbol wieder an
		end
	end, SF_KUERBIS_RESET, 1 )
end

local function baueSFKuerbisse ()
	for i = 1, #sfKuerbisOrte do
		local o = sfKuerbisOrte[i]
		local obj = exports.newmodels_red:createObject ( KUERBIS_MODELL, o[1], o[2], o[3] + KUERBIS_Z_VERSATZ )
		setElementFrozen ( obj, true )
		setElementData ( obj, "istKuerbis", true, true )
		sfKuerbis[obj] = { offen = true }
	end
end

-- Eigener, unabhaengiger Handler auf demselben nativen Event, das auch
-- clicksys/clicksys_server.lua fuer Fahrzeug-/Ped-Klicks nutzt ( Cursor per
-- "M" einblenden, siehe clicksys/clicksys_client.lua ). MTA ruft alle
-- registrierten "onPlayerClick"-Handler unabhaengig voneinander auf, daher
-- kein Eingriff in die grosse bestehende Dispatch-Funktion dort noetig.
addEventHandler ( "onPlayerClick", getRootElement(), function ( button, state, clickedElement )
	if state ~= "down" or button ~= "left" then return end
	local eintrag = sfKuerbis[clickedElement]
	-- Serverseitig massgeblich, unabhaengig vom sichtbaren Client-Zustand:
	-- auch wenn irgendwas clientseitig hakt, kann ein bereits geleerter
	-- Kürbis so nie ein zweites Mal etwas geben.
	if not eintrag or not eintrag.offen then return end

	local ox, oy, oz = getElementPosition ( clickedElement )
	local px, py, pz = getElementPosition ( source )
	if getDistanceBetweenPoints3D ( ox, oy, oz, px, py, pz ) > 8 then return end

	sfKuerbisOeffnen ( clickedElement )
	MtxSetElementData ( source, "kuerbisse", MtxGetElementData ( source, "kuerbisse" ) + 1 )
	outputChatBox ( "Kürbis gefunden! In 5 Stunden liegt hier wieder einer.", source, 0, 200, 0 )
	triggerClientEvent ( source, "achievsound", source )
end )

if event.isHalloween then
	setTimer ( baueSFKuerbisse, 1000, 1 )
end


