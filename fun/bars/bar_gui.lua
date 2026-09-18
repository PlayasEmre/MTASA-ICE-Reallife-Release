--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

pcall ( function () loadstring ( exports.DGS:dgsImportFunction () ) () end )

barMarkers = {}
 barMarkers["x"] = {}
 barMarkers["y"] = {}
 barMarkers["z"] = {}
 barMarkers["int"] = {}
 barMarkers["dim"] = {}
 barMarkers["size"] = {}
  barMarkers["marker"] = {}
  barMarkers["x"][1], barMarkers["y"][1], barMarkers["z"][1], barMarkers["int"][1], barMarkers["dim"][1], barMarkers["size"][1] = -2652.2902832031, 1410.4134521484, 905.24816894531, 3, 0, 1
  barMarkers["x"][2], barMarkers["y"][2], barMarkers["z"][2], barMarkers["int"][2], barMarkers["dim"][2], barMarkers["size"][2] = 499.94775390625, -20.654975891113, 999.67, 17, 0, 2
  

  -- Four Dragons Casino --
  barMarkers["x"][3], barMarkers["y"][3], barMarkers["z"][3], barMarkers["int"][3], barMarkers["dim"][3], barMarkers["size"][3] = 1945.8907470703, 1017.8198242188, 991.4501953125, 10, 0, 1
  barMarkers["x"][4], barMarkers["y"][4], barMarkers["z"][4], barMarkers["int"][4], barMarkers["dim"][4], barMarkers["size"][4] = 1955.6105957031, 1017.8285522461, 991.4345703125, 10, 0, 1

  -- Caligulas Casino --
  barMarkers["x"][5], barMarkers["y"][5], barMarkers["z"][5], barMarkers["int"][5], barMarkers["dim"][5], barMarkers["size"][5] = 2199.7626953125, 1603.626953125, 1004.015625, 1, 0, 1
  barMarkers["x"][6], barMarkers["y"][6], barMarkers["z"][6], barMarkers["int"][6], barMarkers["dim"][6], barMarkers["size"][6] = 2188.5283203125, 1605.5618896484, 1004.028320312, 1, 0, 1

  -- Aztecas Strip --
  barMarkers["x"][7], barMarkers["y"][7], barMarkers["z"][7], barMarkers["int"][7], barMarkers["dim"][7], barMarkers["size"][7] = 1215.8959960938, -13.18529510498, 999.87084960938, 2, 0, 1

  -- Biker-Bar --
  barMarkers["x"][8], barMarkers["y"][8], barMarkers["z"][8], barMarkers["int"][8], barMarkers["dim"][8], barMarkers["size"][8] = 498.78479003906, -75.672836303711, 997.70678710938, 11, 0, 1
  barMarkers["x"][9], barMarkers["y"][9], barMarkers["z"][9], barMarkers["int"][9], barMarkers["dim"][9], barMarkers["size"][9] = 1138.87109375, -8.30859375, 999.6796875, 12, 0, 1

for key, index in pairs ( barMarkers["x"] ) do
	local x, y, z = barMarkers["x"][key], barMarkers["y"][key], barMarkers["z"][key]
	local int = barMarkers["int"][key]
	local dim = barMarkers["dim"][key]
	local size = barMarkers["size"][key]
	barMarkers["marker"][key] = createMarker ( x, y, z, "cylinder", size, 125, 0, 0, 150 )
	setElementInterior ( barMarkers["marker"][key], int )
	setElementDimension ( barMarkers["marker"][key], dim )
	addEventHandler ( "onClientMarkerHit", barMarkers["marker"][key],
		function ( player, dim )
			if player == lp and dim then
				if getElementInterior ( player ) == getElementInterior ( source ) then
					guiSetInputMode ( "no_binds_when_editing" )
					showCursor ( true )
					setElementClicked ( true )
					showBarInterface ()
				end
			end
		end
	)
end

