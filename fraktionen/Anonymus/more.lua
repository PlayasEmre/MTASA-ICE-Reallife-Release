--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function getinfogha ( player )
    if isAnonymus( player ) then
	    outputChatBox ( "Mit /hackbhf kannst du den ATM am Bahnhof hacken.", player, 125, 0, 0 )
		outputChatBox ( "Mit /hacknoob kannst du den ATM am Noobspawn hacken.", player, 125, 0, 0 )
		outputChatBox ( "Mit /hackstadt kannst du den ATM an der Stadthalle hacken.", player, 125, 0, 0 )
		outputChatBox ( "Mit /hackwangcars kannst du den ATM am wangcars über dem wangcars hacken.", player, 125, 0, 0 )
		outputChatBox ( "Mit /hackhandy kannst du das Handy eines anderen Spielers hacken und es an oder ausmachen", player, 125, 0, 0 )
		outputChatBox ( "Mit /hackwanteds kannst du die Wanteds eines Spielers löschen.", player, 125, 0, 0 )
		outputChatBox ( "Mit /hackcomputer (am Gefängnis-Computer) öffnest du alle Türen/Schleusen zum Gefängnis.", player, 125, 0, 0 )
		outputChatBox ( "Mit /hackfree Spielername (am Zellenblock-Eingang) befreist du einen inhaftierten Spieler.", player, 125, 0, 0 )
	else
	    outputChatBox ( "Du bist kein Mitglied der Anonymus.", player, 125, 0, 0 )
	end
end
addCommandHandler ( "hackinfo", getinfogha )