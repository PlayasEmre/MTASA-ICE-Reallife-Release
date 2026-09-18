--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local skillBars = 0

-- fullState [0-1]
function createSkillBar ( fullState, parent, x, y, width, height )

	skillBars = skillBars + 1
	if not width then
		width = 77
		height = 21
	end
	side = ( width * 6 / 77 )
	barMaxWidth = width - side * 2 -- Middle Bar
	barSize = barMaxWidth * fullState
	
	gImage["skillBar"..skillBars] = dgsCreateImage ( x, y, width, height, ":"..getResourceName(getThisResource()).."/images/skills/bg.png", false, parent )

	dgsCreateImage ( side, 0, barSize, height, ":"..getResourceName(getThisResource()).."/images/skills/px.png", false, gImage["skillBar"..skillBars] )
	dgsCreateImage ( barSize + side, 0, 77 / width * 6, height, ":"..getResourceName(getThisResource()).."/images/skills/cur.png", false, gImage["skillBar"..skillBars] )
	dgsCreateImage ( 0, 0, width, height, ":"..getResourceName(getThisResource()).."/images/skills/bar.png", false, gImage["skillBar"..skillBars] )
	
	return gImage["skillBar"..skillBars]
end
addEvent ( "createSkillBar", true )
addEventHandler ( "createSkillBar", getRootElement(), createSkillBar )

function showSkillInfo_func ( text, fullState, left, cur )

	gImage["skillBG"] = dgsCreateImage( 3 * 2 + 235,3,102,79,":"..getResourceName(getThisResource()).."/images/colors/c_red.jpg",false)

	local bar = createSkillBar ( fullState, gImage["skillBG"], 12, 24, 77, 21 )

	if text == "Spielskills:" then
		gLabel[1] = dgsCreateLabel(5,4,81,14,"Spielskills:",false,gImage["skillBG"])
		dgsLabelSetColor(gLabel[1],0,0,0,255)
		dgsLabelSetVerticalAlign(gLabel[1],"top")
		dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
		dgsSetFont(gLabel[1],"default-bold")
		gLabel[2] = dgsCreateLabel(8,49,90,28,"Noch "..left.." $\nbis zu LVL "..(cur+1),false,gImage["skillBG"])
		dgsLabelSetColor(gLabel[2],0,0,0,255)
		dgsLabelSetVerticalAlign(gLabel[2],"top")
		dgsLabelSetHorizontalAlign(gLabel[2],"left",false)
		dgsSetFont(gLabel[2],"default-bold")
	else
		gLabel[1] = dgsCreateLabel(5,4,81,14,"Angelskill:",false,gImage["skillBG"])
		dgsLabelSetColor(gLabel[1],0,0,0,255)
		dgsLabelSetVerticalAlign(gLabel[1],"top")
		dgsLabelSetHorizontalAlign(gLabel[1],"left",false)
		dgsSetFont(gLabel[1],"default-bold")
		gLabel[2] = dgsCreateLabel(8,49,90,28,"Noch "..left.." Fische\nbis zu LVL "..(cur+1),false,gImage["skillBG"])
		dgsLabelSetColor(gLabel[2],0,0,0,255)
		dgsLabelSetVerticalAlign(gLabel[2],"top")
		dgsLabelSetHorizontalAlign(gLabel[2],"left",false)
		dgsSetFont(gLabel[2],"default-bold")
	end
	setTimer ( destroyElement, 5000, 1, gImage["skillBG"] )
end
addEvent ( "showSkillInfo", true )
addEventHandler ( "showSkillInfo", getRootElement(), showSkillInfo_func )