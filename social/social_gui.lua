--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function showSocialRankWindow ()

	if gWindow["socialRankSelection"] then
		dgsSetVisible ( gWindow["socialRankSelection"], true )
	else
		gWindow["socialRankSelection"] = dgsCreateWindow (screenwidth/2-402/2,120,402,220, "Social menue",false)
		dgsWindowSetCloseButtonEnabled(gWindow["socialRankSelection"], false)
		dgsSetAlpha(gWindow["socialRankSelection"],1)
		dgsWindowSetMovable ( gWindow["socialRankSelection"], false )
		dgsWindowSetSizable ( gWindow["socialRankSelection"], false )
		gGrid["socialRank"] = dgsCreateGridList(10,10,159,181,false,gWindow["socialRankSelection"])
		dgsGridListSetSelectionMode(gGrid["socialRank"],0)
		dgsSetAlpha(gGrid["socialRank"],1)
		
		gColumn["socialRank"] = dgsGridListAddColumn(gGrid["socialRank"],"Sozialer Status",0.55)
		gColumn["socialAvailable"] = dgsGridListAddColumn(gGrid["socialRank"],"",0.25)
				
		gLabel["socialRankInfo"] = dgsCreateLabel(175,10,227,112,"In diesem Menü kannst du deine frei-\ngeschalteten sozialen Staten akti-\nvieren, damit dieser in der Spielerliste\nsichtbar wird.\nAußerdem wird dir angezeigt, welchen\nStatus du als nächstes erreichen\nkannst bzw. was dafür nötig ist,\nden jeweiligen Status zu erreichen.",false,gWindow["socialRankSelection"])
		dgsSetAlpha(gLabel["socialRankInfo"],1)
		dgsLabelSetColor(gLabel["socialRankInfo"],200,200,000)
		dgsLabelSetVerticalAlign(gLabel["socialRankInfo"],"top")
		dgsLabelSetHorizontalAlign(gLabel["socialRankInfo"],"left",false)
		dgsSetFont(gLabel["socialRankInfo"],"default-bold")
		gLabel["socialRankReqs"] = dgsCreateLabel(183,138,59,15,"Benötigt:",false,gWindow["socialRankSelection"])
		dgsSetAlpha(gLabel["socialRankReqs"],1)
		dgsLabelSetColor(gLabel["socialRankReqs"],63,160,224)
		dgsLabelSetVerticalAlign(gLabel["socialRankReqs"],"top")
		dgsLabelSetHorizontalAlign(gLabel["socialRankReqs"],"left",false)
		dgsSetFont(gLabel["socialRankReqs"],"default-bold")
		gLabel["socialRankRequirements"] = dgsCreateLabel(265,138,116,72,"",false,gWindow["socialRankSelection"])
		dgsSetAlpha(gLabel["socialRankRequirements"],1)
		dgsLabelSetColor(gLabel["socialRankRequirements"],000,120,000)
		dgsLabelSetVerticalAlign(gLabel["socialRankRequirements"],"top")
		dgsLabelSetHorizontalAlign(gLabel["socialRankRequirements"],"left",false)
		dgsSetFont(gLabel["socialRankRequirements"],"default-bold")
		
		gButton["socialRankSelect"] = dgsCreateButton(176,162,70,30,"Verwenden",false,gWindow["socialRankSelection"],_,_,_,_,_,_,tocolor(100,181,246,255),tocolor(150,205,250,255),tocolor(66,140,205,255),true)
		dgsSetAlpha(gButton["socialRankSelect"],1)
		
		addEventHandler("onDgsMouseClickUp", gButton["socialRankSelect"], 
			function ( button )
			if button == "left" then
				local rowindex = dgsGridListGetSelectedItem ( gGrid["socialRank"] )
				if rowindex == -1 then return end
				local selectedText = dgsGridListGetItemText ( gGrid["socialRank"], rowindex, gColumn["socialRank"] )
				local selectedTextAvailable = dgsGridListGetItemText ( gGrid["socialRank"], rowindex, gColumn["socialAvailable"] )
					if selectedText and selectedTextAvailable == "[x]" then
						triggerServerEvent ( "socialStateNewChange", localPlayer, selectedText )
						outputChatBox ( "Dein neuen sozialer Status ist nun: "..selectedText.."!", 0, 125, 0 )
					else
						outputChatBox ( "Du hast diesen Status noch nicht frei geschaltet!", 125, 0, 0 )
					end
			   end
		end, false)
		
		addEventHandler ( "onDgsMouseClickUp", gGrid["socialRank"],
			function (button)
			if button == "left" then
				local rowindex = dgsGridListGetSelectedItem ( gGrid["socialRank"] )
				if rowindex == -1 then return end
				local selectedText = dgsGridListGetItemText ( gGrid["socialRank"], rowindex, gColumn["socialRank"] )
					if selectedText then
						dgsSetText ( gLabel["socialRankRequirements"], socialNeeds[selectedText] )
					end
				end
			end,
		false)
	end
	fillSocialList ( gGrid["socialRank"], gColumn["socialRank"], gColumn["socialAvailable"] )
end

function fillSocialList ( grid, rank, available )
	dgsGridListClear ( grid )
	for i = 1, socialStateCount do
		if availableSocialStates[i] then
			local row = dgsGridListAddRow ( grid )
			dgsGridListSetItemText ( grid, row, rank, socialStates[i], false, false )
			dgsGridListSetItemText ( grid, row, available, "[x]", false, false )
		elseif reachableSocialStates[i] then
			local row = dgsGridListAddRow ( grid )
			dgsGridListSetItemText ( grid, row, rank, socialStates[i], false, false )
			dgsGridListSetItemText ( grid, row, available, "[_]", false, false )
		end
	end
end