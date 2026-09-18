--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

vehBlipColor = {}
	vehBlipColor["r"] = {}
	vehBlipColor["g"] = {}
	vehBlipColor["b"] = {}
		color = 1
		vehBlipColor["r"][color] = 255
		vehBlipColor["g"][color] = 0
		vehBlipColor["b"][color] = 0
		color = color + 1
		vehBlipColor["r"][color] = 0
		vehBlipColor["g"][color] = 255
		vehBlipColor["b"][color] = 0
		color = color + 1
		vehBlipColor["r"][color] = 0
		vehBlipColor["g"][color] = 0
		vehBlipColor["b"][color] = 255
		color = color + 1
		vehBlipColor["r"][color] = 0
		vehBlipColor["g"][color] = 0
		vehBlipColor["b"][color] = 0
		color = color + 1
		vehBlipColor["r"][color] = 255
		vehBlipColor["g"][color] = 255
		vehBlipColor["b"][color] = 255
		color = color + 1
		vehBlipColor["r"][color] = 255
		vehBlipColor["g"][color] = 255
		vehBlipColor["b"][color] = 0
		color = color + 1
		vehBlipColor["r"][color] = 255
		vehBlipColor["g"][color] = 0
		vehBlipColor["b"][color] = 255
		color = color + 1
		vehBlipColor["r"][color] = 0
		vehBlipColor["g"][color] = 255
		vehBlipColor["b"][color] = 255
		color = color + 1
		vehBlipColor["r"][color] = 125
		vehBlipColor["g"][color] = 125
		vehBlipColor["b"][color] = 125
		color = color + 1
		vehBlipColor["r"][color] = 255
		vehBlipColor["g"][color] = 150
		vehBlipColor["b"][color] = 0
		color = color + 1
		color = nil

		
-- Lässt die Lichter eines Fahrzeugs kurz blinken (wie eine Fernbedienung),
-- z.B. beim Auf-/Zuschließen. setVehicleOverrideLights: 1 = erzwungen aus,
-- 2 = erzwungen an, 0 = zurück zur normalen (automatischen) Beleuchtung.
function flashVehicleLights ( veh, blinks )
	if not isElement ( veh ) then return end
	blinks = ( blinks or 2 ) * 2
	local step = 0
	setTimer ( function ()
		if not isElement ( veh ) then return end
		step = step + 1
		setVehicleOverrideLights ( veh, ( step % 2 == 1 ) and 2 or 1 )
		if step >= blinks then
			setVehicleOverrideLights ( veh, 0 )
		end
	end, 150, blinks )
end



function respawnPrivVeh ( carslot, pname )
	local carslot = tonumber ( carslot )
	local vehicle = allPrivateCars[pname][carslot] or false
	if isElement ( vehicle ) then
		if MtxGetElementData ( vehicle, "special" ) == 2 then 
			detachElements ( objectYacht[pname][carslot], vehicle )
			destroyElement ( objectYacht[pname][carslot] )
			special = 2
		end
		destroyMagnet ( vehicle )
		dbExec ( handler, "UPDATE vehicles SET ??=? WHERE ??=? AND ??=?", "Benzin", MtxGetElementData(vehicle,"fuelstate"), "UID", playerUID[pname], "Slot", carslot )
		destroyElement ( vehicle )
	end
	local dsatz = dbQueryCoro ( "SELECT * from vehicles WHERE UID = ? AND Slot = ?", playerUID[pname], carslot )
	if dsatz and dsatz[1] then	
		dsatz = dsatz[1]
		local Besitzer = playerUIDName[tonumber(dsatz["UID"])]
		local Typ = tonumber ( dsatz["Typ"] )
		local Tuning = dsatz["Tuning"]
		local Spawnpos_X = tonumber ( dsatz["Spawnpos_X"] )
		local Spawnpos_Y = tonumber ( dsatz["Spawnpos_Y"] )
		local Spawnpos_Z = tonumber ( dsatz["Spawnpos_Z"] )
		local Spawnrot_X = tonumber ( dsatz["Spawnrot_X"] )
		local Spawnrot_Y = tonumber ( dsatz["Spawnrot_Y"] )
		local Spawnrot_Z = tonumber ( dsatz["Spawnrot_Z"] )
		local Farbe = dsatz["Farbe"]
		local LFarbe = dsatz["Lights"]
		local Paintjob = tonumber ( dsatz["Paintjob"] ) or 0
		local Benzin = tonumber ( dsatz["Benzin"] )
		local Distanz = tonumber ( dsatz["Distance"] )
		local STuning = dsatz["STuning"]
		local Spezcolor = dsatz["spezcolor"]
		local Sportmotor = tonumber (dsatz["Sportmotor"])
		local Bremse = tonumber (dsatz["Bremse"] )
		local Antrieb = dsatz["Antrieb"]
		local PlateText = dsatz["plate"]
		local totalschaden = tonumber (dsatz["totalschaden"])
		local Beschlagnahmt = tonumber (dsatz["Beschlagnahmt"])
		local KeyTarget = tonumber (dsatz["KeyTarget"]) or false
		vehicle = createVehicle ( Typ, Spawnpos_X, Spawnpos_Y, Spawnpos_Z, 0, 0, 0, Besitzer )
		allPrivateCars[pname][carslot] = vehicle
		MtxSetElementData ( vehicle, "owner", Besitzer )
		MtxSetElementData ( vehicle, "name", vehicle )
		MtxSetElementData ( vehicle, "carslotnr_owner", carslot )
		MtxSetElementData ( vehicle, "locked", true )
		MtxSetElementData ( vehicle, "color", Farbe )
		MtxSetElementData ( vehicle, "lcolor", LFarbe )
		MtxSetElementData ( vehicle, "spawnpos_x", Spawnpos_X )
		MtxSetElementData ( vehicle, "spawnpos_y", Spawnpos_Y )
		MtxSetElementData ( vehicle, "spawnpos_z", Spawnpos_Z )
		MtxSetElementData ( vehicle, "spawnrot_x", Spawnrot_X )
		MtxSetElementData ( vehicle, "spawnrot_y", Spawnrot_Y )
		MtxSetElementData ( vehicle, "spawnrot_z", Spawnrot_Z )
		MtxSetElementData ( vehicle, "distance", Distanz )
		MtxSetElementData ( vehicle, "stuning", STuning )
		MtxSetElementData ( vehicle, "spezcolor", Spezcolor )
		setVehiclePlateText( vehicle, PlateText )
		MtxSetElementData ( vehicle, "rcVehicle", tonumber ( dsatz["rc"] ) )
		MtxSetElementData ( vehicle, "sportmotor", Sportmotor )
		MtxSetElementData ( vehicle, "bremse", Bremse )
		MtxSetElementData ( vehicle, "antrieb", Antrieb )
		setVehicleLocked ( vehicle, true )
		MtxSetElementData ( vehicle, "fuelstate", Benzin )
		MtxSetElementData ( vehicle, "totalschaden", totalschaden )
		MtxSetElementData ( vehicle, "Beschlagnahmt", Beschlagnahmt )
        MtxSetElementData ( vehicle, "KeyTarget", KeyTarget )
		setPrivVehCorrectColor ( vehicle )
		setPrivVehCorrectLightColor ( vehicle )
		setVehiclePaintjob ( vehicle, Paintjob )
		if special == 2 then
			objectYacht[pname][carslot] = createObject ( 1337, 0, 0, 0 )
			attachElements ( objectYacht[pname][carslot], vehicle, 0, 2, 1.55 )
			setElementDimension (objectYacht[pname][carslot], 1 )
		end
		giveSportmotorUpgrade ( vehicle )
		setVehicleRotation ( vehicle, Spawnrot_X, Spawnrot_Y, Spawnrot_Z )
		pimpVeh ( vehicle, Tuning )
		setVehicleAsMagnetHelicopter ( vehicle )
		return true
	end
	return false
