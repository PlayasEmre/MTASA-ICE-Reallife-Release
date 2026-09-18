--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

codriverVehs = { [500]=true, [422]=true, [478]=true }

-- Solange man auf dem Fahrzeug klebt, laesst sich die Position mit den
-- normalen Laufrichtungen verschieben. Vorher war sie fest.
local VS_TEMPO   = 1.4    -- Meter pro Sekunde
local VS_GRENZE  = 1.6    -- so weit darf man sich hoechstens versetzen
local VS_TAKT    = 100    -- Millisekunden zwischen zwei Meldungen an den Server

local geklebt   = false
local vsX, vsY, vsZ = 0, 0, 0
local vsRotX, vsRotY, vsRotZ = 0, 0, 0
local vsLetzterTick = nil
local vsLetzteMeldung = 0

local function begrenze ( wert )
	return math.max ( -VS_GRENZE, math.min ( VS_GRENZE, wert ) )
end

local function verschiebeAufFahrzeug ()
	if not geklebt then
		return
	end

	local jetzt = getTickCount ()
	local delta = math.min ( jetzt - ( vsLetzterTick or jetzt ), 100 ) / 1000
	vsLetzterTick = jetzt

	-- Die normalen Laufrichtungen statt eigener Tasten: so gibt es keine
	-- Ueberschneidung mit den vielen bereits belegten Tasten.
	-- getPedControlState statt getControlState - Letzteres ist in MTA
	-- veraltet und wird kuenftig entfernt.
	local links   = getPedControlState ( localPlayer, "left" )      and 1 or 0
	local rechts  = getPedControlState ( localPlayer, "right" )     and 1 or 0
	local vor     = getPedControlState ( localPlayer, "forwards" )  and 1 or 0
	local zurueck = getPedControlState ( localPlayer, "backwards" ) and 1 or 0

	local dx = ( rechts - links ) * VS_TEMPO * delta
	local dy = ( vor - zurueck ) * VS_TEMPO * delta

	if dx == 0 and dy == 0 then
		return
	end

	vsX = begrenze ( vsX + dx )
	vsY = begrenze ( vsY + dy )

	-- Nicht in jedem Bild melden, sonst laeuft eine Flut kleiner Events
	-- zum Server. Zehn Meldungen je Sekunde reichen voellig.
	if jetzt - vsLetzteMeldung < VS_TAKT then
		return
	end
	vsLetzteMeldung = jetzt

	triggerServerEvent ( "verschiebeGlue", localPlayer, vsX, vsY, vsZ, vsRotX, vsRotY, vsRotZ )
end

function glue()
	local player = localPlayer
	if not getPedOccupiedVehicle(player) then
		local vehicle = getPedContactElement(player)
		if vehicle and getElementType(vehicle) == "vehicle" then
			if raftboats[getElementModel(vehicle)] or motorboats[getElementModel(vehicle)] or codriverVehs[getElementModel(vehicle)] then
				local px, py, pz = getElementPosition(player)
				local vx, vy, vz = getElementPosition(vehicle)
				local sx = px - vx
				local sy = py - vy
				local sz = pz - vz
				
				local rotpX = 0
				local rotpY = 0
				local rotpZ = getPedRotation(player)
				
				local rotvX,rotvY,rotvZ = getElementRotation(vehicle)
				
				local t = math.rad(rotvX)
				local p = math.rad(rotvY)
				local f = math.rad(rotvZ)
				
				local ct = math.cos(t)
				local st = math.sin(t)
				local cp = math.cos(p)
				local sp = math.sin(p)
				local cf = math.cos(f)
				local sf = math.sin(f)
				
				local z = ct*cp*sz + (sf*st*cp + cf*sp)*sx + (-cf*st*cp + sf*sp)*sy
				local x = -ct*sp*sz + (-sf*st*sp + cf*cp)*sx + (cf*st*sp + sf*cp)*sy
				local y = st*sz - sf*ct*sx + cf*ct*sy
				
				local rotX = rotpX - rotvX
				local rotY = rotpY - rotvY
				local rotZ = rotpZ - rotvZ
				
				local slot = getPedWeaponSlot(player)
				
				triggerServerEvent("gluePlayer", player, vehicle, x, y, z, rotX, rotY, rotZ)

				-- Ausgangspunkt merken, ab hier laesst sich verschieben.
				vsX, vsY, vsZ = x, y, z
				vsRotX, vsRotY, vsRotZ = rotX, rotY, rotZ
				vsLetzterTick = nil
				vsLetzteMeldung = 0
				geklebt = true
				addEventHandler ( "onClientRender", root, verschiebeAufFahrzeug )

				unbindKey("x","down",glue)
				bindKey("enter","down",unglue)
			end
		end
	end
end
bindKey("x","down",glue)

function unglue ()
	local player = localPlayer
	triggerServerEvent("ungluePlayer", player)

	geklebt = false
	removeEventHandler ( "onClientRender", root, verschiebeAufFahrzeug )

	unbindKey("enter","down",unglue)
	bindKey("x","down",glue)
end