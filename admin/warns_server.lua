--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function getPlayerWarns ( name ) 
	local result = dbQueryCoro ( "SELECT adminUID, reason, time, date FROM warns WHERE UID = ?", playerUID[name] )
	if result then
		local count = #result
		if count > 0 then
			local array = {}
			for i = 1, count do
			
				array[i] = { ["adminUID"] = result[i]["adminUID"], ["date"] = result[i]["date"], ["reason"] = result[i]["reason"], ["time"] = result[i]["time"] }
				
			end
			return array
		end
		return 0
	end
	return 0
end

function getPlayerWarnCount ( name )
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "UID", "warns", "UID", playerUID[name] )
	local count = 0
	if result and result[1] then
		count = #result
	end
	return count
end

function checkExpiredWarns ( player )
	local pname = getPlayerName ( player )
    local result = dbQueryCoro ( "SELECT ??, ??, ??, ?? FROM ?? WHERE ??=? ", "time", "adminUID", "id", "date", "warns", "UID", playerUID[pname] )
    local rt = getRealTime ()
    local timesamp = rt.timestamp

    if result and result[1] then
        local warntime = tonumber( result[1]["time"] )
        if warntime < timesamp then
            outputChatBox ( "Die Verwarnung vom "..getData(result[1]["date"]).." von "..playerUIDName[result[1]["adminUID"]].." ist abgelaufen. ID: "..result[1]["id"], player, 255, 0, 0 )
            dbExec ( handler, "DELETE FROM ?? WHERE ??=?", "warns", "id", result[1]["id"] )
            outputDebugString("[WARNSYSTEM] Der Warn von "..pname.." ist abgelaufen.")
			outputLog ( "Der Warn von "..pname.." ist abgelaufen.", "warn" )
			checkExpiredWarns ( player )
        end
	end
end

function getLowestWarnExtensionTime ( name )
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=? ORDER BY time ASC LIMIT 1", "time", "warns", "UID", playerUID[name] )
	if result and result[1] then
		return getData(result[1]["time"])
	end
	return false
end

function outputPlayerWarns ( name, reader )
	local array = getPlayerWarns ( name ) 
	local count = type ( array ) == "number" and 0 or #array
	outputChatBox ( "Warns: "..count, reader, 200, 200, 0 )
	if count > 0 then
		for i = 1, count do
			outputChatBox ( "Warn "..i..":", reader, 255, 0, 0 )
			outputChatBox ( "Von: "..playerUIDName[array[i].adminUID].." ( "..getData(array[i].date).." ), Grund: "..array[i].reason, reader, 255, 0, 0 )
			outputChatBox ( "Ablaufdatum: "..getData(array[i].time), reader, 255, 0, 0 )
		end
	end
end

addCommandHandler ( "warns", function ( player )
	runAsync ( function ()
		outputPlayerWarns ( getPlayerName ( player ), player )
	end )
end )

addCommandHandler ( "checkwarns", function ( player, cmd, name )
	if not isAdminLevel ( player, 1 ) then return end
	runAsync ( function ()
		outputPlayerWarns ( name, player )
	end )
end )

addEvent ( "checkwarns", true )
addEventHandler ( "checkwarns", root, function ( name )
	local reader = client
	if not isAdminLevel ( reader, 1 ) then return end
	runAsync ( function ()
		outputPlayerWarns ( name, reader )
	end )
end )


function banForThreeWarns ( name, admin, reason, suspect )
	local serial = ""
	if isElement ( suspect ) then
		serial = getPlayerSerial ( suspect )
	else
		local serialresult = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Serial", "players", "UID", playerUID[name] )
		if serialresult and serialresult[1] then
			serial = serialresult[1]["Serial"]
		end
	end
	dbExec ( handler, "INSERT INTO ?? (??, ??, ??, ??, ??, ??) VALUES (?,?,?,?,?,?) ON DUPLICATE KEY UPDATE AdminUID=VALUES(AdminUID), Grund=VALUES(Grund), Datum=VALUES(Datum), IP=VALUES(IP), Serial=VALUES(Serial), STime=0", "ban", "UID", "AdminUID", "Grund", "Datum", "IP", "Serial", playerUID[name], playerUID[admin], string.sub ( "3 Verwarnungen: "..reason, 1, 100 ), timestamp(), '0.0.0.0', serial )
	dbExec ( handler, "DELETE FROM ?? WHERE ??=?", "warns", "UID", playerUID[name] )
	outputLog ( name.." wurde nach 3 Verwarnungen von "..admin.." permanent gebannt.", "warn" )
