--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

pcall ( function () loadstring ( exports.DGS:dgsImportFunction() ) () end )

createObject ( 1285, -2017.1163330078, 454.44692993164, 34.750946044922 )

function showNewspaper_func ( text )

	hideInventory()
	setElementClicked ( true )
	guiSetInputMode ( "no_binds_when_editing" )
	showCursor ( true )
	if gWindow["newspaper"] then
		dgsSetVisible ( gWindow["newspaper"], true )
		dgsBringToFront ( gWindow["newspaper"] )
	else
		gWindow["newspaper"] = dgsCreateWindow(screenwidth/2-313/2,screenheight/2-420/2,313,420,"Zeitung",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true)
		dgsBringToFront ( gWindow["newspaper"] )
		dgsWindowSetMovable(gWindow["newspaper"],false)
		dgsWindowSetSizable(gWindow["newspaper"],false)

		gImage["newspaper"] = dgsCreateImage(18,23,281,73,":"..getResourceName(getThisResource()).."/images/liberty_tree.png",false,gWindow["newspaper"])

		gMemo["newspaper"] = dgsCreateMemo(15,95,286,272,text,false,gWindow["newspaper"])
		dgsMemoSetReadOnly(gMemo["newspaper"],true)
		dgsMemoSetWordWrapState(gMemo["newspaper"],true)

		gButton["newspaperClose"] = dgsCreateButton(280,22,24,24,"X",false,gWindow["newspaper"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		addEventHandler("onDgsMouseClickUp", gButton["newspaperClose"],
			function ( button )
				if button ~= "left" then return end
				setElementClicked ( false )
				guiSetInputMode ( "allow_binds" )
				showCursor ( false )
				dgsSetVisible ( gWindow["newspaper"], false )
			end,
		false )
	end
	dgsSetText ( gMemo["newspaper"], text )
end
addEvent ( "showNewspaper", true )
addEventHandler ( "showNewspaper", getRootElement(), showNewspaper_func )

function showNewspaperReporter_func ( text )

	setElementClicked ( true )
	guiSetInputMode ( "no_binds_when_editing" )
	showCursor ( true )
	toggleControl ( "chatbox", false )
	if gWindow["newspaperEdit"] then
		dgsSetVisible ( gWindow["newspaperEdit"], true )
		dgsBringToFront ( gWindow["newspaperEdit"] )
	else
		gWindow["newspaperEdit"] = dgsCreateWindow(screenwidth/2-313/2,screenheight/2-420/2,313,420,"Zeitung",false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true)
		dgsBringToFront ( gWindow["newspaperEdit"] )
		dgsWindowSetMovable(gWindow["newspaperEdit"],false)
		dgsWindowSetSizable(gWindow["newspaperEdit"],false)

		gImage["newspaperEdit"] = dgsCreateImage(18,23,281,73,":"..getResourceName(getThisResource()).."/images/liberty_tree.png",false,gWindow["newspaperEdit"])

		gMemo["newspaperEdit"] = dgsCreateMemo(15,95,286,272,text,false,gWindow["newspaperEdit"])
		dgsMemoSetWordWrapState(gMemo["newspaperEdit"],true)

		gButton["newspaperCloseEdit"] = dgsCreateButton(200,22,100,24,"Speichern",false,gWindow["newspaperEdit"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		addEventHandler("onDgsMouseClickUp", gButton["newspaperCloseEdit"],
			function ( button )
				if button ~= "left" then return end
				setElementClicked ( false )
				guiSetInputMode ( "allow_binds" )
				showCursor ( false )
				dgsSetVisible ( gWindow["newspaperEdit"], false )
				triggerServerEvent ( "redoNewspaperServer", lp, dgsGetText ( gMemo["newspaperEdit"] ) )
				toggleControl ( "chatbox", true )
			end,
		false )
	end
	dgsSetText ( gMemo["newspaperEdit"], text )
end
addEvent ( "showNewspaperReporter", true )
addEventHandler ( "showNewspaperReporter", getRootElement(), showNewspaperReporter_func )