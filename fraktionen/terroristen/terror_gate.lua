--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

terrorgate = createObject( 971, -1992.4000244141, -1635.8000488281, 87.599998474121, 0, 0, 0 )
local terror_gate_moving = false

function terrorgate_func(player, command)

	local x, y, z = getElementPosition( player )
	
	if isTerror (player) or isOnDuty(player) or isMedic(player) then
	
		if getDistanceBetweenPoints3D ( x, y, z, -1992.4000244141, -1635.8000488281, 87.599998474121 ) <= 18 then
		
			if not terror_gate_moving then
			
				moveObject ( terrorgate, 3500, -1992.4000244141, -1635.8000488281, 78.599998474121 )
				terror_gate_moving = true
			
			else
			
				moveObject ( terrorgate, 3500, -1992.4000244141, -1635.8000488281, 87.599998474121 )
				terror_gate_moving = false
			
			end
		
		end
		
	end
	
end

addCommandHandler("mv", terrorgate_func)

------------------------------------------

terrorlift = createObject( 3115, -1967.4000244141, -1494.8000488281, 85.300003051758, 0, 0, 85.742797851563)
local terror_gate_moving = false

function terrorlift_func(player, command)

	local x1, y1, z1 = getElementPosition( player )
	
	if isTerror (player) or isOnDuty(player) or isMedic(player) then
	
		if getDistanceBetweenPoints3D ( x1, y1, z1, -1967.4000244141, -1494.8000488281, 100.300003051758 ) <= 100 then
		
			if not terror_gate_moving then
			
				moveObject ( terrorlift, 8000, -1967.4000244141, -1494.8000488281, 85.300003051758)
				terror_gate_moving = true
			
			else
			
				moveObject ( terrorlift, 8000, -1966.9200439453, -1494.7600097656, 126.09999847412)
				terror_gate_moving = false
			
			end
		
		end
		
	end
	
end

addCommandHandler("mv", terrorlift_func)