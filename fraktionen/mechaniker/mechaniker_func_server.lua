------------------------------
-------- Urheberrecht --------
------- by [LA]Leyynen -------
-------- 2012 - 2013 ---------
------------------------------
---- Script by Noneatme ------


local tuningmarker2 = createMarker(-2083.0676269531,-134.88064575195,35.3203125, "corona", 1, 0, 0, 255, 100)
local rampencol2 = createColSphere ( -2083.6577148438,-138.80012512207,35.3203125, 10, 30, 10)
local haus_col = createColSphere(-2083.6577148438,-138.80012512207,35.3203125, 10, 37, 10)

addEvent("onVioOAmtCarTuning", true)

local veh_tuningtimer = {}


addEventHandler("onMarkerHit", tuningmarker2, function(hitElement)
	if(getElementType(hitElement) == "player") and (isPedInVehicle(hitElement) == false) and (isMechaniker(hitElement) and isEmergencyOnDuty(hitElement)) then
		local car = getElementsWithinColShape(rampencol2, "vehicle")
		triggerClientEvent(hitElement, "onVioOrdnungsamtTuningGuiStart2", hitElement, car)
	end
end)

local function sendMessageForAllInGarage(text)
	local players = getElementsWithinColShape(haus_col, "player")
	for i=1, #players do
		outputChatBox("[INFO]: "..text.."", players[i], 200, 200, 0)
	end
end

-- Echte Preise, NIE vom Client uebernehmen (gleiches Prinzip wie giveFgunsWeapon
-- in fdepots.lua) - sonst koennte ein veraenderter Client einen beliebig
-- niedrigen Preis mitschicken und sich Sportmotor/Totalschaden-Reparatur o.ae.
-- quasi umsonst holen. Muss zu oamt_tunings in mechaniker_func_client.lua passen.
local echtePreise = {
	["Kleine Reparatur"] = 50,
	["Nitro auffüllen"]  = 250,
	["Sportmotor 1"]     = 100000,
	["Sportmotor 2"]     = 250000,
	["Sportmotor 3"]     = 500000,
	["Bremse 1"]         = 25000,
	["Bremse 2"]         = 50000,
	["Bremse 3"]         = 100000,
	["Frontantrieb"]     = 40000,
	["Heckantrieb"]      = 40000,
	["Allradantrieb"]    = 40000,
	["Totalschaden"]     = 20000,
}

