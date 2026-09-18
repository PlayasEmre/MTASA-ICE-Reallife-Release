--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

guncenterEntrance = createMarker ( 2772.8708496094, -2461.78125, 12.632966995239,  "cylinder",  2,  getColorFromString ( "#FE000199" ) )
local blip = createBlip ( 2772.8708496094, -2461.78125, 12.632966995239, 51, 1, 0, 0, 0, 255, 0, 200 )
local MafiaDeliver = createMarker ( -704.0239, 954.8858, 11.4, "checkpoint", 7, 0, 125, 0, 125, nil )
local DeliverBlip = createBlip ( -704.0239, 954.8858, 11.4, 19, 2, 255, 0, 0, 255, 0, 99999.0, nil )
setElementVisibleTo ( MafiaDeliver, root, false )
setElementVisibleTo ( DeliverBlip, root, false )

local TriadenDeliver = createMarker ( -2211.1806, 565.9678, 34.015, "checkpoint", 7, 0, 125, 0, 125, nil )
local TriadenDeliverBlip = createBlip ( -2211.1806, 565.9678, 34.015, 19, 2, 255, 0, 0, 255, 0, 99999.0, nil )
setElementVisibleTo ( TriadenDeliver, root, false )
setElementVisibleTo ( TriadenDeliverBlip, root, false )

-- Echte, im Spiel bestaetigte Position (vom Nutzer direkt uebermittelt).
local BallasDeliver = createMarker ( -2203.379, 37.957, 35.320, "checkpoint", 7, 0, 125, 0, 125, nil )
local BallasDeliverBlip = createBlip ( -2203.379, 37.957, 35.320, 19, 2, 255, 0, 0, 255, 0, 99999.0, nil )
setElementVisibleTo ( BallasDeliver, root, false )
setElementVisibleTo ( BallasDeliverBlip, root, false )

-- War vorher versehentlich exakt dieselbe Koordinate wie BallasDeliver
-- (Kopierfehler). Der Matstruck ist ein FAHRZEUG - muss also ebenerdig und
-- mit dem Auto erreichbar bleiben (der Lift in grove_gate.lua faehrt nur
-- Fussgaenger hoch, ungeeignet). Jetzt zwischen dem eigentlichen Fahrzeugtor
-- (gate, -2441,-81,33.4) und dem Grove-Lager (GroveLagerSF in fdepots.lua,
-- -2457.7,-94.3,25.8) - innerhalb des umzaeunten Gelaendes, nicht direkt am Tor.
local GroveDeliver = createMarker ( -2452.0, -92.0, 28.0, "checkpoint", 7, 0, 125, 0, 125, nil )
local GroveDeliverBlip = createBlip ( -2452.0, -92.0, 28.0, 19, 2, 255, 0, 0, 255, 0, 99999.0, nil )
setElementVisibleTo ( GroveDeliver, root, false )
setElementVisibleTo ( GroveDeliverBlip, root, false )

local AztecasDeliver = createMarker ( -1284.7417, 2451.7451, 86.73, "checkpoint", 7, 0, 125, 0, 125, nil )
local AztecasDeliverBlip = createBlip ( -1284.7417, 2451.7451, 86.73, 19, 2, 255, 0, 0, 255, 0, 99999.0, nil )
setElementVisibleTo ( AztecasDeliver, root, false )
setElementVisibleTo ( AztecasDeliverBlip, root, false )

-- Terror und Anonymus zaehlen zu den boesen Fraktionen und konnten deshalb schon
-- immer einen Matstruck starten, hatten aber keine Abgabestelle - der Truck war
-- fuer sie nicht abschliessbar und die 5.000 $ verloren.
local TerrorDeliver = createMarker ( -1968.5, -1587.0, 87.0, "checkpoint", 7, 0, 125, 0, 125, nil )
local TerrorDeliverBlip = createBlip ( -1968.5, -1587.0, 87.0, 19, 2, 255, 0, 0, 255, 0, 99999.0, nil )
setElementVisibleTo ( TerrorDeliver, root, false )
setElementVisibleTo ( TerrorDeliverBlip, root, false )

local AnonymusDeliver = createMarker ( -2207.5, 1053.0, 79.1, "checkpoint", 7, 0, 125, 0, 125, nil )
local AnonymusDeliverBlip = createBlip ( -2207.5, 1053.0, 79.1, 19, 2, 255, 0, 0, 255, 0, 99999.0, nil )
setElementVisibleTo ( AnonymusDeliver, root, false )
setElementVisibleTo ( AnonymusDeliverBlip, root, false )

