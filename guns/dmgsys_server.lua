--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

setWeaponProperty(33, "poor", "weapon_range", 250)
setWeaponProperty(33, "std", "weapon_range", 250)
setWeaponProperty(33, "pro", "weapon_range", 200)
setWeaponProperty ( 31, "pro", "weapon_range", 100 )
setWeaponProperty ( 31, "pro", "accuracy", 0.9 )
setWeaponProperty ( 24, "pro", "accuracy", 1.6 )

gotLastHit = {}


local WURF_WAFFEN = { [16] = true, [17] = true, [18] = true, [39] = true }
local WURF_TOLERANZ_MS = 5000
local letzteWurfwaffe = {}

addEventHandler ( "onPlayerWeaponFire", getRootElement(), function ( weaponID )
	if WURF_WAFFEN[weaponID] then
		letzteWurfwaffe[source] = { waffe = weaponID, zeit = getTickCount () }
	end
end )

addEventHandler ( "onPlayerQuit", getRootElement(), function ()
	letzteWurfwaffe[source] = nil
end )

local weaponDamages = {
	[0] = { [3] = 5, [4] = 5, [5] = 5, [6] = 5, [7] = 5, [8] = 5, [9] = 5 },
	[4] = { [3] = 10, [4] = 20, [5] = 5, [6] = 5, [7] = 5, [8] = 5, [9] = 20 }, 
	[8] = { [3] = 20, [4] = 20, [5] = 20, [6] = 20, [7] = 20, [8] = 20, [9] = 25 },
	[22] = { [3] = 10, [4] = 10, [5] = 8, [6] = 8, [7] = 8, [8] = 8, [9] = 15 }, 
	[23] = { [3] = 10, [4] = 10, [5] = 8, [6] = 8, [7] = 8, [8] = 8, [9] = 15 }, 
	[24] = { [3] = 35, [4] = 35, [5] = 30, [6] = 30, [7] = 30, [8] = 30, [9] = 70 }, 
	[25] = { [3] = 25, [4] = 25, [5] = 20, [6] = 20, [7] = 20, [8] = 20, [9] = 35 }, 
	[26] = { [3] = 30, [4] = 30, [5] = 20, [6] = 20, [7] = 20, [8] = 20, [9] = 40 }, 
	[27] = { [3] = 30, [4] = 30, [5] = 20, [6] = 20, [7] = 20, [8] = 20, [9] = 40 }, 
	[28] = { [3] = 8, [4] = 8, [5] = 5, [6] = 5, [7] = 5, [8] = 5, [9] = 10 }, 
	[29] = { [3] = 9, [4] = 9, [5] = 8, [6] = 8, [7] = 8, [8] = 8, [9] = 12 }, 
	[32] = { [3] = 8, [4] = 8, [5] = 5, [6] = 5, [7] = 5, [8] = 5, [9] = 10 }, 
	[30] = { [3] = 10, [4] = 10, [5] = 8, [6] = 8, [7] = 8, [8] = 8, [9] = 14 }, 
	[31] = { [3] = 9, [4] = 9, [5] = 7, [6] = 7, [7] = 7, [8] = 7, [9] = 12 }, 
	[33] = { [3] = 15, [4] = 15, [5] = 12, [6] = 12, [7] = 12, [8] = 12, [9] = 20 }, 
	[34] = { [3] = 15, [4] = 15, [5] = 12, [6] = 12, [7] = 12, [8] = 12, [9] = 200 }, 
	[35] = { [3] = 80, [4] = 80, [5] = 50, [6] = 50, [7] = 50, [8] = 50, [9] = 130 }, 
	[36] = { [3] = 80, [4] = 80, [5] = 50, [6] = 50, [7] = 50, [8] = 50, [9] = 130 }, 
	[37] = { [3] = 8, [4] = 8, [5] = 5, [6] = 5, [7] = 5, [8] = 5, [9] = 12 }, 
	[38] = { [3] = 8, [4] = 8, [5] = 6, [6] = 6, [7] = 6, [8] = 6, [9] = 12 }, 
	[16] = { [3] = 80, [4] = 80, [5] = 50, [6] = 50, [7] = 50, [8] = 50, [9] = 130 }, 
	[17] = { [3] = 5, [4] = 5, [5] = 5, [6] = 5, [7] = 5, [8] = 5, [9] = 5 }, 
	[18] = { [3] = 5, [4] = 5, [5] = 5, [6] = 5, [7] = 5, [8] = 5, [9] = 5 }, 
	[39] = { [3] = 100, [4] = 100, [5] = 100, [6] = 100, [7] = 100, [8] = 100, [9] = 100 }
}


