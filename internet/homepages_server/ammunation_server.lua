--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

ammunationDropCount = 1

function emailCheck_func ( version )

	if version == "Custom" and source == client then
		counter = 0
		local players = getElementsByType ( "player" )
		for i=1, #players do
			if ( tonumber ( MtxGetElementData ( players[i], "adminlvl" ) ) or 0 ) >= 1 then
				outputChatBox ( getPlayerName(client).." verwendet modifizierte Files!", players[i], 125, 0, 0 )
				counter = counter + 1
			end
		end
		if counter == 0 then
			local pname = getPlayerName(source)
			outputChatBox ( pname.." wurde vom Anticheatsystem gebannt.", getRootElement(), 255, 0, 0 )
			local ip = getPlayerIP ( source )
			local serial = getPlayerSerial ( source )
			reason = "Modifizierte Files"
			dbExec ( handler, "INSERT INTO ?? (??, ??, ??, ??, ??, ??) VALUES (?,?,?,?,?,?)", "ban", "UID", "AdminUID", "Grund", "Datum", "IP", "Serial", playerUID[getPlayerName(source)], 0, reason, timestamp(), ip, serial )
			kickPlayer ( source, "Vom Anticheat gebannt!" )
		end
	end
end
addEvent ( "emailCheck", true )
addEventHandler ( "emailCheck", getRootElement(), emailCheck_func )

function ammunationOnlineDeliver_func ( totalCost, ammunationOrderPistol, ammunationOrderDeagle, ammunationOrderShotty,ammunationOrderMP, ammunationOrderAK, ammunationOrderM, ammunationOrderG, ammunationOrderMP, ammunationOrderAK, ammunationOrderM, ammunationOrderG, ammunationOrderNVG, ammunationOrderWVG, ammunationOrderArmor, ammunationOrderPistolAmmo, ammunationOrderDeagleAmmo, ammunationOrderShottyAmmo, ammunationOrderMPAmmo, ammunationOrderAKAmmo, ammunationOrderMAmmo, ammunationOrderGAmmo )

	local player = client
	ammunationOrderPistol, ammunationOrderDeagle, ammunationOrderShotty, ammunationOrderMP = math.floor ( math.abs ( ammunationOrderPistol ) ), math.floor ( math.abs ( ammunationOrderDeagle ) ), math.floor ( math.abs ( ammunationOrderShotty ) ), math.floor ( math.abs ( ammunationOrderMP ) )
	ammunationOrderAK, ammunationOrderM, ammunationOrderG = math.floor ( math.abs ( ammunationOrderAK ) ), math.floor ( math.abs ( ammunationOrderM ) ), math.floor ( math.abs ( ammunationOrderG ) )
	ammunationOrderNVG = math.floor ( math.abs ( ammunationOrderNVG ) )
	ammunationOrderWVG = math.floor ( math.abs ( ammunationOrderWVG ) )
	ammunationOrderArmor = math.floor ( math.abs ( ammunationOrderArmor ) )
	ammunationOrderPistolAmmo = math.floor ( math.abs ( ammunationOrderPistolAmmo ) )
	ammunationOrderDeagleAmmo = math.floor ( math.abs ( ammunationOrderDeagleAmmo ) )
	
	ammunationOrderShottyAmmo = math.floor ( math.abs ( ammunationOrderShottyAmmo ) )
	ammunationOrderMPAmmo, ammunationOrderAKAmmo, ammunationOrderMAmmo, ammunationOrderGAmmo = math.floor ( math.abs ( ammunationOrderMPAmmo ) ),  math.floor ( math.abs ( ammunationOrderAKAmmo ) ),  math.floor ( math.abs ( ammunationOrderMAmmo ) ), math.floor ( math.abs ( ammunationOrderGAmmo ) )
	
	totalCost = 0
	
	totalCost = totalCost + pistol_gunshop_price * ammunationOrderPistol
	totalCost = totalCost + eagle_gunshop_price * ammunationOrderDeagle
	totalCost = totalCost + shotgun_gunshop_price * ammunationOrderShotty
	totalCost = totalCost + mp_gunshop_price * ammunationOrderMP
	totalCost = totalCost + ak_gunshop_price * ammunationOrderAK
	totalCost = totalCost + m_gunshop_price * ammunationOrderM
	totalCost = totalCost + gewehr_gunshop_price * ammunationOrderG
	totalCost = totalCost + ammunationOrderNVG * nvgoogles_price
	totalCost = totalCost + ammunationOrderArmor * armor_gunshop_price
	totalCost = totalCost + ammunationOrderWVG * tgoogles_price
	
	totalCost = totalCost + pistolammo_gunshop_price * ammunationOrderPistolAmmo
	totalCost = totalCost + eagleammo_gunshop_price * ammunationOrderDeagleAmmo
	totalCost = totalCost + shotgunammo_gunshop_price * ammunationOrderShottyAmmo
	totalCost = totalCost + mpammo_gunshop_price * ammunationOrderMPAmmo
	totalCost = totalCost + akammo_gunshop_price * ammunationOrderAKAmmo
	totalCost = totalCost + mammo_gunshop_price * ammunationOrderMAmmo
	totalCost = totalCost + gewehrammo_gunshop_price * ammunationOrderGAmmo
	
	if player == client then
		if getElementInterior ( player ) == 0 then
			if not gotLastHit[player] or gotLastHit[player] + healafterdmgtime <= getTickCount() then
				totalCost = math.abs ( totalCost )
				local totalCost = totalCost + 500
				triggerClientEvent ( player, "createNewStatementEntry", player, "Bestellung auf\nAmmunation.com", totalCost * -1, "Incl. 500 "..Tables.waehrung.."\nLieferkosten" )
				if totalCost <= MtxGetElementData ( player, "bankmoney" ) then
					MtxSetElementData ( player, "bankmoney", MtxGetElementData ( player, "bankmoney" ) - totalCost )
					outputChatBox ( "Deine Lieferung ist unterwegs!", player, 0, 125, 0 )
					local x, y, z = getElementPosition ( player )
					y = y - 2
					x = x - 2
					dropObject = createObject ( 2903, x, y, z+6.3+15 )
					moveObject ( dropObject, 9000, x, y, z+6.3 )
					setTimer ( destroyElement, 10000, 1, dropObject )
					setTimer ( createGunDeliveryPickup, 10000, 1, player, x, y, z, ammunationOrderPistol, ammunationOrderDeagle, ammunationOrderShotty,ammunationOrderMP, ammunationOrderAK, ammunationOrderM, ammunationOrderG, ammunationOrderMP, ammunationOrderAK, ammunationOrderM, ammunationOrderG, ammunationOrderNVG, ammunationOrderWVG, ammunationOrderArmor, ammunationOrderPistolAmmo, ammunationOrderDeagleAmmo, ammunationOrderShottyAmmo, ammunationOrderMPAmmo, ammunationOrderAKAmmo, ammunationOrderMAmmo, ammunationOrderGAmmo )
				else
					outputChatBox ( "Du hast nicht genug Geld - deine Sendung würde "..totalCost.." "..Tables.waehrung.." kosten!", player, 125, 0, 0 )
				end
			else
				outputChatBox ( "Es muss dafür "..( healafterdmgtime/1000 ) .." Sekunden nach dem letzten Schuss vergangen sein!", player, 200, 0, 0 )
			end
		else
			outputChatBox ( "Das kannst du hier nicht bestellen.", player, 125, 0, 0 )
		end
	end
