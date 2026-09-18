--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function isWantedcomputerAllowed(player)
	return (isCop(player) or isFBI(player)) and isOnDuty(player)
end

addEvent("giveWanteds",true)
addEventHandler("giveWanteds",root,function(player,reason,wanted)
	if not isWantedcomputerAllowed(client) then return end
	player = getPlayerFromName(player)
	wanted = tonumber(wanted)
	if not wanted then return end

	if(isElement(player))then
		if(wanted<=2)then
			begriff = "Wanted"
		else
			begriff = "Wanteds"
		end
	
		MtxSetElementData(player,"wanteds",tonumber(MtxGetElementData(player,"wanteds"))+wanted)
		
		if(tonumber(MtxGetElementData(player,"wanteds"))>=6)then
			MtxSetElementData(player,"wanteds",6)
		end
		
		outputChatBox("#0040FF[INFO] #FFFFFF"..getPlayerName(client).." hat dir "..wanted.." "..begriff.." gegeben! Grund: "..reason,player,255,255,255,true)
		outputChatBox("#0040FF[INFO] #FFFFFFDu hast "..getPlayerName(player).." "..wanted.." "..begriff.." gegeben! Grund: "..reason,client,255,255,255,true)
		infobox(client,"Du hast dem Spieler Wanteds gegeben.",7500,0,255,0)
	else infobox(client,"Der Spieler konnte nicht gefunden werden!",7500,255,0,0)end
end)

addEvent("deleteWanteds",true)
addEventHandler("deleteWanteds",root,function(player)
	if not isWantedcomputerAllowed(client) then return end
	player = getPlayerFromName(player)

	if(isElement(player))then
		MtxSetElementData(player,"wanteds",0)
		infobox(player,getPlayerName(client).." hat dir deine Wanteds gelöscht!",7500,0,255,0)
		infobox(client,"Du hast "..getPlayerName(player).." seine Wanteds gelöscht!",7500,0,255,0)
	else infobox(client,"Der Spieler konnte nicht gefunden werden!",7500,255,0,0)end
end)



addEvent("giveStvoS",true)
addEventHandler("giveStvoS",root,function(player,reason,stvo)
	if not isWantedcomputerAllowed(client) then return end
	player = getPlayerFromName(player)
	stvo = tonumber(stvo)
	if not stvo then return end

	if(isElement(player))then
		if(stvo<=2)then
			begriff = "StVO"
		else
			begriff = "StVOs"
		end
	
		MtxSetElementData(player,"stvo_punkte",tonumber(MtxGetElementData(player,"stvo_punkte"))+stvo)
		
		if(tonumber(MtxGetElementData(player,"stvo_punkte"))>=15)then
			MtxSetElementData(player,"stvo_punkte",15)
		end
		
		outputChatBox(""..getPlayerName(client).." hat dir "..stvo.." "..begriff.." gegeben! Grund: "..reason,player,255,255,255)
		outputChatBox("Du hast "..getPlayerName(player).." "..stvo.." "..begriff.." gegeben! Grund: "..reason,client,255,255,255)
		infobox(client,"Du hast dem Spieler StVO's gegeben.",7500,0,255,0)
	else infobox(client,"Der Spieler konnte nicht gefunden werden!",7500,255,0,0)end
end)

addEvent("deleteStvoS",true)
addEventHandler("deleteStvoS",root,function(player)
	if not isWantedcomputerAllowed(client) then return end
	player = getPlayerFromName(player)

	if(isElement(player))then
		MtxSetElementData(player,"stvo_punkte",0)
		infobox(player,getPlayerName(client).." hat dir deine StVO's gelöscht!",7500,0,255,0)
		infobox(client,"Du hast "..getPlayerName(player).." seine StVO's gelöscht!",7500,0,255,0)
	else infobox(client,"Der Spieler konnte nicht gefunden werden!",7500,255,0,0)end
end)

addEvent("wantedpc.orten",true)
addEventHandler("wantedpc.orten",root,function(player)
	if not isWantedcomputerAllowed(client) then return end
	local player = getPlayerFromName(player)
	if(isElement(player)and MtxGetElementData ( player, "loggedin", 1 ))then
		if(getElementInterior(player) == 0)then
			if not(MtxGetElementData(player,"handystate") == "off")then
				local x,y,z = getElementPosition(player)
				
				infobox(client,"Die letzte Position des Spielers wird dir nun angezeigt!",7500,0,255,0)
				triggerClientEvent(client,"selfmadeWantedcomputer.create",client,x,y,z)
			else infobox(client,"Das Handy des Spielers ist ausgeschaltet!",7500,255,0,0)end
		else infobox(client,"Der Spieler kann zurzeit nicht geortet werden!",7500,255,0,0)end
	else infobox(client,"Der Spieler konnte nicht gefunden werden oder ist nicht eingeloggt!",7500,255,0,0)end
end)