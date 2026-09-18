--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function specPimpVeh ( veh )

	local stuning = MtxGetElementData ( veh, "stuning" )
	for i = 1, 6 do
		MtxSetElementData ( veh, "stuning"..i, tonumber ( gettok ( stuning, i, string.byte ( "|" ) ) ) )
	end
	
	-- 1 = Kofferraum
	if MtxGetElementData ( veh, "stuning1" ) >= 1 then
		
	else
		MtxSetElementData ( veh, "stuning1", false )
	end
	-- 2 = Panzerung
	if MtxGetElementData ( veh, "stuning2" ) >= 1 then
		setElementHealth ( veh, 1700 )
	else
		MtxSetElementData ( veh, "stuning2", false )
	end
	-- 3 = Benzinersparnis - s.h. fuel --
	if MtxGetElementData ( veh, "stuning3" ) >= 1 then
		MtxSetElementData ( veh, "fuelSaving", true )
	else
		MtxSetElementData ( veh, "stuning3", false )
	end
	-- 4 = GPS, s.h. /vehinfos --
	if MtxGetElementData ( veh, "stuning4" ) >= 1 then
		MtxSetElementData ( veh, "gps", true )
	else
		MtxSetElementData ( veh, "stuning4", false )
	end
	local event = false
	-- 5 = Doppelreifen, s.h. vehenter
	if MtxGetElementData ( veh, "stuning5" ) >= 1 then
		MtxSetElementData ( veh, "wheelrefreshable", true )
		event = true
	else
		MtxSetElementData ( veh, "stuning5", false )
	end
	-- 6 = Nebelwerfer, s.h. Doppelreifen
	if MtxGetElementData ( veh, "stuning6" ) >= 1 then
		MtxSetElementData ( veh, "smokeable", true )
		event = true
	else
		MtxSetElementData ( veh, "stuning6", false )
	end
	
	if event then
		removeEventHandler ( "onVehicleEnter", veh, specialTuningVehEnter )
		removeEventHandler ( "onVehicleExit", veh, specialTuningVehExit )
		addEventHandler ( "onVehicleEnter", veh, specialTuningVehEnter )
		addEventHandler ( "onVehicleExit", veh, specialTuningVehExit )
	end
end

function createSmokeBehindVehicle ( player )

	local veh = getPedOccupiedVehicle ( player )
	if MtxGetElementData ( veh, "smokeable" ) then
		MtxSetElementData ( veh, "smokeable", false )
		local x, y, z = getElementPosition ( veh )
		local smoker1 = createObject ( 2780, x, y-0.1, z )
		local smoker2 = createObject ( 2780, x, y, z )
		local smoker3 = createObject ( 2780, x, y+0.1, z )
		setElementAlpha ( smoker1, 0 )
		setElementAlpha ( smoker2, 0 )
		setElementAlpha ( smoker3, 0 )
		attachElementsInCorrectWay ( smoker1, veh )
		attachElementsInCorrectWay ( smoker2, veh )
		attachElementsInCorrectWay ( smoker3, veh )
		setTimer ( destroyElement, 7500, 1, smoker1 )
		setTimer ( destroyElement, 7500, 1, smoker2 )
		setTimer ( destroyElement, 7500, 1, smoker3 )
		outputChatBox ( "Nebelwand aktiv - erst nach dem nächsten Respawnen verfügbar!", player, 0, 125, 0 )
	else
		outputChatBox ( "Nebelwand nicht verfügbar - bitte respawne dein Fahrzeug!", player, 125, 0, 0 )
	end
end

function refreshWheels ( player )

	local veh = getPedOccupiedVehicle ( player )
	if MtxGetElementData ( veh, "wheelrefreshable" ) then
		MtxSetElementData ( veh, "wheelrefreshable", false )
		setVehicleWheelStates ( veh, 0, 0, 0, 0 )
		outputChatBox ( "Reifen aufgepumpt!", player, 125, 0, 0 )
	else
		outputChatBox ( "Du kannst deine Reifen nur einmal neu aufpumpen - bitte respawne dein Fahrzeug!", player, 125, 0, 0 )
	end
end

function specialTuningVehEnter ( player, seat )

	local veh = getPedOccupiedVehicle ( player )
	if seat == 0 then
		if not isKeyBound ( player, "n", "down", createSmokeBehindVehicle ) then
			if MtxGetElementData ( veh, "smokeable" ) then
				outputChatBox ( "Nebelwand berreit - druecke \"n\", um sie auszuloesen!", player, 0, 125, 0 )
				bindKey ( player, "n", "down", createSmokeBehindVehicle )
			elseif MtxGetElementData ( veh, "stuning6" ) then
				outputChatBox ( "Nebelwand nicht verfügbar - respawne dein Fahrzeug!", player, 125, 0, 0 )
			end
		end
		if not isKeyBound ( player, "r", "down", refreshWheels ) then
			if MtxGetElementData ( veh, "wheelrefreshable" ) then
				outputChatBox ( "Reifenpumpen berreit - druecke \"R\", um sie einzusetzen!", player, 0, 125, 0 )
				bindKey ( player, "r", "down", refreshWheels )
			elseif MtxGetElementData ( veh, "stuning5" ) then
				outputChatBox ( "Reifenpumpen nicht verfügbar - respawne dein Fahrzeug!", player, 125, 0, 0 )
			end
		end
	end
