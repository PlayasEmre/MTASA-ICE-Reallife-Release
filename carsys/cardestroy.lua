--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function privVehExplode ()
	destroyMagnet ( source )

	-- Wird ein Fahrzeug ohne Besitzer ( normaler Verkehr, Event-Fahrzeuge, ... )
	-- SOFORT im selben Moment der Explosion zerstoert, verschwindet es, bevor
	-- die Feuer-/Rauch-Explosionseffekte bei den Clients ueberhaupt sichtbar
	-- werden koennen - sie brauchen ein paar Sekunden, um durchzulaufen. Bei
	-- Fahrzeugen MIT Besitzer passierte das schon vorher nicht ( die blieben
	-- als Wrack liegen, siehe killRests unten ), deshalb war die Explosion
	-- dort schon immer sichtbar. Jetzt bekommen auch besitzerlose Fahrzeuge
	-- dieselbe kurze Verzoegerung, bevor sie endgueltig entfernt werden.
	if not MtxGetElementData ( source, "ownerfraktion" ) then
		local oname = MtxGetElementData ( source, "owner" )
		if oname then
			local owner = getPlayerFromName ( oname )
			local x1, y1, z1 = getElementPosition ( owner )
			local x2, y2, z2 = getElementPosition ( source )
			if MtxGetElementData ( owner, "loggedin" ) == 1 and getDistanceBetweenPoints3D ( x1, y1, z1, x2, y2, z2 ) < 7.5 then
				MtxSetElementData ( owner, "carslot"..MtxGetElementData(source, "carslotnr_owner" ), 0 )
				MtxSetElementData ( owner, "curcars", MtxGetElementData ( owner, "curcars" )-1 )
				if tonumber(MtxGetElementData ( source, "special" )) ~= 2 then outputChatBox ( "Dein Fahrzeug in Slot Nr. "..MtxGetElementData(source, "carslotnr_owner" ).." wurde zerstört!", owner, 125, 0, 0 ) end
				dbExec ( handler, "DELETE FROM ?? WHERE ??=? AND ??=?", "vehicles", "UID", playerUID[oname], "Slot", MtxGetElementData(source, "carslotnr_owner" ) )
				outputLog ( "Fahrzeug von "..oname.." ( "..MtxGetElementData(source, "carslotnr_owner" ).." ) wurde zerstoert. | Modell: "..getElementModel(source).." |", "explodecar" )
				SaveCarData ( owner )
			end
			if tonumber(MtxGetElementData ( source, "special" )) == 2 then
				MtxSetElementData ( owner, "yachtImBesitz", false )
				MtxSetElementData ( owner, "spawnpos_x", -2458.288085 )
				MtxSetElementData ( owner, "spawnpos_y", 774.354492 )
				MtxSetElementData ( owner, "spawnpos_z", 35.171875 )
				MtxSetElementData ( owner, "spawnrot_x", 52 )
				MtxSetElementData ( owner, "spawnint", 0 )
				MtxSetElementData ( owner, "spawndim", 0 )
				outputChatBox ( "Deine Yacht in Slot Nr. "..MtxGetElementData ( source, "carslotnr_owner" ).." wurde zerstört - du spawnst wieder auf der Straße!", owner, 125, 0, 0 )
				SaveCarData ( owner )
			end
		end
		-- Besitzerlos ( oname == nil ): frueher wurde hier sofort
		-- destroyElement() aufgerufen - das killte die Explosionseffekte.
		-- Jetzt einfach nichts extra tun: killRests unten schiebt das
		-- Fahrzeug nach der Verzoegerung weg, genau wie bei Fahrzeugen mit
		-- Besitzer auch, ohne es sofort zu zerstoeren.
	end

	setTimer ( killRests, 3000, 1, source )
end
addEventHandler ( "onVehicleExplode", getRootElement(), privVehExplode )

function killRests ( veh )

	if not isElement ( veh ) then
		return
	end

	setElementPosition ( veh, 999999, 999999, -50 )
end

function armoredRespawn ()

	if isEvilCar ( source ) then
	
		setElementHealth ( source, 2000 )
		
	elseif isFederalCar ( source ) then
		
		if getElementModel ( source ) == 601 then
			setElementHealth ( source, 5000 )
		elseif getElementModel ( source ) == 523 then
			setElementHealth ( source, 1000 )
		elseif getElementModel ( source ) == 599 then
			setElementHealth ( source, 2500 )
		elseif getElementModel ( source ) == 525 then
			setElementHealth ( source, 1000 )
		elseif getElementModel ( source ) == 427 then
			setElementHealth ( source, 5000 )
		elseif getElementModel ( source ) == 609 then
			setElementHealth ( source, 5000 )
		elseif getElementModel ( source ) == 490 then
			setElementHealth ( source, 2500 )
		elseif getElementModel ( source ) == 470 or getElementModel ( source ) == 548 or getElementModel ( source ) == 425 or getElementModel ( source ) == 520 or getElementModel ( source ) == 563 then
			setElementHealth ( source, 3000 )
		elseif getElementModel ( source ) == 433 then
			setElementHealth ( source, 5000 )
		else
			setElementHealth ( source, 2000 )
		end
		
	elseif getElementModel ( source ) == 432 then
	
		setElementHealth ( source, 8000 )
		
	end
	
end
addEventHandler ( "onVehicleRespawn", getRootElement(), armoredRespawn )