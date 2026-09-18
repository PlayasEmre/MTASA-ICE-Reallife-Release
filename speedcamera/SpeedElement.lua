--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function setElementSpeed(element,unit,speed)
	if (unit==nil)then unit=0 end
	if (speed==nil)then speed=0 end
	speed=tonumber(speed)
	local acSpeed=getElementSpeed(element,unit)
	if (acSpeed~=false)then
		local diff=speed/acSpeed
		local x,y,z=getElementVelocity(element)
		setElementVelocity(element,x*diff,y*diff,z*diff)
		return true
	end
	return false
end

function getElementSpeed(element,unit)
	if (unit==nil)then unit=0 end
	if (isElement(element))then
		local x,y,z=getElementVelocity(element)
		if (unit=="km/h" or unit==1 or unit=='1')then
			return(x^2+y^2+z^2)^0.5*100
		else
			return(x^2+y^2+z^2)^0.5*1.91*100
		end
	else
		outputDebugString("Kein Element Ich kann keine Geschwindigkeit bekommen")
		return false
	end
end