--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

loadstring(exports.DGS:dgsImportFunction())()

gButton = {}

function fillSkinlist ()

	dgsGridListClear ( SkinauswahlGrid )
	for i = 0, 288 do
		if skinname[i] ~= false and skinname[i] ~= nil then
			if skinsex[i] == sex then
				if price == "cheap" then
					if tonumber(skinpreis[i]) < 300 then
						local row = dgsGridListAddRow ( SkinauswahlGrid )
						dgsGridListSetItemText ( SkinauswahlGrid, row, skinnameColumn, tostring ( skinname[i] ), false, false )
						dgsGridListSetItemText ( SkinauswahlGrid, row, skinpreisColumn, tostring ( skinpreis[i].." "..Tables.waehrung.."" ), true, false )
					end
				elseif tonumber(skinpreis[i]) >= 300 then
					local row = dgsGridListAddRow ( SkinauswahlGrid )
					dgsGridListSetItemText ( SkinauswahlGrid, row, skinnameColumn, tostring ( skinname[i] ), false, false )
					dgsGridListSetItemText ( SkinauswahlGrid, row, skinpreisColumn, tostring ( skinpreis[i].." "..Tables.waehrung.."" ), true, false )
				end
			end
		end
	end
end

function skinshow ( rowindex )

	if not rowindex or rowindex == -1 then return end
	local selectedText = dgsGridListGetItemText ( SkinauswahlGrid, rowindex, skinnameColumn )
	local selectedPrice = dgsGridListGetItemText ( SkinauswahlGrid, rowindex, skinpreisColumn )
	if selectedText == false or selectedPrice == false then
	else
		for i = 0, 288 do
			if skinname[i] == selectedText then
				if tostring ( skinpreis[i].." "..Tables.waehrung.."" ) == selectedPrice then
					setElementModel ( lp, i )
					curskinPrice = skinpreis[i]
					curskinID = i
				end
			end
		end
	end
end

function sucessfullBuyed_func ()

	dgsSetVisible ( SkinauswahlWindow, false )
	showCursor(false)
	guiSetInputMode("allow_binds")
	triggerServerEvent ( "cancel_gui_server", lp )
	setElementModel ( lp, vioClientGetElementData ( "skinid" ) )
	setElementPosition ( lp, 161.66276550293, -93.030876159668, 1001.453918457 )
	setCameraTarget ( lp )
end
addEvent ( "sucessfullBuyed", true )
addEventHandler ( "sucessfullBuyed", getRootElement(), sucessfullBuyed_func )

