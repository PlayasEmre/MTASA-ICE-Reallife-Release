--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function activeCarGhostMode ( player, time )

	if isElement ( player ) then
		triggerClientEvent ( getRootElement(), "activeCarGhostMode", getRootElement(), player, time )
	end
end

addEventHandler ( "onPlayerVehicleEnter", getRootElement(),
	function ( veh, seat )
		if seat > 0 and rc_vehs[getElementModel ( veh )] then
			removePedFromVehicle ( source )
		end
	end
)