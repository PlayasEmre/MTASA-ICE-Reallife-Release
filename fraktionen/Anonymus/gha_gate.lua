--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local ghagate = createObject( 980,-2162.6999511719,1019.799987793,81.599998474121,0,0,90)

function mvgha ( player )
	if isAnonymus( player ) or isOnDuty( player ) or isMedic(player) then
		if getDistanceBetweenPoints3D ( -2162.6999511719, 1019.799987793, 81.599998474121, getElementPosition ( player ) ) < 10 then
			moveObject ( ghagate, 2000, -2162.6999511719,  1019.799987793, 71.599998474121 ) 
			setTimer ( mvgha, 10000, 1 )
			outputChatBox("Das Tor schliest sich in 10 Sekunden Wieder", player )
		end
	end
end
addCommandHandler("mv" , mvgha )


function mvgha ()
	moveObject ( ghagate, 2000, -2162.6999511719,  1019.799987793, 81.599998474121 ) 
end 
