--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function openFullMap_func ( player, cmd )
	if isAdminLevel ( player, 3 ) then
		triggerClientEvent ( player, "fullMapOpen", player )
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist\nnicht befugt!", 4000, 155, 0, 0 )
	end
end
addCommandHandler ( "map", openFullMap_func )

addEvent ( "fullMapTeleport", true )
addEventHandler ( "fullMapTeleport", getRootElement(), function ( x, y, z )
	local player = client
	if isAdminLevel ( player, 3 ) then
		x, y, z = tonumber ( x ), tonumber ( y ), tonumber ( z )
		if x and y then
			z = z or 20

			if isPedInVehicle ( player ) then
				setElementPosition ( getPedOccupiedVehicle ( player ), x, y, z )
			else
				setElementPosition ( player, x, y, z )
			end
			setElementInterior ( player, 0 )
			setElementDimension ( player, 0 )

			outputAdminLog ( getPlayerName(player).." hat sich per Kartenklick nach "..math.floor(x)..", "..math.floor(y).." teleportiert." )
		end
	end
end )
