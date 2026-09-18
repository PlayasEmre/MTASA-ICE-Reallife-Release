--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local sexShopExitMarker = createMarker ( -100.37322998047, -24.775011062622, 1000, "corona", 1, 125, 0, 0, 0 )
local sexShopExitMarkerOptic = createMarker ( -100.37322998047, -24.775011062622, 999.69348144531, "cylinder", 1, 125, 0, 0, 150 )
local sexShopEnterMarkerOptic = createMarker ( 2085.361328125, 2074.0275878906, 10.029691696167, "cylinder", 1, 125, 0, 0, 150 )
local sexShopEnterMarker = createMarker ( 2085.361328125, 2074.0275878906, 11, "corona", 1, 125, 0, 0, 0 )

setElementInterior ( sexShopExitMarker, 3 )
setElementInterior ( sexShopExitMarkerOptic, 3 )

function sexShopMarkerHit ( hit, dim )

	if dim then
	if getElementType ( hit ) == "player" and getPedOccupiedVehicle ( hit ) == false then
		local player = hit
		if hasPlayerPerso ( player ) then
			if source == sexShopExitMarker then
				fadeElementInterior ( player, 0, 2086.7170410156, 2074.0441894531, 10.703912734985, -90, 0 )
			else
				fadeElementInterior ( player, 3, -100.29917907715, -23.57626914978, 1000.36, 0, 0 )
			end
		else
			infobox ( player, "\n\nDu hast keinen\nAusweis!", 5000, 125, 0, 0 )
		end
	   end
	end
end
addEventHandler ( "onMarkerHit", sexShopEnterMarker, sexShopMarkerHit )
addEventHandler ( "onMarkerHit", sexShopExitMarker, sexShopMarkerHit )

function xxxShopBuy_func ( item )

	local price = sexShopItemPrices[item]
	if price then
		local money = MtxGetElementData ( client, "money" )
		if money >= price then
			giveWeapon ( client, item )
			MtxSetElementData ( client, "money", money - price )
			playSoundFrontEnd ( client, 40 )
		else
			infobox ( client, "\n\nDu hast nicht\ngenug Geld!", 5000, 125, 0, 0 )
		end
	end
end
addEvent ( "xxxShopBuy", true )
addEventHandler ( "xxxShopBuy", getRootElement(), xxxShopBuy_func )