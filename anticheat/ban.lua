--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function banVioPlayer ( player, reason )

	if client then
		if player == client then
			if reason ~= "Event-Faking" and reason ~= "EventFaking" and reason ~= "Event Faking" then
				local pname = getPlayerName(player)
				outputChatBox ( pname.." wurde vom Anticheatsystem gebannt.", getRootElement(), 255, 0, 0 )
				local ip = getPlayerIP ( player )
				local serial = getPlayerSerial ( player )
				dbExec ( handler, "INSERT INTO ?? (??, ??, ??, ??, ??, ??) VALUES (?,?,?,?,?,?)", "ban", "UID", "AdminUID", "Grund", "Datum", "IP", "Serial", playerUID[pname], 0, reason, timestamp(), ip, serial )
				kickPlayer ( player, "Vom Anticheat gebannt!" )
			end
		end
	end
end

function banVioShieldPlayer ( player, reason )

	local pname = getPlayerName(player)
	outputChatBox ( "Spieler "..pname.." wurde vom Anticheatsystem gebannt! ( Grund: "..reason.." )", getRootElement(), 255, 0, 0 )
	
	local ip = getPlayerIP ( player )
	local serial = getPlayerSerial ( player )
	
	dbExec ( handler, "INSERT INTO ?? (??,??,??,??,??,??) VALUES (?,?,?,?,?,?)", "ban", "UID", "AdminUID", "Grund", "Datum", "IP", "Serial", playerUID[pname], 0, reason, timestamp(), ip, serial )
	kickPlayer ( player, "Von: Anticheat, Grund: "..reason.." (Gebannt!)" )
end

function banVioPlayerServer ( player, reason )

	if reason ~= "Event Faking" then
		local pname = getPlayerName(player)
		outputChatBox ( pname.." wurde vom Anticheatsystem gebannt.", getRootElement(), 255, 0, 0 )
		local ip = getPlayerIP ( player )
		local serial = getPlayerSerial ( player )
		dbExec ( handler, "INSERT INTO ?? (??,??,??,??,??,??) VALUES (?,?,?,?,?,?)", "ban", "UID", "AdminUID", "Grund", "Datum", "IP", "Serial", playerUID[pname], 0, reason, timestamp(), ip, serial)
		kickPlayer ( player, "Vom Anticheat gebannt!" )
	end
end

function timebanPlayer ( pname, time, admin, reason )

	local player = findPlayerByName ( pname )
	
	if playerUID[pname] then
	
		local sec = getTBanSecTime ( time )
		local serialresult = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Serial", "players", "UID", playerUID[pname] )
		if not ( serialresult and serialresult[1] ) then
			return false
		end
		local serial = serialresult[1]["Serial"]

		dbExec ( handler, "INSERT INTO ?? (??, ??, ??, ??, ??, ??, ??) VALUES (?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE AdminUID=VALUES(AdminUID), Grund=VALUES(Grund), Datum=VALUES(Datum), IP=VALUES(IP), Serial=VALUES(Serial), STime=VALUES(STime)", "ban", "UID", "AdminUID", "Grund", "Datum", "IP", "Serial", "STime", playerUID[pname], playerUID[admin], reason, timestamp(), '0.0.0.0', serial, sec )
		outputChatBox ("Spieler "..pname.." wurde von "..admin.." fuer "..time.." Stunden gebannt! (Grund: "..tostring(reason)..")",getRootElement(),255,0,0)
		
		if isElement(player) then
	
			kickPlayer ( player, "Du wurdest fuer "..time.." Stunden von "..admin.." gebannt! ( "..reason..")" )
		
		end
		
		return true
		
	end	
	
	return false
	
end

function getTBanSecTime ( duration )

	return getSecTime ( duration )
end