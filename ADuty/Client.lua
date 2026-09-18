--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local function Aduty_NoDMG_Func()
	if getElementData(localPlayer,"adminduty") then
		cancelEvent()
	end
end
addEventHandler("onClientPlayerDamage",localPlayer,Aduty_NoDMG_Func)
addEventHandler("onClientPlayerStealthKill", localPlayer, Aduty_NoDMG_Func)


local adminScanAt = 0
local dutyAdmins = {}

addEventHandler("onClientRender", root, function()
	-- Die Liste der Admins im Supportmodus aendert sich selten. Sie jeden Frame
	-- ueber alle Spieler neu aufzubauen ist der teuerste Teil, deshalb nur alle
	-- 500 ms. Gezeichnet wird weiterhin in jedem Frame.
	local now = getTickCount()
	if now - adminScanAt >= 500 then
		adminScanAt = now
		dutyAdmins = {}
		for _, pelement in ipairs(getElementsByType("player")) do
			if getElementData(pelement, "adminduty") then
				dutyAdmins[#dutyAdmins+1] = pelement
			end
		end
	end

	if #dutyAdmins == 0 then return end

	local x2, y2, z2 = getElementPosition(localPlayer)
	local dim = getElementDimension(localPlayer)
	local int = getElementInterior(localPlayer)

	for i = 1, #dutyAdmins do
		local pelement = dutyAdmins[i]
		if isElement(pelement) and getElementDimension(pelement) == dim and getElementInterior(pelement) == int then
			local x, y, z = getElementPosition(pelement)
			-- Abstand vor der Sichtlinie pruefen: isLineOfSightClear ist ein
			-- Raycast und lief bisher fuer jeden Admin auf der Karte, obwohl der
			-- Text erst unter 5 Metern gezeichnet wird.
			local distance = getDistanceBetweenPoints3D(x, y, z+0.60, x2, y2, z2)
			if distance < 5 and isLineOfSightClear(x, y, z, x2, y2, z2, true, false, false, true) then
				local sx, sy = getScreenFromWorldPosition(x, y, z+0.60)
				if sx and sy then
					local fontbig = 3 - (distance/30)
					dxDrawText("Admin im Supporter-Modus", sx -2, sy -230, sx, sy, tocolor(0, 0, 0, 200), fontbig, "arial", "center")
					dxDrawText("Admin im Supporter-Modus", sx, sy -230, sx, sy, tocolor(255, 0, 0, 200), fontbig, "arial", "center")
				end
			end
		end
	end
end)