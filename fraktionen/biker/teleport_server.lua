--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

createTeleportMarker ( -2201.1906738281, -2341.1567382813, 29.599990844727, 0, 0, 488.29055786133, -81.450035095215, 998.40704345703, 11, 0, 0, 9 ) -- Hintereingang
createTeleportMarker ( 488.33416748047, -82.716491699219, 997.7568359375, 11, 0, -2202.2299804688, -2340.4091796875, 30.274225234985, 0, 0, 50, 9 ) -- Hinterausgang
createTeleportMarker ( -2191.5688476563, -2348.6118164063, 29.599990844727, 0, 0, 501.83410644531, -69.234756469727, 998.40704345703, 11, 0, 180, 0 ) -- Vordereingang
createTeleportMarker ( 501.87518310547, -67.962715148926, 997.73278808594, 11, 0, -2190.6828613281, -2349.3928222656, 30.274225234985, 0, 0, 180 + 50, 0 ) -- Vorderausgang


bikerGate = createObject ( 976, -2193.1000976563, -2349.1000976563, 29.26, 0, 0, 231.40002441406 )

bikerGateMoved = false

bikerLVGate = createObject ( 987, 2512.7060546875, 1603.087890625, 9.6932163238525, 0, 0, 180 )
bikerLVGate2 = createObject ( 987, 2561.62890625, 1483.5478515625, 9.6932163238525, 0, 0, 0 )

local bgate = false
local bgate2 = false


function mv_func ( player )

	if isBiker ( player ) or isOnDuty(player) or isMedic(player) then
	
		if getDistanceBetweenPoints3D ( -2193.1000976563, -2349.1000976563, 29.5, getElementPosition ( player ) ) < 10 then
		
			if bikerGateMoved == false then
				moveObject ( bikerGate, 3000, -2193.1000976563, -2349.1000976563, 29.26, 0, 0, 0 )
				bikerGateMoved = true
			else
				moveObject ( bikerGate, 3000, -2188.8000488281, -2343.6999511719, 29.26, 0, 0, 0 )
				bikerGateMoved = false
			end
			
		elseif getDistanceBetweenPoints3D ( 2512.7060546875, 1603.087890625, 9.6932163238525, getElementPosition ( player ) ) < 18 then
		
			if bgate == false then
			
				moveObject ( bikerLVGate, 1500, 2512.7060546875, 1603.087890625, 1.6932163238525 )
				bgate = true
			
			else
			
				moveObject ( bikerLVGate, 1500, 2512.7060546875, 1603.087890625, 9.6932163238525 )
				bgate = false
			
			end
			
		elseif getDistanceBetweenPoints3D ( 2561.62890625, 1483.5478515625, 9.6932163238525, getElementPosition ( player ) ) < 18 then
		
			if bgate2 == false then
			
				moveObject ( bikerLVGate2, 1500, 2561.62890625, 1483.5478515625, 1.6932163238525 )
				bgate2 = true
			
			else
			
				moveObject ( bikerLVGate2, 1500, 2561.62890625, 1483.5478515625, 9.6932163238525 )
				bgate2 = false
			
			end
			
		end
		
	end
	
end
addCommandHandler ( "mv", mv_func )