--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local lastdeagleshot = 0
local gotdeagle = false
toggleControl ( "fire", true )


function stopFastShotOnDeagleEvent ( )
	if lastdeagleshot + 700 >= getTickCount() then
		toggleControl ( "fire", false )
		lastdeagleshot = getTickCount() + 560000/(getTickCount()-lastdeagleshot)
	else
		lastdeagleshot = getTickCount()
	end
end


function stopFastShotOnDeagleBinded ( )
	if lastdeagleshot + 700 < getTickCount() then
		toggleControl ( "fire", true )
	end
end


addEventHandler ( "onClientPlayerWeaponSwitch", root, function ( previous, current )	
	if getPedWeapon ( localPlayer, current ) == 24 then
		addEventHandler ( "onClientPlayerWeaponFire", localPlayer, stopFastShotOnDeagleEvent )
		bindKey ( "fire", "both", stopFastShotOnDeagleBinded )
		gotdeagle = true
	elseif gotdeagle then
		removeEventHandler ( "onClientPlayerWeaponFire", localPlayer, stopFastShotOnDeagleEvent )
		unbindKey ( "fire", "both", stopFastShotOnDeagleBinded )
		toggleControl ( "fire", true )
		gotdeagle = false
	end
end )

--Anti-Ducken (hierbei nur Sniper) by Bonus

local lastsnipershot = 0

addEventHandler ( "onClientPlayerWeaponFire", localPlayer, function ( weapon )
	if weapon == 34 then
		lastsnipershot = getTickCount()
	end
end )

function stopCrouchOnSniper ( )
	if lastsnipershot + 1500 > getTickCount() then
		toggleControl ( "crouch", false )
	else
		toggleControl ( "crouch", true )
	end
end

addEventHandler ( "onClientPlayerWeaponSwitch", getRootElement(), function ( previous, current )
	if getPedWeapon ( localPlayer, current ) == 34 then
		bindKey ( "crouch", "down", stopCrouchOnSniper )
	elseif previous == 6 then
		unbindKey ( "crouch", "down", stopCrouchOnSniper )
		toggleControl ( "crouch", true )
	end
end )