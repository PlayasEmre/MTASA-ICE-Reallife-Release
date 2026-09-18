--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


local SetHunger = {["Emre"] = true}

local function setHunger()
	if SetHunger[getPlayerName(localPlayer)] then
	    setElementHunger(100)	
	end
end
setTimer(setHunger,60000,0)