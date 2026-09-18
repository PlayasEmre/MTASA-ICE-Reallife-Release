local Fahrschule_Enter=createMarker(-1731.5,-114.1,3.5,"corona",1,255,255,255,160)
local Fahrschule_Exit=createMarker(-2026.9,-103.8,1035.2,"corona",1,255,255,255,160)
setElementInterior(Fahrschule_Exit,3)
setElementDimension(Fahrschule_Exit,0)

local function Fahrschule_Enter_func(player)
	if getElementDimension(player) == 0 and getElementInterior(player) == 0 then
		if getPedOccupiedVehicle(player) == false then
			fadeElementInterior(player,3,-2028.5,-105.1,1035.2,180,70)
		end
	end
end
addEventHandler("onMarkerHit",Fahrschule_Enter,Fahrschule_Enter_func)

local function Fahrschule_Exit_func(player)
	if getElementDimension(player) == 0 and getElementInterior(player) == 3 then
		fadeElementInterior(player,0,-1733.1,-115.5,3.5,132,0)
	end
end
addEventHandler("onMarkerHit",Fahrschule_Exit,Fahrschule_Exit_func)
