--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Zusatzfunktionen fuer die praktische Fahrpruefung: Abbiege-Hinweise
-- ("Bitte rechts/links abbiegen") an den bestehenden Checkpoints, mehrere
-- Tempolimit-Zonen ueber die ganze Strecke verteilt, sowie ein LKW mit
-- Anhaenger, der nach der Route wieder an der Abholstelle zurueckgestellt
-- werden muss. Ergaenzt fahrschule_server.lua, ohne den bestehenden
-- Checkpoint-Ablauf zu veraendern.

-- ===== ABBIEGE-HINWEISE =====
-- Wird aus createTestMarker (fahrschule_server.lua) aufgerufen, sobald ein
-- neuer Checkpoint gesetzt wird. Vergleicht die Fahrtrichtung zum aktuellen
-- Checkpoint mit der Richtung zum naechsten und sagt an, ob es geradeaus,
-- links oder rechts weitergeht.

local TURN_THRESHOLD = 25 -- Grad Richtungsaenderung, ab der "abbiegen" statt "geradeaus" angesagt wird

local function bearing(ax, ay, bx, by)
	return math.deg(math.atan2(by - ay, bx - ax))
end

local function normalizeAngle(deg)
	while deg > 180 do deg = deg - 360 end
	while deg < -180 do deg = deg + 360 end
	return deg
end

function zeigeAbbiegehinweis(player, coordsTable, markerIndex)
	local prev = coordsTable[markerIndex - 1]
	local current = coordsTable[markerIndex]
	local naechster = coordsTable[markerIndex + 1]
	if not prev or not current or not naechster then return end -- erster/letzter Punkt der Route

	local einkommend = bearing(prev.x, prev.y, current.x, current.y)
	local ausgehend = bearing(current.x, current.y, naechster.x, naechster.y)
	local diff = normalizeAngle(ausgehend - einkommend)

	if diff > TURN_THRESHOLD then
		outputChatBox("[Navigation] Gleich bitte links abbiegen.", player, 100, 200, 255)
	elseif diff < -TURN_THRESHOLD then
		outputChatBox("[Navigation] Gleich bitte rechts abbiegen.", player, 100, 200, 255)
	else
		outputChatBox("[Navigation] Geradeaus weiterfahren.", player, 100, 200, 255)
	end
end

-- ===== TEMPOLIMIT-ZONEN =====
-- Automatisch an JEDEM Streckenpunkt aus carTestCoords (fahrschule_server.lua)
-- erzeugt - nicht mehr nur an ein paar Stellen. Das Limit pro Zone wird aus
-- der Kurvenschaerfe an diesem Punkt abgeleitet (scharfe Kurve = langsamer,
-- gerade Strecke = schneller), mit derselben Richtungsberechnung wie bei den
-- Abbiege-Hinweisen oben.

local function schaetzeTempolimit(coordsTable, index)
	local prev = coordsTable[index - 1]
	local current = coordsTable[index]
	local naechster = coordsTable[index + 1]
	if not prev or not naechster then
		return 50 -- erster/letzter Punkt: kein Vorher/Nachher zum Vergleichen
	end

	local einkommend = bearing(prev.x, prev.y, current.x, current.y)
	local ausgehend = bearing(current.x, current.y, naechster.x, naechster.y)
	local diff = math.abs(normalizeAngle(ausgehend - einkommend))

	if diff > 45 then
		return 30 -- scharfe Kurve
	elseif diff > TURN_THRESHOLD then
		return 50 -- leichte Kurve
	else
		return 80 -- gerade Strecke
	end
end

local ZONE_RADIUS = 20
local SPEED_TOLERANCE = 5 -- km/h Toleranz nach oben, bevor gewarnt wird
local WARN_COOLDOWN = 3000 -- ms zwischen zwei Warnungen an denselben Spieler (verhindert Spam UND sorgt fuer Abstand zwischen den Verwarnungen)
local SPEED_STRIKE_LIMIT = 3 -- Anzahl Verwarnungen, bevor die Pruefung automatisch endet

