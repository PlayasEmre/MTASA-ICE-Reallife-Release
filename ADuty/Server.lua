local admindutyskin = 260
local clantagwithsquarebracket = false
local admindutyarray = { skins = {}, vehicles = {} }
local SPAWN_HEIGHT = 1.5

function adminDuty ( player )
	if MtxGetElementData ( player, "loggedin" ) == 1 and not getElementData(player,"inTactic") then
		if ( tonumber ( MtxGetElementData ( player, "adminlvl" ) ) or 0 ) >= 1 then
			if not admindutyarray.skins[player] then
				outputChatBox(""..getPlayerName(player).. " ist nun im Support Modus",player,60,255,0)
				outputChatBox("INFO: Du kannst dir nun mit /acar [ID] ein Admin-Fahrzeug geben.", player, 200, 255, 255)
				admindutyarray.skins[player] = getElementModel ( player )
				MtxSetElementData(player,"adminduty",true)
				setElementModel ( player, admindutyskin )
				addEventHandler ( "onPlayerQuit", player, quitAdminDuty )
				addEventHandler ( "onPlayerWeaponSwitch", player, dontHoldWeaponInAdminDuty )
				local x, y, z = getElementPosition ( player )
				local rx, ry, rz = getElementRotation ( player )
				local name = getPlayerName ( player )
				if clantagwithsquarebracket then
					name = gettok ( name, 2, string.byte ( "[" ) ) or name
				end
				setElementHealth(player,100)
				setPedArmor(player,100)
				setElementHunger(player,100)
			else
				MtxSetElementData(player,"adminduty",false)
				
				if admindutyarray.vehicles[player] and isElement(admindutyarray.vehicles[player]) then
					destroyElement(admindutyarray.vehicles[player])
					admindutyarray.vehicles[player] = nil
					outputChatBox("Dein Admin-Fahrzeug wurde gelöscht.", player, 255, 165, 0)
				end
				
				setElementModel ( player, admindutyarray.skins[player] )
				outputChatBox(""..getPlayerName(player).." ist nicht mehr im Support-Modus",player,255,0,0)
				admindutyarray.skins[player] = nil
				removeEventHandler ( "onPlayerQuit", player, quitAdminDuty )
				removeEventHandler ( "onPlayerWeaponSwitch", player, dontHoldWeaponInAdminDuty )
			end		
		else
			triggerClientEvent(player, "infobox_start", getRootElement(), "Du bist\nnicht befugt!", 7500, 135, 206, 250)
		end
	end
end
addCommandHandler ( "smode", adminDuty )
addCommandHandler ( "aduty", adminDuty )
addCommandHandler ( "supportmode", adminDuty )
addCommandHandler ( "amode", adminDuty )

function quitAdminDuty ( )
	if admindutyarray.skins[source] then
		admindutyarray.skins[source] = nil
	end
	if admindutyarray.vehicles[source] and isElement(admindutyarray.vehicles[source]) then
		destroyElement(admindutyarray.vehicles[source])
		admindutyarray.vehicles[source] = nil
	end
end

function dontHoldWeaponInAdminDuty ( )
	setPedWeaponSlot ( source, 0 )
end

function destroyPlayerVehiclesExceptAdminCar(player)
    local adminVehicle = admindutyarray.vehicles[player]
    if adminVehicle and not isElement(adminVehicle) then
        admindutyarray.vehicles[player] = nil
        adminVehicle = nil
    end

    local destroyCount = 0
    for _, veh in ipairs(getElementsByType("vehicle")) do
        if getVehicleOccupant(veh, 0) == player then
            if not adminVehicle or veh ~= adminVehicle then
                destroyElement(veh)
                destroyCount = destroyCount + 1
            end
        end
    end
    return destroyCount
end

function handleCarCommand(player, command, vehicleID)

    if MtxGetElementData(player, "loggedin") ~= 1 or MtxGetElementData(player, "adminlvl") < 1 or not MtxGetElementData(player, "adminduty") then
        triggerClientEvent(player, "infobox_start", getRootElement(), "Du bist nicht im Duty-Modus\noder nicht befugt!", 7500, 255, 0, 0)
        return false
    end
    
    local id = tonumber(vehicleID)
    
    if not id or id < 400 or id > 611 then
        outputChatBox("Nutzung: /acar [Fahrzeug-ID] (ID 400 - 611)", player, 255, 255, 0)
        return false
    end

    if admindutyarray.vehicles[player] and isElement(admindutyarray.vehicles[player]) then
        destroyElement(admindutyarray.vehicles[player])
        outputChatBox("Dein vorheriges Admin-Fahrzeug wurde entfernt.", player, 150, 150, 150)
    end
    
    local destroyed = destroyPlayerVehiclesExceptAdminCar(player)
    if destroyed > 0 then
        outputChatBox("Es wurden " .. destroyed .. " alte Fahrzeuge entfernt.", player, 150, 150, 150)
    end
    
    local x, y, z = getElementPosition(player)
    local _, _, rz = getElementRotation(player)
    
    local newVehicle = createVehicle(id, x + 2, y, z + SPAWN_HEIGHT, 0, 0, rz)
    
    if newVehicle then
        setVehicleColor(newVehicle, 255, 255, 255, 255, 255, 255)
        warpPedIntoVehicle(player, newVehicle, 0)
        outputChatBox("Fahrzeug ID " .. id .. " wurde erfolgreich gespawnt.", player, 0, 255, 0)
        
        admindutyarray.vehicles[player] = newVehicle
        
        MtxSetElementData(newVehicle, "sportmotor", 4)
        MtxSetElementData(newVehicle, "bremse", 4)
        MtxSetElementData(newVehicle, "antrieb", "rwd")

        if type(giveSportmotorUpgrade) == "function" then
            giveSportmotorUpgrade(newVehicle)
        end
        setVehicleDamageProof(newVehicle, true)
    else
        outputChatBox("Fehler beim Spawnen des Fahrzeugs.", player, 255, 0, 0)
    end
end
addCommandHandler("acar", handleCarCommand)