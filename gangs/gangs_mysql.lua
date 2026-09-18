--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

addEvent ( "onVioPlayerLogin", true )

gangData = {}
	gangData["ranks"] = {}

local function gangHaus ( id )
	local haus = _G["HouseNR"..tostring ( id )]
	if isElement ( haus ) then
		return haus
	end
	return nil
end

function loadGangData ( gangID )
	local house = houses["pickup"] and houses["pickup"][gangID]
	local gangDataResult = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "LeaderMSG", "gang_basic", "HausID", gangID )

	if gangDataResult and gangDataResult[1] then
		gangData[gangID] = {
			["members"] = { ["online"] = {} },
			["msg"] = gangDataResult[1]["LeaderMSG"]
		}
		refreshGangRanks ( gangID )
		if isElement ( house ) then
			MtxSetElementData ( house, "gangHQOf", getGangName ( gangID ) )
		end
		return nil
	end

	if isElement ( house ) then
		MtxSetElementData ( house, "gangHQOf", false )
	end
end

function getMembersInGangCount ( id )
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Gang", "gang_members", "Gang", id )
	return result and #result or 0
end

function getGangMembersString ( id )
	local strings = ";"
	local result = dbQueryCoro ( "SELECT ??, ?? FROM ?? WHERE ??=?", "UID", "Rang", "gang_members", "Gang", id )
	local amount = 0
	if result then
		for i = 1, #result do
			local name = playerUIDName[tonumber(result[i]["UID"])]
			if name then
				amount = amount + 1
				strings = strings..name.."|"..tostring ( result[i]["Rang"] )..";"
			end
		end
	end
	return strings, amount
end

function refreshGangRanks ( gangID )
	if not gangData[gangID] then
		return
	end

	local result = dbQueryCoro ( "SELECT ??, ??, ?? FROM ?? WHERE ??=?", "Rang1", "Rang2", "Rang3", "gang_basic", "HausID", gangID )
	if result and result[1] and gangData[gangID] then
		gangData[gangID]["ranks"] = {
			[1] = result[1]["Rang1"],
			[2] = result[1]["Rang2"],
			[3] = result[1]["Rang3"]
		}
	end
end

function setGangMSG ( id, msg )
	dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "gang_basic", "LeaderMSG", msg, "HausID", id )
	if gangData[id] then
		gangData[id]["msg"] = msg
	end
end

function getGangMSG ( id )
	if gangData[id] then
		return gangData[id]["msg"]
	end
	return ""
end

function isFounderOfGang ( player, gangFounderID )
	if not isElement ( player ) and type ( player ) == "string" then
		local gefunden = getPlayerFromName ( player )
		if gefunden then
			player = gefunden
		end
	end

	if isElement ( player ) then
		local rank = getPlayerGangRank ( player ) or 0
		if not isElement ( player ) then
			return false
		end
		local housekey = MtxGetElementData ( player, "housekey" )
		if gangFounderID then
			return rank >= 3 and gangFounderID == housekey
		end
		return rank >= 3 and getPlayerGang ( player ) == housekey
	end

	if type ( player ) ~= "string" or not playerUID[player] then
		return false
	end

	local result
	if gangFounderID then
		result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=? AND ??=? AND ??=?", "Founder", "gang_members", "UID", playerUID[player], "Gang", gangFounderID, "Founder", "1" )
	else
		result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=? AND ??=?", "Founder", "gang_members", "UID", playerUID[player], "Founder", "1" )
	end

	return ( result and result[1] ) and true or false
end

function refreshPlayerGangData ( player )
	if not isElement ( player ) then return end

	local gang = getPlayerGang ( getPlayerName ( player ) )
	if not isElement ( player ) then return end

	if gang and gang > 0 and isGang ( gang ) then
		local name = getGangName ( gang )
		if isElement ( player ) then
			MtxSetElementData ( player, "gangname", name or "-" )
		end
	else
		MtxSetElementData ( player, "gangname", "-" )
	end
end

function playerLoginGangMembers ( player )
	local pname = getPlayerName ( player )
	local result = dbQueryCoro ( "SELECT ??, ?? FROM ?? WHERE ??=?", "Rang", "Gang", "gang_members", "UID", playerUID[pname] )
	if not isElement ( player ) then return end

	if result and result[1] then
		local gang = tonumber ( result[1]["Gang"] )
		gangData["ranks"][player] = tonumber ( result[1]["Rang"] )
		if gang and isGang ( gang ) then
			gangData[gang]["members"]["online"][player] = true
		else
			outputDebugString ( "[Gangs] "..pname.." haengt an Gang "..tostring ( gang )..", die es nicht mehr gibt.", 2 )
		end
	end
	refreshPlayerGangData ( player )
