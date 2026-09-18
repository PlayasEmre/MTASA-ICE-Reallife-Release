--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local color = {255, 255, 255, 0, 255}

createFactionVehicle (525, -2020.6, -227, 35.2, 0, 0, 90, 11, color ) -- Towtruck
createFactionVehicle (525, -2020.5, -215.5, 35.2, 0, 0, 90, 11, color ) -- Towtruck
createFactionVehicle (525, -2020.6, -238.60001, 35.2, 0, 0, 90, 11, color ) -- Towtruck
createFactionVehicle (525, -2020.8, -250.3, 35.2, 0, 0, 90, 11, color ) -- Rumpo
createFactionVehicle (525, -2087.1001, -215, 35.2, 0, 0, 270, 11, color ) -- Rumpo
createFactionVehicle (525, -2087, -226.60001, 35.2, 0, 0, 270, 11, color ) -- Wayfarer
createFactionVehicle (525, -2087.1001, -238.2, 35.2, 0, 0, 270, 11, color ) -- Wayfarer
createFactionVehicle (525, -2087, -249.89999, 35.2, 0, 0, 270, 11, color ) -- Wayfarer

local heli = createFactionVehicle (417, -2026.6, -137.2, 35.4, 0, 0, 49.988, 11, color ) -- Leviathan
heli = createFactionVehicle (417, -2028.7998, -160.7998, 35.4, 0, 0, 50.482, 11, color )

setVehicleAsMagnetHelicopter(heli)
addEventHandler("onVehicleExplode", heli, function() 
	MtxSetElementData(heli, "magnet", false)
end)