
--------------------------------------------------------
-----------------------Game Light-----------------------
-------- Discord https://discord.gg/HFwHnGguun ---------
--------------------------------------------------------

textyre_doroga = {}
shader_doroga = {}

--  script shadar ha va effect ha 
function hdroad(state)
	if state == true then
		textyre_doroga[1] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/vegasdirtyroad3_256.png", "dxt3")
		shader_doroga[1] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[1], "gTexture", textyre_doroga[1])
		engineApplyShaderToWorldTexture(shader_doroga[1], "vegasdirtyroad3_256")
		
		textyre_doroga[2] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/Tar_1line256HVblend2.png", "dxt3")
		shader_doroga[2] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[2], "gTexture", textyre_doroga[2])
		engineApplyShaderToWorldTexture(shader_doroga[2], "vegasdirtyroad3_256")
		engineApplyShaderToWorldTexture(shader_doroga[2], "Tar_1line256HVblend2")
		engineApplyShaderToWorldTexture(shader_doroga[2], "Tar_1line256HVblenddrt")
		engineApplyShaderToWorldTexture(shader_doroga[2], "Tar_1line256HVblenddrtdot")
		engineApplyShaderToWorldTexture(shader_doroga[2], "Tar_1line256HVgtravel")
		engineApplyShaderToWorldTexture(shader_doroga[2], "Tar_1line256HVlightsand")
		engineApplyShaderToWorldTexture(shader_doroga[2], "Tar_lineslipway")
		engineApplyShaderToWorldTexture(shader_doroga[2], "Tar_venturasjoin")
		engineApplyShaderToWorldTexture(shader_doroga[2], "conc_slabgrey_256128")
		
		textyre_doroga[3] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/snpedtest1BLND.png", "dxt3")
		shader_doroga[3] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[3], "gTexture", textyre_doroga[3])
		engineApplyShaderToWorldTexture(shader_doroga[3], "ws_freeway3blend")
		engineApplyShaderToWorldTexture(shader_doroga[3], "snpedtest1BLND")
		engineApplyShaderToWorldTexture(shader_doroga[3], "vegastriproad1_256")
		
		textyre_doroga[4] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/desert_1line256.png", "dxt3")
		shader_doroga[4] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[4], "gTexture", textyre_doroga[4])
		engineApplyShaderToWorldTexture(shader_doroga[4], "desert_1line256")
		engineApplyShaderToWorldTexture(shader_doroga[4], "desert_1linetar")
		engineApplyShaderToWorldTexture(shader_doroga[4], "roaddgrassblnd")
		
		textyre_doroga[5] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/crossing2_law.png", "dxt3")
		shader_doroga[5] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[5], "gTexture", textyre_doroga[5])
		engineApplyShaderToWorldTexture(shader_doroga[5], "crossing2_law")
		engineApplyShaderToWorldTexture(shader_doroga[5], "lasunion994")
		engineApplyShaderToWorldTexture(shader_doroga[5], "motocross_256")
		
		textyre_doroga[6] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/crossing_law.png", "dxt3")
		shader_doroga[6] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[6], "gTexture", textyre_doroga[6])
		engineApplyShaderToWorldTexture(shader_doroga[6], "crossing_law")
		engineApplyShaderToWorldTexture(shader_doroga[6], "crossing_law2")
		engineApplyShaderToWorldTexture(shader_doroga[6], "crossing_law3")
		engineApplyShaderToWorldTexture(shader_doroga[6], "sf_junction5")
		engineApplyShaderToWorldTexture(shader_doroga[6], "crossing_law.bmp")
				
		textyre_doroga[7] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/dt_road_stoplinea.png", "dxt3")
		shader_doroga[7] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[7], "gTexture", textyre_doroga[7])
		engineApplyShaderToWorldTexture(shader_doroga[7], "dt_road_stoplinea")
		
		textyre_doroga[8] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/Tar_freewyleft.png", "dxt3")
		shader_doroga[8] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[8], "gTexture", textyre_doroga[8])
		engineApplyShaderToWorldTexture(shader_doroga[8], "Tar_freewyleft")
		
		textyre_doroga[9] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/Tar_freewyright.png", "dxt3")
		shader_doroga[9] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[9], "gTexture", textyre_doroga[9])
		engineApplyShaderToWorldTexture(shader_doroga[9], "Tar_freewyright")
		
		textyre_doroga[10] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/Tar_1line256HV.png", "dxt3")
		shader_doroga[10] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[10], "gTexture", textyre_doroga[10])
		engineApplyShaderToWorldTexture(shader_doroga[10], "Tar_1line256HV")
		engineApplyShaderToWorldTexture(shader_doroga[10], "Tar_1linefreewy")
		engineApplyShaderToWorldTexture(shader_doroga[10], "des_1line256")
		engineApplyShaderToWorldTexture(shader_doroga[10], "des_1lineend")
		engineApplyShaderToWorldTexture(shader_doroga[10], "des_1linetar")
		
		textyre_doroga[11] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/sf_junction2.png", "dxt3")
		shader_doroga[11] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[11], "gTexture", textyre_doroga[11])
		engineApplyShaderToWorldTexture(shader_doroga[11], "sf_junction2")
		
		textyre_doroga[12] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/vegastriproad1_256.png", "dxt3")
		shader_doroga[12] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[12], "gTexture", textyre_doroga[12])
		engineApplyShaderToWorldTexture(shader_doroga[12], "vegastriproad1_256")
		engineApplyShaderToWorldTexture(shader_doroga[12], "ws_freeway3")
		engineApplyShaderToWorldTexture(shader_doroga[12], "cuntroad01_law")
		engineApplyShaderToWorldTexture(shader_doroga[12], "roadnew4blend_256")
		engineApplyShaderToWorldTexture(shader_doroga[12], "sf_road5")
		engineApplyShaderToWorldTexture(shader_doroga[12], "sl_roadbutt1")
		engineApplyShaderToWorldTexture(shader_doroga[12], "snpedtest1")
		
		textyre_doroga[13] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/vegastriproad1_256.png", "dxt3")
		shader_doroga[13] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[13], "gTexture", textyre_doroga[13])
		engineApplyShaderToWorldTexture(shader_doroga[13], "vegastriproad1_256")
		engineApplyShaderToWorldTexture(shader_doroga[13], "ws_freeway3")
		engineApplyShaderToWorldTexture(shader_doroga[13], "cuntroad01_law")
		engineApplyShaderToWorldTexture(shader_doroga[13], "roadnew4blend_256")
		engineApplyShaderToWorldTexture(shader_doroga[13], "sf_road5")
		engineApplyShaderToWorldTexture(shader_doroga[13], "sl_roadbutt1")
		engineApplyShaderToWorldTexture(shader_doroga[13], "snpedtest1")
		
		textyre_doroga[14] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/sl_freew2road1.png", "dxt3")
		shader_doroga[14] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[14], "gTexture", textyre_doroga[14])
		engineApplyShaderToWorldTexture(shader_doroga[14], "sl_freew2road1")
		engineApplyShaderToWorldTexture(shader_doroga[14], "snpedtest1blend")
		engineApplyShaderToWorldTexture(shader_doroga[14], "ws_carpark3")
		
		textyre_doroga[15] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/cos_hiwaymid_256.png", "dxt3")
		shader_doroga[15] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[15], "gTexture", textyre_doroga[15])
		engineApplyShaderToWorldTexture(shader_doroga[15], "cos_hiwaymid_256")
		engineApplyShaderToWorldTexture(shader_doroga[15], "sf_road5")
		
		textyre_doroga[16] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/hiwayend_256.png", "dxt3")
		shader_doroga[16] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[16], "gTexture", textyre_doroga[16])
		engineApplyShaderToWorldTexture(shader_doroga[16], "hiwayend_256")
		engineApplyShaderToWorldTexture(shader_doroga[16], "hiwaymidlle_256")
		engineApplyShaderToWorldTexture(shader_doroga[16], "vegasroad2_256")
		
		textyre_doroga[17] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/roadnew4_256.png", "dxt3")
		shader_doroga[17] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[17], "gTexture", textyre_doroga[17])
		engineApplyShaderToWorldTexture(shader_doroga[17], "roadnew4_256")
		engineApplyShaderToWorldTexture(shader_doroga[17], "roadnew4_512")
		engineApplyShaderToWorldTexture(shader_doroga[17], "vegasroad1_256")
		engineApplyShaderToWorldTexture(shader_doroga[17], "dt_road")
		engineApplyShaderToWorldTexture(shader_doroga[17], "vgsN_road2sand01")
		engineApplyShaderToWorldTexture(shader_doroga[17], "hiwayoutside_256")
		engineApplyShaderToWorldTexture(shader_doroga[17], "vegasdirtyroad1_256")
		engineApplyShaderToWorldTexture(shader_doroga[17], "vegasdirtyroad2_256")
		engineApplyShaderToWorldTexture(shader_doroga[17], "vegasroad3_256")
		
		textyre_doroga[18] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/sf_junction1.png", "dxt3")
		shader_doroga[18] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[18], "gTexture", textyre_doroga[18])
		engineApplyShaderToWorldTexture(shader_doroga[18], "sf_junction1")
		engineApplyShaderToWorldTexture(shader_doroga[18], "sf_junction3")
		
		textyre_doroga[19] = dxCreateTexture("shader/Grafik-Panel/files/hdroad/des_oldrunway.png", "dxt3")
		shader_doroga[19] = dxCreateShader("shader/Grafik-Panel/files/hdroad/shader.fx")
		dxSetShaderValue(shader_doroga[19], "gTexture", textyre_doroga[19])
		engineApplyShaderToWorldTexture(shader_doroga[19], "des_oldrunway")
		engineApplyShaderToWorldTexture(shader_doroga[19], "des_panelconc")
		engineApplyShaderToWorldTexture(shader_doroga[19], "plaintarmac1")
	else
		for k, v in pairs(textyre_doroga) do
			if isElement(textyre_doroga[k]) then 
				destroyElement(textyre_doroga[k])
			end
		end
		for k, v in pairs(shader_doroga) do
			if isElement(shader_doroga[k]) then 
				engineRemoveShaderFromWorldTexture(shader_doroga[k], "*") 
				destroyElement(shader_doroga[k]) 
			end
		end
	end
