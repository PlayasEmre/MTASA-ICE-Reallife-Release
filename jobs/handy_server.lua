--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function handychange_func ( player )

	if player == client then
		if MtxGetElementData ( player, "handystate" ) == "on" then
			MtxSetElementData ( player, "handystate", "off" )
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nHandy ausgeschaltet!", 5000, 0, 200, 0 )
		else
			MtxSetElementData ( player, "handystate", "on" )
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nHandy angeschaltet!", 5000, 0, 200, 0 )
		end
	end
end
addEvent ( "handychange", true )
addEventHandler ( "handychange", getRootElement(), handychange_func )


function smscmd_func ( player, cmd, number, ... )

	if number then
		local parametersTable = {...}
		local sendtext = table.concat( parametersTable, " " )
		if sendtext then
			if #sendtext >= 1 then
				SMS_func ( player, tonumber(number), sendtext )
			else
				outputChatBox ( "Bitte gib einen Text ein!", player, 125, 0, 0 )
			end
		else
			outputChatBox ( "Bitte gib einen Text ein!", player, 125, 0, 0 )
		end
	else
		outputChatBox ( "Bitte gib eine gueltige Nummer an!", player, 125, 0, 0 )
	end
end
addCommandHandler ( "sms", smscmd_func )

function callcmd_func ( player, cmd, number )

	callSomeone_func ( player, number )
end
addCommandHandler ( "call", callcmd_func )

function SMS_func ( player, sendnr, sendtext )

	if player == client or not client then
		if MtxGetElementData ( player, "handystate" ) == "on" then
			-- "pmoney" wurde hier geholt und nie benutzt.
			if ( MtxGetElementData ( player, "handyType" ) == 2 and MtxGetElementData ( player, "handyCosts" ) >= smsprice ) or MtxGetElementData ( player, "handyType" ) ~= 2 then
				local players = getElementsByType("player")
				for i=1, #players do
					local playeritem = players[i]
					local telenr = MtxGetElementData ( playeritem, "telenr" )
					if telenr then
						if telenr == sendnr then
							if MtxGetElementData ( playeritem, "handystate" ) == "on" then
								triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nSMS versendet!", 5000, 0, 200, 0 )
								playSoundFrontEnd ( player, 40 )
								triggerClientEvent ( playeritem, "phonesms", player )
								outputChatBox ( "SMS von "..getPlayerName(player).."("..MtxGetElementData(player,"telenr").."): "..sendtext, playeritem, 255, 255, 0 )
								if MtxGetElementData ( player, "handyType" ) == 2 then
									MtxSetElementData ( player, "handyCosts", MtxGetElementData ( player, "handyCosts" ) - smsprice )
								elseif MtxGetElementData ( player, "handyType" ) == 1 then
									MtxSetElementData ( player, "handyCosts", MtxGetElementData ( player, "handyCosts" ) + smsprice )
								end
								return
							end
						end
					end
				end
				triggerClientEvent ( player, "infobox_start", getRootElement(), "Das Handy des\nSpielers ist ausge-\nschaltet oder der\nSpieler ist nicht\nonline!", 7500, 125, 0, 0 )
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "Du hast nicht\nmehr genug Guthaben!\nDu kannst im 24-7\ndein Guthaben\naufladen.", 5000, 125, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDein Handy ist\naus!", 5000, 125, 0, 0 )
		end
	end
end
addEvent ( "SMS", true )
addEventHandler ( "SMS", getRootElement(), SMS_func )

