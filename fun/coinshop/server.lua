--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

--[[addEvent ( "coinshop",true)
addEventHandler ( "coinshop", root, function ( )
	local coins = tonumber(MtxGetElementData ( client, "coins" ))
	if coins >= 250 then
		MtxSetElementData ( client, "coins", coins - 250 )
		outputChatBox ( "Du hast dir ein Tactic Kills/Tode reset gekauft", client, 0, 200, 0 )
		MtxSetElementData(client,"TacticKills",0)
		MtxSetElementData(client,"TacticTode",0)
		triggerClientEvent ( client, "updateCoinsInCoinshop", client )
	else
	    triggerClientEvent(client, "infobox_start", getRootElement(), "Nicht genug Coins!", 5000, 0, 191, 255)
	end
end )

addEvent ( "coinshop2",true)
addEventHandler ( "coinshop2", root, function ( )
	local coins = tonumber(MtxGetElementData ( client, "coins" ))
	if coins >= 100 then
		MtxSetElementData ( client, "coins", coins - 100 )
		outputChatBox ( "text", client, 0, 200, 0 )
		triggerClientEvent ( client, "updateCoinsInCoinshop", client )
	else
	    triggerClientEvent(client, "infobox_start", getRootElement(), "Nicht genug Coins!", 5000, 0, 191, 255)
	end
end )

addEvent ( "coinshop3",true)
addEventHandler ( "coinshop3", root, function ( )
	local coins = tonumber(MtxGetElementData ( client, "coins" ))
	if coins >= 100 then
		MtxSetElementData ( client, "coins", coins - 100 )
		outputChatBox ( "text", client, 0, 200, 0 )
		triggerClientEvent ( client, "updateCoinsInCoinshop", client )
	else
	    triggerClientEvent(client, "infobox_start", getRootElement(), "Nicht genug Coins!", 5000, 0, 191, 255)
	end
end )

addEvent ( "coinshop4",true)
addEventHandler ( "coinshop4", root, function ( )
	local coins = tonumber(MtxGetElementData ( client, "coins" ))
	if coins >= 100 then
		MtxSetElementData ( client, "coins", coins - 100 )
		outputChatBox ( "text", client, 0, 200, 0 )
		triggerClientEvent ( client, "updateCoinsInCoinshop", client )
	else
	    triggerClientEvent(client, "infobox_start", getRootElement(), "Nicht genug Coins!", 5000, 0, 191, 255)
	end
end )--]]