local BikerDeliver = createMarker ( -2188.4504, -2358.4511, 30.476, "checkpoint", 7, 0, 125, 0, 125, nil )
local BikerDeliverBlip = createBlip ( -2188.4504, -2358.4511, 30.476, 19, 2, 255, 0, 0, 255, 0, 99999.0, nil )
setElementVisibleTo ( BikerDeliver, root, false )
setElementVisibleTo ( BikerDeliverBlip, root, false )

local weaponsTruck = false
local weaponsTruckTimer = nil
local weaponsTruckTimerAction = nil

function guncenterEntrance_func ( player, dim )
	if player and getElementType ( player ) == "player" then
		if dim then
			if getPedOccupiedVehicle ( player ) == false then
				if isEvil ( player ) then
					if not weaponsTruck then
						if not aktionlaeuft then
							infobox ( player, "Mit /matstruck\nstartest du für\n5.000$ einen\nMatstruck!", 5000, 0, 155, 0 )
						else
							infobox ( player, "Es läuft oder\nlief vor kurzem\neine Aktion!", 5000, 155, 0, 0 )
						end
					else
						infobox ( player, "Es läuft oder\nlief innerhalb der\nletzten Stunde\nein Matstruck!", 5000, 155, 0, 0 )
					end
				else
					infobox ( player, "Hier ist nichts!", 4000, 155, 0, 0 )
				end
			end
		end
	end
end
addEventHandler ( "onMarkerHit",  guncenterEntrance,  guncenterEntrance_func )


function giveTruck_func ( player )
	if not Aktiondeaktivieren then
		infobox ( player, "Gerade ist es nicht möglich einen matstruck zu starten", 5000, 150, 0, 0 )
		return
	end
	if isEvil ( player ) then
		if MtxGetElementData ( player, "money" ) >= 5000 then
			if not weaponsTruck and not aktionlaeuft then
				local x, y, z = getElementPosition ( player )
				if getDistanceBetweenPoints3D ( x, y, z, 2772.8708496094, -2461.78125, 12.632966995239 ) <= 5 then
					if getRealTime().hour < 12 then
						if getFactionMembersOnline ( 1 ) + getFactionMembersOnline ( 6 ) + getFactionMembersOnline ( 8 ) < 3 then
							infobox ( player, "Nicht genug\nStaatsfraktionisten online!", 5000, 150, 0, 0 )
							return
						end
					end
					startWeaponsTruck ( player )
				else
					infobox ( player, "Du bist nicht\nam MT-Marker!", 5000, 155, 0, 0 )
				end
			else
				infobox ( player, "Es läuft eine\nAktion oder ein\nMatstruck!", 5000, 155, 0, 0 )
				if isTimer ( weaponsTruckTimerAction ) then
					local timeleft = getTimerDetails ( weaponsTruckTimerAction )
					outputChatBox ( "Zeit bis zum nächsten Waffentruck: "..math.floor(timeleft/1000/60*100)/100 .." Minuten!", player, 155, 0, 0 )
				end
			end
		else
			infobox ( player, "\nDu brauchst\n5.000$!", 5000, 155, 0, 0 )
		end
	else
		infobox ( player, "\nNur für\nböse Fraktionisten!", 5000, 155, 0, 0 )
	end
end
addCommandHandler ( "matstruck", giveTruck_func )


