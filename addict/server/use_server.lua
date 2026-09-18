--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

cigarChokeTime = 3000
local smokingPlayers = {}

function removeAddicts_func ()

	local player = client
	local total = getTotalAddictLevel ( player )
	local totalCost = getTotalAddictLevel ( player ) * addictRemoveCost
	local money = MtxGetElementData ( player, "money" )
	if money >= totalCost then
		takePlayerSaveMoney ( player, totalCost )
		
		MtxSetElementData ( player, "cigarettAddictPoints", 0 )
		MtxSetElementData ( player, "alcoholAddictPoints", 0 )
		MtxSetElementData ( player, "drugAddictPoints", 0 )
		
		MtxSetElementData ( player, "cigarettFlushPoints", 0 )
		MtxSetElementData ( player, "alcoholFlushPoints", 0 )
		MtxSetElementData ( player, "drugFlushPoints", 0 )
		
		triggerClientEvent ( player, "showAddictInfo", player, true )
	else
		triggerClientEvent(player, "infobox_start", getRootElement(), "\n\n\nDu hast nicht\ngenug Geld!", 7500, 135, 206, 250)
	end
end
addEvent ( "removeAddicts", true )
addEventHandler ( "removeAddicts", getRootElement(), removeAddicts_func )

function takeDrugs ( player )

	local curPoints = MtxGetElementData ( player, "drugAddictPoints" )
	local curFlush = MtxGetElementData ( player, "drugFlushPoints" )
	meCMD_func ( player, "cmd", "raucht Grass." )
	
	MtxSetElementData ( player, "drugAddictPoints", curPoints + 1 )
	MtxSetElementData ( player, "drugFlushPoints", curFlush + 5 )
	
	setElementHealth ( player, 100 )
	if getElementHunger(player) then
		setElementHunger ( player, getElementHunger(player) + 25 )
	end
	outputLog ( getPlayerName(player).." hat Drogen genommen", "Heilung" )
	
	toggleAllControls ( player, false, true, true )
	
	setPedAnimation ( player, "crack", "crckdeth2", 1, true, true, false )
	setTimer ( setPedAnimation, 5000, 1, player )
	triggerClientEvent ( player, "showAddictInfo", player, true )
	setTimer ( toggleAllControls, 5000, 1, player, true, true, true )
	triggerClientEvent ( player, "startDrugEffect", player, 30000 * 5, getDrugStrength ( player ), false, true )
end

function checkForSymptoms ( player )

	local smokeFlush = MtxGetElementData ( player, "cigarettFlushPoints" )
	local drinkFlush = MtxGetElementData ( player, "alcoholFlushPoints" )
	local drugFlush = MtxGetElementData ( player, "drugFlushPoints" )
	
	local smokeAddict = MtxGetElementData ( player, "cigarettAddictPoints" )
	local drinkAddict = MtxGetElementData ( player, "alcoholAddictPoints" )
	local drugAddict = MtxGetElementData ( player, "drugAddictPoints" )
	
	if math.floor ( smokeAddict/addictLevelDivisors[1] ) < smokeFlush then
		triggerClientEvent(player, "infobox_start", getRootElement(), "Du hast zu lange\nnicht geraucht und\nhast Entzugs-\nerscheinungen.\nBesorg dir ein\npaar Zigaretten!", 7500, 135, 206, 250)
		detoxSympton ( player )
	elseif math.floor ( drinkAddict/addictLevelDivisors[2] ) < drinkFlush then
		triggerClientEvent(player, "infobox_start", getRootElement(), "Du hast zu lange\nnicht getrunken und\nhast Entzugs-\nerscheinungen.\nBesorg dir einen\nDrink!", 7500, 135, 206, 250)
		detoxSympton ( player )
	elseif math.floor ( drugAddict/addictLevelDivisors[3] ) < drugFlush then
		triggerClientEvent(player, "infobox_start", getRootElement(), "Du hast zu lange\nnichts genommen und\nhast Entzugs-\nerscheinungen.\nBesorg dir etwas\nStoff!", 7500, 135, 206, 250)
		detoxSympton ( player )
	end
end

