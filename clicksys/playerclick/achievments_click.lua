--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function showAchievmentWindow ()
	
	gWindow["achievmentList"] = dgsCreateWindow(screenwidth/2-300/2,120,300,422,"Achievments",false)
	dgsWindowSetCloseButtonEnabled(gWindow["achievmentList"], false)
	dgsSetAlpha ( gWindow["achievmentList"], 1 )
	dgsWindowSetMovable ( gWindow["achievmentList"], false )
	dgsWindowSetSizable ( gWindow["achievmentList"], false )
	gImage[2] = dgsCreateImage(10,29,50,50,"images/pokal.bmp",false,gWindow["achievmentList"])
	gLabel[4] = dgsCreateLabel(78,33,186,47,"Hier kannst du sehen,\nwelche Achievments du bereits\nerreicht hast.",false,gWindow["achievmentList"])
	dgsLabelSetColor(gLabel[4],255,255,255)
	dgsLabelSetVerticalAlign(gLabel[4],"top")
	dgsLabelSetHorizontalAlign(gLabel[4],"left",false)
	dgsSetFont(gLabel[4],"default-bold")
	
	currentAchievments = 0

	addAchievment ( "Schlaflos in SA", vioClientGetElementData ( "schlaflosinsa" ) == "done" )
	addAchievment ( "Waffenschieber", vioClientGetElementData ( "gunloads" ) == "done" )
	addAchievment ( "Angler", vioClientGetElementData ( "angler_achiev" ) == "done" )
	addAchievment ( "Mr. License", vioClientGetElementData ( "licenses_achiev" ) == "done" )
	addAchievment ( "Der Sammler", vioClientGetElementData ( "collectr_achiev" ) == "done" )
	addAchievment ( "The Truth is out there", vioClientGetElementData ( "thetruthisoutthere_achiev" ) == "done" )
	addAchievment ( "Silent Assassin", vioClientGetElementData ( "silentassasin_achiev" ) == "done" )
	addAchievment ( "Reallife WTF?", vioClientGetElementData ( "rl_achiev" ) == "done" )
	addAchievment ( "Eigene Fuesse", vioClientGetElementData ( "own_foots" ) == "done" )
	addAchievment ( "King of the Hill", vioClientGetElementData ( "kingofthehill_achiev" ) == "done" )
	addAchievment ( "Highway to Hell", vioClientGetElementData ( "highwaytohell_achiev" ) == "done" )
	addAchievment ( "Schmied", vioClientGetElementData ( "totalHorseShoes" ) == 25 )	
	addAchievment ( "Revolverheld", vioClientGetElementData ( "revolverheld_achiev" ) == 1 )
	addAchievment ( "Chicken Dinner", vioClientGetElementData ( "chickendinner_achiev" ) == 1 )
	addAchievment ( "Nichts geht mehr", vioClientGetElementData ( "nichtsgehtmehr_achiev" ) == 1 )
	addAchievment ( "Highscore", vioClientGetElementData ( "highscore_achiev" ) )
end


function addAchievment ( text, done )

	currentAchievments = currentAchievments + 1
	local x = 11
	if currentAchievments / 2 == math.floor ( currentAchievments / 2 ) then
		x = 151
	end
	
	local y = 90 + math.floor ( currentAchievments / 2 ) * 32
	
	gLabel["achievment"..currentAchievments] = dgsCreateLabel(x,y,130,14,text,false,gWindow["achievmentList"])
	dgsLabelSetVerticalAlign(gLabel["achievment"..currentAchievments],"top")
	dgsLabelSetHorizontalAlign(gLabel["achievment"..currentAchievments],"left",false)
	dgsSetFont(gLabel["achievment"..currentAchievments],"default-bold")
	
	if done then
		dgsLabelSetColor(gLabel["achievment"..currentAchievments],0,200,0)
		gImage["achievment"..currentAchievments] = dgsCreateImage( x + 68, y + 7, 43, 21,":"..getResourceName(getThisResource()).."/images/gui/done.png",false,gWindow["achievmentList"])
	else
		dgsLabelSetColor(gLabel["achievment"..currentAchievments],200,200,0)
	end
end