addEventHandler("onVioOAmtCarTuning", getRootElement(), function(vehicle, tuning, clientPreis)
	if(isTimer(veh_tuningtimer[vehicle])) then
		outputChatBox("Dieses Fahrzeug wird bereits bearbeitet!", client, 150, 0, 0)
		return
	end
	local preis = echtePreise[tuning]
	if not preis then
		return
	end
	local money = MtxGetElementData (client, "money")
	if money >= preis then
		if tuning == "Kleine Reparatur" then
			sendMessageForAllInGarage ( "Das Fahrzeug "..getVehicleNameFromModel(getElementModel(vehicle)).." wird bearbeitet!" )
			setElementFrozen ( vehicle, true )
			MtxSetElementData ( client, "money", money - preis )
			veh_tuningtimer[vehicle] = setTimer(function(vehicle)
				fixVehicle(vehicle)
				setElementFrozen(vehicle, false)
				sendMessageForAllInGarage("Die kleine Reparatur von Fahrzeug "..getVehicleNameFromModel(getElementModel(vehicle)).." wurde erledigt!")
			end, 5000, 1,vehicle)
		elseif(tuning == "Nitro auffüllen") then
			sendMessageForAllInGarage("Das Fahrzeug "..getVehicleNameFromModel(getElementModel(vehicle)).." wird bearbeitet!")
			setElementFrozen(vehicle, true)
			MtxSetElementData (client, "money", money - preis)
			veh_tuningtimer[vehicle] = setTimer(function(vehicle)
				addVehicleUpgrade(vehicle, 1010)
				setElementFrozen(vehicle, false)
				sendMessageForAllInGarage("In dem Fahrzeug "..getVehicleNameFromModel(getElementModel(vehicle)).." wurde Nitro eingebaut!")
			end, 5000, 1,vehicle)
		elseif string.find ( tuning, "Sportmotor" ) or string.find ( tuning, "Bremse" ) then
			local stufe = tonumber ( gettok ( tuning, 2, 32 ) )
			local data = gettok ( tuning, 1, 32 )
			if ( MtxGetElementData ( vehicle, string.lower(data) ) or 0 ) > stufe then
				outputChatBox("Das Fahrzeug hat es bereits eingebaut!", client, 255, 0, 0)
				return
			elseif ( MtxGetElementData ( vehicle, string.lower(data) ) or 0 ) + 1 ~= stufe then
				outputChatBox("Das Fahrzeug braucht erst Stufe ".. ( stufe-1 ), client, 255, 0, 0)
				return
			elseif getPlayerRank ( client ) < 2 then
				outputChatBox("Nur ab Rang 2 erlaubt!", client, 255, 0, 0)
				return
			else
				if MtxGetElementData (vehicle, "owner") then
					sendMessageForAllInGarage("Das Fahrzeug "..getVehicleNameFromModel(getElementModel(vehicle)).." wird bearbeitet!")
					setElementFrozen(vehicle, true)
					MtxSetElementData (client, "money", money - preis)
					veh_tuningtimer[vehicle] = setTimer(function(vehicle, data, stufe)
						MtxSetElementData ( vehicle, string.lower(data), stufe )
						giveSportmotorUpgrade ( vehicle )
						local Besitzer = MtxGetElementData (vehicle, "owner")
						local Slot = MtxGetElementData ( vehicle, "carslotnr_owner" )
						dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=? AND ??=?", "vehicles", data, stufe, "UID", playerUID[Besitzer], "Slot", Slot )
						setElementFrozen(vehicle, false)
						sendMessageForAllInGarage("Der neue Motor wurde erfolgreich in Fahrzeug "..getVehicleNameFromModel(getElementModel(vehicle)).." eingebaut!")
					end, 5000, 1, vehicle, data, stufe )
				else
					outputChatBox ( "Fahrzeuge ohne Besitzer können kein Sportmotor besitzen!", client, 255, 0, 0 )
					return
				end
			end
			local gewinn = preis <= 500 and preis or preis <= 5000 and math.floor ( preis/5 ) or preis <= 50000 and math.floor ( preis/5 ) or preis <= 100000 and math.floor ( preis/10 ) or math.floor ( preis/20 )
			MtxSetElementData ( client, "money", MtxGetElementData ( client, "money" ) + gewinn )
			outputChatBox ( "Du bekommst dafür "..gewinn..""..Tables.waehrung.."", client, 0, 200, 0 )
		elseif tuning == "Frontantrieb" then
			sendMessageForAllInGarage("Das Fahrzeug "..getVehicleNameFromModel(getElementModel(vehicle)).." wird bearbeitet!")
			setElementFrozen(vehicle, true)
			MtxSetElementData (client, "money", money - preis)
			MtxSetElementData ( vehicle, "antrieb", "fwd" )
			setVehicleHandling ( vehicle, "driveType", "fwd" )
			local Besitzer = MtxGetElementData (vehicle, "owner")
			local Slot = MtxGetElementData ( vehicle, "carslotnr_owner" )
			dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=? AND ??=?", "vehicles", "Antrieb", "fwd", "UID", playerUID[Besitzer], "Slot", Slot )
			veh_tuningtimer[vehicle] = setTimer(function(vehicle)
				setElementFrozen(vehicle, false)
				sendMessageForAllInGarage("Der Antrieb vom Fahrzeug "..getVehicleNameFromModel(getElementModel(vehicle)).." wurde verändert!")
			end, 5000, 1, vehicle)
		elseif tuning == "Heckantrieb" then
			sendMessageForAllInGarage("Das Fahrzeug "..getVehicleNameFromModel(getElementModel(vehicle)).." wird bearbeitet!")
			setElementFrozen(vehicle, true)
			MtxSetElementData (client, "money", money - preis)
			MtxSetElementData ( vehicle, "antrieb", "rwd" )
			setVehicleHandling ( vehicle, "driveType", "rwd" )
			local Besitzer = MtxGetElementData (vehicle, "owner")
			local Slot = MtxGetElementData ( vehicle, "carslotnr_owner" )
			dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=? AND ??=?", "vehicles", "Antrieb", "rwd", "UID", playerUID[Besitzer], "Slot", Slot )
			veh_tuningtimer[vehicle] = setTimer(function(vehicle)
				setElementFrozen(vehicle, false)
				sendMessageForAllInGarage("Der Antrieb vom Fahrzeug "..getVehicleNameFromModel(getElementModel(vehicle)).." wurde verändert!")
			end, 5000, 1, vehicle)
		elseif tuning == "Allradantrieb" then
			sendMessageForAllInGarage("Das Fahrzeug "..getVehicleNameFromModel(getElementModel(vehicle)).." wird bearbeitet!")
			setElementFrozen(vehicle, true)
			MtxSetElementData (client, "money", money - preis)
			MtxSetElementData ( vehicle, "antrieb", "awd" )
			setVehicleHandling ( vehicle, "driveType", "awd" )
			local Besitzer = MtxGetElementData (vehicle, "owner")
			local Slot = MtxGetElementData ( vehicle, "carslotnr_owner" )
			dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=? AND ??=?", "vehicles", "Antrieb", "awd", "UID", playerUID[Besitzer], "Slot", Slot )
			veh_tuningtimer[vehicle] = setTimer(function(vehicle)
				setElementFrozen(vehicle, false)
				sendMessageForAllInGarage("Der Antrieb vom Fahrzeug "..getVehicleNameFromModel(getElementModel(vehicle)).." wurde verändert!")
			end, 5000, 1, vehicle)
		elseif tuning == "Totalschaden" then
		if MtxGetElementData(vehicle,"totalschaden") == 1 then
			sendMessageForAllInGarage("Das Fahrzeug "..getVehicleNameFromModel(getElementModel(vehicle)).." wird bearbeitet!")
			setElementFrozen(vehicle, true)
			MtxSetElementData (client, "money", money - preis)
			fixVehicle(vehicle)
			setVehicleDamageProof(vehicle, false)
			MtxSetElementData (vehicle, "locked", false)
			setVehicleLocked ( vehicle, false )
			MtxSetElementData (vehicle, "totalschaden", 0)
			setVehicleEngineState ( vehicle, true )
			MtxSetElementData ( vehicle, "engine", true )
			local gewinn = preis <= 500 and preis or preis <= 5000 and math.floor ( preis/5 ) or preis <= 50000 and math.floor ( preis/5 ) or preis <= 100000 and math.floor ( preis/10 ) or math.floor ( preis/20 )
			MtxSetElementData (client, "money",MtxGetElementData(client,"money") + gewinn)
			outputChatBox("Sie haben das Auto erfolgreich repariert und erhalten "..gewinn.." "..Tables.waehrung,client,255,255,0)
			local Besitzer = MtxGetElementData (vehicle, "owner")
			local Slot = MtxGetElementData ( vehicle, "carslotnr_owner" )
			dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=? AND ??=?", "vehicles", "totalschaden", 0, "UID", playerUID[Besitzer], "Slot", Slot )
				veh_tuningtimer[vehicle] = setTimer(function(vehicle)
					setElementFrozen(vehicle, false)
					sendMessageForAllInGarage("Der Totalschaden vom Fahrzeug "..getVehicleNameFromModel(getElementModel(vehicle)).." wurde verändert!")
				end, 5000, 1, vehicle)
				outputChatBox("Das Totalschaden wird repariert!",client,255, 255, 0)
			else
				outputChatBox("Das Fahrzeug hat keinen Totalschaden aktuell!",client,255, 255, 0) 
			end
		end
	else
		outputChatBox ( "Du musst das Geld auf der Hand haben!", client, 255, 0, 0 )
	end
end)