function matstruckAbgabe ( hitElement )
	if weaponsTruck and hitElement and getElementType ( hitElement ) == "vehicle" then
		if hitElement == weaponsTruck then
			if getElementHealth ( hitElement ) >= 250 then
				local player = getVehicleOccupant ( hitElement, 0 )
				if player then					
					local frac = MtxGetElementData ( player, "fraktion")
					if frac ~= 2 and source == MafiaDeliver then
						return false
					elseif frac ~= 3 and source == TriadenDeliver then
						return false
					elseif frac ~= 7 and source == AztecasDeliver then
						return false
					elseif frac ~= 9 and source == BikerDeliver then
						return false
					elseif frac ~= 12 and source == BallasDeliver then
						return false
					elseif frac ~= 13 and source == GroveDeliver then
						return false
					elseif frac ~= 4 and source == TerrorDeliver then
						return false
					elseif frac ~= 14 and source == AnonymusDeliver then
						return false
					end
					destroyElement ( hitElement )
					setTimer ( function() aktionlaeuft = false end, aktionpuffer, 1 )
					local players = getElementsByType ( "player" )
					for i=1, #players do
						if MtxGetElementData ( players[i], "loggedin" ) then
							if MtxGetElementData ( players[i], "fraktion" ) == frac then
								outputChatBox ("Der Matstruck wurde erfolgreich abgegeben!", players[i], 0, 255, 0)
							else
								outputChatBox ("Der Matstruck wurde abgegeben!", players[i], 255, 0, 0)
							end
						end
					end				
					weaponsTruck = true
					weaponsTruckTimerAction = setTimer ( function() weaponsTruck = false end, 60*60*1000, 1 )
					factionDepotData["mats"][frac] = factionDepotData["mats"][frac] + 4500
					local damoney = 0
					if factionDepotData["money"][frac] >= 5000 then
						factionDepotData["money"][frac] = factionDepotData["money"][frac] - 5000
						damoney = 5000
					else
						damoney = factionDepotData["money"][frac] 
						factionDepotData["money"][frac] = 0
					end
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) + damoney )
					clearElementVisibleTo ( MafiaDeliver )
					clearElementVisibleTo ( DeliverBlip )
					clearElementVisibleTo ( TriadenDeliver )
					clearElementVisibleTo ( TriadenDeliverBlip )
					clearElementVisibleTo ( AztecasDeliver )
					clearElementVisibleTo ( AztecasDeliverBlip )
					clearElementVisibleTo ( BikerDeliver )
					clearElementVisibleTo ( BikerDeliverBlip )
					clearElementVisibleTo ( BallasDeliver )
					clearElementVisibleTo ( BallasDeliverBlip )
					clearElementVisibleTo ( GroveDeliver )
					clearElementVisibleTo ( GroveDeliverBlip )
					clearElementVisibleTo ( TerrorDeliver )
					clearElementVisibleTo ( TerrorDeliverBlip )
					clearElementVisibleTo ( AnonymusDeliver )
					clearElementVisibleTo ( AnonymusDeliverBlip )
					setElementVisibleTo ( MafiaDeliver, getRootElement(), false )
					setElementVisibleTo ( DeliverBlip, getRootElement(), false )
					setElementVisibleTo ( TriadenDeliver, getRootElement(), false )
					setElementVisibleTo ( TriadenDeliverBlip, getRootElement(), false )
					setElementVisibleTo ( AztecasDeliver, getRootElement(), false )
					setElementVisibleTo ( AztecasDeliverBlip, getRootElement(), false )
					setElementVisibleTo ( BikerDeliver, getRootElement(), false )
					setElementVisibleTo ( BikerDeliverBlip, getRootElement(), false )
					setElementVisibleTo ( BallasDeliver, getRootElement(), false )
					setElementVisibleTo ( BallasDeliverBlip, getRootElement(), false )
					setElementVisibleTo ( GroveDeliver, getRootElement(), false )
					setElementVisibleTo ( GroveDeliverBlip, getRootElement(), false )
					setElementVisibleTo ( TerrorDeliver , getRootElement(), false )
					setElementVisibleTo ( TerrorDeliverBlip , getRootElement(), false )
					setElementVisibleTo ( AnonymusDeliver , getRootElement(), false )
					setElementVisibleTo ( AnonymusDeliverBlip , getRootElement(), false )
					if weaponsTruckTimer and isTimer ( weaponsTruckTimer ) then
						killTimer ( weaponsTruckTimer )
						weaponsTruckTimer = nil
					end
				end
			end
		end
	end
end
								
addEventHandler ( "onMarkerHit", MafiaDeliver, matstruckAbgabe )
addEventHandler ( "onMarkerHit", TriadenDeliver, matstruckAbgabe )
addEventHandler ( "onMarkerHit", AztecasDeliver, matstruckAbgabe )
addEventHandler ( "onMarkerHit", BikerDeliver, matstruckAbgabe )
addEventHandler ( "onMarkerHit", BallasDeliver, matstruckAbgabe )
addEventHandler ( "onMarkerHit", GroveDeliver, matstruckAbgabe )
addEventHandler ( "onMarkerHit", TerrorDeliver, matstruckAbgabe )
addEventHandler ( "onMarkerHit", AnonymusDeliver, matstruckAbgabe )