function callSomeone_func ( player, number )

	if player == client or not client then
		if MtxGetElementData ( player, "handystate" ) == "on" then
			-- "pmoney" wurde hier geholt und nie benutzt.
			if number == "*100#" then
				if MtxGetElementData ( player, "handyType" ) == 2 then
					outputChatBox ( "Aktuelles Guthaben: "..MtxGetElementData ( player, "handyCosts" ).." "..Tables.waehrung.."", player, 200, 200, 0 )
				elseif MtxGetElementData ( player, "handyType" ) == 3 then
					outputChatBox ( "Du hast eine Flatrate, Kosten pro Stunde: 50 "..Tables.waehrung.."", player, 200, 200, 0 )
				elseif MtxGetElementData ( player, "handyType" ) == 1 then
					outputChatBox ( "Aktuelle Kosten: "..MtxGetElementData ( player, "handyCosts" ).." "..Tables.waehrung.."", player, 200, 200, 0 )
				end
			elseif not speznr[tonumber(number)] then
				number = tonumber ( number )
				if ( MtxGetElementData ( player, "handyType" ) == 2 and MtxGetElementData ( player, "handyCosts" ) >= callprice ) or MtxGetElementData ( player, "handyType" ) ~= 2 then
					local players = getElementsByType("player")
					for i=1, #players do
						local playeritem = players[i]
						local telenr = MtxGetElementData ( playeritem, "telenr" )
						if telenr then
							if telenr == number then
								if MtxGetElementData ( playeritem, "handystate" ) == "on" then
									if not MtxGetElementData ( player, "call" ) then
										if not MtxGetElementData ( playeritem, "call" ) then
											outputChatBox ( "Tippe /hangup ( /hup ), um aufzulegen!", player, 200, 200, 200 )
											outputChatBox ( getPlayerName(player).." (Nummer: "..MtxGetElementData(player,"telenr")..") ruft an, tippe /pickup ( /pup ) um abzunehmen!", playeritem, 50, 125, 0 )
											MtxSetElementData ( player, "calls", playeritem )
											MtxSetElementData ( player, "call", true )
											MtxSetElementData ( playeritem, "calledby", player )
											triggerClientEvent ( player, "phonewartezeichen", player )
											triggerClientEvent ( playeritem, "phonesound", player )
											if MtxGetElementData ( player, "handyType" ) == 2 then
												MtxSetElementData ( player, "handyCosts", MtxGetElementData ( player, "handyCosts" ) - callprice )
											elseif MtxGetElementData ( player, "handyType" ) == 1 then
												MtxSetElementData ( player, "handyCosts", MtxGetElementData ( player, "handyCosts" ) + callprice )
											end
											return
										else
											outputChatBox ( "Besetzt...", player, 125, 0, 0 )
											triggerClientEvent ( player, "phonesound", player )
										end
									else
										outputChatBox ( "Du telefonierst bereits!", player, 125, 0, 0 )
									end
								else
									outputChatBox ( "Handy ist ausgeschaltet!", player, 125, 0, 0 )
								end
								return
							end
						end
					end
					triggerClientEvent ( player, "infobox_start", getRootElement(), "Das Handy des\nSpielers ist ausge-\nschaltet oder der\nSpieler ist nicht\nonline!", 7500, 125, 0, 0 )
					triggerClientEvent ( player, "phonekeinanschluss", player )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "Du hast nicht\ngenug Geld!\nEin Anruf kostet\n"..callprice.." "..Tables.waehrung.."!", 7500, 125, 0, 0 )
				end
			else
				--speznr = { [110]=true, [112]=true, [300]=true, [400]=true }
				number = tonumber ( number )
				if number == 110 then
					outputChatBox ( "Sie sprechen mit der Polizei von San Fierro - bitte nennen Sie den Namen des Täters.", player, 0, 0, 125 )
					MtxSetElementData ( player, "callswithpolice", true )
				elseif number == 112 then
					if getFactionMembersOnline(10) > 0 then
						outputChatBox ( "Sie sprechen mit dem Krankenhaus von San Fierro - bitte nennen Sie uns ihr Anliegen.", player, 0, 0, 125 )
						MtxSetElementData ( player, "callswithmedic", true )
					else
						outputChatBox ( "Tut uns Leid, jedoch sind alle Sanitäter anderweitig beschäftigt.", player, 0, 0, 125 )
					end
				elseif number == 300 then
					if getFactionMembersOnline(11) > 0 then
						outputChatBox ( "Sie sprechen mit dem Mechanikerzentrum von San Fierro - bitte nennen Sie uns ihr Anliegen.", player, 0, 0, 125 )
						MtxSetElementData ( player, "callswithmechaniker", true )
					else
						outputChatBox ( "Tut uns Leid, jedoch sind alle Mechaniker anderweitig beschäftigt.", player, 0, 0, 125 )
					end
				end
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDein Handy ist\naus!", 7500, 125, 0, 0 )
		end
	end
end
addEvent ( "callSomeone", true )
addEventHandler ( "callSomeone", getRootElement(), callSomeone_func )

function hangup ( player )
	if isElement ( MtxGetElementData ( player, "callswith" ) ) then
		local caller = MtxGetElementData ( player, "callswith" )
		MtxSetElementData ( caller, "call", false )
		MtxSetElementData ( caller, "callswith", "none" )
		MtxSetElementData ( caller, "calledby", "none" )
		MtxSetElementData ( caller, "calls", "none" )
		outputChatBox ( "Aufgelegt.", caller, 200, 200, 200 )
		triggerClientEvent ( caller, "stopphonesound", caller )
	elseif isElement ( MtxGetElementData ( player, "calledby" ) ) then
		local caller = MtxGetElementData ( player, "calledby" )
		MtxSetElementData ( caller, "call", false )
		MtxSetElementData ( caller, "callswith", "none" )
		MtxSetElementData ( caller, "calledby", "none" )
		MtxSetElementData ( caller, "calls", "none" )
		triggerClientEvent ( caller, "stopphonesound", caller )
		outputChatBox ( "Aufgelegt.", caller, 200, 200, 200 )
	end
	MtxSetElementData ( player, "call", false )
	MtxSetElementData ( player, "callswith", "none" )
	MtxSetElementData ( player, "calledby", "none" )
	MtxSetElementData ( player, "calls", "none" )
	outputChatBox ( "Aufgelegt.", player, 200, 200, 200 )
	triggerClientEvent ( player, "stopphonesound", player )
end
addCommandHandler ( "hangup", hangup )
addCommandHandler ( "hup", hangup )


function pickup ( player )

	local caller = MtxGetElementData ( player, "calledby" )
	MtxSetElementData ( player, "calledby", "none" )
	if isElement ( caller ) then
		MtxSetElementData ( player, "call", true )
		MtxSetElementData ( caller, "call", true )
		MtxSetElementData ( player, "callswith", caller )
		MtxSetElementData ( caller, "callswith", player )
		MtxSetElementData ( player, "calledby", "none" )
		MtxSetElementData ( caller, "calledby", "none" )
		MtxSetElementData ( player, "calls", "none" )
		MtxSetElementData ( caller, "calls", "none" )
		triggerClientEvent ( player, "stopphonesound", player )
		triggerClientEvent ( caller, "stopphonesound", caller )
		outputChatBox ( "Abgehoben.", player, 0, 125, 0 )
		outputChatBox ( "Abgehoben.", caller, 0, 125, 0 )
	else
		outputChatBox ( "Du kannst keinen Anruf annehmen!", player, 125, 0, 0 )
	end
end
addCommandHandler ( "pickup", pickup )
addCommandHandler ( "pup", pickup )