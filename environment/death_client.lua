--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local SHOW_DISTANCE = 12

local function dxDrawText3D ( text, x, y, z )
	local sx, sy = getScreenFromWorldPosition ( x, y, z, 0.2 )
	if sx and sy then
		dxDrawText ( text, sx, sy, sx, sy, tocolor ( 255, 255, 255, 220 ), 1, "default-bold", "center", "center", false, false, false, true )
	end
end

local nearbyDrops = {}
local lastDropScan = 0

addEventHandler ( "onClientRender", root, function ()
	local now = getTickCount ()
	if now - lastDropScan >= 200 then
		lastDropScan = now
		nearbyDrops = {}
		local px, py, pz = getElementPosition ( localPlayer )
		for _, pickup in ipairs ( getElementsByType ( "pickup" ) ) do
			if getElementData ( pickup, "deathWeaponDrop" ) then
				local x, y, z = getElementPosition ( pickup )
				if getDistanceBetweenPoints3D ( px, py, pz, x, y, z ) <= SHOW_DISTANCE then
					local weaponID = tonumber ( getElementData ( pickup, "weapon" ) )
					local ammo = tonumber ( getElementData ( pickup, "ammo" ) ) or 0
					local name = ( weaponNames and weaponNames[weaponID] ) or "Waffe"
					nearbyDrops[#nearbyDrops+1] = { text = name.." ("..ammo..")", x = x, y = y, z = z + 0.8 }
				end
			end
		end
	end

	for i = 1, #nearbyDrops do
		local d = nearbyDrops[i]
		dxDrawText3D ( d.text, d.x, d.y, d.z )
	end
end )
