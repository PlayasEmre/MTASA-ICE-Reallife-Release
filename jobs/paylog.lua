--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

payLogPath = "logs/paylog.log"

function outputPayLog ( text )

	local payLog = fileOpen ( payLogPath, false )
	local filesize = fileGetSize ( payLog )
	fileSetPos ( payLog, filesize )
	fileWrite ( payLog, logTimestamp()..": "..text.."\n" )
	fileClose ( payLog )
end