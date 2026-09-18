--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

addAddictPickup = createPickup ( -2651.09, 696.99, 27.58, 3, 1239, 0, 0 )

function showRemoveAddict ( player, matchdim )
	if player == localPlayer and matchdim then
		showCursor ( true )
		setElementClicked ( true )
		if gWindow["removeAddict"] then
			dgsSetVisible ( gWindow["removeAddict"], true )
			dgsBringToFront ( gWindow["removeAddict"] )
		else
			gWindow["removeAddict"] = dgsCreateWindow(800,400,329,155,"Krankenhaus",false)
			dgsBringToFront ( gWindow["removeAddict"] )
			dgsWindowSetCloseButtonEnabled(gWindow["removeAddict"], false)
			dgsWindowSetMovable ( gWindow["removeAddict"], false )
			dgsWindowSetSizable ( gWindow["removeAddict"], false )
			dgsSetAlpha(gWindow["removeAddict"],1)
			
			gLabel[1] = dgsCreateLabel(9,27,279,33,"Herzlich Willkommen!\nHier kannst du dir deine Sucht austreiben lassen!",false,gWindow["removeAddict"])
			dgsSetAlpha(gLabel[1],1)
			dgsLabelSetColor(gLabel[1],200,200,0)
			dgsLabelSetVerticalAlign(gLabel[1],"top")
			dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
			dgsSetFont(gLabel[1],"default-bold")
			gLabel[2] = dgsCreateLabel(109,77,119,16,"Kosten des Entzuges:",false,gWindow["removeAddict"])
			dgsSetAlpha(gLabel[2],1)
			dgsLabelSetColor(gLabel[2],63,160,224)
			dgsLabelSetVerticalAlign(gLabel[2],"top")
			dgsLabelSetHorizontalAlign(gLabel[2],"left",false)
			dgsSetFont(gLabel[2],"default-bold")

			gButton["removeAddictClose"] = dgsCreateButton(304,10,16,19,"x",false,gWindow["removeAddict"])
			dgsSetAlpha(gButton["removeAddictClose"],1)
			dgsSetFont(gButton["removeAddictClose"],"default-bold")
			gButton["removeAddictBuy"] = dgsCreateButton(130,94,60,30,"- "..Tables.waehrung.."",false,gWindow["removeAddict"],_,_,_,_,_,_,tocolor(46,110,255,255),tocolor(123,163,255,255),tocolor(24,74,199,255))
			dgsSetAlpha(gButton["removeAddictBuy"],1)
			dgsSetFont(gButton["removeAddictBuy"],"default-bold")
			
			addEventHandler ( "onDgsMouseClick", gButton["removeAddictClose"],
				function (button,state)
				if button == "left" and state == "down" then
					showCursor ( false )
					setElementClicked ( false )
					dgsSetVisible ( gWindow["removeAddict"], false )
				end
			end
			,false)
			
			addEventHandler ( "onDgsMouseClick", gButton["removeAddictBuy"],
				function (button,state)
					if getTotalAddictLevel ( player ) > 0 then
					    if button == "left" and state == "down" then
							showCursor ( false )
							setElementClicked ( false )
							dgsSetVisible ( gWindow["removeAddict"], false )
							triggerServerEvent ( "removeAddicts", lp )
						end
					end
				end
			,false)
		end
		dgsSetText ( gButton["removeAddictBuy"], ( getTotalAddictLevel ( player ) * addictRemoveCost ).." "..Tables.waehrung.."" )
	end
end
addEventHandler ( "onClientPickupHit", addAddictPickup, showRemoveAddict )

