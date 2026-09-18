--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function deliverPizza_func ()

	if source == client and MtxGetElementData ( client, "money" ) >= 100 then
		local player = source
		if getElementInterior ( client ) == 0 and getElementDimension ( client ) == 0 then
			if not gotLastHit[client] or gotLastHit[client] + healafterdmgtime <= getTickCount() then
				local x, y, z = getElementPosition ( player )
				outputChatBox ( "Deine Bestellung wird geliefert!", player, 0, 125, 0 )
				playSoundFrontEnd ( player, 40 )
				MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - 100 )
				triggerClientEvent ( player, "createNewStatementEntry", player, "Bestellung auf\nPizza.com", 50 * -1, "Mit extra\nKäse" )
				factionDepotData["money"][2] = factionDepotData["money"][2] + 50
				setTimer ( createPizzaPickup, 3500, 1, x, y, z )
			else
				outputChatBox ( "Es muss dafür "..( healafterdmgtime/1000 ) .." Sekunden nach dem letzten Schuss vergangen sein!", client, 200, 0, 0 )
			end
		else
			outputChatBox ( "Das kannst du nur draußen bestellen!", player, 125, 0, 0 )
		end
	end
end
addEvent ( "deliverPizza", true )
addEventHandler ( "deliverPizza", getRootElement(), deliverPizza_func )

function createPizzaPickup ( x, y, z )

	local pickup = createPickup ( x+2, y+2, z, 3, 1582 )
	addEventHandler ( "onPickupHit", pickup, 
		function ( player )
			playSoundFrontEnd ( player, 40 )
			setElementHealth ( player, 60 )
			setElementHunger ( player, 40 )
			if isElement ( source ) then
				destroyElement ( source )
			end
			outputLog ( getPlayerName(player).." hat sich mit Pizza geheilt", "Heilung" )
		end
	)
end