--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local rotX, rotY = 0, 0

local egoEnabled = false
local deathFreecamEnabled = false

local mouseSensitivity = 0.1

local delay = 0

local PI = math.pi

-- Normale /ego Freikamera (unverändert, wie ursprünglich) - Kamera sitzt direkt an
-- der Spielerposition und lässt sich nur mit der Maus drehen. Wird ausschließlich
-- vom /ego Befehl benutzt und von der Medic-Todeskamera unten komplett getrennt,
-- damit Änderungen an der einen niemals die andere beeinflussen können.
local function freecamFrame ()

	local pedX, pedY, pedZ = getPedBonePosition ( lp, 8 )

	local angleZ = math.sin(rotY)
	local angleY = math.cos(rotY) * math.cos(rotX)
	local angleX = math.cos(rotY) * math.sin(rotX)

	local camTargetX = pedX + ( angleX ) * 100
	local camTargetY = pedY + angleY * 100
	local camTargetZ = pedZ + angleZ * 100

	setCameraMatrix ( pedX, pedY, pedZ, camTargetX, camTargetY, camTargetZ )
end

-- Eigenständige Freikamera für den Medic-Transport (Tod / Krankenwagenfahrt) -
-- schwebt ein Stück hinter dem Spieler, damit man sich (und das Fahrzeug) von außen
-- sieht statt von innen, und dreht die Blickrichtung sauber mit, während man im
-- Krankenwagen mitfährt. Komplett eigener Zustand (oldVehRot) und eigene
-- Render-Funktion, unabhängig von freecamFrame oben.
local backDistance = 5 -- Meter hinter dem Spieler
local oldVehRot = nil

local function deathFreecamFrame ()

	local pedX, pedY, pedZ = getPedBonePosition ( lp, 8 )

	local angleZ = math.sin(rotY)
	local angleY = math.cos(rotY) * math.cos(rotX)
	local angleX = math.cos(rotY) * math.sin(rotX)

	local camPosX = pedX - angleX * backDistance
	local camPosY = pedY - angleY * backDistance
	local camPosZ = pedZ - angleZ * backDistance + 1

	local camTargetX = pedX + ( angleX ) * 100
	local camTargetY = pedY + angleY * 100
	local camTargetZ = pedZ + angleZ * 100

	local veh = getPedOccupiedVehicle ( lp )
	if veh then
		local rx, ry, vehRot = getElementRotation ( veh )
		if not oldVehRot then
			oldVehRot = vehRot
		end
		local changedRotation = vehRot - oldVehRot
		oldVehRot = vehRot

		-- Blickrichtung um genau die Fahrzeug-Drehung seit dem letzten Frame mitdrehen
		rotX = rotX - math.rad ( changedRotation )
		if rotX > PI then
			rotX = rotX - 2 * PI
		elseif rotX < -PI then
			rotX = rotX + 2 * PI
		end

		camTargetX = pedX + ( math.cos(rotY) * math.sin(rotX) ) * 100
		camTargetY = pedY + ( math.cos(rotY) * math.cos(rotX) ) * 100
	else
		oldVehRot = nil
	end

	setCameraMatrix ( camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ )
end

-- Maussteuerung wird von beiden Kameras benutzt (reine Eingabeverarbeitung,
-- unabhängig davon welches der beiden Systeme gerade aktiv ist)
local function freecamMouse (cX,cY,aX,aY)

	if isCursorShowing() or isMTAWindowActive() then
		delay = 5
		return
	elseif delay > 0 then
		delay = delay - 1
		return
	end

    local width, height = guiGetScreenSize()
    aX = aX - width / 2
    aY = aY - height / 2

    rotX = rotX + aX * mouseSensitivity * 0.01745
    rotY = rotY - aY * mouseSensitivity * 0.01745

	if rotX > PI then
		rotX = rotX - 2 * PI
	elseif rotX < -PI then
		rotX = rotX + 2 * PI
	end

	if rotY > PI then
		rotY = rotY - 2 * PI
	elseif rotY < -PI then
		rotY = rotY + 2 * PI
	end

    if rotY < -PI / 2.05 then
       rotY = -PI / 2.05
    elseif rotY > PI / 2.05 then
        rotY = PI / 2.05
    end
end

function setEgoEnabled (x, y, z)

	if (x and y and z) then
	    setCameraMatrix ( x, y, z )
	end
	addEventHandler("onClientPreRender", getRootElement(), freecamFrame)
	addEventHandler("onClientCursorMove",getRootElement(), freecamMouse)
end

function setEgoDisabled()

	if egoEnabled then
		egoEnabled = false
		removeEventHandler("onClientPreRender", getRootElement(), freecamFrame)
		if not deathFreecamEnabled then
			removeEventHandler("onClientCursorMove",getRootElement(), freecamMouse)
		end
		setCameraTarget ( lp )
	end
end
addEventHandler ( "onClientPlayerWasted", localPlayer, setEgoDisabled )

local function setDeathFreecamEnabled (x, y, z)

	if (x and y and z) then
	    setCameraMatrix ( x, y, z )
	end
	oldVehRot = nil
	addEventHandler("onClientPreRender", getRootElement(), deathFreecamFrame)
	addEventHandler("onClientCursorMove",getRootElement(), freecamMouse)
end

local function setDeathFreecamDisabled()

	if deathFreecamEnabled then
		deathFreecamEnabled = false
		removeEventHandler("onClientPreRender", getRootElement(), deathFreecamFrame)
		if not egoEnabled then
			removeEventHandler("onClientCursorMove",getRootElement(), freecamMouse)
		end
		setCameraTarget ( lp )
	end
end

-- Freie, mit der Maus drehbare Kamera automatisch aktivieren, während man tot
-- ist (statt der nativen GTA-Todeskamera, die sich nicht steuern lässt), und
-- wieder deaktivieren sobald man geheilt/respawnt wird - siehe environment/death.lua
-- und fraktionen/medic/medic_server.lua.
addEvent ( "startDeathFreecam", true )
addEventHandler ( "startDeathFreecam", localPlayer, function ()
	if not deathFreecamEnabled then
		deathFreecamEnabled = true
		local x, y, z = getElementPosition ( lp )
		setDeathFreecamEnabled ( x, y, z )
	end
end )

addEvent ( "stopDeathFreecam", true )
addEventHandler ( "stopDeathFreecam", localPlayer, setDeathFreecamDisabled )

function ego_func ()

	if egoEnabled then
		setEgoDisabled()
	else
		egoEnabled = true
		local x, y, z = getElementPosition ( lp )
		setEgoEnabled ( x, y, z )
	end
end
addCommandHandler ( "ego", ego_func )