end

textyre_water = {}
shader_water = {}

function hdwater(state)
	if state == true then
		setShaders()
	else
		destroyShaders()
	end
end


--##### SETTINGS #####--

local moonIlluminance = 0.1			-- This value determines how strong the moon should illuminate the water at night
local specularSize = 9.0			-- Lower value = bigger specular lighting from sun (dynamic sky supported)
local flowSpeed = 0.8				-- Movement speed of the water
local reflectionSharpness = 0.06	-- lower value = sharper reflection
local reflectionStrength = 0.9		-- How much reflection?
local refractionStrength = 0.4		-- Strength of the refraction (Only surface refraction, stuff inside water does not get refracted currently)
local causticStrength = 0.3			-- Surface caustic wave effect strength
local causticSpeed = 0.2			-- Caustic movement speed
local causticIterations = 20		-- Caustic detail
local shoreFadeStrength = 0.101		-- lower value = stronger shore fading
setWaterColor(100,225,255,255)		-- i think this water color is pretty

--#######################

local width, height = guiGetScreenSize()
local ScreenInput = dxCreateScreenSource(width/6, height/6)-- Decrease this divisor to increase reflection quality. But anything higher than 1/6 is a waste of memory
local waterNormal = dxCreateTexture("shader/Grafik-Panel/files/hdwater/water/normal.png", "dxt1")
local waterFoam = dxCreateTexture("shader/Grafik-Panel/files/hdwater/water/foam.png", "dxt1")
local waterShader
local currentMinute, minuteStartTickCount, minuteEndTickCount = 0, 0, 0
local lowShader = dxCreateShader("shader/Grafik-Panel/files/hdwater/water_low.fx", 0, 0, false, "world")-- Low quality shader (This rudimentary shader only enables Z-Writing for default GTA:SA water)
if lowShader then
	engineApplyShaderToWorldTexture(lowShader, "waterclear256")
