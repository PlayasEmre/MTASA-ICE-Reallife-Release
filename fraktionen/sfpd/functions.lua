--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function takegunlicenseGUI_func ( pname )

	takegunlicense_func ( client, "takegunlicense", pname )
end
addEvent ( "takegunlicenseGUI", true )
addEventHandler ( "takegunlicenseGUI", getRootElement(), takegunlicenseGUI_func )

function takegunlicense_func ( player, cmd, targetName )

	if ( isCop ( player ) or isFBI ( player ) or isArmy ( player ) ) and MtxGetElementData ( player, "rang" ) >= 4 then
		local target = findPlayerByName( targetName )
		if isElement ( target ) then
			if MtxGetElementData ( target, "gunlicense" ) > 0 then
				MtxSetElementData ( target, "gunlicense", 0 )
				dbExec ( handler, "UPDATE ?? SET ?? = ? WHERE ??=?", "userdata", "Waffenschein", "0", "UID", playerUID[targetName] )
				infobox ( player, "\n\nDu hast "..targetName.."\n seinen Waffenschein\nabgenommen.", 5000, 125, 0, 0 )
				infobox ( target, "\n\n"..getPlayerName ( player ).." hat dir\ndeinen Waffenschein\nabgenommen.", 7500, 125, 0, 0 )
			else
				infobox ( player, "\n\nDer Spieler hat\nkeinen Waffenschein!", 5000, 125, 0, 0 )
			end
		else
			infobox ( player, "\n\n\nUng+ltiger Spieler!", 5000, 125, 0, 0 )
		end
	else
		infobox ( player, "Du bist nicht\nbefugt!", 5000, 125, 0, 0 )
	end
end
addCommandHandler ( "takegunlicense", takegunlicense_func )


function pdComputerSetWanted_func ( wanteds, name, reason )

	if wanteds >= 0 and wanteds <= 6 then
		local player = getPlayerFromName ( name )
		if player then
			if isStateFaction ( client ) then
				MtxSetElementData ( player, "wanteds", wanteds )
				setPlayerWantedLevel ( player, wanteds )
				outputChatBox ( "Der Beamte "..getPlayerName ( client ).." hat deinen Fahndungslevel auf "..wanteds.." gesetzt!", player, 0, 0, 255 )
				outputChatBox ( "Grund: "..reason, player, 0, 0, 255 )
				sendMSGForFaction ( getPlayerName ( client ).." hat "..name.." den Fahndungslevel auf "..wanteds.." gesetzt ( "..reason.." )!", 1, 200, 200, 0 )
				sendMSGForFaction ( getPlayerName ( client ).." hat "..name.." den Fahndungslevel auf "..wanteds.." gesetzt ( "..reason.." )!", 6, 200, 200, 0 )
				sendMSGForFaction ( getPlayerName ( client ).." hat "..name.." den Fahndungslevel auf "..wanteds.." gesetzt ( "..reason.." )!", 8, 200, 200, 0 )
				triggerClientEvent ( client, "refreshPDComputer", client)
			end
		else
			infobox ( client, "Du hast einen\nungueltigen Spieler\nangegeben!", 5000, 125, 0, 0 )
		end
	end
end
addEvent ( "pdComputerSetWanted", true )
addEventHandler ( "pdComputerSetWanted", getRootElement(), pdComputerSetWanted_func )

function pdComputerAddSTVO_func ( name, stvo, reason )

	if stvo >= 0 and stvo <= 15 then
		local player = getPlayerFromName ( name )
		if player then
			MtxSetElementData ( player, "stvo_punkte", tonumber ( MtxGetElementData ( player, "stvo_punkte" ) + stvo) )
			outputChatBox ( "Du hast "..name.." "..stvo.." STVO-Punkt(e) wegen \""..reason.."\" gegeben!", client, 255, 255, 0 )
			outputChatBox ( "Du hast "..stvo.." STVO-Punkt(e) erhalten, Grund: \""..reason.."\", Gemeldet von: "..getPlayerName ( client ), player, 255, 255, 0 )
			outputChatBox ( "Das war dein "..MtxGetElementData ( player, "stvo_punkte" )..". Punkt - Bei 15 wird dir dein Fuehrerschein beim naechsten Einloggen entzogen!", player, 255, 255, 0 )
			triggerClientEvent ( client, "refreshPDComputer", client)
		else
			infobox ( client, "Du hast einen\nungueltigen Spieler\nangegeben!", 5000, 125, 0, 0 )
		end
	end
end
addEvent ( "pdComputerAddSTVO", true )
addEventHandler ( "pdComputerAddSTVO", getRootElement(), pdComputerAddSTVO_func )


