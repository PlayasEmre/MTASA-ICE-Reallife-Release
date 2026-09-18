--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


local discoBlip = 48
createBlip ( -2552.9599609375, 193.01498413086, 5.7878270149231, discoBlip, 2, 255, 0, 0, 255, 0, 200, getRootElement() )

discoEnterMarker = createMarker ( -2551.1716308594, 193.70712280273, 5.0384402275085, "cylinder", 1.5, 255, 0, 0, 150 )
discoExitMarker = createMarker ( 493.41168212891, -24.308652877808, 999.57861328125, "cylinder", 1.5, 255, 0, 0, 150 )
setElementInterior ( discoExitMarker, 17 )

function enterDisco ( hit, dim )

	if hit and dim then
		if getElementType ( hit ) == "player" then
			if not getPedOccupiedVehicle ( hit ) then
				local x, y, z, r = 493.40060424805, -22.230197906494, 1000.328918457, 0
				fadeElementInterior ( hit, 17, x, y, z, r )
			end
		end
	end
end
addEventHandler ( "onMarkerHit", discoEnterMarker, enterDisco )

function exitDisco ( hit, dim )

	if hit and dim then
		if getElementType ( hit ) == "player" then
			if not getPedOccupiedVehicle ( hit ) then
				local x, y, z, r = -2552.9599609375, 193.01498413086, 5.7878270149231, 105
				fadeElementInterior ( hit, 0, x, y, z, r )
			end
		end
	end
end
addEventHandler ( "onMarkerHit", discoExitMarker, exitDisco )