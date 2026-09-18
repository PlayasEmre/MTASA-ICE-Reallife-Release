--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local GANG_MSG_MAXLAENGE = 200
local GANG_RANGNAME_MAXLAENGE = 32
local GANG_NAME_MAXLAENGE = 32

local function istGangMitglied ( player, id )
	if not id or id == false or id <= 0 then
		return false
	end
	return getPlayerGang ( player ) == id
end

local function zahlAusEingabe ( wert )
	local zahl = tonumber ( wert )
	if not zahl then
		return nil
	end
	zahl = math.floor ( math.abs ( zahl ) )
	if zahl ~= zahl or zahl == math.huge then
		return nil
	end
	return zahl
end

local function textAusEingabe ( wert, maxLaenge )
	if type ( wert ) ~= "string" then
		return nil
	end
	wert = wert:gsub ( "^%s+", "" ):gsub ( "%s+$", "" )
	if #wert < 1 then
		return nil
	end
	if #wert > maxLaenge then
		wert = wert:sub ( 1, maxLaenge )
	end
	return wert
end

function creategang_func ( player )

	local housekey = MtxGetElementData ( player, "housekey" )
	if housekey > 0 then
		local pname = getPlayerName ( player )
		if MtxGetElementData ( player, "fraktion" ) == 0 then
			if not isInGang ( pname, nil ) then
				if isGang ( housekey ) then
					infobox ( player, "\n\nIn deinem Haus\ngibt es bereits\neine Gang!", 5000, 125, 0, 0 )
					return
				end
				local bankmoney = MtxGetElementData ( player, "bankmoney" )
				if bankmoney >= costsToCreateGang then
					if not MtxGetElementData ( player, "gangCreateTry" ) then
						MtxSetElementData ( player, "gangCreateTry", true )
						outputChatBox ( "Du willst eine Gang gruenden - das wird dich "..formNumberToMoneyString ( costsToCreateGang ).." kosten.", player, 200, 200, 0 )
						outputChatBox ( "Tippe erneut /creategang, um zu bestaetigen.", player, 200, 200, 0 )
					else
						MtxSetElementData ( player, "gangCreateTry", false )
						createNewGang ( pname.."s Gang", getElementModel ( player ), housekey )
						insertInGang ( pname, housekey, 3, true )
						if isElement ( player ) then
							outputChatBox ( "Du hast soeben deine eigene Gang gegruendet - Mehr erfaehrst du im Hausmenue.", player, 0, 125, 0 )
							MtxSetElementData ( player, "bankmoney", MtxGetElementData ( player, "bankmoney" ) - costsToCreateGang )
						end
					end
				else
					infobox ( player, "\n\nEine neue Gang\nzu erstellen kostet\n"..formNumberToMoneyString ( costsToCreateGang ), 5000, 125, 0, 0 )
				end
			else
				infobox ( player, "\n\n\nDu bist bereits\nin einer Gang!", 5000, 125, 0, 0 )
			end
		else
			infobox ( player, "\n\n\nDu bist in\neiner Fraktion!", 5000, 125, 0, 0 )
		end
	else
		infobox ( player, "\n\n\nDu hast kein\neigenes Haus!", 5000, 125, 0, 0 )
	end
end
addCommandHandler ( "creategang", creategang_func )

addEventHandler ( "onPlayerQuit", getRootElement(), function ()
	if MtxGetElementData ( source, "gangCreateTry" ) then
		MtxSetElementData ( source, "gangCreateTry", false )
	end
end )

function leavegang_func ( player )

	local pname = getPlayerName ( player )
	if isInGang ( pname ) then
		if not isInGang ( pname, MtxGetElementData ( player, "housekey" ) ) then
			removePlayerFromGang ( pname )
			infobox ( player, "\n\n\nDu hast deine\nGang verlassen.", 5000, 125, 0, 0 )
		else
			infobox ( player, "\n\n\nDu musst die\nGang erst auf-\nloesen.", 5000, 125, 0, 0 )
		end
	end
end
addCommandHandler ( "leavegang", leavegang_func )

