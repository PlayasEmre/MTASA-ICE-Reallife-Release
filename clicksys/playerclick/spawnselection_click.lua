--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

spawnPointListCMD1 = {
 ["Noobspawn"]="noobspawn",
 ["Haus"]="house",
 ["Basis"]="faction",
 
 ["SFPD"]="faction",
 ["LVPD"]="faction",
 
 ["Ranch"]="faction",
 ["Caligulas Casino"]="faction",
 
 ["Chinatown"]="faction",
 ["Four Dragons"]="faction",
 
 ["SF Basis"]="faction",
 
 ["Striplokal"]="faction",
 
 ["Flugzeugträger"]="faction",
 ["Area 51"]="faction",

 ["Angel Pine"]="faction",
 ["Clubgelände"]="faction",
 
 ["Hier"]="hier",
 ["Mistys Bar"]="bar",
 ["Yacht"]="boat",
 ["Wohnwagen"]="wohnmobil",
 
 ["Hotel ( SF )"]="hotel",
 ["Hotel ( LV )"]="hotel"
 }

spawnPointListCMD2 = {
 ["Noobspawn"]="",
 ["Haus"]="",
 ["Basis"]="",
 
 ["SFPD"]="sf",
 ["LVPD"]="lv",
 
 ["Ranch"]="sf",
 ["Caligulas Casino"]="lv",
 
 ["Chinatown"]="sf",
 ["Four Dragons"]="lv",
 
 ["SF Basis"]="sf",
 
 ["Striplokal"]="strip",
 
 ["Flugzeugträger"]="sf",
 ["Area 51"]="lv",
 
 ["Angel Pine"]="sf",
 ["Clubgelände"]="lv",

 ["Hier"]="",
 ["Mistys Bar"]="",
 ["Yacht"]="",
 ["Wohnwagen"]="",
 
 ["Hotel ( SF )"]="sf",
 ["Hotel ( LV )"]="lv"
 }

factionsInBothCitys = {
 [1]=true, -- SFPD
 [2]=true, -- Mafia
 [3]=true, -- Triaden
 [6]=true, -- FBI
 [7]=true, -- Aztecas
 [8]=true, -- Army
 [9]=true  -- AoD
 }

function showSpawnSelection ()

	showCursor ( true )
	if isElement ( gWindow["spawnPointSelection"] ) then
		dgsSetVisible ( gWindow["spawnPointSelection"], true )
		dgsBringToFront ( gWindow["spawnPointSelection"] )
	else
		gWindow["spawnPointSelection"] = dgsCreateWindow(screenwidth/2-281/2,120,281,287,"SpawnPoint menue",false)		dgsBringToFront(gWindow["spawnPointSelection"])
		dgsWindowSetCloseButtonEnabled(gWindow["spawnPointSelection"], false)
		dgsSetAlpha(gWindow["spawnPointSelection"],1)
		dgsWindowSetMovable ( gWindow["spawnPointSelection"], false )
		dgsWindowSetSizable ( gWindow["spawnPointSelection"], false )
		gGrid["availableSpawnPoints"] = dgsCreateGridList(9,8,128,253,false,gWindow["spawnPointSelection"])
		dgsGridListSetSelectionMode(gGrid["availableSpawnPoints"],1)
		gColumn["spawnPoint"] = dgsGridListAddColumn(gGrid["availableSpawnPoints"],"Startpunkt",0.8)
		dgsSetAlpha(gGrid["availableSpawnPoints"],1)
		gButton["changeSpawnPoint"] = dgsCreateButton(145,90,126,69,"Als Start- und\nWieder-\neinstiegspunkt festlegen",false,gWindow["spawnPointSelection"],nil,nil,nil,nil,nil,nil,tocolor(46,110,255,255),tocolor(123,163,255,255),tocolor(24,74,199,255))
		dgsSetAlpha(gButton["changeSpawnPoint"],1)
		dgsSetFont(gButton["changeSpawnPoint"],"default-bold")
		
		addEventHandler ( "onDgsMouseClickUp", gButton["changeSpawnPoint"],
			function (button)
			if button == "left" then
				local row, column = dgsGridListGetSelectedItem ( gGrid["availableSpawnPoints"] )
				if row == -1 then return end
				local text = dgsGridListGetItemText ( gGrid["availableSpawnPoints"], row, column )
				local cmd1 = spawnPointListCMD1[text]
				local cmd2 = spawnPointListCMD2[text]
					if cmd1 then
						triggerServerEvent ( "changeSpawnPosition", lp, cmd1, cmd2 )
					end
				end
			end,
		false )
	end
	fillSpawnPointList ()
end

function fillSpawnPointList ()

	dgsGridListClear ( gGrid["availableSpawnPoints"] )
	
	local row
	-- Noobspawn --
	row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
	dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Noobspawn", false, false )
	-- Haus --
	if vioClientGetElementData ( "housekey" ) ~= 0 then
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Haus", false, false )
	end
	-- Fraktion --
	local fraktion = getElementData ( lp, "fraktion" )
	if fraktion == 1 then
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "SFPD", false, false )
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "LVPD", false, false )
	elseif fraktion == 2 then
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Ranch", false, false )
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Caligulas Casino", false, false )
	elseif fraktion == 3 then
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Chinatown", false, false )
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Four Dragons", false, false )
	elseif fraktion == 6 then
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "SF Basis", false, false )
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "LVPD", false, false )
	elseif fraktion == 7 then
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Basis", false, false )
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Striplokal", false, false )
	elseif fraktion == 8 then
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Flugzeugträger", false, false )
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Area 51", false, false )
	elseif fraktion == 9 then
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Angel Pine", false, false )
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Clubgelände", false, false )
	elseif fraktion > 0 then
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Basis", false, false )
	end
	-- Admin --
	if getElementData ( lp, "adminlvl" ) >= 1 then
		row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
		dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Hier", false, false )
	end
	-- Yacht --
	row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
	dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Yacht", false, false )
	-- Wohnwagen --
	row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
	dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Wohnwagen", false, false )

	-- Hotels --
	row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
	dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Hotel ( SF )", false, false )
	row = dgsGridListAddRow ( gGrid["availableSpawnPoints"] )
	dgsGridListSetItemText ( gGrid["availableSpawnPoints"], row, gColumn["spawnPoint"], "Hotel ( LV )", false, false )
end