function pdComputerDeleteSTVO_func ( name, stvo, reason )
	if stvo >= 0 and stvo <= 15 then
		local player = getPlayerFromName ( name )
		if player then
			MtxSetElementData ( player, "stvo_punkte", tonumber ( MtxGetElementData ( player, "stvo_punkte" ) - stvo) )
			outputChatBox ( "Du hast "..stvo.." Punkt(e) von "..getPlayerName(player).." gelöscht!", client, 255, 255, 0 )
			outputChatBox ( "Du hast von "..getPlayerName(client).." "..stvo.." STVO-Punkt(e) gelöscht bekommen! Grund: \""..reason.."\"", player, 255, 255, 0 )
			triggerClientEvent ( client, "refreshPDComputer", client)
		else
			infobox ( client, "Du hast einen\nungueltigen Spieler\nangegeben!", 5000, 125, 0, 0 )
		end
	end
end
addEvent ( "pdComputerDeleteSTVO", true )
addEventHandler ( "pdComputerDeleteSTVO", getRootElement(), pdComputerDeleteSTVO_func )


function deleteSTVO_func ( player, cmd, name, stvo, reason )
	if isStateFaction ( player ) then
		if isOnDuty ( player ) then
			if getPlayerRank ( player ) >= 2 then
				if name then
					if findPlayerByName ( name ) then
						if stvo >= 0 and stvo <= 15 then
							if reason then
								if stvo > MtxGetElementData ( findPlayerByName ( name ), "stvo_punkte" ) then
									stvo = MtxGetElementData ( findPlayerByName ( name ), "stvo_punkte" )
								end
								triggerEvent ("pdComputerDeleteSTVO", player, name, stvo, reason)
								local msg = getPlayerName(player).. " hat "..stvo.." StVO Punkte von "..getPlayerName(findPlayerByName(name)).." gelöscht. Grund: "..reason
								sendMSGForFaction (msg, 1)
								sendMSGForFaction (msg, 6)
								sendMSGForFaction (msg, 7)
								triggerClientEvent ( client, "refreshPDComputer", client)
							else
								infobox ( client," Bitte Grund angeben!", 5000, 125, 0, 0)
							end
						else
							infobox ( client, "Der Spieler hat\nschon genug\nStVO Punkte!", 5000, 125, 0, 0)
						end
					else
						infobox ( client, "Der Spieler existiert\nnicht oder ist\nnicht online!", 5000, 125, 0, 0)
					end
				else
					infobox ( client, "Bitte Name\neingeben!", 5000, 125, 0, 0)
				end
			else
				infobox ( client, "Erst ab\nRang 2 erlaubt!", 5000, 125, 0, 0)
			end
		else
			infobox ( client, "Du musst dafür\nOnduty sein!", 5000, 125, 0, 0)
		end
	else
		infobox ( client, "Du bist\nnicht befugt!", 5000, 125, 0, 0)
	end
end
addCommandHandler ("delstvo", deleteSTVO_func)


function ticket_func ( player, cmd, target, price )
	if target then
		local target = findPlayerByName( target )
		if price then
			local price = tonumber ( price )
			if target then
				if price then
					price = math.floor ( math.abs ( price ) )
					if isOnDuty(player) then
						if MtxGetElementData ( target, "wanteds" ) >= 1 then
							if MtxGetElementData ( target, "money" ) >= price then
								outputChatBox ( getPlayerName ( player ).." bietet dir ein Ticket an: "..price.." € fuer Straferlass.", target, 0, 125, 0 )
								outputChatBox ( "Tippe /accept ticket, um zuzustimmen.", target, 0, 125, 0 )
								MtxSetElementData ( target, "ticketprice", price )
								triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\n\nDu hast "..getPlayerName(target).."\nein Ticket angeboten.", 7500, 0, 125, 0 )
								local msg = getPlayerName(player).. " hat "..getPlayerName(target).." ( "..MtxGetElementData ( target, "wanteds" ).." ) ein Ticket für "..price.." angeboten."
								sendMSGForFaction (msg, 1)
								sendMSGForFaction (msg, 6)
								sendMSGForFaction (msg, 8)								
							else
								triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDer Spieler hat\nnicht genug Geld\ndabei!", 7500, 125, 0, 0 )
							end
						else
							triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\n\nDer Spieler muss\nein Wanted haben!", 7500, 125, 0, 0 )
						end
					else
						triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist kein\nPolizist im Dienst!", 7500, 125, 0, 0 )
					end
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\n\nGebrauch:\n/ticket [Name] [Preis]!", 7500, 125, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDer Spieler\nexistiert nicht!", 7500, 125, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\n\nGebrauch:\n/ticket [Name] [Preis]!", 7500, 125, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\n\nGebrauch:\n/ticket [Name] [Preis]!", 7500, 125, 0, 0 )
	end
end
addCommandHandler ( "ticket", ticket_func )