end

function towveh_func ( player, command, towcar)
	if towcar == nil then
		triggerClientEvent ( player, "infobox_start", player, "Gebrauch:\n/towveh\n[Fahrzeugnummer]", 5000, 125, 0, 0 )
	else
		if MtxGetElementData ( player, "carslot"..towcar ) and tonumber(MtxGetElementData ( player, "carslot"..towcar )) >= 1 then
			local pname = getPlayerName ( player )
			local veh = allPrivateCars[pname][tonumber(towcar)] or false
			if MtxGetElementData(veh, "Beschlagnahmt") ~= 1 then
			if MtxGetElementData(veh, "totalschaden") ~= 1 then
			if MtxGetElementData ( player, "money" ) >= 20 then
				if respawnPrivVeh ( towcar, pname ) then
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - 20 )
					triggerClientEvent ( player, "infobox_start", player, "\nDu hast dein\nFahrzeug respawnt!", 5000, 0, 255, 0 )
				else
					triggerClientEvent ( player, "infobox_start", player, "\nDas Fahrzeug ist\nnicht leer!", 5000, 125, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", player, "\nDu hast nicht\ngenug Geld!", 5000, 125, 0, 0 )
			end
		else
			outputChatBox ("Dein Fahrzeug hat einen Totalschaden - Kontaktiere einen Mechaniker für Hilfe!",player,125, 0, 0 )
		end
		else
			outputChatBox ("Dein Fahrzeug (Slot: "..towcar..") \nwurde abgeschleppt!\n Du kannst es am Mechanikerbase\n freikaufen.",player,125, 0, 0)
		end
		else
			triggerClientEvent ( player, "infobox_start", player, "\nDu hast kein\nFahrzeug mit\ndieser Nummer!", 5000, 125, 0, 0 )
		end
	end
end	
addEvent ( "respawnPrivVehClick", true )
-- Absender erzwingen, sonst liesse sich fremdes Fahrzeug respawnen + Geld abbuchen.
addEventHandler ( "respawnPrivVehClick", getRootElement(), function ( _, command, towcar )
	if not isElement ( client ) then return end
	towveh_func ( client, command, towcar )
end )
addCommandHandler ( "towveh", towveh_func )

function sellcarto_func ( player, cmd, target, price, pSlot )
	local target = target and getPlayerFromName ( target ) or false
	if target and pSlot and tonumber ( pSlot ) then
		local pSlot = tonumber ( pSlot )
		local tSlot = getFreeCarSlot ( target )
		local pname = getPlayerName ( player )
		local result = dbQueryCoro ( "SELECT AuktionsID FROM vehicles WHERE ??=? AND ??=?", "UID", playerUID[pname], "Slot", pSlot )
		if not result or not result[1] or tonumber ( result[1]["AuktionsID"] ) == 0 then
			if tSlot and MtxGetElementData ( target, "carslot"..tSlot ) == 0 and MtxGetElementData ( player, "carslot"..pSlot ) > 0 then
				local veh = allPrivateCars[pname][pSlot] or false
				if tonumber ( price ) then
					price = math.abs ( math.floor ( tonumber ( price ) ) )
					if isElement ( veh ) then
						if MtxGetElementData ( target, "curcars" ) < MtxGetElementData ( target, "maxcars" ) then	
							local model = getElementModel ( veh )
							local stunings = sTuningsToString ( veh )
							outputChatBox ( getPlayerName ( player ).." bietet dir folgendes Fahrzeug für "..price.." "..Tables.waehrung.." an: "..getVehicleName ( veh ), target, 0, 125, 0 )
							outputChatBox ( "Tunings: "..stunings, target, 0, 125, 0 )
							outputChatBox ( "Tippe /buy car, um das Fahrzeug zu kaufen.", target, 0, 125, 0 )
							outputChatBox ( "Du hast "..getPlayerName ( target ).." dein Fahrzeug aus Slot Nr. "..pSlot.." angeboten.", player, 200, 200, 0 )							
							
							MtxSetElementData ( target, "carToBuyFrom", player )
							MtxSetElementData ( target, "carToBuySlot", tonumber ( pSlot ) )
							MtxSetElementData ( target, "carToBuyPrice", price )
							MtxSetElementData ( target, "carToBuyModel", getElementModel ( veh ) )
							outputLog ( getPlayerName ( player ).." hat ein Auto an Spieler angeboten ( "..getVehicleName ( veh ) .. " - " .. getPlayerName ( target ).." )", "vehicle" )
						else
							outputChatBox ( "Der Spieler hat keinen freien Fahrzeugslot mehr!", player, 125, 0, 0 )
						end
					else
						outputChatBox ( "Ungültiges Fahrzeug oder nicht respawnt! Gebrauch: /sellcarto [Name] [Preis] [Eigener Slot]", player, 125, 0, 0 )
					end
				else
					outputChatBox ( "Ungültiger Preis! Gebrauch: /sellcarto [Name] [Preis] [Eigener Slot]", player, 125, 0, 0 )
				end
			else
				outputChatBox ( "Ungültiger Fahrzeugslot! Gebrauch: /sellcarto [Name] [Preis] [Eigener Slot]", player, 125, 0, 0 )
			end
		else
			outputChatBox ( "Dieses Fahrzeug wird momentan versteigert!", player, 125, 0, 0 )
		end
	else
		outputChatBox ( "Gebrauch: /sellcarto [Name] [Preis] [Eigener Slot]", player, 125, 0, 0 )
	end
end
addCommandHandler ( "sellcarto", sellcarto_func )


function respawnVeh_func ( towcar, pname, veh )
	if towcar then
		respawnPrivVeh ( towcar, pname )
	else
		if not getVehicleOccupant ( veh ) then
			respawnVehicle ( veh )
			setElementDimension ( veh, 0 )
			setElementInterior ( veh, 0 )
        end
    end
end
addEvent ( "respawnVeh", true )
addEventHandler ( "respawnVeh", getRootElement(), respawnVeh_func )


function deleteVeh_func ( towcar, pname, veh, reason )
	local admin = getPlayerName ( source )
	if ( tonumber ( MtxGetElementData ( source, "adminlvl" ) ) or 0 ) >= 2 then
		local towcar = tonumber ( towcar )
		local player = getPlayerFromName ( pname )
		if player then
			outputChatBox ( "Dein Fahrzeug in Slot Nr. "..towcar.." wurde von "..admin.." gelöscht ("..reason..")!", player, 125, 0, 0 )
			MtxSetElementData ( player, "carslot"..towcar, 0 )
			allPrivateCars[pname][towcar] = nil
		else
			offlinemsg ( "Dein Fahrzeug in Slot Nr. "..towcar.." wurde von "..admin.." gelöscht("..reason..")!", "Server", pname )
		end
		outputLog ( "Fahrzeug von "..pname.." ( "..towcar.." ) wurde von "..admin.." gelöscht. | Modell: "..getElementModel(veh).." |", "autodelete" )
		destroyElement ( veh )
		dbExec ( handler, "DELETE FROM ?? WHERE ??=? AND ??=?", "vehicles", "UID", playerUID[pname], "Slot", towcar )
	end
end
addEvent ( "deleteVeh", true )
addEventHandler ( "deleteVeh", getRootElement(), deleteVeh_func )


function park_func ( player, command )
	if getPedOccupiedVehicleSeat ( player ) == 0 then
		local veh = getPedOccupiedVehicle ( player )
		if isElement ( veh ) and MtxGetElementData ( veh, "owner" ) == getPlayerName ( player ) or MtxGetElementData(veh, "KeyTarget") == playerUID[getPlayerName(player)]  or ( tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0 ) >= 4 then
			if isTrailerInParkingZone ( veh ) then
				local x, y, z = getElementPosition ( veh )
				local rx, ry, rz = getVehicleRotation ( veh )
				local c1, c2, c3, c4 = getVehicleColor ( veh )
				MtxSetElementData ( veh, "spawnposx", x )
				MtxSetElementData ( veh, "spawnposy", y )
				MtxSetElementData ( veh, "spawnposz", z )
				MtxSetElementData ( veh, "spawnrotx", rx )
				MtxSetElementData ( veh, "spawnroty", ry )
				MtxSetElementData ( veh, "spawnrotz", rz )
				MtxSetElementData ( veh, "color1", c1 )
				MtxSetElementData ( veh, "color2", c2 )
				MtxSetElementData ( veh, "color3", c3 )
				MtxSetElementData ( veh, "color4", c4 )
				outputChatBox ( "Fahrzeug geparkt!", player, 0, 255, 0 )
			
				local Spawnpos_X, Spawnpos_Y, Spawnpos_Z = getElementPosition ( veh )
				local Spawnrot_X, Spawnrot_Y, Spawnrot_Z = getVehicleRotation ( veh )
				local Farbe1, Farbe2, Farbe3, Farbe4 =  getVehicleColor ( veh )
				local color = "|"..Farbe1.."|"..Farbe2.."|"..Farbe3.."|"..Farbe4.."|"
				local Paintjob = getVehiclePaintjob ( veh ) or 3
				local Benzin = MtxGetElementData ( veh, "fuelstate" )
				local pname = MtxGetElementData ( veh, "owner" )
				local Distance = MtxGetElementData ( veh, "distance" )
				local slot = MtxGetElementData ( veh, "carslotnr_owner" )
				
				dbExec ( handler, "UPDATE vehicles SET Spawnpos_X=?, Spawnpos_Y=?, Spawnpos_Z=?, Spawnrot_X=?, Spawnrot_Y=?, Spawnrot_Z=?, Farbe=?, Paintjob=?, Benzin=?, Distance=? WHERE UID=? AND Slot=?", Spawnpos_X, Spawnpos_Y, Spawnpos_Z, Spawnrot_X, Spawnrot_Y, Spawnrot_Z, color, Paintjob, Benzin, Distance, playerUID[pname], slot ) 
			else
				outputChatBox ( "Dieses Fahrzeug kannst du nicht in der Stadt parken!", player, 125, 0, 0 )
			end
		else
			outputChatBox ( "Dieses Fahrzeug gehört dir nicht!", player, 255, 0, 0 )
		end
	else
		outputChatBox ( "Du musst in einem Fahrzeug sitzen!", player, 255, 0, 0 )
	end
end
addCommandHandler ( "park", park_func )

function lock(player, cmd, target, locknr)
	local veh = allPrivateCars[target][tonumber(locknr)] or false
	if MtxGetElementData(veh, "KeyTarget") == playerUID[getPlayerName(player)] then
		if MtxGetElementData ( veh, "locked" ) then
			MtxSetElementData ( veh, "locked", false )
			triggerClientEvent(player, "locksound", player)
			setVehicleLocked ( veh, false )
			setElementFrozen ( veh, false )
			flashVehicleLights ( veh )
			outputChatBox ( "Fahrzeug aufgeschlossen!", player, 0, 0, 255 )
		elseif not MtxGetElementData ( veh, "locked" ) then
			MtxSetElementData ( veh, "locked", true )
			triggerClientEvent(player, "locksound", player)
			setVehicleLocked ( veh, true )
			setElementFrozen ( veh, true )
			flashVehicleLights ( veh )
			outputChatBox ( "Fahrzeug abgeschlossen!", player, 0, 0, 255 )
		end
	end
end
addCommandHandler("tlock", lock)


function lock_func ( player, command, locknr )
	if locknr == nil then
		outputChatBox ( "Gebrauch: /lock [Fahrzeugnummer]", player, 255, 0, 0 )
	else
		if MtxGetElementData ( player, "carslot"..locknr ) and tonumber(MtxGetElementData ( player, "carslot"..locknr )) >= 1 then
			local pname = getPlayerName ( player )
			local veh = allPrivateCars[pname][tonumber(locknr)] or false
			if isElement ( veh ) then
				if MtxGetElementData ( veh, "locked" ) then
					MtxSetElementData ( veh, "locked", false )
					triggerClientEvent(player, "locksound", player)
					setVehicleLocked ( veh, false )
					setElementFrozen(veh, false)
					flashVehicleLights ( veh )
					outputChatBox ( "Fahrzeug aufgeschlossen!", player, 0, 0, 255 )
				elseif not MtxGetElementData ( veh, "locked" ) then
					MtxSetElementData ( veh, "locked", true )
					triggerClientEvent(player, "locksound", player)
					setVehicleLocked ( veh, true )
					if not getVehicleOccupant(veh) then
						setElementFrozen(veh, true)
					end
					flashVehicleLights ( veh )
					outputChatBox ( "Fahrzeug abgeschlossen!", player, 0, 0, 255 )
				end
			else
				outputChatBox ( "Bitte respawne dein Fahrzeug zuerst!", player, 255, 0, 0 )
			end
		else
			outputChatBox ( "Du hast kein Fahrzeug mit diesem Namen!", player, 255, 0, 0 )
		end
	end
end
addEvent ( "lockPrivVehClick", true )
-- Absender erzwingen, sonst liesse sich fremdes Auto aufschliessen.
addEventHandler ( "lockPrivVehClick", getRootElement(), function ( _, command, locknr )
	if not isElement ( client ) then return end
	lock_func ( client, command, locknr )
end )
addCommandHandler ( "lock", lock_func )


addEvent ( "lockVehClick", true )
addEventHandler ( "lockVehClick", getRootElement(), function ( player, veh )
	if isElement ( veh ) and getElementType ( veh ) == "vehicle" then
		if MtxGetElementData ( veh, "owner" ) == getPlayerName ( player ) or MtxGetElementData ( veh, "KeyTarget" ) == playerUID[getPlayerName(player)] then
			if MtxGetElementData ( veh, "locked" ) then
				MtxSetElementData ( veh, "locked", false )
				triggerClientEvent ( player, "locksound", player )
				setVehicleLocked ( veh, false )
				setElementFrozen ( veh, false )
				flashVehicleLights ( veh )
				outputChatBox ( "Fahrzeug aufgeschlossen!", player, 0, 0, 255 )
			else
				MtxSetElementData ( veh, "locked", true )
				triggerClientEvent ( player, "locksound", player )
				setVehicleLocked ( veh, true )
				if not getVehicleOccupant ( veh ) then
					setElementFrozen ( veh, true )
				end
				flashVehicleLights ( veh )
				outputChatBox ( "Fahrzeug abgeschlossen!", player, 0, 0, 255 )
			end
		else
			outputChatBox ( "Das Fahrzeug gehört dir nicht!", player, 255, 0, 0 )
		end
	end
end )


addEvent ( "respawnVehClick", true )
addEventHandler ( "respawnVehClick", getRootElement(), function ( player, veh )
	if isElement ( veh ) and getElementType ( veh ) == "vehicle" then
		local owner = MtxGetElementData ( veh, "owner" )
		if owner == getPlayerName ( player ) or MtxGetElementData ( veh, "KeyTarget" ) == playerUID[getPlayerName(player)] then
			local towcar = MtxGetElementData ( veh, "carslotnr_owner" )
			if MtxGetElementData ( veh, "Beschlagnahmt" ) ~= 1 then
				if MtxGetElementData ( veh, "totalschaden" ) ~= 1 then
					if MtxGetElementData ( player, "money" ) >= 20 then
						if respawnPrivVeh ( towcar, owner ) then
							MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - 20 )
							triggerClientEvent ( player, "infobox_start", player, "\nDu hast das\nFahrzeug respawnt!", 5000, 0, 255, 0 )
						else
							triggerClientEvent ( player, "infobox_start", player, "\nDas Fahrzeug ist\nnicht leer!", 5000, 125, 0, 0 )
						end
					else
						triggerClientEvent ( player, "infobox_start", player, "\nDu hast nicht\ngenug Geld!", 5000, 125, 0, 0 )
					end
				else
					outputChatBox ( "Das Fahrzeug hat einen Totalschaden - Kontaktiere einen Mechaniker für Hilfe!", player, 125, 0, 0 )
				end
			else
				outputChatBox ( "Das Fahrzeug (Slot: "..towcar..") \nwurde abgeschleppt!\n Es kann am Mechanikerbase\n freigekauft werden.", player, 125, 0, 0 )
			end
		else
			outputChatBox ( "Das Fahrzeug gehört dir nicht!", player, 255, 0, 0 )
		end
	end
end )