end
local effectBias = dxCreateShader("shader/Grafik-Panel/files/hdwater/effectBias.fx", 999, 0, false, "world")-- Apply depth bias to water effects to prevent flickering
if effectBias then
	engineApplyShaderToWorldTexture(effectBias, "coronaringa")
	engineApplyShaderToWorldTexture(effectBias, "boatwake1")
	engineApplyShaderToWorldTexture(effectBias, "waterwake")
	engineApplyShaderToWorldTexture(effectBias, "sphere")
end

function setShaders()
if ScreenInput and not waterShader then
	waterShader = dxCreateShader("shader/Grafik-Panel/files/hdwater/water.fx", 999, 0, false, "world")
		if waterShader then
			setNearClipDistance(0.299)-- prevent depth buffer glitching
			engineApplyShaderToWorldTexture(waterShader, "waterclear256")
			dxSetShaderValue(waterShader, "sPixelSize", {1/width, 1/height})
			dxSetShaderValue(waterShader, "normalTexture", waterNormal)
			dxSetShaderValue(waterShader, "foamTexture", waterFoam)
			dxSetShaderValue(waterShader, "screenInput", ScreenInput)
			dxSetShaderValue(waterShader, "specularSize", specularSize)
			dxSetShaderValue(waterShader, "flowSpeed", flowSpeed)
			dxSetShaderValue(waterShader, "reflectionSharpness", reflectionSharpness)
			dxSetShaderValue(waterShader, "reflectionStrength", reflectionStrength)
			dxSetShaderValue(waterShader, "refractionStrength", refractionStrength)
			dxSetShaderValue(waterShader, "causticStrength", causticStrength)
			dxSetShaderValue(waterShader, "causticSpeed", causticSpeed)
			dxSetShaderValue(waterShader, "causticIterations", causticIterations)
			dxSetShaderValue(waterShader, "deepness", shoreFadeStrength)
			removeEventHandler("onClientPreRender", root, updateShaders)
			addEventHandler("onClientPreRender", root, updateShaders)
		end
	end
