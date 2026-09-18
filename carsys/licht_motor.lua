--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


noengine = { [509]=true, [481]=true, [510]=true, [462]=true }

function toggleVehicleLights ( player, key, state )
	if ( getPedOccupiedVehicleSeat ( player ) == 0 ) then
		local veh = getPedOccupiedVehicle ( player )
		if getElementModel ( veh ) ~= 438 then
			if ( getVehicleOverrideLights ( veh ) ~= 2 ) then
				setVehicleOverrideLights ( veh, 2 )
				MtxSetElementData ( veh, "light", true)
				triggerClientEvent(player, "lightsound", player)
			else
				setVehicleOverrideLights ( veh, 1 )
				MtxSetElementData ( veh, "light", false)
				triggerClientEvent(player, "lightsound1", player)
			end
		end
	end
end

function toggleVehicleTrunkBind ( player, key, state )
	local veh = getPedOccupiedVehicle ( player )
	if veh then
	if getPedOccupiedVehicleSeat ( player ) == 0 and MtxGetElementData ( veh, "engine" ) then
		if MtxGetElementData ( veh, "owner" ) then
			if MtxGetElementData ( veh, "stuning1" ) then
				if MtxGetElementData ( veh, "engine" ) then
					toggleVehicleTrunk ( veh )
					unbindKey ( player, "sub_mission", "down", toggleVehicleTrunkBind, "Kofferraum auf/zu" )
					setTimer ( rebindTrunk, 750, 1, player )
				else
					outputChatBox ( "Der Motor muss laufen!", player, 125, 0, 0 )
				end
				else
					outputChatBox ( "Dieses Fahrzeug hat keinen Kofferraum!", player, 125, 0, 0 )
				end
		     end
		end
	end
end

function rebindTrunk ( player )

	bindKey ( player, "sub_mission", "down", toggleVehicleTrunkBind, "Kofferraum auf/zu" )
end


