--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function camfix_func ()

	setCameraClip ( true, true )
end
addEvent ( "camfix", true )
addEventHandler ( "camfix", getRootElement(), camfix_func )