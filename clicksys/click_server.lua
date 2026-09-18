--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function number_func ( player, cmd, target )
	if target then
		local targetNR = getPlayerFromName ( target )
		if targetNR then
			local nr = MtxGetElementData ( targetNR, "telenr" )
			if nr then
				outputChatBox ( "NR von "..target..": "..nr, player, 200, 200, 0 )
			end
		end
	end
end
addCommandHandler ( "number", number_func )

function sprunkAutomatUse_func ( )
	playSoundFrontEnd ( client, 40 )
	MtxSetElementData ( client, "money", MtxGetElementData ( client, "money" ) - 10 )
	if getElementHealth ( client ) + sprunkheal < 100 then
		setElementHealth ( client, getElementHealth ( client ) + sprunkheal )
	else
		setElementHealth ( client, 100 )
	end
end
addEvent ( "sprunkAutomatUse", true )
addEventHandler ( "sprunkAutomatUse", getRootElement(), sprunkAutomatUse_func )

function showLicenses_func ( player )

	if player == client then
		local target = getPlayerFromName ( MtxGetElementData ( player, "curclicked" ) )
		if target then
			local pname = getPlayerName ( player )
			local licenses = ""
			if MtxGetElementData ( player, "carlicense" ) == 1 then licenses = licenses.."Fuehrerschein " end
			if MtxGetElementData ( player, "bikelicense" ) == 1 then licenses = licenses.."Motorradschein " end
			if MtxGetElementData ( player, "fishinglicense" ) == 1 then licenses = licenses.."Angelschein " end
			if MtxGetElementData ( player, "lkwlicense" ) == 1 then licenses = licenses.."LKW-Fuehrerschein " end
			if MtxGetElementData ( player, "gunlicense" ) == 1 then licenses = licenses.."Waffenschein " end
			if MtxGetElementData ( player, "motorbootlicense" ) == 1 then licenses = licenses.."Bootsfuehrerschein " end
			if MtxGetElementData ( player, "segellicense" ) == 1 then licenses = licenses.."Segelschein " end
			if MtxGetElementData ( player, "planelicenseb" ) == 1 then licenses = licenses.."Flugschein A " end
			if MtxGetElementData ( player, "planelicensea" ) == 1 then licenses = licenses.."Flugschein B " end
			if MtxGetElementData ( player, "helilicense" ) == 1 then licenses = licenses.."Flugschein C " end
			outputChatBox ( "Vorhandene Lizensen von "..pname..": ", target, 200, 0, 200 )
			outputChatBox ( licenses, target, 200, 200, 0 )
			outputChatBox ( "Du hast "..getPlayerName(target).." deine Scheine gezeigt!", player, 0, 125, 0 )
		else
			outputChatBox ( "Spieler nicht gefunden!", player, 255, 0, 0 )
		end
	end
end
addEvent ( "showLicenses", true )
addEventHandler ( "showLicenses", getRootElement(), showLicenses_func )

function showGWD_func ( player )

	if player == client then
		local target = getPlayerFromName ( MtxGetElementData ( player, "curclicked" ) )
		if target then
			local pname = getPlayerName ( player )
			outputChatBox ( "Du hast "..getPlayerName ( target ).." deine GWD-Note gezeigt!", player, 0, 125, 0 )
			outputChatBox ( getPlayerName ( player ).." zeigt dir seine GWD-Note: "..tostring(MtxGetElementData(player,"armyperm10")).." %!", target, 125, 200, 125 )
		else
			outputChatBox ( "Spieler nicht gefunden!", player, 255, 0, 0 )
		end
	end
end
addEvent ( "showGWD", true )
addEventHandler ( "showGWD", getRootElement(), showGWD_func )