function toggleVehicleEngine ( player, key, state )
	local veh = getPedOccupiedVehicle ( player )
	if veh then
	if MtxGetElementData(veh, "motorworking") == true then return end 
	if getElementModel ( veh ) ~= 438 then
		if ( getPedOccupiedVehicleSeat ( player ) == 0 ) then
			local x,y,z = getElementPosition(veh)
			
			-- Falls das Fahrzeug neu gespawnt ist und noch keinen Benzinwert hat
			if not MtxGetElementData ( veh, "fuelstate" ) then
				MtxSetElementData ( veh, "fuelstate", 100 )
				MtxSetElementData ( veh, "engine", false )
				setVehicleOverrideLights ( veh, 1 )
				MtxSetElementData ( veh, "light", false)
				setVehicleEngineState ( veh, false )
			end
			
			if MtxGetElementData(veh, "totalschaden") == 1 then
				outputChatBox("Das Fahrzeug hat einen Totalschaden! Du musst es erst von einem Mechaniker reparieren lassen.", player, 255, 0, 0)
				outputChatBox("Verwende /call 300, um einen Mechaniker anzurufen!", player, 200, 0, 0)
				setVehicleEngineState ( veh, false )
				MtxSetElementData ( veh, "engine", false )
				return
			end
			
			if MtxGetElementData(veh, "Beschlagnahmt") == 1 then
				outputChatBox("Dieses Auto ist beschlagnahmt, kaufe es mit /freikaufen frei!",player,255,0,0)
				outputChatBox("Freikauf kosten: 2000 €",player,255,0,0)
				setVehicleEngineState ( veh, false )
				MtxSetElementData ( veh, "engine", false )
				return
			end

			-- Falls der Motor läuft -> immer abschalten
			if getVehicleEngineState ( veh ) then
				setVehicleEngineState ( veh, false )
				MtxSetElementData ( veh, "engine", false )
			-- Falls der Motor NICHT läuft, dem Spieler das Fahrzeug jedoch gehört
			
			elseif MtxGetElementData ( veh, "owner" ) == getPlayerName ( player ) then
			
				-- Falls das Fahrzeug noch genug Benzin hat
				if tonumber ( MtxGetElementData ( veh, "fuelstate" ) ) >= 1 then
					MtxSetElementData(veh, "motorworking", true)
					setTimer(function()
						MtxSetElementData(veh, "motorworking", false)
						setVehicleEngineState ( veh, true )
						MtxSetElementData ( veh, "engine", true )
						if not MtxGetElementData ( veh, "timerrunning" ) then
							setVehicleNewFuelState ( veh )
							MtxSetElementData ( veh, "timerrunning", true )
						end
					end, 1000, 1)
				else
					outputChatBox ( "Das Fahrzeug hat nicht mehr genug Benzin - du kannst an einer Tankstelle einen Reservekanister erwerben!", player, 125, 0, 0 )
				end

			elseif MtxGetElementData(veh, "KeyTarget") == playerUID[getPlayerName(player)] then

				-- Falls das Fahrzeug noch genug Benzin hat
				if tonumber ( MtxGetElementData ( veh, "fuelstate" ) ) >= 1 then
					MtxSetElementData(veh, "motorworking", true)
					setTimer(function()
						MtxSetElementData(veh, "motorworking", false)
						setVehicleEngineState ( veh, true )
						MtxSetElementData ( veh, "engine", true )
						if not MtxGetElementData ( veh, "timerrunning" ) then
							setVehicleNewFuelState ( veh )
							MtxSetElementData ( veh, "timerrunning", true )
						end
					end, 1000, 1)
				else
					outputChatBox ( "Das Fahrzeug hat nicht mehr genug Benzin - du kannst an einer Tankstelle einen Reservekanister erwerben!", player, 125, 0, 0 )
				end
			-- Kein Besitzer bzw. Fraktionswagen / gespawnte Fahrzeuge
			elseif not MtxGetElementData ( veh, "owner" ) then
				if MtxGetElementData ( veh, "fuelstate" ) >= 1 then
					MtxSetElementData(veh, "motorworking", true)
					setTimer(function()
						MtxSetElementData(veh, "motorworking", false)
						setVehicleEngineState ( veh, true )
						MtxSetElementData ( veh, "engine", true )
						if not MtxGetElementData ( veh, "timerrunning" ) then
							setVehicleNewFuelState ( veh )
							MtxSetElementData ( veh, "timerrunning", true )
						end
					end, 1000, 1)
				end
			elseif MtxGetElementData ( veh, "ownerfraktion" ) then
				local car_acess
				if tonumber(MtxGetElementData( veh, "ownerfraktion" )) == tonumber(MtxGetElementData ( player, "fraktion" )) then
					car_acess = true
				elseif tonumber(MtxGetElementData( veh, "ownerfraktion" )) == 1 then
					if isStateFaction(player) then
						car_acess = true				
					end
				elseif tonumber(MtxGetElementData( veh, "ownerfraktion" )) == 6 then
					if isArmy(player) or isFBI(player) then
						car_acess = true				
					end
				end
			
				if MtxGetElementData ( veh, "fuelstate" ) >= 1 and car_acess == true then
					MtxSetElementData(veh, "motorworking", true)
						setTimer(function()
							MtxSetElementData(veh, "motorworking", false)
							setVehicleEngineState ( veh, true )
							MtxSetElementData ( veh, "engine", true )
							if not MtxGetElementData ( veh, "timerrunning" ) then
								setVehicleNewFuelState ( veh )
								MtxSetElementData ( veh, "timerrunning", true )
							end
						end, 1000, 1)
				    end
				end
			end
		end
	end
end

VehicleSoundBIKE={
	[522]=true,
	[521]=true,
	[461]=true,
	[581]=true,
	[462]=true,
	[463]=true,
	[448]=true,
	[468]=true,
	[586]=true,
	[523]=true,
};

