--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function giveSportmotorUpgrade ( veh )
	local sportmotor = MtxGetElementData ( veh, "sportmotor" )
	if sportmotor and sportmotor > 0 then
		local vehmodel = getElementModel ( veh ) 
		setVehicleHandling(veh, "engineAcceleration", (getModelHandling(vehmodel)['engineAcceleration']* (1 + 0.2*sportmotor)))
		setVehicleHandling(veh, "maxVelocity", (getModelHandling(vehmodel)['maxVelocity']*(1 + 0.2*sportmotor)))	
		setVehicleHandling(veh, "engineInertia", (getModelHandling(vehmodel)['engineInertia']*(1 + 0.2*sportmotor)))	
		setVehicleHandling(veh, "mass", (getModelHandling(vehmodel)['mass']*(1 + 0.2*sportmotor)))
		setVehicleHandling(veh, "turnMass", (getModelHandling(vehmodel)['turnMass']*(1 + 0.2*sportmotor)))
	end
	local bremse = MtxGetElementData ( veh, "bremse" )
	if bremse and bremse > 0 then
		local vehmodel = getElementModel ( veh ) 
		setVehicleHandling(veh, "brakeDeceleration", (getModelHandling(vehmodel)['brakeDeceleration']*(1 + 0.2*sportmotor)))
		setVehicleHandling(veh, "tractionMultiplier", (getModelHandling(vehmodel)['tractionMultiplier']*(1 + 0.2*sportmotor)))	
	end
	local antrieb = MtxGetElementData ( veh, "antrieb" )
	if antrieb then
		setVehicleHandling ( veh, "driveType", antrieb )
	end
end