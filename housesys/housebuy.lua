--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function housePickup ( player )

	if getElementModel ( source ) == 1273 or getElementModel ( source ) == 1272 then
		if MtxGetElementData ( source, "owner" ) == "none" then					--Frei
			preis = MtxGetElementData ( source, "preis" )
			triggerClientEvent ( player, "infobox_start", getRootElement(), "Dieses Haus steht\nzum Verkauf für\n"..preis.."!", 5000, 0, 125, 0 )
			outputChatBox ( "Tippe /buyhouse [bank/bar] um das Haus mit Bargeld/vom Konto zu kaufen (2% mehr Kosten!)", player, 0, 125, 0 )
			local x, y, z = getElementPosition ( source )
			MtxSetElementData ( player, "housex", x )
			MtxSetElementData ( player, "housey", y )
			MtxSetElementData ( player, "housez", z )
			MtxSetElementData ( player, "house", source )
			triggerClientEvent(player,"onCreateNewHouseGUI",player, source)
		elseif MtxGetElementData ( source, "owner" ) ~= "none" then				-- Verkauft
			if not MtxGetElementData ( source, "gangHQOf" ) then
				fix = ""
				if MtxGetElementData ( source, "miete" ) and MtxGetElementData ( source, "miete" ) > 0 then
					fix = "Miete: "..MtxGetElementData ( source, "miete" ).." "..Tables.waehrung..", /rent\nzum mieten!"
				else
					fix = ""
				end
				triggerClientEvent ( player, "infobox_start", getRootElement(), "Dieses Haus gehört:\n"..MtxGetElementData(source,"owner").."\n"..fix, 7500, 200, 200, 0 )
			end
			local x, y, z = getElementPosition ( source )
			MtxSetElementData ( player, "housex", x )
			MtxSetElementData ( player, "housey", y )
			MtxSetElementData ( player, "housez", z )
			MtxSetElementData ( player, "house", source )
			triggerClientEvent(player,"onCreateOwnerHouseGUI",player, source)
		end
	end
end


function buyhouse_func ( player, cmd, zahlart )

	if zahlart == "bank" or zahlart == "bar" then
		if MtxGetElementData ( player, "housex" ) ~= 0 then
			local haus = MtxGetElementData ( player, "house" )
			local x1, y1, z1 = getElementPosition ( player )
			local x2 = MtxGetElementData ( player, "housex" )
			local y2 = MtxGetElementData ( player, "housey" )
			local z2 = MtxGetElementData ( player, "housez" )
			local pname = getPlayerName ( player )
			local distance = getDistanceBetweenPoints3D ( x1, y1, z1, x2, y2, z2 )
			if distance < 5 then
				if MtxGetElementData ( haus, "owner" ) == "none" then
					if MtxGetElementData ( player, "playingtime" ) >= 180 then
						local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=? AND ?? LIKE ?", "Typ", "buyit", "HoechstbietenderUID", playerUID[pname], "Typ", "Houses" )
						if not result or not result[1] then
							if haus ~= "none" then
								if tonumber(MtxGetElementData ( player, "housekey" )) <= 0 then
									local hauskosten = tonumber(MtxGetElementData ( haus, "preis" ))
									if zahlart == "bank" then
										local hauskosten = hauskosten*1.02
										if MtxGetElementData ( player, "bankmoney" ) >= hauskosten then
											dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "houses", "UID", playerUID[pname], "ID", MtxGetElementData ( haus, "id" ) )
											
											MtxSetElementData ( player, "bankmoney", MtxGetElementData ( player, "bankmoney" ) - hauskosten )
											
											triggerClientEvent ( player, "createNewStatementEntry", player, "Hauskauf", hauskosten * - 1, "\n" )
											
											MtxSetElementData ( player, "housekey", MtxGetElementData ( haus, "id" ) )
											MtxSetElementData ( haus, "owner", pname )
											
											datasave_remote(player)
											MtxSetElementData ( player, "HaeuserGekauft", MtxGetElementData ( player, "HaeuserGekauft" ) + 1 )
											
											triggerClientEvent ( player, "infobox_start", getRootElement(), "Glückwunsch,\ndu hast das Haus\ngekauft!Für\nmehr Infos, öffne\ndas Hilfemenü!", 10000, 125, 0, 0 )
											triggerClientEvent ( player, "achievsound", getRootElement() )
											outputLog ( getPlayerName ( player ).." hat ein Haus gekauft ( "..MtxGetElementData ( haus, "id" ).." )", "house" )
											setHouseBought ( haus, pname )
											updatePartnerSpawnFromHouse ( player )
										else
											triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu hast nicht\ngenug Geld auf\ndemKonto!", 5000, 125, 0, 0 )
										end
									else
										if MtxGetElementData ( player, "money" ) >= hauskosten then
											dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "houses", "UID", playerUID[pname], "ID", MtxGetElementData ( haus, "id" ) )

											MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) - hauskosten )
											
											MtxSetElementData ( player, "housekey", MtxGetElementData ( haus, "id" ) )
											MtxSetElementData ( haus, "owner", pname )
											
											datasave_remote(player)
											MtxSetElementData ( player, "HaeuserGekauft", MtxGetElementData ( player, "HaeuserGekauft" ) + 1 )

											triggerClientEvent ( player, "infobox_start", getRootElement(), "Glückwunsch,\ndu hast das Haus\ngekauft!Für\nmehr Infos, öffne\ndas Hilfemenü!", 10000, 125, 0, 0 )
											triggerClientEvent ( player, "achievsound", getRootElement() )
											
											
											outputLog ( getPlayerName ( player ).." hat ein Haus gekauft ( "..MtxGetElementData ( haus, "id" ).." )", "house" )
											setHouseBought ( haus, pname )
											updatePartnerSpawnFromHouse ( player )
										else
											triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu hast nicht\ngenug Bargeld!", 5000, 125, 0, 0 )
										end
									end
									dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Hausschluessel", MtxGetElementData ( player, "housekey" ), "UID", playerUID[getPlayerName(player)] )
								else
									triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu hast bereits\nein Haus!", 5000, 125, 0, 0 )
								end
							end
						else
							outputChatBox ( "Du ersteigerst momentan bereits ein Haus!", player, 0, 125, 0 )
						end
					else
						triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nErst ab\n3 Stunden!", 5000, 125, 0, 0 )
					end
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu hast nicht\ngenug Geld!", 5000, 125, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist bei\nkeinem Haus!", 5000, 125, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist bei\nkeinem Haus!", 5000, 125, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nBitte als Zahlart\nbar oder bank\nangeben!!", 5000, 125, 0, 0 )
	end
end
addCommandHandler ( "buyhouse", function ( player, cmd, zahlart ) runAsync ( buyhouse_func, player, cmd, zahlart ) end )