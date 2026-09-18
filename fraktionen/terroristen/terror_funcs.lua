--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local terror_marker = createMarker ( -1965.44140625, -1589.2802734375, 88.685966491699, "cylinder", - 3 )
local TerrorOben = createMarker(-1973.8000488281, -1574.6999511719, 131.89999389648, "corona", 1.2, 125, 0, 0, 255)
local TerrorUnten = createMarker(-1979.8000488281, -1579.3000488281, 87.400001525879, "corona", 1.2, 125, 0, 0, 255)
local vehWithBomb = {}
local c4gesetzt = {}

function TerrorToOben_func(player)
	if getElementType(player) == "player" and getPedOccupiedVehicle(player) == false then
		fadeElementInterior(player, 0, -1975.8000488281, -1574.3000488281, 131.89999389648, 0, 0)
	end
end
addEventHandler("onMarkerHit", TerrorUnten, TerrorToOben_func)

function TerrorToUnten_func(player)
	if getElementType(player) == "player" and getPedOccupiedVehicle(player) == false then
		fadeElementInterior(player, 0, -1979.8000488281, -1579.3000488281, 87.400001525879, 0, 0)
	end
end
addEventHandler("onMarkerHit", TerrorOben, TerrorToUnten_func)

function finishTerrorBomb ( veh, player )
	if isElement(veh) and isElement(player) then
		outputChatBox ( "Bombe ist fertig eingebaut!", player, 0, 125, 0 )
		outputChatBox ( "Benutze /detonate, um sie zu zuenden!", player, 0, 125, 0 )
		setElementFrozen ( veh, false )
		vehWithBomb[veh] = true
		addEventHandler ( "onVehicleRespawn", veh, 
		function ()
			vehWithBomb[source] = nil
		end )
	end
end

addEventHandler( "onMarkerHit", terror_marker, 
	function ( element, dim )
	if getElementType( element ) == "vehicle" then
		local player = getVehicleOccupant ( element )
		if player then 
			if isTerror ( player ) then
				setElementFrozen ( element, true )
				outputChatBox ( "Bombe wird eingebaut ...", player, 125, 125, 0 )
				setTimer ( finishTerrorBomb, 10000, 1, element, player )
			end
		end
	end
end)
	
function terrorExplodeCar ( car, pl )
	local x, y, z = getElementPosition ( car )
	createExplosion ( x, y, z, 0, pl )
	createExplosion ( x, y, z, 10, pl )
	createExplosion ( x, y, z, 8, pl )
	createExplosion ( x, y, z, 4, pl )
	createExplosion ( x, y, z, 2, pl )
	createExplosion ( x, y, z, 1, pl )
	vehWithBomb[car] = nil
	blowVehicle ( car, true )
end
	
addCommandHandler( "detonate", 
	function ( player )
		local veh = getPedOccupiedVehicle ( player )
		if isTerror(player) and veh then
			local pcheck = getVehicleOccupant ( veh )
			if pcheck == player and vehWithBomb[veh] then
				outputChatBox ( "Bombe geht in 10 Sekunden hoch ...", player, 125, 125, 0 )
				setTimer ( terrorExplodeCar, 10000, 1, veh, player )
			end
		end
	end,
false,false)

-- Das frühere /equip-Paket wurde entfernt: Waffen und C4 laufen jetzt über
-- /fguns am Waffenlager (siehe fraktionen/fdepots.lua), damit Terroristen
-- dieselbe Material- und Rangregelung haben wie die anderen Fraktionen.

-- c4gesetzt ist hier lokal, deshalb greift fdepots.lua ueber diese beiden
-- Funktionen darauf zu.

-- Wahr, solange der Spieler eine C4 besitzt: vom Kauf bis zur Detonation.
-- Eine abgelegte, aber noch nicht gezuendete C4 zaehlt weiterhin als vorhanden.
function hatTerroristC4 ( player )
	return c4gesetzt[player] == true
end

-- Gibt dem Terroristen eine C4. Mehr als eine gleichzeitig ist nicht moeglich,
-- weil c4gesetzt nur ein Ja/Nein kennt und beim Zuenden auf false faellt - eine
-- zweite C4 waere sonst beim ersten Zuenden mit verloren.
function gibTerroristC4 ( player )
	if not isElement ( player ) or not isTerror ( player ) then return false end
	if hatTerroristC4 ( player ) then return false end
	c4gesetzt[player] = true
	MtxSetElementData ( player, "hasBomb", true )
	return true
end

-- Ohne das bleibt der Eintrag nach dem Verlassen dauerhaft in der Tabelle stehen.
addEventHandler ( "onPlayerQuit", getRootElement(), function ()
	c4gesetzt[source] = nil
end )

function arm_func ( player )
	if isTerror ( player ) then
		if isKeyBound ( player, "mouse3", "up", explodeTerror ) then
			outputChatBox ( "Bombe entschaerft!", player, 0, 125, 0 )
			MtxSetElementData ( player, "hasBomb", true )
			setPlayerNametagColor ( player, 200, 200, 200 )
			unbindKey ( player, "mouse3", "up", explodeTerror )
		elseif MtxGetElementData ( player, "armingBomb" ) then
			outputChatBox ( "Du machst die Bombe bereits scharf!", player, 125, 0, 0 )
		elseif MtxGetElementData ( player, "hasBomb" ) then
			setTimer ( arm_bomb, 7500, 1, player )
			outputChatBox ( "Bombe wird scharfgemacht...", player, 125, 125, 0 )
			MtxSetElementData ( player, "armingBomb", true )
		else
			outputChatBox ( "Du hast keine Bombe!", player, 125, 0, 0 )
		end
	end
