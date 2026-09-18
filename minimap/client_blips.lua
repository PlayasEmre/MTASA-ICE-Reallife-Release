--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

--# Textures table

local blips_textures = {
  { "arrow", ":"..getResourceName(getThisResource()).."/minimap/blips/arrow.png" },
  { "radardisc", ":"..getResourceName(getThisResource()).."/minimap/blips/radardisc.png" },
  { "radar_airYard", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_airYard.png" },
  { "radar_ammugun", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_ammugun.png" },
  { "radar_barbers", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_barbers.png" },
  { "radar_BIGSMOKE", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_BIGSMOKE.png" },
  { "radar_boatyard", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_boatyard.png" },
  { "radar_bulldozer", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_bulldozer.png" },
  { "radar_burgerShot", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_burgerShot.png" },
  { "radar_cash", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_cash.png" },
  { "radar_CATALINAPINK", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_CATALINAPINK.png"},
  { "radar_centre", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_centre.png" },
  { "radar_CESARVIAPANDO", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_CESARVIAPANDO.png" },
  { "radar_chicken", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_chicken.png" },
  { "radar_CJ", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_CJ.png" },
  { "radar_CRASH1", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_CRASH1.png" },
  { "radar_dateDisco", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_dateDisco.png" },
  { "radar_dateDrink", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_dateDrink.png" },
  { "radar_dateFood", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_dateFood.png" },
  { "radar_diner", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_diner.png" },
  { "radar_emmetGun", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_emmetGun.png" },
  { "radar_enemyAttack", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_enemyAttack.png" },
  { "radar_fire", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_fire.png" },
  { "radar_Flag", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_Flag.png" },
  { "radar_gangB", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_gangB.png" },
  { "radar_gangG", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_gangG.png" },
  { "radar_gangN", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_gangN.png" },
  { "radar_gangP", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_gangP.png" },
  { "radar_gangY", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_gangY.png" },
  { "radar_girlfriend", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_girlfriend.png" },
  { "radar_gym", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_gym.png" },
  { "radar_hostpital", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_hostpital.png" },
  { "radar_impound", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_impound.png" },
  { "radar_light", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_light.png" },
  { "radar_LocoSyndicate", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_LocoSyndicate.png" },
  { "radar_MADDOG", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_MADDOG.png" },
  { "radar_mafiaCasino", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_mafiaCasino.png" },
  { "radar_MCSTRAP", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_MCSTRAP.png" },
  { "radar_modGarage", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_modGarage.png" },
  { "radar_north", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_north.png" },
  { "radar_OGLOC", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_OGLOC.png" },
  { "radar_pizza", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_pizza.png" },
  { "radar_police", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_police.png" },
  { "radar_propertyG", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_propertyG.png" },
  { "radar_propertyR", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_propertyR.png" },
  { "radar_qmark", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_qmark.png" },
  { "radar_race", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_race.png" },
  { "radar_runway", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_runway.png" },
  { "radar_RYDER", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_RYDER.png" },
  { "radar_saveGame", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_saveGame.png" },
  { "radar_school", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_school.png" },
  { "radar_spray", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_spray.png" },
  { "radar_SWEET", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_SWEET.png" },
  { "radar_tattoo", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_tattoo.png" },
  { "radar_THETRUTH", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_THETRUTH.png" },
  { "radar_TORENO", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_TORENO.png" },
  { "radar_TorenoRanch", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_TorenoRanch.png" },
  { "radar_triads", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_triads.png" },
  { "radar_triadsCasino", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_triadsCasino.png" },
  { "radar_truck", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_truck.png" },
  { "radar_tshirt", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_tshirt.png" },
  { "radar_waypoint", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_waypoint.png" },
  { "radar_WOOZIE", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_WOOZIE.png" },
  { "radar_ZERO", ":"..getResourceName(getThisResource()).."/minimap/blips/radar_ZERO.png" },
  { "siterocket", ":"..getResourceName(getThisResource()).."/minimap/blips/siterocket.png" }
}

--# Apply textures

addEvent("cdn:onClientReady",true)
addEventHandler("cdn:onClientReady",resourceRoot,function()
	for i = 2, #blips_textures do
		local shader = dxCreateShader(":"..getResourceName(getThisResource()).."/minimap/texture.fx")
		engineApplyShaderToWorldTexture(shader, blips_textures[i][1])
		dxSetShaderValue(shader, "gTexture", dxCreateTexture(blips_textures[i][2]))
	end
end)