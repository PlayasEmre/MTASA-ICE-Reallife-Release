--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


-- INTERIOR OBJECT --

local radio = createObject(2103, 409.51727294922, 262.29370117188, 997.16198730469, 0, 0, 130)
setElementInterior(radio, 3)

local innenraum = createObject(14594, 242.4009552002, 995.79626464844, 0, 0, 179.99450683594)
setElementInterior(innenraum, 3)

-- INT MARKER --

local marker1 = createMarker(437.60995483398, 230.7248840332, 996.91188964844, "corona", 1.5, 0, 255, 0, 150)
setElementInterior(marker1, 3)

local marker2 = createMarker(-2655.1066894531, 640.07641601563, 14.554549789429, "corona", 1.5, 0, 255, 0, 150)

addEventHandler("onMarkerHit", marker1, function(hitElement, dim)
	if getElementType(hitElement) == "player" and (dim) then
		if isPedInVehicle ( hitElement ) == false then
			setElementPosition(hitElement, -2655.2829589844, 638.32342529297, 14.453125)
			setElementInterior(hitElement, 0)
			infobox ( hitElement, "\nPass besser\nauf dich auf!", 5000, 0, 125, 0 )
		end
	end
end)

addEventHandler("onMarkerHit", marker2, function(hitElement, dim)
	if getElementType(hitElement) == "player" and (dim) then
		if isPedInVehicle ( hitElement ) == false then
			setElementPosition(hitElement, 435.42782592773, 230.65969848633, 996.81188964844)
			setElementInterior(hitElement, 3)
			infobox ( hitElement, "\nWillkommen im\nKrankenhaus!", 5000, 0, 125, 0 )
		end
	end
end)

-- MEDIPACK AUFLADEN --

local marker_medipack = createMarker(398.35266113281, 258.39260864258, 996.01188964844, "cylinder", 2.0, 255, 0, 0, 150)
setElementInterior(marker_medipack, 3)

addEventHandler("onMarkerHit", marker_medipack, function(hitElement, dim)
	if getElementType(hitElement) == "player" and (dim) then
		if(isMedic(hitElement)) then
			outputChatBox("[INFO]: Nutze /loadmedikits um deine Medipacks wieder aufzuladen!", hitElement, 150, 150, 0)
		else
			outputChatBox("[INFO]: Nur für Mitarbeiter der Los Angeles Emergency!", hitElement, 175, 0, 0)
		end
	end
end)

addCommandHandler("loadmedikits", function(thePlayer)
	if(isMedic(thePlayer)) then
		if (isEmergencyOnDuty(thePlayer)) then
			if (isElementWithinMarker(thePlayer, marker_medipack)) then
				MtxSetElementData(thePlayer, "medikits", 10)
				outputChatBox("Du hast deine Medikits erfolgreich aufgeladen! Du hast nun 10 Stück. Nutze /usekit um jemanden zu heilen!", thePlayer, 0, 150, 0)
			else
				triggerClientEvent ( thePlayer, "infobox_start", getRootElement(), "\nDu bist nicht\nim dafür vorgesehenen\nMarker!", 5000, 255, 0, 0 )			
			end
		else
			triggerClientEvent ( thePlayer, "infobox_start", getRootElement(), "\nDu bist\nOffduty!", 5000, 255, 0, 0 )			
		end
	else
		triggerClientEvent ( thePlayer, "infobox_start", getRootElement(), "\nDu bist\nkein Sanitäter!", 5000, 255, 0, 0 )			
	end
end)

