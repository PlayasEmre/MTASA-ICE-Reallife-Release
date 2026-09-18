--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function carbuy ( player, carprice, vehid, spawnx, spawny, spawnz, rx, ry, rz, c1, c2, c3, c4, p, ec, Tuning )
	local carprice = carprice
	local vehid = tonumber ( vehid )
	local spawnx = tonumber ( spawnx )
	local spawny = tonumber ( spawny )
	local spawnz = tonumber ( spawnz )
	local Tuning = Tuning
	local pname = getPlayerName ( player )
	local hasCamper = false
	
	if not carprices[vehid] then
		if aiCarPrices[vehid] then
			table.insert ( carprices, vehid, aiCarPrices[vehid] )
		end
	end

	if camper[vehid] then
		local dsatz = dbQueryCoro ( "SELECT Typ from vehicles WHERE ??=?", "UID", playerUID[pname] )
		if dsatz and dsatz[1] then
			for i=1, #dsatz do
				if camper[tonumber(dsatz[i]["Typ"])] then
					outputChatBox ( "Du kannst nur einen Wohnwagen haben!", player, 125, 0, 0 )
					return
				end
			end
		end
	end
	
	local slot = 0
	local differenz = 0
	if carprices[vehid] or MtxGetElementData ( player, "everyCarBuyableForFree" ) then
		if MtxGetElementData ( player, "maxcars" ) > MtxGetElementData ( player, "curcars" ) then
			for i=1, MtxGetElementData ( player, "maxcars" ) do
				if MtxGetElementData ( player, "carslot"..i ) == 0 then
					slot = i
					break
				end
			end
			if slot > 0 then
				if not MtxGetElementData ( player, "everyCarBuyableForFree" ) then
					if carprices[tonumber(vehid)] then
						carprice = carprices[tonumber(vehid)]
					end
					if ec then
						differenz = MtxGetElementData ( player, "bankmoney" ) - carprice
					else
						differenz = MtxGetElementData ( player, "money" ) - carprice
					end
				end
				if MtxGetElementData ( player, "everyCarBuyableForFree" ) or differenz >= 0 then
					if hasPlayerLicense ( player, tonumber(vehid) ) then
						setElementDimension ( player, 0 )
						setElementInterior ( player, 0 )
						fadeCamera( player, true)
						setCameraTarget( player, player )
						local vehicle = createVehicle ( vehid, spawnx, spawny, spawnz, 0, 0, 0, pname )
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
						MtxSetElementData ( player, "curcars", MtxGetElementData ( player, "curcars" )+1 )
						MtxSetElementData ( player, "FahrzeugeGekauft", MtxGetElementData ( player, "FahrzeugeGekauft" ) + 1 )
						if not Tuning then
							Tuning = "|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|"
						end
						setVehicleRotation ( vehicle, rx, ry, rz )
						
						local Farbe1, Farbe2, Farbe3, Farbe4
						local Paintjob
							
						if not c1 or not c2 or not c3 or not c4 then
							Farbe1, Farbe2, Farbe3, Farbe4 = getVehicleColor ( vehicle )
						else
							Farbe1, Farbe2, Farbe3, Farbe4 = c1, c2, c3, c4
							setVehicleColor ( vehicle, c1, c2, c3, c4 )
						end
						if not p then
							Paintjob = getVehiclePaintjob ( vehicle )
						else
							Paintjob = p
							setVehiclePaintjob ( vehicle, p )
						end
						
						MtxSetElementData ( vehicle, "stuning", "0|0|0|0|0|0|" )
						local color = "|"..Farbe1.."|"..Farbe2.."|"..Farbe3.."|"..Farbe4.."|"
						MtxSetElementData ( vehicle, "color", color )
						MtxSetElementData ( vehicle, "lcolor", "|255|255|255|" )
						MtxSetElementData ( vehicle , "sportmotor", 0 )
						MtxSetElementData ( vehicle , "bremse", 0 )
						local antrieb = getVehicleHandling(vehicle)["driveType"]
						MtxSetElementData ( vehicle, "antrieb", antrieb )
						setPrivVehCorrectLightColor ( vehicle )
							
						specPimpVeh ( vehicle )
						SaveCarData ( player )
						outputChatBox ( "Glückwunsch, du hast das Fahrzeug gekauft! Tippe /vehhelp für mehr Informationen oder rufe das Hilfemenü auf!", player, 0, 255, 0 )
						checkCarWahnAchiev( player )
							
						if not MtxGetElementData ( player, "everyCarBuyableForFree" ) then
							if ec then
								MtxSetElementData ( player, "bankmoney", MtxGetElementData ( player, "bankmoney" ) - carprice )
								triggerClientEvent ( player, "createNewStatementEntry", player, "Fahrzeugkauf\n", carprice * -1000, getVehicleNameFromModel ( vehid ).."\n" )
							else
								MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - carprice )
							end
						end
						warpPedIntoVehicle ( player, vehicle )
						
						if not dbExec ( handler, "INSERT INTO vehicles (UID, Typ, Tuning, Spawnpos_X, Spawnpos_Y, Spawnpos_Z, Spawnrot_X, Spawnrot_Y, Spawnrot_Z, Farbe, Paintjob, Benzin, Slot, Sportmotor, Bremse, Antrieb) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", playerUID[pname], vehid, Tuning, spawnx, spawny, spawnz, rx, ry, rz, color, Paintjob, '100', slot, '0', '0', antrieb )  then
							outputDebugString ( "[carbuy] Error executing the query" )
							destroyElement ( vehicle )
						end
							
						activeCarGhostMode ( player, 10000 )
						triggerClientEvent ( player, "leaveCarhouse", player )
						
						setElementPosition ( vehicle, spawnx, spawny, spawnz )
						outputLog ( getPlayerName ( player ).." hat ein Auto gekauft ( "..getVehicleNameFromModel ( vehid ).." )", "vehicle" )
						return true
					else
						outputChatBox ( "Du hast nicht die erforderlichen Scheine!", player, 125, 0, 0 )
					end
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "Du hast nicht\ngenug Geld! Das\nFahrzeug kostet\n"..carprice.." "..Tables.waehrung.."!", 5000, 125, 0, 0 )
				end	
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "Du hast keinen\nfreien Fahrzeugslot!\nTippe /sellcar, um\neines deiner Fahr-\nzeuge zu ver-\nkaufen.", 5000, 125, 0, 0 )
			end
		else 
			triggerClientEvent ( player, "infobox_start", getRootElement(), "Du hast bereits zuviele\nFahrzeuge, zerstoere oder\nverkaufe eines deiner\nalten!", 5000, 255, 0, 0 )
		end
	else
		outputChatBox ( "Du hast nicht die erforderlichen Scheine / Boni!", player, 125, 0, 0 )
	end
	setCameraTarget( player, player )
	triggerClientEvent ( player, "leaveCarhouse", player )
	return false
end


function getFreeCarSlot ( player )

	if MtxGetElementData ( player, "maxcars" ) > MtxGetElementData ( player, "curcars" ) then
		local cars = 0
		for i = 1, MtxGetElementData ( player, "maxcars" ) do
			if MtxGetElementData ( player, "carslot"..i ) == 0 then
				return i
			end
		end
	else
		return false
	end
end