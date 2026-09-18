--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local dgsOk, dgsErr = pcall(function()
	loadstring(exports.DGS:dgsImportFunction())()
end)

itemShopItems = {
 ["Bier"]=beer_price,
 ["Blumen"]=flowers_price,
 ["Kamera"]=cam_price,
 ["Kamera Film"]=camammo_price,
 ["Nachtsichtgeraet"]=nvgoogles_price,
 ["Infrarotsichtgeraet"]=tgoogles_price,
 ["Wuerfel"]=wuerfel_price,
 ["Rubbellos"]=rubbellos_price,
 ["Zigaretten"]=zigarett_price
 }

itemShopIDs = {
 ["Bier"]="beer",
 ["Blumen"]="flowers",
 ["Kamera"]="cam",
 ["Kamera Film"]="camammo",
 ["Nachtsichtgeraet"]="nv",
 ["Infrarotsichtgeraet"]="t",
 ["Wuerfel"]="dice",
 ["Rubbellos"]="los",
 ["Zigaretten"]="cig",
 ["50 $ Guthaben"]="sim-50",
 ["100 $ Guthaben"]="sim-100",
 ["250 $ Guthaben"]="sim-250"
 }

function create24_7Shop_func ()

	showCursor ( true )
	guiSetInputMode ( "no_binds_when_editing" )
	if gWindow["24-7"] then
		dgsSetVisible ( gWindow["24-7"], true )
		dgsBringToFront ( gWindow["24-7"] )
	else
		gWindow["24-7"] = dgsCreateWindow(screenwidth/2-316/2,screenheight/2-306/2,316,306,"24-7 Laden",false, nil, nil, nil, nil, nil, nil, nil, true)
		dgsBringToFront ( gWindow["24-7"] )
		dgsWindowSetMovable ( gWindow["24-7"], false )
		dgsWindowSetSizable  ( gWindow["24-7"], false )
		gImage[1] = dgsCreateImage(9,31,138,58,":"..getResourceName(getThisResource()).."/images/gui/24-7.png",false,gWindow["24-7"])
		gLabel[1] = dgsCreateLabel(151,23,139,69,"Herzlich willkommen im\n24-7 Laden!\n\nHier bekommst du alles,\nwas du brauchst.",false,gWindow["24-7"])
		dgsLabelSetColor(gLabel[1],200,200,0)
		dgsLabelSetVerticalAlign(gLabel[1],"top")
		dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
		dgsSetFont(gLabel[1],"default-bold")

		gGrid["24-7Items"] = dgsCreateGridList(11,108,216,185,false,gWindow["24-7"])
		dgsGridListSetSelectionMode(gGrid["24-7Items"],0)
		gColumn["24-7Names"] = dgsGridListAddColumn(gGrid["24-7Items"],"Artikel",0.6)
		gColumn["24-7Prices"] = dgsGridListAddColumn(gGrid["24-7Items"],"Preis",0.2)

		local row
		for key, index in pairs ( itemShopItems ) do
			row = dgsGridListAddRow ( gGrid["24-7Items"] )
			dgsGridListSetItemText ( gGrid["24-7Items"], row, gColumn["24-7Names"], key, false, false )
			dgsGridListSetItemText ( gGrid["24-7Items"], row, gColumn["24-7Prices"], tostring ( index ).." $", false, false )
		end
		row = dgsGridListAddRow ( gGrid["24-7Items"] )

		row = dgsGridListAddRow ( gGrid["24-7Items"] )
		dgsGridListSetItemText ( gGrid["24-7Items"], row, gColumn["24-7Names"], "Handy", true, false )



		row = dgsGridListAddRow ( gGrid["24-7Items"] )
		dgsGridListSetItemText ( gGrid["24-7Items"], row, gColumn["24-7Names"], "50 $ Guthaben", false, false )
		dgsGridListSetItemText ( gGrid["24-7Items"], row, gColumn["24-7Prices"], tostring ( prePaidPrices["low"] ).." $", false, false )

		row = dgsGridListAddRow ( gGrid["24-7Items"] )
		dgsGridListSetItemText ( gGrid["24-7Items"], row, gColumn["24-7Names"], "100 $ Guthaben", false, false )
		dgsGridListSetItemText ( gGrid["24-7Items"], row, gColumn["24-7Prices"], tostring ( prePaidPrices["middle"] ).." $", false, false )

		row = dgsGridListAddRow ( gGrid["24-7Items"] )
		dgsGridListSetItemText ( gGrid["24-7Items"], row, gColumn["24-7Names"], "250 $ Guthaben", false, false )
		dgsGridListSetItemText ( gGrid["24-7Items"], row, gColumn["24-7Prices"], tostring ( prePaidPrices["large"] ).." $", false, false )

		gLabel[2] = dgsCreateLabel(231,153,30,15,"Geld:",false,gWindow["24-7"])
		dgsLabelSetColor(gLabel[2],200,200,0)
		dgsLabelSetVerticalAlign(gLabel[2],"top")
		dgsLabelSetHorizontalAlign(gLabel[2],"left",false)
		dgsSetFont(gLabel[2],"default-bold")
		gLabel["curMoney24-7"] = dgsCreateLabel(237,167,71,15,"0 $",false,gWindow["24-7"])
		dgsLabelSetColor(gLabel["curMoney24-7"],0,125,0)
		dgsLabelSetVerticalAlign(gLabel["curMoney24-7"],"top")
		dgsLabelSetHorizontalAlign(gLabel["curMoney24-7"],"left",false)
		dgsSetFont(gLabel["curMoney24-7"],"default-bold")

		gRadio["vertrag"] = dgsCreateRadioButton(233,192,72,20,"Vertrag",false,gWindow["24-7"])
		dgsSetFont(gRadio["vertrag"],"default-bold")
		gRadio["prepayed"] = dgsCreateRadioButton(233,212,72,20,"PrePayed",false,gWindow["24-7"])
		dgsSetFont(gRadio["prepayed"],"default-bold")
		gRadio["flatrate"] = dgsCreateRadioButton(233,232,72,20,"Flatrate",false,gWindow["24-7"])
		dgsRadioButtonSetSelected(gRadio["flatrate"],true)

		dgsSetFont(gRadio["flatrate"],"default-bold")

		gButton["close24-7Window"] = dgsCreateButton(289,22,18,19,"x",false,gWindow["24-7"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		dgsSetFont(gButton["close24-7Window"],"default-bold")
		addEventHandler ( "onDgsMouseClickUp", gButton["close24-7Window"],
			function ( btn )
				if btn ~= "left" then return end
				showCursor ( false )
				guiSetInputMode ( "allow_binds" )
				dgsSetVisible ( gWindow["24-7"], false )
				triggerServerEvent ( "Cancel24_7", lp, lp )
			end,
		false )
		gButton["buy24-7Item"] = dgsCreateButton(235,107,70,41,"Kaufen",false,gWindow["24-7"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		dgsSetFont(gButton["buy24-7Item"],"default-bold")
		addEventHandler ( "onDgsMouseClickUp", gButton["buy24-7Item"],
			function ( btn, state )
				if btn == "left" then
					local rowindex, columnindex = dgsGridListGetSelectedItem ( gGrid["24-7Items"] )
					if rowindex == -1 then return end
					local text = dgsGridListGetItemText ( gGrid["24-7Items"], rowindex, gColumn["24-7Names"] )

					triggerServerEvent ( "itemBuy", lp, lp, itemShopIDs[text] )
				end
			end,
		false )
		gButton["changeMobile24-7"] = dgsCreateButton(235,261,70,33,"Tarif\nWechseln",false,gWindow["24-7"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler ( "onDgsMouseClickUp", gButton["changeMobile24-7"],
			function ( btn, state )
				if btn == "left" then
					local val
					if dgsRadioButtonGetSelected(gRadio["flatrate"]) then
						val = 3
					elseif dgsRadioButtonGetSelected(gRadio["prepayed"]) then
						val = 2
					elseif dgsRadioButtonGetSelected(gRadio["vertrag"]) then
						val = 1
					end

					triggerServerEvent ( "changeTarif", lp, val )
				end
			end,
		false )
		dgsSetFont(gButton["changeMobile24-7"],"default-bold")
	end
	refreshUtilityShopMoney ()
end
addEvent ( "create24_7Shop", true )
addEventHandler ( "create24_7Shop", getRootElement(), create24_7Shop_func )

function refreshUtilityShopMoney ()

	if gWindow["24-7"] then
		if dgsGetVisible ( gWindow["24-7"] ) then
			local money = mymoney
			dgsSetText ( gLabel["curMoney24-7"], money.." $" )
			setTimer ( refreshUtilityShopMoney, 1000, 1 )
		end
	end
end
