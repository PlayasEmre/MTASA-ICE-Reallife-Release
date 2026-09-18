--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local ansagean = true

function pdansage(player)
local veh = getPedOccupiedVehicle ( player )
if veh then
local x, y, z = getElementPosition(player)
local chatSphere = createColSphere ( x, y, z, 20 )
local nearbyPlayers = getElementsWithinColShape ( chatSphere, "player" )
destroyElement ( chatSphere )
    if isOnDuty(player) or isFBI(player) or isArmy(player) then	
		if not ansagean then
			outputChatBox("Offenbar wurde berreits vor kurzem gebindet, bitte warte 3 Sekunden!", player, 200, 0, 0)
		return
		end				
        ansagean = false			
		setTimer(function ()
			ansagean = true
		end, 3000, 1)		
		triggerClientEvent ("speak1", getRootElement(), player, x, y, z )
		for index, nearbyPlayer in ipairs ( nearbyPlayers ) do
		    outputChatBox("Du wurdest gebindet!", nearbyPlayer, 200, 0, 0)
		end
    else
	    outputChatBox ( "Du bist kein Cop im Dienst!", player )
    end
	else
	    outputChatBox ( "Du musst in einem Fahrzeug sitzen", player )
    end
end
addCommandHandler("ansage",pdansage)

local vkkan = true

function vkkansage(player)
local veh = getPedOccupiedVehicle ( player )
if veh then
local x, y, z = getElementPosition(player)
local chatSphere = createColSphere ( x, y, z, 20 )
local nearbyPlayers = getElementsWithinColShape ( chatSphere, "player" )
destroyElement ( chatSphere )
if isOnDuty(player) or isFBI(player) or isArmy(player) then
		if not vkkan then
			outputChatBox("Offenbar wurde berreits vor kurzem gebindet, bitte warte 3 Sekunden!", player, 200, 0, 0)
		return
		end				
        vkkan = false			
		setTimer(function ()
			vkkan = true
		end, 3000, 1)
		triggerClientEvent ("speak2", getRootElement(), player, x, y, z )
	    for index, nearbyPlayer in ipairs ( nearbyPlayers ) do
		    outputChatBox("Du wurdest gebindet!", nearbyPlayer, 200, 0, 0)
		end
    else
	  outputChatBox ( "Du bist kein Cop im Dienst!", player )
    end
	else
	    outputChatBox ( "Du musst in einem Fahrzeug sitzen", player )
    end
end
addCommandHandler("vkk",vkkansage)	
	
local gesuchtan = true

function gesucht(player)
local veh = getPedOccupiedVehicle ( player )
if veh then
local x, y, z = getElementPosition(player)
local chatSphere = createColSphere ( x, y, z, 20 )
local nearbyPlayers = getElementsWithinColShape ( chatSphere, "player" )
destroyElement ( chatSphere )
if isOnDuty(player) or isFBI(player) or isArmy(player) then
		if not gesuchtan then
			outputChatBox("Offenbar wurde berreits vor kurzem gebindet, bitte warte 3 Sekunden!", player, 200, 0, 0)
		return
		end				
        gesuchtan = false			
		setTimer(function ()
			gesuchtan = true
		end, 3000, 1)
		triggerClientEvent ("speak3", getRootElement(), player, x, y, z )
		for index, nearbyPlayer in ipairs ( nearbyPlayers ) do
		    outputChatBox("Du wurdest gebindet!", nearbyPlayer, 200, 0, 0)
        end			
    else
	  outputChatBox ( "Du bist kein Cop im Dienst!", player )
    end
	else
	    outputChatBox ( "Du musst in einem Fahrzeug sitzen", player )
    end
end
addCommandHandler("gesucht",gesucht)



local ansagean = true

function pdansage(player)
local veh = getPedOccupiedVehicle ( player )
if veh then
local x, y, z = getElementPosition(player)
local chatSphere = createColSphere ( x, y, z, 20 )
local nearbyPlayers = getElementsWithinColShape ( chatSphere, "player" )
destroyElement ( chatSphere )
    if isOnDuty(player) or isFBI(player) or isArmy(player) then	
		if not ansagean then
			outputChatBox("Offenbar wurde berreits vor kurzem gebindet, bitte warte 3 Sekunden!", player, 200, 0, 0)
		return
		end				
        ansagean = false			
		setTimer(function ()
			ansagean = true
		end, 3000, 1)		
		triggerClientEvent ("speak4", getRootElement(), player, x, y, z )
		for index, nearbyPlayer in ipairs ( nearbyPlayers ) do
		    outputChatBox("Du wurdest gebindet!", nearbyPlayer, 200, 0, 0)
		end
    else
	    outputChatBox ( "Du bist kein Cop im Dienst!", player )
    end
	else
	    outputChatBox ( "Du musst in einem Fahrzeug sitzen", player )
    end
end
addCommandHandler("vvkcall",pdansage)





local ansagean2 = true

function pdansage2(player)
local veh = getPedOccupiedVehicle ( player )
if veh then
local x, y, z = getElementPosition(player)
local chatSphere = createColSphere ( x, y, z, 20 )
local nearbyPlayers = getElementsWithinColShape ( chatSphere, "player" )
destroyElement ( chatSphere )
    if isOnDuty(player) or isFBI(player) or isArmy(player) then	
		if not ansagean2 then
			outputChatBox("Offenbar wurde berreits vor kurzem gebindet, bitte warte 3 Sekunden!", player, 200, 0, 0)
		return
		end				
        ansagean2 = false			
		setTimer(function ()
			ansagean2 = true
		end, 3000, 1)		
		triggerClientEvent ("speak5", getRootElement(), player, x, y, z )
		for index, nearbyPlayer in ipairs ( nearbyPlayers ) do
		    outputChatBox("Du wurdest gebindet!", nearbyPlayer, 200, 0, 0)
		end
    else
	    outputChatBox ( "Du bist kein Cop im Dienst!", player )
    end
	else
	    outputChatBox ( "Du musst in einem Fahrzeug sitzen", player )
    end
end
addCommandHandler("vvk2",pdansage2)