function guninvite_func ( player, cmd, name )

	if not name then
		infobox ( player, "\n\nBenutzung:\n/ganguninvite [Name]", 5000, 125, 0, 0 )
		return
	end

	local gang = getPlayerGang ( player )
	if not gang or gang <= 0 then
		infobox ( player, "\n\n\nDu bist in\nkeiner Gang!", 5000, 125, 0, 0 )
		return
	end

	if getPlayerGangRank ( player ) < 3 then
		infobox ( player, "\n\nDu hast nicht\ndie erforderlichen\nRechte!", 5000, 125, 0, 0 )
		return
	end

	local uninvitedPlayer = getPlayerFromName ( name )
	local zielName = uninvitedPlayer and getPlayerName ( uninvitedPlayer ) or name

	if not playerUID[zielName] then
		infobox ( player, "\n\n\nUngueltiger Spieler!", 5000, 125, 0, 0 )
		return
	end

	if getPlayerGang ( zielName ) ~= gang then
		infobox ( player, "\n\nDer Spieler ist\nnicht in deiner\nGang!", 5000, 125, 0, 0 )
		return
	end

	if isFounderOfGang ( zielName ) then
		infobox ( player, "\n\n\nDer Spieler ist\nder Gruender!", 5000, 125, 0, 0 )
		return
	end

	if zielName == getPlayerName ( player ) then
		infobox ( player, "\n\nDu kannst dich nicht\nselbst rauswerfen -\nnutze /leavegang.", 5000, 125, 0, 0 )
		return
	end

	removePlayerFromGang ( zielName )

	if isElement ( uninvitedPlayer ) then
		outputChatBox ( getPlayerName ( player ).." hat dich aus der Gang geworfen.", uninvitedPlayer, 125, 0, 0 )
	end
	if isElement ( player ) then
		outputChatBox ( "Du hast "..zielName.." aus der Gang geworfen.", player, 0, 200, 0 )
	end
end
addCommandHandler ( "ganguninvite", guninvite_func )

function ginvite_func ( player, cmd, name )

	if not name then
		infobox ( player, "\n\nBenutzung:\n/ganginvite [Name]", 5000, 125, 0, 0 )
		return
	end

	local invitedPlayer = getPlayerFromName ( name )
	local pname = getPlayerName ( player )
	if invitedPlayer then
		if invitedPlayer == player then
			infobox ( player, "\n\nDu kannst dich nicht\nselbst einladen!", 5000, 125, 0, 0 )
			return
		end
		if isInGang ( player ) then
			if not isInGang ( invitedPlayer ) then
				if getPlayerGangRank ( player ) >= 3 then
					local id = getPlayerGang ( player )
					if MtxGetElementData ( invitedPlayer, "fraktion" ) == 0 then
						if getMembersInGangCount ( id ) < getGangMaxMembers ( id ) then
							insertInGang ( getPlayerName ( invitedPlayer ), id, 1 )
							infobox ( player, "\n\nDu hast "..name.."\nin deine Gang\naufgenommen.", 5000, 0, 200, 0 )
							infobox ( invitedPlayer, "\n\nDu wurdest von\n"..pname.." in eine\nGang eingeladen.", 5000, 0, 200, 0 )
						else
							infobox ( player, "\nDie Gang ist voll!\nMelde dich im\n Forum oder wirf\njemanden raus!", 5000, 125, 0, 0 )
						end
					else
						infobox ( player, "\n\n\nDer Spieler ist\nbereits in einer\nFraktion!", 5000, 125, 0, 0 )
					end
				else
					infobox ( player, "\n\n\nDu bist nicht\nbefugt!", 5000, 125, 0, 0 )
				end
			else
				infobox ( player, "\n\nDer Spieler ist\nbereits in einer\nGang!", 5000, 125, 0, 0 )
			end
		else
			infobox ( player, "\n\n\nDu bist in\nkeiner Gang!", 5000, 125, 0, 0 )
		end
	else
		infobox ( player, "\n\n\nUngueltiger Spieler!", 5000, 125, 0, 0 )
	end
end
addCommandHandler ( "ganginvite", ginvite_func )

function ggiverank_func ( player, cmd, name, rank )

	if not name or not rank then
		infobox ( player, "\n\nBenutzung:\n/ganggiverank\n[Name] [1-3]", 5000, 125, 0, 0 )
		return
	end

	local neuerRang = zahlAusEingabe ( rank )
	if not neuerRang or neuerRang < 1 or neuerRang > 3 then
		infobox ( player, "\n\nUngueltiger Rang!\nErlaubt: 1 bis 3", 5000, 125, 0, 0 )
		return
	end

	local member = getPlayerFromName ( name )
	local zielName = member and getPlayerName ( member ) or name

	if not playerUID[zielName] then
		infobox ( player, "\n\n\nUngueltiger Spieler!", 5000, 125, 0, 0 )
		return
	end

	local gang = getPlayerGang ( player )
	if not gang or gang <= 0 or getPlayerGang ( zielName ) ~= gang then
		infobox ( player, "\n\n\nUngueltiger Spieler!", 5000, 125, 0, 0 )
		return
	end

	if getPlayerGangRank ( player ) < 3 then
		infobox ( player, "\n\n\nDu bist nicht\nbefugt!", 5000, 125, 0, 0 )
		return
	end

	if zielName == getPlayerName ( player ) then
		infobox ( player, "\n\nDu darfst dir nicht\nselbst einen Rang\nsetzen!", 5000, 125, 0, 0 )
		return
	end

	if isFounderOfGang ( zielName ) then
		infobox ( player, "\n\nDer Rang des\nGruenders ist nicht\naenderbar!", 5000, 125, 0, 0 )
		return
	end

	setPlayerGangRank ( zielName, neuerRang )
	infobox ( player, "Rang gesetzt.", 5000, 0, 125, 0 )
