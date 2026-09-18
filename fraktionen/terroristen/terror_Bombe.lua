--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Bombe --
local Bombe_R
local Bombe_O 
local Bombe_P 
local Bombe_T
local Bombe_T2
local Bombe_S = false

addCommandHandler('bombe', function(psource)
if isTerror(psource) then
	if (Bombe_S == false) then
		if(isPedOnGround(psource) and not isElementInWater(psource) and not isPedInVehicle(psource))then
			local x, y, z = getElementPosition(psource)
			_G["Bombe_O"] = createObject(1654, x-.5, y, z-.85, -90, 0, 0, true)

			outputChatBox("-- Es wurde eine Bombe gelegt !", getRootElement(), 120, 0, 0)
			outputChatBox("Deine Bombe wurde erfolgreich gelegt, beschütze sie 10 Minuten lang.", psource, 80, 80, 0)
			setElementFrozen(psource, true)
			setPedAnimation(psource, 'BOMBER', 'BOM_Plant', -1, false)
				setTimer(function() setElementFrozen(psource, false) setPedAnimation(psource) end, 3000, 1)
			
			Bombe_R = createRadarArea(x-55, y-55, 105, 105, 150, 0, 0, 200, getRootElement())
				setRadarAreaFlashing(Bombe_R, true)
			
			Bombe_S = true
			Bombe_P = psource
			
			Bombe_T = setTimer(function()
				xB, yB, zB = getElementPosition(_G["Bombe_O"])
				createExplosion(xB, yB, zB+1, 10)
				destroyElement(_G["Bombe_O"])
				destroyElement(Bombe_R)
				Bombe_CD = setTimer(function() Bombe_S = false end, 30*60*1000, 1)
				if isElement(Bombe_P) then
					MtxSetElementData ( psource, "money", MtxGetElementData ( psource, "money" ) + 20000 )
					outputChatBox("Die Bombe ist erfolgreich hochgegangen! Du erhälst 20.000€.", psource, 0, 120, 0)
				end
			end, 10*60*1000, 1)
		end
		else
			outputChatBox('Entweder gibt es bereits eine aktive Bombe oder du musst noch warten!', psource, 120,0,0)
		end
	end
end)

addCommandHandler("delbomb", function(pl)
if isOnDuty(pl) or isFBI(pl) or isArmy(pl) then	
	local x, y, z = getElementPosition(pl)
	if(Bombe_S == true and not isTimer(Bombe_T2))then
		if not isPedInVehicle(pl) then
		local xB, yB, zB = getElementPosition(_G["Bombe_O"])
			if(getDistanceBetweenPoints3D(xB, yB, zB, x, y, z) < 5)then 
				setElementFrozen(pl, true)
				setPedAnimation(pl, "BOMBER", "BOM_Plant_Loop", 60000)
				outputChatBox("Die Bombe wird entschärft, dieser Vorgang dauert 60 Sekunden...", pl, 80, 80, 0)
				setElementData(pl, 'defusePlayer', true)
				Bombe_T2 = setTimer(bombDefuse_Like, 60000, 1, pl)
				addEventHandler('onPlayerWasted', pl, function()
					if(getElementData(source, 'defusePlayer') == true)then
						if isTimer(Bombe_T2) then
							killTimer(Bombe_T2)
						end
						setElementFrozen(source, false)
						outputChatBox("Du hast es nicht geschafft die Bombe zu entschärfen!", source, 120, 0, 0)
						setElementData(source, 'defusePlayer', false)
					end
				end)
			end
		end
	end
  end
end)

function bombDefuse_Like(player)
	if(isTimer(Bombe_T))then
		killTimer(Bombe_T)
	end
	destroyElement(_G["Bombe_O"])
	destroyElement(Bombe_R)
	outputChatBox("Die Bombe wurde erfolgreich entschärft !", getRootElement(), 0, 120,0)
	outputChatBox("Du hast die Bombe erfolgreich entschärft, du erhälst 20.000€.", player)
	MtxSetElementData ( player, "money", MtxGetElementData ( player, "money" ) + 20000 )
	Bombe_CD = setTimer(function() Bombe_S = false end, 3600000, 1)
	setElementFrozen(player, false)
	setPedAnimation(player, false)
	setElementData(player, 'defusePlayer', false)
end


addCommandHandler("resetbombe",function(player)
	if ( tonumber ( MtxGetElementData(player,"adminlvl") ) or 0 ) >= 3 then
			if(isTimer(Bombe_T))then
				killTimer(Bombe_T)
			end
			if(isTimer(Bombe_S))then
				killTimer(Bombe_S)
			end	
	        Bombe_S = false
			if isElement(_G["Bombe_O"]) and isElement(Bombe_R) then
				destroyElement(_G["Bombe_O"])
				destroyElement(Bombe_R)
			end
			outputChatBox("Der Bomben-Timer wurde von einem Teammitglied zurückgesetzt!",root,200,0,0)
			outputLog(getPlayerName(player).." hat den Bomben-Timer zurückgesetzt!","Adminsystem")
	  else
		  infobox(player,"Der Bomben-Timer ist\nnicht aktiv!",4000,255,0,0)	
	  end
end)