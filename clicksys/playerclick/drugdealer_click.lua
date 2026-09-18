--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

pcall(function() loadstring(exports.DGS:dgsImportFunction())() end)

function showDrugMenue ()

	showCursor ( true )
	if isElement ( gWindow["drogenverkauf"] ) then
		dgsSetVisible ( gWindow["drogenverkauf"], true )
	else
		gWindow["drogenverkauf"] = dgsCreateImage(screenwidth/2-255/2, 145,255,119,":"..getResourceName(getThisResource()).."/images/background.png",false)
		gLabel["drogen"] = dgsCreateLabel(14,30,109,18,"Drogen (in gramm)",false,gWindow["drogenverkauf"])
		dgsLabelSetColor(gLabel["drogen"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["drogen"],"top")
		dgsLabelSetHorizontalAlign(gLabel["drogen"],"left",false)
		dgsSetFont(gLabel["drogen"],"default-bold")
		gEdit["drogenanzahl"] = dgsCreateEdit(41,58,59,20,"",false,gWindow["drogenverkauf"])
		gButton["verkaufen"] = dgsCreateButton(86,92,72,18,"Geben",false,gWindow["drogenverkauf"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["abbrechen"] = dgsCreateButton(225,25,20,20,"X",false,gWindow["drogenverkauf"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
	end
	addEventHandler("onDgsMouseClickUp", gButton["verkaufen"], givedrugs, false)
	addEventHandler("onDgsMouseClickUp", gButton["abbrechen"], closeDrugWindow, false)
end

function givedrugs (button)

	if button ~= nil and button ~= "left" then return end
	local target = vioClientGetElementData ( "curclicked" )
	triggerServerEvent ( "givedrugs", root, localPlayer, "cmd", target, tonumber ( dgsGetText ( gEdit["drogenanzahl"] ) ) )
end

function closeDrugWindow(button)

	if button ~= nil and button ~= "left" then return end
	dgsSetVisible(gWindow["drogenverkauf"],false)
	showCursor(false)
end
