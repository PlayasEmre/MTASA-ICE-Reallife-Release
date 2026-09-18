--//                                                               \\
--||  Project: MTA - German ICE Reallife Gamemode    ||
--||  Developers: PlayasEmre                         ||
--||  Version: 5.0                                   ||
--\\                                                               //

-- Anzeigeart. Wird hier fest eingestellt, es gibt keinen Befehl dafuer.
--   "modern"  - runder Tacho, komplett gezeichnet, ohne Bilddateien
--   "rund"    - der bisherige Tacho mit den vorhandenen Bildern
--   "digital" - flaches Feld unten rechts, nur Zahl
local TACHO_STIL = "modern"

-- Moderner Tacho: Mittelpunkt und Groesse in der 1920x1080-Bezugsgroesse.
local M_X       = 1770
local M_Y       = 900
local M_RADIUS  = 104
local M_DICKE   = 13     -- Staerke des Geschwindigkeitsbogens
local M_MAX     = 240    -- Ende der Skala in km/h
local M_SWEEP   = 260    -- wie viel Grad der Bogen ueberstreicht

-- Zahl in der Mitte des Rundtachos. Der Zeiger bleibt, die Geschwindigkeit
-- steht zusaetzlich als Ziffer darin - damit laesst sie sich genau ablesen,
-- ohne dass der gewohnte Tacho verschwindet.
local RUND_ZAHL     = true
local RUND_ZAHL_X   = 1760   -- Mitte der Tachoscheibe
local RUND_ZAHL_Y   = 905
local RUND_ZAHL_GR  = 2.0    -- Schriftgroesse der Zahl

-- Lage und Groesse der digitalen Anzeige, in der 1920x1080-Bezugsgroesse.
-- Gsx und Gsy rechnen das auf die tatsaechliche Aufloesung um.
local D_BREITE = 330
local D_HOEHE  = 104
local D_X      = 1920 - D_BREITE - 40
local D_Y      = 1080 - D_HOEHE - 42

local FARBE_BG     = tocolor ( 18, 20, 26, 205 )
local FARBE_RAND   = tocolor ( 255, 255, 255, 26 )
local FARBE_TEXT   = tocolor ( 255, 255, 255, 255 )
local FARBE_LEISE  = tocolor ( 160, 166, 178, 255 )
local FARBE_TANK   = tocolor ( 70, 190, 90, 255 )
local FARBE_TANK_W = tocolor ( 220, 70, 70, 255 )

-- Gurtsymbol. Weiss auf transparent, damit es sich einfaerben laesst.
local GURT_BILD = "images/gurt/gurt.png"

-- Zeichnet das Gurtsymbol: gruen wenn angelegt, rot blinkend wenn offen.
-- Der Zustand kommt aus dem Anschnallsystem ( carsys/gurt ).
local function zeichneGurt ( x, y, groesse )
	if not fileExists ( GURT_BILD ) then
		return
	end

	local an = ( tonumber ( vioClientGetElementData ( "gurt" ) ) or 0 ) == 1

	if an then
		dxDrawImage ( x, y, groesse, groesse, GURT_BILD, 0, 0, 0, tocolor ( 70, 200, 110, 255 ), false )
		return
	end

	local hell = math.floor ( getTickCount () / 500 ) % 2 == 0
	dxDrawImage ( x, y, groesse, groesse, GURT_BILD, 0, 0, 0,
				  hell and tocolor ( 235, 80, 70, 255 ) or tocolor ( 140, 50, 46, 255 ), false )
end

---------------------------------------------------------------------
-- Geschwindigkeit
---------------------------------------------------------------------

function getElementSpeed ( element, unit )
	if unit == nil then unit = 0 end

	if not isElement ( element ) then
		outputDebugString ( "Kein Element. Ich kann keine Geschwindigkeit bekommen" )
		return false
	end

	local x, y, z = getElementVelocity ( element )
	local actualSpeed = ( x^2 + y^2 + z^2 ) ^ 0.5

	if unit == "km/h" or unit == 1 or unit == '1' then
		return actualSpeed * 180
	elseif unit == "mph" or unit == 2 or unit == '2' then
		return actualSpeed * 111.85
	end

	return actualSpeed * 50
end

---------------------------------------------------------------------
-- Moderner Tacho, komplett gezeichnet
---------------------------------------------------------------------

