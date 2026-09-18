--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

addEvent( "doSuspensionTool", true )

function BaixarCarro ( )
	if isPedInVehicle(localPlayer) then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if getVehicleType ( vehicle ) == "Automobile" or getVehicleType ( vehicle ) == "Monster Truck" or getVehicleType ( vehicle ) == "Quad" then
			guiSetText ( TxtHoldCtrl, "STRG zum Benutzen!")

			local seatvehicle = getVehicleOccupant(vehicle,0)
			if (seatvehicle) then
				EscondeMostra()
			else
				infobox_start_func ( "Nur für den\nFahrer erlaubt!", 3000, 255, 0, 0 )
			end
		else
			infobox_start_func ( "\nNur für\nAutos!", 3000, 255, 0, 0 )
		end
	else
        infobox_start_func ( "Du bist in\nkeinem Fahrzeug!", 3000, 255, 0, 0 )
	end
end
addEventHandler( "doSuspensionTool", getRootElement(), BaixarCarro  )

function Levanta()
    triggerServerEvent("subir", localPlayer)
end

function Desce()
    triggerServerEvent("descer", localPlayer)
end

addEventHandler ( "onClientPlayerVehicleEnter", localPlayer, function ( veh, seat )
	if getElementData ( source, "adminlvl" ) >= 1 then
	if seat == 0 then
		if getVehicleType ( veh ) == "Automobile" or getVehicleType ( veh ) == "Monster Truck" or getVehicleType ( veh ) == "Quad" then 
			bindKey("O", "down", BaixarCarro)
		end
	end
	end
end )

function removeTheSuspensionKey ( )
	unbindKey ("O", "down", BaixarCarro)
	removeEventHandler ( "onClientPlayerVehicleExit", localPlayer, removeTheSuspensionKey )
end