function vehinfos_func ( player )
	local curcars = MtxGetElementData ( player, "curcars" )
	local maxcars = MtxGetElementData ( player, "maxcars" )
	if curcars and maxcars then
		outputChatBox ( "Momentan im Besitz: "..curcars.." Fahrzeuge von maximal "..maxcars, player, 0, 0, 255  )
		local pname = getPlayerName ( player )
		color = 0
		for i = 1, maxcars do
			carslotname = "carslot"..i
			if MtxGetElementData ( player, carslotname ) ~= 0 then
				local veh = allPrivateCars[pname][i] or false
				if isElement ( veh ) then
					local x, y, z = getElementPosition( veh )
					if MtxGetElementData ( veh, "gps" ) then
						color = color + 1
						local blip = createBlip ( x, y, z, 0, 2, vehBlipColor["r"][color], vehBlipColor["g"][color], vehBlipColor["b"][color], 255, 0, 99999.0, player )
						setTimer ( destroyElement, 10000, 1, blip )
						outputChatBox ( "Slot Nr. "..i..": "..getVehicleName ( veh )..", steht momentan in "..getZoneName( x,y,z )..", "..getZoneName( x,y,z, true ), player, vehBlipColor["r"][color], vehBlipColor["g"][color], vehBlipColor["b"][color] )
					else
						outputChatBox ( "Slot Nr. "..i..": "..getVehicleName ( veh )..", steht momentan in "..getZoneName( x,y,z )..", "..getZoneName( x,y,z, true ), player, 0, 0, 200 )
					end
				else
					local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=? AND ??=?", "AuktionsID", "vehicles", "UID", playerUID[pname], "Slot", i )
					if result and result[1] and result[1]["AuktionsID"] == "1" then
						outputChatBox ( "Dein Fahrzeug in Slot Nr. "..i.." muss zuerst mit /towveh "..i.." respawned werden!", player, 125, 0, 0 )
					elseif result and result[1] then
						outputChatBox ( "Dein Fahrzeug in Slot Nr. "..i.." steht momentan zum Verkauf!", player, 125, 0, 0 )
					end
				end
			end
		end
	end
