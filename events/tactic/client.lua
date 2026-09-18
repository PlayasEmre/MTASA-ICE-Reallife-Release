local GLOBALscreenX, GLOBALscreenY = guiGetScreenSize()
local TACTICS_DIMENSION = 10

local COLOR_STAAT = "#3296FF" 
local COLOR_GANG = "#FF3232" 	
local COLOR_KILLS = "#32FF32" 	
local COLOR_DEATHS = "#FF6464" 	
local COLOR_WHITE = "#FFFFFF" 	
local COLOR_BG = tocolor(0, 0, 0, 150)

local Tactic = {Window={},Button={},Gridlist={},GridlistColumn={},Label={},Edit={},Image={},Tabpanel={},Tab={},}

local countdownTime = 3
local screenWidth, screenHeight = GLOBALscreenX, GLOBALscreenY
local isCountdownActive = false
local toggleControls = {"fire","aim_weapon", "next_weapon", "previous_weapon", "forwards", "backwards", "left", "right"}
local startTime = 0
local countdownsounddone = {}


createBlip(-2227.7705078125, 255.875, 35.3203125,6,1)

local function createTacticGUI()

	if getElementData(localPlayer,"ElementClicked") == false then
		showCursor(true)
		setElementData(localPlayer,"ElementClicked",true)
		

		Tactic.Window[1]=dgsCreateWindow(GLOBALscreenX/2-500/2,GLOBALscreenY/2-320/2,500,320,Tables.servername.." - Tacticarena (TDM)",false)
		dgsWindowSetCloseButtonEnabled(Tactic.Window[1], false)
		dgsWindowSetSizable(Tactic.Window[1],false)
		dgsWindowSetMovable(Tactic.Window[1],false)
		

		Tactic.Button[1]=dgsCreateButton(474,-25,26,25,"×",false,Tactic.Window[1],nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
		dgsSetProperty(Tactic.Button[1],"textSize",{1.6,1.6})
		

		dgsCreateLabel(10,10,480,20,"ACHTUNG: Beim Betreten der Tactic Arena verlierst du alle deine Waffen.",false,Tactic.Window[1])
		

		local mapHeaderLabel = dgsCreateLabel(10,40,480,20,"Wähle eine Map aus:",false,Tactic.Window[1])
		dgsLabelSetColor(mapHeaderLabel, 63, 160, 224)
		dgsSetFont(mapHeaderLabel, "default-bold")
		Tactic.Gridlist[1] = dgsCreateGridList(10, 60, 480, 100, false, Tactic.Window[1])
		Tactic.GridlistColumn[1] = dgsGridListAddColumn(Tactic.Gridlist[1], "Map", 0.9)
		

		triggerServerEvent("requestTacticMaps", root)


		local teamHeaderLabel = dgsCreateLabel(10,170,480,20,"Wähle ein Team aus.",false,Tactic.Window[1])
		dgsLabelSetColor(teamHeaderLabel, 63, 160, 224)
		dgsSetFont(teamHeaderLabel, "default-bold")
		

		Tactic.Button[2]=dgsCreateButton(10,190,480,40,"Staat",false,Tactic.Window[1],nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
		Tactic.Button[3]=dgsCreateButton(10,240,480,40,"Gang",false,Tactic.Window[1],nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
		

		local function closeGUIAndJoinTeam(team)
			if not Tactic.Gridlist[1] or not isElement(Tactic.Gridlist[1]) then
				return outputChatBox("FEHLER: Map-Liste ist ungültig. Bitte erneut versuchen.", 255, 50, 50)
			end
			
			local selectedRow = dgsGridListGetSelectedItem(Tactic.Gridlist[1])
			
			if not selectedRow or selectedRow == -1 then
				return outputChatBox("Fehler: Bitte wähle zuerst eine Map aus!", 255, 50, 50)
			end
			
			local mapName = dgsGridListGetItemText(Tactic.Gridlist[1], selectedRow, 1)
			
			dgsCloseWindow(Tactic.Window[1])
			showCursor(false)
			setElementData(localPlayer,"ElementClicked",false)
			
			triggerServerEvent("joinTacticsTeam",localPlayer, team, mapName) 
		end

		addEventHandler("onDgsMouseClickUp",Tactic.Button[3],
			function(button)
				if button == "left" then
					closeGUIAndJoinTeam("gang")
				end
			end,
		false)
		
		addEventHandler("onDgsMouseClickUp",Tactic.Button[2],
			function(button)
				if button == "left" then
					closeGUIAndJoinTeam("staat")
				end
			end,
		false)
		
		addEventHandler("onDgsMouseClickUp",Tactic.Button[1],
			function(button)
				if button == "left" then
					dgsCloseWindow(Tactic.Window[1])
					showCursor(false)
					setElementData(localPlayer,"ElementClicked",false)
				end
			end,
		false)
	end
end

addEvent("createTacticWindow",true)
addEventHandler("createTacticWindow",root,function()
	setTimer(createTacticGUI, 100, 1)
end)


function receiveTacticMaps(mapsTable)
	if Tactic.Gridlist[1] and isElement(Tactic.Gridlist[1]) then
		if type(mapsTable) == "table" then
			dgsGridListClear(Tactic.Gridlist[1])
			for _, mapName in ipairs(mapsTable) do
				local row = dgsGridListAddRow(Tactic.Gridlist[1])
				dgsGridListSetItemText(Tactic.Gridlist[1], row, 1, mapName, false, false) 
			end
			if #mapsTable > 0 then
				dgsGridListSetSelectedItem(Tactic.Gridlist[1], 1)
			end
		end
	end
end
addEvent("receiveTacticMaps", true)
addEventHandler("receiveTacticMaps", root, receiveTacticMaps)


local tacticListCache = {}
local tacticListCacheAt = 0

function renderTacticUserList()
	if getElementData(localPlayer, "inTactic") == true and getElementData(localPlayer, "loggedin") == 1 then

		local localPlayerMap = getElementData(localPlayer, "currentTacticMap")

		if localPlayerMap and getElementDimension(localPlayer) == TACTICS_DIMENSION then

			local LIST_START_X = 20 * Gsx
			local LIST_START_Y = 420 * Gsy
			local ROW_HEIGHT = 24 * Gsy
			local LIST_WIDTH = 450 * Gsx

			local now = getTickCount()
			if now - tacticListCacheAt >= 250 then
				tacticListCacheAt = now

				local playersToDisplay = {}

				for i,v in ipairs(getElementsByType("player")) do
					local otherPlayerMap = getElementData(v, "currentTacticMap")

					if getElementData(v,"loggedin") == 1 and getElementDimension(v) == TACTICS_DIMENSION and getElementData(v,"inTactic") == true and otherPlayerMap == localPlayerMap then

						-- Anzeige = dauerhafter Stat minus Stand beim Arena-Betreten,
						-- damit sie pro Match bei 0 startet, ohne den Stat selbst zu aendern.
						local Kills = (tonumber(getElementData(v,"TacticKills")) or 0) - (tonumber(getElementData(v,"TacticKillsBaseline")) or 0)
						local Tode = (tonumber(getElementData(v,"TacticTode")) or 0) - (tonumber(getElementData(v,"TacticTodeBaseline")) or 0)

						table.insert(playersToDisplay, {
							element = v,
							kills = Kills,
							tode = Tode
						})
					end
				end

				table.sort(playersToDisplay, function(a, b)
					if a.kills ~= b.kills then
						return a.kills > b.kills
					else
						return a.tode < b.tode
					end
				end)

				tacticListCache = playersToDisplay
			end

			local playersToDisplay = tacticListCache
			local visibleRowsCount = math.min(#playersToDisplay, 5)
			
			if visibleRowsCount > 0 then
				dxDrawRectangle(LIST_START_X, LIST_START_Y, LIST_WIDTH, ROW_HEIGHT * visibleRowsCount + (5 * Gsy),COLOR_BG)
			end
			
			for di = 0, visibleRowsCount - 1 do
				local playerData = playersToDisplay[di + 1]
				local v = playerData.element
				local Kills = playerData.kills
				local Tode = playerData.tode
				local y_pos = LIST_START_Y + (di * ROW_HEIGHT)
				
				local playerTeam = getElementData(v, "tacticTeam")
				local teamColorHex = COLOR_WHITE
				if playerTeam == "staat" then
					teamColorHex = COLOR_STAAT
				elseif playerTeam == "gang" then
					teamColorHex = COLOR_GANG
				end

				local playerText = teamColorHex .. getPlayerName(v) .. " | " .. COLOR_KILLS .. "Kills: " .. tostring(Kills) .. COLOR_WHITE .. " - " .. COLOR_DEATHS .. "Tode: " .. tostring(Tode)
				
				dxDrawText(playerText,(30 + 5) * Gsx, y_pos,(30 + LIST_WIDTH) * Gsx, y_pos + ROW_HEIGHT,tocolor(255,255,255,255),1.35*Gsx,"default-bold","left","center",false,true,true,true)
			end
		end
	end
end
addEventHandler("onClientRender", root, renderTacticUserList)


function startCountdown()
	if isCountdownActive == false then
		isCountdownActive = true
		for _, control in ipairs(toggleControls) do
			toggleControl(control,false)
		end
		setElementFrozen(localPlayer,true)
		addEventHandler("onClientRender", root, drawCountdown)
	end
end

function drawCountdown()
	local timeLeft = math.ceil(countdownTime - (getTickCount() - startTime) / 1000)
	if timeLeft > 0 then
		textToShow = tostring(timeLeft)
	elseif timeLeft == 0 then
		textToShow = "Go"
	else
		for _, control in ipairs(toggleControls) do
			toggleControl(control,true)
		end
		removeEventHandler("onClientRender", root, drawCountdown)
		setElementFrozen(localPlayer,false)
		isCountdownActive = false
	end

	dxDrawText(textToShow, screenWidth / 2 - 20, screenHeight / 2 - 20, screenWidth / 2 + 20, screenHeight / 2 + 20, tocolor(255, 255, 255, 255), 2, "pricedown", "center", "center")

	if timeLeft <= 3 and not countdownsounddone[textToShow] then
		countdownsounddone[textToShow] = true
		playCountdownSound(textToShow)
	end
end

function playCountdownSound(textToShow)
 	local soundFile = "events/tactic/" .. textToShow .. ".mp3"
 	
 	local sound = playSound(soundFile)

 	if sound and isElement(sound) then
 		setSoundVolume(sound, 0.5)
 		setTimer(destroySound,3000,1, sound)
 	end
end

function destroySound(sound)
 	if sound and isElement(sound) then
 		destroyElement(sound)
 	end
end

function startGame()
 	if not isCountdownActive then
 		startTime = getTickCount()
 		countdownsounddone = {}
 		startCountdown()
 	end
end
addEvent("startGame", true)
addEventHandler("startGame", root, startGame)

local function PlayerDamageTactic(attacker, weapon, bodypart)
 	if getElementData(source, "inTactic") == true then
 		
 		local attackerTeam = getElementData(attacker, "tacticTeam")
 		local localPlayerTeam = getElementData(source, "tacticTeam")
 		
 		if isElement(attacker) and attackerTeam and localPlayerTeam and isCountdownActive then
 			if attackerTeam == localPlayerTeam then
 				cancelEvent()
 			end
 		end
 	end
end
addEventHandler("onClientPlayerDamage", root, PlayerDamageTactic)