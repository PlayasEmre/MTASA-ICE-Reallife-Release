--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function news_func ( player, cmd, ... )
	local parametersTable = {...}
	local stringWithAllParameters = table.concat( parametersTable, " " )
	if isReporter ( player ) then
		if not MtxGetElementData ( player, "newsNotPostable" ) then
			if isNewsCar(getPedOccupiedVehicle(player)) then
				if #stringWithAllParameters >= 1 then
					outputChatBox ( "Reporter "..getPlayerName(player)..": "..stringWithAllParameters, getRootElement(), 255, 125, 20 )
					if getRealTime().hour >= 10 then
						MtxSetElementData ( player, "boni", tonumber ( MtxGetElementData ( player, "boni" ) ) + 10 )
					end
					MtxSetElementData ( player, "newsNotPostable", true )
					setTimer ( MtxSetElementData, 3000, 1, player, "newsNotPostable", false )
				else
					outputChatBox ( "Dein Text ist zu kurz.", player, 125, 0, 0 )
				end
			else
				outputChatBox ( "Du sitz in keinem News-Fahrzeug!", player, 125, 0, 0 )
			end
		else
			outputChatBox ( "Du kannst du nur alle 3 Sekunden News schreiben!", player, 125, 0, 0 )
		end
	end
end
addCommandHandler ( "news", news_func )

function live_func ( player, cmd, target )
	
	if isReporter ( player ) and not MtxGetElementData ( player, "isLive" ) then
		local target = findPlayerByName( target )
		if target then
			MtxSetElementData ( target, "isLive", true )
			MtxSetElementData ( player, "isLive", true )
			MtxSetElementData ( target, "isLiveWith", getPlayerName(player) )
			MtxSetElementData ( player, "isLiveWith", getPlayerName(target) )
			outputChatBox ( "Du bist nun in einem Interview mit "..getPlayerName(player)..", tippe /endlive zum beenden.", target, 200, 200, 0 )
			outputChatBox ( "Du bist nun in einem Interview mit "..getPlayerName(target)..", tippe /endlive zum beenden.", player, 200, 200, 0 )
		end
	end
end
addCommandHandler ( "live", live_func )

function endlive_func ( player )
	
	if MtxGetElementData ( player, "isLive" ) then
		MtxSetElementData ( player, "isLive", false )
		outputChatBox ( "Das Interview wurde beendet!", player, 0, 200, 0 )
		local target = MtxGetElementData ( player, "isLiveWith" )
		local target = getPlayerFromName ( target )
		if target then
			outputChatBox ( "Das Interview wurde beendet!", target, 0, 200, 0 )
			MtxSetElementData ( target, "isLive", false )
		end
	else
		outputChatBox ( "Du bist in keiner Live-Unterhaltung!", player, 125, 0, 0 )
	end
end
addCommandHandler ( "endlive", endlive_func )


local reporterBlips = {}
addCommandHandler ( "reporterstart", function ( player )
	if isReporter ( player ) then
		if not reporterBlips[player] then
			reporterBlips[player] = {}
		elseif isElement ( reporterBlips[player]["start"] ) then
			destroyElement ( reporterBlips[player]["start"] )
		end
		local x, y, z = getElementPosition ( player )
		reporterBlips[player]["start"] = createBlip ( x, y, z, 0, 3, 180, 130 ) 
		infobox ( player, "Start-Markierung gesetzt", 4000, 0, 200, 0 )
		outputChatBox ( "Mit /delreporterstart kannst du die Markierung löschen.", player, 0, 200, 0 )
	end
end )


addCommandHandler ( "reporterende", function ( player )
	if isReporter ( player ) then
		if not reporterBlips[player] then
			reporterBlips[player] = {}
		elseif isElement ( reporterBlips[player]["ende"] ) then
			destroyElement ( reporterBlips[player]["ende"] )
		end
		local x, y, z = getElementPosition ( player )
		reporterBlips[player]["ende"] = createBlip ( x, y, z, 19, 2 )
		infobox ( player, "Ende-Markierung gesetzt", 4000, 0, 200, 0 )
		outputChatBox ( "Mit /delreporterende kannst du die Markierung löschen.", player, 0, 200, 0 )
	end
end )


addCommandHandler ( "delreporterstart", function ( player )
	if reporterBlips[player] and reporterBlips[player]["start"] then
		if isElement ( reporterBlips[player]["start"] ) then
			destroyElement ( reporterBlips[player]["start"] )
		end
		reporterBlips[player]["start"] = nil
	end
end )


addCommandHandler ( "delreporterende", function ( player )
	if reporterBlips[player] and reporterBlips[player]["ende"] then
		if isElement ( reporterBlips[player]["ende"] ) then
			destroyElement ( reporterBlips[player]["ende"] )
			reporterBlips[player]["ende"] = nil
		end
	end
end )


addCommandHandler ( "delallreporterblips", function ( player )
	if isReporter ( player ) and ( tonumber ( MtxGetElementData ( player, "rang" ) ) or 0 ) >= 4 or ( tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0 ) >= 1 then
		local deleted = false
		for _, array in pairs ( reporterBlips ) do
			for _, blip in pairs ( array ) do
				destroyElement ( blip )
				deleted = true
			end
		end
		if deleted then
			outputChatBox ( "Alle Reporter-Markierungen wurden von "..getPlayerName(player).." gelöscht.", 255, 0, 0 )
		end
	else
		infobox ( player, "Du bist\nnicht befugt", 4000, 155, 0, 0 )
	end
end )


		
	
	