end
addCommandHandler ( "vehinfos", vehinfos_func )


function vehhelp_func ( player )
	outputChatBox ( "--- Fahrzeughilfe ---", player, 0, 0, 255 )
	outputChatBox ( "/towveh [Nummer] zum Respawnen am Parkort", player, 255, 0, 255 )
	outputChatBox ( "/lock [Nummer] zum Oeffnen/Schliessen", player, 255, 0, 255 )
	outputChatBox ( "/tlock [Name] [Nummer] zum Oeffnen/Schliessen", player, 255, 0, 255 )
	outputChatBox ( "/park zum Parken", player, 255, 0, 255 )
	outputChatBox ( "/vehinfos zum Anzeigen aller Aktueller Fahrzeuge", player, 255, 0, 255 )
	outputChatBox ( "/sellcar [Nummer] zum verkaufen des Autos ( 75% der Kosten werden erstattet )", player, 255, 0, 255 )
	outputChatBox ( "/sellcarto [Name] [Preis] [Slot zum verkaufen des Autos an einen Spieler", player, 255, 0, 255 )
	outputChatBox ( "/buycar zum Annehmen eines Angebotes", player, 255, 0, 255 )
	outputChatBox ( "/givekey [Spieler] [Eigener Slot], um das Auto weiterzugeben", player, 255, 0, 255 )
	outputChatBox ( "/clearvehKey [Eigener Slot], um den Schlüssel zu entfernen", player, 255, 0, 255 )
	outputChatBox ( "/break um die Handbremse zu betätigen", player, 255, 0, 255 )
