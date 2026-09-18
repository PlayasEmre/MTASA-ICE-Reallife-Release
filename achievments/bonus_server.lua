--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

carslotUpgradePrices = { [3]=50, [5]=60, [7]=75 }


function setMaximumCarsForPlayer ( player )

	local pname = getPlayerName ( player )
	
	local carslotUpdate5, carslotUpdate4, carslotUpdate3, carslotUpdate2, carslotUpdate1 = getCarslotUpdate ( pname )

	MtxSetElementData ( player, "carslotupgrade", carslotUpdate1 )
	MtxSetElementData ( player, "carslotupgrade2", carslotUpdate2 )
	MtxSetElementData ( player, "carslotupgrade3", carslotUpdate3 )
	MtxSetElementData ( player, "carslotupgrade4", carslotUpdate4 )
	MtxSetElementData ( player, "carslotupgrade5", carslotUpdate5 )
	
	local maxcars = 5
	if carslotUpdate5 == 1 then
		maxcars = 15
		if MtxGetElementData ( player, "premium" ) == true then
			maxcars = 20
		end
	elseif carslotUpdate4 == 1 then
		maxcars = 13
	elseif carslotUpdate3 == 1 then
		maxcars = 11
	elseif carslotUpdate2 == 1 then
		maxcars = 9
	elseif carslotUpdate1 == "buyed" then
		maxcars = 7
	end
	
	MtxSetElementData ( player, "maxcars", maxcars )
end

