guiObjectModels = { [2942]=true, [2190]=true, [2754]=true }
secondClickTypes = { ["ped"] = true, ["player"] = true, ["vehicle"] = true }
clickSpecialPeds = { [rathausped]=true, [vincenzo]=true, [aztecasBouncer]=true }

function player_click ( button, state, clickedElement, x, y, z )
	-- "source" ist die von MTA bereitgestellte, implizite Variable des ausloesenden
	-- Events. Diese Funktion laeuft ueber runAsync in einer Coroutine (siehe unten)
	-- und der Trunk-Zweig ruft dbQueryCoro auf, was die Coroutine pausiert (yield).
	-- Nach dem Fortsetzen ist der urspruengliche Event-Kontext vorbei und "source"
	-- global bereits nil/veraendert. Deshalb hier als echte Lua-Local sichern,
	-- die (anders als die MTA-Variable) die Coroutine-Pause uebersteht.
	local source = source
	if state == "down" and not getElementClicked ( source ) then
		
		if MtxGetElementData ( source, "adminEnterVehicle" ) then
			
			if isElement ( clickedElement ) then
				if getElementType( clickedElement ) == "vehicle" then
				
					if getVehicleOccupant ( clickedElement ) then
						removePedFromVehicle ( getVehicleOccupant ( clickedElement ) )
					end
					
					warpPedIntoVehicle ( source, clickedElement )
					MtxSetElementData ( source, "adminEnterVehicle", false )
				
					return nil
				
				end
			end
			
		end
	
		-- Keypads
		if fourDragonGateSwitches[clickedElement] then
			moveTriadCasinoGate_func ( source )
			return nil
		elseif MafiaCasinoKeypads and MafiaCasinoKeypads[clickedElement] then
			moveCasinoDoor ( source )
			return true
		end

		local x1, y1, z1 = getElementPosition ( source )
		local veh = getPedOccupiedVehicle ( source )

		if veh then
			if MtxGetElementData ( veh, "katjuscha" ) then
				fireKatjuscha ( MtxGetElementData ( veh, "katjuschaID" ), x, y, z )
				showCursor ( source, false )
				return nil
			end
		end
		
		-- Wanzen --
		
		if MtxGetElementData ( source, "wanzen" ) then
		
			if clickedElement then
			
				if getElementType( clickedElement ) == "vehicle" then
				
					createWanze ( source, clickedElement, x, y, z )
					return true
				
				else
				
					outputChatBox ( "Wanzen koennen nur an Autos oder in der Umgebung platziert werden!", source, 0, 125, 0 )
				
				end
				
			else
			
				createWanze ( source, clickedElement, x, y, z )
				return true

			end
		
		end
		
		-----------------

		-- Spezial --
		if not clickedElement then
			if MtxGetElementData ( source, "objectToPlace" ) or MtxGetElementData ( source, "airstrike" ) then
				if MtxGetElementData ( source, "airstrike" ) then
					MtxSetElementData ( source, "airstrike", false )
					createAirstrike ( source, x, y, z )
					showCursor ( source, false )
					setElementClicked ( source, false )
				end
				return true
			end
		end
		---------------
		
		if clickedElement then
		
			if getElementData( clickedElement, "bank_ped" ) == true then

				if not MtxGetElementData ( source, "hackingAtm" ) then
					triggerClientEvent ( source, "showCashPoint", getRootElement() )
					setElementClicked ( source, true )
				end

			end
		
		end

		-- Special Elements - Objekte --
		if clickedElement and not secondClickTypes[getElementType(clickedElement)] then
			local x2, y2, z2 = getElementPosition ( clickedElement )
			if getDistanceBetweenPoints3D ( x1, y1, z1, x2, y2, z2 ) <= 10 then
				local model = getElementModel ( clickedElement )
				local count = getElementData ( clickedElement, "count" )
				if guiObjectModels[model] then
					if model == 2942 then
						if not MtxGetElementData ( source, "hackingAtm" ) then
							triggerClientEvent ( source, "showCashPoint", getRootElement() )
							setElementClicked ( source, true )
						end
					elseif model == 2190 then
						if isOnDuty ( source ) or isArmy ( source ) or isFBI ( source ) then
							triggerClientEvent ( source, "wantedcomputer", getRootElement() )
							setElementClicked ( source, true )
						end
					elseif model == 2754 then
						triggerClientEvent ( source, "showChipBuy", source )
					end
				elseif MtxGetElementData ( clickedElement, "placeableObject" ) then
					if MtxGetElementData ( source, "premium" ) == true then
						if not MtxGetElementData ( source, "objectDelete" ) then
							outputChatBox ( "Du kannst dieses Objekt loeschen; Klicke es dazu erneut an!", source, 0, 125, 0 )
							MtxSetElementData ( source, "objectDelete", true )
							setTimer ( MtxSetElementData, 60000, 1, source, "objectDelete", nil )
						else
							destroyElement ( clickedElement )
						end
					end
				elseif MtxGetElementData ( clickedElement, "placeableObjectMySQL" ) then
					if MtxGetElementData ( source, "premium" ) == true then
						if not MtxGetElementData ( source, "objectDelete" ) then
							outputChatBox ( "Du kannst dieses Objekt löschen; Klicke es dazu erneut an!", source, 0, 125, 0 )
							MtxSetElementData ( source, "objectDelete", true )
							setTimer ( MtxSetElementData, 60000, 1, source, "objectDelete", nil )
						else
							local id = MtxGetElementData ( clickedElement, "id" )
							dbExec ( handler, "DELETE FROM ?? WHERE ??=?", "object", "id", id )
							destroyElement ( clickedElement )
						end
					end
				elseif MtxGetElementData ( clickedElement, "weed" ) then
					local x1, y1, z1 = getElementPosition ( source )
					local x2, y2, z2 = getElementPosition ( clickedElement )
					if getDistanceBetweenPoints3D ( x1, y1, z1, x2, y2, z2 ) <= 3 then
						local id = MtxGetElementData ( clickedElement, "id" )
						if weedPlants[id] then
						
							-- 20 Minuten = 1 Gramm, Deckel bei 50 Gramm (= 16,6 Stunden).
							-- Der Deckel stand frueher auf 100, obwohl die Meldung beim
							-- Anpflanzen 50 Gramm in 16.6h verspricht. Muss zur Anzeige in
							-- hobby/gardenclub/gardenclub_client.lua passen (WEED_MAX_GRAMM).
							local drugs = math.floor ( ( getMinTime () - MtxGetElementData ( clickedElement, "time" ) ) / 20 )

							if drugs > 50 then
								drugs = 50
							elseif drugs < 0 then
								if not isOnDuty ( source ) then
									outputChatBox ( "Die Drogen sind noch nicht bereit geerntet zu werden!", source, 255, 0, 0 )
									return
								end
							end
							destroyElement ( weedPlants[id] )
							weedPlants[id] = nil
							outputLog ( getPlayerName(source).." hat ID "..id.." geerntet und "..drugs.." bekommen!", "drogen" )
							dbExec ( handler, "DELETE FROM ?? WHERE ??=?", "weed", "id", id )
							
							outputChatBox ( "Du hast "..drugs.." Gramm Drogen geerntet!", source, 0, 125, 0 )
							MtxSetElementData ( source, "drugs", MtxGetElementData ( source, "drugs" ) + drugs )
						else
							destroyElement ( clickedElement )
						end
					end
				elseif gunBoxes[clickedElement] then
					triggerClientEvent ( source,"gunCrateMenue", getRootElement() )
					setElementFrozen ( source, true )
					setElementClicked ( source, true )
				elseif depots[clickedElement] then
					if isInDepotFaction ( source ) then
						local owner = MtxGetElementData ( source, "fraktion" )
						if owner == 6 or owner == 8 then
							owner = 1
						end
						-- Der Tresor gehoert einer bestimmten Fraktion (depots[clickedElement]) -
						-- nur Mitglieder GENAU dieser Fraktion duerfen ihn benutzen.
						if owner ~= depots[clickedElement] then
							outputChatBox ( "Das ist nicht die Kasse deiner Fraktion!", source, 125, 0, 0 )
						else
							setElementClicked ( source, true )
							triggerClientEvent ( source, "showFDepot", getRootElement(), factionDepotData["money"][owner], factionDepotData["mats"][owner], factionDepotData["drugs"][owner])
						end
					else
						outputChatBox ( "Du bist in einer ungueltigen Fraktion!", source, 125, 0, 0 )
					end
				end
				return true
			end
		end
		
		-- Special Elements - Player --
		if clickedElement then
			if secondClickTypes[getElementType(clickedElement)] then
				if getElementModel ( clickedElement ) == 283 and not getElementType ( clickedElement ) == "player" then
					if not MtxGetElementData ( source, "ticketOffered" ) then
						MtxSetElementData ( source, "ticketOffered", true )
						outputChatBox ( "Hier kannst du ein Strafzettel loesen, um ein Wanted zu loeschen.", source, 200, 200, 0 )
						outputChatBox ( "Kosten: 2.000 "..Tables.waehrung.."", source, 200, 200, 0 )
						setTimer ( MtxSetElementData, 30000, 1, source, "ticketOffered", false )
					else
						if MtxGetElementData ( source, "wanteds" ) == 1 then
							if MtxGetElementData ( source, "money" ) >= 2000 then
								MtxSetElementData ( source, "ticketOffered", false )
								outputChatBox ( "Strafzettel bezahlt!", source, 0, 125, 0 )
								setPlayerWantedLevel ( source, 0 )
								MtxSetElementData ( source, "wanteds", 0 )
								takePlayerSaveMoney ( source, 2000 )
							else
								outputChatBox ( "Ein Strafzettel kostet 2.000 "..Tables.waehrung.."", source, 125, 0, 0 )
							end
						else
							outputChatBox ( "Nur moeglich, wenn du ein Wanted hast!", source, 125, 0, 0 )
						end
					end
				elseif clickedElement == source then
					-- Klick auf sich selbst oeffnet bewusst nichts. Der Zweig
					-- muss bleiben, damit der Klick hier endet und nicht unten
					-- in der Behandlung fuer andere Spieler landet. Das eigene
					-- Menue gibt es ueber F4 und /self.
				elseif clickSpecialPeds[clickedElement] then
					if clickedElement == rathausped then
						triggerClientEvent ( source, "ShowRathausMenue", getRootElement() )
						showCursor ( source, true )
						setElementClicked ( source, true )
					-- Vincenzo und der Aztecas-Tuersteher sind deaktiviert: zu
					-- "showVincenzosGunshop"/"showAztecasGunshop" existiert clientseitig
					-- kein Empfaenger. Der Cursor wurde trotzdem eingeschaltet, wodurch
					-- der Spieler ohne Fenster damit haengen blieb.
					end
				elseif getElementType ( clickedElement ) == "vehicle" then
					local veh = clickedElement
					if MtxGetElementData ( source, "wanzen" ) then
						createWanze ( source, clickedElement, false, false, false )
					elseif getVehicleTrunkState ( veh ) then
						local data = (dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=? AND ??=?", "Kofferraum", "vehicles", "UID", playerUID[MtxGetElementData ( veh, "owner" )], "Slot", MtxGetElementData ( veh, "carslotnr_owner" ) ))[1]["Kofferraum"]
						local drugs = tonumber ( gettok ( data, 1, string.byte ( '|' ) ) )
						local mats = tonumber ( gettok ( data, 2, string.byte ( '|' ) ) )
						local gun = tonumber ( gettok ( data, 3, string.byte ( '|' ) ) )
						local ammo = tonumber ( gettok ( data, 4, string.byte ( '|' ) ) )
						triggerClientEvent ( source, "showTrunkGui", getRootElement(), drugs, mats, gun, ammo )
						MtxSetElementData ( source, "clickedVehicle", clickedElement )
						showCursor ( source, true )
						setElementClicked ( source, true )
					elseif not gangAreaUnderPreparation or not playerData[getPlayerName(source)] then
						triggerClientEvent ( source, "_createCarmenue", getRootElement(), clickedElement )
						MtxSetElementData ( source, "clickedVehicle", clickedElement )
						showCursor ( source, true )
						setElementClicked ( source, true )
					end
				elseif MtxGetElementData ( clickedElement, "clickPed" ) then
					local typ = MtxGetElementData ( clickedElement, "typ" )
					local item, price
					if typ == "bum" then
						item = "100 "..Tables.waehrung.."?!"
						price = "Burger"
					elseif typ == "gunbuyer" then
						if MtxGetElementData ( clickedElement, "item" ) == 4 then
							price = "Messer"
						elseif MtxGetElementData ( clickedElement, "item" ) == 22 then
							price = "9mm Pistole"
						else
							price = "AK-47"
						end
						item = tostring ( MtxGetElementData ( clickedElement, "price" ) ).." "..Tables.waehrung..""
					else
						price = tostring ( MtxGetElementData ( clickedElement, "price" ) ).." "..Tables.waehrung..""
					end
					if typ == "wdealer" then
						item = aiGunNames[MtxGetElementData ( clickedElement, "item" )]
					elseif typ == "dealer" then
						item = tostring ( MtxGetElementData ( clickedElement, "item" ) ).." g, \nDrogen"
					elseif typ == "sdealer" then
						item = tostring ( MtxGetElementData ( clickedElement, "item" ) ).." Stk.,\nHanfsamen"
					elseif typ == "car" then
						local i = MtxGetElementData ( clickedElement, "id" )
						local car = curAiCarSpots[i]["car"]
						item = MtxGetElementData ( car, "name" )
						price = MtxGetElementData ( car, "price" )
					end
					MtxSetElementData ( source, "curclicked", clickedElement )
					setElementClicked ( source, true )
					triggerClientEvent ( source, "showPedInteraction", getRootElement(), typ, item, price )
	                elseif(getElementType(clickedElement)=="player")then
					if(MtxGetElementData(clickedElement,"tazered")and isOnDuty(source))then
					grab_func(source,"grab",getPlayerName(clickedElement))
					else
						local pname = getPlayerName ( clickedElement )
						MtxSetElementData ( source, "curclicked", pname )
						setElementClicked ( source, true )
						triggerClientEvent ( source,"ShowInteraktionsguiGui", getRootElement() )
					end
				end
			end
		end
	end
end
addEventHandler ( "onPlayerClick", getRootElement (), function ( ... ) runAsync ( player_click, ... ) end )

function cancel_gui_server_func ( player )

	if player then source = player end
	if not MtxGetElementData ( source, "tazered" ) then end
	if MtxGetElementData(source,"nodmzone") == 1 then toggleControl ( source, "fire", false ) end
	if MtxGetElementData(source,"sprint") == 1 then toggleControl ( source, "sprint", false ) end
	showCursor ( source, false )
	setElementClicked ( source, false )
end
addEvent ("cancel_gui_server", true )
addEventHandler ( "cancel_gui_server", getRootElement (), cancel_gui_server_func )

function self_func ( player )

	if not getElementClicked ( player ) then
		triggerClientEvent ( player, "ShowSelfClickMenue", player )
		showCursor ( player, true )
		setElementClicked ( player, true )
	end
end
addCommandHandler ( "self", self_func )