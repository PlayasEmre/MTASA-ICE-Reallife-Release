--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function FBI_Duty_Func(player,cmd)
	if isFBI (player)then
		if not isOnDuty(player)then
			if MtxGetElementData(player,"rang")==5 then
				setElementModel(player,163)
			elseif MtxGetElementData(player,"rang")==4 then
				setElementModel(player,164)
			elseif MtxGetElementData(player,"rang")==3 then
				setElementModel(player,282)
			elseif MtxGetElementData(player,"rang")==2 then
				setElementModel(player,165)
			elseif MtxGetElementData(player,"rang")==1 then
				setElementModel(player,166)
			elseif MtxGetElementData(player,"rang")==0 then
				setElementModel(player,284)
			end
			setPedArmor(player,100)
			setElementHunger(player,100)
			setElementHealth(player,100)
			outputChatBox("Du hast den Dienst als Polizist angetreten!",player)
			outputChatBox("Ausruestung bekommst du mit /fguns in der Waffenkammer.",player,0,200,0)
		else outputChatBox("Du bist bereits im Dienst!",player)end
	end
end
addEvent("go:sapd_duty2",true)
addEventHandler("go:sapd_duty2",getRootElement(),FBI_Duty_Func)


--//SAPD Duty Icons
SAPDdutyIcon=createPickup(-2446.8195800781,518.64300537109,30.276069641113,3,1275,50,0)--SF
SAPDdutyIconINT=createPickup(986.46917724609,-11.640666007996,248.5625,3,1275,50,0)--SF
setElementInterior(SAPDdutyIconINT,10)


--//SAPD Functions
function FBI_DutyIcon_Func(player)
	if(isFBI(player))then
		-- Statt des Duty-Fensters wird der Dienst hier direkt umgeschaltet.
		-- Ausruestung gibt es getrennt ueber /fguns in der Waffenkammer.
		if isOnDuty(player) then FBI_OffDuty_Func(player) else FBI_Duty_Func(player) end
	else outputChatBox("Du bist kein Staatsfraktionist!",player)end
end
addEventHandler("onPickupHit",SAPDdutyIcon,FBI_DutyIcon_Func)
addEventHandler("onPickupHit",SAPDdutyIconINT,FBI_DutyIcon_Func)

function FBI_OffDuty_Func(player,cmd)
	if isAbleOffduty(player)then
		if not getPedOccupiedVehicle(player)then
			setElementModel(player,MtxGetElementData(player,"skinid") or 0)
			takeAllWeapons(player)
			outputChatBox("Du hast den Dienst als Polizist beendet!",player)
		else outputChatBox("Du darfst in keinem Fahrzeug sitzen!",player)end
	else outputChatBox("Du bist kein Beamter im Dienst!",player)end
end
addEvent("gooff:sapd_duty2",true)
addEventHandler("gooff:sapd_duty2",getRootElement(),FBI_OffDuty_Func)
