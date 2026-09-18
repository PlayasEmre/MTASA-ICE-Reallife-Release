function armyClassSpawn ( player )

	if not isKeyBound ( player, "1", "down", tazer_func ) then
		bindKey ( player, "1", "down", tazer_func )
	end
	
	giveWeapon ( player, 22, 170, true )
	if MtxGetElementData ( player, "job" ) == "soldat" then
		giveWeapon ( player, 22, 102*2*2, true )
		giveWeapon ( player, 31, 150, true )
		giveWeapon ( player, 24, 90, true )
	elseif MtxGetElementData ( player, "job" ) == "pionier" then
		giveWeapon ( player, 6, 1, true )
		giveWeapon ( player, 16, 3, true )
		giveWeapon ( player, 24, 90, true )
	elseif MtxGetElementData ( player, "job" ) == "marine" then
		giveWeapon ( player, 25, 50, true )
		giveWeapon ( player, 24, 90, true )
	elseif MtxGetElementData ( player, "job" ) == "air" then
		giveWeapon ( player, 29, 250, true )
		giveWeapon ( player, 46, 3, true )
		giveWeapon ( player, 24, 40, true )
	elseif MtxGetElementData ( player, "job" ) == "tankcommander" then
		giveWeapon ( player, 36, 20, true )
		giveWeapon ( player, 27, 500, true )
		giveWeapon ( player, 24, 40, true )
	elseif MtxGetElementData ( player, "job" ) == "spaeher" then
		giveWeapon ( player, 23, 90, true )
		giveWeapon ( player, 34, 20, true )
		giveWeapon ( player, 24, 40, true )
	end
	
	
	setPedArmor ( player, 100 )
	giveWeapon ( player, 31, 300, true )
end

explosiveCount = 0

function explosive_func ( player )
	if MtxGetElementData ( player, "job" ) == "pionier" and isArmy then
		if not MtxGetElementData ( player, "expTimer" ) then
			MtxSetElementData ( player, "expTimer", true )
			setTimer ( MtxSetElementData, 30000, 1, player, "expTimer", false )
			local x, y, z = getElementPosition ( player )
			local z = z - 0.73
			local x = x + 0.3
			local y = y + 0.3
			_G["explosive"..explosiveCount] = createObject ( 1654, x, y, z )
			setTimer ( explodeExplosive, 10000, 1, _G["explosive"..explosiveCount], player )
			outputChatBox ( "Sprengladung ist scharf, du hast 10 Sekunden!", player, 125, 0, 0 )
			explosiveCount = explosiveCount + 1
		else
			outputChatBox ( "Du kannst nur alle 30 Sekunden eine Sprengladung legen!", player, 125, 0, 0 )
		end
	else
		outputChatBox ( "Du bist nicht befugt!", player, 125, 0, 0 )
	end
end
addCommandHandler ( "explosive", explosive_func )

function explodeExplosive ( explosive, player )

	local x, y, z = getElementPosition ( explosive )
	createExplosion ( x, y, z, 0, player )
	destroyElement ( explosive )
end