function detoxSympton ( player )

	if getPedOccupiedVehicle ( player ) then
		toggleControl ( player, "accelerate", false )
		setControlState ( player, "accelerate", true )
		setTimer ( toggleControl, 5000, 1, player, "accelerate", true )
		setTimer ( setControlState, 5000, 1, player, "accelerate", false )
	else
		crackAnimation_func ( player )
	end
end

function lowerFlush ( player )

	local smokeFlush = MtxGetElementData ( player, "cigarettFlushPoints" )
	local drinkFlush = MtxGetElementData ( player, "alcoholFlushPoints" )
	local drugFlush = MtxGetElementData ( player, "drugFlushPoints" )
	
	local change = false
	
	if smokeFlush and smokeFlush > 0 then
		change = true
		MtxSetElementData ( player, "cigarettFlushPoints", smokeFlush - 1 )
	end
	if drinkFlush and drinkFlush > 0 then
		change = true
		MtxSetElementData ( player, "alcoholFlushPoints", drinkFlush - 1 )
	end
	if drugFlush and drugFlush > 0 then
		change = true
		MtxSetElementData ( player, "drugFlushPoints", drugFlush - 1 )
	end
	
	if change then
		triggerClientEvent ( player, "showAddictInfo", player, true )
	end
end

function lowerAddict ( player )

	local smokeAddict = MtxGetElementData ( player, "cigarettAddictPoints" )
	local drinkAddict = MtxGetElementData ( player, "alcoholAddictPoints" )
	local drugAddict = MtxGetElementData ( player, "drugAddictPoints" )
	
	local change = false
	
	if smokeAddict > 0 then
		MtxSetElementData ( player, "cigarettAddictPoints", smokeAddict - 1 )
		if math.floor ( smokeAddict / addictLevelDivisors[1] ) > math.floor ( MtxGetElementData ( player, "cigarettAddictPoints" ) / addictLevelDivisors[1] ) then
			change = true
		end
	end
	if drinkAddict > 0 then
		MtxSetElementData ( player, "alcoholAddictPoints", drinkAddict - 1 )
		if math.floor ( drinkAddict / addictLevelDivisors[2] ) > math.floor ( MtxGetElementData ( player, "alcoholAddictPoints" ) / addictLevelDivisors[2] ) then
			change = true
		end
	end
	if drugAddict > 0 then
		MtxSetElementData ( player, "drugAddictPoints", drugAddict - 1 )
		if math.floor ( drugAddict / addictLevelDivisors[3] ) > math.floor ( MtxGetElementData ( player, "drugAddictPoints" ) / addictLevelDivisors[3] ) then
			change = true
		end
	end
	
	if change then
		triggerClientEvent ( player, "showAddictInfo", player, true )
	end
end

function smokeCigarett ( player )

	if not smokingPlayers[player] then
		smokingPlayers[player ]= true
		
		local curPoints = MtxGetElementData ( player, "cigarettAddictPoints" )
		local curFlush = MtxGetElementData ( player, "cigarettFlushPoints" )
		meCMD_func ( player, "cmd", "raucht eine Zigarette." )
		
		MtxSetElementData ( player, "cigarettAddictPoints", curPoints + 1 )
		MtxSetElementData ( player, "cigarettFlushPoints", curFlush + 1 )
		
		if not isPedInVehicle ( player ) then
			setPedAnimation ( player, "smoking", "M_smkstnd_loop", 1, true, true, false )
			setTimer ( setPedAnimation, 2000, 1, player )
		end
		
		addPlayerHealth ( player, 10 )
		-- getElementHunger liefert nil, solange der Hungerwert fuer diesen
		-- Spieler noch nicht gesetzt wurde (der Client meldet ihn erst kurz
		-- nach dem Login). Ohne Pruefung bricht "nil + 20" hier ab und alles
		-- danach - Flush-Punkte, showAddictInfo, Husten - laeuft nicht mehr.
		local hunger = getElementHunger ( player )
		if hunger then
			setElementHunger ( player, hunger + 20 )
		end
		outputLog ( getPlayerName(player).." hat Zigarette geraucht", "Heilung" )
		
		local drinkFlush = MtxGetElementData ( player, "alcoholFlushPoints" )
		local drugFlush = MtxGetElementData ( player, "drugFlushPoints" )
		
		if drinkFlush > 0 then
			MtxSetElementData ( player, "alcoholFlushPoints", drinkFlush - 1 )
		end
		if drugFlush > 0 then
			MtxSetElementData ( player, "drugFlushPoints", drugFlush - 1 )
		end
		
		triggerClientEvent ( player, "showAddictInfo", player, true )
		
		
		if MtxGetElementData ( player, "cigarettFlushPoints" ) >= 2 * MtxGetElementData ( player, "cigarettAddictPoints" )  / addictLevelDivisors[1] + 1 then
			setTimer ( setPedChoking, 2750, 1, player, true )
			setTimer ( setPedChoking, 2750 + cigarChokeTime, 1, player, false )
			
			totalSmokeTime = 2750 + cigarChokeTime
			
			triggerClientEvent(player, "infobox_start", getRootElement(), "Offenbar hast du\nzu viele Zigaretten\nin kurzer Zeit\ngeraucht - gewöhne\ndeine Lungen an\nZigaretten!", 7500, 135, 206, 250)
		else
			totalSmokeTime = 2000
		end
		
		setTimer ( 
			function ( player )
				smokingPlayers[player] = false
			end,
		totalSmokeTime, 1, player )
	end
