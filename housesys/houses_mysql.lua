--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

houses = {}
 houses["id"] = {}
 houses["pickup"] = {}

function createHouse ( player, cmd, preis, int )
	if preis and tonumber(preis) and int and tonumber(int) then
		local Preis = tonumber ( math.abs ( preis ) )
		local CurrentInterior = tonumber ( int )
		if ( tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0 ) >= 2 then
			if Preis >= 15000 then
				if CurrentInterior ~= nil then
					local SymbolX, SymbolY, SymbolZ = getElementPosition ( player )
					local Besitzer = "none"
					local Preis = tonumber ( preis )
					local CurrentInterior = tonumber ( int )
					local inserted, _, ID = dbPoll ( dbQuery ( handler, "INSERT INTO houses ( SymbolX, SymbolY, SymbolZ, UID, Preis, CurrentInterior, Kasse, Miete ) VALUES (?,?,?,?,?,?,?,?)", SymbolX, SymbolY, SymbolZ, 0, Preis, CurrentInterior, '0', '0' ), -1 )
					if not inserted then
						outputDebugString("[createHouse] Error executing the query")
						return false
					else
						outputDebugString ("Haus ID "..ID.." wurde angelegt!")
						outputChatBox ( "Haus angelegt!", player, 200, 200, 0 )
						createHouseNew ( ID, SymbolX, SymbolY, SymbolZ, Besitzer, Preis, CurrentInterior, 0, 0 )
						return true
					end
				else
					outputChatBox ( "Gebrauch: /newhouse [Preis] [Interior ( iraum [1-30] )]", player, 155, 0, 0 )
				end
			else
				outputChatBox ( "Mindestpreis muss 15.000$ sein!", player, 155, 0, 0 )
			end
		else
			infobox ( player, "Du bist\nnicht befugt!", player, 4000, 155, 0, 0 )
		end
	else
		outputChatBox ( "Gebrauch: /newhouse [Preis] [Interior ( iraum [1-30] )]", player, 155, 0, 0 )
	end
end
addCommandHandler ( "newhouse", createHouse )


function createHouseNew ( id, x, y, z, owner, cost, int, kasse, rent, tier )

	local img
	if owner == "none" then img = 1273 else img = 1272 end

	local pickup = createPickup ( x, y, z, 3, img, 200, 0 )
	addEventHandler ( "onPickupHit", pickup, housePickup )

	houses["id"][pickup] = id
	houses["pickup"][id] = pickup
	if owner ~= "0" then
		houses["pickup"][owner] = pickup
	end

	MtxSetElementData ( pickup, "owner", owner )
	MtxSetElementData ( pickup, "locked", true )
	MtxSetElementData ( pickup, "preis", cost )
	MtxSetElementData ( pickup, "curint", int )
	MtxSetElementData ( pickup, "id", id )
	MtxSetElementData ( pickup, "miete", rent )
	MtxSetElementData ( pickup, "kasse", kasse )
	MtxSetElementData ( pickup, "tier", tier or "mittel" )
end


function setHouseBought ( pickup, owner )
	if isElement ( pickup ) then
		local x, y, z = getElementPosition ( pickup )
		local newpickup = createPickup ( x, y, z, 3, 1272, 200, 0 )
		
		local id = houses["id"][pickup]
		houses["id"][newpickup] = id
		houses["id"][pickup] = nil
		
		houses["pickup"][id] = newpickup
		houses["pickup"][owner] = newpickup
		
		MtxSetElementData ( newpickup, "owner", owner )
		MtxSetElementData ( newpickup, "locked", true )
		MtxSetElementData ( newpickup, "preis", MtxGetElementData ( pickup, "preis" ) )
		MtxSetElementData ( newpickup, "curint", MtxGetElementData ( pickup, "curint" ) )
		MtxSetElementData ( newpickup, "id", id )
		MtxSetElementData ( newpickup, "miete", MtxGetElementData ( pickup, "miete" )  )
		MtxSetElementData ( newpickup, "kasse", MtxGetElementData ( pickup, "kasse" )  )
		MtxSetElementData ( newpickup, "tier", MtxGetElementData ( pickup, "tier" )  )
		
		destroyElement ( pickup )
		addEventHandler ( "onPickupHit", newpickup, housePickup )
	end
