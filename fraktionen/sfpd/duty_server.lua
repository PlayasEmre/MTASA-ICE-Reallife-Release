--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function SAPD_Duty_Func(player,cmd)
	if isCop (player)then
		if not isOnDuty(player)then
			if MtxGetElementData(player,"rang")==5 then
			    setElementModel ( player, 265 )
			elseif MtxGetElementData(player,"rang")==4 then
			    setElementModel ( player, 267 )
			elseif MtxGetElementData(player,"rang")==3 then
			    setElementModel ( player, 281 )
			elseif MtxGetElementData(player,"rang")==2 then
			    setElementModel ( player, 280 )
			elseif MtxGetElementData(player,"rang")==1 then
			    setElementModel ( player, 283 )
			elseif MtxGetElementData(player,"rang")==0 then
			    setElementModel ( player, 284 )
			end
			
			setPedArmor(player,100)
			setElementHunger(player,100)
			setElementHealth(player,100)
			outputChatBox("Du hast den Dienst als Polizist angetreten!",player)
			outputChatBox("Ausruestung bekommst du mit /fguns in der Waffenkammer.",player,0,200,0)
		else outputChatBox("Du bist bereits im Dienst!",player)end
	end
end
addEvent("go:sapd_duty",true)
addEventHandler("go:sapd_duty",getRootElement(),SAPD_Duty_Func)

--//SAPD Duty Icons
SAPDdutyIcon=createPickup(-1611.5,679.3,-5.3,3,1275,50,0)--SF
SAPDdutyIconINT=createPickup(259.6,110.6,1003,3,1275,50,0)--SF
setElementInterior(SAPDdutyIconINT,10)

--//Einknast Icons
SAPDeinknastenIcon=createPickup(-1589.9,716.3,-5.2,3,2680,50,0)--SF

--//SAPD Functions
function SAPD_DutyIcon_Func(player)
	if(isCop(player))then
		-- Statt des Duty-Fensters wird der Dienst hier direkt umgeschaltet.
		-- Ausruestung gibt es getrennt ueber /fguns in der Waffenkammer.
		if isOnDuty(player) then SAPD_OffDuty_Func(player) else SAPD_Duty_Func(player) end
	else outputChatBox("Du bist kein Staatsfraktionist!",player)end
end
addEventHandler("onPickupHit",SAPDdutyIcon,SAPD_DutyIcon_Func)
addEventHandler("onPickupHit",SAPDdutyIconINT,SAPD_DutyIcon_Func)

function SAPD_OffDuty_Func(player,cmd)
	if isAbleOffduty(player)then
		if not getPedOccupiedVehicle(player)then
			setElementModel(player,MtxGetElementData(player,"skinid") or 0)
			takeAllWeapons(player)
			outputChatBox("Du hast den Dienst als Polizist beendet!",player)
		else outputChatBox("Du darfst in keinem Fahrzeug sitzen!",player)end
	else outputChatBox("Du bist kein Beamter im Dienst!",player)end
end
addEvent("gooff:sapd_duty",true)
addEventHandler("gooff:sapd_duty",getRootElement(),SAPD_OffDuty_Func)
