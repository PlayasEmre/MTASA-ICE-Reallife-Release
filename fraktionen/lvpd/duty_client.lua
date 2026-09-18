--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Das Duty-Fenster wurde entfernt: der Duty-Marker schaltet den Dienst jetzt
-- direkt um (siehe duty_server), Ausruestung kommt ueber /fguns.



copskins={
[288]=true,[283]=true,[280]=true,[281]=true,[266]=true,[284]=true
}
fbiskins={
[285]=true,[286]=true,[165]=true,[164]=true,[163]=true
}



function isOnStateDuty(player)
	local model = getElementModel(lp) 
	if copskins[model] or fbiskins[model] then return true else return false end
end
