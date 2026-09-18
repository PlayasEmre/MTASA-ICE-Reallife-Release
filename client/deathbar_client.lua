--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

addEventHandler ( "onClientPlayerWasted", localPlayer, function ( killer, weapon, ammo, bodypart )
	-- Falls beim Sterben noch ein Menü offen war, blieb der Mauszeiger aktiv und
	-- hat dadurch die freie Kamera-Drehung blockiert. Beim Sterben immer sauber
	-- zurücksetzen, damit man sich umschauen kann (z.B. während des Transports).
	showCursor ( false )
	setElementClicked ( false )
	triggerServerEvent ( "onPlayerWastedTriggered", lp, killer, weapon, ammo, bodypart )
end )