-- Kreisbogen aus kurzen Liniensegmenten. Winkel in Grad, 0 zeigt nach oben,
-- positive Werte laufen im Uhrzeigersinn.
local function zeichneBogen ( cx, cy, radius, dicke, vonWinkel, bisWinkel, farbe )
	if bisWinkel <= vonWinkel then
		return
	end

	-- Schrittweite nach Bogenlaenge: enger bei grossem Radius, damit keine
	-- Luecken entstehen, aber nicht unnoetig viele Segmente bei kleinem.
	local schritt = math.max ( 1.2, 90 / math.max ( radius, 1 ) )
	local a = vonWinkel

	while a < bisWinkel do
		local b = math.min ( a + schritt, bisWinkel )
		local r1, r2 = math.rad ( a ), math.rad ( b )

		dxDrawLine ( cx + math.sin ( r1 ) * radius, cy - math.cos ( r1 ) * radius,
					 cx + math.sin ( r2 ) * radius, cy - math.cos ( r2 ) * radius,
					 farbe, dicke, false )
		a = b
	end
end

-- Farbverlauf nach Tempo: ruhiges Blaugruen, ab zwei Dritteln gelb, oben rot.
local function tempoFarbe ( anteil )
	if anteil < 0.66 then
		return tocolor ( 60, 200, 170, 255 )
	elseif anteil < 0.85 then
		return tocolor ( 240, 200, 60, 255 )
	end
	return tocolor ( 235, 80, 70, 255 )
end

local function zeichneModern ( veh, tempo, tank, lights, engine )
	local cx = M_X * Gsx
	local cy = M_Y * Gsy
	local r  = M_RADIUS * Gsy
	local d  = M_DICKE * Gsy

	local anteil = math.max ( 0, math.min ( 1, tempo / M_MAX ) )
	local start  = -M_SWEEP / 2
	local ende   = start + M_SWEEP * anteil

	-- Leichte Abdunklung hinter der Scheibe, damit der Tacho auf hellem
	-- Hintergrund nicht verschwindet.
	zeichneBogen ( cx, cy, r * 0.62, r * 1.24, 0, 360, tocolor ( 12, 14, 18, 150 ) )

	-- Skalenbogen und darauf der gefuellte Teil
	zeichneBogen ( cx, cy, r, d, start, start + M_SWEEP, tocolor ( 255, 255, 255, 34 ) )
	zeichneBogen ( cx, cy, r, d, start, ende, tempoFarbe ( anteil ) )

	-- Feine Teilstriche alle 40 km/h
	for wert = 0, M_MAX, 40 do
		local w = start + M_SWEEP * ( wert / M_MAX )
		local rad = math.rad ( w )
		local i1, i2 = r - d * 0.9, r - d * 1.7

		dxDrawLine ( cx + math.sin ( rad ) * i1, cy - math.cos ( rad ) * i1,
					 cx + math.sin ( rad ) * i2, cy - math.cos ( rad ) * i2,
					 tocolor ( 255, 255, 255, 70 ), 2 * Gsy, false )
	end

	-- Tankbogen innen
	local tankAnteil = math.max ( 0, math.min ( 1, tank / 100 ) )
	local tankR = r - d * 2.4

	zeichneBogen ( cx, cy, tankR, 5 * Gsy, start, start + M_SWEEP, tocolor ( 255, 255, 255, 26 ) )
	zeichneBogen ( cx, cy, tankR, 5 * Gsy, start, start + M_SWEEP * tankAnteil,
				   ( tank <= 15 ) and FARBE_TANK_W or FARBE_TANK )

	-- Zahl und Einheit in der Mitte
	local zahl = tostring ( math.floor ( tempo ) )
	dxDrawText ( zahl, cx, cy - 6 * Gsy, cx, cy - 6 * Gsy,
				 FARBE_TEXT, 2.6 * Gsy, "default-bold", "center", "center", false, false, false )
	dxDrawText ( "km/h", cx, cy + 26 * Gsy, cx, cy + 26 * Gsy,
				 FARBE_LEISE, 0.9 * Gsy, "default-bold", "center", "center", false, false, false )

	-- Statussymbole unter der Scheibe. Vier Stueck, deshalb mittig ausgerichtet
	-- statt von einem festen Punkt aus.
	local iconG = 26 * Gsy
	local iconY = cy + r * 0.72
	local abstand = iconG * 1.5
	local iconX = cx - abstand * 1.5 - iconG / 2

	zeichneGurt ( iconX, iconY, iconG )

	iconX = iconX + abstand
	dxDrawImage ( iconX, iconY, iconG, iconG, "carsys/tacho/img/State.png", 0, 0, 0,
				  isVehicleLocked ( veh ) and tocolor ( 0, 150, 0, 255 ) or tocolor ( 150, 0, 0, 255 ), false )

	iconX = iconX + abstand
	if lights == 2 then
		dxDrawImage ( iconX, iconY, iconG, iconG, "carsys/tacho/img/Light.png", 0, 0, 0, tocolor ( 0, 85, 200, 255 ), false )
	end

	iconX = iconX + abstand
	if getElementData ( veh, "totalschaden" ) == 1 then
		dxDrawImage ( iconX, iconY, iconG, iconG, "carsys/tacho/img/Engine.png", 0, 0, 0, tocolor ( 200, 0, 0, 255 ), false )
	elseif engine == true then
		dxDrawImage ( iconX, iconY, iconG, iconG, "carsys/tacho/img/Engine.png", 0, 0, 0, tocolor ( 200, 85, 0, 255 ), false )
	end
