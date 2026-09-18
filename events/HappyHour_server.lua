--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local isHappyHour = false
local wochentage = {"So","Mo","Di","Mi","Do","Fr","Sa"};
local StartTime = 14;
local EndTime = 20;

setTimer(function()
	local time = getRealTime();
	local hour = time.hour;
	local weekday = time.weekday;

	if isHappyHour == false then
		if wochentage[weekday+1] == "Fr" and hour == StartTime or wochentage[weekday+1] == "Sa" and hour == StartTime or wochentage[weekday+1] == "So" and hour == StartTime then
			outputDebugString("Die Happy-Hour hat begonnen",3,0,255,9)
			outputChatBox("#FF00DE[Happy Hour] #ffffffDie Happy Hour läuft nun:", root, 255, 0, 0,true)
			outputChatBox("#FF00DE[Happy Hour] #ffffffZwischen 14 Uhr und 20 Uhr habt Ihr nun folgende Vorzüge.", root, 255, 0, 0,true)
			outputChatBox("#FF00DE[Happy Hour] #ffffffGangwars können ohne gegnerische Fraktion gestartet werden.", root, 255, 0, 0,true)
			outputChatBox("#FF00DE[Happy Hour] #ffffffPayday-Event gestartet!",root, 255, 0, 0,true)
			outputChatBox("#FF00DE[Happy Hour] #ffffffDie Tactics Arena findet immer am Freitag, Samstag und Sonntag statt.",root, 255, 0, 0,true)
			isHappyHour = true
			minanzahlangwteilnehmern = 0
			event.ispaydaycoins = true
			tacticsoffon = false
		end
	else
		if hour == EndTime then
			if isHappyHour == true then
				outputDebugString("Die Happy-Hour wurde beendet",3,255,0,0)
				outputChatBox("#FF00DE[Happy Hour] #ffffffDie Happy Hour ist nun vorbei.", root, 255, 0, 0,true)
				isHappyHour = false
				minanzahlangwteilnehmern = 3
				event.ispaydaycoins = false
				tacticsoffon = true
			end
		end	
	end	
end,1000,0)