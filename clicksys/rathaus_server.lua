--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function LizenzKaufen_func ( player, lizens )

	if player == client then
		local pname = getPlayerName ( player )
		if lizens == "planeb" then
			if tonumber(MtxGetElementData ( player, "planelicenseb" )) == 0 then
				if tonumber(MtxGetElementData ( player, "money" )) >= 34950 then
					if MtxGetElementData ( player, "planelicensea" ) == 1 then
						MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - 34950 )
						MtxSetElementData ( player, "planelicenseb", 1 )
						triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nFluglizens\nTyp B erhalten!", 5000, 0, 255, 0 )
						playSoundFrontEnd ( player, 40 )
						dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "FlugscheinKlasseB", 1, "UID", playerUID[pname] )
					else
						triggerClientEvent ( player, "infobox_start", getRootElement(), "Du benoetigst\nzuerst einen\nFlugschein Typ A!", 5000, 255, 0, 0 )
					end
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast nicht\ngenug Geld!", 5000, 255, 0, 0 )
				end
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast bereits\neinen Flugschein!", 5000, 255, 0, 0 )
				end	
		elseif lizens == "wschein" then
			if tonumber(MtxGetElementData ( player, "gunlicense" )) == 0 then
				if tonumber(MtxGetElementData ( player, "money" )) >= 5000 then
					if tonumber(MtxGetElementData ( player, "playingtime" )) >= Tables.noobtime then
					if MtxGetElementData ( player, "level" ) >= 1 then
						MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - 5000 )
						outputChatBox ( "------------WAFFENSCHEIN INFORMATION------------", player, 0, 150, 0 )
						outputChatBox ( "Du hast soeben deinen Waffenschein erhalten, der dich zum Besitz einer Waffe berechtigt.", player, 0, 125, 0 )
						outputChatBox ( "Traegst du deine Waffen offen, so wird die Polizei sie dir abnehmen.", player, 0, 125, 0 )
						outputChatBox ( "Falls du zu oft negativ auffaellst ( z.b.\ndurch Schiesserein ), koennen sie dir ihn\nauch wieder abnehmen.", player, 0, 125, 0 )
						outputChatBox ( "Ausserdem: GRUNDLOSES Toeten von Spielern ist verboten. Gruende sind nicht: Geldgier, Hat mich angeguggt usw., sondern z.b. Selbstverteidigung oder Gangkriege.", player, 0, 125, 0 )
						outputChatBox ( "------------WAFFENSCHEIN INFORMATION------------", player, 0, 150, 0 )
						playSoundFrontEnd ( player, 40 )
						MtxSetElementData ( player, "gunlicense", 1 )
						dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Waffenschein", 1, "UID", playerUID[pname] )
						else
							outputChatBox ( "Du benötigst Level 1 um diese Lizenz kaufen zu können!", player, 255, 0, 0 )
						end
					else
						triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nErst ab 3\nStunden verfuegbar!", 5000, 255, 0, 0 )
					end
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu hast nicht\ngenug Geld!", 5000, 255, 0, 0 )
				end
			else
			     triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu hast bereits\neinen Waffenschein!", 5000, 255, 0, 0 )
			end
		elseif lizens == "planea" then
			if tonumber(MtxGetElementData ( player, "planelicensea" )) == 0 then
				if tonumber(MtxGetElementData ( player, "money" )) >= 15000 then
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - 15000 )
					MtxSetElementData ( player, "planelicensea", 1 )
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nFlugschein\nerhalten!", 5000, 0, 255, 0 )
					playSoundFrontEnd ( player, 40 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "FlugscheinKlasseA", 1, "UID", playerUID[pname] )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast nicht\ngenug Geld!", 5000, 255, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast bereits\neinen\nFlugschein!", 5000, 255, 0, 0 )
			end
		elseif lizens == "fishing" then
			if tonumber(MtxGetElementData ( player, "fishinglicense" )) == 0 then
				if tonumber(MtxGetElementData ( player, "money" )) >= 100 then
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - 100 )
					MtxSetElementData ( player, "fishinglicense", 1 )
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nAngelschein\nerhalten!", 5000, 0, 255, 0 )
					playSoundFrontEnd ( player, 40 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Angelschein", 1, "UID", playerUID[pname] )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast nicht\ngenug Geld!", 5000, 255, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast bereits\neinen Angelschein!", 5000, 255, 0, 0 )
			end
		elseif lizens == "perso" then
			if tonumber(MtxGetElementData ( player, "perso" )) == 0 then
				if tonumber(MtxGetElementData ( player, "money" )) >= 200 then
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - 200 )
					MtxSetElementData ( player, "perso", 1 )
					if tonumber(MtxGetElementData(player,"Introtask")) == 2 then
						outputChatBox("Herzlichen Glückwunsch, Sie haben eine Aufgabe erledigt! Du erhältst €2500",player,255,255,255)
						MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) + 2500 )
						MtxSetElementData ( player,"Introtask",3 )
					end
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nPersonalausweiss\nerhalten!", 5000, 0, 255, 0 )
					playSoundFrontEnd ( player, 40 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Perso", 1, "UID", playerUID[pname] )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast nicht\ngenug Geld!", 5000, 255, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast bereits\neinen\nPersonalausweiss!", 5000, 255, 0, 0 )
			end
		elseif lizens == "raft" then
			if tonumber(MtxGetElementData(player, "segellicense")) == 0 then
				if tonumber(MtxGetElementData(player, "money")) >= 200 then
					MtxSetElementData ( player, "money", MtxGetElementData(player, "money") - 200 )
					MtxSetElementData ( player, "segellicense", 1 )
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nSegellizens\nerhalten!", 5000, 0, 255, 0 )
					playSoundFrontEnd ( player, 40 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Segelschein", 1, "UID", playerUID[pname] )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast nicht\ngenug Geld!", 5000, 255, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast bereits\neinen Segelschein!", 5000, 255, 0, 0 )
			end
		elseif lizens == "maxveh" then
			if MtxGetElementData ( player, "carslotupgrade" ) ~= "buyed" then
				if tonumber(MtxGetElementData ( player, "money" )) >= fahrzeugslotprice[5] then
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - fahrzeugslotprice[5] )
					MtxSetElementData ( player, "carslotupgrade", "buyed" )
					MtxSetElementData ( player, "maxcars", 7 )
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nMax. Fahrzeuganzahl\nauf 7\nerhöht!", 5000, 0, 255, 0 )
					playSoundFrontEnd ( player, 40 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "CarslotUpgrades", "buyed", "UID", playerUID[pname] )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast nicht\ngenug Geld!", 5000, 255, 0, 0 )
				end
			elseif tonumber(MtxGetElementData ( player, "carslotupgrade2" )) ~= 1 then
				if tonumber(MtxGetElementData ( player, "money" )) >= fahrzeugslotprice[7] then
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - fahrzeugslotprice[7] )
					MtxSetElementData ( player, "carslotupgrade2", 1 )
					MtxSetElementData ( player, "maxcars", 9 )
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nMax. Fahrzeuganzahl\nauf 9\nerhöht!", 5000, 0, 255, 0 )
					playSoundFrontEnd ( player, 40 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "CarslotUpdate2", 1, "UID", playerUID[pname] )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast nicht\ngenug Geld!", 5000, 255, 0, 0 )
				end
			elseif tonumber(MtxGetElementData ( player, "carslotupgrade3" )) ~= 1 then
				if tonumber(MtxGetElementData ( player, "money" )) >= fahrzeugslotprice[9] then
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - fahrzeugslotprice[9] )
					MtxSetElementData ( player, "carslotupgrade3", 1 )
					MtxSetElementData ( player, "maxcars", 11 )
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nMax. Fahrzeuganzahl\nauf 11\nerhöht!", 5000, 0, 255, 0 )
					playSoundFrontEnd ( player, 40 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "CarslotUpdate3", 1, "UID", playerUID[pname] )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast nicht\ngenug Geld!", 5000, 255, 0, 0 )
				end
			elseif tonumber(MtxGetElementData ( player, "carslotupgrade4" )) ~= 1 then
				if tonumber(MtxGetElementData ( player, "money" )) >= fahrzeugslotprice[11] then
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - fahrzeugslotprice[11] )
					MtxSetElementData ( player, "carslotupgrade4", 1 )
					MtxSetElementData ( player, "maxcars", 13 )
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nMax. Fahrzeuganzahl\nauf 13\nerhöht!", 5000, 0, 255, 0 )
					playSoundFrontEnd ( player, 40 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "CarslotUpdate4", 1, "UID", playerUID[pname] )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast nicht\ngenug Geld!", 5000, 255, 0, 0 )
				end
			elseif tonumber(MtxGetElementData ( player, "carslotupgrade5" )) ~= 1 then
				if tonumber(MtxGetElementData ( player, "money" )) >= fahrzeugslotprice[13] then
					MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - fahrzeugslotprice[13] )
					MtxSetElementData ( player, "carslotupgrade5", 1 )
					if MtxGetElementData ( player, "premium" ) == true then
						MtxSetElementData ( player, "maxcars", 20 )
					else
						MtxSetElementData ( player, "maxcars", 15 )
					end
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nMax. Fahrzeuganzahl\nmaximiert!", 5000, 0, 255, 0 )
					playSoundFrontEnd ( player, 40 )
					dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "bonustable", "CarslotUpdate5", 1, "UID", playerUID[pname] )
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu hast nicht\ngenug Geld!", 5000, 255, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "Du hast bereits\ndie maximale\nFahrzeuganzahl\ngekauft!", 5000, 255, 0, 0 )
			end
		end
		checkAchievLicense ( player )
	end
