--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function SAPD_Duty_Func3(player,cmd)
	if getElementData(player,"fraktion")==1 then
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
addEvent("go:sapd_duty3",true)
addEventHandler("go:sapd_duty3",getRootElement(),SAPD_Duty_Func3)


--//SAPD Duty Icons
SAPDdutyIcon=createPickup(254.74592590332,65.768547058105,1003.640625,3,1275,50,0)--lspd
SAPDdutyIconINT=createPickup(254.74592590332,65.768547058105,1003.640625,3,1275,50,0)--lspd
setElementInterior(SAPDdutyIconINT,6)


--//SAPD Functions
function SAPD_DutyIcon_Func3(player)
	if getElementData(player,"fraktion")==1 then
		-- Statt des Duty-Fensters wird der Dienst hier direkt umgeschaltet.
		-- Ausruestung gibt es getrennt ueber /fguns in der Waffenkammer.
		if isOnDuty(player) then SAPD_OffDuty_Func3(player) else SAPD_Duty_Func3(player) end
	else outputChatBox("Du bist kein Staatsfraktionist!",player)end
end
addEventHandler("onPickupHit",SAPDdutyIcon,SAPD_DutyIcon_Func3)
addEventHandler("onPickupHit",SAPDdutyIconINT,SAPD_DutyIcon_Func3)

function SAPD_OffDuty_Func3(player,cmd)
	if isAbleOffduty(player)then
		if not getPedOccupiedVehicle(player)then
			setElementModel(player,MtxGetElementData(player,"skinid") or 0)
			takeAllWeapons(player)
			outputChatBox("Du hast den Dienst als Polizist beendet!",player)
		else outputChatBox("Du darfst in keinem Fahrzeug sitzen!",player)end
	else outputChatBox("Du bist kein Beamter im Dienst!",player)end
end
addEvent("gooff:sapd_duty3",true)
addEventHandler("gooff:sapd_duty3",getRootElement(),SAPD_OffDuty_Func3)
