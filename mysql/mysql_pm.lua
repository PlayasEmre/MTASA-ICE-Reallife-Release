--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function pm_func ( player, cmd, target, ... )

	if MtxGetElementData ( player, "adminlvl" ) < 1 then
		outputChatBox ( "PMs sind deaktiviert! Bitte nutze /call, /sms oder schreibe eine E-Mail.", player, 125, 0, 0 )
		return true
	end

	local parametersTable = {...}
	local msg = table.concat( parametersTable, " " ) 
	local money = MtxGetElementData ( player, "money" )
	local pname = getPlayerName ( player )
	if true then
			if target and #msg >= 1 then	
				if getElementData ( getPlayerFromName(target), "loggedin" ) == 1 then
					local msg = "Nachricht von "..pname.."("..timestamp().."): "..msg
					outputChatBox ( "Nachricht wurde gesendet!", player, 0, 125, 0 )
					outputChatBox ( msg, getPlayerFromName(target), 200, 200, 0 )
				else
					if playerUID[target] then
						offlinemsg ( msg, pname, target )
						outputChatBox ( "Der Spieler ist offline - die Nachricht wird später zugestellt!", player, 200, 200, 0 )
					else
						outputChatBox ( "Der Spieler existiert nicht!", player, 125, 0, 0 )
					end
				end
			else
				outputChatBox ( "Gebrauch: /pm [Empfaenger] [Text]", player, 125, 0, 0 )
		end
	end
end
addCommandHandler ( "pm", pm_func )


function checkmsgs ( player )
	local result = dbQueryCoro ( "SELECT * FROM pm WHERE EmpfaengerUID = ?", playerUID[getPlayerName ( player )] )
	if result and result[1] then
		for i=1, #result do
			outputChatBox ( "Nachricht von "..result[i]["Sender"].."("..result[i]["Datum"].."): "..result[i]["Text"], player, 200, 200, 0 )
		end
		dbExec ( handler, "DELETE FROM pm WHERE EmpfaengerUID = ?", playerUID[getPlayerName ( player )] )
	end
end


function takeMSGMoney ( player )
	MtxSetElementData ( player, "money", MtxGetElementData(player,"money")-pm_price )
end