end
addCommandHandler ( "vehhelp", vehhelp_func )


function sellcar_func ( player, cmd, slot )
	if slot then
		local slot = tonumber(slot)
		if MtxGetElementData ( player, "carslot"..slot ) > 0 then
			local pname = getPlayerName(player)
			local veh = allPrivateCars[pname][slot] or false
			if isElement ( veh ) then
				local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=? AND ??=?", "AuktionsID", "vehicles", "UID", playerUID[pname], "Slot", slot )
				if result and result[1] and tonumber ( result[1]["AuktionsID"] ) == 0 then
					destroyMagnet ( veh )
					local model = getElementModel ( veh )
					local price = carprices[model]
					if not price then
						price = 0
					end
					MtxSetElementData ( player, "carslot"..slot, 0 )
					allPrivateCars[pname][slot] = nil
					local spawnx = MtxGetElementData ( player, "spawnpos_x" )
					if spawnx == "marquis" or spawnx == "tropic" then
						MtxSetElementData ( player, "spawnpos_x", -2458.288085 )
						MtxSetElementData ( player, "spawnpos_y", 774.354492 )
						MtxSetElementData ( player, "spawnpos_z", 35.171875 )
						MtxSetElementData ( player, "spawnrot_x", 52 )
						MtxSetElementData ( player, "spawnint", 0 )
						MtxSetElementData ( player, "spawndim", 0 )
					end
					dbExec ( handler, "DELETE FROM ?? WHERE ??=? AND ??=?", "vehicles", "UID", playerUID[pname], "Slot", slot )
					MtxSetElementData(player,"curcars",tonumber(MtxGetElementData ( player, "curcars" ))-1)
					MtxSetElementData ( player, "FahrzeugeVerkauft", MtxGetElementData ( player, "FahrzeugeVerkauft" ) + 1 )
					SaveCarData ( player )
					infobox ( player, "Fahrzeug verkauft\nfür "..price/100*75 ..""..Tables.waehrung.."", 4000, 0, 200, 0 )
					outputLog ( getPlayerName ( player ).." hat ein Auto an Server verkauft ( "..getVehicleName ( veh ).." )", "vehicle" )
					destroyElement ( veh )
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" )+price/100*75 )
				else
					outputChatBox ( "Dieses Fahrzeug kannst du nicht verkaufen, da es zum Verkauf steht.", player, 125, 0, 0 )
				end
			else
				outputChatBox ( "Bitte respawne dein Fahrzeug vorher!", player, 125, 0, 0 )
			end		
		else
			infobox ( player, "\nUngültiger Slot!", 4000, 125, 0, 0 )
		end
	else
		infobox ( player, "Gebrauch:\n/sellcar [Slot]!", 4000, 200, 0, 0 )
	end