end
addEvent ( "LizenzKaufen", true )
addEventHandler ( "LizenzKaufen", getRootElement(), LizenzKaufen_func )

function checkAchievLicense ( player )

	if tonumber ( MtxGetElementData ( player, "motorbootlicense" ) ) == 1 and tonumber ( MtxGetElementData ( player, "segellicense" ) ) == 1 and tonumber ( MtxGetElementData ( player, "helilicense" ) ) == 1 and tonumber ( MtxGetElementData ( player, "lkwlicense" ) ) == 1 and tonumber ( MtxGetElementData ( player, "lkwlicense" ) ) == 1 and tonumber ( MtxGetElementData ( player, "perso" ) )  == 1 and tonumber ( MtxGetElementData ( player, "carlicense" ) ) == 1 and tonumber ( MtxGetElementData ( player, "fishinglicense" ) ) == 1 and tonumber ( MtxGetElementData ( player, "planelicensea" ) ) == 1 and tonumber ( MtxGetElementData ( player, "planelicenseb" ) ) == 1 and tonumber ( MtxGetElementData ( player, "bikelicense" ) ) == 1 and tonumber ( MtxGetElementData ( player, "gunlicense" ) ) == 1 and MtxGetElementData ( player, "licenses_achiev" ) ~= "done" then
		if MtxGetElementData ( player, "licenses_achiev" ) ~= "done" then																						-- Achiev: Mr. License
			MtxSetElementData ( player, "licenses_achiev", "done" )																								-- Achiev: Mr. License
			triggerClientEvent ( player, "showAchievmentBox", player, " Mr. License", 40, 10000 )																-- Achiev: Mr. License
			MtxSetElementData ( player, "bonuspoints", tonumber(MtxGetElementData ( player, "bonuspoints" )) + 40 )												-- Achiev: Mr. License
			dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "achievments", "Lizensen", "done", "UID", playerUID[getPlayerName(player)] )						-- Achiev: Mr. License
		end	
	end
end