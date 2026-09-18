------------------------------
-------- Urheberrecht --------
------- by [LA]Leyynen -------
------------ 2012 ------------
------------------------------
---- Script by Noneatme ------


local gate = {}
local gatevar = {}
gate[1] = createObject(968, -2062.2900390625, -101.900390625, 35, 0, 90, 90) -- Schranke
-- Offen: -2062, -101, 35, 0, 0, 90
gatevar[1] = false
isSchrankenTimer = false


addCommandHandler("mv", function(thePlayer)
		if isSchrankenTimer == false then
			local x, y, z = getElementPosition(gate[1])
			local x2, y2, z2 = getElementPosition(thePlayer)
			if(getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) > 10) then return end
			local i = 1
			if(gatevar[i] == false) then
				gatevar[i] = true
				moveObject(gate[i], 1500, -2062.2900390625, -101.900390625, 35, 0, -90, 0)
				isSchrankenTimer = true
				setTimer(function()
					isSchrankenTimer = false
				end, 1500, 1)
			else
				gatevar[i] = false
				moveObject(gate[i], 1500, -2062.2900390625, -101.900390625, 35, 0, 90, 0)
				isSchrankenTimer = true
				setTimer(function()
					isSchrankenTimer = false
				end, 1500, 1)
			end
		end
end)

local element = {}
element["tor1"] = createObject(10575, -2072.2001953125, -131.099609375, 36.099998474121, 0, 0, 180)
element["tor2"] = createObject(10575, -2072.2001953125, -138.7001953125, 36.099998474121, 0, 0, 180)
element["tor3"] = createObject ( 10575, -2072.2001953125, -146.400390625, 36.099998474121, 0, 0, 180 )

local svar = {}
svar[1] = false
svar[2] = false
svar[3] = false


local smoving = {}
smoving[1] = false
smoving[2] = false
smoving[3] = false


for i = 1, #svar, 1 do
	setObjectScale(element["tor"..i], 0.91000002)
	addCommandHandler("mv", function(thePlayer)
	if(isMechaniker(thePlayer)) or isMedic(player) or isFBI(player) then
			local x, y, z = getElementPosition(element["tor"..i])
			local x2, y2, z2 = getElementPosition(thePlayer)
			if(getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) > 5) then return end
			if(smoving[i] == false) then
				if (svar[i] == false) then
					svar[i] = true
					smoving[i] = true
					--HOCH
					moveObject ( element["tor"..i], 3000, x, y, 37.799998474121, 0, 90, 0 )
					setTimer(function()
						smoving[i] = false
					end, 3000,1)
				else 
					--RUNTER
					moveObject ( element["tor"..i], 3000, x, y, 36.099998474121, 0, -90, 0 )
					svar[i] = false
					smoving[i] = true
					setTimer(function()
						smoving[i] = false
					end, 3000,1)
				end
			end
		end
	end)
end

local gate = createObject(980, -1907.5, -858.59997558594, 33.799999237061, 0, 0, 90)
local state = false
 
function move(player)
    local Name = getPlayerName(player)
    if(isMechaniker(player)) or isMedic(player) or isFBI(player) then
        local x, y, z = getElementPosition(gate)
		local x2, y2, z2 = getElementPosition(player)
		if(getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) > 7) then return end
        if not state then
            moveObject(gate, 2000, -1907.5, -858.59997558594, 28.299999237061)
            state = not state
        elseif state then
            moveObject(gate, 2000, -1907.5, -858.59997558594, 33.799999237061)
            state = not state
        end
	end
end	
addCommandHandler("mv", move)