end
addCommandHandler ( "sellcar", sellcar_func )


function accept_sellcarto ( accepter, _, cmd )
	if cmd == "car" then
		local target = accepter
		local pSlot = MtxGetElementData ( accepter, "carToBuySlot" )
		player = MtxGetElementData ( accepter, "carToBuyFrom" )
		price = MtxGetElementData ( accepter, "carToBuyPrice" )
		model = MtxGetElementData ( accepter, "carToBuyModel" )
		if isElement ( player ) then
			local money = MtxGetElementData ( target, "bankmoney" )
			local tSlot = tonumber ( getFreeCarSlot ( target ) )
			if price <= money then
				if tonumber ( pSlot ) and tSlot then
					pSlot = tonumber ( pSlot )
					local pname = getPlayerName ( player )
					local result = dbQueryCoro ( "SELECT ??, ?? FROM ?? WHERE ??=? AND ??=?", "AuktionsID", "ID", "vehicles", "UID", playerUID[pname], "Slot", pSlot )
					if result and result[1] and tonumber ( result[1]["AuktionsID"] ) == 0 then
						if MtxGetElementData ( player, "carslot"..pSlot ) > 0 then
							local veh = allPrivateCars[pname][pSlot] or false
							if isElement ( veh ) then
								if model == getElementModel ( veh ) then
									if MtxGetElementData ( target, "curcars" ) < MtxGetElementData ( target, "maxcars" ) then
										
										local id = result[1]["ID"]
										
										outputChatBox ( "Du hast dein Fahrzeug in Slot Nr. "..pSlot.." an "..getPlayerName ( target ).." gegeben!", player, 0, 125, 0 )
										outputChatBox ( "Du hast ein Fahrzeug in Slot Nr. "..tSlot.." von "..getPlayerName ( player ).." erhalten!", target, 0, 125, 0 )
										
										dbExec ( handler, "UPDATE ?? SET ??=?, ??=?, ??=? WHERE ??=?", "vehicles", "UID", playerUID[getPlayerName(target)], "Slot", tSlot, "Lights", "|255|255|255|", "ID", id )

										MtxSetElementData ( target, "carslot"..tSlot, MtxGetElementData ( player, "carslot"..pSlot ) )
										MtxSetElementData ( player, "carslot"..pSlot, 0 )
										MtxSetElementData ( target, "curcars", MtxGetElementData ( target, "curcars" ) + 1 )
										MtxSetElementData ( player, "curcars", MtxGetElementData ( player, "curcars" ) - 1 )
										MtxSetElementData ( veh, "lcolor", "|255|255|255|" )
										
										setPrivVehCorrectLightColor ( veh )
										
										MtxSetElementData ( veh, "owner", getPlayerName ( target ) )
										MtxSetElementData ( veh, "name", "privVeh"..getPlayerName(target)..tSlot )
										MtxSetElementData ( veh, "carslotnr_owner", tSlot )
										
										allPrivateCars[getPlayerName(target)][tSlot] = veh
										allPrivateCars[pname][pSlot] = nil
										
										SaveCarData ( player )
										SaveCarData ( target )
										MtxSetElementData ( player, "FahrzeugeVerkauft", MtxGetElementData ( player, "FahrzeugeVerkauft" ) + 1 )
										MtxSetElementData ( target, "FahrzeugeGekauft", MtxGetElementData ( target, "FahrzeugeGekauft" ) + 1 )
											
										MtxSetElementData ( target, "bankmoney", money - price )
										MtxSetElementData ( player, "bankmoney", MtxGetElementData ( player, "bankmoney" ) + price )
											
										casinoMoneySave ( target )
										casinoMoneySave ( player )
										outputLog ( getPlayerName ( accepter ).." hat ein Auto von "..getPlayerName ( player ) .. " gekauft ( "..price.." - "..getVehicleName ( veh ).." )", "vehicle" )
									else
										infobox ( accepter, "Du hast keinen\nfreien Fahrzeugslot mehr!", 5000, 125, 0, 0 )
									end
								else
									infobox ( accepter, "Ein Fehler\nist aufgetreten.\nBitte lass dir\ndas Angebot erneut\nschicken!", 5000, 125, 0, 0 )
								end
							else
								infobox ( accepter, "Ein Fehler\nist aufgetreten.\nBitte lass dir\ndas Angebot erneut\nschicken!", 5000, 125, 0, 0 )
							end
						else
							infobox ( accepter, "Der Verkaufer hat\ndas Fahrzeug nicht\nmehr!", 5000, 125, 0, 0 )
						end
					end
				else
					infobox ( accepter, "Ein Fehler\nist aufgetreten.\nBitte lass dir\ndas Angebot erneut\nschicken!", 5000, 125, 0, 0 )
				end
			else
				infobox ( accepter, "Du hast nicht\ngenug Geld auf\nder Bank!", 5000, 125, 0, 0 )
			end
		else
			infobox ( accepter, "Der Anbieter des\nFahrzeugs ist offline!", 5000, 125, 0, 0 )
		end
	end