addCommandHandler("usekit", function(thePlayer, cmd, target)
	if(target) and (getPlayerFromName(target)) and (getPlayerName(thePlayer) ~= target) then
		if(isMedic(thePlayer)) and (isEmergencyOnDuty(thePlayer)) then
			target = getPlayerFromName(target)
			local carheal = false
			if isPedInVehicle(thePlayer) and isPedInVehicle(target) and getElementModel(getPedOccupiedVehicle(thePlayer)) == 416 and getElementModel(getPedOccupiedVehicle(target)) == 416 then
				carheal = true
			end
			local x, y, z = getElementPosition(thePlayer)
			local x2, y2, z2 = getElementPosition(target)
			if(getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) > 20) then
				triggerClientEvent ( thePlayer, "infobox_start", getRootElement(), "\nDu bist\nnicht nahe genug\nam Spieler!", 5000, 255, 0, 0 )	
				return
			end
			local kits = tonumber(MtxGetElementData(thePlayer, "medikits"))
			if not(kits) or (kits < 1) and (carheal == false) then
				triggerClientEvent ( thePlayer, "infobox_start", getRootElement(), "\nDu hast\nkeine Medikits mehr!", 5000, 255, 0, 0 )
				return
			end
			if(carheal == false) then
				MtxSetElementData(thePlayer, "medikits", kits-1)
				local x1, y1, z1 = getElementPosition(target)
				local x2, y2, z2 = getElementPosition(thePlayer)
				local rot = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
				rot = rot-90
				setPedRotation(target, rot)
				
				x1, y1, z1 = getElementPosition(thePlayer)
				x2, y2, z2 = getElementPosition(target)
				rot = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
				rot = rot-90
				setPedRotation(thePlayer, rot)
			end
			toggleAllControls(target, false)
			toggleAllControls(thePlayer, false)
			setPedAnimation(thePlayer, "INT_SHOP", "shop_self", -1, true, false, false)
			triggerClientEvent ( thePlayer, "infobox_start", getRootElement(), "\nHeile Spieler ..", 5000, 255, 0, 0 )	
			setTimer(function()
				toggleAllControls(target, true)
				toggleAllControls(thePlayer, true)
				setPedAnimation(thePlayer)
				outputChatBox("[INFO]: Du wurdest von Sanitäter "..getPlayerName(thePlayer).." geheilt!", target, 200, 200, 0)
				if(carheal == false) then
					outputChatBox("[INFO]: Du hast "..getPlayerName(target).." geheilt! Verbleibene Kits: "..(kits-1), thePlayer, 0, 150, 0)
					setElementData(thePlayer, "medickits", kits-1)
				else
					outputChatBox("[INFO]: Du hast "..getPlayerName(target).." geheilt! Da du in einem Krankenwagen sitzt, hast du kein Kit verbraucht.", thePlayer, 0, 150, 0)
				end
				setElementHealth(target, 100)
				if(getPedArmor(target) < 50) then
					setPedArmor(target, 50)
				end
			end, 2000, 1)
		else
			triggerClientEvent ( thePlayer, "infobox_start", getRootElement(), "\nDu bist\nkein Sanitäter\nim Dienst!", 5000, 255, 0, 0 )	
		end
	else
		triggerClientEvent ( thePlayer, "infobox_start", getRootElement(), "Spieler ist\nnicht online\noder ungültig!", 5000, 255, 0, 0 )	
	end
end)

-- DUTY FUNC --

local duty_marker = createMarker(413.16009521484, 257.68475341797, 995.51188964844, "cylinder", 1.5, 255, 0, 0, 150)
setElementInterior(duty_marker, 3)

addEventHandler("onMarkerHit", duty_marker, function(hitElement, dim)
	if getElementType(hitElement) == "player" and (dim) then
		if(isMedic(hitElement)) then
			outputChatBox("[INFO]: Nutze /medic um in Dienst zu gehen/den Dienst zu verlassen!", hitElement, 200, 200, 0)
		else
			outputChatBox("Nur für Mitarbeiter der San Fierro Emergency!", hitElement, 175, 0, 0)
		end
	end
end)

