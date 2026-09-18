--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function showArmyClassChoose_func ()

	showCursor ( true )
	if isElement ( gWindow["armyClasschose"] ) then
		dgsSetVisible ( gWindow["armyClasschose"], true )
		dgsBringToFront ( gWindow["armyClasschose"] )
	else
		gWindow["armyClasschose"] = dgsCreateWindow(screenwidth/2-305/2,screenheight/2-285/2,305,285,"Klassenauswahl",false)
		dgsWindowSetSizable ( gWindow["armyClasschose"], false )
		dgsWindowSetMovable ( gWindow["armyClasschose"], false )
		dgsBringToFront ( gWindow["armyClasschose"] )

		GUIEditor_Grid[1] = dgsCreateGridList(0.0295,0.0982,0.5148,0.5614,true,gWindow["armyClasschose"])
		dgsGridListSetSelectionMode(GUIEditor_Grid[1],1)
		for i = 1, 1 do
			dgsGridListAddRow(GUIEditor_Grid[1])
		end
		dgsGridListAddColumn(GUIEditor_Grid[1],"Klasse",0.2)
		dgsGridListAddColumn(GUIEditor_Grid[1],"Rang",0.2)

		GUIEditor_Button[1] = dgsCreateButton(0.2611,0.75,0.4968,0.2,"Ändern",true,GUIEditor_Grid[1], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))

		GUIEditor_Image[1] = dgsCreateImage(0.7803,0.1018,0.1639,0.1754,":"..getResourceName(getThisResource()).."/images/whiz.png",true,gWindow["armyClasschose"])

		GUIEditor_Radio[1] = dgsCreateRadioButton(0.0295,0.6772,0.3639,0.0632,"Flugzeugträger",true,gWindow["armyClasschose"])
		dgsSetFont(GUIEditor_Radio[1],"default-bold")
		GUIEditor_Radio[2] = dgsCreateRadioButton(0.0295,0.7404,0.3639,0.0632,"Area 51",true,gWindow["armyClasschose"])
		dgsSetFont(GUIEditor_Radio[2],"default-bold")
		GUIEditor_Radio[3] = dgsCreateRadioButton(0.0295,0.8035,0.3639,0.0632,"Spezial",true,gWindow["armyClasschose"])
		dgsRadioButtonSetSelected(GUIEditor_Radio[3],true)
		dgsSetFont(GUIEditor_Radio[3],"default-bold")

		GUIEditor_Label[2] = dgsCreateLabel(0.6033,0.2947,0.3246,0.0526,"Brigarde General",true,gWindow["armyClasschose"])
		dgsLabelSetColor(GUIEditor_Label[2],000,125,000,255)
		dgsLabelSetVerticalAlign(GUIEditor_Label[2],"top")
		dgsLabelSetHorizontalAlign(GUIEditor_Label[2],"left",false)
		dgsSetFont(GUIEditor_Label[2],"default-bold")

		gLabel["armyInfo1"] = dgsCreateLabel(0.1049,0.8632,0.3082,0.1123,"Nicht immer\nverfügbar!",true,gWindow["armyClasschose"])
		dgsLabelSetColor(gLabel["armyInfo1"],125,000,000,255)
		dgsLabelSetVerticalAlign(gLabel["armyInfo1"],"top")
		dgsLabelSetHorizontalAlign(gLabel["armyInfo1"],"left",false)
		dgsSetFont(gLabel["armyInfo1"],"default-bold")
		gLabel["armyInfo2"] = dgsCreateLabel(0.5672,0.4,0.4033,0.2,"Hier kannst du deine\nKlasse sowie deinen\nAnfangspunkt fest-\nlegen!",true,gWindow["armyClasschose"])
		dgsLabelSetColor(gLabel["armyInfo2"],255,255,255,255)
		dgsLabelSetVerticalAlign(gLabel["armyInfo2"],"top")
		dgsLabelSetHorizontalAlign(gLabel["armyInfo2"],"left",false)
		dgsSetFont(gLabel["armyInfo2"],"default-bold")
		gLabel["armyInfo3"] = dgsCreateLabel(0.5672,0.2351,0.2197,0.0632,"Dein Rang:",true,gWindow["armyClasschose"])
		dgsLabelSetColor(gLabel["armyInfo3"],150,150,000,255)
		dgsLabelSetVerticalAlign(gLabel["armyInfo3"],"top")
		dgsLabelSetHorizontalAlign(gLabel["armyInfo3"],"left",false)
		dgsSetFont(gLabel["armyInfo3"],"default-bold")
		gLabel["armyInfo4"] = dgsCreateLabel(0.5541,0.6596,0.4197,0.0667,"Fahrzeug Befugnisse:",true,gWindow["armyClasschose"])
		dgsLabelSetColor(gLabel["armyInfo4"],150,150,000,255)
		dgsLabelSetVerticalAlign(gLabel["armyInfo4"],"top")
		dgsLabelSetHorizontalAlign(gLabel["armyInfo4"],"left",false)
		dgsSetFont(gLabel["armyInfo4"],"default-bold")

		gMemo["armyDeko1"] = dgsCreateMemo(0.423,0.6702,0.0066,0.2982,"",true,gWindow["armyClasschose"])
		gMemo["armyDeko2"] = dgsCreateMemo(0.5541,0.6316,0.4131,0.007,"",true,gWindow["armyClasschose"])
		gMemo["armyDeko3"] = dgsCreateMemo(0.5508,0.3754,0.4098,0.007,"",true,gWindow["armyClasschose"])

		gCheck["armyVeh1"] = dgsCreateCheckBox(0.4361,0.7123,0.2754,0.0596,"Patriot",false,true,gWindow["armyClasschose"])
		dgsSetFont(gCheck["armyVeh1"],"default-bold")
		gCheck["armyVeh2"] = dgsCreateCheckBox(0.4361,0.7123+0.0894*1,0.2754,0.0596,"Baracks",false,true,gWindow["armyClasschose"])
		dgsSetFont(gCheck["armyVeh2"],"default-bold")
		gCheck["armyVeh3"] = dgsCreateCheckBox(0.4361,0.7123+0.0894*2,0.2754,0.0596,"Launch",false,true,gWindow["armyClasschose"])
		dgsSetFont(gCheck["armyVeh3"],"default-bold")
		gCheck["armyVeh4"] = dgsCreateCheckBox(0.4361,0.7123+0.0894*3,0.2754,0.0596,"Cargobob",false,true,gWindow["armyClasschose"])
		dgsSetFont(gCheck["armyVeh4"],"default-bold")
		gCheck["armyVeh5"] = dgsCreateCheckBox(0.7082,0.7123,0.2754,0.0596,"Raindance",false,true,gWindow["armyClasschose"])
		dgsSetFont(gCheck["armyVeh5"],"default-bold")
		gCheck["armyVeh6"] = dgsCreateCheckBox(0.7082,0.7123+0.0894*1,0.2754,0.0596,"Hydra",false,true,gWindow["armyClasschose"])
		dgsSetFont(gCheck["armyVeh6"],"default-bold")
		gCheck["armyVeh7"] = dgsCreateCheckBox(0.7082,0.7123+0.0894*2,0.2754,0.0596,"Hunter",false,true,gWindow["armyClasschose"])
		dgsSetFont(gCheck["armyVeh7"],"default-bold")
	end
end
addEvent ( "showArmyClassChoose", true )
addEventHandler ( "showArmyClassChoose", getRootElement(), showArmyClassChoose_func )
