bonusVehicles = {
 [460]=true, -- Wasserflugzeug
 [539]=true, -- Vortex
 [471]=true, -- Quad
 [442]=true, -- Leichenwagen
 [457]=true  -- Golfwagen
}

camper = {
 [483]=true,
 [508]=true
}

function hasPlayerLicense (player,id)
	if cars[id] then
		if tonumber ( MtxGetElementData (player, "carlicense" ) ) == 1 then
			return true
		else
			return false
		end
	elseif lkws[id] then
		if tonumber ( MtxGetElementData (player,"lkwlicense") ) == 1 then
			return true
		else
			return false
		end
	elseif bikes[id] then
		if tonumber ( MtxGetElementData (player,"bikelicense") ) == 1 then
			return true
		else
			return false
		end
	elseif helicopters[id] then
		if tonumber ( MtxGetElementData (player,"helilicense") ) == 1 then
			return true
		else
			return false
		end
	elseif planea[id] then
		if tonumber ( MtxGetElementData (player,"planelicensea") ) == 1 then
			return true
		else
			return false
		end
	elseif planeb[id] then
		if tonumber ( MtxGetElementData (player,"planelicenseb") ) == 1 then
			return true
		else
			return false
		end
	elseif motorboats[id] then
		if tonumber ( MtxGetElementData (player,"motorbootlicense") ) == 1 then
			return true
		else
			return false
		end
	elseif raftboats[id] then
		if tonumber ( MtxGetElementData (player,"segellicense") ) == 1 then
			return true
		else
			return false
		end
	elseif nolicense[id] then
		return true
	else
		return true
	end
end


function opticExitVehicle ( player )
	local veh = getPedOccupiedVehicle ( player )
	if isElement ( veh ) then
		if getPedOccupiedVehicleSeat ( player ) == 0 then
			setElementVelocity ( veh, 0, 0, 0 )
		end
		setControlState ( player, "enter_exit", false )
		setTimer ( removePedFromVehicle, 750, 1, player )
		setTimer ( setControlState, 150, 1, player, "enter_exit", false )
		setTimer ( setControlState, 200, 1, player, "enter_exit", true )
		setTimer ( setControlState, 700, 1, player, "enter_exit", false )
	end
end
addEvent ( "opticExitVehicle", true )

addEventHandler ( "opticExitVehicle", getRootElement(),
	function ()
		opticExitVehicle ( client )
	end
)

function hasPlayerPerso ( player )
	return ( MtxGetElementData ( player, "perso" ) == 1 )
end