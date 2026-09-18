--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local tacticsMarker = createMarker(-2226.8,252.1,35.3,"corona",1.1,255,255,255,160)

addEventHandler("onMarkerHit",tacticsMarker,function(client)
	if not isPedInVehicle(client) then
		if not isPedDead(client) then
			if not isAbleOffduty ( client ) then 
				if tonumber(MtxGetElementData(client,"playingtime")) >= 180 then
					if tonumber(MtxGetElementData(client,"wanteds")) == 0 then
						triggerClientEvent(client,"createTacticWindow",client)
					else infobox(client,"Da du Wanteds hast, kannst du die Tactic-Arena nicht betreten!")end
				else infobox(client,"Du musst 3 Spielstunden haben!")end
			else infobox(client,"Du bist noch im Dienst!")end
		end
	end
end)

local tacticsDim = 10
local tacticStop = false
local tacticTime = {}
local tacticCounter = 0

local tacticStaatSpawns={
-- x,y,z,rot,int
["LVPD"] = {238.60000610352,142.60000610352,1003,0,3},
["Jizzys"] = {-2688.1000976563,1424.1999511719,906.5,0,3},
["Motel"] = {2195.1999511719,-1143.0999755859,1029.8000488281,0,15},
["Battlefield"] = {-1131.3000488281,1036.3000488281,1345.6999511719,0,10},
}

local tacticUntergrundSpawns={
-- x,y,z,rot,int
["LVPD"] = {298,175.39999389648,1007.200012207,90,3},
["Jizzys"] = {-2633.5,1395.4000244141,906.5,0,3},
["Motel"] = {2219.3999023438,-1153.6999511719,1025.8000488281,0,15},
["Battlefield"] = {-975.29998779297,1070,1345,0,10},
}

local tacticMaps={
[1]="LVPD",
[2]="Jizzys",
[3]="Motel",
[4]="Battlefield",
}

local rdmStaatSkins = {[1]=280,[2]=246,[3]=283,[4]=288}
local rdmGangSkins = {[1]=300,[2]=298,[3]=247,[4]=195}
local MAX_PLAYERS_PER_MAP = 5

addEvent("requestTacticMaps", true)
addEventHandler("requestTacticMaps", root, function()
    
    if not client or getElementType(client) ~= "player" then return end
    
    local mapNames = {}
    
    if type(tacticMaps) == "table" then
        for _, name in ipairs(tacticMaps) do
            table.insert(mapNames, name)
        end
    end
   
    triggerClientEvent(client, "receiveTacticMaps", client, mapNames)
end)
addEvent("joinTacticsTeam",true)
addEventHandler("joinTacticsTeam",root,function(team, selectedMap) 

	local mapIsValid = false
	for _, validMap in ipairs(tacticMaps) do
		if validMap == selectedMap then
			mapIsValid = true
			break
		end
	end
	
	if not mapIsValid then
		infobox(client, "Ungültige Map ausgewählt!")
		return
	end

	if tacticsoffon then
		outputChatBox("Die Tactic Arena ist geschlossen",client,255,0,0)
		return false
	end
	
	local playerCountInMap = 0
    for _, player in ipairs(getElementsByType("player")) do
        if getElementData(player, "inTactic") == true and getElementData(player, "currentTacticMap") == selectedMap then
            playerCountInMap = playerCountInMap + 1
        end
    end
    
    if playerCountInMap >= MAX_PLAYERS_PER_MAP then
        infobox(client, "Die Map **'" .. selectedMap .. "'** ist bereits **voll** (" .. MAX_PLAYERS_PER_MAP .. " Spieler).")
        return
    end
	
	outputChatBox("Du kannst die Arena mit /leavetactic wieder verlassen.",client,255,255,255)
	outputChatBox("Du kannst die Arena mit /leave wieder verlassen.",client,255,255,255)
	tacticCounter = tacticCounter + 1
	
	setElementData(client,"inTactic",true)
	setElementData(client,"tacticTeam",tostring(team))
	setElementData(client,"currentTacticMap",selectedMap)
	-- Stand beim Betreten merken, damit die Live-Anzeige im Match bei 0 startet,
	-- ohne den dauerhaften TacticKills/TacticTode-Stat selbst anzufassen.
	setElementData(client,"TacticKillsBaseline", getElementData(client,"TacticKills") or 0)
	setElementData(client,"TacticTodeBaseline", getElementData(client,"TacticTode") or 0)

	local x,y,z,rot,int,skin 

	if getElementData(client,"tacticTeam") == "staat" then
		rdmSkin = math.random(1,4)
		skin=rdmStaatSkins[rdmSkin]
		x,y,z,rot,int = tacticStaatSpawns[selectedMap][1],tacticStaatSpawns[selectedMap][2],tacticStaatSpawns[selectedMap][3],tacticStaatSpawns[selectedMap][4],tacticStaatSpawns[selectedMap][5]
		setElementRotation(client,0,0,90)
	elseif getElementData(client,"tacticTeam") == "gang" then
		local rdmSkin = math.random(1,4)
		skin=rdmGangSkins[rdmSkin]
		x,y,z,rot,int = tacticUntergrundSpawns[selectedMap][1],tacticUntergrundSpawns[selectedMap][2],tacticUntergrundSpawns[selectedMap][3],tacticUntergrundSpawns[selectedMap][4],tacticUntergrundSpawns[selectedMap][5]
		setElementRotation(client,0,0,90)
	end
	
	if tacticStop == false then
		MtxSetElementData(client,"spawnProtection",false)
		spawnPlayer(client,x,y,z,rot,skin,int,tacticsDim)
		triggerClientEvent ( client, "startGame", client, "startGame" )
		setElementModel(client,skin)
		setPedArmor(client, math.min(getPedArmor(client) + 100, 100))
		giveTacticWeapons(client)
		TacticPlayer(nil,nil)
	else
		tacticTime[client] = setTimer(function()
			MtxSetElementData(client,"spawnProtection",false)
			spawnPlayer(client,x,y,z,rot,skin,int,tacticsDim)
			triggerClientEvent ( client, "startGame", client, "startGame" )
			setElementModel(client,skin)
			setPedArmor(client, math.min(getPedArmor(client) + 100, 100))
			giveTacticWeapons(client)
		end,5000,1)
	end
end)