end

function destroyShaders()
	removeEventHandler("onClientPreRender", root, updateShaders)
	if waterShader then
		destroyElement(waterShader)
		waterShader = nil
	end
	if lowShader then
		engineApplyShaderToWorldTexture(lowShader, "waterclear256")
	end
end

function updateShaders()
	if waterShader and ScreenInput then
		-- get Time with seconds
		local ho, mi = getTime()
		local se = 0
		if mi ~= currentMinute then
			minuteStartTickCount = getTickCount()
			local gameSpeed = math.clamp(0.01, getGameSpeed(), 10)
			minuteEndTickCount = minuteStartTickCount + getMinuteDuration() / gameSpeed
		end
		if minuteStartTickCount then
			local minFraction = math.unlerpclamped(minuteStartTickCount, getTickCount(), minuteEndTickCount)
			se = math_min (59, math.floor(minFraction * 60)) / 60 -- divide seconds by 60 to make it more useful
		end
		currentMinute = mi
		local shiningPower = getShiningPower(ho, mi, se)
		local sunX, sunY, sunZ = 0, 0, 0
		local moonX, moonY, moonZ = 0, 0, 0
		local skyResource = getResourceFromName("shader_dynamic_sky")
		if skyResource and getResourceState(skyResource) == "running" and exports.shader_dynamic_sky:isDynamicSkyEnabled() then-- try to get sun position from dynamic sky
			local px, py, pz = getElementPosition(localPlayer)
			local x, y, z = exports.shader_dynamic_sky:getDynamicSunVector()
			local dist = getFarClipDistance()*0.8
			sunX, sunY, sunZ = px - x*dist, py - y*dist, pz - z*dist
			x, y, z = exports.shader_dynamic_sky:getDynamicMoonVector()
			moonX, moonY, moonZ = px - x*dist, py - y*dist, pz - z*dist
		else
			shiningPower = 0-- if no sun position is available, disable specular lighting
		end
		local cr, cg, cb = getSunColor()
		local nightModifier = 1
		if ho >= 21 or ho < 5 then-- at night sun color is now moon color, sun position is now moon position, specular strength is lower
			cr, cg, cb = 255, 255, 255
			sunX, sunY, sunZ = moonX, moonY, moonZ
			nightModifier = 0.4
		end
		local wr, wg, wb, waterAlpha = getWaterColor()
		dxUpdateScreenSource(ScreenInput)
		dxSetShaderValue(waterShader, "dayTime", getDiffuse(ho, mi, se))
		dxSetShaderValue(waterShader, "waterShiningPower", shiningPower * nightModifier)
		dxSetShaderValue(waterShader, "waterColor", {wr/255, wg/255, wb/255, waterAlpha/255})
		dxSetShaderValue(waterShader, "sunColor", {cr/600, cg/600, cb/600})-- reduce sun color intensity because it looks garbage otherwise
		dxSetShaderValue(waterShader, "sunPos", {sunX, sunY, sunZ})
	end
