--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

jobchoosepickup = createPickup ( 362.39953613281, 180.4635925293, 1008.0034790039, 3, 1210, 50)
setElementInterior (jobchoosepickup, 3, 362.39953613281, 180.4635925293, 1008.0034790039)

createMarker ( -2044.0001220703,449.74362182617,35.172294616699, "cylinder", -1, getColorFromString ( "#FF000099" ) )
cityHallEnter = createMarker ( -2044.0001220703,449.74362182617,35.172294616699, "corona", 1, 0, 0, 0, 0)
cityHallExit = createMarker ( 389.67465209961,173.73570251465,1008.3828125, "corona", 1, 0, 0, 0, 0 )
cityHallExitOptic = createMarker ( 389.67465209961,173.73570251465,1008.3828125, "cylinder", -1, getColorFromString ( "#FF000099" ) )
setElementInterior ( cityHallExit, 3 )
setElementInterior ( cityHallExitOptic, 3 )


function jobchoosepickup_func (player)
	setElementFrozen ( player, true )
    setTimer ( setElementFrozen, 100, 1, player, false )
	triggerClientEvent ( player, "showJobGui", getRootElement() )
	showCursor ( player, true )
	setElementClicked ( player, true )
end
addEventHandler ( "onPickupHit", jobchoosepickup, jobchoosepickup_func )

function pickedUpRathaus (source, dim)
	if getElementType(source) == "player" and dim and getPedOccupiedVehicle(source) == false then
		addEventHandler("onPlayerWeaponSwitch",source,dontHoldWeapon)
		fadeElementInterior ( source, 3, 388.5, 173.82061767578, 1008.032043457, 90 )
		toggleControl (source,"fire", true )
		toggleControl (source,"aim_weapon", true )
		toggleControl (source,"next_weapon", true )
		toggleControl (source,"previous_weapon", true )
		MtxSetElementData(source,"nodmzone", 1)
	end	
end
addEventHandler ( "onMarkerHit", cityHallEnter, pickedUpRathaus )


function pickedUpRathaus2 (source)
	if getElementType(source) == "player" and getPedOccupiedVehicle(source) == false then
	   removeEventHandler("onPlayerWeaponSwitch",source,dontHoldWeapon)
	   fadeElementInterior ( source, 0, -2043.9810791016,451.46301269531,35.172294616699, 270 )
	   toggleControl (source,"fire", false )
	   toggleControl (source,"aim_weapon", false )
	   toggleControl (source,"next_weapon", false )
	   toggleControl (source,"previous_weapon", false )
	   MtxSetElementData(source,"nodmzone", 0)
	end
end
addEventHandler ( "onMarkerHit", cityHallExit, pickedUpRathaus2 )


rathausmarker = createMarker ( 362.45562744141, 173.81, 1007.5, "corona", 2, 125, 0, 0, 0 )
setElementInterior (rathausmarker, 3)
rathausmarker2 = createMarker ( 362.45562744141, 173.81, 1007, "cylinder", 1, 125, 0, 0 )
setElementInterior (rathausmarker2, 3)

function rathausmarker_func (player)
   
    setElementFrozen ( player, true )
    setTimer ( setElementFrozen, 100, 1, player, false )
	triggerClientEvent ( player, "ShowRathausMenue", getRootElement() )
	showCursor ( player, true )
	setElementClicked ( player, true )
end
addEventHandler ( "onMarkerHit", rathausmarker, rathausmarker_func )

rathausped = createPed(141, 359.7138671875, 173.625765625, 1008.38934)
setElementInterior (rathausped, 3)
setPedRotation(rathausped, 280)

function dontHoldWeapon()
	setPedWeaponSlot(source,0)
end