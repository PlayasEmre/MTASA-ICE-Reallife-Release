--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local abschlepp_marker = createMarker( -2089.634765625,-177.40313720703,35.3203125, "corona", 3, 255, 0, 0, 255 )

function absfunc (hitElement)
	if getElementType(hitElement) == "vehicle" then
		local player = getVehicleOccupant(hitElement,0)
		if isElement(player) then
			if isMechaniker(player) then
				if getElementModel ( hitElement ) == 525 then
					local towedVehicle = getVehicleTowedByVehicle ( hitElement )
					if towedVehicle ~= false then
						if MtxGetElementData(towedVehicle, "owner") then
							if MtxGetElementData ( towedVehicle, "ownerfraktion" ) then
								 outputChatBox("Dieses Fahrzeug kannst du nicht Abschleppen (Fraktionsfahrzeug etc).", player, 255, 155, 0)
								 return false 
							end
							local x, y, z = getElementPosition ( towedVehicle )
							local rx, ry, rz = getVehicleRotation ( towedVehicle )
							MtxSetElementData ( towedVehicle, "Beschlagnahmt", 1 )
							MtxSetElementData ( towedVehicle, "spawnposx", x )
							MtxSetElementData ( towedVehicle, "spawnposy", y )
							MtxSetElementData ( towedVehicle, "spawnposz", z )
							MtxSetElementData ( towedVehicle, "spawnrotx", rx )
							MtxSetElementData ( towedVehicle, "spawnroty", ry )
							MtxSetElementData ( towedVehicle, "spawnrotz", rz )
							setElementFrozen( towedVehicle, true )
							setVehicleDamageProof( towedVehicle, true )
							setVehicleEngineState ( towedVehicle, false )
							MtxSetElementData ( towedVehicle, "engine", false )
							local Spawnpos_X, Spawnpos_Y, Spawnpos_Z = getElementPosition ( towedVehicle )
							local Spawnrot_X, Spawnrot_Y, Spawnrot_Z = getVehicleRotation ( towedVehicle )
							local Farbe1, Farbe2, Farbe3, Farbe4 =  getVehicleColor ( towedVehicle )
							local color = "|"..Farbe1.."|"..Farbe2.."|"..Farbe3.."|"..Farbe4.."|"
							local Paintjob = getVehiclePaintjob ( towedVehicle ) or 3
							setElementPosition(towedVehicle,-2068.6342773438,-134.87577819824,34.919010162354)
							setElementDimension(towedVehicle,4515)
							local Benzin = MtxGetElementData ( towedVehicle, "fuelstate" )
							local pname = MtxGetElementData ( towedVehicle, "owner" )
							local Distance = MtxGetElementData ( towedVehicle, "distance" )
							local Beschlagnahmt = MtxGetElementData ( towedVehicle, "Beschlagnahmt")
							local slot = MtxGetElementData ( towedVehicle, "carslotnr_owner" )
							dbExec ( handler, "UPDATE vehicles SET Spawnpos_X=?, Spawnpos_Y=?, Spawnpos_Z=?, Spawnrot_X=?, Spawnrot_Y=?, Spawnrot_Z=?, Farbe=?, Paintjob=?, Benzin=?, Distance=?, Beschlagnahmt=? WHERE UID=? AND Slot=?",Spawnpos_X, Spawnpos_Y, Spawnpos_Z, Spawnrot_X, Spawnrot_Y, Spawnrot_Z, color, Paintjob, Benzin, Distance, Beschlagnahmt, playerUID[pname], slot)
							MtxSetElementData(player,"money",tonumber(MtxGetElementData(player,"money"))+360)
							outputChatBox ( "Du hast das Auto erfolgreich abgeschleppt!", player, 0, 255, 0 )
							outputChatBox( "Du erhältst 360 € für jedes abgeschleppte Fahrzeug",player)
							outputChatBox ("Dein Fahrzeug in Slot "..slot.." wurde abgeschleppt!",getPlayerFromName(pname),255,0,0)
							offlinemsg (getPlayerName(player).. " Dein Fahrzeug in Slot "..slot.." wurde abgeschleppt!", "abgeschleppt", pname )
					  end
					 else outputChatBox("Du hast keinen Fahrzeug an einem Anhänger gerade !",player,200,200,0)
				 end
				else outputChatBox ( "Du brauchst einen Abschleppwagen!", player, 200, 200, 0 ) end 
			 else outputChatBox ( "Du bist nicht berechtigt!", player, 200, 200, 0 ) end
		end
	end
end
addEventHandler("onMarkerHit", abschlepp_marker, absfunc)


local AbholPickup = createPickup(-2028.6102294922,-106.0006942749,35.167686462402, 3, 1318, 0)

function isElementWithinPickup(theElement, thePickup)
	if (isElement(theElement) and getElementType(thePickup) == "pickup") then
		local x, y, z = getElementPosition(theElement)
		local x2, y2, z2 = getElementPosition(thePickup)
		if (getDistanceBetweenPoints3D(x2, y2, z2, x, y, z) <= 1) then
			return true
		end
	end
	return false
end


addEventHandler("onPickupHit", AbholPickup, function(player)
	if getElementType(player) == "player" and getPedOccupiedVehicle(player) == false then
		outputChatBox("Hier kannst du deine Fahrzeuge freikaufen 2000€", player, 0, 125, 0)
		outputChatBox("Befehl: /freikaufen <slot>", player, 0, 125, 0)
	end
end)


addCommandHandler("freikaufen", function(player, _, carslot)
	if isElementWithinPickup(player, AbholPickup) then
		local carslot = tonumber(carslot)
		if carslot and carslot > 0 then
			local vehicle = allPrivateCars[getPlayerName(player)][carslot] or false
			if vehicle ~= false then
			local x, y, z = getElementPosition ( vehicle )
				if MtxGetElementData(vehicle, "Beschlagnahmt") == 1 then
					if MtxGetElementData(player, "money") >= 2000 then
						takePlayerSaveMoney(player, 2000)
						setElementDimension(vehicle, 0)
						setElementFrozen(vehicle, false)
						setVehicleDamageProof(vehicle, false)
						fixVehicle(vehicle)
						setElementPosition(vehicle, -2063.9660644531,-85.355171203613,34.714595794678)
						setElementRotation (vehicle,0,0,180)
                        warpPedIntoVehicle(player,vehicle)
						MtxSetElementData(vehicle, "Beschlagnahmt", 0)
						dbExec(handler, "UPDATE vehicles SET Beschlagnahmt=? WHERE UID=? AND slot=?", 0, playerUID[getPlayerName(player)], carslot)
						outputChatBox( "Du hast dein Fahrzeug in "..carslot.." erfolgreich freikgekauft.", player, 0, 125, 0)
						outputChatBox ( "Du hast dein Auto freigekauft", player, 200, 200, 0 )
					    outputChatBox ( "Du solltest es umparken!", player, 200, 200, 0 )
					else
						outputChatBox("Du hast nicht genug Geld!", player, 125, 0, 0)
					end
				else
					outputChatBox("Dieses Fahrzeug befindet sich nicht in unserer Garage.", player, 125, 0, 0)
				end
			end
		else
			outputChatBox("SYNTAX: /freikaufen <slot>", player, 90, 90, 90)
		end
	end
end)