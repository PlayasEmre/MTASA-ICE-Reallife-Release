--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


function setVehicleAsMagnetHelicopter ( veh )

	if getElementModel ( veh ) == 417 then
		local x, y, z = getElementPosition ( veh )
		local magnet = createObject ( 1301, x, y, z-1.5)
		attachElements ( magnet, veh, 0, 0, -1.5 )
		MtxSetElementData ( veh, "magpos", -1.5 )
		MtxSetElementData ( veh, "magnet", magnet )
		MtxSetElementData ( veh, "magnetic", true )
		MtxSetElementData ( veh, "hasmagnetactivated", false )
	end
end

function destroyMagnet ( veh )

	if veh then
		source = veh
	end
	if MtxGetElementData ( source, "magnetic" ) then
		local magnet = MtxGetElementData ( veh, "magnet" )
		destroyElement ( magnet )
	end
end
addEventHandler ( "onVehicleExplode", getRootElement(), destroyMagnet )

function magnetUp ( player )

	local veh = getPedOccupiedVehicle ( player )
	if veh then
		local magpos = MtxGetElementData ( veh, "magpos" )
		if magpos then
			if magpos < -1.5 then
				local magnet = MtxGetElementData ( veh, "magnet" )
				detachElements ( magnet )
				local magpos = magpos+0.1
				attachElements ( magnet, veh, 0, 0, magpos, 0, 0, 0 )
				MtxSetElementData ( veh, "magpos", magpos )
			end
		end
	end
end
function magnetDown ( player )

	local veh = getPedOccupiedVehicle ( player )
	if veh then
		local magpos = MtxGetElementData ( veh, "magpos" )
		if magpos then
			if magpos > -15 then
				local magnet = MtxGetElementData ( veh, "magnet" )
				detachElements ( magnet )
				local magpos = magpos-0.1
				attachElements ( magnet, veh, 0, 0, magpos, 0, 0, 0 )
				MtxSetElementData ( veh, "magpos", magpos )
			end
		end
	end
end

function bindTrigger ()

	if getElementType ( source ) == "player" then
		if not isKeyBound ( source, "lctrl", "down", magnetVehicleCheck ) then
			bindKey ( source, "lctrl", "down", magnetVehicleCheck )
			bindKey ( source, "rctrl", "down", magnetVehicleCheck )
			bindKey ( source, "num_sub", "down", magnetUp )
			bindKey ( source, "num_add", "down", magnetDown )
		end
	end
end
function unbindTrigger ()

	if isKeyBound ( source, "lctrl", "down", magnetVehicleCheck ) then
		unbindKey ( source, "lctrl", "down", magnetVehicleCheck )
		unbindKey ( source, "rctrl", "down", magnetVehicleCheck )
		unbindKey ( source, "num_sub", "down", magnetUp )
		unbindKey ( source, "num_add", "down", magnetDown )
	end
end
addEventHandler ( "onPlayerVehicleEnter", getRootElement(), bindTrigger )
addEventHandler ( "onPlayerVehicleExit", getRootElement(), unbindTrigger )
addEventHandler ( "onPlayerWasted", getRootElement(), unbindTrigger )

function magnetVehicleCheck ( player )

	local veh = getPedOccupiedVehicle ( player )
	if veh then
		if MtxGetElementData ( veh, "magnetic" ) then
			if MtxGetElementData ( veh, "hasmagnetactivated" ) then
				MtxSetElementData ( veh, "hasmagnetactivated", false )
				detachElements ( MtxGetElementData ( veh, "magneticVeh" ) )
			else
				local magnet = MtxGetElementData ( veh, "magnet" )
				local x, y, z = getElementPosition ( magnet )
				local magpos = MtxGetElementData ( veh, "magpos" )
				local marker = createColSphere ( x , y , z, 2 )
				local vehs = getElementsWithinColShape ( marker, "vehicle" )
				destroyElement ( marker )
				grabveh = false
				for key, vehitem in ipairs(vehs) do
					if vehitem ~= veh then
						local grabveh = vehitem
						attachElements ( grabveh, magnet, 0, 0, -1, 0, 0, getVehicleRotation(grabveh) )
						MtxSetElementData ( veh, "hasmagnetactivated", true )
						MtxSetElementData ( veh, "magneticVeh", grabveh )
						break
					end
				end
			end
		end
	end
end