end
addCommandHandler ( "arm", arm_func )

function arm_bomb ( player )
	if not isPedDead ( player ) and MtxGetElementData ( player, "hasBomb" ) then
		bindKey ( player, "mouse3", "up", explodeTerror, player )
		outputChatBox ( "Bombe ist scharf!", player, 0, 125, 0 )
		setPlayerNametagColor ( player, 200, 0, 0 )
		MtxSetElementData ( player, "hasBomb", false )
	else
		outputChatBox ( "Du hast keine Bombe/bist Tod!", player, 125, 0, 0 )
	end
	MtxSetElementData ( player, "armingBomb", false )
end

function explodeTerror ( keyPresser )
	local x, y, z = getElementPosition ( keyPresser )
	local rnd = math.random ( 7, 12 )
	createExplosion ( x, y, z, rnd, keyPresser )
	setTimer ( reExplode, 100, 1, keyPresser )
	setPlayerNametagColor ( keyPresser, 200, 200, 200 )
	unbindKey ( keyPresser, "mouse3", "up", explodeTerror )
end

function reExplode ( player )
	setTimer ( reReExplode, math.floor(math.random(200,1000)), 1, player )
	setTimer ( reReExplode, math.floor(math.random(200,1000)), 1, player )
	setTimer ( reReExplode, math.floor(math.random(200,1000)), 1, player )
	setTimer ( reReExplode, math.floor(math.random(200,1000)), 1, player )
	setTimer ( reReExplode, math.floor(math.random(200,1000)), 1, player )
end

function reReExplode ( player )
	local veh = getPedOccupiedVehicle ( player )
	local x, y, z = getElementPosition ( player )
	if veh then
		local x, y, z = getElementPosition ( veh )
	end
	local rnd = math.random ( 7, 12 )
	createExplosion ( x, y, z, rnd, player )
end

addCommandHandler("c4", function(player)
	if isTerror ( player ) then
		if c4gesetzt[player] then
			if not getElementData(player, "bombPlaced") then
				local px, py, pz = getElementPosition(player)
				local prz = getElementRotation(player)
				c4 = createObject(1252, px, py, pz - 0.95, 90, 0, prz)
				setElementFrozen(c4, true)
				local x, y, z = getElementPosition(c4)
				setElementData(c4, "gesetzt", true)
				setElementData(c4, "besitzer", getPlayerName(player))
				setElementData(player, "bombPlaced", true)
				outputChatBox("Du hast nun eine Bombe gelegt!", player, 125, 0, 0)
			else
				outputChatBox("Du hast schon eine Bombe gesetzt!", player, 125, 0, 0) 
			end
		else
			outputChatBox("Du hast kein C4!", player, 125, 0, 0) 
		end
	else
		outputChatBox("Du bist kein Terrorist!", player, 125, 0, 0) 
	end
end)

addCommandHandler("c4back", function(player)
    if isElement(c4) and getElementData(c4, "besitzer") == getPlayerName(player) and getElementData(c4, "gesetzt") == true then
        local px, py, pz = getElementPosition(player)
        local x, y, z = getElementPosition(c4)
        if getDistanceBetweenPoints3D(px, py, pz, x, y, z) < 5 then
            setElementData(c4, "gesetzt", false)
            if isElement(c4) then 
				destroyElement(c4) 
			end
            setElementData(player, "bombPlaced", false)
			c4gesetzt[player] = true
            outputChatBox("Du hast deine C4 wieder aufgehoben", player, 0, 125, 0)
        else
            outputChatBox("Du bist zu weit von deiner Bombe entfernt.", player, 125, 0, 0)
        end
    end
end)


addCommandHandler("detonatec4", function(player)
    if isElement(c4) and getElementData(c4, "besitzer") == getPlayerName(player) and getElementData(c4, "gesetzt") == true then
        local x, y, z = getElementPosition(c4)
        setTimer(function()
            createExplosion(x, y, z, 0)
            createExplosion(x, y, z, 10)
            createExplosion(x, y, z, 8)
            createExplosion(x, y, z, 4)
            createExplosion(x, y, z, 2)
            createExplosion(x, y, z, 2)
			createExplosion(x, y, z, 10)
			createExplosion(x, y, z, 10)
			createExplosion(x, y, z, 10)
			createExplosion(x, y, z, 4)
			createExplosion(x, y, z, 4)
			createExplosion(x, y, z, 4)
            setElementData(c4, "gesetzt", false)
            setElementData(c4, "besitzer", nil)
            setElementData(player, "bombPlaced", false)
			c4gesetzt[player] = false
            if isElement(c4) then 
				destroyElement(c4) 
			end
            outputChatBox("Deine Bombe ist erfolgreich hoch gegangen", player, 0, 125, 0)
        end, 50, 1)
    end
end)