-- [vehicle] = { timer = ..., zone = colshape-Element }. Mehrere Zonen koennen
-- sich ueberlappen (manche Streckenpunkte liegen naeher als 2x ZONE_RADIUS
-- zusammen) - "zone" merkt sich, welche Zone GERADE ueberwacht wird, damit
-- das Verlassen einer aelteren, bereits ueberschriebenen Zone nicht faelschlich
-- die Ueberwachung der aktuell aktiven Zone abbricht.
local zoneMonitors = {}
local lastWarnung = {} -- [player] = Tickcount der letzten Warnung

-- Global (kein "local"), damit fahrschule_server.lua den Zaehler in
-- resetPruefungsData mit zuruecksetzen kann, sobald ein Versuch (egal ob
-- bestanden, durchgefallen oder abgebrochen) beendet ist.
speedStrikes = {} -- [player] = Anzahl Verwarnungen im aktuellen Versuch

local function zoneTick(veh, limit, player)
	if not isElement(veh) or not isElement(player) then
		if zoneMonitors[veh] then
			if isTimer ( zoneMonitors[veh].timer ) then killTimer ( zoneMonitors[veh].timer ) end
			zoneMonitors[veh] = nil
		end
		return
	end
	local speed = getElementSpeed(veh, "km/h") or 0
	if speed > limit + SPEED_TOLERANCE then
		local now = getTickCount()
		if not lastWarnung[player] or (now - lastWarnung[player]) > WARN_COOLDOWN then
			lastWarnung[player] = now
			speedStrikes[player] = (speedStrikes[player] or 0) + 1
			local anzahl = speedStrikes[player]

			if anzahl >= SPEED_STRIKE_LIMIT then
				automatischDurchgefallen(player, "zu oft zu schnell gefahren ("..anzahl.."x verwarnt)")
			else
				outputChatBox("[Tempolimit] Zu schnell: "..math.floor(speed).." km/h (erlaubt: "..limit.." km/h)! Verwarnung "..anzahl.."/"..SPEED_STRIKE_LIMIT, player, 255, 100, 0)
				local lehrerName = MtxGetElementData(player, "fahrschullehrername")
				local lehrer = lehrerName and getPlayerFromName(lehrerName)
				if lehrer then
					outputChatBox("[Pruefung] "..getPlayerName(player).." wurde wegen zu schnellen Fahrens verwarnt ("..anzahl.."/"..SPEED_STRIKE_LIMIT..").", lehrer, 255, 150, 0)
				end
			end
		end
	end
end

for index, punkt in ipairs(carTestCoords) do
	local limit = schaetzeTempolimit(carTestCoords, index)
	local col = createColSphere(punkt.x, punkt.y, punkt.z, ZONE_RADIUS)

	addEventHandler("onColShapeHit", col, function(hitElement)
		if getElementType(hitElement) ~= "vehicle" then return end
		local driver = getVehicleController(hitElement)
		if not driver or MtxGetElementData(driver, "inpruefung") ~= true then return end
		if zoneMonitors[hitElement] then killTimer(zoneMonitors[hitElement].timer) end
		zoneMonitors[hitElement] = {
			timer = setTimer(zoneTick, 1000, 0, hitElement, limit, driver),
			zone = col,
		}
	end, false)

	addEventHandler("onColShapeLeave", col, function(hitElement)
		local monitor = zoneMonitors[hitElement]
		if monitor and monitor.zone == col then
			if isTimer ( monitor.timer ) then killTimer ( monitor.timer ) end
			zoneMonitors[hitElement] = nil
		end
	end, false)
end

-- ===== LKW MIT ANHAENGER =====
-- Nutzt die bereits vorhandenen LKW (Modell 515) + Anhaenger (Modell 435)
-- aus fahrschule_cars.lua (lkwAnhaengerPaare - dort werden sie erzeugt und
-- schon fest aneinandergehaengt). Hier kommt nur die Rueckgabe-Logik dazu:
-- Sobald ein Anhaenger nah genug an seine ursspruengliche Startposition
-- zurueckgebracht wird, koppelt er sich automatisch ab und rastet exakt an
-- dieser Position/Ausrichtung ein - sieht danach aus, als waere er frisch
-- dort gespawnt. Blockiert die Pruefung selbst nicht, der Fahrlehrer
-- entscheidet weiterhin mit /stoppruefung.

