--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function showChipBuy_func ()

	showCursor ( true )
	setElementClicked ( true )
	if isElement ( gWindow["chipBuy"] ) then
		dgsSetVisible ( gWindow["chipBuy"], true )
	else
		gWindow["chipBuy"] = dgsCreateWindow(screenwidth/2-229/2,screenheight/2-188/2,229,188,"Chips",false)
		dgsWindowSetMovable(gWindow["chipBuy"],false)
		dgsWindowSetSizable(gWindow["chipBuy"],false)
		gLabel[1] = dgsCreateLabel(16,21,195,31,"Hier kannst du neue Chips kaufen\noder Chips in Geld umtauschen.",false,gWindow["chipBuy"])
		dgsLabelSetColor(gLabel[1],200,200,0,255)
		dgsLabelSetVerticalAlign(gLabel[1],"top")
		dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
		dgsSetFont(gLabel[1],"default-bold")
		gLabel[2] = dgsCreateLabel(15,67,28,17,"Fuer",false,gWindow["chipBuy"])
		dgsLabelSetColor(gLabel[2],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel[2],"top")
		dgsLabelSetHorizontalAlign(gLabel[2],"left",false)
		dgsSetFont(gLabel[2],"default-bold")
		gLabel[3] = dgsCreateLabel(139,67,13,26,""..Tables.waehrung.."",false,gWindow["chipBuy"])
		dgsLabelSetColor(gLabel[3],0,200,0,255)
		dgsLabelSetVerticalAlign(gLabel[3],"top")
		dgsLabelSetHorizontalAlign(gLabel[3],"left",false)
		dgsSetFont(gLabel[3],"default-bold")
		gLabel[4] = dgsCreateLabel(156,67,56,20,"Chips",false,gWindow["chipBuy"])
		dgsLabelSetColor(gLabel[4],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel[4],"top")
		dgsLabelSetHorizontalAlign(gLabel[4],"left",false)
		dgsSetFont(gLabel[4],"default-bold")
		gImage[1] = dgsCreateImage(153,94,50,50,":"..getResourceName(getThisResource()).."/images/inventory/chip.png",false,gWindow["chipBuy"])

		gButton["chipEintauschen"] = dgsCreateButton(9,151,87,29,"Eintauschen",false,gWindow["chipBuy"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["chipClose"] = dgsCreateButton(118,151,87,29,"Schliessen",false,gWindow["chipBuy"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		gEdit["chipAmount"] = dgsCreateEdit(43,61,93,30,"",false,gWindow["chipBuy"])
		gRadio["chipsBuy"] = dgsCreateRadioButton(14,123,91,15,"kaufen",false,gWindow["chipBuy"])
		dgsSetFont(gRadio["chipsBuy"],"default-bold")
		gRadio["chipsSwap"] = dgsCreateRadioButton(13,98,91,15,"tauschen",false,gWindow["chipBuy"])
		dgsSetFont(gRadio["chipsSwap"],"default-bold")
		dgsRadioButtonSetSelected(gRadio["chipsBuy"],true)

		addEventHandler ( "onDgsMouseClickUp", gButton["chipClose"],
			function ()
				dgsSetVisible ( gWindow["chipBuy"], false )
				showCursor ( false )
				setElementClicked ( false )
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["chipEintauschen"],
			function ()
				triggerServerEvent ( "buyChips", lp, dgsGetText ( gEdit["chipAmount"] ), dgsRadioButtonGetSelected ( gRadio["chipsBuy"] ) )
			end,
		false )
	end
	dgsSetText ( gEdit["chipAmount"], "0" )
end
addEvent ( "showChipBuy", true )
addEventHandler ( "showChipBuy", getRootElement(), showChipBuy_func )