function grab_func ( player, cmd, targetName )

	if not client or client == player then
		local target = findPlayerByName( targetName )
		if isOnDuty(player) then
			if isElement ( target ) then
				if MtxGetElementData ( target, "tazered" ) then
					local x1, y1, z1 = getElementPosition ( player )
					local x2, y2, z2 = getElementPosition ( target )
					if getDistanceBetweenPoints3D ( x1, y1, z1, x2, y2, z2 ) < 10 then
						local veh = getPedOccupiedVehicle ( player )
						local model = getElementModel ( veh )
						local validSeats = {}
						if copcars[model] or model == 497 or model == 427 or model == 490 or model == 609 or model == 470 then
							for i = 2, 3 do
								if not getVehicleOccupant ( veh, i ) then
								validSeats[i] = true
								end
							end
						elseif copbikes[model] or model == 415 or model == 601 or model == 433 or model == 548 or 563 then
							if not getVehicleOccupant ( veh, 1 ) then
								validSeats[1] = true
							end
						else
							infobox ( player, "\n\n\nDu sitzt in\neinem Ungueltigen\nFahrzeug!", 5000, 125, 0, 0 )
							return
						end
						for key, index in pairs ( validSeats ) do
							setPedAnimation(target)
							warpPedIntoVehicle ( target, veh, key )
							MtxSetElementData ( target, "tied", false )
							toggleAllControls ( target, false )
							removeEventHandler ( "onPlayerCommand", target, block_tie_cmds )
							addEventHandler( "onPlayerCommand", target, block_tie_cmds )
							outputChatBox ( "Du hast "..getPlayerName(target).." gefesselt!", player, 0, 125, 0 )
							outputChatBox ( "Du wurdest von "..getPlayerName(player).." gefesselt!", target, 200, 200, 0 )
							return
						end
						infobox ( player, "\n\n\nDu hast keinen\nfreien Sitz!", 5000, 125, 0, 0 )
					else
						infobox ( player, "\n\n\nDas Ziel ist\nzu weit entfernt!", 5000, 125, 0, 0 )
					end
				else
					infobox ( player, "\n\n\nDer Spieler muss\ngetazert sein!", 5000, 125, 0, 0 )
				end
			else
				infobox ( player, "\n\n\nUngueltiger Spieler!", 5000, 125, 0, 0 )
			end
		else
			infobox ( player, "\n\n\nDu bist kein\nBeamter im Dienst!", 5000, 125, 0, 0 )
		end
	end
end
addCommandHandler ( "grab", grab_func )
addEvent ( "grab", true )
addEventHandler ( "grab", getRootElement(), grab_func )

function accept_ticket_func ( player, cmd, after )

	if after == "ticket" then
		local price = MtxGetElementData ( player, "ticketprice" )
		local money = MtxGetElementData ( player, "money" )
		if price then
			if money >= price then
				if MtxGetElementData ( player, "wanteds" ) >= 1 then
					MtxSetElementData ( player, "wanteds", 0 )
					setPlayerWantedLevel ( player, 0 )
					
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - price )
					
					MtxSetElementData ( player, "ticketprice", nil )
					
					infobox ( player, "\n\nDeine Strafe wurde\ndir erlassen.", 5000, 0, 200, 0 )
					
					factionDepotData["money"][1] = factionDepotData["money"][1] + price
				else
					infobox ( player, "\n\n\nDu hast keine\nWanteds!", 7500, 125, 0, 0 )
				end
			else
				infobox ( player, "\n\n\nDu hast nicht\ngenug Geld!", 7500, 125, 0, 0 )
			end
		else
			infobox ( player, "\n\n\nNiemand hat dir\nein Ticket angeboten!", 7500, 125, 0, 0 )
		end
	end
end
addCommandHandler ( "accept", accept_ticket_func )

