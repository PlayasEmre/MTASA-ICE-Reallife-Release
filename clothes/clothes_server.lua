--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

zipEntrance = createMarker ( -1883.3000488281,865.40002441406,34.200000762939, "cylinder", 1.1, getColorFromString("#FF000099") )
zipExit = createMarker ( 161.54940795898, -95.684967041016, 1000.807128906, "cylinder", 1.2, getColorFromString("#FF000099") )
zipBuy = createMarker ( 181.23762512207, -91.531929016113, 1000.82, "checkpoint", 1.2, getColorFromString("#FF000099") )
setElementInterior ( zipExit, 18 )
setElementInterior ( zipBuy, 18 )

zipBlip = createBlip ( -1882.6131591797,865.89544677734,35.171875, 45, 1, 0, 0, 0, 0, 0, 200, getRootElement() )
zipBlip2 = createBlip ( -2493.3742675781,-37.273193359375,25.765625, 45, 1, 0, 0, 0, 0, 0, 200, getRootElement() )

function clothesBuyServer_func ( player, skinid, skinpreis )

	if player == client then
		local skinpreis = tonumber ( skinpreis )
		local skinid = tonumber ( skinid )
		local money = tonumber( MtxGetElementData ( player, "money" ) )
		-- Gueltigen CJ-Skin-Bereich pruefen: eine ungueltige Skin-ID bei
		-- setElementModel/spawnPlayer ist eine der klassischsten GTA:SA-Absturz-
		-- ursachen (nicht nur fuer den Spieler selbst, sondern fuer jeden, der ihn
		-- sieht) - und wuerde bei jedem zukuenftigen Login erneut passieren, da
		-- der Wert in der DB gespeichert und beim Spawn blind uebernommen wird.
		if not skinid or skinid < 0 or skinid > 311 then
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\nUngueltiger Skin!", 5000, 125, 0, 0 )
			return
		end
		if money >= skinpreis then
			MtxSetElementData ( player, "skinid", skinid )
			MtxSetElementData ( player, "money", money - skinpreis )
			playSoundFrontEnd ( player, 40 )
			triggerClientEvent ( player, "sucessfullBuyed", getRootElement() )
			setElementModel ( player, skinid )
			setElementDimension ( player, 0 )
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "Du hast zu\nwenig Geld!\nDer Skin kostet\n"..skinpreis.." "..Tables.waehrung.."!", 5000, 125, 0, 0 )
		end
		setPlayerNametagShowing ( player, true )
	end
end
addEvent ( "clothesBuyServer", true )
addEventHandler ( "clothesBuyServer", getRootElement(), clothesBuyServer_func )

function clothesCancel_func ()

	setElementDimension ( client, 0 )
end
addEvent ( "clothesCancel", true )
addEventHandler ( "clothesCancel", getRootElement(), clothesCancel_func )

function zipMarkerHit ( marker, dim )

	local player = source
	if getPedOccupiedVehicle ( player ) == false and dim then
		if marker == zipEntrance then
			setElementInterior ( player, 18, 161.66276550293, -93.030876159668, 1001.453918457 )
		end
		if marker == zipExit then
			setElementInterior ( player, 0, -1886.0278320313, 863.37353515625, 34.822071075439 )
		end
		if marker == zipBuy then
			setElementDimension ( player, math.random ( 1, 10000) )
			triggerClientEvent ( player, "_createSkinauswahlGui", player )
			showCursor ( player, true )
			setElementClicked ( player, true )
			setElementPosition ( player, 181.53558349609, -88.071517944336, 1001.672668457 )
			setCameraMatrix ( player, 178.41389465332, -87.539283752441, 1001.2360839844, 181.53558349609, -88.071517944336, 1001.672668457 )
		end
	end
	setPlayerNametagShowing ( player, true )
end
addEventHandler ( "onPlayerMarkerHit", getRootElement(), zipMarkerHit )