function showBarInterface ()

	if gWindow["bar"] and isElement ( gWindow["bar"] ) then
		dgsSetVisible ( gWindow["bar"], true )
		dgsBringToFront ( gWindow["bar"] )
	else
		local WIN_W, WIN_H = 325, 220
		local LEFT_X = 10
		local GRID_W, GRID_H = 140, 166
		local GRID_Y = (WIN_H - GRID_H) / 2
		local RIGHT_X = LEFT_X + GRID_W + 15
		local BTN_W, BTN_H = 80, 43
		local BTN_SPACING = 8
		local BTN_BLOCK_H = BTN_H * 3 + BTN_SPACING * 2
		local BTN_Y1 = (WIN_H - BTN_BLOCK_H) / 2
		local BTN_Y2 = BTN_Y1 + BTN_H + BTN_SPACING
		local BTN_Y3 = BTN_Y2 + BTN_H + BTN_SPACING
		local BOTTLE_X = RIGHT_X + BTN_W + 15

		gWindow["bar"] = dgsCreateWindow(screenwidth/2-WIN_W/2,screenheight/2-WIN_H/2,WIN_W,WIN_H,"Bar",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true)
		dgsBringToFront ( gWindow["bar"] )
		dgsSetProperty ( gWindow["bar"], "image", false )
		dgsWindowSetMovable ( gWindow["bar"], false )
		dgsWindowSetSizable ( gWindow["bar"], false )

		gGrid["barDrinks"] = dgsCreateGridList(LEFT_X,GRID_Y,GRID_W,GRID_H,false,gWindow["bar"])
		dgsGridListSetSelectionMode(gGrid["barDrinks"],0)
		gColumn["barGetraenk"] = dgsGridListAddColumn(gGrid["barDrinks"],"Getraenk",0.6)
		gColumn["barPreis"] = dgsGridListAddColumn(gGrid["barDrinks"],"Preis",0.2)

		gLabel[1] = dgsCreateLabel(RIGHT_X,BTN_Y1-22,BTN_W+15+60,20,"Was darfs sein?",false,gWindow["bar"], tocolor(0,200,0,255))
		dgsLabelSetVerticalAlign(gLabel[1],"top")
		dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
		dgsSetFont(gLabel[1],"default-bold")

		gButton["barDrink"] = dgsCreateButton(RIGHT_X,BTN_Y1,BTN_W,BTN_H,"Trinken",false,gWindow["bar"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["barSnack"] = dgsCreateButton(RIGHT_X,BTN_Y2,BTN_W,BTN_H,"Snack\nkaufen",false,gWindow["bar"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["barClose"] = dgsCreateButton(RIGHT_X,BTN_Y3,BTN_W,BTN_H,"Schliessen",false,gWindow["bar"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		gImage[1] = dgsCreateImage(BOTTLE_X,BTN_Y1,60,BTN_Y3+BTN_H-BTN_Y1,":"..getResourceName(getThisResource()).."/images/gui/bottle.png",false,gWindow["bar"])
		dgsSetAlpha(gImage[1],0.7)
		dgsSetEnabled(gImage[1],false)

		addEventHandler ( "onDgsMouseClickUp", gButton["barDrink"],
			function (btn)
				if btn ~= "left" then return end
				local row, column = dgsGridListGetSelectedItem ( gGrid["barDrinks"] )
				if row == -1 then return end
				local drink = dgsGridListGetItemText ( gGrid["barDrinks"], row, gColumn["barGetraenk"] )
				if alcoholSorts[drink] then
					guiSetInputMode ( "allow_binds" )
					showCursor ( false )
					setElementClicked ( false )
					dgsSetVisible ( gWindow["bar"], false )
					triggerServerEvent ( "drinkSomethingFromBar", lp, drink )
				end
			end
		)
		addEventHandler ( "onDgsMouseClickUp", gButton["barClose"],
			function (btn)
				if btn ~= "left" then return end
				guiSetInputMode ( "allow_binds" )
				showCursor ( false )
				setElementClicked ( false )
				dgsSetVisible ( gWindow["bar"], false )
			end
		)
		addEventHandler ( "onDgsMouseClickUp", gButton["barSnack"],
			function (btn)
				if btn ~= "left" then return end
				triggerServerEvent ( "buySnack", localPlayer, lp )
			end
		)
		for key, index in pairs ( alcoholPrices ) do
			local row = dgsGridListAddRow ( gGrid["barDrinks"] )
			dgsGridListSetItemText ( gGrid["barDrinks"], row, gColumn["barGetraenk"], key, false, false )
			dgsGridListSetItemText ( gGrid["barDrinks"], row, gColumn["barPreis"], index.." $", false, false )
		end
	end
end