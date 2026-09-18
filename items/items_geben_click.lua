--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function showItemGiveList()

	dgsSetInputMode ( "no_binds_when_editing" )
	showCursor ( true )
	if isPlayerClickWindowValid ( "itemsGive" ) then
		dgsSetVisible ( gWindow["itemsGive"], true )
		dgsBringToFront(gWindow["itemsGive"])
	else
		-- y=215: direkt unter dem Interaktionsfenster (y=0, Hoehe 200), sonst
		-- verdeckt dieses Fenster dessen unterste Button-Reihe ("Heiraten").
		-- Feste Pixelmasse statt relativer Werte: die alten relativen Koordinaten
		-- liessen das Anzahl-Feld auf wenige Pixel zusammenschrumpfen und die
		-- Spaltenbreiten (0.55 + 0.25) schnitten grosse Betraege ab.
		gWindow["itemsGive"] = dgsCreateWindow(screenwidth/2-240/2,215,240,330,"Item geben",false)
		dgsBringToFront(gWindow["itemsGive"])
		dgsWindowSetMovable(gWindow["itemsGive"],false)
		dgsWindowSetSizable(gWindow["itemsGive"],false)
		gGrid["itemsGive"] = dgsCreateGridList(8,8,224,170,false,gWindow["itemsGive"])
		dgsGridListSetSelectionMode(gGrid["itemsGive"],0)
		gColumn["itemGiveName"] = dgsGridListAddColumn(gGrid["itemsGive"],"Item",0.58)
		gColumn["itemGiveCount"] = dgsGridListAddColumn(gGrid["itemsGive"],"Anzahl",0.38)

		gLabel["itemGiveInfo"] = dgsCreateLabel(8,186,224,20,"An",false,gWindow["itemsGive"])
		dgsLabelSetColor(gLabel["itemGiveInfo"],200,200,000)
		dgsLabelSetVerticalAlign(gLabel["itemGiveInfo"],"center")
		dgsLabelSetHorizontalAlign(gLabel["itemGiveInfo"],"left",false)
		dgsSetFont(gLabel["itemGiveInfo"],"default-bold")

		gLabel["itemGiveAmountInfo"] = dgsCreateLabel(8,212,68,26,"Anzahl:",false,gWindow["itemsGive"])
		dgsLabelSetColor(gLabel["itemGiveAmountInfo"],200,200,000)
		dgsLabelSetVerticalAlign(gLabel["itemGiveAmountInfo"],"center")
		dgsLabelSetHorizontalAlign(gLabel["itemGiveAmountInfo"],"left",false)
		dgsSetFont(gLabel["itemGiveAmountInfo"],"default-bold")

		gEdit["itemGiveAmount"] = dgsCreateEdit(80,212,152,26,"",false,gWindow["itemsGive"])

		gButton["itemGive"] = dgsCreateButton(8,250,108,36,"Geben",false,gWindow["itemsGive"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["itemGiveClose"] = dgsCreateButton(124,250,108,36,"Schliessen",false,gWindow["itemsGive"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		addEventHandler("onDgsMouseClickUp", gButton["itemGiveClose"],
			function (btn)
				if btn ~= "left" then return end
				hideItemGiveList()
			end,
		false )
		addEventHandler("onDgsMouseClickUp", gButton["itemGive"],
			function ( btn, state )
				if btn ~= "left" then return end
				local rowindex, columnindex = dgsGridListGetSelectedItem ( gGrid["itemsGive"] )
				if not rowindex or rowindex == -1 then
					outputChatBox ( "Waehle zuerst ein Item aus der Liste aus!", 125, 0, 0 )
					return
				end
				local selectedText = dgsGridListGetItemText ( gGrid["itemsGive"], rowindex, gColumn["itemGiveName"] )
				if selectedText == "Sonstiges" then
					-- Reine Ueberschriftzeile, kein vergebbares Item.
					return
				end
				if selectedText == "Geld" then
					local amount = tonumber ( dgsGetText ( gEdit["itemGiveAmount"] ) )
					if not amount or amount <= 0 then
						outputChatBox ( "Bitte eine gueltige Zahl eingeben!", 125, 0, 0 )
						return
					end
					hideItemGiveList()
					triggerServerEvent ( "geldgeben", lp, amount )
				elseif dgsGetVisible ( gWindow["itemsGive"] ) then
					hideItemGiveList()
					local def = itemDefs[selectedText]
					local foodSlot = nil
					for i = 1, 3 do
						if foodName[vioClientGetElementData ( "food"..i )] == selectedText then
							foodSlot = i
							break
						end
					end
					if foodSlot then
						triggerServerEvent ( "giveitem", lp, vioClientGetElementData ( "curclicked" ), "eat", foodSlot )
					elseif def and def.command then
						local amount = tonumber ( dgsGetText ( gEdit["itemGiveAmount"] ) )
						if not amount or amount <= 0 then
							outputChatBox ( "Bitte eine gueltige Zahl eingeben!", 125, 0, 0 )
							return
						end
						triggerServerEvent ( "giveitem", lp, vioClientGetElementData ( "curclicked" ), def.command, nil, amount )
					elseif placeAbleObjects[selectedText] then
						triggerServerEvent ( "giveitem", lp, vioClientGetElementData ( "curclicked" ), "object" )
					else
						outputChatBox ( "Dieses Item kann nicht uebergeben werden!", 125, 0, 0 )
					end
				end
			end,
		false )
	end
	local name = vioClientGetElementData ( "curclicked" )
	if type ( name ) == "string" and name ~= "" and isElement ( getPlayerFromName ( name ) ) then
		dgsSetText ( gLabel["itemGiveInfo"], "An: "..name )
		local grid = gGrid["itemsGive"]
		local columnName = gColumn["itemGiveName"]
		local columnCount = gColumn["itemGiveCount"]
		fillWithItems ( grid, columnName, columnCount )
		local row = dgsGridListAddRow ( grid )
		dgsGridListSetItemText ( grid, row, columnName, "Sonstiges", true, false )
		local row = dgsGridListAddRow ( grid )
		dgsGridListSetItemText ( grid, row, columnName, "Geld", false, false )
		dgsGridListSetItemText ( grid, row, columnCount, mymoney..""..Tables.waehrung.."", false, false )
	else
		hideItemGiveList()
		outputChatBox ( "Der Spieler ist offline!", 125, 0, 0 )
	end
end

function hideItemGiveList()

	-- Nur dieses Fenster schliessen, nicht die komplette Klick-GUI: sonst
	-- verschwindet nach jeder Item-Uebergabe auch das Interaktionsmenue
	-- samt Cursor. Zum kompletten Schliessen gibt es dort "Schliessen".
	if isPlayerClickWindowValid ( "itemsGive" ) then
		dgsSetVisible ( gWindow["itemsGive"], false )
	end
end
