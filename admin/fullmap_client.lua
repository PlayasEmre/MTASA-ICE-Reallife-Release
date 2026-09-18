--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local MAP_SIZE = 700
local sw, sh = guiGetScreenSize()
if sh < 700 then
	MAP_SIZE = 450
end
local mapX, mapY = ( sw - MAP_SIZE ) / 2, ( sh - MAP_SIZE ) / 2
local closeX, closeY, closeW, closeH = mapX + MAP_SIZE - 90, mapY - 32, 90, 24

local mapOpen = false
local mapTexture

local function loadMapTexture()
	if mapTexture then return end
	mapTexture = dxCreateTexture ( ":"..getResourceName(getThisResource()).."/admin/map.jpg" )
end

local function worldToScreen ( wx, wy )
	local sx = mapX + ( wx + 3000 ) * MAP_SIZE / 6000
	local sy = mapY + ( 3000 - wy ) * MAP_SIZE / 6000
	return sx, sy
end

local function drawPlayerBlips()
	for _, ply in ipairs ( getElementsByType ( "player" ) ) do
		if isElement ( ply ) then
			local px, py = getElementPosition ( ply )
			local sx, sy = worldToScreen ( px, py )
			if sx >= mapX and sx <= mapX + MAP_SIZE and sy >= mapY and sy <= mapY + MAP_SIZE then
				local r, g, b = 255, 220, 0
				if ply == localPlayer then r, g, b = 0, 255, 0 end
				dxDrawRectangle ( sx - 3, sy - 3, 6, 6, tocolor ( r, g, b, 255 ) )
				dxDrawText ( getPlayerName ( ply ), sx + 5, sy - 6, sx + 200, sy + 6, tocolor ( 255, 255, 255, 255 ), 0.8, "sans" )
			end
		end
	end
end

local function drawMap()
	if mapTexture then
		dxDrawImage ( mapX, mapY, MAP_SIZE, MAP_SIZE, mapTexture )
	end

	drawPlayerBlips()

	dxDrawRectangle ( mapX, mapY, MAP_SIZE, 2, tocolor(255,255,255,200) )
	dxDrawRectangle ( mapX, mapY + MAP_SIZE - 2, MAP_SIZE, 2, tocolor(255,255,255,200) )
	dxDrawRectangle ( mapX, mapY, 2, MAP_SIZE, tocolor(255,255,255,200) )
	dxDrawRectangle ( mapX + MAP_SIZE - 2, mapY, 2, MAP_SIZE, tocolor(255,255,255,200) )

	dxDrawText ( "Klicke auf die Karte, um dich zu teleportieren", mapX, mapY - 26, mapX + MAP_SIZE, mapY, tocolor(255,255,255,255), 1.1, "sans", "left", "top" )

	dxDrawRectangle ( closeX, closeY, closeW, closeH, tocolor(66,140,205,220) )
	dxDrawText ( "Schliessen", closeX, closeY, closeX + closeW, closeY + closeH, tocolor(255,255,255,255), 1, "sans", "center", "center" )
end

local function screenToWorld ( px, py )
	local relX = px - mapX
	local relY = py - mapY
	if relX < 0 or relX > MAP_SIZE or relY < 0 or relY > MAP_SIZE then return nil end
	local worldX = relX * 6000 / MAP_SIZE - 3000
	local worldY = 3000 - relY * 6000 / MAP_SIZE
	return worldX, worldY
end

local function closeFullMap()
	if not mapOpen then return end
	mapOpen = false
	removeEventHandler ( "onClientRender", root, drawMap )
	showCursor ( false, false )
end

local function openFullMap()
	if mapOpen then return end
	loadMapTexture()
	mapOpen = true
	addEventHandler ( "onClientRender", root, drawMap )
	showCursor ( true, true )
end
addEvent ( "fullMapOpen", true )
addEventHandler ( "fullMapOpen", root, openFullMap )

addEventHandler ( "onClientClick", root, function ( button, state, absX, absY )
	if not mapOpen or button ~= "left" or state ~= "up" then return end

	if absX >= closeX and absX <= closeX + closeW and absY >= closeY and absY <= closeY + closeH then
		closeFullMap()
		return
	end

	local worldX, worldY = screenToWorld ( absX, absY )
	if worldX then
		local hit, hx, hy, hz = processLineOfSight ( worldX, worldY, 1000, worldX, worldY, -50 )
		local worldZ = hit and ( hz + 1 ) or 20
		triggerServerEvent ( "fullMapTeleport", localPlayer, worldX, worldY, worldZ )
		closeFullMap()
	end
end )

addEventHandler ( "onClientResourceStop", resourceRoot, closeFullMap )