function _createSkinauswahlGui_func ()

	setPedRotation ( lp, 90 )
	guiSetInputMode ( "no_binds_when_editing" )
	showCursor ( true )
	setElementClicked ( true )
	if SkinauswahlWindow then
		dgsSetVisible ( SkinauswahlWindow, true )
	else
		sex = "male"
		price = "cheap"

		local screenwidth, screenheight = guiGetScreenSize ()

		SkinauswahlWindow = dgsCreateWindow(90,screenheight/2-440/2,384,440,"Skinauswahl",false, nil,nil,nil,nil,nil, tocolor(16,29,61,255), nil, true)
		dgsSetProperty(SkinauswahlWindow, "image", false)
		dgsWindowSetMovable(SkinauswahlWindow, false)
		dgsWindowSetSizable(SkinauswahlWindow, false)
		dgsBringToFront(SkinauswahlWindow)

		SkinauswahlGrid = dgsCreateGridList(0.0339,0.04,0.625,0.87,true,SkinauswahlWindow)
		dgsGridListSetSelectionMode(SkinauswahlGrid,1)
		skinnameColumn = dgsGridListAddColumn(SkinauswahlGrid,"Skin",0.6)
		skinpreisColumn = dgsGridListAddColumn(SkinauswahlGrid,"Preis",0.2)

		addEventHandler ( "onDgsMouseClickUp", SkinauswahlGrid, function ( btn, state, x, y )
			if btn ~= "left" then return end
			local gx, gy = dgsGetPosition ( SkinauswahlGrid, false, true )
			local columnHeight = dgsGetProperty ( SkinauswahlGrid, "columnHeight" ) or 0
			local rowHeight = dgsGetProperty ( SkinauswahlGrid, "rowHeight" ) or 0
			local leading = dgsGetProperty ( SkinauswahlGrid, "leading" ) or 0
			local rowMoveOffset = dgsGetProperty ( SkinauswahlGrid, "rowMoveOffset" ) or 0
			local rowHeightLeading = rowHeight + leading
			if rowHeightLeading <= 0 then return end
			local relY = y - gy - columnHeight - rowMoveOffset
			if relY < 0 then return end
			local row = math.floor ( relY / rowHeightLeading ) + 1
			local rowCount = dgsGridListGetRowCount ( SkinauswahlGrid )
			if row < 1 or row > rowCount then return end
			dgsGridListSetSelectedItem ( SkinauswahlGrid, row, skinnameColumn )
			skinshow ( row )
		end, false )

		gButton["clothesMaennerskins"] = dgsCreateButton(0.7,0.03,0.2656,0.0977,"Maennerskins",true,SkinauswahlWindow, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["clothesFrauenskins"] = dgsCreateButton(0.7,0.1905,0.2656,0.0977,"Frauenskins",true,SkinauswahlWindow, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["clothesGuenstig"] = dgsCreateButton(0.7,0.351,0.2656,0.0977,"Guenstig",true,SkinauswahlWindow, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["clothesTeuer"] = dgsCreateButton(0.7,0.5115,0.2656,0.0977,"Teuer",true,SkinauswahlWindow, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["clothesKaufen"] = dgsCreateButton(0.7,0.672,0.2656,0.0977,"Kaufen",true,SkinauswahlWindow, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["clothesCancel"] = dgsCreateButton(0.7,0.8325,0.2656,0.0977,"Abbrechen",true,SkinauswahlWindow, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		addEventHandler("onDgsMouseClickUp", gButton["clothesCancel"],
			function ( btn )
				if btn ~= "left" then return end
				dgsSetVisible ( SkinauswahlWindow, false )
				showCursor(false)
				guiSetInputMode("allow_binds")
				triggerServerEvent ( "cancel_gui_server", lp )
				triggerServerEvent ( "clothesCancel", lp )
				setElementModel ( lp, vioClientGetElementData ( "skinid" ) )
				setElementPosition ( lp, 161.66276550293, -93.030876159668, 1001.453918457 )
				setCameraTarget ( lp )
			end
		)

		addEventHandler("onDgsMouseClickUp", gButton["clothesKaufen"],
			function ( btn )
				if btn ~= "left" then return end
				triggerServerEvent ( "clothesBuyServer", lp, lp, curskinID, curskinPrice )
			end
		)

		addEventHandler("onDgsMouseClickUp", gButton["clothesFrauenskins"],
			function ( btn )
				if btn ~= "left" then return end
				sex = "female"
				fillSkinlist ()
			end
		)
		addEventHandler("onDgsMouseClickUp", gButton["clothesMaennerskins"],
			function ( btn )
				if btn ~= "left" then return end
				sex = "male"
				fillSkinlist ()
			end
		)
		addEventHandler("onDgsMouseClickUp", gButton["clothesTeuer"],
			function ( btn )
				if btn ~= "left" then return end
				price = "expensive"
				fillSkinlist ()
			end
		)
		addEventHandler("onDgsMouseClickUp", gButton["clothesGuenstig"],
			function ( btn )
				if btn ~= "left" then return end
				price = "cheap"
				fillSkinlist ()
			end
		)

		fillSkinlist ()
	end
end
addEvent ( "_createSkinauswahlGui", true )
addEventHandler ( "_createSkinauswahlGui", lp, _createSkinauswahlGui_func )