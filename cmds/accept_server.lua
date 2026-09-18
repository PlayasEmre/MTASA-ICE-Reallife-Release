--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function accept_func ( player, cmd, typ )

	if typ == "race" then
		acceptRace ( player )
	end
end
addCommandHandler ( "accept", accept_func )