end


function setHouseSold ( pickup, owner )
	if isElement ( pickup ) then
		local x, y, z = getElementPosition ( pickup )
		local newpickup = createPickup ( x, y, z, 3, 1273, 200, 0 )
		
		local id = houses["id"][pickup]
		houses["id"][newpickup] = id
		houses["id"][pickup] = nil
		
		houses["pickup"][id] = newpickup
		houses["pickup"][owner] = nil
		
		MtxSetElementData ( newpickup, "owner", "none" )
		MtxSetElementData ( newpickup, "locked", true )
		MtxSetElementData ( newpickup, "preis", MtxGetElementData ( pickup, "preis" ) )
		MtxSetElementData ( newpickup, "curint", MtxGetElementData ( pickup, "curint" ) )
		MtxSetElementData ( newpickup, "id", id )
		MtxSetElementData ( newpickup, "miete", MtxGetElementData ( pickup, "miete" )  )
		MtxSetElementData ( newpickup, "kasse", MtxGetElementData ( pickup, "kasse" )  )
		MtxSetElementData ( newpickup, "tier", MtxGetElementData ( pickup, "tier" )  )
		
		destroyElement ( pickup )
		addEventHandler ( "onPickupHit", newpickup, housePickup )
	end
end


function houseCreation()
	local result = dbPoll ( dbQuery ( handler, "SELECT * FROM houses" ), -1 )
	if result and result[1] then
		local amount = #result
		for i=1, amount do
			local id = tonumber(result[i]["ID"])
			local x = tonumber(result[i]["SymbolX"])
			local y = tonumber(result[i]["SymbolY"])
			local z = tonumber(result[i]["SymbolZ"])
			local owner = playerUIDName[tonumber(result[i]["UID"])]
			local cost = tonumber(result[i]["Preis"])
			local int = tonumber(result[i]["CurrentInterior"])
			local kasse = tonumber(result[i]["Kasse"])
			local rent = tonumber(result[i]["Miete"])
			local tier = result[i]["Tier"]
			createHouseNew ( id, x, y, z, owner, cost, int, kasse, rent, tier )
			loadGangData ( id )
		end
		outputServerLog("Es wurden "..amount.." Haeuser gefunden")
	else
		outputDebugString("[houseCreation] Error executing the query.")
	end
end
addEventHandler ( "onResourceStart", resourceRoot, houseCreation )


function dehouse (player)
	if isAdminLevel ( player, 3 ) then
		local haus = MtxGetElementData ( player, "house" )
		local owner = MtxGetElementData ( haus, "owner" )
		local x1, y1, z1 = getElementPosition ( player )
		local x2 = MtxGetElementData ( player, "housex" )
		local y2 = MtxGetElementData ( player, "housey" )
		local z2 = MtxGetElementData ( player, "housez" )
		local pname = getPlayerName ( player )
		local hausid = MtxGetElementData ( haus, "id" )
		local distance = getDistanceBetweenPoints3D ( x1, y1, z1, x2, y2, z2 )
		if distance < 5 then
			outputChatBox("Das Haus mit der ID "..hausid.." wurde soeben gelöscht!", player, 100, 255, 0)
			if not owner == "none" then
				local owner = MtxGetElementData ( haus, "owner" )
				dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "houses", "Besitzer", "none",  "ID", hausid )
				dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "houses", "Hausschluessel", 0,  "UID", playerUID[target] )
				MtxSetElementData ( haus, "owner", "none" )
				setElementModel ( haus, 1273 )
			end
			destroyElement(haus)
			dbExec ( handler, "DELETE FROM ?? WHERE ?? = ?", "houses", "ID", hausid )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist bei keinem Haus oder bist kein\nAdministrator.", 7500, 125, 0, 0 )
	end	
end
addCommandHandler ( "delhouse", dehouse )