end

function specialTuningVehExit ( player, seat )

	local veh = getPedOccupiedVehicle ( player )
	if seat == 0 then
		if isKeyBound ( player, "n", "down", createSmokeBehindVehicle ) then
			unbindKey ( player, "n", "down", createSmokeBehindVehicle )
		end
		if isKeyBound ( player, "r", "down", refreshWheels ) then
			unbindKey ( player, "r", "down", refreshWheels )
		end
	end
end


-- TRUNK --
function trunkStorageServer_func ( element, value, take )
	if source == client then
		local player = source
		local veh = MtxGetElementData ( player, "clickedVehicle" )
		local data = (dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=? AND ??=?", "Kofferraum", "vehicles", "UID", playerUID[MtxGetElementData ( veh, "owner" )], "Slot", MtxGetElementData ( veh, "carslotnr_owner" ) ))[1]["Kofferraum"]
		local drugs = tonumber ( gettok ( data, 1, string.byte ( '|' ) ) )
		local mats = tonumber ( gettok ( data, 2, string.byte ( '|' ) ) )
		local gun = tonumber ( gettok ( data, 3, string.byte ( '|' ) ) )
		local ammo = tonumber ( gettok ( data, 4, string.byte ( '|' ) ) )
			
		if element == "drugs" or element == "mats" then
			value = math.abs ( math.floor ( tonumber ( value ) ) )
		end
			
		if take then
			if element == "drugs" then
				if drugs >= value then
					drugs = drugs - value
					MtxSetElementData ( player, "drugs", MtxGetElementData ( player, "drugs" ) + value )
				end
			elseif element == "mats" then
				if mats >= value then
					mats = mats - value
					MtxSetElementData ( player, "mats", MtxGetElementData ( player, "mats" ) + value )
				end
			else
				giveWeapon ( player, gun, ammo )
				setPedWeaponSlot ( player, getSlotFromWeapon ( gun ) )
				gun = 0
				ammo = 0
			end
		else
			if element == "drugs" then
				if MtxGetElementData ( player, "drugs" ) >= value then
					drugs = drugs + value
					MtxSetElementData ( player, "drugs", MtxGetElementData ( player, "drugs" ) - value )
				else
				end
			elseif element == "mats" then
				if MtxGetElementData ( player, "mats" ) >= value then
					mats = mats + value
					MtxSetElementData ( player, "mats", MtxGetElementData ( player, "mats" ) - value )
				end
			else
				gun = getPedWeapon ( player )
				ammo = getPedTotalAmmo ( player )
				takeWeapon ( player, gun )
				setPedWeaponSlot ( player, 0 )
			end
		end
		local string = tostring ( drugs.."|"..mats.."|"..gun.."|"..ammo.."|" )
		local Besitzer = MtxGetElementData ( veh, "owner" )
		local slot = tonumber ( MtxGetElementData ( veh, "carslotnr_owner" ) )
		playSoundFrontEnd ( player, 40 )

		dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=? AND ??=?", "vehicles", "Kofferraum", string, "UID", playerUID[Besitzer], "Slot", slot )
	end
end
addEvent ( "trunkStorageServer", true )
addEventHandler ( "trunkStorageServer", getRootElement(), function ( element, value, take ) runAsync ( trunkStorageServer_func, element, value, take ) end )


function sTuningsToString ( veh )
	if veh and getElementType (veh) == "vehicle" then
		local thestring = ""
		if MtxGetElementData ( veh, "stuning1" ) then
			thestring = "Kofferraum"
		end
		if MtxGetElementData ( veh, "stuning2" ) then
			if thestring == "" then
				thestring = "Panzerung"
			else
				thestring = thestring..", Panzerung"
			end
		end
		if MtxGetElementData ( veh, "stuning3" ) then
			if thestring == "" then
				thestring = "Benzinersparnis"
			else
				thestring = thestring..", Benzinersparnis"
			end
		end
		if MtxGetElementData ( veh, "stuning4" ) then
			if thestring == "" then
				thestring = "GPS"
			else
				thestring = thestring..", GPS"
			end
		end
		if MtxGetElementData ( veh, "stuning5" ) then
			if thestring == "" then
				thestring = "Doppelreifen"
			else
				thestring = thestring..", Doppelreifen"
			end
		end
		if MtxGetElementData ( veh, "stuning6" ) then
			if thestring == "" then
				thestring = "Nebelwerfer"
			else
				thestring = thestring..", Nebelwerfer"
			end
		end
		if thestring == "" then thestring = "Keine" end
		return thestring
	else
		return false
	end
end
	