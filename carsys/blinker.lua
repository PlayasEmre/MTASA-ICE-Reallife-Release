--[[
	//\\ Script by PSWGM9100 //\\
]]

local left = false
local right = false

function Blinker_Left()
	if isPedInVehicle(localPlayer) == true then
		if left == false then
			left = true
			local occupiedVehicle = getPedOccupiedVehicle(localPlayer)
			local x,y,z = getElementPosition(occupiedVehicle)
			Blinker_vorne = createMarker(x,y,z,"corona",0.3,238,154,0)
			Blinker_hinten = createMarker(x,y,z,"corona",0.3,238,154,0)
			attachElements(Blinker_vorne,occupiedVehicle,-0.8,2.3)
			attachElements(Blinker_hinten,occupiedVehicle,-0.8,-2.8)
			
			
			blink = setTimer(function()
				if getElementAlpha(Blinker_vorne) == tonumber(255) and getElementAlpha(Blinker_hinten) == tonumber(255) then
				setElementAlpha(Blinker_vorne,0)
				setElementAlpha(Blinker_hinten,0)
			else
				setElementAlpha(Blinker_vorne,255)
				setElementAlpha(Blinker_hinten,255)
				end
			end,500,0)
			
		else
			if isTimer ( blink ) then killTimer ( blink ) end
			destroyElement(Blinker_vorne)
			destroyElement(Blinker_hinten)
			left = false
		end
	end
end
bindKey(",","down",Blinker_Left)

function Blinker_Right()
	if isPedInVehicle(localPlayer) == true then
		if right == false then
			right = true
			local occupiedVehicle = getPedOccupiedVehicle(localPlayer)
			local x,y,z = getElementPosition(occupiedVehicle)
			Blinker_vorne1 = createMarker(x,y,z,"corona",0.3,238,154,0)
			Blinker_hinten1 = createMarker(x,y,z,"corona",0.3,238,154,0)
			attachElements(Blinker_vorne1,occupiedVehicle,0.8,2.3)
			attachElements(Blinker_hinten1,occupiedVehicle,0.8,-2.8)
			
			
			blink1 = setTimer(function()
				if getElementAlpha(Blinker_vorne1) == tonumber(255) and getElementAlpha(Blinker_hinten1) == tonumber(255) then
				setElementAlpha(Blinker_vorne1,0)
				setElementAlpha(Blinker_hinten1,0)
			else
				setElementAlpha(Blinker_vorne1,255)
				setElementAlpha(Blinker_hinten1,255)
				end
			end,500,0)
			
		else
			if isTimer ( blink1 ) then killTimer ( blink1 ) end
			destroyElement(Blinker_vorne1)
			destroyElement(Blinker_hinten1)
			right = false
		end
	end
end
bindKey(".","down",Blinker_Right)


function blinker()
   if isTimer(blink) and isTimer(blink1) then
		killTimer(blink)
		if isTimer ( blink1 ) then killTimer ( blink1 ) end
		destroyElement(Blinker_vorne)
		destroyElement(Blinker_hinten)
		destroyElement(Blinker_vorne1)
		destroyElement(Blinker_hinten1)
		left = false
		right = false
	end
end
addEventHandler("onClientVehicleExit",root,blinker)