function showAddictInfo_func ( )

	showCursor ( true )
	if isElement(gWindow["suchtInfo"]) then
		dgsSetVisible ( gWindow["suchtInfo"], true )
		dgsBringToFront ( gWindow["suchtInfo"] )
	else
		gWindow["suchtInfo"] = dgsCreateWindow(810,100,307,320,"Sucht",false)
		dgsBringToFront ( gWindow["suchtInfo"] )
		dgsWindowSetCloseButtonEnabled(gWindow["suchtInfo"], false)
		dgsSetAlpha ( gWindow["suchtInfo"], 1 )
		dgsWindowSetMovable ( gWindow["suchtInfo"], false )
		dgsWindowSetSizable ( gWindow["suchtInfo"], false )
	
		gLabel[1] = dgsCreateLabel(10,25,288,80,"Hier kannst du ablesen, wonach du suechtig bist\nbzw. wieviel du vom jeweiligen Wirkstoff intus hast.\n\nSinkt der Pegel eines Wirkstoffes nach dem du sue-\nchtig bist zu stark, treten Entzugserscheinungen\nein.",false,gWindow["suchtInfo"])
		dgsLabelSetColor(gLabel[1],255,255,255)
		dgsLabelSetVerticalAlign(gLabel[1],"top")
		dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
		dgsSetFont(gLabel[1],"default-bold")
		gLabel[2] = dgsCreateLabel(11,113,86,17,"Wirkstoffpegel",false,gWindow["suchtInfo"])
		dgsLabelSetColor(gLabel[2],63,160,224)
		dgsLabelSetVerticalAlign(gLabel[2],"top")
		dgsLabelSetHorizontalAlign(gLabel[2],"left",false)
		dgsSetFont(gLabel[2],"default-bold")
		gLabel[4] = dgsCreateLabel(181,111,63,15,"Suchtlevel",false,gWindow["suchtInfo"])
		dgsLabelSetColor(gLabel[4],63,160,224)
		dgsLabelSetVerticalAlign(gLabel[4],"top")
		dgsLabelSetHorizontalAlign(gLabel[4],"left",false)
		dgsSetFont(gLabel[4],"default-bold")
		gLabel[6] = dgsCreateLabel(13,237,287,46,"Wenn du eine Sucht loswerden willst,\nkannst du dich im Krankenhaus behandeln lassen,\noder du wartest, bis die Sucht nachlaesst.",false,gWindow["suchtInfo"])
		dgsLabelSetColor(gLabel[6],200,200,0)
		dgsLabelSetVerticalAlign(gLabel[6],"top")
		dgsLabelSetHorizontalAlign(gLabel[6],"left",false)
		dgsSetFont(gLabel[6],"default-bold")

		gProgress["cigFlush"] = dgsCreateProgressBar(13,137,77,20,false,gWindow["suchtInfo"])
		gLabel[3] = dgsCreateLabel(18,2,49,16,"Nikotin",false,gProgress["cigFlush"])
		dgsLabelSetColor(gLabel[3],0,0,200)
		dgsLabelSetVerticalAlign(gLabel[3],"top")
		dgsLabelSetHorizontalAlign(gLabel[3],"left",false)
		dgsSetFont(gLabel[3],"default-bold")
		gProgress["alcFlush"] = dgsCreateProgressBar(13,171,77,20,false,gWindow["suchtInfo"])
		gLabel[3] = dgsCreateLabel(18,2,49,16,"Ethanol",false,gProgress["alcFlush"])
		dgsLabelSetColor(gLabel[3],0,0,200)
		dgsLabelSetVerticalAlign(gLabel[3],"top")
		dgsLabelSetHorizontalAlign(gLabel[3],"left",false)
		dgsSetFont(gLabel[3],"default-bold")
		gProgress["drugFlush"] = dgsCreateProgressBar(13,209,77,20,false,gWindow["suchtInfo"])
		gLabel[3] = dgsCreateLabel(18,2,49,16,"THC",false,gProgress["drugFlush"])
		dgsLabelSetColor(gLabel[3],0,0,200)
		dgsLabelSetVerticalAlign(gLabel[3],"top")
		dgsLabelSetHorizontalAlign(gLabel[3],"left",false)
		dgsSetFont(gLabel[3],"default-bold")

		gLabel["cigarettLevel"] = dgsCreateLabel(169,137,138,16,"Zigarettensuechtig",false,gWindow["suchtInfo"])
		dgsLabelSetColor(gLabel["cigarettLevel"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["cigarettLevel"],"top")
		dgsLabelSetHorizontalAlign(gLabel["cigarettLevel"],"left",false)
		dgsSetFont(gLabel["cigarettLevel"],"default-bold")
		gLabel["alcLevel"] = dgsCreateLabel(169,171,138,16,"Zigarettensuechtig",false,gWindow["suchtInfo"])
		dgsLabelSetColor(gLabel["alcLevel"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["alcLevel"],"top")
		dgsLabelSetHorizontalAlign(gLabel["alcLevel"],"left",false)
		dgsSetFont(gLabel["alcLevel"],"default-bold")
		gLabel["drugLevel"] = dgsCreateLabel(169,209,138,16,"Zigarettensuechtig",false,gWindow["suchtInfo"])
		dgsLabelSetColor(gLabel["drugLevel"],255,255,255)
		dgsLabelSetVerticalAlign(gLabel["drugLevel"],"top")
		dgsLabelSetHorizontalAlign(gLabel["drugLevel"],"left",false)
		dgsSetFont(gLabel["drugLevel"],"default-bold")

		gImage[1] = dgsCreateImage(119,137,31,26,"images/addict/cig.bmp",false,gWindow["suchtInfo"])
		gImage[1] = dgsCreateImage(119,171,31,26,"images/addict/alc.bmp",false,gWindow["suchtInfo"])
		gImage[1] = dgsCreateImage(119,200,31,26,"images/addict/drug.bmp",false,gWindow["suchtInfo"])
	end
	setTimer ( dgsSetVisible, 5000, 1, gWindow["suchtInfo"], false )
	setTimer ( showCursor, 5000, 1, false )
	updateAddictWindow ()
end
addEvent ( "showAddictInfo", true )
addEventHandler ( "showAddictInfo", getRootElement(), showAddictInfo_func )

function updateAddictWindow ()
	dgsSetText ( gLabel["cigarettLevel"], getCigarettAddictLevel ( localPlayer ) )
	dgsSetText ( gLabel["alcLevel"], getAlcoholAddictLevel ( localPlayer ) )
	dgsSetText ( gLabel["drugLevel"], getDrugAddictLevel ( localPlayer ) )
	
	dgsProgressBarSetProgress ( gProgress["cigFlush"], getCigarettProgress () )
	dgsProgressBarSetProgress ( gProgress["alcFlush"], getAlcoholProgress () )
	dgsProgressBarSetProgress ( gProgress["drugFlush"], getDrugProgress () )
end

function getAlcoholProgress ()
	local curFlush = vioClientGetElementData ( "alcoholAddictPoints" )
	local max = addictLevelDivisors[2] * 5 * 5
	local lvl = 100 - max / ( curFlush )
	if lvl > 100 then
		lvl = 100
	end
	return lvl
end

function getCigarettProgress ()
	local lvl = ( vioClientGetElementData ( "cigarettFlushPoints" ) ) * 10
	if lvl > 100 then
		lvl = 100
	end
	return lvl
end

function getDrugProgress ()
	local lvl = vioClientGetElementData ( "drugFlushPoints" ) * 5
	if lvl > 100 then
		lvl = 100
	end
	return lvl
end