end
addEvent ( "ammunationOnlineDeliver", true )
addEventHandler ( "ammunationOnlineDeliver", getRootElement(), ammunationOnlineDeliver_func )

function createGunDeliveryPickup ( playeritem, x, y, z, ammunationOrderPistol, ammunationOrderDeagle, ammunationOrderShotty,ammunationOrderMP, ammunationOrderAK, ammunationOrderM, ammunationOrderG, ammunationOrderMP, ammunationOrderAK, ammunationOrderM, ammunationOrderG, ammunationOrderNVG, ammunationOrderWVG, ammunationOrderArmor, ammunationOrderPistolAmmo, ammunationOrderDeagleAmmo, ammunationOrderShottyAmmo, ammunationOrderMPAmmo, ammunationOrderAKAmmo, ammunationOrderMAmmo, ammunationOrderGAmmo )

	local colSphereAmmunation = createColSphere ( x, y, z, 2 )
	if getElementDimension(playeritem) == 14 then
        setElementDimension (colSphereAmmunation, 14)
    end
	local players = getElementsWithinColShape ( colSphereAmmunation, "player" )
	destroyElement ( colSphereAmmunation )
	for i=1, #players do
		givePlayerWeaponsFromDelivery ( players[i], ammunationOrderPistol, ammunationOrderDeagle, ammunationOrderShotty,ammunationOrderMP, ammunationOrderAK, ammunationOrderM, ammunationOrderG, ammunationOrderMP, ammunationOrderAK, ammunationOrderM, ammunationOrderG, ammunationOrderNVG, ammunationOrderWVG, ammunationOrderArmor, ammunationOrderPistolAmmo, ammunationOrderDeagleAmmo, ammunationOrderShottyAmmo, ammunationOrderMPAmmo, ammunationOrderAKAmmo, ammunationOrderMAmmo, ammunationOrderGAmmo )
		return
	end
	_G["gunPickup"..ammunationDropCount] = createPickup ( x, y, z, 3, 1210 )
	local pickup = _G["gunPickup"..ammunationDropCount]
	if getElementDimension(playeritem) == 14 then
    	setElementDimension (pickup, 14)
    end
	
	MtxSetElementData ( pickup, "ammunationOrderPistol", ammunationOrderPistol + ammunationOrderPistolAmmo )
	MtxSetElementData ( pickup, "ammunationOrderDeagle", ammunationOrderDeagle + ammunationOrderDeagleAmmo )
	MtxSetElementData ( pickup, "ammunationOrderShotty", ammunationOrderShotty + ammunationOrderShottyAmmo )
	MtxSetElementData ( pickup, "ammunationOrderMP", ammunationOrderMP + ammunationOrderMPAmmo )
	MtxSetElementData ( pickup, "ammunationOrderAK", ammunationOrderAK + ammunationOrderAKAmmo )
	MtxSetElementData ( pickup, "ammunationOrderM", ammunationOrderM + ammunationOrderMAmmo )
	MtxSetElementData ( pickup, "ammunationOrderG", ammunationOrderG + ammunationOrderGAmmo )
	MtxSetElementData ( pickup, "ammunationOrderNVG", ammunationOrderNVG )
	MtxSetElementData ( pickup, "ammunationOrderWVG", ammunationOrderWVG )
	MtxSetElementData ( pickup, "ammunationOrderArmor", ammunationOrderArmor )
	
	addEventHandler ( "onPickupHit", pickup,
		function ( player )
			if MtxGetElementData ( player, "gunlicense" ) == 1 then
				playSoundFrontEnd ( player, 40 )
				
				ammunationOrderPistol = MtxGetElementData ( source, "ammunationOrderPistol" )
				ammunationOrderDeagle = MtxGetElementData ( source, "ammunationOrderDeagle" )
				ammunationOrderShotty = MtxGetElementData ( source, "ammunationOrderShotty" )
				ammunationOrderMP = MtxGetElementData ( source, "ammunationOrderMP" )
				ammunationOrderAK = MtxGetElementData ( source, "ammunationOrderAK" )
				ammunationOrderM = MtxGetElementData ( source, "ammunationOrderM" )
				ammunationOrderG = MtxGetElementData ( source, "ammunationOrderG" )
				ammunationOrderNVG = MtxGetElementData ( source, "ammunationOrderNVG" )
				ammunationOrderWVG = MtxGetElementData ( source, "ammunationOrderWVG" )
				ammunationOrderArmor = MtxGetElementData ( source, "ammunationOrderArmor" )
				givePlayerWeaponsFromDelivery ( player, ammunationOrderPistol, ammunationOrderDeagle, ammunationOrderShotty,ammunationOrderMP, ammunationOrderAK, ammunationOrderM, ammunationOrderG, ammunationOrderMP, ammunationOrderAK, ammunationOrderM, ammunationOrderG, ammunationOrderNVG, ammunationOrderWVG, ammunationOrderArmor )
				destroyElement ( source )
			else
				outputChatBox ( "Du hast keinen Waffenschein!", player, 125, 0, 0 )
			end
		end
	)
	ammunationDropCount = ammunationDropCount + 1