function fdraw_func ( player, cmd, amount )
	local frac = MtxGetElementData ( player, "fraktion" )
	if frac == 1 or frac == 6 or frac == 8 then
		if MtxGetElementData ( player, "rang" ) >= 5 then
			local amount = tonumber ( amount )
			if amount then
				amount = math.abs ( math.floor ( amount ) )
				if factionDepotData["money"][1] >= amount then
					factionDepotData["money"][1] = factionDepotData["money"][1] - amount
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) + amount)
					outputLog ( getPlayerName(player).." hat "..amount.." € aus der Staatskasse genommen.", "fkasse" )
				else
					infobox ( player, "\n\nEs ist nicht mehr\ngenug Geld in der\nKasse!", 7500, 125, 0, 0 )
				end
			else
				infobox ( player, "\n\n\nGebrauch: /fdraw [Summe]", 7500, 125, 0, 0 )
			end
		else
			infobox ( player, "\n\n\nDu bist nicht\nbefugt!", 7500, 125, 0, 0 )
		end
	elseif frac == 5 then
		if MtxGetElementData ( player, "rang" ) >= 4 then
			local amount = tonumber ( amount )
			if amount then
				amount = math.abs ( math.floor ( amount ) )
				local fmoney = factionDepotData["money"][5]
				if fmoney >= amount then
					factionDepotData["money"][5] = factionDepotData["money"][5] - amount
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) + amount)
					outputLog ( getPlayerName(player).." hat "..amount.." € aus der Reporterkasse genommen.", "fkasse" )
				else
					infobox ( player, "\n\nEs ist nicht mehr\ngenug Geld in der\nKasse!", 7500, 125, 0, 0 )
				end
			else
				infobox ( player, "\n\n\nGebrauch: /fdraw [Summe]", 7500, 125, 0, 0 )
			end
		else
			infobox ( player, "\n\n\nDu bist nicht\nbefugt!", 7500, 125, 0, 0 )
		end
	elseif frac == 10 or frac == 11 then
		if MtxGetElementData ( player, "rang" ) >= 4 then
			local amount = tonumber ( amount )
			if amount then
				amount = math.abs ( math.floor ( amount ) )
				local fmoney = factionDepotData["money"][10]
				if fmoney >= amount then
					factionDepotData["money"][10] = factionDepotData["money"][10] - amount
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) + amount)
					outputLog ( getPlayerName(player).." hat "..amount.." € aus der Reporterkasse genommen.", "fkasse" )
				else
					infobox ( player, "\n\nEs ist nicht mehr\ngenug Geld in der\nKasse!", 7500, 125, 0, 0 )
				end
			else
				infobox ( player, "\n\n\nGebrauch: /fdraw [Summe]", 7500, 125, 0, 0 )
			end
		else
			infobox ( player, "\n\n\nDu bist nicht\nbefugt!", 7500, 125, 0, 0 )
		end
	end
end
addCommandHandler ( "fdraw", fdraw_func )

function fbank_func ( player, cmd, amount )
	local frac = MtxGetElementData ( player, "fraktion" )
	if frac == 1 or frac == 6 or frac == 8 then
		if MtxGetElementData ( player, "rang" ) >= 0 then
			local amount = tonumber ( amount )
			if amount then
				amount = math.abs ( math.floor ( amount ) )
				if MtxGetElementData ( player, "money" ) >= amount then
					factionDepotData["money"][1] = factionDepotData["money"][1] + amount
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - amount )
					outputLog ( getPlayerName(player).." hat "..amount.." € in die Staatskasse gezahlt.", "fkasse" )
				else
					infobox ( player, "\n\nDu hast nicht\nsoviel Geld!", 7500, 125, 0, 0 )
				end
			else
				infobox ( player, "\n\n\nGebrauch: /fbank [Summe]", 7500, 125, 0, 0 )
			end
		else
			infobox ( player, "\n\n\nDu bist nicht\nbefugt!", 7500, 125, 0, 0 )
		end
	elseif frac == 5 then
		if MtxGetElementData ( player, "rang" ) >= 0 then
			local amount = tonumber ( amount )
			if amount then
				amount = math.abs ( math.floor ( amount ) )
				if MtxGetElementData ( player, "money" ) >= amount then
					factionDepotData["money"][5] = factionDepotData["money"][5] + amount
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - amount )
					outputLog ( getPlayerName(player).." hat "..amount.." € in die Reporterkasse gezahlt.", "fkasse" )
				else
					infobox ( player, "\n\nDu hast nicht\nsoviel Geld!", 7500, 125, 0, 0 )
				end
			else
				infobox ( player, "\n\n\nGebrauch: /fbank [Summe]", 7500, 125, 0, 0 )
			end
		else
			infobox ( player, "\n\n\nDu bist nicht\nbefugt!", 7500, 125, 0, 0 )
		end
	elseif frac == 10 or frac == 11 then
		if MtxGetElementData ( player, "rang" ) >= 0 then
			local amount = tonumber ( amount )
			if amount then
				amount = math.abs ( math.floor ( amount ) )
				if MtxGetElementData ( player, "money" ) >= amount then
					factionDepotData["money"][10] = factionDepotData["money"][10] + amount
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - amount )
					outputLog ( getPlayerName(player).." hat "..amount.." € in die Medic%Mech gezahlt.", "fkasse" )
				else
					infobox ( player, "\n\nDu hast nicht\nsoviel Geld!", 7500, 125, 0, 0 )
				end
			else
				infobox ( player, "\n\n\nGebrauch: /fbank [Summe]", 7500, 125, 0, 0 )
			end
		else
			infobox ( player, "\n\n\nDu bist nicht\nbefugt!", 7500, 125, 0, 0 )
		end
	end
end
addCommandHandler ( "fbank", fbank_func )