function leavetactic(client)
	if getElementData(client,"inTactic") == true then
		spawnPlayer(client,-2228.7,252.3,35.3,90,tonumber(MtxGetElementData(client,"skinid")),0,0)
		setElementData(client,"inTactic",false)
		setElementData(client,"tacticTeam",nil)
		setElementData(client,"currentTacticMap",nil)
		tacticCounter = tacticCounter - 1
		takeAllWeapons(client)
		--setElementData(client,"TacticKills",0)
		--setElementData(client,"TacticTode",0)
	end
end
addCommandHandler("leavetactic",leavetactic)
addCommandHandler("leave",leavetactic)

function respawnTacticMode(client)
	local currentMap = getElementData(client,"currentTacticMap")
	if not currentMap then 
		leavetactic(client)
		return 
	end

	local x,y,z,rot,int,skin

	if getElementData(client,"tacticTeam") == "staat" then
		local rdmSkin = math.random(1,4)
		skin = rdmStaatSkins[rdmSkin]
		x,y,z,rot,int = tacticStaatSpawns[currentMap][1],tacticStaatSpawns[currentMap][2],tacticStaatSpawns[currentMap][3],tacticStaatSpawns[currentMap][4],tacticStaatSpawns[currentMap][5]
		setElementRotation(client,0,0,90)
	elseif getElementData(client,"tacticTeam") == "gang" then
		local rdmSkin = math.random(1,4)
		skin = rdmGangSkins[rdmSkin]
		x,y,z,rot,int = tacticUntergrundSpawns[currentMap][1],tacticUntergrundSpawns[currentMap][2],tacticUntergrundSpawns[currentMap][3],tacticUntergrundSpawns[currentMap][4],tacticUntergrundSpawns[currentMap][5]
		setElementRotation(client,0,0,90)
	end
	spawnPlayer(client,x,y,z,rot,skin,int,tacticsDim)
	triggerClientEvent ( client, "startGame", client, "startGame" )
	setElementModel(client,skin)
	setPedArmor(client, math.min(getPedArmor(client) + 100, 100))
	giveTacticWeapons(client)
	setPedHeadless(client,false)
end

addEventHandler("onPlayerQuit",root,function()
	if MtxGetElementData(source,"inTactic") == true then
		tacticCounter = tacticCounter - 1
		takeAllWeapons(source)
		if isTimer(tacticTime[source]) then
			killTimer(tacticTime[source])
		end
	end
end)

function giveTacticWeapons(client)
	takeAllWeapons(client)
	giveWeapon(client,24,9999,true)
	giveWeapon(client,29,9999,true)
	giveWeapon(client,31,9999,true)
	giveWeapon(client,33,9999,true)
end

function TacticPlayer(kill,killer)
	if isElement( killer ) and killer ~= source and getElementType ( killer ) == "player" then
		if getElementData(killer,"inTactic") == true and getElementData(killer,"tacticTeam") then
			if kill then
				setElementData(killer,"TacticKills",getElementData(killer,"TacticKills") + 1 )
				MtxSetElementData ( killer, "coins", tonumber(MtxGetElementData ( killer, "coins" )) + 5 )
				outputChatBox("Du erhältst 5 Coins pro Kill",killer,43,255,0)
				AchievmentTactic(killer)
				-- Nach einem Kill starten beide Spieler wieder am Spawn (statt
				-- dass der Killer nur geheilt an Ort und Stelle weiterspielt).
				respawnTacticMode(killer)
			end
			setElementData(source,"TacticTode",getElementData(source,"TacticTode") + 1 )
		end
	end
end
addEventHandler("onPlayerWasted",root,TacticPlayer)

function AchievmentTactic(killer)
	if getElementData(killer,"inTactic") == true and getElementData(killer,"tacticTeam") and getElementData(killer,"TacticKills") == 10 then
		triggerClientEvent ( killer, "showAchievmentBox", killer, "Du hast in der tactic Arena 10 Leute gekillt", 10, 10000 )
		MtxSetElementData ( killer, "coins", tonumber(MtxGetElementData ( killer, "coins" )) + 100 )
		outputChatBox("Du erhältst 100 Coins",killer,43,255,0)
		dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "achievments", "TactickillCoin", 1, "UID", playerUID[getPlayerName(killer)] )
	end
end


function tacticsoffon ( client )
	if ( tonumber ( MtxGetElementData ( client, "adminlvl" ) ) or 0 ) >= 6 and getPlayerName(client) == "Emre" then
	    if tacticsoffon == false then
			tacticsoffon = true
			outputChatBox ("Die Tactic Arena ist zurzeit geschlossen!",root, 255, 0, 0 )
		else
			tacticsoffon = false
			outputChatBox ("Die Tactic Arena ist jetzt wieder geöffnet!", root, 255, 120, 0 )
		end
	end
end
addCommandHandler("tc",tacticsoffon)