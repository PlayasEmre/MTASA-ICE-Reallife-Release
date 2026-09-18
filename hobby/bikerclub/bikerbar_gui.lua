--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function showBikerBarWindow_func ()

	guiSetInputMode ( "no_binds_when_editing" )
	showCursor ( true )
	if gWindow["bikerClubWindow"] then
		dgsSetVisible ( gWindow["bikerClubWindow"], true )
		dgsBringToFront ( gWindow["bikerClubWindow"] )
	else
		local screenwidth, screenheight = guiGetScreenSize ()

		gWindow["bikerClubWindow"] = dgsCreateWindow(screenwidth/2-345/2,screenheight/2-329/2,345,329,"Bikerclub",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true)
		dgsWindowSetSizable ( gWindow["bikerClubWindow"], false )
		dgsWindowSetMovable ( gWindow["bikerClubWindow"], false )
		dgsBringToFront ( gWindow["bikerClubWindow"] )
		dgsSetProperty ( gWindow["bikerClubWindow"], "image", false )

		gButton["billiardQue"] = dgsCreateButton(0.0377,0.0912,0.2145,0.1185,"Billiardque\nkaufen",true,gWindow["bikerClubWindow"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["Freeway"] = dgsCreateButton(0.2754,0.0912,0.2145,0.1185,"Freeway\nkaufen",true,gWindow["bikerClubWindow"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["Bikeroutfit"] = dgsCreateButton(0.7449,0.1155,0.2145,0.1185,"Bikeroutfit\nkaufen",true,gWindow["bikerClubWindow"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["bikerBeitreten"] = dgsCreateButton(0.1884,0.7872,0.2696,0.1398,"Beitreten",true,gWindow["bikerClubWindow"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["bikerClose"] = dgsCreateButton(0.629,0.7872,0.2696,0.1398,"Schliessen",true,gWindow["bikerClubWindow"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		addEventHandler("onDgsMouseClickUp", getRootElement(),
			function (btn)
				if btn ~= "left" then return end
				if source == gButton["billiardQue"] then
					triggerServerEvent ( "bikerBarBuyQue", getRootElement(), localPlayer )
				elseif source == gButton["Freeway"] then
					triggerServerEvent ( "bikerBarBuyBike", getRootElement(), localPlayer )
					dgsSetVisible(gWindow["bikerClubWindow"],false)
					guiSetInputMode("allow_binds")
					showCursor(false)
					triggerServerEvent ( "cancel_gui_server", localPlayer )
				elseif source == gButton["bikerBeitreten"] then
					triggerServerEvent ( "bikerBarJoin", getRootElement(), localPlayer )
				elseif source == gButton["Bikeroutfit"] then
					triggerServerEvent ( "bikerBarBuySkin", getRootElement(), localPlayer)
				elseif source == gButton["bikerClose"] then
					dgsSetVisible(gWindow["bikerClubWindow"],false)
					guiSetInputMode("allow_binds")
					showCursor(false)
					triggerServerEvent ( "cancel_gui_server", localPlayer )
				end
			end
		)


		gLabel["skinPrice"] = dgsCreateLabel(0.8,0.2523,0.1275,0.0547,outfitPrice.." $",true,gWindow["bikerClubWindow"])
		dgsLabelSetColor(gLabel["skinPrice"],000,125,000)
		dgsLabelSetVerticalAlign(gLabel["skinPrice"],"top")
		dgsLabelSetHorizontalAlign(gLabel["skinPrice"],"left",false)
		gLabel["freewayPrice"] = dgsCreateLabel(0.3159,0.228,0.1536,0.0547,freewayPrice.." $",true,gWindow["bikerClubWindow"])
		dgsLabelSetColor(gLabel["freewayPrice"],0,125,0)
		dgsLabelSetVerticalAlign(gLabel["freewayPrice"],"top")
		dgsLabelSetHorizontalAlign(gLabel["freewayPrice"],"left",false)
		gLabel["billiardQuePrice"] = dgsCreateLabel(0.113,0.2249,0.1536,0.0547,quePrice.." $",true,gWindow["bikerClubWindow"])
		dgsLabelSetColor(gLabel["billiardQuePrice"],0,125,0)
		dgsLabelSetVerticalAlign(gLabel["billiardQuePrice"],"top")
		dgsLabelSetHorizontalAlign(gLabel["billiardQuePrice"],"left",false)

		gLabel["mistysInfo"] = dgsCreateLabel(0.0261,0.5623,0.9594,0.1945,"Hier kannst du dem Bikerclub beiterten, was es dir erlaubt,\ndie oben genannten Boni zu erwerben. \nAusserdem kannst du dann in dieser Bar spawnen,\nfalls du dich neu einloggst oder stirbst.",true,gWindow["bikerClubWindow"])
		dgsLabelSetColor(gLabel["mistysInfo"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["mistysInfo"],"top")
		dgsLabelSetHorizontalAlign(gLabel["mistysInfo"],"left",false)
		dgsSetFont(gLabel["mistysInfo"],"default-bold")
		gLabel["bikerClubInfo"] = dgsCreateLabel(0.0725,0.4255,0.9275,0.1094,"Harte Rockmusik, billiges Bier und starke Maschienen - \nMystis Bar, Treffpunkt fuer alle Biker in San Fierro!",true,gWindow["bikerClubWindow"])
		dgsLabelSetColor(gLabel["bikerClubInfo"],200,200,000)
		dgsLabelSetVerticalAlign(gLabel["bikerClubInfo"],"top")
		dgsLabelSetHorizontalAlign(gLabel["bikerClubInfo"],"left",false)
		dgsSetFont(gLabel["bikerClubInfo"],"default-bold")
	end
end
addEvent ( "showBikerBarWindow", true )
addEventHandler ( "showBikerBarWindow", getRootElement(), showBikerBarWindow_func )
