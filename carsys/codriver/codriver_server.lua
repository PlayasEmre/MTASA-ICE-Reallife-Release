--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

function gluePlayer(vehicle, x, y, z, rotX, rotY, rotZ)
	if source == client then
		attachElements(source, vehicle, x, y, z, rotX, rotY, rotZ)
		setPedWeaponSlot(source, 0)
		bindKey ( source, "mouse_wheel_up", "down", weaponsup )
		bindKey ( source, "mouse_wheel_down", "down", weaponsdown )
	end
end
addEvent("gluePlayer",true)
addEventHandler("gluePlayer",getRootElement(),gluePlayer)

function ungluePlayer()
	if source == client then
		detachElements(source)
		unbindKey ( source, "mouse_wheel_up", "down", weaponsup )
		unbindKey ( source, "mouse_wheel_down", "down", weaponsdown )
	end
end
addEvent("ungluePlayer",true)
addEventHandler("ungluePlayer",getRootElement(),ungluePlayer)

-- Verschiebt einen bereits angehefteten Spieler auf dem Fahrzeug.
-- Vorher war die Position fest: man klebte genau dort, wo man eingestiegen
-- ist, und konnte sich nicht mehr bewegen.
local VERSCHIEBUNG_MAX = 1.6   -- Meter, die man sich vom Einstiegspunkt entfernen darf

addEvent ( "verschiebeGlue", true )
addEventHandler ( "verschiebeGlue", getRootElement(), function ( x, y, z, rotX, rotY, rotZ )
	if source ~= client or not isElement ( source ) then
		return
	end

	if not isElementAttached ( source ) then
		return
	end

	x, y, z = tonumber ( x ), tonumber ( y ), tonumber ( z )
	if not x or not y or not z then
		return
	end

	-- Grenzen serverseitig erzwingen. Der Client schickt die Werte, ein
	-- manipulierter koennte sich sonst beliebig weit vom Fahrzeug wegsetzen.
	local grenze = VERSCHIEBUNG_MAX
	if math.abs ( x ) > grenze or math.abs ( y ) > grenze or math.abs ( z ) > grenze then
		return
	end

	setElementAttachedOffsets ( source, x, y, z,
								tonumber ( rotX ) or 0, tonumber ( rotY ) or 0, tonumber ( rotZ ) or 0 )
end )