end

function givePlayerWeaponsFromDelivery ( player, ammunationOrderPistol, ammunationOrderDeagle, ammunationOrderShotty, ammunationOrderMP, ammunationOrderAK, ammunationOrderM, ammunationOrderG, ammunationOrderMP, ammunationOrderAK, ammunationOrderM, ammunationOrderG, ammunationOrderNVG, ammunationOrderWVG, ammunationOrderArmor )
	local weaponbought = false
	local armorbought = false
	if MtxGetElementData ( player, "gunlicense" ) == 1 then
		if (ammunationOrderPistol)*17 > 0 then
			giveWeapon ( player, 22, (ammunationOrderPistol)*17 )
			weaponbought = true
		elseif ammunationOrderDeagle*7 > 0 then
			giveWeapon ( player, 24, (ammunationOrderDeagle)*7 )
			weaponbought = true
		end
		if (ammunationOrderAK)*30 > 0 then
			giveWeapon ( player, 30, (ammunationOrderAK)*30 )
			weaponbought = true
		elseif ammunationOrderM * 50 > 0 then
			giveWeapon ( player, 31, (ammunationOrderM)*50 )
			weaponbought = true
		end
		if ammunationOrderShotty > 0 then
			giveWeapon ( player, 25, (ammunationOrderShotty)*5 )
			weaponbought = true
		end
		if ammunationOrderMP > 0 then
			giveWeapon ( player, 29, (ammunationOrderMP)*30 )
			weaponbought = true
		end
		if ammunationOrderG > 0 then
			giveWeapon ( player, 33, (ammunationOrderG) )
			weaponbought = true
		end
		if ammunationOrderNVG then
			if ammunationOrderNVG > 0 then
				giveWeapon ( player, 44, ammunationOrderNVG )
				weaponbought = true
			end
		end
		if ammunationOrderWVG then
			if ammunationOrderWVG > 0 then
				giveWeapon ( player, 45, ammunationOrderWVG )
				weaponbought = true
			end
		end
		if ammunationOrderArmor > 0 then
			setPedArmor ( player, 100*ammunationOrderArmor )
			armorbought = true
		end
		if armorbought and weaponbought then
			outputLog ( getPlayerName(player).." hat Waffe und Weste bestellt.", "Heilung" )
		elseif armorbought then
			outputLog ( getPlayerName(player).." hat Weste bestellt.", "Heilung" )
		elseif weaponbought then
			outputLog ( getPlayerName(player).." hat Waffe bestellt.", "Heilung" )
		end
			
			
		outputChatBox ( "Lieferung erhalten!", player, 0, 125, 0 )
	else
		outputChatBox ( "Du hast keinen Waffenschein!", player, 125, 0, 0 )
	end
end