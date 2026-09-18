--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Feature: ATM-Hack-Minispiel (Kurzschluss)       ||
--\\                                                  //

-- Kurzschluss-Minispiel: 4 farbige Kabel muessen links nach rechts auf die
-- passende Farbe verbunden werden, bevor die Zeit ablaeuft. Reines dxDraw +
-- eigene Klick-Erkennung, keine GUI-Library noetig.

local screenW, screenH = guiGetScreenSize ()

local COL_BG = tocolor ( 10, 10, 12, 235 )
local COL_BORDER = tocolor ( 200, 60, 60, 255 )
local COL_TEXT = tocolor ( 235, 240, 250, 255 )
local COL_TEXT_DIM = tocolor ( 170, 180, 205, 255 )

local WIRE_COLORS = {
	{ name = "red",    col = tocolor(220,60,60,255) },
	{ name = "blue",   col = tocolor(60,140,220,255) },
	{ name = "green",  col = tocolor(70,200,110,255) },
	{ name = "yellow", col = tocolor(230,200,60,255) },
}

local minigameActive = false
local timeLimit = 20
local endsAt = 0
local leftOrder, rightOrder = {}, {}
local connected = {} -- [colorIndex] = true
local draggingFrom = nil -- colorIndex, waehrend man von einem linken Knoten zieht

local NODE_R = 16
local PANEL_W, PANEL_H = 420, 320
local PANEL_X, PANEL_Y = (screenW-PANEL_W)/2, (screenH-PANEL_H)/2

local function shuffledIndices ()
	local t = { 1, 2, 3, 4 }
	for i = #t, 2, -1 do
		local j = math.random ( i )
		t[i], t[j] = t[j], t[i]
	end
	return t
end

local function nodePositions ( order )
	local positions = {}
	for slot, colorIndex in ipairs ( order ) do
		positions[colorIndex] = PANEL_Y + 70 + (slot-1) * 55
	end
	return positions
end

local leftY, rightY = {}, {}

local function resetMinigame ()
	leftOrder = shuffledIndices ()
	rightOrder = shuffledIndices ()
	leftY = nodePositions ( leftOrder )
	rightY = nodePositions ( rightOrder )
	connected = {}
	draggingFrom = nil
end

local function isAllConnected ()
	for i = 1, 4 do
		if not connected[i] then return false end
	end
	return true
end

local function endMinigame ( success )
	if not minigameActive then return end
	minigameActive = false
	showCursor ( false )
	guiSetInputMode ( "allow_binds" )
	triggerServerEvent ( "atmHackMinigameResult", localPlayer, success )
end

addEvent ( "startAtmHackMinigame", true )
addEventHandler ( "startAtmHackMinigame", root, function ( seconds )
	timeLimit = seconds or 20
	endsAt = getTickCount () + timeLimit * 1000
	resetMinigame ()
	minigameActive = true
	showCursor ( true )
	guiSetInputMode ( "no_binds" )
	outputChatBox ( "Verbinde die Kabel mit der passenden Farbe, bevor die Zeit ablaeuft!", 220, 160, 40 )
end )

local function getHoveredNode ( side, px, py )
	local x = ( side == "left" ) and PANEL_X + 40 or PANEL_X + PANEL_W - 40
	local yTable = ( side == "left" ) and leftY or rightY
	for colorIndex, y in pairs ( yTable ) do
		if math.abs ( px - x ) <= NODE_R and math.abs ( py - y ) <= NODE_R then
			return colorIndex
		end
	end
	return nil
end

-- Wichtig: bindKey("mouse1",...) wuerde durch guiSetInputMode("no_binds")
-- (siehe oben, blockiert waehrend des Minispiels alle Steuerungen) mit
-- deaktiviert werden - deshalb hier onClientClick statt bindKey, das ist ein
-- echtes Maus-Klick-Event und von diesem Modus nicht betroffen.
addEventHandler ( "onClientClick", root, function ( button, state, absoluteX, absoluteY )
	if not minigameActive then return end
	if button ~= "left" then return end
	if not absoluteX then return end

	if state == "down" then
		local leftHit = getHoveredNode ( "left", absoluteX, absoluteY )
		if leftHit and not connected[leftHit] then
			draggingFrom = leftHit
		end
	elseif state == "up" then
		if not draggingFrom then return end

		local rightHit = getHoveredNode ( "right", absoluteX, absoluteY )
		if rightHit == draggingFrom then
			connected[draggingFrom] = true
			draggingFrom = nil
			if isAllConnected () then
				endMinigame ( true )
			end
		else
			-- Falsche Farbe getroffen oder daneben losgelassen - Kabel faellt
			-- einfach zurueck, kein Fehlschlag/Strafe.
			draggingFrom = nil
		end
	end
end )

addEventHandler ( "onClientRender", root, function ()
	if not minigameActive then return end

	local now = getTickCount ()
	local remaining = math.max ( 0, endsAt - now )
	if remaining <= 0 then
		endMinigame ( false )
		return
	end

	dxDrawRectangle ( PANEL_X, PANEL_Y, PANEL_W, PANEL_H, COL_BG )
	dxDrawRectangle ( PANEL_X, PANEL_Y, PANEL_W, 4, COL_BORDER )
	dxDrawText ( "Kurzschluss - Kabel verbinden", PANEL_X, PANEL_Y+10, PANEL_X+PANEL_W, PANEL_Y+34, COL_TEXT, 1.15, "default-bold", "center", "center" )
	dxDrawText ( math.ceil ( remaining/1000 ).."s", PANEL_X, PANEL_Y+34, PANEL_X+PANEL_W, PANEL_Y+54, tocolor(230,200,60,255), 1.0, "default-bold", "center", "center" )

	for colorIndex, y in pairs ( leftY ) do
		local col = WIRE_COLORS[colorIndex].col
		if draggingFrom == colorIndex then
			dxDrawRectangle ( PANEL_X+40-NODE_R-3, y-NODE_R-3, (NODE_R+3)*2, (NODE_R+3)*2, tocolor(255,255,255,180) )
		end
		dxDrawRectangle ( PANEL_X+40-NODE_R, y-NODE_R, NODE_R*2, NODE_R*2, col )
	end

	for colorIndex, y in pairs ( rightY ) do
		local col = WIRE_COLORS[colorIndex].col
		dxDrawRectangle ( PANEL_X+PANEL_W-40-NODE_R, y-NODE_R, NODE_R*2, NODE_R*2, col )
	end

	for colorIndex in pairs ( connected ) do
		local col = WIRE_COLORS[colorIndex].col
		dxDrawLine ( PANEL_X+40, leftY[colorIndex], PANEL_X+PANEL_W-40, rightY[colorIndex], col, 4 )
	end

	-- Live-Vorschau der Kabelleitung waehrend man zieht.
	if draggingFrom and isCursorShowing () then
		local cx, cy = getCursorPosition ()
		if cx then
			local col = WIRE_COLORS[draggingFrom].col
			dxDrawLine ( PANEL_X+40, leftY[draggingFrom], cx * screenW, cy * screenH, col, 3 )
		end
	end

	dxDrawText ( "Verbunden: "..(function() local n=0 for _ in pairs(connected) do n=n+1 end return n end)().."/4", PANEL_X, PANEL_Y+PANEL_H-30, PANEL_X+PANEL_W, PANEL_Y+PANEL_H-10, COL_TEXT_DIM, 0.9, "default", "center", "center" )
end )

addEventHandler ( "onClientResourceStop", resourceRoot, function ()
	if minigameActive then
		minigameActive = false
		showCursor ( false )
		guiSetInputMode ( "allow_binds" )
	end
end )
