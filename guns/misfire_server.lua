--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function misfire ()

	local x, y, z = getElementPosition ( client )
	createExplosion ( x, y, z, 2, client )
	takeWeapon ( client, getPedWeapon ( client ), 1 )
end
addEvent ( "misfire", true )
addEventHandler ( "misfire", getRootElement(), misfire )