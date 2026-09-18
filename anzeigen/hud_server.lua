function hud_trigger_1(player)
	setElementData( player, "hud", 1 )
	dbExec ( handler, "UPDATE ?? SET ?? = ? WHERE ??=?", "userdata", "hud", "1", "UID", playerUID[player] )
	triggerClientEvent( player, "showhudclient", player, 1)
	datasave_remote(player)
end
addEvent( "hud_trigger_1", true )
addEventHandler( "hud_trigger_1", root, hud_trigger_1 )


function hud_trigger_2(player) 
	setElementData( player, "hud", 2 )
	dbExec ( handler, "UPDATE ?? SET ?? = ? WHERE ??=?", "userdata", "hud", "2", "UID", playerUID[player] )
	triggerClientEvent( player, "showhudclient", player, 2)
	datasave_remote(player)
end
addEvent( "hud_trigger_2", true )
addEventHandler( "hud_trigger_2", root, hud_trigger_2 )

--[[function hud_trigger_3()
	MtxSetElementData( player, "hud", 3 )
	dbExec ( handler, "UPDATE ?? SET ?? = ? WHERE ??=?", "userdata", "hud", "3", "UID", playerUID[player] )
	triggerClientEvent( player, "showhudclient", player, 3)
end
addEvent( "hud_trigger_3", true )
addEventHandler( "hud_trigger_3", root, hud_trigger_3 )--]]