end
addCommandHandler ( "ganggiverank", ggiverank_func )

function gangLeaderChangeRecieve_func ( field, v1, v2, v3 )

	local player = client
	if not isElement ( player ) or MtxGetElementData ( player, "loggedin" ) ~= 1 then
		return
	end

	local id = getPlayerGang ( player )
	if not isElement ( player ) then
		return
	end

	if not id or id <= 0 or not isGang ( id ) then
		infobox ( player, "\n\n\nDu bist in\nkeiner Gang!", 5000, 125, 0, 0 )
		return
	end

	local rang = getPlayerGangRank ( player ) or 0
	local pname = getPlayerName ( player )

	for i = 1, 3 do
		if field == "rank"..i then
			return nil
		end
	end

	if field == "take" or field == "store" then
		local take = ( field == "take" )
		if take and rang < 3 then
			infobox ( player, "Dazu bist du\nnicht berechtigt.", 5000, 125, 0, 0 )
			return nil
		end

		v2 = zahlAusEingabe ( v2 )
		if not v2 or v2 < 1 then
			infobox ( player, "Ungueltige Menge.", 5000, 125, 0, 0 )
			return nil
		end

		if v1 == "money" then
			if take then
				if getGangMoney ( id ) >= v2 then
					local money = MtxGetElementData ( player, "money" )
					MtxSetElementData ( player, "money", money + v2 )
					setGangMoney ( id, getGangMoney ( id ) - v2 )
				else
					infobox ( player, "Nicht genug Geld\nim Lager.", 5000, 125, 0, 0 )
					return nil
				end
			else
				local money = MtxGetElementData ( player, "money" )
				if money >= v2 then
					MtxSetElementData ( player, "money", money - v2 )
					setGangMoney ( id, getGangMoney ( id ) + v2 )
				else
					infobox ( player, "Du hast nicht\ngenug Geld dabei.", 5000, 125, 0, 0 )
					return nil
				end
			end
		elseif v1 == "drugs" then
			local drugs = MtxGetElementData ( player, "drugs" )
			if take then
				if getGangDrugs ( id ) >= v2 then
					MtxSetElementData ( player, "drugs", drugs + v2 )
					setGangDrugs ( id, getGangDrugs ( id ) - v2 )
				else
					infobox ( player, "Nicht genug Drogen\nim Lager.", 5000, 125, 0, 0 )
					return nil
				end
			else
				if drugs >= v2 then
					MtxSetElementData ( player, "drugs", drugs - v2 )
					setGangDrugs ( id, getGangDrugs ( id ) + v2 )
				else
					infobox ( player, "Du hast nicht\ngenug Drogen\ndabei.", 5000, 125, 0, 0 )
					return nil
				end
			end
		elseif v1 == "mats" then
			local mats = MtxGetElementData ( player, "mats" )
			if take then
				if getGangMats ( id ) >= v2 then
					MtxSetElementData ( player, "mats", mats + v2 )
					setGangMats ( id, getGangMats ( id ) - v2 )
				else
					infobox ( player, "Nicht genug Mats\nim Lager.", 5000, 125, 0, 0 )
					return nil
				end
			else
				if mats >= v2 then
					MtxSetElementData ( player, "mats", mats - v2 )
					setGangMats ( id, getGangMats( id ) + v2 )
				else
					infobox ( player, "Du hast nicht\ngenug Mats\ndabei.", 5000, 125, 0, 0 )
					return nil
				end
			end
		else
			return nil
		end
		infobox ( player, "Lager benutzt.", 5000, 0, 125, 0 )

	elseif field == "changeGangWeapon" then
		if rang < 3 then
			infobox ( player, "Du bist nicht\nberechtigt!", 5000, 125, 0, 0 )
			return nil
		end
		v1 = tonumber ( v1 )
		if v1 and validWeaponsForGang[v1] then
			dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "gang_basic", "Waffe", v1, "HausID", id )
			infobox ( player, "Gangwaffe geaendert.", 5000, 0, 125, 0 )
		else
			infobox ( player, "Diese Waffe ist\nnicht erlaubt!", 5000, 125, 0, 0 )
		end

	elseif field == "renameGang" then
		if isFounderOfGang ( player ) then
			local neuerName = textAusEingabe ( v1, GANG_NAME_MAXLAENGE )
			if not neuerName then
				infobox ( player, "Ungueltiger Name!", 5000, 125, 0, 0 )
			elseif getGangFromName ( neuerName ) then
				infobox ( player, "Dieser Name ist\nbereits vergeben!", 5000, 125, 0, 0 )
			else
				setGangName ( id, neuerName )
				infobox ( player, "Name geaendert.", 5000, 0, 125, 0 )
			end
		else
			infobox ( player, "Dazu ist nur\nder Gruender be-\nrechtigt.", 5000, 125, 0, 0 )
		end

	elseif field == "deleteGang" then
		if isFounderOfGang ( player ) then
			deleteGang ( id )
		else
			infobox ( player, "Nur der Gruender\nist zum loeschen\neiner Gang berechtigt.", 5000, 125, 0, 0 )
		end

	elseif field == "giveRank" then
		if rang < 3 then
			infobox ( player, "Dazu bist du\nnicht berechtigt.", 5000, 125, 0, 0 )
			return nil
		end
		v2 = zahlAusEingabe ( v2 )
		if not v2 or v2 < 1 or v2 > 3 then
			infobox ( player, "Ungueltiger Wert!", 5000, 125, 0, 0 )
			return nil
		end
		if type ( v1 ) ~= "string" or v1 == pname then
			infobox ( player, "Du darfst dir\nnicht selbst einen\nRang setzen!", 5000, 125, 0, 0 )
			return nil
		end
		if not playerUID[v1] or getPlayerGang ( v1 ) ~= id then
			infobox ( player, "Ungueltiger Spieler!", 5000, 125, 0, 0 )
			return nil
		end
		if isFounderOfGang ( v1 ) then
			infobox ( player, "Der Rang des\nGruenders ist nicht\naenderbar!", 5000, 125, 0, 0 )
			return nil
		end
		setPlayerGangRank ( v1, v2 )
		infobox ( player, "Rang gesetzt.", 5000, 0, 125, 0 )

	elseif field == "invite" then
		if rang < 3 then
			infobox ( player, "Du bist nicht\nberechtigt!", 5000, 125, 0, 0 )
			return nil
		end
		if type ( v1 ) == "string" and getPlayerFromName ( v1 ) then
			ginvite_func ( player, "ganginvite", v1 )
		else
			infobox ( player, "Ungueltiger Spieler!", 5000, 125, 0, 0 )
		end

	elseif field == "uninvite" then
		if rang < 3 then
			infobox ( player, "Du bist nicht\nberechtigt!", 5000, 125, 0, 0 )
			return nil
		end
		if type ( v1 ) == "string" then
			guninvite_func ( player, "ganguninvite", v1 )
		else
			infobox ( player, "Ungueltiger Spieler!", 5000, 125, 0, 0 )
		end

	elseif field == "pinboard" then
		if rang < 3 then
			infobox ( player, "Du bist nicht\nbefugt.", 5000, 125, 0, 0 )
			return nil
		end
		local text = textAusEingabe ( v1, GANG_MSG_MAXLAENGE )
		if text then
			setGangMSG ( id, text )
			infobox ( player, "Pinnwand geaendert.", 5000, 0, 125, 0 )
		end

	elseif field == "useSkin" then
		local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Skin", "gang_basic", "HausID", id )
		if not isElement ( player ) then return nil end
		local skin = result and result[1] and tonumber ( result[1]["Skin"] )
		if skin and skinname[skin] then
			MtxSetElementData ( player, "skinid", skin )
			setElementModel ( player, skin )
			infobox ( player, "Skin angenommen!", 5000, 0, 125, 0 )
		else
			infobox ( player, "Es ist kein gueltiger\nGang-Skin gesetzt.", 5000, 125, 0, 0 )
		end

	elseif field == "setSkin" then
		if rang < 3 then
			infobox ( player, "Du bist nicht\nberechtigt!", 5000, 125, 0, 0 )
			return nil
		end
		local skin = getElementModel ( player )
		if skinname[skin] then
			dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "gang_basic", "Skin", skin, "HausID", id )
			infobox ( player, "Skin geaendert!", 5000, 0, 125, 0 )
		else
			infobox ( player, "Dieser Skin ist\nnicht verfuegbar!", 5000, 125, 0, 0 )
		end

	elseif field == "equip" then
		local money = MtxGetElementData ( player, "money" )
		if money < costsToArm then
			infobox ( player, "Du hast nicht\ngenug Geld!", 5000, 125, 0, 0 )
			return nil
		end

		local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Waffe", "gang_basic", "HausID", id )
		if not isElement ( player ) then return nil end

		local waffe = result and result[1] and tonumber ( result[1]["Waffe"] )
		if not waffe or not validWeaponsForGang[waffe] then
			infobox ( player, "Es ist keine gueltige\nGangwaffe gesetzt.", 5000, 125, 0, 0 )
			return nil
		end

		money = MtxGetElementData ( player, "money" )
		if money < costsToArm then
			infobox ( player, "Du hast nicht\ngenug Geld!", 5000, 125, 0, 0 )
			return nil
		end

		MtxSetElementData ( player, "money", money - costsToArm )
		setPedArmor ( player, 100 )
		setElementHealth ( player, 100 )
		giveWeapon ( player, waffe )
		infobox ( player, "Du hast dich\nausgeruestet!", 5000, 0, 125, 0 )

	elseif field == "renameRanks" then
		if rang < 3 then
			infobox ( player, "Du bist nicht\nberechtigt!", 5000, 125, 0, 0 )
			return nil
		end
		local r1 = textAusEingabe ( v1, GANG_RANGNAME_MAXLAENGE )
		local r2 = textAusEingabe ( v2, GANG_RANGNAME_MAXLAENGE )
		local r3 = textAusEingabe ( v3, GANG_RANGNAME_MAXLAENGE )
		if not r1 or not r2 or not r3 then
			infobox ( player, "Rangnamen duerfen\nnicht leer sein!", 5000, 125, 0, 0 )
			return nil
		end
		setGangRankName ( id, 1, r1 )
		setGangRankName ( id, 2, r2 )
		setGangRankName ( id, 3, r3 )
		infobox ( player, "Raenge geaendert!", 5000, 0, 125, 0 )

	elseif field == "sendMSGToGang" then
		local text = textAusEingabe ( v1, GANG_MSG_MAXLAENGE )
		if text then
			sendMessageToGangMembers ( id, pname.." "..text )
		end
	end