end

function isGang ( id )
	return ( id and gangData[id] ) and true or false
end

function playerDisconnectGangMembers ( player )
	if not gangData["ranks"][player] then
		return
	end

	for id, daten in pairs ( gangData ) do
		if id ~= "ranks" and type ( daten ) == "table" and daten["members"] then
			daten["members"]["online"][player] = nil
		end
	end

	gangData["ranks"][player] = nil
end

function getGangMaxMembers ( id )
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "MaxMembers", "gang_basic", "HausID", id )
	if result and result[1] then
		return tonumber ( result[1]["MaxMembers"] ) or 0
	end
	return 0
end

function getGangMoney ( id )
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Kasse", "houses", "ID", id )
	if result and result[1] then
		return tonumber ( result[1]["Kasse"] ) or 0
	end
	return 0
end

function setGangMoney ( id, amount )
	dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "houses", "Kasse", amount, "ID", id )
end

function gangVehicleCost ( id )
	return 0
end

function getGangMats ( id )
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Mats", "gang_basic", "HausID", id )
	if result and result[1] then
		return tonumber ( result[1]["Mats"] ) or 0
	end
	return 0
end

function setGangMats ( id, amount )
	dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "gang_basic", "Mats", amount, "HausID", id )
end

function getGangDrugs ( id )
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Drugs", "gang_basic", "HausID", id )
	if result and result[1] then
		return tonumber ( result[1]["Drugs"] ) or 0
	end
	return 0
end

function setGangDrugs ( id, amount )
	dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "gang_basic", "Drugs", amount, "HausID", id )
end

function getGangVehicleCost ( id )
	return 999
end

function getGangName ( id )
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Name", "gang_basic", "HausID", id )
	if result and result[1] then
		return result[1]["Name"]
	end
	return false
end

function removePlayerFromGang ( pname )
	if isElement ( pname ) then
		pname = getPlayerName ( pname )
	end
	if not playerUID[pname] then
		return
	end

	local player = getPlayerFromName ( pname )
	if player then
		local gang = getPlayerGang ( pname )
		if gang and gang > 0 and isGang ( gang ) then
			gangData[gang]["members"]["online"][player] = nil
		end
		gangData["ranks"][player] = nil
	end

	dbExec ( handler, "DELETE FROM ?? WHERE ??=?", "gang_members", "UID", playerUID[pname] )

	if isElement ( player ) then
		MtxSetElementData ( player, "gangname", "-" )
	end
end

function getPlayerGang ( pname )
	local pname = isElement ( pname ) and getPlayerName ( pname ) or pname
	if type ( pname ) ~= "string" or not playerUID[pname] then
		return false
	end
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Gang", "gang_members", "UID", playerUID[pname] )
	if result and result[1] then
		return tonumber ( result[1]["Gang"] )
	end
	return false
end

function isInGang ( pname, id )
	pname = isElement ( pname ) and getPlayerName ( pname ) or pname
	if type ( pname ) ~= "string" or not playerUID[pname] then
		return false
	end

	local result
	if not id then
		result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "UID", "gang_members", "UID", playerUID[pname] )
	else
		result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=? AND ??=?", "UID", "gang_members", "UID", playerUID[pname], "Gang", id )
	end

	return ( result and result[1] ) and true or false
end

function getPlayerGangRank ( player )
	if isElement ( player ) then
		return gangData["ranks"][player] or 0
	elseif type ( player ) == "string" and playerUID[player] then
		local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Rang", "gang_members", "UID", playerUID[player] )
		if result and result[1] then
			return tonumber ( result[1]["Rang"] ) or 0
		end
	end
	return 0
end

function setPlayerGangRank ( pname, newRank )
	if isElement ( pname ) then
		pname = getPlayerName ( pname )
	end

	newRank = tonumber ( newRank )
	if not newRank or newRank < 1 or newRank > 3 or not playerUID[pname] then
		return false
	end
	newRank = math.floor ( newRank )

	dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "gang_members", "Rang", newRank, "UID", playerUID[pname] )

	local player = getPlayerFromName ( pname )
	if player then
		gangData["ranks"][player] = newRank
		infobox_start_func ( "Dir wurde Rang\n"..newRank.." zugewiesen.", player, 125, 0, 0 )
	end
	return true