function m_func ( player, cmd, ... )

	local veh = getPedOccupiedVehicle ( player )

	if veh then
		if isFederalCar( veh ) and isOnDuty(player) then
			local parametersTable = {...}
			local stringWithAllParameters = table.concat( parametersTable, " " )
			local posX, posY, posZ = getElementPosition ( player )
			local chatSphere = createColSphere( posX, posY, posZ, 30 )
			local nearbyPlayers = getElementsWithinColShape( chatSphere, "player" )
			destroyElement( chatSphere )
			local x1, y1, z1 = getElementPosition ( player )
			local pname = getPlayerName ( player )
			local rankname = getPlayerRankName ( player )
			for i=1, #nearbyPlayers do
				local nearbyPlayer = nearbyPlayers[i]
				local x2, y2, z2 = getElementPosition ( nearbyPlayer)
				local distance = getDistanceBetweenPoints3D ( x1,y1,z1,x2,y2,z2 )
				if getElementDimension ( player ) == getElementDimension ( nearbyPlayer ) then
					outputChatBox ( "["..rankname.." "..pname.."]: " ..stringWithAllParameters, nearbyPlayer, 255, 255, 20 )
				end
			end
			outputLog ( "["..rankname.." "..pname.."]: " ..stringWithAllParameters, "Chat" )
		else
			outputChatBox ( "Du bist nicht im Dienst/sitzt in keinem Polizeifahrzeug!", player, 125, 0, 0 )
		end
	else
		outputChatBox ( "Du sitzt in keinem Fahrzeug!", player, 125, 0, 0 )
	end
	
end

addCommandHandler ( "m", m_func )

function test_func ( player, cmd, target )

	if not client or client == player then
		if isOnDuty(player) then
			target = findPlayerByName( target )
			if target then
				outputChatBox ( "Officer "..getPlayerName ( player ).." fordert dich zu einem Alkohol- und Drogentest auf.", target, 125, 0, 0 )
				outputChatBox ( "Tippe /accept test, um zuzustimmen.", target, 125, 125, 0 )
				outputChatBox ( "Du hast "..getPlayerName ( target ).." zu einem Test aufgefordert.", player, 0, 125, 0 )
				
				MtxSetElementData ( target, "tester", player )
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nGebrauch: /test\n[Name]", 5000, 125, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist nicht\nim Dienst!", 5000, 125, 0, 0 )
		end
	end
end
addCommandHandler ( "givetest", test_func )
addEvent ( "test", true )
addEventHandler ( "test", getRootElement(), test_func )

function frisk_func ( player, cmd, target )
	if isOnDuty(player) then
		local playerid = findPlayerByName( target )
		if player == client or not client then
			if playerid then
				local x1, y1, z1 = getElementPosition ( player )
				local x2, y2, z2 = getElementPosition ( playerid )
				if getDistanceBetweenPoints3D ( x1, y1, z1, x2, y2, z2 ) <= 5 then
					outputChatBox ( "Gegenstaende von "..target..":", player, 0, 0, 125 )
					outputChatBox ( "Materials: "..MtxGetElementData(playerid,"mats")..", Drogen: "..MtxGetElementData(playerid,"drugs"),player,200,200,0)
					outputChatBox ( getPlayerName(player).." hat dich durchsucht!", playerid, 125, 0, 0 )
				else
					outputChatBox ( "Du bist zu weit entfernt!", player, 125, 0, 0 )
				end
			end
		end
	end
end
addEvent ( "friskGUI", true )
addEventHandler ( "friskGUI", getRootElement(), frisk_func )
addCommandHandler ( "frisk", frisk_func )

function offduty_func ( player )
	if isAbleOffduty ( player ) then
		if not getPedOccupiedVehicle ( player ) then
			setElementModel ( player, MtxGetElementData ( player, "skinid" ) or 0 )
			if MtxGetElementData ( player, "fraktion" ) ~= 8 then
				takeAllWeapons ( player )
			end
		else
			outputChatBox ( "Du darfst nicht in einem Fahrzeug sitzen.", player, 125, 0, 0 )
		end
	else
		outputChatBox ( "Du bist kein Beamter im Dienst!", player, 125, 0, 0 )
	end
end
addCommandHandler ( "offduty", offduty_func )

function takeillegal_func ( player, cmd, target )

	local playerid = findPlayerByName( target )
	if player == client or not client then
		if playerid then
			if isOnDuty(player) then
				outputChatBox ( "Du hast "..target.." seine Illegalen Gegenstaende abgenommen!", player, 0, 125, 0 )
				MtxSetElementData ( playerid, "drugs", 0 )
				MtxSetElementData ( playerid, "mats", 0 )
				outputChatBox ( getPlayerName(player).." hat dir deine Illegalen Gegenstaende abgenommen!", playerid, 125, 0, 0 )
			else
				outputChatBox ( "Du bist kein Cop im Dienst!", player, 125, 0, 0 )
			end
		end
	end
