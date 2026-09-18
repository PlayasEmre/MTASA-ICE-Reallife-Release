--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //


function grantIntroTaskReward ( targetPlayer, typ )
	if MtxGetElementData ( targetPlayer, "loggedin" ) == 1 then
		if(tonumber(MtxGetElementData(targetPlayer,"Introtask"))==1)then
			if(typ=="give:Roller")then
				MtxSetElementData(targetPlayer,"Introtask",2)
				MtxSetElementData(targetPlayer,"money",tonumber(MtxGetElementData(targetPlayer,"money")) + 1500)
				outputChatBox("Herzlichen Glückwunsch, Sie haben eine Aufgabe erledigt! Du erhältst €1500",targetPlayer,255,255,255)
			end
		elseif(tonumber(MtxGetElementData(targetPlayer,"Introtask"))==2)then
			if(typ=="give:rathaus")then
			    MtxSetElementData(targetPlayer,"Introtask",3)
				MtxSetElementData(targetPlayer,"money",tonumber(MtxGetElementData(targetPlayer,"money")) + 2500)
				outputChatBox("Herzlichen Glückwunsch, Sie haben eine Aufgabe erledigt! Du erhältst €2500",targetPlayer,255,255,255)
			end
		elseif(tonumber(MtxGetElementData(targetPlayer,"Introtask"))==3)then
			if(typ=="give:helpmenue")then
				MtxSetElementData(targetPlayer,"Introtask",4)
				MtxSetElementData(targetPlayer,"money",tonumber(MtxGetElementData(targetPlayer,"money")) + 2000)
				outputChatBox("Herzlichen Glückwunsch, Sie haben eine Aufgabe erledigt! Du erhältst €2000",targetPlayer,255,255,255)
			end
		elseif(tonumber(MtxGetElementData(targetPlayer,"Introtask"))==4)then
			if(typ=="give:führerschein")then
				MtxSetElementData(targetPlayer,"Introtask",5)
				MtxSetElementData(targetPlayer,"money",tonumber(MtxGetElementData(targetPlayer,"money")) + 4000)
				outputChatBox("Herzlichen Glückwunsch, Sie haben eine Aufgabe erledigt! Du erhältst €4000",targetPlayer,255,255,255)
			end
		 elseif(tonumber(MtxGetElementData(targetPlayer,"Introtask"))== 5)then
			if(typ=="give:lkwschein")then
				MtxSetElementData(targetPlayer,"Introtask",6)
				MtxSetElementData(targetPlayer,"money",tonumber(MtxGetElementData(targetPlayer,"money")) + 4500)
				outputChatBox("Herzlichen Glückwunsch, Sie haben eine Aufgabe erledigt! Du erhältst €4500",targetPlayer,255,255,255)
			end
		 elseif(tonumber(MtxGetElementData(targetPlayer,"Introtask"))==6)then
			if(typ=="give:Bus")then
				MtxSetElementData(targetPlayer,"Introtask",7)
				MtxSetElementData(targetPlayer,"money",tonumber(MtxGetElementData(targetPlayer,"money")) + 4000)
				outputChatBox("Herzlichen Glückwunsch, Sie haben eine Aufgabe erledigt! Du erhältst €4000",targetPlayer,255,255,255)
				datasave_remote(targetPlayer)
			end
		end
	end
end

addEvent("set:task",true)
addEventHandler("set:task",root,function(targetPlayer,typ)
	if targetPlayer ~= client then return end
	grantIntroTaskReward ( targetPlayer, typ )
end)