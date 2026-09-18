--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


copskins={
[265]=true,[267]=true,[281]=true,[283]=true,[284]=true
}
fbiSkins={
[285]=true,[286]=true,[165]=true,[164]=true,[163]=true
}


function tazer_func ( attacker )
end

function tazery_func ( attacker )
local attackerplayer = getPlayerFromName ( attacker )
		if isOnDuty(attacker) then
					if MtxGetElementData ( source, "tazered") == false then
						if isOnStateDuty ( source ) then
							triggerClientEvent ( attackerplayer, "infobox_start", getRootElement(), "\n\nDas Ziel ist ein Verbündeter!", 5000, 125, 0, 0 )
						else
							setPedAnimation( source, "crack", "crckdeth2",-1,true,true,false)
							MtxSetElementData(source,"anim", 1)
							setTimer ( defreeze_tazer, 20000, 1, source )
							MtxSetElementData ( attackerplayer, "tazer", 1 )
							MtxSetElementData ( source, "tazered", 1 )
							setTimer ( reuse_tazer, 25000, 1, attackerplayer )
									local pname = getPlayerName ( attacker )
									if getTeamName(getPlayerTeam(source)) == "Terror" then
									else
									outputChatBox ( pname.." hat dich ausser Gefecht gesetzt!", source, 200, 0, 0 )
									outputChatBox ( "Du hast "..getPlayerName(source).." ausser Gefecht gesetzt!", attacker, 0, 200, 0 )
								end
						end
					else
						triggerClientEvent ( attacker, "infobox_start", getRootElement(), "\n\nDer Spieler ist bereits ausser Gefecht!", 5000, 125, 0, 0 )	
				end
		end
end
addEvent ( "tazer", true )
addEventHandler ( "tazer", getRootElement(), tazery_func )

function defreeze_tazer ( player )

	setPedAnimation ( player )
	MtxSetElementData ( player, "tazered", 0 )
	MtxSetElementData(player,"anim", 0)
	if MtxGetElementData ( player, "tied" ) then
		toggleAllControls ( player, true, true, false )
	end
end

function reuse_tazer ( player )

	MtxSetElementData ( player, "tazer", 0 )
end

function accept_func ( player, cmd, add )

	if add == "test" then
		local cop = MtxGetElementData ( player, "tester" )
		if isElement ( cop ) then
			local alc = MtxGetElementData ( player, "alcoholFlushPoints" ) / 25
			local drogen = MtxGetElementData ( player, "drugFlushPoints" )
			infobox ( player, "\n\n\nDu hast dem\nTest zugestimmt.", 5000, 0, 125, 0 )
			local result = "Ergebnis:\nAlkoholgehalt im Blut: "..alc.." Promil,\nTHC-Gehalt im Blut: "..drogen
			outputChatBox ( result, cop, 200, 200, 0 )
			outputChatBox ( result, player, 200, 200, 0 )
		else
			infobox ( player, "\n\n\nNicht möglich.", 5000, 125, 0, 0 )
		end
	end
end
addCommandHandler ( "accept", accept_func )

function cuff_func ( player, cmd, target )

	if player == client or not client then
		if copskins[getElementModel ( player )] or fbiSkins[getElementModel ( player )] or isArmy ( player ) then
			if getPlayerFromName ( target ) then
				local target = getPlayerFromName ( target )
				local x1, y1, z1 = getElementPosition ( player )
				local x2, y2, z2 = getElementPosition ( target )
				if getDistanceBetweenPoints3D ( x1, y1, z1, x2, y2, z2 ) < 5 then
					MtxSetElementData ( target, "sprint", 1 )
					setTimer ( reengage_sprint, 60000, 1, target )
					toggleControl ( target, "sprint", false )
					toggleControl ( target, "walk", false )
					setControlState ( target, "walk", true )
					outputChatBox ( getPlayerName(player).." hat deine Füsse gefesselt! Du kannst nicht mehr rennen!", target, 0, 125, 0 )
					outputChatBox ( "Du hast "..getPlayerName(target).." Fussfesseln angelegt!", player, 0, 125, 0 )
					takeAllWeapons ( target )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist zu weit entfernt!", 5000, 125, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nUngültiger Spieler!", 5000, 125, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist kein Polizist im Dienst!", 5000, 125, 0, 0 )
		end
	end
end
addEvent ( "cuffGUI", true )
addEventHandler ( "cuffGUI", getRootElement(), cuff_func )
addCommandHandler ( "cuff", cuff_func )

function reengage_sprint ( player )

	MtxSetElementData ( player, "sprint", 0 )
	toggleControl ( player, "sprint", true )
	toggleControl ( player, "walk", true )
	setControlState ( player, "walk", false )
	outputChatBox ( "Du hast deine Fussfesseln gelöst!", player, 0, 125, 0 )
end