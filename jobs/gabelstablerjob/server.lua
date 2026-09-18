local car1 = createVehicle(455, -2858.40625, 1262.6044921875, 5.5710258483887, 0, 0, 316)
setElementFrozen(car1, true)
setVehicleDamageProof(car1, true)
setVehicleLocked(car1, true)

local car2 = createVehicle(455, -2859.8720703125, 1325.4677734375, 5.5710258483887, 0, 0, 49.999755859375)
setElementFrozen(car2, true)
setVehicleDamageProof(car2, true)
setVehicleLocked(car2, true)

local car3 = createVehicle(455, -2935.63671875, 1316.8974609375, 5.5710258483887, 0, 0, 139.99877929688)
setElementFrozen(car3, true)
setVehicleDamageProof(car3, true)
setVehicleLocked(car3, true)

local car4 = createVehicle(455, -2902.462890625, 1294.3673095703, 5.5710258483887, 0, 0, 139.99877929688)
setElementFrozen(car4, true)
setVehicleDamageProof(car4, true)
setVehicleLocked(car4, true)


local lohn = 150
local stabler = {}

local pickup = createPickup(-2967.274, 1233.04, 5, 3, 1239, 1000)
local marker = createMarker(-2967.274, 1233.04, 5, "corona", 1.0, 0, 0, 0, 0)



addEventHandler("onMarkerHit", marker, function(hitElement, dim)
if getElementType(hitElement) == "player" and (dim) then
	if isPedInVehicle ( hitElement ) == false then
		if(getElementData(hitElement, "IsInGabelJob") == true) then return end
		if MtxGetElementData (hitElement, "job") == "gabelstapler" then
			triggerEvent("onGabelstaplerJobStart", hitElement)
			triggerClientEvent("onload_gabelstaplerjob", hitElement)
		else
				triggerClientEvent("onClientGabelstaplerJobHit", hitElement)
				triggerClientEvent ( hitElement, "infobox_start", getRootElement(), "\n\nDu bist nun Gabelstapler-Fahrer!\nÖffne das Hilfemenü für mehr Informationen!", 7500, 0, 125, 0 )
			end
		end
	end
end)



addEvent("onGabelstaplerJobStart", true)
addEvent("onGabelstaplerJobAbgeliefert", true)
addEvent("onGabelstaplerJobStop", true)

addEventHandler("onGabelstaplerJobStart", getRootElement(), function()
	if(isElement(stabler[source])) then return end
	if(getElementData(source, "IsInGabelJob") == true) then return end
	local thePlayer = source
	setCameraMatrix(thePlayer, -2910.81, 1270.289, 9, -2877.426, 1282.03, 5)
	outputChatBox("[AUFGABE]: Lade die Kisten auf deinem Gabelstapler.", thePlayer, 0, 100, 200)
	outputChatBox("[AUFGABE]: Für jede Kiste bekommst du "..lohn..""..Tables.waehrung..". Du bekommst zusätzliches Geld für die grünen Kisten.", thePlayer, 0, 100, 200)
	setElementFrozen(thePlayer, true)
	setTimer(function()
		outputChatBox("[AUFGABE]: Bringe die Kisten dann zu den Transportern. Verlasse das Fahrzeug, wenn du aufhören möchtest.", thePlayer, 0, 100, 200)
		setCameraMatrix(thePlayer, -2890.993, 1284.616, 5, -2901.7, 1295, 8.18)
		setTimer(function()
			fadeCamera(thePlayer, false)
			setTimer(function()
				if(isElement(thePlayer)) then
					setElementFrozen(thePlayer, false)
					setCameraTarget(thePlayer, thePlayer)
					fadeCamera(thePlayer, true)
					MtxSetElementData(thePlayer, "job", "gabelstapler")
					stabler[thePlayer] = createVehicle(getVehicleModelFromName("Forklift"), -2947.23, 1255.64, 5, 0, 0, 0, getPlayerName(thePlayer))
					warpPedIntoVehicle(thePlayer, stabler[thePlayer])
					setVehicleDamageProof(stabler[thePlayer], true)
					setTimer ( SetGabelJob, 5000, 1, thePlayer )
				end
			end, 1500, 1)
		end, 2500, 1)
	end, 5000, 1)
end)

function SetGabelJob (thePlayer)
	setElementData (thePlayer, "IsInGabelJob", true)
end

function GabelstaplerStop ( thePlayer )
	if getElementData(thePlayer, "IsInGabelJob") == true then
		destroyElement(stabler[thePlayer])
		setElementData(thePlayer, "IsInGabelJob", false)
		triggerClientEvent(thePlayer, "onClientGabelstaplerJobQuit", thePlayer)
		outputChatBox("Job beendet!", thePlayer, 200, 200, 0)
	end
end
-- Vom Client: Absender erzwingen. Der serverinterne triggerEvent unten uebergibt
-- den Spieler weiterhin direkt.
addEventHandler("onGabelstaplerJobStop", getRootElement(), function ( thePlayer )
	GabelstaplerStop ( isElement ( client ) and client or thePlayer )
end)
addCommandHandler("gabelfixx", GabelstaplerStop)
addEventHandler ( "onVehicleExit", getRootElement(), GabelstaplerStop )

addEventHandler("onPlayerWasted", getRootElement(), function()
	if(stabler[source]) then
		triggerEvent("onGabelstaplerJobStop", source)
	end
end)

addEventHandler("onPlayerQuit", getRootElement(), function()
	if(stabler[source]) then
		destroyElement(stabler[source])
	end
end)

addEventHandler("onGabelstaplerJobAbgeliefert", getRootElement(), function(lohn2)
	if getElementData(source, "IsInGabelJob") ~= true then
		return
	end
	setElementData(source, "IsInGabelJob", false)
	local money = MtxGetElementData (source, "money")
	local gewinn = lohn
	MtxSetElementData (source, "money", money + gewinn)
	MtxSetElementData(source,"coins",tonumber(MtxGetElementData(source,"coins"))+20)
	outputChatBox("Du hast 20 Coins erhalten!", source, 255, 255, 255)
	givePlayerEXP(source,8)
end)