end

function getDiffuse(ho, mi, se)
	local diffuse = 1
	if ho > 21 or ho < 6 then
		diffuse = 0
	end
	if ho == 6 then
		diffuse = 1 - (60 - mi - se) / 60-- make water bright at 6:00
	elseif ho == 20 then
		diffuse = 1 - (mi + se) / 60-- make water dark after 20:00
	elseif ho == 21 then-- add moon light after 21:00
		diffuse = math_min(1, 1 + (mi + se - 20) / 20) * moonIlluminance
	elseif ho > 21 or ho < 3 then
		diffuse = moonIlluminance
	elseif ho == 3 then-- remove moon light between 3:40 and 4:00
		diffuse = math_min(1, 1 - (mi + se - 40) / 20) * moonIlluminance
	end
	return diffuse
end

function getShiningPower(ho, mi, se)
	local shiningPower = 1
	if ho == 6 then
		if mi < 20 then-- lerp specular start between 6:00 - 6:20
			shiningPower = 1 - (20 - mi - se) / 20
		elseif mi >= 20 then
			shiningPower = 1
		end
	elseif ho == 19 then-- lerp specular end between 19:40 - 20:00
		shiningPower = math_min(1, 1 - (mi + se - 40) / 20)
	elseif ho == 20 or ho == 5 or ho == 4 then
		shiningPower = 0
	elseif ho == 3 then-- stop specular moon lighting between 3:40 and 4:00
		shiningPower = math_min(1, 1 - (mi + se - 40) / 20)
	elseif ho == 21 then
		shiningPower = math_min(1, 1 + (mi + se - 20) / 20)-- start specular moon lighting between 21:00 and 21:20
	end
	return shiningPower
end

function math.clamp(low, value, high)
    return math_max(low, math_min(value, high))
end

function math.unlerp(from, pos, to)
	if to == from then
		return 1
	end
	return (pos - from) / (to - from)
end

function math.unlerpclamped(from, pos, to)
	return math.clamp(0, math.unlerp(from, pos, to), 1)
end

function math_max(a, b)
	return a > b and a or b
end

function math_min(a, b)
	return a < b and a or b
end