function damageCalcServer_func (attacker,weapon,bodypart,loss,player)
if(attacker and weapon and bodypart and loss)then end
	if source == client then

		local waffeOk = ( getPedWeapon ( client ) == weapon )
		if not waffeOk and WURF_WAFFEN[weapon] then
			local info = letzteWurfwaffe[client]
			if info and info.waffe == weapon and ( getTickCount () - info.zeit ) <= WURF_TOLERANZ_MS then
				waffeOk = true
			end
		end
		if not waffeOk then
			return
		end

		-- Spawnschutz
		if not MtxGetElementData ( client, "spawnProtection" ) and not MtxGetElementData (player, "spawnProtection" ) and not MtxGetElementData ( player, "tazered" ) then
			-- Spielzeit
			if MtxGetElementData ( client, "playingtime" ) and MtxGetElementData ( client, "playingtime" ) >= Tables.noobtime and MtxGetElementData (player, "playingtime" ) and MtxGetElementData (player, "playingtime" ) >= Tables.noobtime then
				if MtxGetElementData (player, "jailtime" ) == 0 and MtxGetElementData ( player, "prison" ) == 0 then
					local x1, y1, z1 = getElementPosition ( client )
					local x2, y2, z2 = getElementPosition ( player )
					triggerClientEvent (player, "startBloodScreen", player)
					local dist = getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z2)
					gotLastHit[player] = getTickCount()
					gotLastHit[client] = getTickCount()
					if weapon == 34 and bodypart == 9 and dist >= 20 then
						if (MtxGetElementData(player,"nodmzone")== 1) then
							return false
						end
						setPedHeadless ( player, true )
						killPed ( player, client, weapon, bodypart )
						outputChatBox ( "Du wurdest gesnipet!", player, 255, 0, 0 )
						outputLog ( getPlayerName ( client ).." hat "..getPlayerName ( player ).." mit der Sniper ein Headshot gegeben", "dmg" )
					elseif weapon == 34 and bodypart == 9 then
						return
					else
						if (MtxGetElementData(player,"nodmzone")== 1) then
							return false
						end
						if (getElementData(player,"inTactic") == true) then
							if(getElementData(attacker,"tacticTeam") == "staat")then
								if(getElementData(player,"tacticTeam") == "staat")then
									return false
								end
							elseif (getElementData(attacker,"tacticTeam") == "gang") then
								if (getElementData(player,"tacticTeam") == "gang") then
									return false
								end
							end
						end
						local multiply = 1
						if weapon == 24 and dist <= 1 then
							multiply = 0.5
						end	
						local basicDMG = ( weaponDamages[weapon] and weaponDamages[weapon][bodypart] or 1 ) * multiply			
						damagePlayer ( player, basicDMG, client, weapon )
						local pname = getPlayerName ( client )
						outputLog ( pname.." hat "..getPlayerName ( player ).." mit Waffe "..weapon.." an Part "..bodypart.." getroffen, Schaden: "..basicDMG, "dmg" )
						if gangAreaUnderAttack then
							if playerData[pname] and playerData[pname]["imGW"] and isElement ( player ) and getElementType ( player ) == "player" and MtxGetElementData ( player, "fraktion" ) ~= MtxGetElementData ( client, "fraktion" ) then
								playerData[pname]["damage"] = playerData[pname]["damage"] + basicDMG
								if playerData[getPlayerName(player)] then
									playerData[getPlayerName(player)]["hatDMGbekommen"] = client
								end
								MtxSetElementData ( client, "GangwarDamageGemacht", ( MtxGetElementData ( client, "GangwarDamageGemacht" ) or 0 ) + basicDMG )
								MtxSetElementData ( player, "GangwarDamageBekommen", ( MtxGetElementData ( player, "GangwarDamageBekommen" ) or 0 ) + basicDMG )
								triggerClientEvent ( client, "rechneDMGAn", client, basicDMG )
							end	
						end	
						if client then
							MtxSetElementData ( client, "lastcrime", "violance" )
						end
					end
				end
			end
		end
	end
end
addEvent ( "damageCalcServer", true )
addEventHandler ( "damageCalcServer", getRootElement(), damageCalcServer_func )


function headlessPed ( player )
	if isPedDead ( player ) then
		setPedHeadless ( player, true )
	end
end

addEventHandler ( "onPlayerSpawn", getRootElement(),
function ()
	if getElementData(source,"inTactic") == true then
		MtxSetElementData ( source, "spawnProtection", false )
		return
	end
	MtxSetElementData ( source, "spawnProtection", true )
	setTimer ( MtxSetElementData, 10000, 1, source, "spawnProtection", false )
	setPedHeadless ( source, false )
	gotLastHit[source] = 0
end)
	

addCommandHandler("hitglocke", function( player )
	if MtxGetElementData ( player, "hitglocke" ) == 1 then	
		outputChatBox("Du hast die Hitglocke deaktiviert.", player)
		MtxSetElementData ( player, "hitglocke", 0 )
	else 
		outputChatBox("Du hast die Hitglocke aktiviert.", player)
		MtxSetElementData ( player, "hitglocke", 1 )
	end
end)


addEvent ( "kickplayerforhighping", true )
addEventHandler ( "kickplayerforhighping", root, function ( ping )
	kickPlayer ( client, "Du wurdest wegen zu hohem Ping ("..ping..") gekickt!" )
end )