addCommandHandler("medic", function(thePlayer)
	if(isMedic(thePlayer)) then
		local x, y, z = getElementPosition ( thePlayer )
		if getDistanceBetweenPoints3D ( x, y, z, 413.16009521484, 257.68475341797, 995.51188964844 ) <= 5 then
			local duty = isEmergencyOnDuty ( thePlayer )
			if(duty == true) then
				outputChatBox("[INFO]: Du bist nun nicht mehr als Sanitäter im Dienst!", thePlayer, 200, 200, 0)
				takeWeapon(thePlayer, 41)
				setElementModel ( thePlayer, MtxGetElementData ( thePlayer, "skinid" ) )
				triggerClientEvent ( thePlayer, "saniShowTimeLeftStart", thePlayer )
			else
				outputChatBox("[INFO]: Du bist nun als Sanitäter im Dienst!", thePlayer, 200, 200, 0)
				outputChatBox("[INFO]: Ausserdem hast du 5 Medikits erhalten, /usekit!", thePlayer, 200, 200, 0)
				local thezahl = math.random (1, #factionSkins[10])
				setElementModel ( thePlayer, factionSkins[10][thezahl] )
				giveWeapon(thePlayer, 41, 1000, true)
				setPedArmor(thePlayer,100)
				MtxSetElementData(thePlayer, "medikits", 5)
				triggerClientEvent ( thePlayer, "saniShowTimeLeftStart", thePlayer )
			end
		else
			triggerClientEvent ( thePlayer, "infobox_start", getRootElement(), "Du bist nicht\nim Marker!", 5000, 255, 0, 0 )
		end
	else
		triggerClientEvent ( thePlayer, "infobox_start", getRootElement(), "Du bist kein\nSanitäter!", 5000, 255, 0, 0 )
	end
end)


-- Statt sofortiger Vor-Ort-Heilung per CPR: Der Sanitäter lädt den Patienten in
-- den Krankenwagen (Modell 416) und muss ihn zum Krankenhaus fahren. Erst bei
-- Ankunft in der Abgabezone (bei den Ambulanzen/Krankenhaus) wird geheilt und
-- der Sanitäter bezahlt. Falls kein Sanitäter rechtzeitig transportiert, greift
-- weiterhin die automatische Heilung nach Ablauf der heaventime (siehe death.lua).
local hospitalDropoff = createColCuboid ( -2666, 605, 8, 22, 45, 14 )
local hospitalDropoffX, hospitalDropoffY, hospitalDropoffZ = -2655, 627.5, 15 -- Mittelpunkt der Abgabezone
local transportedPatients = {} -- [ambulance] = Patient-Element, damit die Abgabezone weiß wer transportiert wird
local transportBlips = {} -- [ambulance] = Blip, zeigt dem Sanitäter den Weg zum Krankenhaus
local transportKeepalive = {} -- [ambulance] = Timer, erneuert attachElements regelmäßig

local function entferneTransportBlip ( ambulance )
	if isElement ( transportBlips[ambulance] ) then
		destroyElement ( transportBlips[ambulance] )
	end
	transportBlips[ambulance] = nil
end

local function entferneKeepaliveTimer ( ambulance )
	if isTimer ( transportKeepalive[ambulance] ) then
		killTimer ( transportKeepalive[ambulance] )
	end
	transportKeepalive[ambulance] = nil
end

local function vollendeTransport ( sanitaeter, thePlayer, ambulance )
	MtxSetElementData ( thePlayer, "medicTransportBy", false )
	triggerClientEvent ( thePlayer, "stopDeathFreecam", thePlayer )
	if isElement ( ambulance ) then
		transportedPatients[ambulance] = nil
		entferneTransportBlip ( ambulance )
		entferneKeepaliveTimer ( ambulance )
	end
	detachElements ( thePlayer )
	setElementFrozen ( thePlayer, false )
	if isElement ( ambulance ) then
		removePedFromVehicle ( thePlayer )
	end

	MtxSetElementData ( thePlayer, "heaventime", 0 )
	showChat ( thePlayer, true )
	setCameraTarget ( thePlayer )

	runAsync ( RemoteSpawnPlayer, thePlayer )

	setElementHealth ( thePlayer, 100 )
	if MtxGetElementData ( thePlayer, "fraktion" ) > 0 then
		setPedArmor ( thePlayer, 100 )
	end
	setElementFrozen ( thePlayer, false )
	toggleAllControls ( thePlayer, true )
	setPedAnimation ( thePlayer, false )
	playSoundFrontEnd ( thePlayer, 17 )
	if isTimer ( thedeathtimer[thePlayer] ) then
		killTimer ( thedeathtimer[thePlayer] )
	end

	if MtxGetElementData ( thePlayer, "money" ) >= hospitalcosts then
		MtxSetElementData ( thePlayer, "money", MtxGetElementData ( thePlayer, "money" ) - hospitalcosts )
	end

	local money = 150
	if isElement ( sanitaeter ) then
		outputChatBox ( "Du wurdest von Sanitäter "..getPlayerName(sanitaeter).." ins Krankenhaus gefahren und wieder ins Leben gerufen!", thePlayer, 0, 255, 0 )
		MtxSetElementData ( sanitaeter, "money", MtxGetElementData ( sanitaeter, "money" ) + money )
		outputChatBox ( "Du hast "..getPlayerName(thePlayer).." im Krankenhaus abgeliefert und erhälst bei", sanitaeter, 0, 255, 0 )
		outputChatBox ( " deiner nächsten Abrechnung "..money.."$ money.", sanitaeter, 0, 255, 0 )
	else
		outputChatBox ( "Du wurdest ins Krankenhaus gefahren und wieder ins Leben gerufen!", thePlayer, 0, 255, 0 )
	end
end

local m_pick = {}
local m_mark = {}
local m_blip = {}

function checkIfMedicRespawn ( client )
	local pname = getPlayerName ( client )

	if isElement ( m_pick[pname] ) then
		destroyElement ( m_pick[pname] )
	end
	if isElement ( m_mark[pname] ) then
		destroyElement ( m_mark[pname] )
	end
	if isElement ( m_blip[pname] ) then
		destroyElement ( m_blip[pname] )
	end

	if getElementInterior ( client ) == 0 then
		if MtxGetElementData ( client, "jailtime") == 0 and MtxGetElementData ( client, "prison") == 0 then
			local r, g, b = math.random ( 0, 255 ), math.random ( 0, 255 ), math.random ( 0, 255 )
			local x, y, z = getElementPosition ( client )
			m_pick[pname] = createPickup ( x, y, z, 3, 1240, 1000 )
			m_mark[pname] = createMarker ( x, y, z, "corona", 1.0, 0, 0, 0, 0 )
			m_blip[pname] = createBlip ( x, y, z, 0, 2, r, g, b, 255, 0, 99999, root )
			local zonename1 = getZoneName(x, y, z, false)
			local zonename2 = getZoneName(x, y, z, true)
			setElementVisibleTo ( m_blip[pname], root, false )
			local playerdeatharray = { m_pick[pname], r, g, b, 68*1000 }

			for playeritem, key in pairs ( fraktionMembers[10] ) do
				if isElement ( playeritem ) and playeritem ~= client then
					if isEmergencyOnDuty ( playeritem ) then
						outputChatBox ( "[INFO]: Toter in "..zonename1..", "..zonename2.." gemeldet.", playeritem, 255, 155, 0 )
						setElementVisibleTo ( m_blip[pname], playeritem, true )
						triggerClientEvent ( playeritem, "newDeadGuyToRescue", playeritem, playerdeatharray )
					end
				else
					fraktionMembers[10][playeritem] = nil
				end
			end
			addEventHandler("onMarkerHit", m_mark[pname], medicOnMarkerHitRevive )
		end
	end
end


function medicOnMarkerHitRevive ( hitElement )
	if getElementType ( hitElement ) == "player" then
		if isMedic ( hitElement ) and isEmergencyOnDuty ( hitElement ) then
			if getElementHealth ( hitElement ) > 0 then
				local pname = nil
				for name, marker in pairs ( m_mark ) do
					if marker == source then
						pname = name
						break
					end
				end
				if pname then
					local thePlayer = getPlayerFromName ( pname )
					if isElement ( thePlayer ) and isPedDead ( thePlayer ) then
						local ambulance = getPedOccupiedVehicle ( hitElement )
						if ambulance and getElementModel ( ambulance ) == 416 and getPedOccupiedVehicleSeat ( hitElement ) == 0 then
							-- Den urspruenglichen 20-Sek.-Timer aus playerdeath() (death.lua)
							-- abbrechen: laueft er noch (schnelle Abholung durch den Sanitaeter),
							-- wuerde endfade() spaeter trotzdem feuern und den Patienten per
							-- removePedFromVehicle() aus dem fahrenden Krankenwagen werfen.
							if isTimer ( thedeathtimer[thePlayer] ) then
								killTimer ( thedeathtimer[thePlayer] )
							end
							-- Ein "toter" (Ragdoll-)Ped lässt sich nicht zuverlässig auf einen
							-- Sitzplatz setzen. Deshalb kurz an Ort und Stelle respawnen (löst
							-- den Ragdoll-Zustand, OHNE ihn wegzuteleportieren), damit er sich
							-- danach ganz normal auf einen echten Sitzplatz setzen lässt.
							-- Das Flag verhindert, dass unser eigener onPlayerSpawn-Handler das
							-- fälschlich als abgebrochenen Transport behandelt.
							local ax, ay, az = getElementPosition ( ambulance )
							local skin = MtxGetElementData ( thePlayer, "skinid" )
							local interior = getElementInterior ( ambulance )
							local dimension = getElementDimension ( ambulance )
							-- Kamera erst abblenden und die Ueberblendung abwarten (setTimer),
							-- bevor der Vor-Ort-Respawn passiert - sonst ist die Abblendung noch
							-- nicht fertig und der Sprung zur Fahrzeugposition (deathFreecamFrame
							-- in ego_client.lua folgt jeden Frame der echten Spielerposition)
							-- bleibt trotzdem sichtbar. Das Flag verhindert, dass unser eigener
							-- onPlayerSpawn-Handler das faelschlich als abgebrochenen Transport
							-- behandelt.
							fadeCamera ( thePlayer, false, 0.2 )
							setTimer ( function ()
								if not ( isElement ( thePlayer ) and isElement ( ambulance ) ) then return end
								MtxSetElementData ( thePlayer, "medicPickupInProgress", true )
								setElementAlpha ( thePlayer, 0 )
								spawnPlayer ( thePlayer, ax, ay, az, 0, skin, interior, dimension )
								setElementAlpha ( thePlayer, 0 ) -- spawnPlayer setzt die Sichtbarkeit selbst zurueck, deshalb hier nochmal
								setElementModel ( thePlayer, skin )
								setElementHealth ( thePlayer, 1 )
								setElementInterior ( thePlayer, interior )
								setElementDimension ( thePlayer, dimension )
								MtxSetElementData ( thePlayer, "medicPickupInProgress", false )

								for _, seat in ipairs ( { 2, 3, 1 } ) do -- bevorzugt Rücksitz, Beifahrersitz nur als Notlösung
									if warpPedIntoVehicle ( thePlayer, ambulance, seat ) then
										break
									end
								end
								setElementAlpha ( thePlayer, 255 )
								fadeCamera ( thePlayer, true, 0.3 )
								toggleAllControls ( thePlayer, false )
							end, 250, 1 )

							MtxSetElementData ( thePlayer, "medicTransportBy", getPlayerName ( hitElement ) )
							transportedPatients[ambulance] = thePlayer

							-- Absicherung: falls er durch einen Unfall/Zusammenstoß aus dem Sitz
							-- fliegt, regelmäßig prüfen und wieder reinsetzen. Auch hier kurz
							-- abblenden, damit das Zurücksetzen nicht als sichtbares "Rausspringen
							-- und wieder Reinsitzen" wahrgenommen wird.
							entferneKeepaliveTimer ( ambulance )
							transportKeepalive[ambulance] = setTimer ( function ()
								if isElement ( thePlayer ) and isElement ( ambulance ) and MtxGetElementData ( thePlayer, "medicTransportBy" ) then
									if getPedOccupiedVehicle ( thePlayer ) ~= ambulance then
										fadeCamera ( thePlayer, false, 0.15 )
										setTimer ( function ()
											if not ( isElement ( thePlayer ) and isElement ( ambulance ) ) then return end
											for _, seat in ipairs ( { 2, 3, 1 } ) do
												if warpPedIntoVehicle ( thePlayer, ambulance, seat ) then
													break
												end
											end
											fadeCamera ( thePlayer, true, 0.2 )
										end, 160, 1 )
									end
								else
									entferneKeepaliveTimer ( ambulance )
								end
							end, 500, 0 )

							-- Blip zur Abgabezone, damit der Sanitäter weiß wohin er fahren muss.
							entferneTransportBlip ( ambulance )
							local zielBlip = createBlip ( hospitalDropoffX, hospitalDropoffY, hospitalDropoffZ, 0, 2, 255, 0, 0, 255, 0, 99999, root )
							setElementVisibleTo ( zielBlip, root, false )
							setElementVisibleTo ( zielBlip, hitElement, true )
							transportBlips[ambulance] = zielBlip
							outputChatBox ( "[INFO]: Der rote Blip auf der Karte zeigt dir, wohin du den Patienten fahren musst!", hitElement, 0, 200, 0 )

							-- Die freie Kamera (startDeathFreecam, seit playerdeath aktiv) läuft
							-- während des ganzen Transports einfach weiter, damit der Patient
							-- die Fahrt ins Krankenhaus die ganze Zeit frei mitverfolgen kann.

							outputChatBox ( "[INFO]: Du hast "..getPlayerName(thePlayer).." in den Krankenwagen geladen. Fahre ihn ins Krankenhaus!", hitElement, 0, 200, 0 )
							outputChatBox ( "[INFO]: Sanitäter "..getPlayerName(hitElement).." hat dich in den Krankenwagen geladen und fährt dich ins Krankenhaus!", thePlayer, 0, 200, 0 )
							destroyElement ( m_mark[pname] )
							destroyElement ( m_pick[pname] )
							destroyElement ( m_blip[pname] )
						else
							outputChatBox ( "[INFO]: Du musst als Fahrer im Krankenwagen sitzen, um den Patienten mitzunehmen!", hitElement, 200, 0, 0 )
						end
					end
				end
			end
		end
	end
end

-- Ob ein Spieler gerade aktiv im Sanitaeter-Transport ist (als Patient oder
-- als fahrender Sanitaeter) - fuer die AFK-Ausnahme in environment/afk.lua,
-- da beide waehrend der Fahrt kaum/keine Eingaben machen koennen/muessen.
function istInSanitaeterTransport ( player )
	if MtxGetElementData ( player, "medicTransportBy" ) then
		return true
	end
	for ambulance, patient in pairs ( transportedPatients ) do
		if getPedOccupiedVehicle ( player ) == ambulance and getPedOccupiedVehicleSeat ( player ) == 0 then
			return true
		end
	end
	return false
end

-- onPlayerDamage feuert NICHT bei einem toedlichen Treffer - dann feuert
-- direkt onPlayerWasted, an dem cancelEvent() in onPlayerDamage vorbeigeht.
-- Da der Patient waehrend des Transports absichtlich auf 1 HP gehalten wird,
-- ist praktisch jeder Treffer toedlich. rettePatientVorTod() faengt genau
-- diesen Fall ab: wird von playerdeath() (death.lua) ganz am Anfang
-- aufgerufen, noch bevor der normale Todes-Ablauf startet, und "rettet" den
-- Patienten mit demselben Ragdoll-Flucht-Trick wie beim Einladen oben. Gibt
-- true zurueck, wenn der Spieler tatsaechlich im Transport war.
function rettePatientVorTod ( player )
	local ambulance = nil
	for veh, patient in pairs ( transportedPatients ) do
		if patient == player then
			ambulance = veh
			break
		end
	end
	if not ( ambulance and isElement ( ambulance ) ) then
		return false
	end

	local ax, ay, az = getElementPosition ( ambulance )
	local skin = MtxGetElementData ( player, "skinid" )
	local interior = getElementInterior ( ambulance )
	local dimension = getElementDimension ( ambulance )
	fadeCamera ( player, false, 0.2 )
	setTimer ( function ()
		if not ( isElement ( player ) and isElement ( ambulance ) ) then return end
		MtxSetElementData ( player, "medicPickupInProgress", true )
		setElementAlpha ( player, 0 )
		spawnPlayer ( player, ax, ay, az, 0, skin, interior, dimension )
		setElementAlpha ( player, 0 ) -- spawnPlayer setzt die Sichtbarkeit selbst zurueck, deshalb hier nochmal
		setElementModel ( player, skin )
		setElementHealth ( player, 1 )
		setElementInterior ( player, interior )
		setElementDimension ( player, dimension )
		MtxSetElementData ( player, "medicPickupInProgress", false )

		for _, seat in ipairs ( { 2, 3, 1 } ) do
			if warpPedIntoVehicle ( player, ambulance, seat ) then
				break
			end
		end
		setElementAlpha ( player, 255 )
		fadeCamera ( player, true, 0.3 )
		toggleAllControls ( player, false )
	end, 250, 1 )

	return true
end

-- Während des Transports (im Krankenwagen sitzend, bewusstlos) unverwundbar,
-- damit der Patient nicht nochmal angeschossen werden/sterben kann, bevor er
-- im Krankenhaus abgeliefert wurde.
addEventHandler ( "onPlayerDamage", root, function ()
	if MtxGetElementData ( source, "medicTransportBy" ) then
		cancelEvent ()
		setElementHealth ( source, 1 )
	end
end )

addEventHandler ( "onColShapeHit", hospitalDropoff, function ( hitElement, matchingDimension )
	if matchingDimension and getElementType ( hitElement ) == "vehicle" and getElementModel ( hitElement ) == 416 then
		local patient = transportedPatients[hitElement]
		if isElement ( patient ) then
			local sanitaeter = getPlayerFromName ( MtxGetElementData ( patient, "medicTransportBy" ) )
			vollendeTransport ( sanitaeter, patient, hitElement )
		end
	end
end )

-- Falls der Krankenwagen während des Transports zerstört wird, den Patienten
-- lösen statt ihn an ein nicht mehr existierendes Fahrzeug gebunden zu lassen.
addEventHandler ( "onElementDestroy", root, function ()
	local patient = transportedPatients[source]
	if patient then
		transportedPatients[source] = nil
		entferneTransportBlip ( source )
		entferneKeepaliveTimer ( source )
		if isElement ( patient ) then
			detachElements ( patient )
			setElementFrozen ( patient, false )
			MtxSetElementData ( patient, "medicTransportBy", false )
		end
	end
end )


addEventHandler("onPlayerSpawn", root, function()
	-- Der kurze Respawn beim Einladen ins Fahrzeug (medicOnMarkerHitRevive)
	-- löst diesen Event ebenfalls aus - in dem Moment aber nichts von unten
	-- ausführen, das ist kein abgebrochener Transport.
	if MtxGetElementData ( source, "medicPickupInProgress" ) then
		return
	end

	local pname = getPlayerName(source)
	if isElement ( m_mark[pname] ) then
		destroyElement ( m_mark[pname] )
	end
	if isElement ( m_pick[pname] ) then
		destroyElement ( m_pick[pname] )
	end
	if isElement ( m_blip[pname] ) then
		destroyElement ( m_blip[pname] )
	end
	-- Falls der Spieler stattdessen über die normale Sterbezeit (heaventime)
	-- automatisch respawnt wurde, während er noch im Krankenwagen transportiert
	-- wurde, hier sauber lösen statt ihn dort hängen zu lassen.
	if MtxGetElementData ( source, "medicTransportBy" ) then
		detachElements ( source )
		setElementFrozen ( source, false )
		setPedAnimation ( source, false )
		MtxSetElementData ( source, "medicTransportBy", false )
		for veh, patient in pairs ( transportedPatients ) do
			if patient == source then
				transportedPatients[veh] = nil
				entferneTransportBlip ( veh )
				entferneKeepaliveTimer ( veh )
			end
		end
	end
end )


addEventHandler("onPlayerQuit", root, function()
	local pname = getPlayerName(source)
	if isElement ( m_mark[pname] ) then
		destroyElement ( m_mark[pname] )
	end
	if isElement ( m_pick[pname] ) then
		destroyElement ( m_pick[pname] )
	end
	if isElement ( m_blip[pname] ) then
		destroyElement ( m_blip[pname] )
	end
	-- Falls der Patient während des Transports die Verbindung trennt, den
	-- Eintrag/Blip beim Sanitäter aufräumen statt ihn dauerhaft hängen zu lassen.
	if MtxGetElementData ( source, "medicTransportBy" ) then
		for veh, patient in pairs ( transportedPatients ) do
			if patient == source then
				transportedPatients[veh] = nil
				entferneTransportBlip ( veh )
				entferneKeepaliveTimer ( veh )
			end
		end
	end
end )