function startWeaponsTruck ( player )
	outputChatBox ( "Ein Matstruck wurde beladen!", getRootElement(), 125, 0, 0 )
	outputChatBox ( "Bringe nun den Truck zurück zur Basis!", player, 0, 125, 0 )
	MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - 5000 )
	weaponsTruck = createVehicle ( 455, 2765.6179199219, -2455.2485351563, 14.051976203918, 0, 0, 0, "BonusRulez" )
	setVehiclePaintjob ( weaponsTruck, 2 )
	setVehicleColor ( weaponsTruck, 40, 1, 0, 0 )
	warpPedIntoVehicle ( player, weaponsTruck )
	setElementHealth ( weaponsTruck, 2000 )
	aktionlaeuft = true
	outputLog ( "Matstruck - "..getPlayerName(player).." - "..fraktionNames[MtxGetElementData ( player, "fraktion")], "aktion" )
	if MtxGetElementData ( player, "fraktion" ) == 2 then
		setElementVisibleTo ( MafiaDeliver, player, true )
		setElementVisibleTo ( DeliverBlip, player, true )
	elseif MtxGetElementData ( player, "fraktion" ) == 3 then
		setElementVisibleTo ( TriadenDeliver, player, true )
		setElementVisibleTo ( TriadenDeliverBlip, player, true )
	elseif MtxGetElementData ( player, "fraktion" ) == 7 then
		setElementVisibleTo ( AztecasDeliver, player, true )
		setElementVisibleTo ( AztecasDeliverBlip, player, true )
	elseif MtxGetElementData ( player, "fraktion" ) == 9 then
		setElementVisibleTo ( BikerDeliver, player, true )
		setElementVisibleTo ( BikerDeliverBlip, player, true )
	elseif MtxGetElementData ( player, "fraktion" ) == 12 then
		setElementVisibleTo ( BallasDeliver, player, true )
		setElementVisibleTo ( BallasDeliverBlip, player, true )
	elseif MtxGetElementData ( player, "fraktion" ) == 13 then
		setElementVisibleTo ( GroveDeliver, player, true )
		setElementVisibleTo ( GroveDeliverBlip, player, true )
	elseif MtxGetElementData ( player, "fraktion" ) == 4 then
		setElementVisibleTo ( TerrorDeliver, player, true )
		setElementVisibleTo ( TerrorDeliverBlip, player, true )
	elseif MtxGetElementData ( player, "fraktion" ) == 14 then
		setElementVisibleTo ( AnonymusDeliver, player, true )
		setElementVisibleTo ( AnonymusDeliverBlip, player, true )
	end
	if weaponsTruckTimer and isTimer ( weaponsTruckTimer ) then
		killTimer ( weaponsTruckTimer )
	end
	weaponsTruckTimer = setTimer ( destroyWtruck, 15*60*1000, 1 )
	addEventHandler ( "onVehicleEnter", weaponsTruck, vehicleEnterMafiaTruck )
	addEventHandler ( "onVehicleExit", weaponsTruck, vehicleExitMafiaTruck )
	addEventHandler ( "onVehicleExplode", weaponsTruck, vehicleExplodeMafiaTruck )
end
	
	
function vehicleEnterMafiaTruck ( player, seat )
	if seat ~= 0 then return false end
	if MtxGetElementData ( player, "fraktion" ) == 2 then
		if source == weaponsTruck then
			setElementVisibleTo ( MafiaDeliver, player, true )
			setElementVisibleTo ( DeliverBlip, player, true )
		end
	end
	if MtxGetElementData ( player, "fraktion" ) == 3 then
		if source == weaponsTruck then
			setElementVisibleTo ( TriadenDeliver, player, true )
			setElementVisibleTo ( TriadenDeliverBlip, player, true )
		end
	end
	if MtxGetElementData ( player, "fraktion" ) == 7 then
		if source == weaponsTruck then
			setElementVisibleTo ( AztecasDeliver, player, true )
			setElementVisibleTo ( AztecasDeliverBlip, player, true )
		end
	end
	if MtxGetElementData ( player, "fraktion" ) == 9 then
		if source == weaponsTruck then
			setElementVisibleTo ( BikerDeliver, player, true )
			setElementVisibleTo ( BikerDeliverBlip, player, true )
		end
	end
	if MtxGetElementData ( player, "fraktion" ) == 12 then
		if source == weaponsTruck then
			setElementVisibleTo ( BallasDeliver, player, true )
			setElementVisibleTo ( BallasDeliverBlip, player, true )
		end
	end
	if MtxGetElementData ( player, "fraktion" ) == 13 then
		if source == weaponsTruck then
			setElementVisibleTo ( GroveDeliver, player, true )
			setElementVisibleTo ( GroveDeliverBlip, player, true )
		end
	end
	if MtxGetElementData ( player, "fraktion" ) == 4 then
		if source == weaponsTruck then
			setElementVisibleTo ( TerrorDeliver, player, true )
			setElementVisibleTo ( TerrorDeliverBlip, player, true )
		end
	end
	if MtxGetElementData ( player, "fraktion" ) == 14 then
		if source == weaponsTruck then
			setElementVisibleTo ( AnonymusDeliver, player, true )
			setElementVisibleTo ( AnonymusDeliverBlip, player, true )
		end
	end
