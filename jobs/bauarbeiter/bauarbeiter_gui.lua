--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function showBauingWindow ()
	if isElement ( gWindow["BauSelection"] ) then
		return
	end

	guiSetInputMode ( "no_binds_when_editing" )
	showCursor ( true )
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

	gWindow["BauSelection"] = dgsCreateWindow(screenwidth/2-WIN_W/2,screenheight/2-WIN_H/2,WIN_W,WIN_H,"Bauarbeiter",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true)
	dgsBringToFront(gWindow["BauSelection"])
	dgsWindowSetMovable(gWindow["BauSelection"],false)
	dgsWindowSetSizable(gWindow["BauSelection"],false)

	gLabel[2] = dgsCreateLabel(LEFT_X,26,160,18,"Bauarbeiter-Level:",false,gWindow["BauSelection"])
	dgsLabelSetColor(gLabel[2],255,255,255)
	dgsLabelSetVerticalAlign(gLabel[2],"top")
	dgsLabelSetHorizontalAlign(gLabel[2],"left",false)
	dgsSetFont(gLabel[2],"default-bold")
	gLabel[3] = dgsCreateLabel(LEFT_X+160,26,50,18,tostring ( vioClientGetElementData ( "bauarbeiterLVL" ) ), false,gWindow["BauSelection"])
	dgsLabelSetColor(gLabel[3],0,200,0)
	dgsLabelSetVerticalAlign(gLabel[3],"top")
	dgsLabelSetHorizontalAlign(gLabel[3],"left",false)
	dgsSetFont(gLabel[3],"default-bold")

	gButton["Bauing1"] = dgsCreateButton(LEFT_X,ROW_Y1,BTN_W,BTN_H,"Anlagen Warten",false,gWindow["BauSelection"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(gButton["Bauing1"],"default-bold")
	addEventHandler ( "onDgsMouseClickUp", gButton["Bauing1"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "BauarbeiterJobRecieve", lp, "job1" )
			destroyElement ( gWindow["BauSelection"] )
			guiSetInputMode ( "allow_binds" )
			showCursor ( false )
			setElementClicked ( false )
		end,
	false )
	gLabel[1] = dgsCreateLabel(RIGHT_X,ROW_Y1,RIGHT_W,BTN_H+15,"Du musst Anlagen warten\nund erhaelst pro\nReparatur 25 "..Tables.waehrung..".",false,gWindow["BauSelection"])
	dgsLabelSetColor(gLabel[1],200,200,0)
	dgsLabelSetVerticalAlign(gLabel[1],"top")
	dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
	dgsSetFont(gLabel[1],"default-bold")

	if vioClientGetElementData ( "bauarbeiterLVL" ) >= 100 then
		txt = "Dozer Fahren"
		gLabel[4] = dgsCreateLabel(RIGHT_X,ROW_Y2,RIGHT_W,BTN_H+20,"Du musst Erde mit\ndem Dozer transpotieren\n- dafuer erhaelst du\n55 "..Tables.waehrung.." pro Ladung.",false,gWindow["BauSelection"])
		dgsLabelSetColor(gLabel[4],200,200,0)
		dgsLabelSetVerticalAlign(gLabel[4],"top")
		dgsLabelSetHorizontalAlign(gLabel[4],"left",false)
		dgsSetFont(gLabel[4],"default-bold")
	else
		txt = "Du brauchst\nmind. LVL 100"
	end
	gButton["Bauing2"] = dgsCreateButton(LEFT_X,ROW_Y2,BTN_W,BTN_H,txt,false,gWindow["BauSelection"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(gButton["Bauing2"],"default-bold")
	addEventHandler ( "onDgsMouseClickUp", gButton["Bauing2"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "BauarbeiterJobRecieve", lp, "job2" )
			destroyElement ( gWindow["BauSelection"] )
			guiSetInputMode ( "allow_binds" )
			showCursor ( false )
			setElementClicked ( false )
		end,
	false )
	if vioClientGetElementData ( "bauarbeiterLVL" ) >= 250 then
		txt = "Zementtruck Fahren"
		gLabel[5] = dgsCreateLabel(RIGHT_X,ROW_Y3,RIGHT_W,BTN_H+20,"Du musst Baustellen mit\ndem Zementtruck\nbeliefern - dafuer erhaelst\ndu 850 "..Tables.waehrung.." pro Lieferung.",false,gWindow["BauSelection"])
		dgsLabelSetColor(gLabel[5],200,200,0)
		dgsLabelSetVerticalAlign(gLabel[5],"top")
		dgsLabelSetHorizontalAlign(gLabel[5],"left",false)
		dgsSetFont(gLabel[5],"default-bold")
	else
		txt = "Du brauchst\nmind. LVL 250"
	end
	gButton["Bauing3"] = dgsCreateButton(LEFT_X,ROW_Y3,BTN_W,BTN_H,txt,false,gWindow["BauSelection"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(gButton["Bauing3"],"default-bold")
	addEventHandler ( "onDgsMouseClickUp", gButton["Bauing3"],
		function (btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "BauarbeiterJobRecieve", lp, "job3" )
			destroyElement ( gWindow["BauSelection"] )
			guiSetInputMode ( "allow_binds" )
			showCursor ( false )
			setElementClicked ( false )
		end,
	false )

	txt = "Comming soon!"
	gButton["Bauing4"] = dgsCreateButton(LEFT_X,ROW_Y4,BTN_W,BTN_H,txt,false,gWindow["BauSelection"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(gButton["Bauing4"],"default-bold")
	addEventHandler ( "onDgsMouseClickUp", gButton["Bauing4"],
		function (btn)
			if btn ~= "left" then return end
			destroyElement ( gWindow["BauSelection"] )
			guiSetInputMode ( "allow_binds" )
			showCursor ( false )
			setElementClicked ( false )
		end,
	false )
	gButton["Bauing5"] = dgsCreateButton(RIGHT_X,ROW_Y4,RIGHT_W,BTN_H,"Fenster schliessen",false,gWindow["BauSelection"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	dgsSetFont(gButton["Bauing5"],"default-bold")
	addEventHandler ( "onDgsMouseClickUp", gButton["Bauing5"],
		function (btn)
			if btn ~= "left" then return end
			destroyElement ( gWindow["BauSelection"] )
			guiSetInputMode ( "allow_binds" )
			showCursor ( false )
			setElementClicked ( false )
		end,
	false )
end
addEvent ( "showBauingWindow", true )
addEventHandler ( "showBauingWindow", getRootElement(), showBauingWindow )
