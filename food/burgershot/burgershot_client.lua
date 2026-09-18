--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

createObject ( 2642, -2358.2592773438, -160.6789855957, 36.138740539551 )
createObject ( 8843, -2352.7250976563, -159.10821533203, 34.3203125 )
createObject ( 8843, -2333.2939453125, -172.28869628906, 34.3203125, 0, 0, 90 )

createBlip ( -2352.765625, -155.2479095459, 34.0703125, 10, 2, 255, 0, 0, 255, 0, 200 )
createBlip ( 2154.13, 2808.33, 9.81, 10, 2, 255, 0, 0, 255, 0, 200 )
createBlip ( 1856.83, 2081.05, 9.82, 10, 2, 255, 0, 0, 255, 0, 200 )

DriveInMarkerSF = createMarker ( -2352.765625, -155.2479095459, 34.0703125, "cylinder", 5, 125, 0, 0, 200 )
DriveInMarkerLV1 = createMarker ( 2154.13, 2808.33, 9.81, "cylinder", 5, 125, 0, 0, 200 )
DriveInMarkerLV2 = createMarker ( 1856.83, 2081.05, 9.82, "cylinder", 5, 125, 0, 0, 200 )

function showDriveIn_func ( hit, dim )

	local unusedX1, unusedY1, z1 = getElementPosition ( source )
	local unusedX2, unusedY2, z2 = getElementPosition ( hit )
	local diff = math.abs ( z1 - z2 )
	if hit == lp and dim and diff < 10 then
		setElementClicked ( true )
		guiSetInputMode("no_binds_when_editing")
		showCursor ( true )
		if isElement ( gWindow["burgershotDriveIn"] ) then
			dgsSetVisible ( gWindow["burgershotDriveIn"], true )
			dgsBringToFront ( gWindow["burgershotDriveIn"] )
		else
			local WIN_W, WIN_H = 380, 190

			gWindow["burgershotDriveIn"] = dgsCreateWindow ( screenwidth/2-WIN_W/2, screenheight/2-WIN_H/2, WIN_W, WIN_H, "Burgershot", false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true )
			dgsBringToFront ( gWindow["burgershotDriveIn"] )
			dgsWindowSetMovable(gWindow["burgershotDriveIn"], false)
			dgsWindowSetSizable(gWindow["burgershotDriveIn"], false)

			gLabel["burgershotInfo"] = dgsCreateLabel(15,25,350,35,"Herzlich Wilkommen bei \"Burgershot\".\nIhre Bestellung bitte!",false,gWindow["burgershotDriveIn"])
			dgsSetEnabled(gLabel["burgershotInfo"],false)
			dgsLabelSetColor(gLabel["burgershotInfo"],200,200,0,255)
			dgsLabelSetVerticalAlign(gLabel["burgershotInfo"],"top")
			dgsLabelSetHorizontalAlign(gLabel["burgershotInfo"],"left",false)
			dgsSetFont(gLabel["burgershotInfo"],"default-bold")

			gImage["burgershotBurger"] = dgsCreateImage({x=15, y=70, w=70, h=70, img=":"..getResourceName(getThisResource()).."/images/inventory/burger.bmp", relative=false, parent=gWindow["burgershotDriveIn"]})
			dgsSetEnabled(gImage["burgershotBurger"],false)
			gLabel["burgershotInfo1"] = dgsCreateLabel(95,75,90,20,"Burger",false,gWindow["burgershotDriveIn"])
			dgsSetEnabled(gLabel["burgershotInfo1"],false)
			dgsLabelSetColor(gLabel["burgershotInfo1"],255,255,255,255)
			dgsLabelSetVerticalAlign(gLabel["burgershotInfo1"],"top")
			dgsLabelSetHorizontalAlign(gLabel["burgershotInfo1"],"left",false)
			dgsSetFont(gLabel["burgershotInfo1"],"default-bold")
			gLabel["burgershotInfo2"] = dgsCreateLabel(95,98,90,20, burgerPrice.." "..Tables.waehrung.."",false,gWindow["burgershotDriveIn"])
			dgsSetEnabled(gLabel["burgershotInfo2"],false)
			dgsLabelSetColor(gLabel["burgershotInfo2"],25,125,0,255)
			dgsLabelSetVerticalAlign(gLabel["burgershotInfo2"],"top")
			dgsLabelSetHorizontalAlign(gLabel["burgershotInfo2"],"left",false)
			dgsSetFont(gLabel["burgershotInfo2"],"default-bold")

			gImage["burgershotSnack"] = dgsCreateImage({x=200, y=70, w=70, h=70, img=":"..getResourceName(getThisResource()).."/images/inventory/snack.bmp", relative=false, parent=gWindow["burgershotDriveIn"]})
			dgsSetEnabled(gImage["burgershotSnack"],false)
			gLabel["burgershotPrice2"] = dgsCreateLabel(280,75,90,20,"Snack",false,gWindow["burgershotDriveIn"])
			dgsSetEnabled(gLabel["burgershotPrice2"],false)
			dgsLabelSetColor(gLabel["burgershotPrice2"],255,255,255,255)
			dgsLabelSetVerticalAlign(gLabel["burgershotPrice2"],"top")
			dgsLabelSetHorizontalAlign(gLabel["burgershotPrice2"],"left",false)
			dgsSetFont(gLabel["burgershotPrice2"],"default-bold")
			gLabel["burgershotPrice1"] = dgsCreateLabel(280,98,90,20, snackPrice.." "..Tables.waehrung.."",false,gWindow["burgershotDriveIn"])
			dgsSetEnabled(gLabel["burgershotPrice1"],false)
			dgsLabelSetColor(gLabel["burgershotPrice1"],25,125,0,255)
			dgsLabelSetVerticalAlign(gLabel["burgershotPrice1"],"top")
			dgsLabelSetHorizontalAlign(gLabel["burgershotPrice1"],"left",false)
			dgsSetFont(gLabel["burgershotPrice1"],"default-bold")

			gButton["BurgershotBuy1"] = dgsCreateButton(95,135,70,30,"Kaufen",false,gWindow["burgershotDriveIn"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
			gButton["BurgershotBuy2"] = dgsCreateButton(280,135,70,30,"Kaufen",false,gWindow["burgershotDriveIn"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

			addEventHandler( "onDgsMouseClickUp", gButton["BurgershotBuy1"],
				function (btn)
					if btn ~= "left" then return end
					triggerServerEvent ( "BurgershotBuy", lp, 1 )
					closeBurgershotWindow ()
				end
			)
			addEventHandler( "onDgsMouseClickUp", gButton["BurgershotBuy2"],
				function (btn)
					if btn ~= "left" then return end
					triggerServerEvent ( "BurgershotBuy", lp, 2 )
					closeBurgershotWindow ()
				end
			)
		end
	end
end
addEventHandler ( "onClientMarkerHit", DriveInMarkerSF, showDriveIn_func )
addEventHandler ( "onClientMarkerHit", DriveInMarkerLV1, showDriveIn_func )
addEventHandler ( "onClientMarkerHit", DriveInMarkerLV2, showDriveIn_func )

function closeBurgershotWindow ()
	if isElement ( gWindow["burgershotDriveIn"] ) then
		destroyElement ( gWindow["burgershotDriveIn"] )
	end
	gWindow["burgershotDriveIn"] = nil
	showCursor ( false )
	guiSetInputMode("allow_binds")
	setElementClicked ( false )
end