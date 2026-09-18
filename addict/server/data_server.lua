--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function loadAddictionsForPlayer ( player )

	local pname = getPlayerName ( player )
	local result = dbQueryCoro ( "SELECT ??, ?? FROM ?? WHERE ??=?", "Rausch", "Sucht", "userdata", "UID", playerUID[pname] )
	if result and result[1] then
		local dataString1 = result[1]["Rausch"]
		local dataString2 = result[1]["Sucht"]
		
		local cigarettFlushPoints = tonumber ( gettok ( dataString1, 1, string.byte ( '|' ) ) ) or 0
		local alcoholFlushPoints = tonumber ( gettok ( dataString1, 2, string.byte ( '|' ) ) ) or 0
		local drugFlushPoints = tonumber ( gettok ( dataString1, 3, string.byte ( '|' ) ) ) or 0

		local cigarettAddictPoints = tonumber ( gettok ( dataString2, 1, string.byte ( '|' ) ) ) or 0
		local alcoholAddictPoints = tonumber ( gettok ( dataString2, 2, string.byte ( '|' ) ) ) or 0
		local drugAddictPoints = tonumber ( gettok ( dataString2, 3, string.byte ( '|' ) ) ) or 0
		
		MtxSetElementData ( player, "cigarettFlushPoints", cigarettFlushPoints )
		MtxSetElementData ( player, "alcoholFlushPoints", alcoholFlushPoints )
		MtxSetElementData ( player, "drugFlushPoints", drugFlushPoints )

		MtxSetElementData ( player, "cigarettAddictPoints", cigarettAddictPoints )
		MtxSetElementData ( player, "alcoholAddictPoints", alcoholAddictPoints )
		MtxSetElementData ( player, "drugAddictPoints", drugAddictPoints )
	end
end

function saveAddictionsForPlayer ( player )

	local pname = getPlayerName ( player )
	
	local dataString1 = tostring ( MtxGetElementData ( player, "cigarettFlushPoints" ) or 0 ).."|"..tostring ( MtxGetElementData ( player, "alcoholFlushPoints" ) or 0 ).."|"..tostring ( MtxGetElementData ( player, "drugFlushPoints" ) or 0 ).."|"
	local dataString2 = tostring ( MtxGetElementData ( player, "cigarettAddictPoints" ) or 0 ).."|"..tostring ( MtxGetElementData ( player, "alcoholAddictPoints" ) or 0 ).."|"..tostring ( MtxGetElementData ( player, "drugAddictPoints" ) or 0 ).."|"
	
	dbExec ( handler, "UPDATE ?? SET ??=?, ??=? WHERE ??=?", "userdata", "Rausch", dataString1, "Sucht", dataString2, "UID", playerUID[pname] )
end