end
addEvent ( "takeillegalGUI", true )
addEventHandler ( "takeillegalGUI", getRootElement(), takeillegal_func )
addCommandHandler ( "takeillegal", takeillegal_func )


function suspect_func ( player, cmd, target, ... )

	if player == client or not client then
		local reason = table.concat ( {...}, " " )
		if not reason then
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu hast keinen\nGrund angegeben!", 7500, 125, 0, 0 )
		else
			if isOnDuty(player) then
				local target = findPlayerByName( target )
				if target and MtxGetElementData ( target, "loggedin" ) == 1 then
					if MtxGetElementData ( target, "jailtime" ) == 0 and MtxGetElementData ( target, "prison" ) == 0 then
						if getPedOccupiedVehicle ( player ) then
							local model = getElementModel ( getPedOccupiedVehicle ( player ) )
							if copcars[model] or model == 497 or model == 427 or model == 490 or model == 609 or model == 470 or copbikes[model] or model == 415 or model == 601 or model == 433 or model == 548 or 563 then
								if MtxGetElementData ( target, "wanteds" ) <= 5 then
									MtxSetElementData ( target, "wanteds", MtxGetElementData ( target, "wanteds" ) + 1 )
									setPlayerWantedLevel ( target, MtxGetElementData ( target, "wanteds" ) )
								end
								outputChatBox ( "Du hast ein Verbrechen begangen: "..reason..", Gemeldet von: "..getPlayerName(player), target, 255, 255, 0 )
								local msg = getPlayerName(player).." hat "..getPlayerName(target).." ein Wanted wegen "..reason.." gegeben!"
								sendMSGForFaction ( msg, 1, 0, 0, 200 )
								sendMSGForFaction ( msg, 6, 0, 0, 200 )
								sendMSGForFaction ( msg, 8, 0, 0, 200 )
							end
						else
							if MtxGetElementData ( target, "wanteds" ) <= 5 then
								MtxSetElementData ( target, "wanteds", MtxGetElementData ( target, "wanteds" ) + 1 )
								setPlayerWantedLevel ( target, MtxGetElementData ( target, "wanteds" ) )
							end
							outputChatBox ( "Du hast ein Verbrechen begangen: "..reason..", Gemeldet von: "..getPlayerName(player), target, 255, 255, 0 )
							local msg = getPlayerName(player).." hat "..getPlayerName(target).." ein Wanted wegen "..reason.." gegeben!"
							sendMSGForFaction ( msg, 1, 0, 0, 200 )
							sendMSGForFaction ( msg, 6, 0, 0, 200 )
							sendMSGForFaction ( msg, 8, 0, 0, 200 )
						end
					else
						triggerClientEvent ( player, "infobox_start", getRootElement(), "Der Spieler\nist schon\nim Knast!", 7500, 125, 0, 0 )
					end
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nUngültiger\nSpieler!", 7500, 125, 0, 0 )
				end
			end
		end
	end
end
addCommandHandler("su", suspect_func)
addEvent ("suspect", true )
addEventHandler ("suspect", getRootElement(), suspect_func )


