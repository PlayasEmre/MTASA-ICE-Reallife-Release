--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

drugjobicon = createPickup ( -1868.9344482422, -144.03060913086, 11.665347099304, 3, 1239, 1000, 0 )
drugfarmicon = createPickup ( -1096.7784423828, -1614.6346435547, 76.240158081055, 3, 1239, 1000, 0 )
local drugblip = createBlip ( -1868.9344482422, -144.03060913086, 11.665347099304, 58, 2, 255, 255, 0, 255, 0, 200 )

function usedrugs_func ( player )

	if MtxGetElementData ( player, "drugs" ) >= 3 then
		if isControlEnabled ( player, "enter_exit" ) then
			MtxSetElementData ( player, "lastcrime", "drogen" )
			
			MtxSetElementData ( player, "drugs", MtxGetElementData ( player, "drugs" ) - 3 )
			
			takeDrugs ( player )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu hast nicht\ngenug Drogen\ndabei ( mind. 3 g)!", 7500, 200, 0, 0 )
	end
end
addCommandHandler ( "usedrugs", usedrugs_func )

function jobicon_dealer ( player )
	
	triggerClientEvent ( player, "infobox_start", getRootElement(), "Tippe /job, um\nDealer zu werden -\ndazu brauchst du\nnichts, aber es\nist illegal!", 7500, 200, 200, 0 )
end
addEventHandler ( "onPickupHit", drugjobicon, jobicon_dealer )

function jobicon_drugs ( player )

	triggerClientEvent ( player, "infobox_start", getRootElement(), "Tippe /buydrugs\n[Summe], um hier\nDrogen fuer "..drugprice.."$\nje Gramm zu\nerwerben.", 7500, 200, 200, 0 )
end
addEventHandler ( "onPickupHit", drugfarmicon, jobicon_drugs )

function buydrugs_func ( player, cmd, zahl )

	if tonumber ( zahl ) then
		local zahl = math.floor ( math.abs ( tonumber ( zahl ) ) )
		if MtxGetElementData ( player, "job" ) == "dealer" then
			if zahl <= 30 then
				if MtxGetElementData ( player, "money" ) >= zahl*drugprice then
					local jobtime = tonumber ( MtxGetElementData ( player, "jobtime" ) )
					if jobtime == 0 then
						MtxSetElementData ( player, "drugs", MtxGetElementData ( player, "drugs" ) + zahl )
						MtxSetElementData ( player, "lastcrime", "drugdealing" )
						MtxSetElementData ( player, "jobtime", tonumber ( MtxGetElementData ( player, "jobtime" ) ) + 20 )
						MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - zahl*drugprice )
						playSoundFrontEnd ( player, 40 )
						triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast nun\n"..MtxGetElementData ( player, "drugs" ).." Gramm Drogen\ndabei!", 7500, 125, 0, 0 )
					else
						triggerClientEvent ( player, "infobox_start", getRootElement(), "Du musst noch\n"..jobtime.." Minuten warten,\nbis du wieder\nDrogen kaufen\nkannst.", 7500, 125, 0, 0 )
					end
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "Du hast nicht\ngenug Geld!\n"..zahl.." Gramm Drogen\nkosten "..drugprice*zahl.." $!", 7500, 125, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "Du kannst max.\n30 Gramm pro\n20 Minuten er-\nwerben!", 7500, 125, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist kein\nDealer!", 7500, 125, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nUngueltige Zahl!", 7500, 125, 0, 0 )
	end
end
addCommandHandler ( "buydrugs", buydrugs_func )

function drugRecieve_func ( drugs )

	if source == client then
		if drugs == "boom" then
			setTimer ( Boomplane, 3000, 1 )
			setTimer ( Boomplane2, 3500, 1 )
		elseif drugs == "cops" then
			if MtxGetElementData ( source, "wanteds" ) >= 5 then
				MtxSetElementData ( source, "wanteds", 6 )
			else
				MtxSetElementData ( source, "wanteds", MtxGetElementData ( source, "wanteds" ) + 2 )
			end
			setPlayerWantedLevel ( source, MtxGetElementData ( source, "wanteds" ) )
		else
			MtxSetElementData ( source, "drugs", MtxGetElementData ( source, "drugs" ) + drugs )
		end
		MtxSetElementData ( source, "jobtime", tonumber ( MtxGetElementData ( source, "jobtime" ) ) + 20 )
	end
end
addEvent ( "drugRecieve", true )
addEventHandler ( "drugRecieve", getRootElement(), drugRecieve_func )

function Boomplane ()

	createExplosion ( -2301.7600097656+math.random ( -1, 1 ), -2804.5095214844+math.random ( -1, 1 ), 14+math.random ( -.3, .3 ), math.random ( 4, 7 ) )
end

function Boomplane2 ()

	setTimer ( Boomplane, 400, 4 )
end

function givedrugs_func ( player, cmd, target, summe )
	
	if player == client or not client then
		if MtxGetElementData ( player, "job" ) == "dealer" then
			local target = getPlayerFromName ( target )
			local summe = math.abs(math.floor(tonumber(summe)))
			if MtxGetElementData ( player, "drugs" ) >= summe then
				playSoundFrontEnd ( player, 40 )
				MtxSetElementData ( player, "lastcrime", "drugdealing" )
				playSoundFrontEnd ( target, 40 )
				MtxSetElementData ( player, "drugs", MtxGetElementData ( player, "drugs" ) - summe )
				MtxSetElementData ( target, "drugs", MtxGetElementData ( target, "drugs" ) + summe )
				outputChatBox ( "Du hast "..getPlayerName(target).." "..summe.." Gramm Drogen gegeben!", player, 0, 125, 0 )
				outputChatBox ( "Du hast von "..getPlayerName(player).." "..summe.." Gramm Drogen bekommen!", target, 0, 125, 0 )
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu hast nicht\ngenug Drogen dabei!", 7000, 125, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist kein\nDrogendealer!", 7000, 125, 0, 0 )
		end
	end
end
addEvent ( "givedrugs", true )
addEventHandler ( "givedrugs", getRootElement(), givedrugs_func )
addCommandHandler ( "givedrugs", givedrugs_func )