function bonusBuy_func ( player, bonus )

	if player == client then
		local pname = getPlayerName ( player )
		local bonuspoints = tonumber ( MtxGetElementData ( player, "bonuspoints" ) )
		if bonus == " Lungenvolumen" then
			if MtxGetElementData ( player, "lungenvol" ) ~= "none" then
				outputChatBox ( "Diesen Bonus hast du bereits gekauft!", player, 125, 0, 0 )
			else
				if bonuspoints >= 35 then
					outputChatBox ( "Du hast den Bonus gekauft!", player, 0, 125, 0 )
					setPedStat ( player, 225, 500 )
					MtxSetElementData ( player, "lungenvol", "buyed" )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 35 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "Lungenvolumen", "buyed", "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Muskeln" then
			if MtxGetElementData ( player, "muscle" ) ~= "none" then
				outputChatBox ( "Diesen Bonus hast du bereits gekauft!", player, 125, 0, 0 )
			else
				if bonuspoints >= 40 then
					outputChatBox ( "Du hast den Bonus gekauft!", player, 0, 125, 0 )
					setPedStat ( player, 23, 500 )
					MtxSetElementData ( player, "muscle", "buyed" )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 40 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "Muskeln", "buyed", "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Kondition" then
			if MtxGetElementData ( player, "stamina" ) ~= "none" then
				outputChatBox ( "Diesen Bonus hast du bereits gekauft!", player, 125, 0, 0 )
			else
				if bonuspoints >= 25 then
					outputChatBox ( "Du hast den Bonus gekauft!", player, 0, 125, 0 )
					setPedStat ( player, 22, 500 )
					MtxSetElementData ( player, "stamina", "buyed" )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 25 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "Kondition", "buyed", "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Boxen" then
			if MtxGetElementData ( player, "boxen" ) ~= "none" then
				setPedFightingStyle ( player, 5 )
				outputChatBox ( "Aktueller Stil: Boxen", player, 175, 175, 20 )
				dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "CurStyle", "5", "UID", playerUID[pname] )
			else
				if bonuspoints >= 25 then
					outputChatBox ( "Du hast den Bonus gekauft - vergiss nicht, ihn zu aktivieren!", player, 0, 125, 0 )
					MtxSetElementData ( player, "boxen", "buyed" )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 25 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "Boxen", "buyed", "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "Verwenden" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Kung-Fu" then
			if MtxGetElementData ( player, "kungfu" ) ~= "none" then
				setPedFightingStyle ( player, 6 )
				outputChatBox ( "Aktueller Stil: Kung-Fu", player, 175, 175, 20 )
				dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "CurStyle", "6", "UID", playerUID[pname] )
			else
				if bonuspoints >= 35 then
					outputChatBox ( "Du hast den Bonus gekauft - vergiss nicht, ihn zu aktivieren!", player, 0, 125, 0 )
					MtxSetElementData ( player, "kungfu", "buyed" )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 35 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "KungFu", "buyed", "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "Verwenden" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Streetfighting" then
			if MtxGetElementData ( player, "streetfighting" ) ~= "none" then
				setPedFightingStyle ( player, 7 )
				outputChatBox ( "Aktueller Stil: Streetfighting", player, 175, 175, 20 )
				dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "CurStyle", "7", "UID", playerUID[pname] )
			else
				if bonuspoints >= 40 then
					outputChatBox ( "Du hast den Bonus gekauft - vergiss nicht, ihn zu aktivieren!", player, 0, 125, 0 )
					MtxSetElementData ( player, "streetfighting", "buyed" )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 40 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "Streetfighting", "buyed", "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "Verwenden" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Pistole" then
			if MtxGetElementData ( player, "pistolskill" ) ~= "none" then
				outputChatBox ( "Diesen Bonus hast du bereits gekauft!", player, 125, 0, 0 )
			else
				if bonuspoints >= 20 then
					outputChatBox ( "Du hast den Bonus gekauft!", player, 0, 125, 0 )
					setPedStat ( player, 69, 900 )
					setPedStat ( player, 70, 999 )
					MtxSetElementData ( player, "pistolskill", "buyed" )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 20 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "PistolenSkill", "buyed", "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Deagle" then
			if MtxGetElementData ( player, "deagleskill" ) ~= "none" then
				outputChatBox ( "Diesen Bonus hast du bereits gekauft!", player, 125, 0, 0 )
			else
				if bonuspoints >= 30 then
					outputChatBox ( "Du hast den Bonus gekauft!", player, 0, 125, 0 )
					setPedStat ( player, 71, 999 )
					MtxSetElementData ( player, "deagleskill", "buyed" )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 30 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "DeagleSkill", "buyed", "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Sturmgewehr" then
			if MtxGetElementData ( player, "assaultskill" ) ~= "none" then
				outputChatBox ( "Diesen Bonus hast du bereits gekauft!", player, 125, 0, 0 )
			else
				if bonuspoints >= 30 then
					outputChatBox ( "Du hast den Bonus gekauft!", player, 0, 125, 0 )
					setPedStat ( player, 77, 999 )
					setPedStat ( player, 78, 999 )
					MtxSetElementData ( player, "assaultskill", "buyed" )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 30 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "AssaultSkill", "buyed", "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Schrotflinten" then
			if MtxGetElementData ( player, "shotgunskill" ) ~= "none" then
				outputChatBox ( "Diesen Bonus hast du bereits gekauft!", player, 125, 0, 0 )
			else
				if bonuspoints >= 20 then
					outputChatBox ( "Du hast den Bonus gekauft!", player, 0, 125, 0 )
					setPedStat ( player, 72, 999 )
					setPedStat ( player, 74, 999 )
					MtxSetElementData ( player, "shotgunskill", "buyed" )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 20 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "ShotgunSkill", "buyed", "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " MP5" then
			if MtxGetElementData ( player, "mp5skill" ) ~= "none" then
				outputChatBox ( "Diesen Bonus hast du bereits gekauft!", player, 125, 0, 0 )
			else
				if bonuspoints >= 35 then
					outputChatBox ( "Du hast den Bonus gekauft!", player, 0, 125, 0 )
					setPedStat ( player, 76, 999 )
					MtxSetElementData ( player, "mp5skill", "buyed" )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 35 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "MP5Skills", "buyed", "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Vortex" then
			if MtxGetElementData ( player, "vortex" ) ~= "none" then
				outputChatBox ( "Diesen Bonus hast du bereits gekauft!", player, 125, 0, 0 )
			else
				if bonuspoints >= 30 then
					outputChatBox ( "Du hast den Bonus gekauft und kannst das Vortex nun an der Bonushalle erwerben!", player, 0, 125, 0 )
					outputChatBox ( "( LKW-Icon )", player, 0, 125, 0 )
					MtxSetElementData ( player, "vortex", "buyed" )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 30 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "Vortex", "buyed", "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Quad" then
			if MtxGetElementData ( player, "quad" ) ~= "none" then
				outputChatBox ( "Diesen Bonus hast du bereits gekauft!", player, 125, 0, 0 )
			else
				if bonuspoints >= 30 then
					outputChatBox ( "Du hast den Bonus gekauft und kannst das Quad nun an der Bonushalle erwerben!", player, 0, 125, 0 )
					outputChatBox ( "( LKW-Icon )", player, 0, 125, 0 )
					MtxSetElementData ( player, "quad", "buyed" )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 30 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "Quad", "buyed", "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Leichenwagen" then
			if MtxGetElementData ( player, "romero" ) == 1 then
				outputChatBox ( "Diesen Bonus hast du bereits gekauft!", player, 125, 0, 0 )
			else
				if bonuspoints >= 50 then
					outputChatBox ( "Du hast den Bonus gekauft und kannst den Leichenwagen nun an der Bonushalle erwerben!", player, 0, 125, 0 )
					outputChatBox ( "( LKW-Icon )", player, 0, 125, 0 )
					MtxSetElementData ( player, "romero", 1 )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 50 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "Leichenwagen", 1, "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Caddy" then
			if MtxGetElementData ( player, "golfcart" ) then
				outputChatBox ( "Diesen Bonus hast du bereits gekauft!", player, 125, 0, 0 )
			else
				if bonuspoints >= 25 then
					outputChatBox ( "Du hast den Bonus gekauft und kannst das Caddy nun an der Bonushalle erwerben!", player, 0, 125, 0 )
					outputChatBox ( "( LKW-Icon )", player, 0, 125, 0 )
					MtxSetElementData ( player, "golfcart", true )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 25 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "Caddy", 1, "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Skimmer" then
			if MtxGetElementData ( player, "skimmer" ) == 1 then
				outputChatBox ( "Diesen Bonus hast du bereits gekauft!", player, 125, 0, 0 )
			else
				if bonuspoints >= 50 then
					outputChatBox ( "Du hast den Bonus gekauft und kannst den Skimmer nun an der Bonushalle erwerben!", player, 0, 125, 0 )
					outputChatBox ( "( LKW-Icon )", player, 0, 125, 0 )
					MtxSetElementData ( player, "skimmer", 1 )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 50 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "Skimmer", 1, "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Fahrzeugslots" then
			outputChatBox ( "Fahrzeugslots bitte im Rathaus kaufen!", player, 255, 0, 0 )
		elseif bonus == " Cluckin Bell" then
			if MtxGetElementData ( player, "bonusskin1" ) ~= "none" then
				if not getPedOccupiedVehicle ( player ) then
					setElementModel ( player, 167 )
					MtxSetElementData ( player, "skinid", 167 )
				else
					outputChatBox ( "Du kannst deinen Skin nicht in Fahrzeugen verwenden!", player, 125, 0, 0 )
				end
			else
				if bonuspoints >= 25 then
					outputChatBox ( "Du hast den Skin gekauft! Waehle ihn jetzt aus, um ihn zu aktivieren!", player, 0, 125, 0 )
					MtxSetElementData ( player, "bonusskin1", "buyed" )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 25 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "BonusSkin1", "buyed", "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Notebook" then
			if MtxGetElementData ( player, "fruitNotebook" ) >= 1 then
				outputChatBox ( "Du hast dein Notebook bereits! Waehle es im Inventar aus!", player, 125, 0, 0 )
			else
				if bonuspoints >= 25 then
					outputChatBox ( "Du hast dein Notebook gekauft und kannst es jetzt im Inventar verwenden!", player, 0, 125, 0 )
					MtxSetElementData ( player, "fruitNotebook", 1 )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 25 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "inventar", "FruitNotebook", 1, "UID", playerUID[pname] )
					triggerClientEvent ( player, "refreshBonus", player, "" )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Fernglas" then
			if MtxGetElementData ( player, "fglass" ) then
				outputChatBox ( "Du hast bereits ein Fernglas in deinem Inventar!", player, 125, 0, 0 )
			else
				if bonuspoints >= 10 then
					outputChatBox ( "Fernglas gekauft - schau in deinem Inventar nach!", player, 0, 125, 0 )
					MtxSetElementData ( player, "fglass", true )
					MtxSetElementData ( player, "bonuspoints", bonuspoints - 10 )
					triggerClientEvent ( player, "refreshBonus", player, "" )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "fglass", "1", "UID", playerUID[pname] )
				else
					outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
				end
			end
		elseif bonus == " Doppel SMG" then
			if MtxGetElementData ( player, "doubleSMG" ) then
				if getPedStat ( player, 75 ) == 999 then
					setPedStat ( player, 75, 600 )
					outputChatBox ( "Es wird eine Waffe verwendet.", player, 200, 200, 0 )
				else
					setPedStat ( player, 75, 999 )
					outputChatBox ( "Es werdem zwei Waffen verwendet.", player, 200, 200, 0 )
				end
				else
					if bonuspoints >= 50 then
						outputChatBox ( "Skill gekauft!", player, 0, 125, 0 )
						setPedStat ( player, 75, 999 )
						MtxSetElementData ( player, "doubleSMG", true )
						MtxSetElementData ( player, "bonuspoints", bonuspoints - 50 )
						triggerClientEvent ( player, "refreshBonus", player, "" )
						dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "uzi", "1", "UID", playerUID[pname] )
					else
						outputChatBox ( "Du hast nicht genug Bonuspunkte!", player, 125, 0, 0 )
					end
				end
			end
	  end
end
addEvent ( "bonusBuy", true )
addEventHandler ( "bonusBuy", getRootElement(), bonusBuy_func )