local reasonArray = { 
	-- 1 --
	["verweigerung"] = { "Verweigerung zur Durchsuchung", 1 },
	["dur"] = { "Verweigerung zur Durchsuchung", 1 },
	["durchsuchung"] = { "Verweigerung zur Durchsuchung", 1 },
	["behinderung"] = { "Beamtenbehinderung", 1 },
	["beh"] = { "Beamtenbehinderung", 1 },
	["belästigung"] = { "Beamtenbelästigung", 1 },
	["bel"] = { "Beamtenbelästigung", 1 },
	["beleidigung"] = { "Beleidigung", 1 },
	["id"] = { "Beleidigung", 1 },
	["lsv"] = { "Befehlsverweigerung", 1 },
	["verweigerung"] = { "Befehlsverweigerung", 1 },
	["mats1"] = { "Materialbesitz ( 10-49 )", 1 },
	["drogen1"] = { "Drogenbesitz ( 10-49 )", 1 },
	["vd"] = { "Versuchter Diebstahl", 1 },
	["beschädigung"] = { "starke Sachbeschädigung", 1 },
	["sach"] = { "starke Sachbeschädigung", 1 },
	["sb"] = { "starke Sachbeschädigung", 1 },
	["illad"] = { "illegale Werbung", 1 },
	["ad"] = { "illegale Werbung", 1 },
	["waffe"] = { "Waffennutzung", 1 },
	["nnu"] = { "Waffennutzung", 1 },
	["vt"] = { "Vortäuschen falscher Tatsachen", 1 },
	["tatsachen"] = { "Vortäuschen falscher Tatsachen", 1 },
	["kpv"] = { "Körperverletzung", 1 },
	["drogen"] = { "Einfluss unter Drogen", 1 },
	["konsum"] = { "Drogenkonsum", 1 },
	["fof"] = { "Fahren ohne Führerschein", 1 },
	["fahren"] = { "Fahren ohne Führerschein", 1 },
	
	-- 2 --
	["flucht"] = { "Flucht vor/aus Kontrolle", 2 },
	["beihilfe"] = { "Beihilfe zur Flucht", 2 },
	["schuss"] = { "Körperverletzung durch Schusswaffen", 2 },
	["bes"] = { "Beschuss", 2 },
	["mats2"] = { "Materialbesitz ( 50-149 )", 2 },
	["drogen2"] = { "Drogenbesitz ( 50-149 )", 2 },
	["bestechung"] = { "Bestechungsversuch", 2 },
	["best"] = { "Bestechungsversuch", 2 },
	["bestech"] = { "Bestechungsversuch", 2 },
	["iv"] = { "illegaler Verkauf von Waffen/Drogen/Mats", 2 },
	["verkauf"] = { "illegaler Verkauf von Waffen/Drogen/Mats", 2 },
	["diebstahl"] = { "Diebstahl", 2 },
	["anbau"] = { "Drogen Anbau/Abbau", 2 },
	["abbau"] = { "Drogen Anbau/Abbau", 2 },
	["farm"] = { "Drogen Anbau/Abbau", 2 },
	["wegwerfen"] = { "Drogen/Mats wegwerfen", 2 },
	["werfen"] = { "Drogen/Mats wegwerfen", 2 },
	["erpressung"] = { "Erpressung / Drohung", 2 },
	["drohung"] = { "Erpressung / Drohung", 2 },
	["erp"] = { "Erpressung / Drohung", 2 },
	["dro"] = { "Erpressung / Drohung", 2 },
	["van"] = { "Vandalismus", 2 },
	["vandalismus"] = { "Vandalismus", 2 },
	["sach2"] = { "Vandalismus", 2 },
	["sb2"] = { "Vandalismus", 2 },
	
	-- 3 --
	["mats3"] = { "Materialbesitz ( 150+ )", 3 },
	["drogen3"] = { "Drogenbesitz ( 150+ )", 3 },
	["mt"] = { "Matstruck", 3 },
	["mv"] = { "Matstruck", 3 },
	["dt"] = { "Drogentruck", 3 },
	["cr"] = { "Carrob", 3 },
	["car"] = { "Carrob", 3 },
	["feldweg"] = { "Betreten des Bundeswehrgebiets (Feldweg)", 3 },
	["fw"] = { "Betreten des Bundeswehrgebiets (Feldweg)", 3 },
	["hinterhof"] = { "Betreten des SFPD/LVPD Parkplatzes (Hinterhof)", 3 },
	["mord"] = { "Mord", 3 },
	["rd"] = { "Mord", 3 },
	
	-- 4 --
	["br"] = { "Bankraub", 4 },
	["bank"] = { "Bankraub", 4 },
	["gn"] = { "Geiselnahme", 4 },
	["geisel"] = { "Geiselnahme", 4 },
	["mr"] = { "Museumraub", 4 },
	["museum"] = { "Museumraub", 4 },
	["sniper"] = { "Sniper-Nutzung", 4 },
	["snp"] = { "Sniper-Nutzung", 4 },
	["interior"] = { "Betreten der Polizeiwache", 4 },
	["int"] = { "Betreten der Polizeiwache", 4 },
	
	-- 6 --	
	["carrier"] = { "Betreten des Flugzeugträgers", 6 },
	["fl"] = { "Betreten des Flugzeugträgers", 6 },
	["fbi"] = { "Betreten der FBI Basis", 6 },
	["area"] = { "Einbruch in die Area51", 6 },
	["army"] = { "Einbruch in die Area51", 6 },
	["51"] = { "Einbruch in die Area51", 6 },
	["rpg"] = { "Raketenwerfer-Nutzung", 6 },
	["raketenwerfer"] = { "Raketenwerfer-Nutzung", 6 }
}

