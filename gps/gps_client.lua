--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local zielX, zielY = 0, 0
local navAktiv = false
local pfeil, blip, col

local screenWidth, screenHeight = guiGetScreenSize()
local width, height = 700, 700
if screenHeight < 700 then
	width, height = 450, 450
end

local map_window, map_imgMap, map_btnClose

function findRotation ( x1, y1, x2, y2 )
	local X = math.abs ( x2 - x1 )
	local Y = math.abs ( y2 - y1 )
	local Rotm = math.deg ( math.atan2 ( Y, X ) )
	if x1 <= x2 and y1 < y2 then
		Rotm = 90 - Rotm
	elseif x2 <= x1 and y1 < y2 then
		Rotm = 270 + Rotm
	elseif x1 <= x2 and y2 <= y1 then
		Rotm = 90 + Rotm
	elseif x2 < x1 and y2 <= y1 then
		Rotm = 270 - Rotm
	end
	return 630 - Rotm
end

function rotArrow ()
	if isPedInVehicle ( localPlayer ) then
		local vehicle = getPedOccupiedVehicle ( localPlayer )
		local px, py, pz = getElementPosition ( vehicle )
		local rot = findRotation ( px, py, zielX, zielY )
		setElementPosition ( pfeil, px, py, pz + 1 )
		setElementRotation ( pfeil, 0, 90, rot )
	else
		hideArrow ()
	end
end

function showArrow ()
	local px, py, pz = getElementPosition ( localPlayer )
	pfeil = createObject ( 1318, px, py, pz )
	setElementCollisionsEnabled ( pfeil, false )
	addEventHandler ( "onClientPreRender", getRootElement(), rotArrow )
end

function hideArrow ()
	removeEventHandler ( "onClientPreRender", getRootElement(), rotArrow )
	if isElement ( pfeil ) then destroyElement ( pfeil ) end
	if isElement ( blip ) then destroyElement ( blip ) end
	if isElement ( col ) then destroyElement ( col ) end
	pfeil, blip, col = nil, nil, nil
	navAktiv = false
end

addEventHandler ( "onClientVehicleExit", getRootElement(), function ( player, seat )
	if player == localPlayer then
		hideArrow ()
	end
end )

function map_close ( button, state )
	if button == "left" and state == "up" then
		guiSetVisible ( map_window, false )
		showCursor ( false )
	end
end

function map_click ( button, state, relX, relY )
	if button == "left" and state == "up" then
		guiSetVisible ( map_window, false )
		showCursor ( false )

		local winX, winY = guiGetPosition ( map_window, false )
		local px = ( relX - winX ) * 6000 / width - 3000 - 50
		local py = 3000 - ( relY - winY ) * 6000 / height

		zielX, zielY = px, py
		showArrow ()

		col = createColCircle ( px, py, 25 )
		blip = createBlip ( px, py, 0, 41, 2 )
		addEventHandler ( "onClientColShapeHit", col, function ()
			if source == col then
				hideArrow ()
				outputChatBox ( "Du hast dein Ziel erreicht!", 0, 255, 0 )
			end
		end )

		navAktiv = true
	end
end

function erstelleKarte ()
	map_window = guiCreateWindow ( screenWidth / 2 - width / 2, screenHeight / 2 - height / 2, width + 20, height + 50, "Karte", false )
	map_imgMap = guiCreateStaticImage ( 0, 0, width, height, ":"..getResourceName(getThisResource()).."/gps/map.jpg", false, map_window )
	map_btnClose = guiCreateButton ( width - 70, height + 10, 70, 30, "Schliessen", false, map_window )
	addEventHandler ( "onClientGUIDoubleClick", map_imgMap, map_click, false )
	addEventHandler ( "onClientGUIClick", map_btnClose, map_close, false )
	guiSetVisible ( map_window, false )
end

function zeigeKarte ()
	if navAktiv then
		outputChatBox ( "Beende zuerst die aktive Navigation mit /stopgps!", 255, 0, 0 )
		return
	end
	if not isPedInVehicle ( localPlayer ) then
		outputChatBox ( "Du musst in einem Fahrzeug sitzen!", 255, 0, 0 )
		return
	end
	if not isElement ( map_window ) then
		erstelleKarte ()
	end
	guiSetVisible ( map_window, true )
	showCursor ( true )
end
addCommandHandler ( "gps", zeigeKarte )

addCommandHandler ( "stopgps", function ()
	hideArrow ()
end )
