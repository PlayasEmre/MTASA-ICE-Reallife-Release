--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function iraeume ( player, cmd, i )

	if ( tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0 ) >= 2 then
		local int, intx, inty, intz = getInteriorData ( i )
		if int then
			setElementInterior ( player, int, intx, inty, intz )
		else
			infobox ( player, "Der Interior\nexistiert nicht!", 4000, 200, 0, 0 )
		end
	end
end
addCommandHandler ( "iraum", iraeume )

function in_func ( player )
	local house = MtxGetElementData ( player, "house" )
	if isElement ( house ) then
		local px, py, pz = getElementPosition ( player )
		local hx, hy, hz = getElementPosition ( house )
		if getDistanceBetweenPoints3D ( px, py, pz, hx, hy, hz ) <= 5 then
			if ( getElementModel ( house ) == 1273 or getElementModel ( house ) == 1272 ) and MtxGetElementData ( house, "curint" ) > 0 then
				if not MtxGetElementData ( house, "locked" ) or math.abs ( MtxGetElementData ( player, "housekey" ) ) == MtxGetElementData ( house, "id" ) or MtxGetElementData ( house, "id" ) == getPlayerGang ( player ) then
					local i = MtxGetElementData ( house, "curint" )
					MtxSetElementData ( player, "curIntIn", i )
					local int, intx, inty, intz = getInteriorData ( i )
					local dim = MtxGetElementData ( house, "id" )
					if i == 0 then
						dim = 0
					end
					setElementDimension ( player, dim )
					fadeElementInterior ( player, int, intx, inty, intz )
					triggerClientEvent ( player, "infobox_start", getRootElement(), "Druecke F2, um\ndas Hausmenue zu\noeffnen. Darueber\nkannst du das Haus\nauch wieder verlassen!", 7500, 125, 0, 0 )
					bindKey ( player, "F2", "down", house_func )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nEs ist abgeschlossen!", 7500, 125, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist bei\nkeinem Haus!", 7500, 125, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist bei\nkeinem Haus!", 7500, 125, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist bei\nkeinem Haus!", 7500, 125, 0, 0 )
	end
end
addCommandHandler ( "in", in_func )

function out_func ( player )
	local dim = getElementDimension ( player )
	local haus = MtxGetElementData ( player, "house" )
	if not isElement ( haus ) then
		haus = houses["pickup"][getElementDimension ( player )]
	end
	if isElement ( haus ) then
		local i = MtxGetElementData ( haus, "curint" )
		local int, intx, inty, intz = getInteriorData ( i )
		if int then
			local px, py, pz = getElementPosition ( player )
			if getDistanceBetweenPoints3D ( px, py, pz, intx, inty, intz ) <= 10 then
				MtxGetElementData ( player, "curIntIn", 0 )
				local dim = getElementDimension ( player )
				local sx, sy, sz = getElementPosition ( haus )
				fadeElementInterior ( player, 0, sx, sy, sz )
				setElementDimension ( player, 0 )
				unbindKey ( player, "F2", "down", house_func )
			end
		end
	else
		outputChatBox ( "Du bist in keinem Haus!", player, 125, 0, 0 )
	end
end
addCommandHandler ( "out", out_func )

function rent_func ( player )

	local haus = MtxGetElementData ( player, "house" )
	if haus then
		local x1, y1, z1 = getElementPosition ( player )
		local x2, y2, z2 = getElementPosition ( haus )
		local pname = getPlayerName ( player )
		local distance = getDistanceBetweenPoints3D ( x1, y1, z1, x2, y2, z2 )
		local miete = tonumber ( MtxGetElementData ( haus, "miete" ) )
		local kasse = tonumber ( MtxGetElementData ( haus, "kasse" ) )
		if distance < 5 then
			if MtxGetElementData ( haus, "miete" ) >= 1 and MtxGetElementData ( haus, "owner" ) ~= "none" then
				if MtxGetElementData ( player, "housekey" ) == 0 then
					if MtxGetElementData ( player, "money" ) >= miete then
						MtxSetElementData ( player, "housekey", tonumber ( MtxGetElementData ( haus, "id" ) ) * -1 )
						triggerClientEvent ( player, "infobox_start", getRootElement(), "Du hast dich\nerfolgreich einge-\nmietet, tippe /unrent,\num auszuziehen!", 7500, 0, 200, 0 )
						moneychange ( player, miete*-1 )
						updatePartnerSpawnFromHouse ( player )
						local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Kasse", "houses", "ID", getElementDimension ( player ) )
						if result and result[1] then
							kasse = tonumber ( result[1]["Kasse"] )
							dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "houses", "Kasse", kasse + miete, "ID", MtxGetElementData ( haus, "id" ) )
							MtxSetElementData ( haus, "kasse", kasse + miete )
						end
					else
						triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu hast zu\nwenig Geld!", 7500, 125, 0, 0 )
					end
				elseif MtxGetElementData ( player, "housekey" ) < 0 then
					triggerClientEvent ( player, "infobox_start", getRootElement(), "Du bist bereits\nin ein Haus\neingemietet! Tippe\n/unrent, um aus-\nzuziehen!", 7500, 125, 0, 0 )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "Dir gehört bereits\nein Haus - Tippe\nzuerst /sellhouse!", 7500, 125, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nHier kansnt du\ndich nicht\neinmieten!", 7500, 125, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist bei\nkeinem Haus!", 7500, 125, 0, 0 )
		end
	end