end
addCommandHandler ( "buy", accept_sellcarto )


function handbremsen ( player )
	local vehicle = getPedOccupiedVehicle ( player )
	if vehicle then
		local sitz = getPedOccupiedVehicleSeat ( player )
		if sitz == 0 then
			local vx, vy, vz = getElementVelocity ( getPedOccupiedVehicle ( player ) )
			local speed = math.sqrt ( vx ^ 2 + vy ^ 2 + vz ^ 2 )
			
			if speed < 5 * 0.00464 then
			else
				return
			end
	
			if MtxGetElementData ( vehicle, "owner" ) == getPlayerName ( player ) or MtxGetElementData(vehicle, "KeyTarget") == playerUID[getPlayerName(player)]  then
				if isElementFrozen ( vehicle ) then
					setElementFrozen ( vehicle, false )
					outputChatBox ( "Handbremse gelöst!", player, 0, 125, 0 )
				else
					setElementFrozen ( vehicle, true )
					outputChatBox ( "Handbremse angezogen!", player, 0, 125, 0 )
				end
			end
		end
	end
end

addCommandHandler ( "break", handbremsen )


local function kickeUnberechtigtenFahrer ( veh )
	if not isElement ( veh ) then return end
	local driver = getVehicleOccupant ( veh, 0 )
	if not isElement ( driver ) then return end
	local dname = getPlayerName ( driver )
	if MtxGetElementData ( veh, "owner" ) ~= dname and MtxGetElementData ( veh, "KeyTarget" ) ~= playerUID[dname] then
		if getVehicleEngineState ( veh ) then
			setVehicleEngineState ( veh, false )
			MtxSetElementData ( veh, "engine", false )
			infobox ( driver, "Dir wurde der\nSchlüssel für dieses\nFahrzeug entzogen!\nDer Motor geht aus.", 4000, 255, 0, 0 )
		end
	end
end