function suspect2_func ( player, cmd, target, reason )
	if not reason then
		triggerClientEvent ( player, "infobox_start", getRootElement(), "Du hast keinen\nGrund angegeben!", 7500, 125, 0, 0 )
	else
		if isOnDuty(player) then
			if target then
				local target = findPlayerByName( target )
				if target and MtxGetElementData ( target, "loggedin" ) == 1 then
					if MtxGetElementData ( target, "jailtime" ) == 0 and MtxGetElementData ( target, "prison" ) == 0 then
						local reason = string.lower ( reason ) 
						local wanteds = MtxGetElementData ( target, "wanteds" )
						if reasonArray[reason] then
							MtxSetElementData ( target, "wanteds", wanteds+reasonArray[reason][2] )
							if MtxGetElementData ( target, "wanteds" ) > 6 then
								MtxSetElementData ( target, "wanteds", 6 )
							end
							outputChatBox ( "Du hast ein Verbrechen begangen: "..reasonArray[reason][1]..", Gemeldet von: "..getPlayerName(player), target, 255, 255, 0 )
							local msg = getPlayerName(player).." hat "..getPlayerName(target).." Wanteds wegen "..reasonArray[reason][1].." gegeben!"
							sendMSGForFaction ( msg, 1, 0, 0, 200 )
							sendMSGForFaction ( msg, 6, 0, 0, 200 )
							sendMSGForFaction ( msg, 8, 0, 0, 200 )
						else
							infobox ( player, "Ungültiger Grund", 4000, 200, 0 ,0 )
						end
					else
						triggerClientEvent ( player, "infobox_start", getRootElement(), "Der Spieler\nist schon\nim Knast!", 7500, 125, 0, 0 )
					end
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nUngueltiger\nSpieler!", 7500, 125, 0, 0 )
				end
			else
				infobox ( player, "Gebrauch:\n/suspect [Name] [Abk]", 4000, 200, 0, 0 )
			end
		end
	end
end
addCommandHandler("suspect", suspect2_func)


function clear_func ( player, cmd, target )

	if player == client or not client then
		if isOnDuty(player) then
			local target = findPlayerByName( target )
			if target then
				if getElementType ( target ) == "player" and MtxGetElementData ( target, "loggedin" ) == 1 then
					MtxSetElementData ( target, "wanteds", 0 )
					setPlayerWantedLevel ( target, 0 )
					outputChatBox ( "Du hast die Akten von "..getPlayerName(target).." geloescht!", player,255, 255, 0 )
					outputChatBox ( getPlayerName(player).." hat deine Akten geloescht!", target, 255, 255, 0 )
					local msg = getPlayerName(player).." hat "..getPlayerName(target).." die Akten geloescht!"
					sendMSGForFaction ( msg, 1, 0, 0, 200 )
					sendMSGForFaction ( msg, 6, 0, 0, 200 )
					sendMSGForFaction ( msg, 8, 0, 0, 200 )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nUngueltiger\nSpieler!", 5000, 125, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nUngueltiger\nSpieler!", 5000, 125, 0, 0 )
			end
		end
	end
end
addCommandHandler("clear", clear_func)
addEvent ("clear", true )
addEventHandler ("clear", getRootElement(), clear_func )

function stvopunkte_func ( player, cmd, target, ... )

	if player == client or not client then
		local reason = table.concat ( {...}, " " )
		if not reason then
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nKein Grund\nangegeben!", 5000, 125, 0, 0 )
		else
			if isOnDuty(player) then
				local target = findPlayerByName( target )
				if target and MtxGetElementData ( target, "loggedin" ) == 1 then
					MtxSetElementData ( target, "stvo_punkte", tonumber(MtxGetElementData ( target, "stvo_punkte" ) + 1) )
					outputChatBox ( "Du hast "..getPlayerName(target).." einen STVO-Punkt wegen \""..reason.."\" gegeben!", player,255, 255, 0 )
					outputChatBox ( "Du hast einen STVO-Punkt erhalten, Grund: \""..reason.."\", Gemeldet von: "..getPlayerName(player), target, 255, 255, 0 )
					outputChatBox ( "Das war bereits dein "..MtxGetElementData(target, "stvo_punkte")..". Punkt - Bei 15 wird dir dein Fuehrerschein beim naechsten Einloggen entzogen!", target, 255, 255, 0 )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nUngueltiger\nSpieler!", 5000, 125, 0, 0 )
				end
			end
		end
	end
end
addCommandHandler("stvopunkte", stvopunkte_func)
addEvent ("stvopunkte", true )
addEventHandler ("stvopunkte", getRootElement(), stvopunkte_func )

function takeweapons_func ( player, cmd, target )

	if player == client or not client then
		if isOnDuty(player) then
			if findPlayerByName( target ) then
				local target = findPlayerByName( target )
				local x, y, z = getElementPosition ( player )
				local tx, ty, tz = getElementPosition ( target )
				if getDistanceBetweenPoints3D ( x, y, z, tx, ty, tz ) < 5 then
					MtxSetElementData ( player, "hasBomb", false )
					takeAllWeapons ( target )
					outputChatBox ( "Du hast "..getPlayerName(target).." entwaffnet!", player, 0, 125, 0 )
					outputChatBox ( "Du wurdest von "..getPlayerName(player).." entwaffnet!", target, 125, 0, 0 )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDer Spieler\nist zu weit\nentfernt!", 5000, 125, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nUngueltiger\nSpieler!", 5000, 125, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist kein\nPolizist im\nDienst!", 5000, 125, 0, 0 )
		end
	end
end
addCommandHandler("takeweapons", takeweapons_func)
addEvent ("takeweapons", true )
addEventHandler ("takeweapons", getRootElement(), takeweapons_func )