end
addCommandHandler ( "rent", function ( player ) runAsync ( rent_func, player ) end )

function sellhouse_func ( player )

	local ID = tonumber ( MtxGetElementData ( player, "housekey" ) )
	if ID > 0 then
		local haus = houses["pickup"][ID]
		local pname = getPlayerName ( player )
		local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=? AND ?? LIKE ?", "Typ", "buyit", "AnbieterUID", playerUID[pname], "Typ", "Houses" )
		if not result or not result[1] then
			if not isGang ( ID ) then
				outputLog ( pname.." hat sein Haus verkauft.", "house" )
				MtxSetElementData ( player, "spawnpos_x", -2458.288085 )
				MtxSetElementData ( player, "spawnpos_y", 774.354492 )
				MtxSetElementData ( player, "spawnpos_z", 35.171875 )
				MtxSetElementData ( player, "spawnrot_x", 52 )
				MtxSetElementData ( player, "spawnint", 0 )
				MtxSetElementData ( player, "spawndim", 0 )
				MtxSetElementData ( player, "housekey", 0 )
				updatePartnerSpawnFromHouse ( player )
				local owner = MtxGetElementData ( haus, "owner" )
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu hast soeben\ndein Haus verkauft!", 7500, 0, 200, 0 )
				dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "houses", "UID", 0, "UID", playerUID[getPlayerName(player)] )
				dbExec ( handler, "UPDATE ?? SET ??=? WHERE ?? LIKE ?", "userdata", "Hausschluessel", 0, "UID", playerUID[getPlayerName(player)] )
				local hauswert = tonumber ( MtxGetElementData ( haus, "preis" ) )
				moneychange ( player, hauswert )
				datasave_remote(player)
				setHouseSold ( haus, player )
			else
				infobox ( player, "\n\n\nLoese erst deine\nGang auf!", 5000, 125, 0, 0 )
			end
		else
			outputChatBox ( "Dein Haus wird momentan versteigert!", player, 125, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDir gehoert\nkein Haus!", 7500, 125, 0, 0 )
	end
end
addCommandHandler ( "sellhouse", function ( player ) runAsync ( sellhouse_func, player ) end )

function unrent_func ( player )

	local ID = MtxGetElementData ( player, "housekey" )
	if ID < 0 then
		MtxSetElementData ( player, "spawnpos_x", -2458.288085 )
		MtxSetElementData ( player, "spawnpos_y", 774.354492 )
		MtxSetElementData ( player, "spawnpos_z", 35.171875 )
		MtxSetElementData ( player, "spawnrot_x", 52 )
		MtxSetElementData ( player, "spawnint", 0 )
		MtxSetElementData ( player, "spawndim", 0 )
		MtxSetElementData ( player, "housekey", 0 )
		updatePartnerSpawnFromHouse ( player )
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu hast dich\nausgemietet!", 7500, 0, 200, 0 )
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist nirgends\neingemietet!", 7500, 125, 0, 0 )
	end
end
addCommandHandler ( "unrent", unrent_func )

function setrent_func ( player, cmd, preis )

	local ID = MtxGetElementData ( player, "housekey" )
	local haus = houses["pickup"][ID]
	local preis = math.abs(math.floor(preis))
	if ID > 0 then
		local miete =  math.abs ( tonumber ( preis ) )
		if miete and miete <= 1000 then
			MtxSetElementData ( haus, "miete", miete )
			dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "houses", "Miete",  miete, "ID", MtxGetElementData ( haus, "id" ) )
			if miete == 0 then
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDein Haus ist\nnun nicht mehr\nzu mieten!", 7500, 0, 200, 0 )
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDein Haus ist\nnun fuer "..miete.." "..Tables.waehrung.."\nzu mieten!", 7500, 0, 200, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "Fehler: Tippe\n/setrent [Summe],\n0 "..Tables.waehrung.." = Nicht\nmietbar, max.\n1000 "..Tables.waehrung.."!", 7500, 125, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDir gehoert\nkein Haus!", 7500, 125, 0, 0 )
	end
end
addCommandHandler ( "setrent", setrent_func )