VehicleSound={
	[602]=true,
	[496]=true,
	[401]=true,
	[518]=true,
	[527]=true,
	[589]=true,
	[419]=true,
	[587]=true,
	[533]=true,
	[526]=true,
	[474]=true,
	[545]=true,
	[517]=true,
	[410]=true,
	[600]=true,
	[436]=true,
	[439]=true,
	[549]=true,
	[424]=true,
	[491]=true,
	[445]=true,
	[604]=true,
	[507]=true,
	[585]=true,
	[466]=true,
	[492]=true,
	[546]=true,
	[551]=true,
	[516]=true,
	[467]=true,
	[426]=true,
	[547]=true,
	[405]=true,
	[580]=true,
	[409]=true,
	[550]=true,
	[566]=true,
	[540]=true,
	[421]=true,
	[529]=true,
	[485]=true,
	[438]=true,
	[437]=true,
	[574]=true,
	[431]=true,
	[420]=true,
	[525]=true,
	[536]=true,
	[427]=true,
	[407]=true,
	[544]=true,
	[490]=true,
	[528]=true,
	[575]=true,
	[534]=true,
	[433]=true,
	[408]=true,
	[416]=true,
	[552]=true,
	[567]=true,
	[535]=true,
	[576]=true,
	[412]=true,
	[402]=true,
	[475]=true,
	[542]=true,
	[603]=true,
	[429]=true,
	[541]=true,
	[415]=true,
	[480]=true,
	[562]=true,
	[565]=true,
	[434]=true,
	[494]=true,
	[502]=true,
	[503]=true,
	[411]=true,
	[559]=true,
	[561]=true,
	[560]=true,
	[506]=true,
	[451]=true,
	[558]=true,
	[555]=true,
	[477]=true,
	[579]=true,
	[404]=true,
	[489]=true,
	[505]=true,
	[568]=true,
	[479]=true,
	[508]=true,
	[543]=true,
	[478]=true,
	[470]=true,
	[596]=true,
	[598]=true,
	[599]=true,
	[597]=true,
	[601]=true,
	[428]=true,
	[499]=true,
	[609]=true,
	[498]=true,
	[524]=true,
	[532]=true,
	[578]=true,
	[573]=true,
	[455]=true,
	[588]=true,
	[403]=true,
	[423]=true,
	[414]=true,
	[443]=true,
	[515]=true,
	[514]=true,
	[531]=true,
	[456]=true,
	[459]=true,
	[422]=true,
	[482]=true,
	[605]=true,
	[418]=true,
	[572]=true,
	[582]=true,
	[413]=true,
	[440]=true,
	[554]=true,
	[400]=true,
	[442]=true,
	[458]=true,
	[504]=true,
	[483]=true,
	[500]=true,
	[444]=true,
	[556]=true,
	[557]=true,
	[557]=true,
	[495]=true,
};


local Motorstartet = "Nein"

function motorsound ( player )
	local veh = getPedOccupiedVehicle ( player )
	if veh then
    if getVehicleEngineState ( veh ) == false then
		if VehicleSoundBIKE[getElementModel(veh)] then
			triggerClientEvent(player, "Motor_Bike", player)
		end
		if VehicleSound[getElementModel(veh)] then
			triggerClientEvent(player, "motorsound", player)
		end
        timer = setTimer(function()
            toggleVehicleEngine(player)
        end, 300, 1)
    local taste_start = "x"
        Motorstartet = "Ja"
        if ( Motorstartet == "Ja" ) then
			setElementAngularVelocity(veh,math.random(-2,2)/100,math.random(-2,2)/100,math.random(-1,1)/100)
		setTimer(function()
			setElementAngularVelocity(veh,math.random(-2,2)/100,math.random(-2,2)/100,math.random(-1,1)/100)
		end, 500, 1)
	end
		else
			Motorstartet = "Nein"
			toggleVehicleEngine(player)
			triggerClientEvent(player, "motorrsound", player)
		end
	end
end
 
function killtimer ()
    if isTimer (timer) then
        killTimer(timer)
    end
end

function enginecheck (  veh, seat )
	if seat == 0 then
		if ( not noengine[getElementModel ( veh )] or ( noengine[getElementModel ( veh )] and MtxGetElementData ( veh, "owner" ) ) ) and getElementModel ( veh ) ~= 438 then
			if not MtxGetElementData ( veh, "engine" ) then
				MtxSetElementData ( veh, "engine", false )
				setVehicleEngineState ( veh, false )
			end
			if not MtxGetElementData ( veh, "light" ) then
				MtxSetElementData ( veh, "light", false )
				setVehicleOverrideLights ( veh, 1 )
			end

			if getElementType ( source ) == "player" then
				if not isKeyBound ( source, "l", "down", toggleVehicleLights ) then
					bindKey ( source, "l", "down", toggleVehicleLights, "Licht an/aus" )
					bindKey ( source, "x", "down", motorsound, "Motor an/aus" )
					bindKey ( source, "x", "up", killtimer)
					bindKey ( source, "sub_mission", "down", toggleVehicleTrunkBind, "Kofferraum auf/zu" )
				end
			end
		end  
	end
end
addEventHandler ( "onPlayerVehicleEnter", getRootElement(), enginecheck )

function vehexit ()
	unbindKey ( source, "l", "down", toggleVehicleLights, "Licht an/aus" )
	unbindKey ( source, "sub_mission", "down", toggleVehicleTrunkBind, "Kofferraum auf/zu" )
	unbindKey ( source, "x", "down", motorsound, "Motor an/aus" )
	unbindKey ( source, "x", "up", killtimer)
end
addEventHandler ("onPlayerVehicleExit", getRootElement(), vehexit )