fahrschulVehicles = {}

function fahrschuleVehicles(player,seat)
	local veh = source
	if seat == 0 and fahrschulVehicles[veh] == true then
	    if not isFahrschuleDuty ( player ) --[[and MtxGetElementData( player, "inpruefung") == true and isElementFrozen(veh) == true--]] then
		    outputChatBox("Viel Spaß beim fahren", player, 125, 125, 0)
			outputChatBox("Man sollte in der Prüfung nicht das Fahrzeug verlassen", player, 125, 125, 0)
			setElementFrozen(veh,false)
			setVehicleDamageProof(veh, true)
		elseif not isFahrschuleDuty ( player ) then
			opticExitVehicle ( player )
			outputChatBox ( "Du bist nicht als Fahrlehrer im Dienst", player, 125, 0, 0 )
		end
	end
end
addEventHandler ( "onVehicleEnter",root,fahrschuleVehicles)

-- onRespawned (optional) wird sowohl beim ersten Erzeugen als auch nach jedem
-- automatischen Respawn aufgerufen - damit koennen Aufrufer (z.B. der LKW-
-- Anhaenger) sich z.B. wieder ankoppeln, ohne die Respawn-Logik hier selbst
-- nachzubauen.
function createfahrschulVehicle ( model, x, y, z, rx, ry, rz, onRespawned )
	local veh = createVehicle ( model, x, y, z, rx, ry, rz )
	setVehicleColor ( veh, 224, 255, 255, 224, 255, 255, 224, 255, 255 )
	setVehiclePaintjob ( veh, 3 )
	setElementHealth ( veh, 1700 )
	toggleVehicleRespawn ( veh, true )
	setVehicleRespawnDelay ( veh, FCarDestroyRespawn * 1000 * 60 )
	setVehicleIdleRespawnDelay ( veh, FCarIdleRespawn * 1000 * 60 )
	fahrschulVehicles[veh] = true
	setElementFrozen(veh,true)
	addEventHandler ( "onVehicleExplode",veh,function()
		setTimer(createfahrschulVehicle, 1 * 60 * 1000, 1, model, x, y, z, rx, ry, rz, onRespawned)
	end)
	addEventHandler ( "onElementDestroy", veh, function()
		fahrschulVehicles[veh] = nil
	end)
	if onRespawned then onRespawned ( veh ) end
	return veh
end


createfahrschulVehicle(405,-1768.2,-132.0,3.4,0,0,270)
createfahrschulVehicle(405,-1768.2,-135.8,3.4,0,0,270)
createfahrschulVehicle(579,-1768.2,-139.9,3.5,0,0,270)
createfahrschulVehicle(579,-1768.2,-144.2,3.5,0,0,270)
createfahrschulVehicle(487,-1765.0,-179.6,3.6,0,0,270)
createfahrschulVehicle(487,-1765.0,-168.1,3.6,0,0,270)
createfahrschulVehicle(487,-1765.0,-157.4,3.6,0,0,270)
createfahrschulVehicle(468,-1737.3,-170.0,3.2,0,0,48)
createfahrschulVehicle(468,-1740.2,-172.8,3.2,0,0,48)
createfahrschulVehicle(468,-1743.3,-175.7,3.2,0,0,48)
createfahrschulVehicle(468,-1746.2,-178.4,3.2,0,0,48)
createfahrschulVehicle(446,-1768.4,-192.0,0.0,0,0,180)
createfahrschulVehicle(446,-1752.0,-192.0,0.0,0,0,180)


lkwAnhaengerPaare = {}

-- Der Anhaenger (Modell 435) haengt immer im selben Abstand/derselben
-- Ausrichtung hinter der Zugmaschine (Modell 515) - Position wird deshalb aus
-- der LKW-Position berechnet, statt fuer jedes Gespann per Hand ausgerechnet
-- zu werden. Zum Verschieben eines Gespanns reicht es also, nur noch die
-- LKW-Koordinaten unten anzupassen, der Anhaenger zieht automatisch mit.
local LKW_ANHAENGER_ABSTAND = 11.8 -- aus den bisherigen, von Hand plazierten Gespannen ermittelt

local function erstelleLkwGespann ( truckX, truckY, truckZ, rz )
	local truck = createfahrschulVehicle ( 515, truckX, truckY, truckZ, 0, 0, rz )
	local rad = math.rad ( rz )
	local trailerX = truckX + math.sin ( rad ) * LKW_ANHAENGER_ABSTAND
	local trailerY = truckY - math.cos ( rad ) * LKW_ANHAENGER_ABSTAND

	local paar = { truck = truck, x = trailerX, y = trailerY, z = truckZ, rx = 0, ry = 0, rz = rz }
	lkwAnhaengerPaare[#lkwAnhaengerPaare + 1] = paar

	-- Anhaenger wird wie jedes andere Fahrschul-Fahrzeug erzeugt - dadurch
	-- respawnt er nach dem Zerstoeren automatisch von selbst (siehe
	-- createfahrschulVehicle). Der Hook unten haengt ihn danach wieder an den
	-- LKW und haelt den lkwAnhaengerPaare-Eintrag aktuell.
	createfahrschulVehicle ( 435, trailerX, trailerY, truckZ, 0, 0, rz, function ( neuerAnhaenger )
		paar.trailer = neuerAnhaenger
		setElementFrozen ( neuerAnhaenger, false ) -- Anhaenger muss beweglich sein, um gezogen werden zu koennen
		attachTrailerToVehicle ( paar.truck, neuerAnhaenger )
		if bindeAnhaengerDetachHandler then
			bindeAnhaengerDetachHandler ( paar )
		end
	end )
end

erstelleLkwGespann ( -1708.9, -134.0, 4.1, 135 )
erstelleLkwGespann ( -1705.1, -137.8, 4.1, 135 )