end

---------------------------------------------------------------------
-- Digitale Anzeige
---------------------------------------------------------------------

local function zeichneDigital ( veh, tempo, tank, lights, engine )
	local x, y = D_X * Gsx, D_Y * Gsy
	local b, h = D_BREITE * Gsx, D_HOEHE * Gsy

	dxDrawRectangle ( x, y, b, h, FARBE_BG, false )
	dxDrawRectangle ( x, y, b, 2 * Gsy, FARBE_RAND, false )

	-- Grosse Zahl links, Einheit klein daneben. Die Zahl wird abgerundet,
	-- sonst flackert die letzte Stelle bei jeder kleinen Schwankung.
	local zahl = tostring ( math.floor ( tempo ) )

	dxDrawText ( zahl, x + 18 * Gsx, y + 8 * Gsy, x + 190 * Gsx, y + 68 * Gsy,
				 FARBE_TEXT, 2.6 * Gsy, "default-bold", "right", "center", false, false, false )

	dxDrawText ( "km/h", x + 196 * Gsx, y + 34 * Gsy, x + 260 * Gsx, y + 62 * Gsy,
				 FARBE_LEISE, 1.0 * Gsy, "default-bold", "left", "center", false, false, false )

	-- Tankbalken unten quer
	local balkenX = x + 18 * Gsx
	local balkenB = b - 36 * Gsx
	local balkenY = y + 76 * Gsy
	local balkenH = 8 * Gsy

	dxDrawRectangle ( balkenX, balkenY, balkenB, balkenH, tocolor ( 255, 255, 255, 30 ), false )
	dxDrawRectangle ( balkenX, balkenY, balkenB * math.max ( 0, math.min ( 100, tank ) ) / 100, balkenH,
					  ( tank <= 15 ) and FARBE_TANK_W or FARBE_TANK, false )

	-- Statussymbole rechts oben, gleiche Bilder wie beim Rundtacho
	local iconY = y + 12 * Gsy
	local iconG = 26 * Gsy
	local iconX = x + b - 34 * Gsx

	if getElementData ( veh, "totalschaden" ) == 1 then
		dxDrawImage ( iconX, iconY, iconG, iconG, "carsys/tacho/img/Engine.png", 0, 0, 0, tocolor ( 200, 0, 0, 255 ), false )
	elseif engine == true then
		dxDrawImage ( iconX, iconY, iconG, iconG, "carsys/tacho/img/Engine.png", 0, 0, 0, tocolor ( 200, 85, 0, 255 ), false )
	end

	iconX = iconX - 32 * Gsx
	if lights == 2 then
		dxDrawImage ( iconX, iconY, iconG, iconG, "carsys/tacho/img/Light.png", 0, 0, 0, tocolor ( 0, 85, 200, 255 ), false )
	end

	iconX = iconX - 32 * Gsx
	dxDrawImage ( iconX, iconY, iconG, iconG, "carsys/tacho/img/State.png", 0, 0, 0,
				  isVehicleLocked ( veh ) and tocolor ( 0, 150, 0, 255 ) or tocolor ( 150, 0, 0, 255 ), false )

	iconX = iconX - 32 * Gsx
	zeichneGurt ( iconX, iconY, iconG )
end

---------------------------------------------------------------------
-- Rundtacho ( bisherige Fassung )
---------------------------------------------------------------------