function house_func ( player, key, state )

	if isInUserHouse ( player ) then
		local amount = tonumber ( (dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Kasse", "houses", "ID", getElementDimension ( player ) ))[1]["Kasse"] )
		if amount then
			if not getElementClicked ( player ) then
				setElementClicked ( player, true )
				showCursor ( player, true )
				setElementClicked ( player, true )
				local id = getElementDimension ( player )
				if isInGang ( player, id ) then
					openClientGangWindow ( player, id )
				else
					triggerClientEvent ( player, "showHouseGui", player, amount )
				end
			end
		end
	end
end

function hlock_func ( player )

	local hkey = MtxGetElementData ( player, "housekey" )
	if hkey > 0 then
		MtxSetElementData ( houses["pickup"][hkey], "locked", not MtxGetElementData ( houses["pickup"][hkey], "locked" ) )
		if MtxGetElementData ( houses["pickup"][hkey], "locked" ) then fix = "ab" else fix = "auf" end
		outputChatBox ( "Haustuer "..fix.."geschlossen!", player, 0, 125, 0 )
	else
		outputChatBox ( "Dir gehoert kein Haus!", player, 125, 0, 0 )
	end
end
addCommandHandler ( "hlock", hlock_func )

function houseClickServer_func ( player, cmd, amount )
	playSoundFrontEnd ( player, 20 )
	if cmd == "eat" then
		setPedAnimation ( player, "food", "EAT_Burger", 1, true, false, true )
		setTimer ( setPedAnimation, 1200, 1, player )
		setTimer ( setElementHunger, 1200, 1, player, 100 )
	elseif cmd == "heal" then
		setElementHealth ( player, 100 )
	elseif cmd == "take" or cmd == "give" then
		if amount then
			amount = math.abs(math.floor(amount))
			if getElementDimension ( player ) == MtxGetElementData ( player, "housekey" ) then
				local houseAmount = tonumber ( (dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Kasse", "houses", "ID", MtxGetElementData ( player, "housekey" ) ))[1]["Kasse"] )
				if cmd == "take" then
					if houseAmount >= amount then
						givePlayerSaveMoney ( player, amount )
						dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "houses", "Kasse",  houseAmount - amount, "ID", MtxGetElementData ( player, "housekey" ) )
						triggerClientEvent ( "showHouseGui", player, houseAmount - amount )
					else
						outputChatBox ( "Du hast nicht genug Geld in deiner Hauskasse!", player, 125, 0, 0 )
					end
				elseif cmd == "give" then
					if MtxGetElementData ( player, "money" ) >= amount then
						takePlayerSaveMoney ( player, amount )
						dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "houses", "Kasse",  houseAmount + amount, "ID", MtxGetElementData ( player, "housekey" ) )
						triggerClientEvent ( "showHouseGui", player, houseAmount + amount )
					else
						outputChatBox ( "Du hast nicht genug Geld!", player, 125, 0, 0 )
					end
				end
			else
				outputChatBox ( "Du bist nicht befugt!", player, 125, 0, 0 )
			end
		else
			outputChatBox ( "Ungültiger Wert!", player, 125, 0, 0 )
		end
	end
end
addEvent ( "houseClickServer", true )
addEventHandler ( "houseClickServer", getRootElement(), function ( player, cmd, amount ) runAsync ( houseClickServer_func, player, cmd, amount ) end )


addCommandHandler ( "garage", function ( player )
	local id = MtxGetElementData ( player, "housekey" )
	if id then
		local x, y, z = getElementPosition ( player )
		
		-- Bahnhof-Haus --
		if id == 110 then
			-- Nord-Garage --
			if getDistanceBetweenPoints3D ( x, y, z, -2039.28625, 178.75263, 28.84 ) <= 10 then
				setGarageOpen ( 22, not isGarageOpen ( 22 ) )
			-- Süd-Garage --
			elseif getDistanceBetweenPoints3D ( x, y, z, -2026.6065674, 129.412, 28.9 ) <= 10 then
				setGarageOpen ( 21, not isGarageOpen ( 21 ) )
			end
		end
	end
end )


function excuteHLock(player)
	if player ~= client then return end
	executeCommandHandler("hlock",player)
end
addEvent("onHouseSetState",true)
addEventHandler("onHouseSetState",root,excuteHLock)

function excuteEnter(player)
	if player ~= client then return end
	executeCommandHandler("in",player)
end
addEvent("onHouseEnter",true)
addEventHandler("onHouseEnter",root,excuteEnter)

function excuteLeave(player)
	if player ~= client then return end
	executeCommandHandler("out",player)
end
addEvent("onHouseLeave",true)
addEventHandler("onHouseLeave",root,excuteLeave)

function sellHouseExcute(player)
	if player ~= client then return end
	executeCommandHandler("sellhouse",player)
end
addEvent("onHouseSellGUI",true)
addEventHandler("onHouseSellGUI",root,sellHouseExcute)

function excuteRent(player,rent)
	if player ~= client then return end
	executeCommandHandler("setrent",player,rent)
end
addEvent("onHouseSetRent",true)
addEventHandler("onHouseSetRent",root,excuteRent)

function houseBuyGUI(player,zahlart)
	if player ~= client then return end
	executeCommandHandler("buyhouse",player,zahlart)
end
addEvent("onHouseBuyGUI",true)
addEventHandler("onHouseBuyGUI",root,houseBuyGUI)