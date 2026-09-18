--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

Domanes = {}

function searsForURL ( url )

	local url = string.lower ( url )
	if Domanes[url] then
		triggerEvent ( Domanes[url], getRootElement() )
	else
		triggerEvent ( "VierNullVier", getRootElement() )
	end
end