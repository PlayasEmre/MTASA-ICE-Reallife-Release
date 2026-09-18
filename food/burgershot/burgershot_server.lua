--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function BurgershotBuy_func ( item )

	local player = source
	local money = MtxGetElementData ( player, "money" )
	if player == client or not client then
		if item == 1 then
			if money >= burgerPrice then
				if MtxGetElementData ( player, "food1" ) == 0 or MtxGetElementData ( player, "food2" ) == 0 or MtxGetElementData ( player, "food3" ) == 0 then
					MtxSetElementData ( player, "money", money - burgerPrice )
					putFoodInSlot ( player, 3 )
				else
					outputChatBox ( "Du hast keinen freien Essensslot mehr! Wirf etwas weg!", player, 125, 0, 0 )
				end
			else
				outputChatBox ( "Du hast nicht genug Geld! Ein Burger kostet "..burgerPrice.." "..Tables.waehrung.."!", player, 125, 0, 0 )
			end
		elseif item == 2 then
			if money >= snackPrice then
				if MtxGetElementData ( player, "food1" ) == 0 or MtxGetElementData ( player, "food2" ) == 0 or MtxGetElementData ( player, "food3" ) == 0 then
					MtxSetElementData ( player, "money", money - snackPrice )
					putFoodInSlot ( player, 4 )
				else
					outputChatBox ( "Du hast keinen freien Essensslot mehr! Wirf etwas weg!", player, 125, 0, 0 )
				end
			else
				outputChatBox ( "Du hast nicht genug Geld! Ein Snack kostet "..snackPrice.." "..Tables.waehrung.."!", player, 125, 0, 0 )
			end
		end
	end
end
addEvent ( "BurgershotBuy", true )
addEventHandler ( "BurgershotBuy", getRootElement(), BurgershotBuy_func )