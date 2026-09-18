--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

loadstring(exports.DGS:dgsImportFunction())()

function giveHotDogGui()

	if isElement ( gWindow["sellHotdog"] ) then
		return
	end

	showCursor ( true )

	local WIN_W, WIN_H = 230, 150
	gWindow["sellHotdog"] = dgsCreateWindow(screenwidth/2-WIN_W/2,145,WIN_W,WIN_H,"Hotdogverkauf",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true)
	dgsWindowSetSizable ( gWindow["sellHotdog"], false )
	dgsWindowSetMovable ( gWindow["sellHotdog"], false )
	dgsBringToFront ( gWindow["sellHotdog"] )

	gLabel["hotdogPreis"] = dgsCreateLabel(15,32,50,20,"Preis:",false,gWindow["sellHotdog"])
	dgsLabelSetColor(gLabel["hotdogPreis"],200,200,125,255)
	dgsLabelSetVerticalAlign(gLabel["hotdogPreis"],"top")
	dgsLabelSetHorizontalAlign(gLabel["hotdogPreis"],"left",false)
	dgsSetFont(gLabel["hotdogPreis"],"default-bold")
	gEdit["hotdogPrice"] = dgsCreateEdit(65,30,60,25,"",false,gWindow["sellHotdog"])
	gLabel["hotdog$Symbol"] = dgsCreateLabel(130,32,30,20,""..Tables.waehrung.."",false,gWindow["sellHotdog"])
	dgsLabelSetColor(gLabel["hotdog$Symbol"],15,200,0,255)
	dgsLabelSetVerticalAlign(gLabel["hotdog$Symbol"],"top")
	dgsLabelSetHorizontalAlign(gLabel["hotdog$Symbol"],"left",false)
	gButton["sellHotdog"] = dgsCreateButton(130,60,85,40,"Anbieten",false,gWindow["sellHotdog"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

	gLabel["hotdogsLeft"] = dgsCreateLabel(15,65,110,50,"Verbleibende Hotdogs\nim Wagen:",false,gWindow["sellHotdog"])
	dgsLabelSetColor(gLabel["hotdogsLeft"],200,15,15,255)
	dgsLabelSetVerticalAlign(gLabel["hotdogsLeft"],"top")
	dgsLabelSetHorizontalAlign(gLabel["hotdogsLeft"],"left",false)
	dgsSetFont(gLabel["hotdogsLeft"],"default-bold")
	gLabel["hotdogsCurrent"] = dgsCreateLabel(15,110,110,25,"0 Hotdogs",false,gWindow["sellHotdog"])
	dgsLabelSetColor(gLabel["hotdogsCurrent"],0,125,0,255)
	dgsLabelSetVerticalAlign(gLabel["hotdogsCurrent"],"top")
	dgsLabelSetHorizontalAlign(gLabel["hotdogsCurrent"],"left",false)
	dgsSetFont(gLabel["hotdogsCurrent"],"default-bold")

	addEventHandler("onDgsMouseClickUp", gButton["sellHotdog"],
		function(btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "sellhotdog", localPlayer, localPlayer, "", dgsGetText ( gEdit["hotdogPrice"] ) )
		end
	)
end

function HotdogLoadMenue()
	dgsSetInputMode ( "no_binds_when_editing" )
	showCursor ( true )
	setElementClicked ( true )

	if isElement ( gWindow["hotdogBuyin"] ) then
		return
	end

	local WIN_W, WIN_H = 230, 165
	gWindow["hotdogBuyin"] = dgsCreateWindow(screenwidth/2-WIN_W/2,screenheight/2-WIN_H/2,WIN_W,WIN_H,"Hotdogs einladen",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true)
	dgsWindowSetSizable ( gWindow["hotdogBuyin"], false )
	dgsWindowSetMovable ( gWindow["hotdogBuyin"], false )
	dgsBringToFront ( gWindow["hotdogBuyin"] )

	gEdit["hotdogAmount"] = dgsCreateEdit(15,45,60,30,"",false,gWindow["hotdogBuyin"])
	gButton["hotdogLoad"] = dgsCreateButton(100,45,115,30,"Einladen",false,gWindow["hotdogBuyin"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	gLabel["hotdogInfotext"] = dgsCreateLabel(15,90,200,20,"Preis pro Hotdog:",false,gWindow["hotdogBuyin"])
	dgsLabelSetColor(gLabel["hotdogInfotext"],200,200,0,255)
	dgsLabelSetVerticalAlign(gLabel["hotdogInfotext"],"top")
	dgsLabelSetHorizontalAlign(gLabel["hotdogInfotext"],"left",false)
	dgsSetFont(gLabel["hotdogInfotext"],"default-bold")
	gLabel["hotdogPrice"] = dgsCreateLabel(15,115,200,20,"1 "..Tables.waehrung.." / Stueck",false,gWindow["hotdogBuyin"])
	dgsLabelSetColor(gLabel["hotdogPrice"],0,125,0,255)
	dgsLabelSetVerticalAlign(gLabel["hotdogPrice"],"top")
	dgsLabelSetHorizontalAlign(gLabel["hotdogPrice"],"left",false)
	dgsSetFont(gLabel["hotdogPrice"],"default-bold")

	addEventHandler("onDgsMouseClickUp", gButton["hotdogLoad"],
		function(btn)
			if btn ~= "left" then return end
			triggerServerEvent ( "buyhotdogs", localPlayer, localPlayer, math.abs ( math.floor ( tonumber ( dgsGetText ( gEdit["hotdogAmount"] ) ) ) ) )
			dgsSetInputMode ( "allow_binds" )
			showCursor ( false )
			if isElement ( gWindow["hotdogBuyin"] ) then
				destroyElement ( gWindow["hotdogBuyin"] )
			end
			gWindow["hotdogBuyin"] = nil
			triggerServerEvent ( "cancel_gui_server", localPlayer )
		end
	)
end
addEvent ( "showHotdogLoadMenue", true )
addEventHandler ( "showHotdogLoadMenue", getRootElement(), HotdogLoadMenue )