local function schluesselGeben ( player, slotNr, targetName )
	local pname = getPlayerName ( player )
	slotNr = tonumber ( slotNr )

	if not slotNr or not ( tonumber ( MtxGetElementData ( player, "carslot"..slotNr ) ) and tonumber ( MtxGetElementData ( player, "carslot"..slotNr ) ) > 0 ) then
		infobox ( player, "Ungültiger\nFahrzeug-Slot!", 5000, 255, 0, 0 )
		return
	end

	local veh = allPrivateCars[pname] and allPrivateCars[pname][slotNr]
	if not isElement ( veh ) then
		infobox ( player, "Bitte respawne\ndieses Fahrzeug\nzuerst!", 5000, 255, 0, 0 )
		return
	end

	if targetName == pname then
		infobox ( player, "Du kannst dir nicht\nselbst einen Schlüssel\ngeben!", 5000, 255, 0, 0 )
		return
	end


	local target = getPlayerFromName ( targetName )
	local targetUID = target and playerUID[getPlayerName(target)] or nil
	if not targetUID then
		local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "UID", "userdata", "Name", targetName )
		targetUID = result and result[1] and tonumber ( result[1]["UID"] )
	end
	local ownerUID = playerUID[pname]

	if not targetUID then
		infobox ( player, "Spieler '"..tostring(targetName).."'\nexistiert nicht.", 5000, 255, 0, 0 )
		return
	end
	if not ownerUID then
		infobox ( player, "Fehler: Deine UID\nnicht gefunden!", 5000, 255, 0, 0 )
		return
	end

	dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=? AND ??=?", "vehicles", "KeyTarget", targetUID, "UID", ownerUID, "Slot", slotNr )
	MtxSetElementData ( veh, "KeyTarget", targetUID )
	kickeUnberechtigtenFahrer ( veh )

	infobox ( player, "Schlüssel von Slot "..slotNr.."\nan "..targetName.." gegeben.", 5000, 0, 200, 0 )
	if target then
		infobox ( target, "Du hast von "..pname.."\neinen Fahrzeugschlüssel\nerhalten! (Slot "..slotNr..")", 5000, 0, 200, 0 )
	else
		dbExec ( handler, "INSERT INTO pm (Sender, EmpfaengerUID, Text, Datum) VALUES (?,?,?,?)", pname, targetUID, "Du hast von "..pname.." einen Fahrzeugschlüssel erhalten! (Slot "..slotNr..")", timestamp() )
	end
	outputDebugString ( "Schlüssel gegeben: "..pname.." -> "..targetName.." (Slot: "..slotNr..")" )
end


local function schluesselEntziehen ( player, slotNr )
	local pname = getPlayerName ( player )
	slotNr = tonumber ( slotNr )

	if not slotNr or not ( tonumber ( MtxGetElementData ( player, "carslot"..slotNr ) ) and tonumber ( MtxGetElementData ( player, "carslot"..slotNr ) ) > 0 ) then
		infobox ( player, "Ungültiger\nFahrzeug-Slot!", 5000, 255, 0, 0 )
		return
	end

	local ownerUID = playerUID[pname]
	if not ownerUID then
		infobox ( player, "Fehler: Deine UID\nnicht gefunden!", 5000, 255, 0, 0 )
		return
	end

	local veh = allPrivateCars[pname] and allPrivateCars[pname][slotNr]
	local aktuelleUID = isElement ( veh ) and MtxGetElementData ( veh, "KeyTarget" )
	if not aktuelleUID then
		infobox ( player, "Für Slot "..slotNr.."\nist aktuell kein\nSchlüssel vergeben.", 5000, 255, 0, 0 )
		return
	end

	dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=? AND ??=?", "vehicles", "KeyTarget", "none", "UID", ownerUID, "Slot", slotNr )

	if isElement ( veh ) then
		MtxSetElementData ( veh, "KeyTarget", false )
		kickeUnberechtigtenFahrer ( veh )
	end

	infobox ( player, "Schlüssel für Slot "..slotNr.."\nentfernt.", 5000, 0, 200, 0 )

	local targetName = playerUIDName[tonumber(aktuelleUID)]
	if targetName then
		local target = getPlayerFromName ( targetName )
		if target then
			infobox ( target, "Dein Schlüssel für\n"..pname.."s Fahrzeug\n(Slot "..slotNr..") wurde entzogen.", 5000, 255, 125, 0 )
		else
			dbExec ( handler, "INSERT INTO pm (Sender, EmpfaengerUID, Text, Datum) VALUES (?,?,?,?)", pname, tonumber(aktuelleUID), "Dein Schlüssel für "..pname.."s Fahrzeug (Slot "..slotNr..") wurde entzogen.", timestamp() )
		end
	end
	outputDebugString ( "Schlüssel entfernt: "..pname.." (Slot: "..slotNr..")" )
end

addEvent("onClientGiveKey", true)
addEventHandler("onClientGiveKey", root, function(targetName, slotNr)
	schluesselGeben ( client, slotNr, targetName )
end)

addEvent("onClientClearKey", true)
addEventHandler("onClientClearKey", root, function(slotNr)
	schluesselEntziehen ( client, slotNr )
end)


function giveVehicleKey ( player, cmd, kplayer, slotNr )
	if not kplayer or not slotNr then
		infobox ( player, "Gebrauch:\n/givekey [Spieler] [Slot]", 5000, 125, 0, 0 )
		return
	end
	schluesselGeben ( player, slotNr, kplayer )
end
addCommandHandler("givekey",giveVehicleKey)

function deleteTargetKey ( player, cmd, slotNr )
	if not slotNr then
		infobox ( player, "Gebrauch:\n/clearvehKey [Slot]", 5000, 125, 0, 0 )
		return
	end
	schluesselEntziehen ( player, slotNr )
end
addCommandHandler("clearvehKey", deleteTargetKey)