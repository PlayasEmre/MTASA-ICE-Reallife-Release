--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function reload_settimer (total_clip, cur_clip, cur_gun)

	toggleControl ( "next_weapon", false )
	toggleControl ( "previous_weapon", false )
	setPedControlState ( localPlayer, "aim_weapon", false )
	setPedControlState ( localPlayer, "fire", false )
	setTimer ( rebind_wpchange, 500, 1, total_clip )
	setTimer ( kill_evr, 5000, 1 )
end
addEvent( "reload_settimer_trigger", true )
addEventHandler( "reload_settimer_trigger", getRootElement(), reload_settimer )

function rebind_wpchange (total_clip)

	local x = getPedAmmoInClip ( localPlayer, getPedWeaponSlot ( localPlayer ) )
	if x == total_clip then
		toggleControl ( "next_weapon", true )
		toggleControl ( "previous_weapon", true )
		toggleControl ( "fire", true )
		if getPedWeaponSlot ( localPlayer ) ~= 1 then
			toggleControl ( "aim_weapon", true )
		end
	else
		setTimer ( rebind_wpchange, 500, 1, total_clip )
	end
end

function kill_evr ()

	toggleControl ( "next_weapon", true )
	toggleControl ( "previous_weapon", true )
	toggleControl ( "fire", true )
	toggleControl ( "aim_weapon", true )
end