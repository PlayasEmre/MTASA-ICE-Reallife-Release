--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

--[[function invitePlayerToRace ( text, target, betTyp, betAmount, targetID )

	if #text > 1 then
		local player = client
		local x1, y1, z1 = getElementPosition ( player )
		local x2, y2, z2 = getElementPosition ( target )
		local dist = getDistanceBetweenPoints3D ( x1, y1, z1, x2, y2, z2 )
		if dist <= 5 then
			betAmount = math.floor ( math.abs ( tonumber ( betAmount ) ) )
			if betAmount == 0 then
				betTyp = 0
			end
			outputChatBox ( getPlayerName ( client ).." hat dich zu einem Wettrennen herausgefordert, Ziel: "..text..".", target, 200, 200, 0 )
			if ( betTyp == 1 ) then
				outputChatBox ( "Preisgeld: "..betAmount.." $", target, 200, 200, 0 )
			elseif ( betTyp == 2 ) then
				outputChatBox ( "Wetteinsatz: Die Zulassungspapiere für dein Fahrzeug.", target, 200, 200, 0 )
			end
			outputChatBox ( "Tippe /accept race, um die Herausforderung anzunehmen.", target, 200, 200, 0 )
			outputChatBox ( "Du hast "..getPlayerName ( target ).." zu einem Rennen herausgefordert.", client, 0, 200, 0 )
			
			MtxSetElementData ( target, "challengerQ", client )
			MtxSetElementData ( target, "betTypQ", betTyp )
			MtxSetElementData ( target, "betAmountQ", betAmount )
			MtxSetElementData ( target, "targetIDQ", targetID )
			
			MtxSetElementData ( client, "challengerQ", target )
			MtxSetElementData ( client, "betTypQ", betTyp )
			MtxSetElementData ( client, "betAmountQ", betAmount )
			MtxSetElementData ( client, "targetIDQ", targetID )
		else
			infobox ( player, "Du hast bist\nzu weit entfernt!", 5000, 150, 0, 0 )
		end
	end
end
addEvent ( "invitePlayerToRace", true )
addEventHandler ( "invitePlayerToRace", getRootElement(), invitePlayerToRace )

function acceptRace ( player )

	local challenger = MtxGetElementData ( player, "challengerQ" )
	local bet = MtxGetElementData ( player, "betAmountQ" )
	local betTyp = MtxGetElementData ( player, "betTypQ" )
	local targetID = MtxGetElementData ( player, "targetIDQ" )
	if isElement ( challenger ) and isElement ( player ) then
		MtxSetElementData ( player, "betAmount", bet )
		MtxSetElementData ( challenger, "betAmount", bet )
		MtxSetElementData ( player, "betTyp", betTyp )
		MtxSetElementData ( challenger, "betTyp", betTyp )
		MtxSetElementData ( player, "challenger", challenger )
		MtxSetElementData ( challenger, "challenger", player )
		MtxSetElementData ( player, "targetID", targetID )
		MtxSetElementData ( challenger, "targetID", targetID )
	end
	if isElement ( challenger ) and MtxGetElementData ( challenger, "challenger" ) == player and MtxGetElementData ( player, "betAmount" ) == MtxGetElementData ( challenger, "betAmount" ) and MtxGetElementData ( player, "betTyp" ) == MtxGetElementData ( challenger, "betTyp" ) then
		local x1, y1, z1 = getElementPosition ( player )
		local x2, y2, z2 = getElementPosition ( challenger )
		
		local dist = getDistanceBetweenPoints3D ( x1, y1, z1, x2, y2, z2 )
		if dist <= 5 then
			if getPedOccupiedVehicleSeat ( player ) == 0 then
				if getPedOccupiedVehicleSeat ( challenger ) == 0 then
					if MtxGetElementData ( player, "betTyp" ) == 0 or ( MtxGetElementData ( player, "betTyp" ) == 0 and MtxGetElementData ( player, "money" ) >= bet and MtxGetElementData ( challenger, "money" ) >= bet ) then
						MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - bet )
						MtxSetElementData ( challenger, "money", MtxGetElementData ( challenger, "money" ) - bet )
						
						local veh1 = getPedOccupiedVehicle ( challenger )
						local veh2 = getPedOccupiedVehicle ( player )
						
						setElementFrozen ( veh1, true )
						setElementFrozen ( veh2, true )
						setVehicleDamageProof ( veh1, true )
						setVehicleDamageProof ( veh2, true )
						toggleControl ( player, "enter_exit", false )
						toggleControl ( challenger, "enter_exit", false )
						
						addEventHandler ( "onPlayerWasted", player, racePlayerWasted )
						addEventHandler ( "onPlayerWasted", challenger, racePlayerWasted )
						addEventHandler ( "onPlayerQuit", player, racePlayerQuit )
						addEventHandler ( "onPlayerQuit", challenger, racePlayerQuit )
						addEventHandler ( "onPlayerVehicleExit", player, racePlayerVehExit )
						addEventHandler ( "onPlayerVehicleExit", challenger, racePlayerVehExit )
						
						MtxSetElementData ( player, "isInRace", true )
						MtxSetElementData ( challenger, "isInRace", true )
						
						triggerClientEvent ( player, "showRaceCountdown", player )
						triggerClientEvent ( challenger, "showRaceCountdown", challenger )
						setTimer (
							function ( veh1, veh2, player, challenger )
								setElementFrozen ( veh1, false )
								setElementFrozen ( veh2, false )
								
								setVehicleDamageProof ( veh1, false )
								setVehicleDamageProof ( veh2, false )
								
								if isElement ( player ) then
									toggleControl ( player, "enter_exit", true )
								end
								if isElement ( challenger ) then
									toggleControl ( challenger, "enter_exit", true )
								end
							end,
						3000 + 3000, 1, veh1, veh2, player, challenger )
						
						local i = MtxGetElementData ( player, "targetID" )
						
						local x, y, z = possibleRaceTargets["x"][i], possibleRaceTargets["y"][i], possibleRaceTargets["z"][i]
						local marker = createMarker ( x, y, z, "checkpoint", 10, 200, 0, 0, 125, nil )
						local blip = createBlip ( x, y, z, 53, 2, 0, 0, 0, 255, 0, 99999, nil )
						
						addEventHandler ( "onPlayerMarkerHit", player, raceTargetMarkerHit )
						addEventHandler ( "onPlayerMarkerHit", challenger, raceTargetMarkerHit )
						
						MtxSetElementData ( player, "raceMarker", marker )
						MtxSetElementData ( challenger, "raceMarker", marker )
						MtxSetElementData ( player, "raceBlip", blip )
						MtxSetElementData ( challenger, "raceBlip", blip )
						
						setElementVisibleTo ( marker, player, true )
						setElementVisibleTo ( blip, player, true )
						setElementVisibleTo ( marker, challenger, true )
						setElementVisibleTo ( blip, challenger, true )
						return true
					else
						infobox ( player, "Du oder dein\nPartner haben nicht\ngenug Geld dabei!", 5000, 150, 0, 0 )
					end
				else
					infobox ( player, "Das Ziel ist\nnicht in einem\nFahrzeug!", 5000, 150, 0, 0 )
				end
			else
				infobox ( player, "Du bist nicht\nin einem Fahrzeug!", 5000, 150, 0, 0 )
			end
		else
			infobox ( player, "Du hast bist\nzu weit entfernt!", 5000, 150, 0, 0 )
		end
	else
		infobox ( player, "Du hast keine\nHerausforderung!", 5000, 150, 0, 0 )
	end
	MtxSetElementData ( player, "challenger", false )
end

function raceTargetMarkerHit ( marker )

	if MtxGetElementData ( source, "isInRace" ) and marker == MtxGetElementData ( source, "raceMarker" ) then
		local challenger = source
		local player = MtxGetElementData ( challenger, "challenger" )
		removeRaceEvent ( player, challenger )
		
		outputChatBox ( "Du hast das Rennen verloren!", player, 125, 0, 0 )
		outputChatBox ( "Du hast das Rennen gewonnen!", challenger, 0, 200, 0 )
		
		local betAmount = MtxGetElementData ( challenger, "betAmount" ) * 2
		triggerClientEvent ( challenger, "raceWon", challenger, betAmount )
		if betAmount > 0 then
			MtxSetElementData ( challenger, "money", MtxGetElementData ( challenger, "money" ) + betAmount )
			outputChatBox ( "Du erhälst "..betAmount.." $ Preisgeld!", challenger, 0, 125, 0 )
		end
		
		MtxSetElementData ( player, "isInRace", false )
		MtxSetElementData ( challenger, "isInRace", false )
	end
end

function racePlayerQuit ()

	if MtxGetElementData ( source, "isInRace" ) then
		local player = source
		local challenger = MtxGetElementData ( player, "challenger" )
		removeRaceEvent ( player, challenger )
		
		outputChatBox ( "Du hast das Rennen gewonnen!", challenger, 0, 200, 0 )
		
		local betAmount = MtxGetElementData ( challenger, "betAmount" ) * 2
		triggerClientEvent ( challenger, "raceWon", challenger, betAmount )
		if betAmount > 0 then
			MtxSetElementData ( challenger, "money", MtxGetElementData ( challenger, "money" ) + betAmount )
			outputChatBox ( "Du erhälst "..betAmount.." $ Preisgeld!", challenger, 0, 125, 0 )
		end
		
		MtxSetElementData ( player, "isInRace", false )
		MtxSetElementData ( challenger, "isInRace", false )
	end
end

function racePlayerWasted ()

	if MtxGetElementData ( source, "isInRace" ) then
		local player = source
		local challenger = MtxGetElementData ( player, "challenger" )
		removeRaceEvent ( player, challenger )
		
		outputChatBox ( "Du hast das Rennen verloren!", player, 125, 0, 0 )
		outputChatBox ( "Du hast das Rennen gewonnen!", challenger, 0, 200, 0 )
		
		local betAmount = MtxGetElementData ( challenger, "betAmount" ) * 2
		triggerClientEvent ( challenger, "raceWon", challenger, betAmount )
		if betAmount > 0 then
			MtxSetElementData ( challenger, "money", MtxGetElementData ( challenger, "money" ) + betAmount )
			outputChatBox ( "Du erhälst "..betAmount.." $ Preisgeld!", challenger, 0, 125, 0 )
		end
		
		MtxSetElementData ( player, "isInRace", false )
		MtxSetElementData ( challenger, "isInRace", false )
	end
end

function racePlayerVehExit ()

	if MtxGetElementData ( source, "isInRace" ) then
		local player = source
		local challenger = MtxGetElementData ( player, "challenger" )
		removeRaceEvent ( player, challenger )
		
		outputChatBox ( "Du hast das Rennen verloren!", player, 125, 0, 0 )
		outputChatBox ( "Du hast das Rennen gewonnen!", challenger, 0, 200, 0 )
		
		local betAmount = MtxGetElementData ( challenger, "betAmount" ) * 2
		triggerClientEvent ( challenger, "raceWon", challenger, betAmount )
		if betAmount > 0 then
			MtxSetElementData ( challenger, "money", MtxGetElementData ( challenger, "money" ) + betAmount )
			outputChatBox ( "Du erhälst "..betAmount.." $ Preisgeld!", challenger, 0, 125, 0 )
		end
		
		MtxSetElementData ( player, "isInRace", false )
		MtxSetElementData ( challenger, "isInRace", false )
	end
end

function removeRaceEvent ( player, challenger )

	removeEventHandler ( "onPlayerWasted", player, racePlayerWasted )
	removeEventHandler ( "onPlayerWasted", challenger, racePlayerWasted )
	removeEventHandler ( "onPlayerQuit", player, racePlayerQuit )
	removeEventHandler ( "onPlayerQuit", challenger, racePlayerQuit )
	removeEventHandler ( "onPlayerVehicleExit", player, racePlayerVehExit )
	removeEventHandler ( "onPlayerVehicleExit", challenger, racePlayerVehExit )
	removeEventHandler ( "onPlayerMarkerHit", player, raceTargetMarkerHit )
	removeEventHandler ( "onPlayerMarkerHit", challenger, raceTargetMarkerHit )
	
	destroyElement ( MtxGetElementData ( player, "raceMarker" ) )
	destroyElement ( MtxGetElementData ( player, "raceBlip" ) )
end--]]