end
addEvent ( "gangLeaderChangeRecieve", true )
addEventHandler ( "gangLeaderChangeRecieve", getRootElement(), gangLeaderChangeRecieve_func )

function openClientGangWindow ( player, gangID )

	if client then
		player = client
		gangID = nil
	end

	if not isElement ( player ) or MtxGetElementData ( player, "loggedin" ) ~= 1 then
		return
	end

	local id = tonumber ( gangID ) or getElementDimension ( player )
	if not istGangMitglied ( player, id ) then
		if isElement ( player ) then
			setElementClicked ( player, false )
			showCursor ( player, false )
			infobox ( player, "\n\nDu gehoerst nicht\nzu dieser Gang!", 5000, 125, 0, 0 )
		end
		return
	end

	if not isElement ( player ) then
		return
	end

	local msg = getGangMSG ( id )
	local gangVehicleCost = getGangVehicleCost ( id )
	local money = getGangMoney ( id )
	local mats = getGangMats ( id )
	local drugs = getGangDrugs ( id )
	local memberCount = getMembersInGangCount ( id )
	local memberString = getGangMembersString ( id )
	local gangname = getGangName ( id )
	local rank1, rank2, rank3 = getGangRankName ( id, 1 ), getGangRankName ( id, 2 ), getGangRankName ( id, 3 )

	if not isElement ( player ) then
		return
	end

	triggerClientEvent ( player, "showGangWindow", player, msg, gangVehicleCost, money, mats, drugs, memberCount, memberString, gangname, rank1, rank2, rank3 )
end
addEvent ( "showGangGUIAgain", true )
addEventHandler ( "showGangGUIAgain", getRootElement(), openClientGangWindow )

function gangEat_func ()

	local player = client
	if not isElement ( player ) or MtxGetElementData ( player, "loggedin" ) ~= 1 then
		return
	end

	local id = getElementDimension ( player )
	if not istGangMitglied ( player, id ) then
		return
	end

	if not isElement ( player ) then
		return
	end

	setElementHealth ( player, 100 )
	setPedArmor ( player, 100 )
	setElementHunger ( player, 100 )
end
addEvent ( "gangEatServer", true )
addEventHandler ( "gangEatServer", root, gangEat_func )
