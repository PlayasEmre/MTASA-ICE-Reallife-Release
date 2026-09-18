--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

addEventHandler('onClientPlayerJoin', root,
	function()
		outputChatBox('* ' .. getPlayerName(source) .. ' hat '..Tables.servername..' Reallife '..Tables.ScriptVersion..' betreten :)', 0, 238, 0)
	end
)

addEventHandler('onClientPlayerQuit', root,
	function(reason)
		outputChatBox('* ' .. getPlayerName(source) .. ' hat '..Tables.servername..' Reallife '..Tables.ScriptVersion..' verlassen :( [' .. reason .. ']', 180, 0, 0)
	end
)