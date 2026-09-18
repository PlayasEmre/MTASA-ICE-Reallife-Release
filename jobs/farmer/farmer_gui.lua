--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local dgsOk, dgsErr = pcall(function()
	loadstring(exports.DGS:dgsImportFunction())()
end)

function showFarmingWindow ()

	if isElement ( gWindow["farmSelection"] ) then
		return
	end

	showCursor ( true )
	guiSetInputMode ( "no_binds_when_editing" )
	setElementClicked ( true )
	local txt

	local WIN_W, WIN_H = 320, 320
	local LEFT_X = 16
	local BTN_W, BTN_H = 100, 43
	local ROW_SPACING = BTN_H + 20
	local ROW_Y1 = 60
	local ROW_Y2 = ROW_Y1 + ROW_SPACING
	local ROW_Y3 = ROW_Y2 + ROW_SPACING
	local ROW_Y4 = ROW_Y3 + ROW_SPACING
	local RIGHT_X = LEFT_X + BTN_W + 16
	local RIGHT_W = WIN_W - RIGHT_X - 16

	gWindow["farmSelection"] = dgsCreateWindow(screenwidth/2-WIN_W/2,screenheight/2-WIN_H/2,WIN_W,WIN_H,"Farmer",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true)
	dgsBringToFront(gWindow["farmSelection"])
	dgsWindowSetMovable(gWindow["farmSelection"],false)
	dgsWindowSetSizable(gWindow["farmSelection"],false)

	gLabel[2] = dgsCreateLabel(LEFT_X,26,180,18,"Aktueller Farmer-Level:",false,gWindow["farmSelection"])
	dgsLabelSetColor(gLabel[2],255,255,255,255)
	dgsLabelSetVerticalAlign(gLabel[2],"top")
	dgsLabelSetHorizontalAlign(gLabel[2],"left",false)
	dgsSetFont(gLabel[2],"default-bold")
	gLabel[3] = dgsCreateLabel(LEFT_X+180,26,40,18,tostring ( vioClientGetElementData ( "farmerLVL" ) ), false,gWindow["farmSelection"])
	dgsLabelSetColor(gLabel[3],0,200,0,255)
	dgsLabelSetVerticalAlign(gLabel[3],"top")
	dgsLabelSetHorizontalAlign(gLabel[3],"left",false)
	dgsSetFont(gLabel[3],"default-bold")

	gButton["farming1"] = dgsCreateButton(LEFT_X,ROW_Y1,BTN_W,BTN_H,"Auf dem Feld arbeiten",false,gWindow["farmSelection"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(gButton["farming1"],"default-bold")
	addEventHandler ( "onDgsMouseClickUp", gButton["farming1"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "farmerJobRecieve", lp, "job1" )
			if isElement ( gWindow["farmSelection"] ) then destroyElement ( gWindow["farmSelection"] ) end
			gWindow["farmSelection"] = nil
			showCursor ( false )
			guiSetInputMode ( "allow_binds" )
			setElementClicked ( false )
		end,
	false )
	gLabel[1] = dgsCreateLabel(RIGHT_X,ROW_Y1,RIGHT_W,BTN_H+15,"Du musst Getreide saehen\nund erhaelst dafuer pro\ngesaehter Pflanze 15 "..Tables.waehrung..".",false,gWindow["farmSelection"])
	dgsLabelSetColor(gLabel[1],200,200,0,255)
	dgsLabelSetVerticalAlign(gLabel[1],"top")
	dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
	dgsSetFont(gLabel[1],"default-bold")

	if vioClientGetElementData ( "farmerLVL" ) >= 100 then
		txt = "Traktor fahren"
		gLabel[4] = dgsCreateLabel(RIGHT_X,ROW_Y2,RIGHT_W,BTN_H+20,"Du musst Pflanzen mit\ndem Traktor ernten\n- dafuer erhaelst du\n20 "..Tables.waehrung.." pro Pflanze.",false,gWindow["farmSelection"])
		dgsLabelSetColor(gLabel[4],200,200,0,255)
		dgsLabelSetVerticalAlign(gLabel[4],"top")
		dgsLabelSetHorizontalAlign(gLabel[4],"left",false)
		dgsSetFont(gLabel[4],"default-bold")
	else
		txt = "Du brauchst\nmind. LVL 100"
	end
	gButton["farming2"] = dgsCreateButton(LEFT_X,ROW_Y2,BTN_W,BTN_H,txt,false,gWindow["farmSelection"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(gButton["farming2"],"default-bold")
	addEventHandler ( "onDgsMouseClickUp", gButton["farming2"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "farmerJobRecieve", lp, "job2" )
			if isElement ( gWindow["farmSelection"] ) then destroyElement ( gWindow["farmSelection"] ) end
			gWindow["farmSelection"] = nil
			showCursor ( false )
			guiSetInputMode ( "allow_binds" )
			setElementClicked ( false )
		end,
	false )
	if vioClientGetElementData ( "farmerLVL" ) >= 250 then
		txt = "Maehdrescher fahren"
		gLabel[5] = dgsCreateLabel(RIGHT_X,ROW_Y3,RIGHT_W,BTN_H+20,"Du musst Getreide mit\ndem Maehdrescher\nernten - dafuer erhaelst\ndu 25 "..Tables.waehrung.." pro Pflanze.",false,gWindow["farmSelection"])
		dgsLabelSetColor(gLabel[5],200,200,0,255)
		dgsLabelSetVerticalAlign(gLabel[5],"top")
		dgsLabelSetHorizontalAlign(gLabel[5],"left",false)
		dgsSetFont(gLabel[5],"default-bold")
	else
		txt = "Du brauchst\nmind. LVL 250"
	end
	gButton["farming3"] = dgsCreateButton(LEFT_X,ROW_Y3,BTN_W,BTN_H,txt,false,gWindow["farmSelection"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(gButton["farming3"],"default-bold")
	addEventHandler ( "onDgsMouseClickUp", gButton["farming3"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "farmerJobRecieve", lp, "job3" )
			if isElement ( gWindow["farmSelection"] ) then destroyElement ( gWindow["farmSelection"] ) end
			gWindow["farmSelection"] = nil
			showCursor ( false )
			guiSetInputMode ( "allow_binds" )
			setElementClicked ( false )
		end,
	false )
	if vioClientGetElementData ( "farmerLVL" ) >= 500 then
		txt = "Farmeroutfit verwenden"
	else
		txt = "Du brauchst\nmind. LVL 500"
	end
	gButton["farming4"] = dgsCreateButton(LEFT_X,ROW_Y4,BTN_W,BTN_H,txt,false,gWindow["farmSelection"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(gButton["farming4"],"default-bold")
	addEventHandler ( "onDgsMouseClickUp", gButton["farming4"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "farmerJobRecieve", lp, "skin" )
			if isElement ( gWindow["farmSelection"] ) then destroyElement ( gWindow["farmSelection"] ) end
			gWindow["farmSelection"] = nil
			showCursor ( false )
			guiSetInputMode ( "allow_binds" )
			setElementClicked ( false )
		end,
	false )
	gButton["farming5"] = dgsCreateButton(RIGHT_X,ROW_Y4,RIGHT_W,BTN_H,"Fenster schliessen",false,gWindow["farmSelection"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(gButton["farming5"],"default-bold")
	addEventHandler ( "onDgsMouseClickUp", gButton["farming5"],
		function (btn)
			if btn ~= "left" then return end
			if isElement ( gWindow["farmSelection"] ) then destroyElement ( gWindow["farmSelection"] ) end
			gWindow["farmSelection"] = nil
			showCursor ( false )
			guiSetInputMode ( "allow_binds" )
			setElementClicked ( false )
		end,
	false )
end
addEvent ( "showFarmingWindow", true )
addEventHandler ( "showFarmingWindow", getRootElement(), showFarmingWindow )
