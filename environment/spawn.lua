--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

spawnBoats = { [454]=true, [484]=true }

function RemoteSpawnPlayer ( player )

	if isElement ( player ) then
		local pname = getPlayerName ( player )
		toggleAllControls ( player, true )
		setPlayerHudComponentVisible ( player, "radar", true )
		if MtxGetElementData ( player, "spawnpos_x" ) == "wohnmobil" then
			local spawned = false
			for i = 1, MtxGetElementData ( player, "maxcars" ) do
				local veh = allPrivateCars[pname][i]
				if veh then
					local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=? AND ??=?", "Typ", "vehicles", "UID", playerUID[pname], "Slot", i )
					if result and result[1] then
						local model = tonumber ( result[1]["Typ"] )
						if model == 508 then
							sx, sy, sz = getElementPosition ( veh )
							savespawn ( player, sx+4, sy+4, sz, 0, 0, 0 )
							spawned = true
							break
						end
					end
				end
			end
			if not spawned then
				savespawn ( player, -2458.288085, 774.354492, 35.171875, 0, 0, 0 )
			end
		elseif tonumber ( MtxGetElementData ( player, "spawnpos_x" ) ) then
			MtxSetElementData ( player, "spawnpos_x", tonumber(MtxGetElementData ( player, "spawnpos_x" )) )
			MtxSetElementData ( player, "spawnpos_y", tonumber(MtxGetElementData ( player, "spawnpos_y" )) )
			savespawn ( player, 0, 0, 0, 0, 0, 0 )
			local sx, sy, sz = MtxGetElementData ( player, "spawnpos_x" ), MtxGetElementData ( player, "spawnpos_y" ),MtxGetElementData ( player, "spawnpos_z" )
			setElementPosition ( player, sx, sy, sz )
			setElementInterior ( player, MtxGetElementData ( player, "spawnint" ) )
			setElementDimension ( player, MtxGetElementData ( player, "spawndim" ) )
			if not isKeyBound ( player, "F2", "down", house_func ) then
				bindKey ( player, "F2", "down", house_func )
			end
		else
			local spawned = false
			if MtxGetElementData ( player, "maxcars" ) then
				for i = 1, MtxGetElementData ( player, "maxcars" ) do
					local veh = allPrivateCars[pname][i]
					if veh then
						local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=? AND ??=?", "Typ", "vehicles", "UID", playerUID[pname], "Slot", i )
						if result and result[1] then
							local model = tonumber ( result[1]["Typ"] )
							if model then
								if spawnBoats[model] then
									sx, sy, sz = getElementPosition ( veh )
									savespawn ( player, sx, sy, sz+3.8, 0, 0, 0 )
									spawned = true
									break
								end
							end
						end
					end
				end
				if not spawned then
					savespawn ( player, -2458.288085, 774.354492, 35.171875, 0, 0, 0 )
				end
			end
		end
		-- Absicherung gegen eine ungueltige, irgendwie in der DB gelandete Skin-ID:
		-- setElementModel/spawnPlayer mit einer ungueltigen Skin-ID ist eine
		-- klassische GTA:SA-Absturzursache (betrifft auch Spieler, die einen
		-- sehen) und wuerde sonst bei JEDEM Login dieses Accounts erneut passieren.
		local spawnSkinid = tonumber ( MtxGetElementData ( player, "skinid" ) )
		if not spawnSkinid or spawnSkinid < 0 or spawnSkinid > 311 then
			spawnSkinid = 0
			MtxSetElementData ( player, "skinid", 0 )
		end
		setElementModel ( player, spawnSkinid )
		if isArmy ( player ) then
			armyClassSpawn ( player )
		end
		fadeCamera ( player, true )
		setCameraTarget( player, player )
		setPlayerWantedLevel ( player, tonumber(MtxGetElementData ( player, "wanteds")) )
		if tonumber(MtxGetElementData ( player, "jailtime" )) >= 1 or MtxGetElementData ( player, "prison" ) >= 1 then
			putPlayerInJail ( player )
		end
		if tonumber ( MtxGetElementData ( player, "heaventime" ) ) >= 1 then
			endfade ( player, tonumber ( MtxGetElementData ( player, "heaventime" ) ) )
			setElementInterior ( player, 0 )
			setElementDimension ( player, 1 )
		end
	end
	triggerClientEvent ( player, "camfix", player )
end

function savespawn ( player, x, y, z, rx, ry, rz, highNoon )

	if highNoon then
		setElementDimension ( player, 0 )
	end
	spawnPlayer ( player, x, y, z, rz )
	setElementHealth ( player, 100 )
	setElementModel ( player, MtxGetElementData ( player, "skinid") or 0 )
	fadeCamera ( player, true )
	setCameraTarget( player, player )
	if tonumber ( MtxGetElementData ( player, "fraktion" ) ) == 5 then
		local gun1 = 43
		local ammo1 = 20000
		giveWeapon ( player, gun1, ammo1, true )
		giveWeapon ( player, gun1, ammo1, true )
		giveWeapon ( player, gun1, ammo1, true )
	end
	if isEvil ( player ) then
		setPedArmor ( player, 100 )
	end
	setPlayerWantedLevel ( player, MtxGetElementData ( player, "wanteds" ) )
end