function setpermission_func ( player, cmd, target, perm, bool )
	
	local target = findPlayerByName( target )
	if target then
		if isArmy ( player ) then
			-- Vorher "== 4 or 5": Lua liest das als (rang == 4) or 5, und 5 ist
			-- immer wahr - die Rangpruefung griff damit nie.
			if getPlayerRank ( player ) >= 4 then
				local perm = tonumber ( perm )
				if perm then
					if perm > 0 and perm < 11 then
						if perm == 10 then
							bool = tonumber ( bool )
							if bool then
								MtxSetElementData ( target, "armyperm10", bool )
								saveArmyPermissions ( target )
								outputChatBox ( "Du hast "..getPlayerName ( target ).." die GWD-Note "..bool.." gegeben!", player, 0, 125, 0 )
								outputChatBox ( getPlayerName ( player ).." hat dir die GWD-Note "..bool.." gegeben!", target, 0, 125, 0 )
							end
						else
							if bool == "1" then
								fix = "gegeben"
								MtxSetElementData ( target, "armyperm"..perm, 1 )
							else
								fix = "genommen"
								MtxSetElementData ( target, "job", "none" )
								MtxSetElementData ( target, "armyperm"..perm, 0 )
							end
							saveArmyPermissions ( target )
							outputChatBox ( "Du hast "..getPlayerName ( target ).." "..permNames[perm].." "..fix..".", player, 0, 125, 0 )
							outputChatBox ( getPlayerName ( player ).." hat dir "..permNames[perm].." "..fix..".", target, 0, 125, 0 )
						end
					else
						outputChatBox ( "Gebrauch: /setpermission [Name] [Permission 1-10] [1 oder 0]", player, 125, 0, 0 )
					end
				else
					outputChatBox ( "Gebrauch: /setpermission [Name] [Permission 1-10] [1 oder 0]", player, 125, 0, 0 )
				end
			else
				outputChatBox ( "Gebrauch: /setpermission [Name] [Permission 1-10] [1 oder 0]", player, 125, 0, 0 )
			end
		else
			outputChatBox ( "Du bist kein Soldat!", player, 125, 0, 0 )
		end
	else
		outputChatBox ( "Gebrauch: /setpermission [Name] [Permission 1-10] [1 oder 0]", player, 125, 0, 0 )
		outputChatBox ( "Permissions: 1=Soldat,2=Pionier,3=Marine,4=Luftwaffe,5=Panzerkommandoer,6=Spaeher,7=Ehrenm.,8=Luftwaffenm.,9=Verdienstm.,10=GWD", player, 125, 125, 0 )
	end
end
addCommandHandler ( "setpermission", setpermission_func )

permNames = {}
	permNames[1] = "Soldat"
	permNames[2] = "Pionier"
	permNames[3] = "Marine"
	permNames[4] = "Luftwaffe"
	permNames[5] = "Panzerkommandoer"
	permNames[6] = "Spaeher"
	permNames[7] = "Ehrenmedallie"
	permNames[8] = "Luftwaffen Orden"
	permNames[9] = "Verdienstkreuz"
	permNames[10] = "Zeugnis"
	
validClasses = {}
validClasses = { ["soldat"]=true, ["pionier"]=true, ["marine"]=true, ["air"]=true, ["tankcommander"]=true, ["spaeher"]=true }

function class_func ( player, cmd, class )

	if validClasses[class] then
		suc = false
		if MtxGetElementData ( player, "armyperm6" ) == 1 and class == "spaeher" then
			suc = true
		elseif MtxGetElementData ( player, "armyperm5" ) == 1 and class == "tankcommander" then
			suc = true
		elseif MtxGetElementData ( player, "armyperm4" ) == 1 and class == "air" then
			suc = true
		elseif MtxGetElementData ( player, "armyperm3" ) == 1 and class == "marine" then
			suc = true
		elseif MtxGetElementData ( player, "armyperm2" ) == 1 and class == "pionier" then
			suc = true
		elseif MtxGetElementData ( player, "armyperm1" ) == 1 and class == "soldat" then
			suc = true
		end
		if suc then
			MtxSetElementData ( player, "job", class )
			outputChatBox ( "Klasse geaendert!", player, 125, 0, 0 )
		else
			outputChatBox ( "Du darfst diese Klasse nicht benutzen!", player, 125, 0, 0 )
		end
	else
		outputChatBox ( "Gebrauch: /class [soldat|pionier|marine|air|tankcommander]", player, 125, 0, 0 )
	end
end
addCommandHandler ( "class", class_func )

-- /rearm wurde entfernt. Staatsfraktionen ruesten sich jetzt ueber /fguns in
-- der Waffenkammer aus (siehe fraktionen/fdepots.lua); der Dienstantritt gibt
-- nur noch Uniform, Ruestung und Status.
