--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local promptTimeToHide = 0

function prompt_func ( text, time )

	showCursor ( true )
	gWindow["promptWindow"] = dgsCreateWindow(screenwidth/2-363/2,screenheight/2-292/2,363,292,"Wichtige Informationen",false)
	dgsWindowSetSizable ( gWindow["promptWindow"], false )
	dgsWindowSetMovable ( gWindow["promptWindow"], false )
	dgsBringToFront ( gWindow["promptWindow"] )
	local img = dgsCreateImage(86,54,190,170,":"..getResourceName(getThisResource()).."/images/prompt.png",false,gWindow["promptWindow"])

	gLabel["promptText"] = dgsCreateLabel(11,26,343,223,text,false,gWindow["promptWindow"])
	dgsLabelSetColor(gLabel["promptText"],255,255,255)
	dgsLabelSetVerticalAlign(gLabel["promptText"],"top")
	dgsLabelSetHorizontalAlign(gLabel["promptText"],"left",false)
	dgsSetFont(gLabel["promptText"],"default-bold")
	timeLabel = dgsCreateLabel(19,261,330,21,"Dieses Fenster schliesst sich automatisch in "..time.." Sekunden.",false,gWindow["promptWindow"])
	dgsLabelSetColor(timeLabel,200,0,0)
	dgsLabelSetVerticalAlign(timeLabel,"top")
	dgsLabelSetHorizontalAlign(timeLabel,"left",false)
	dgsSetFont(timeLabel,"default-bold")

	promptTimeToHide = time

	time = time + 1
	setTimer (
		function ( timeLabel )
			dgsSetText ( timeLabel, "Dieses Fenster schliesst sich automatisch in "..promptTimeToHide.." Sekunden." )
			promptTimeToHide = promptTimeToHide - 1
		end,
	1000, time, timeLabel )
	setTimer ( destroyElement, time*1000+1000, 1, gWindow["promptWindow"] )
	setTimer ( showCursor, time*1000+1000, 1, false )
end
addEvent ( "prompt", true )
addEventHandler ( "prompt", getRootElement(), prompt_func )
