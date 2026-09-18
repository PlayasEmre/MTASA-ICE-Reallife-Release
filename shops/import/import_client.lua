--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

loadstring(exports.DGS:dgsImportFunction())()

createBlip ( -1570.33, 83.42, 2.45, 6, 0.75, 255, 0, 0, 255, 0, 200 )

local importMarker = createMarker ( -1570.33, 83.42, 2.45, "cylinder", 1.5, 255, 0, 0, 150 )
function showImportWindow ( hit, dim )

	if hit == lp and dim and not getPedOccupiedVehicle ( hit ) then
		if isElement ( gWindow["bellicImport"] ) then
			return
		end

		local WIN_W, WIN_H = 330, 200
		local BTN_X, BTN_W, BTN_H, BTN_SPACING = 15, 75, 44, 10
		local BTN_Y1 = 20
		local BTN_Y2 = BTN_Y1 + BTN_H + BTN_SPACING
		local BTN_Y3 = BTN_Y2 + BTN_H + BTN_SPACING

		gWindow["bellicImport"] = dgsCreateWindow(screenwidth/2-WIN_W/2,screenheight/2-WIN_H/2,WIN_W,WIN_H,"Bellic & Bellic Import Co.",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true)
		dgsWindowSetSizable ( gWindow["bellicImport"], false )
		dgsWindowSetMovable ( gWindow["bellicImport"], false )
		dgsBringToFront ( gWindow["bellicImport"] )
		dgsSetProperty ( gWindow["bellicImport"], "image", false )

		gButton["importBuyTec9"] = dgsCreateButton(BTN_X,BTN_Y1,BTN_W,BTN_H,"Tec9",false,gWindow["bellicImport"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["importBuyUzi"] = dgsCreateButton(BTN_X,BTN_Y2,BTN_W,BTN_H,"Uzi",false,gWindow["bellicImport"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["importBuyMag"] = dgsCreateButton(BTN_X,BTN_Y3,BTN_W,BTN_H,"Magazin",false,gWindow["bellicImport"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["importClose"] = dgsCreateButton(WIN_W-BTN_X-BTN_W,BTN_Y3,BTN_W,BTN_H,"Schliessen",false,gWindow["bellicImport"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		gLabel[1] = dgsCreateLabel(34,24,33,16,"750 $",false,gButton["importBuyTec9"])
		dgsSetEnabled(gLabel[1],false)
		dgsLabelSetColor(gLabel[1],0,200,0,255)
		dgsLabelSetVerticalAlign(gLabel[1],"top")
		dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
		dgsSetFont(gLabel[1],"default-bold")
		gLabel[2] = dgsCreateLabel(34,25,33,14,"750 $",false,gButton["importBuyUzi"])
		dgsSetEnabled(gLabel[2],false)
		dgsLabelSetColor(gLabel[2],0,200,0,255)
		dgsLabelSetVerticalAlign(gLabel[2],"top")
		dgsLabelSetHorizontalAlign(gLabel[2],"left",false)
		dgsSetFont(gLabel[2],"default-bold")
		gLabel[3] = dgsCreateLabel(33,26,30,15,"150 $",false,gButton["importBuyMag"])
		dgsSetEnabled(gLabel[3],false)
		dgsLabelSetColor(gLabel[3],0,200,0,255)
		dgsLabelSetVerticalAlign(gLabel[3],"top")
		dgsLabelSetHorizontalAlign(gLabel[3],"left",false)
		dgsSetFont(gLabel[3],"default-bold")
		gLabel[4] = dgsCreateLabel(BTN_X+BTN_W+15,BTN_Y1,WIN_W-(BTN_X+BTN_W+15)-15,BTN_Y3-BTN_Y1,"Einhaendige Schnellfeuerwaffe.\nEs koennen auch zwei zur\ngleichen Zeit verwendet\nwerden.",false,gWindow["bellicImport"])
		dgsLabelSetColor(gLabel[4],200,200,0,255)
		dgsLabelSetVerticalAlign(gLabel[4],"top")
		dgsLabelSetHorizontalAlign(gLabel[4],"left",false)
		dgsSetFont(gLabel[4],"default-bold")

		guiSetInputMode ( "no_binds_when_editing" )
		showCursor ( true )
		setElementClicked ( true )

		addEventHandler ( "onDgsMouseClickUp", gButton["importClose"],
			function ( btn )
				if btn ~= "left" then return end
				guiSetInputMode ( "allow_binds" )
				showCursor ( false )
				setElementClicked ( false )
				if isElement ( gWindow["bellicImport"] ) then
					destroyElement ( gWindow["bellicImport"] )
					gWindow["bellicImport"] = nil
				end
			end,
		false )

		addEventHandler ( "onDgsMouseClickUp", gButton["importBuyUzi"],
			function ( btn )
				if btn ~= "left" then return end
				triggerServerEvent ( "importRecieve", lp, "uzi" )
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["importBuyTec9"],
			function ( btn )
				if btn ~= "left" then return end
				triggerServerEvent ( "importRecieve", lp, "tec9" )
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["importBuyMag"],
			function ( btn )
				if btn ~= "left" then return end
				triggerServerEvent ( "importRecieve", lp, "ammo" )
			end,
		false )
	end
end
addEventHandler ( "onClientMarkerHit", importMarker, showImportWindow )