local function zeichneRund ( veh, tempo, tank, lights, engine )
	local tankNadel = 180 / 100 * tank

	dxDrawImage ( 1550 * Gsx, 700 * Gsy, 400 * Gsx, 400 * Gsy, "carsys/tacho/img/Background.png", 0, 0, 0, tocolor(255,255,255,255), false )
	dxDrawImage ( 1620 * Gsx, 780 * Gsy, 280 * Gsx, 280 * Gsy, "carsys/tacho/img/Needle.png", tempo, 0, 0, tocolor(255,255,255,255), true )
	dxDrawImage ( 1535 * Gsx, 720 * Gsy, 240 * Gsx, 240 * Gsy, "carsys/tacho/img/TankNeedle.png", tankNadel, 0, 0, tocolor(255,255,255,255), true )

	if tank <= 15 then
		dxDrawImage ( 1620 * Gsx, 805 * Gsy, 25 * Gsx, 25 * Gsy, "carsys/tacho/img/TankWarning.png", 0, 0, 0, tocolor(255,255,255,255), false )
	end

	dxDrawImage ( 1750 * Gsx, 970 * Gsy, 35 * Gsx, 35 * Gsy, "carsys/tacho/img/State.png", 0, 0, 0,
				  isVehicleLocked ( veh ) and tocolor(0,150,0,255) or tocolor(150,0,0,255), false )

	zeichneGurt ( 1670 * Gsx, 922 * Gsy, 35 * Gsy )

	if lights then
		dxDrawImage ( 1705 * Gsx, 922 * Gsy, 35 * Gsx, 35 * Gsy, "carsys/tacho/img/Light.png", 0, 0, 0,
					  ( lights == 2 ) and tocolor(0,85,200,255) or tocolor(255,255,255,255), false )
	end

	if getElementData ( veh, "totalschaden" ) == 1 then
		dxDrawImage ( 1785 * Gsx, 922 * Gsy, 35 * Gsx, 35 * Gsy, "carsys/tacho/img/Engine.png", 0, 0, 0, tocolor(200,0,0,255), false )
	elseif engine == true then
		dxDrawImage ( 1785 * Gsx, 922 * Gsy, 35 * Gsx, 35 * Gsy, "carsys/tacho/img/Engine.png", 0, 0, 0, tocolor(200,85,0,255), false )
	else
		dxDrawImage ( 1785 * Gsx, 922 * Gsy, 35 * Gsx, 35 * Gsy, "carsys/tacho/img/Engine.png", 0, 0, 0, tocolor(255,255,255,255), false )
	end

	-- Digitale Zahl in der Scheibenmitte.
	if RUND_ZAHL then
		local zx = RUND_ZAHL_X * Gsx
		local zy = RUND_ZAHL_Y * Gsy
		local zahl = tostring ( math.floor ( tempo ) )

		-- Dunkle Kontur, damit die Zahl auf dem Zifferblatt lesbar bleibt.
		for dx = -1, 1 do
			for dy = -1, 1 do
				if dx ~= 0 or dy ~= 0 then
					dxDrawText ( zahl, zx + dx * 2 * Gsx, zy + dy * 2 * Gsy, zx + dx * 2 * Gsx, zy + dy * 2 * Gsy,
								 tocolor ( 0, 0, 0, 220 ), RUND_ZAHL_GR * Gsy, "default-bold", "center", "center", false, false, false )
				end
			end
		end

		dxDrawText ( zahl, zx, zy, zx, zy, FARBE_TEXT, RUND_ZAHL_GR * Gsy, "default-bold", "center", "center", false, false, false )

		dxDrawText ( "km/h", zx, zy + 26 * Gsy, zx, zy + 26 * Gsy,
					 FARBE_LEISE, 0.85 * Gsy, "default-bold", "center", "center", false, false, false )
	end
end

---------------------------------------------------------------------
-- Zeichnen
---------------------------------------------------------------------

function drawSpeedo ()
	local veh = getPedOccupiedVehicle ( localPlayer )
	if not isElement ( veh ) then
		return
	end

	local tank   = tonumber ( getElementData ( veh, "fuelstate" ) ) or 0
	local tempo  = getElementSpeed ( veh, "km/h" ) or 0
	local lights = getVehicleOverrideLights ( veh )
	local engine = getVehicleEngineState ( veh )

	if TACHO_STIL == "modern" then
		zeichneModern ( veh, tempo, tank, lights, engine )
	elseif TACHO_STIL == "digital" then
		zeichneDigital ( veh, tempo, tank, lights, engine )
	else
		zeichneRund ( veh, tempo, tank, lights, engine )
	end
end

-- Der Handler wird beim Ein- und Aussteigen gesetzt und entfernt. Vorher
-- entfernte drawSpeedo sich mitten im Zeichnen selbst, sobald der Spieler
-- nicht mehr im Fahrzeug sass - dabei wird eine Liste veraendert, ueber die
-- MTA gerade laeuft. Jetzt beendet die Funktion in dem Fall einfach still.
local function speedoAn ()
	removeEventHandler ( "onClientRender", root, drawSpeedo )
	addEventHandler ( "onClientRender", root, drawSpeedo )
end

local function speedoAus ()
	removeEventHandler ( "onClientRender", root, drawSpeedo )
end

addEventHandler ( "onClientVehicleEnter", root, function ( player )
	if player == localPlayer then
		speedoAn ()
	end
end )

addEventHandler ( "onClientVehicleExit", root, function ( player )
	if player == localPlayer then
		speedoAus ()
	end
end )

-- Beim Tod oder beim Herausbeamen kommt kein onClientVehicleExit.
addEventHandler ( "onClientPlayerWasted", localPlayer, speedoAus )