end

function warn_func ( player, cmd, name, extends, ... )

	if getElementType ( player ) == "console" or ( tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0 ) >= 1 and ( not client or client == player ) then
		local suspect = findPlayerByName ( name )
		local playerexists = false
		if not suspect then
			if playerUID[name] then
				suspect = name
			end
		end
		if suspect then
			local reason = {...}
			reason = table.concat( reason, " " )		
			if extends and tonumber(extends) ~= nil then
				local extends = math.abs ( math.floor ( tonumber ( extends ) ) )
				if extends and extends > 0 then 
					local admin = getPlayerName ( player )
					local rt = getRealTime ()
					local month = rt.month + 1
					local day = rt.monthday
					local year = rt.year+1970
					local timesamp = rt.timestamp
					dbExec ( handler, "INSERT INTO ?? ( ??,??,??,??,??) VALUES (?,?,?,?,?)", "warns", "UID", "adminUID", "reason", "time", "date", playerUID[name], playerUID[admin], reason, timesamp + extends*86400 , timesamp )
					if isElement ( suspect ) then
						MtxSetElementData ( suspect, "warns", MtxGetElementData ( suspect, "warns" ) + 1 )
						if getPlayerWarnCount ( name ) >= 3 then
							banForThreeWarns ( name, admin, reason, suspect )
							kickPlayer ( suspect, "Von: "..admin..", Grund: "..reason.." (Gebannt, 3 Verwarnungen)" )
						else
							if extends == 1 then
								praefix = "Tag"
							else
								praefix = "Tage"
							end
							outputChatBox ( "Du wurdest von "..admin.." verwarnt! Grund: "..reason..", Ablaufzeit: "..extends.." "..praefix.."!", suspect, 255, 0, 0 )
							outputChatBox ( "Beim dritten Warn wirst du automatisch gebannt. Tippe /warns, um deine Verwarnungen einzusehen.", suspect, 255, 0, 0 )
						end
					else
						if getPlayerWarnCount ( name ) >= 3 then
							banForThreeWarns ( name, admin, reason, suspect )
						end
						offlinemsg ( "Du wurdest von "..admin.." verwarnt; Grund: "..reason, "Server", name )
					end
					outputChatBox ( "Du hast "..name.." verwarnt!", player, 0, 200, 0 )
				else
					infobox ( player, "Gebrauch:\n/warn [Name]\n[1-365]\n[Grund]", 5000, 125, 0, 0 )
				end
			else
				infobox ( player, "Gebrauch:\n/warn [Name]\n[Dauer in Tagen]\n[Grund]", 5000, 125, 0, 0 )
			end
		else
			infobox ( player, "Der Spieler\nexistiert nicht!", 5000, 125, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "Du bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )
	end
end
addCommandHandler ( "warn", function ( player, cmd, name, extends, ... ) runAsync ( warn_func, player, cmd, name, extends, ... ) end )

addEvent ( "warn", true )
addEventHandler ( "warn", getRootElement(),
	function ( name, extends, reason )
		local theClient = client
		runAsync ( function ()
			warn_func ( theClient, "warn", name, extends, reason )
		end )
	end
)

function deletewarn_func ( player, cmd, target )
    if ( tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0 ) >= 3 then
		if target and playerUID[target] then
			local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "UID", "warns", "UID", playerUID[target] )
			if result and result[1] then
				dbExec ( handler, "DELETE FROM ?? WHERE ??=?", "warns", "UID", playerUID[target] )
				outputChatBox ( "Die Warns von "..target.." wurde erfolgreich gelöscht", player, 0, 125, 0 )
				outputAdminLog ( getPlayerName ( player ).." hat die Warns von "..target.." gelöscht." )
				local targetpl = getPlayerFromName ( target )
				if isElement ( targetpl ) then
					MtxSetElementData ( targetpl, "warns", 0 )
				end
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "Gebrauch:\n/deletewarn NAME", 5000, 255, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "Du bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )
    end
end
addCommandHandler ( "deletewarn", function ( player, cmd, target ) runAsync ( deletewarn_func, player, cmd, target ) end )