end


function vehicleExitMafiaTruck ( player, seat )
	if seat ~= 0 then return false end
	if not source then return end
	if source ~= weaponsTruck then return end
	
	if MtxGetElementData ( player, "fraktion" ) == 2 then
		if source == weaponsTruck then
			setElementVisibleTo ( MafiaDeliver, player, false )
			setElementVisibleTo ( DeliverBlip, player, false )
		end
	end
	if MtxGetElementData ( player, "fraktion" ) == 3 then
		if source == weaponsTruck then
			setElementVisibleTo ( TriadenDeliver, player, false )
			setElementVisibleTo ( TriadenDeliverBlip, player, false )
		end
	end
	if MtxGetElementData ( player, "fraktion" ) == 7 then
		if source == weaponsTruck then
			setElementVisibleTo ( AztecasDeliver, player, false )
			setElementVisibleTo ( AztecasDeliverBlip, player, false )
		end
	end
	if MtxGetElementData ( player, "fraktion" ) == 9 then
		if source == weaponsTruck then
			setElementVisibleTo ( BikerDeliver, player, false )
			setElementVisibleTo ( BikerDeliverBlip, player, false )
		end
	end
	if MtxGetElementData ( player, "fraktion" ) == 12 then
		if source == weaponsTruck then
			setElementVisibleTo ( BallasDeliver, player, false )
			setElementVisibleTo ( BallasDeliverBlip, player, false )
		end
	end
	if MtxGetElementData ( player, "fraktion" ) == 13 then
		if source == weaponsTruck then
			setElementVisibleTo ( GroveDeliver, player, false )
			setElementVisibleTo ( GroveDeliverBlip, player, false )
		end
	end
	if MtxGetElementData ( player, "fraktion" ) == 4 then
		if source == weaponsTruck then
			setElementVisibleTo ( TerrorDeliver, player, false )
			setElementVisibleTo ( TerrorDeliverBlip, player, false )
		end
	end
	if MtxGetElementData ( player, "fraktion" ) == 14 then
		if source == weaponsTruck then
			setElementVisibleTo ( AnonymusDeliver, player, false )
			setElementVisibleTo ( AnonymusDeliverBlip, player, false )
		end
	end
end