local LKW_RETURN_TOLERANCE = 6 -- Meter

-- Setzt einen Anhaenger exakt auf seine urspruengliche Position/Ausrichtung
-- zurueck (koppelt ihn dafuer bei Bedarf zuerst vom Zugfahrzeug ab). Global,
-- damit fahrschule_server.lua das auch beim Abbrechen (Aussteigen) oder
-- automatischen Durchfallen aufrufen kann - nicht nur bei der regulaeren
-- Rueckgabe an der Abholstelle unten.
function setzeAnhaengerZurueck(paar)
	if not paar or not isElement(paar.trailer) then return end
	if isElement(paar.truck) then
		paar.absichtlichGeloest = true
		detachTrailerFromVehicle(paar.truck, paar.trailer)
	end
	setElementPosition(paar.trailer, paar.x, paar.y, paar.z)
	setElementRotation(paar.trailer, paar.rx, paar.ry, paar.rz)
	setElementVelocity(paar.trailer, 0, 0, 0)
	setElementAngularVelocity(paar.trailer, 0, 0, 0)
end

-- Findet das lkwAnhaengerPaare-Eintrag zu einem bestimmten Zugfahrzeug.
function findeAnhaengerPaarFuerTruck(truck)
	for _, paar in ipairs(lkwAnhaengerPaare) do
		if paar.truck == truck then return paar end
	end
	return nil
end

-- Loest sich der Anhaenger UNTERWEGS (nicht an der Abholstelle, siehe Flag
-- absichtlichGeloest), war das kein kontrolliertes Abkoppeln, sondern z.B. eine
-- Folge von zu hartem/schnellem Fahren oder einem Unfall - dann faellt die
-- Pruefung automatisch durch. Eigene, global aufrufbare Funktion, da sie nach
-- einem Anhaenger-Respawn (siehe fahrschule_cars.lua) auf dem neuen Anhaenger-
-- Element erneut registriert werden muss (Handler haengt am Element, nicht am
-- lkwAnhaengerPaare-Eintrag).
function bindeAnhaengerDetachHandler(paar)
	addEventHandler("onTrailerDetach", paar.trailer, function(truck)
		if paar.absichtlichGeloest then
			paar.absichtlichGeloest = false
			return
		end
		local driver = getVehicleController(truck)
		if driver and MtxGetElementData(driver, "inpruefung") == true and MtxGetElementData(driver, "inpruefungType") == "LKW" then
			automatischDurchgefallen(driver, "Anhänger hat sich unerwartet gelöst")
		end
	end)
end

for _, paar in ipairs(lkwAnhaengerPaare) do
	local zone = createColSphere(paar.x, paar.y, paar.z, LKW_RETURN_TOLERANCE)
	paar.absichtlichGeloest = false -- true waehrend des kontrollierten Abkoppelns, damit onTrailerDetach das nicht als Unfall wertet

	addEventHandler("onColShapeHit", zone, function(hitElement)
		if hitElement ~= paar.trailer then return end

		setzeAnhaengerZurueck(paar)

		for _, p in ipairs(getElementsByType("player")) do
			if MtxGetElementData(p, "inpruefung") == true and MtxGetElementData(p, "inpruefungType") == "LKW" then
				outputChatBox("[Pruefung] Anhaenger wurde automatisch an der Abholstelle eingerastet!", p, 0, 200, 0)
				local lehrerName = MtxGetElementData(p, "fahrschullehrername")
				local lehrer = lehrerName and getPlayerFromName(lehrerName)
				if lehrer then
					outputChatBox("[Pruefung] "..getPlayerName(p).." hat den Anhaenger zurueckgestellt.", lehrer, 0, 200, 0)
				end
			end
		end
	end, false)

	bindeAnhaengerDetachHandler(paar)
end
