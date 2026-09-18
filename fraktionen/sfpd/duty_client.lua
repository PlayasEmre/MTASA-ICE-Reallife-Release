--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Das Duty-Fenster wurde entfernt: der Duty-Marker schaltet den Dienst jetzt
-- direkt um (siehe duty_server), Ausruestung kommt ueber /fguns.



--//Dutyicons
-- SAPD, SAPD2, FBI - zu einem Handler zusammengefasst statt drei separater
-- onClientRender-Registrierungen mit identischer Logik (spart Funktionsaufruf-
-- Overhead pro Frame, Verhalten pro Punkt bleibt unveraendert).
local dutyIconPoints = {
	{ x = -1611.5, y = 679.3, z = -5.3, interior = 0 },  -- SAPD
	{ x = 259.6, y = 110.6, z = 1003, interior = 10 },   -- SAPD2
	{ x = 325.2, y = 305.2, z = 999.1, interior = 5 },   -- FBI
}
addEventHandler("onClientRender",root,function()
	local x,y,z=getElementPosition(lp)
	local interior = getElementInterior(lp)
	for _, point in ipairs(dutyIconPoints) do
		if interior == point.interior and (getDistanceBetweenPoints3D(x,y,z,point.x,point.y,point.z)<=12) and (isLineOfSightClear(x,y,z,point.x,point.y,point.z,true,true,true,true,true)) then
			local sx,sy=getScreenFromWorldPosition(point.x,point.y,point.z)
			if(sx)and(sy)then
				sx=sx-20
				dxDrawText("Dienst",sx,sy,sx,sy,tocolor(0,0,0,200),1.5)
				dxDrawText("Dienst",sx+1,sy+1,sx,sy,tocolor(255,255,255,200),1.5)
			end
			break
		end
	end
end)