end

function getGangRankName ( id, rank )
	if gangData[id] and gangData[id]["ranks"] then
		return gangData[id]["ranks"][rank]
	end
	return "Rang "..tostring ( rank )
end

function setGangRankName ( id, rank, strings )
	if gangData[id] and gangData[id]["ranks"] then
		gangData[id]["ranks"][rank] = strings
	end
	dbExec ( handler, "UPDATE ?? SET ?? = ? WHERE ??=?", "gang_basic", "Rang"..rank, strings, "HausID", id )
	refreshGangRanks ( id )
end

function insertInGang ( pname, id, rank, founder )
	if not rank then
		rank = 1
	end
	if isElement ( pname ) then
		pname = getPlayerName ( pname )
	end
	if not playerUID[pname] then
		return false
	end

	local player = getPlayerFromName ( pname )
	if player and isGang ( id ) then
		gangData[id]["members"]["online"][player] = true
		gangData["ranks"][player] = rank
	end

	dbExec ( handler, "INSERT INTO ?? ( ??, ??, ?? ) VALUES (?,?,?)", "gang_members", "UID", "Gang", "Rang", playerUID[pname], id, rank )

	if founder then
		dbExec ( handler, "UPDATE ?? SET ?? = ? WHERE ??=?", "gang_members", "Founder", "1", "UID", playerUID[pname] )
	end

	local name = getGangName ( id )
	if isElement ( player ) then
		MtxSetElementData ( player, "gangname", name or "-" )
	end
	return true
end

function getPlayerRankNameInGang ( player )
	local gang = getPlayerGang ( player )
	if not gang or not gangData[gang] or not gangData[gang]["ranks"] then
		return "-"
	end
	return gangData[gang]["ranks"][getPlayerRankInGang ( player )] or "-"
end

function getPlayerRankInGang ( pname )
	local pname = isElement ( pname ) and getPlayerName ( pname ) or pname
	if type ( pname ) ~= "string" or not playerUID[pname] then
		return false
	end
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Rang", "gang_members", "UID", playerUID[pname] )
	if result and result[1] then
		return tonumber ( result[1]["Rang"] )
	end
	return false
end

function sendMessageToGangMembers ( id, msg )
	if not gangData[id] or not gangData[id]["members"] then
		return
	end
	for key in pairs ( gangData[id]["members"]["online"] ) do
		if isElement ( key ) then
			outputChatBox ( msg, key, 200, 200, 0 )
		end
	end
end

function createNewGang ( name, leaderSkin, houseID )
	dbExec ( handler, "INSERT INTO ?? ( ??, ??, ??, ?? ) VALUES (?,?,?,?)", "gang_basic", "Name", "LeaderMSG", "HausID", "Skin", name, "Gang wurde gegruendet.", houseID, leaderSkin or 7 )
	loadGangData ( houseID )
end

function getGangFromName ( name )
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ?? LIKE ?", "HausID", "gang_basic", "Name", name )
	if result and result[1] then
		return tonumber ( result[1]["HausID"] )
	end
	return false
end

function setGangName ( id, name )
	dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "gang_basic", "Name", name, "HausID", id )

	local haus = gangHaus ( id )
	if haus then
		MtxSetElementData ( haus, "gangHQOf", name )
	end

	if gangData[id] and gangData[id]["members"] then
		for key in pairs ( gangData[id]["members"]["online"] ) do
			if isElement ( key ) then
				MtxSetElementData ( key, "gangname", name )
			end
		end
	end
end

function deleteGang ( id )
	sendMessageToGangMembers ( id, "Deine Gang wurde aufgeloest." )

	dbExec ( handler, "DELETE FROM ?? WHERE ??=?", "gang_basic", "HausID", id )
	dbExec ( handler, "DELETE FROM ?? WHERE ??=?", "gang_members", "Gang", id )
	dbExec ( handler, "DELETE FROM ?? WHERE ??=?", "gang_vehicles", "GangID", id )

	if gangData[id] and gangData[id]["members"] then
		for key in pairs ( gangData[id]["members"]["online"] ) do
			if isElement ( key ) then
				gangData["ranks"][key] = nil
				MtxSetElementData ( key, "gangname", "-" )
			end
		end
	end

	gangData[id] = nil

	local haus = gangHaus ( id )
	if haus then
		MtxSetElementData ( haus, "gangHQOf", false )
	end
end