function vehicleExplodeMafiaTruck ()
	outputChatBox ( "Der Matstruck wurde zerstört!", getRootElement(), 255, 0, 0 )
	if isElement ( weaponsTruck ) then
		destroyElement ( weaponsTruck )
	end
	weaponsTruck = true
	clearElementVisibleTo ( MafiaDeliver )
	clearElementVisibleTo ( DeliverBlip )
	clearElementVisibleTo ( TriadenDeliver )
	clearElementVisibleTo ( TriadenDeliverBlip )
	clearElementVisibleTo ( AztecasDeliver )
	clearElementVisibleTo ( AztecasDeliverBlip )
	clearElementVisibleTo ( BikerDeliver )
	clearElementVisibleTo ( BikerDeliverBlip )
	clearElementVisibleTo ( BallasDeliver )
	clearElementVisibleTo ( BallasDeliverBlip )
	clearElementVisibleTo ( GroveDeliver )
	clearElementVisibleTo ( GroveDeliverBlip )
	clearElementVisibleTo ( TerrorDeliver )
	clearElementVisibleTo ( TerrorDeliverBlip )
	clearElementVisibleTo ( AnonymusDeliver )
	clearElementVisibleTo ( AnonymusDeliverBlip )
	setElementVisibleTo ( MafiaDeliver, getRootElement(), false )
	setElementVisibleTo ( DeliverBlip, getRootElement(), false )
	setElementVisibleTo ( TriadenDeliver, getRootElement(), false )
	setElementVisibleTo ( TriadenDeliverBlip, getRootElement(), false )
	setElementVisibleTo ( AztecasDeliver, getRootElement(), false )
	setElementVisibleTo ( AztecasDeliverBlip, getRootElement(), false )
	setElementVisibleTo ( BikerDeliver, getRootElement(), false )
	setElementVisibleTo ( BikerDeliverBlip, getRootElement(), false )
	setElementVisibleTo ( BallasDeliver, getRootElement(), false )
	setElementVisibleTo ( BallasDeliverBlip, getRootElement(), false )
	setElementVisibleTo ( GroveDeliver, getRootElement(), false )
	setElementVisibleTo ( GroveDeliverBlip, getRootElement(), false )
	setElementVisibleTo ( TerrorDeliver , getRootElement(), false )
	setElementVisibleTo ( TerrorDeliverBlip , getRootElement(), false )
	setElementVisibleTo ( AnonymusDeliver , getRootElement(), false )
	setElementVisibleTo ( AnonymusDeliverBlip , getRootElement(), false )
	setTimer ( function() aktionlaeuft = false end, aktionpuffer, 1 )
	weaponsTruckTimerAction = setTimer ( function() weaponsTruck = false end, 60*60*1000, 1 )
	if weaponsTruckTimer and isTimer ( weaponsTruckTimer ) then
		killTimer ( weaponsTruckTimer )
		weaponsTruckTimer = nil
	end
end
	

function destroyWtruck ()
	outputChatBox ( "Der Matstruck wurde wegen Zeitüberschreitung zerstört!", getRootElement(), 255, 0, 0 )
	if isElement ( weaponsTruck ) then
		destroyElement ( weaponsTruck )
	end
	weaponsTruck = true
	weaponsTruckTimerAction = setTimer ( function() weaponsTruck = false end, 60*60*1000, 1 )
	clearElementVisibleTo ( MafiaDeliver )
	clearElementVisibleTo ( DeliverBlip )
	clearElementVisibleTo ( TriadenDeliver )
	clearElementVisibleTo ( TriadenDeliverBlip )
	clearElementVisibleTo ( AztecasDeliver )
	clearElementVisibleTo ( AztecasDeliverBlip )
	clearElementVisibleTo ( BikerDeliver )
	clearElementVisibleTo ( BikerDeliverBlip )
	clearElementVisibleTo ( BallasDeliver )
	clearElementVisibleTo ( BallasDeliverBlip )
	clearElementVisibleTo ( GroveDeliver )
	clearElementVisibleTo ( GroveDeliverBlip )
	clearElementVisibleTo ( TerrorDeliver )
	clearElementVisibleTo ( TerrorDeliverBlip )
	clearElementVisibleTo ( AnonymusDeliver )
	clearElementVisibleTo ( AnonymusDeliverBlip )
	setElementVisibleTo ( MafiaDeliver, getRootElement(), false )
	setElementVisibleTo ( DeliverBlip, getRootElement(), false )
	setElementVisibleTo ( TriadenDeliver, getRootElement(), false )
	setElementVisibleTo ( TriadenDeliverBlip, getRootElement(), false )
	setElementVisibleTo ( AztecasDeliver, getRootElement(), false )
	setElementVisibleTo ( AztecasDeliverBlip, getRootElement(), false )
	setElementVisibleTo ( BikerDeliver, getRootElement(), false )
	setElementVisibleTo ( BikerDeliverBlip, getRootElement(), false )
	setElementVisibleTo ( BallasDeliver, getRootElement(), false )
	setElementVisibleTo ( BallasDeliverBlip, getRootElement(), false )
	setElementVisibleTo ( GroveDeliver, getRootElement(), false )
	setElementVisibleTo ( GroveDeliverBlip, getRootElement(), false )
	setElementVisibleTo ( TerrorDeliver , getRootElement(), false )
	setElementVisibleTo ( TerrorDeliverBlip , getRootElement(), false )
	setElementVisibleTo ( AnonymusDeliver , getRootElement(), false )
	setElementVisibleTo ( AnonymusDeliverBlip , getRootElement(), false )
	setTimer ( function() aktionlaeuft = false end, aktionpuffer, 1 )
	if weaponsTruckTimer and isTimer ( weaponsTruckTimer ) then
		killTimer ( weaponsTruckTimer )
		weaponsTruckTimer = nil
	end
end
