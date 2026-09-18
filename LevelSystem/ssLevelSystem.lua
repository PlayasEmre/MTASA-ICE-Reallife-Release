function levelshop(player)
	if MtxGetElementData(player, "level") >= 5 and MtxGetElementData(player, "levelshop1") == 0 then
		MtxSetElementData(player, "money", MtxGetElementData(player, "money") + 30000)
		outputChatBox("Du hast 30.000€ erhalten für das erreichen von Level 5!",player,255,255,0)
		MtxSetElementData(player,"levelshop1",1)
		datasave_remote(player)
	else
		outputChatBox("Du hast bereits deine Belohnung schon erhalten",player,255,255,255)
	end
end
addEvent("levelshop", true)
addEventHandler("levelshop",root,levelshop)

function levelshop2(player)
	if MtxGetElementData(player, "level") >= 10 and MtxGetElementData(player, "levelshop2") == 0 then
		setPremiumData(player,30,3)
		outputChatBox("Du hast Premuim Gold Für 1 Monat erhalten für das erreichen von Level 10!",player,255,255,255)
		MtxSetElementData(player,"levelshop2",1)
		datasave_remote(player)
	else
		outputChatBox("Du hast bereits deine Belohnung schon erhalten",player,255,255,255)
	end
end
addEvent("levelshop2", true)
addEventHandler("levelshop2",root,levelshop2)

function levelshop3(player)
	if MtxGetElementData(player, "level") >= 20 and MtxGetElementData(player, "levelshop3") == 0 then
		outputChatBox("Du hast 250 Coins erhalten für das erreichen von Level 20!",player,255,255,255)
		MtxSetElementData(player, "coins", MtxGetElementData(player, "coins") + 250)
		MtxSetElementData(player,"levelshop3",1)
		datasave_remote(player)
	else
		outputChatBox("Du hast bereits deine Belohnung schon erhalten",player,255,255,255)
	end
end
addEvent("levelshop3", true)
addEventHandler("levelshop3",root,levelshop3)

function levelshop4(player)
	if MtxGetElementData(player, "level") >= 30 and MtxGetElementData(player, "levelshop4") == 0 then
		MtxSetElementData(player, "money", MtxGetElementData(player, "money") + 100000)
		MtxSetElementData(player, "coins", MtxGetElementData(player, "coins") + 500)
		outputChatBox("Du hast 100.000€ und 500 Coins erhalten für das Erreichen von Level 30!",player,255,255,255)
		MtxSetElementData(player,"levelshop4",1)
		datasave_remote(player)
    else
		outputChatBox("Du hast bereits deine Belohnung schon erhalten",player,255,255,255)
	end
end
addEvent("levelshop4", true)
addEventHandler("levelshop4",root,levelshop4)