end

function drinkAlcohol ( player, sort )

	local points = alcoholSorts[sort]
	local curPoints = MtxGetElementData ( player, "alcoholAddictPoints" )
	local curFlush = MtxGetElementData ( player, "alcoholFlushPoints" )
	meCMD_func ( player, "cmd", "trinkt ein"..alcoholGramma[sort].."." )
	
	MtxSetElementData ( player, "alcoholAddictPoints", curPoints + points )
	MtxSetElementData ( player, "alcoholFlushPoints", curFlush + points * 3 )
	
	addPlayerHealth ( player, 10 * points )
	local hunger = getElementHunger ( player )
	if hunger then
		setElementHunger ( player, hunger + 20 * points )
	end
	outputLog ( getPlayerName(player).." hat Alkohol getrunken", "Heilung" )
	
	if hasDrunkToMuch ( player ) then
		setTimer ( killPed, 5000, 1, player )
		setPedAnimation ( player, "food", "EAT_Vomit_P", 5000, true, true, false )

		triggerClientEvent(player, "infobox_start", getRootElement(), "\n\nDu hast zu viel\ngetrunken und dir\neine Alkoholvergiftung\nzugezogen.", 7500, 135, 206, 250)
	else
		setTimer ( setPedAnimation, 5000, 1, player )
		setPedAnimation ( player, "VENDING", "VEND_Drink2_P", 5000, true, true, false )

		triggerClientEvent ( player, "showAddictInfo", player, true )
		triggerClientEvent ( player, "startDrugEffect", player, 30000 * points, getAlcoholStrength ( player ), true, false )
	end
end

function getAlcoholStrength ( player )

	local curFlush = MtxGetElementData ( player, "alcoholAddictPoints" )
	curFlush = curFlush / 5 + 1
	local curAddict = MtxGetElementData ( player, "alcoholFlushPoints" )
	curAddict = curAddict / addictLevelDivisors[2] + 1
	
	local strength = ( curFlush * curAddict ) / 500 * 1.1
	if strength > 1 then
		strength = 1
	elseif strength < 0.1 then
		strength = 0.1
	end
	
	return strength
end

function getDrugStrength ( player )

	local curFlush = MtxGetElementData ( player, "alcoholAddictPoints" )
	curFlush = curFlush / 5 + 1
	local curAddict = MtxGetElementData ( player, "alcoholFlushPoints" )
	curAddict = curAddict / addictLevelDivisors[3] + 1
	
	local strength = ( curFlush * curAddict ) / 10 ^ ( curAddict ) + 0.1
	if strength > 1 then
		strength = 1
	elseif strength < 0.1 then
		strength = 0.1
	end
	
	return strength
end

function hasDrunkToMuch ( player )

	local curAddict = MtxGetElementData ( player, "alcoholFlushPoints" ) / addictLevelDivisors[2] + 1
	local curFlush = MtxGetElementData ( player, "alcoholAddictPoints" )
	if math.floor ( curFlush / 10 - curAddict ) >= 1 then
		return true
	end
	return false
end