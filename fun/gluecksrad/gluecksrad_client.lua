--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Gluecksrad - Client ( 3D-Weltrad + Ticketmenue )||
--\\                                                  //

local GR_SPIN_DURATION = 6000   -- muss mit dem Server uebereinstimmen
local GR_SPIN_TURNS    = 6      -- volle Umdrehungen vor dem Auslaufen

-- Eingemessener Standort: Boden liegt bei z = 27.680, die Nabe entsprechend
-- einen Radradius darueber. Aendert sich GR_RADIUS, muss GR_Z mitwandern.
local GR_X, GR_Y, GR_Z = -1990.244, 95.130, 28.280   -- Mittelpunkt des Rades
local GR_ROTATION      = 90                     -- Blickrichtung des Rades in Grad
local GR_RADIUS        = 1.5                    -- Radius des Rades in Metern, /radface
local GR_STAND_HEIGHT  = 2.6                    -- Hoehe des Standfusses unter der Nabe
local GR_RANGE         = 6                      -- Interaktionsreichweite in Metern
local GR_DRAW_RANGE    = 70                     -- ab hier wird gar nicht mehr gezeichnet

-- Ausstellungspodest neben dem Rad. Das Fahrzeug ist ein rein clientseitiges
-- Element: niemand kann einsteigen, es wird nicht synchronisiert und kostet
-- den Server nichts.
-- Welches Fahrzeug ausgestellt wird, bestimmt allein der Server ueber seine
-- Liste GR_CAR_LIST - hier steht bewusst KEIN Wert. Ein Platzhalter waere eine
-- zweite Quelle fuer dieselbe Angabe: bliebe die Antwort des Servers einmal
-- aus, stuende am Podest ein anderes Fahrzeug, als tatsaechlich vergeben wird.
-- Bis die Antwort da ist, steht schlicht nichts auf dem Podest.
local GR_CAR_MODEL   = 0
local GR_CAR_POS     = { -1986.458, 94.970, 26.680 }   -- Standort, z ist der Boden
local GR_CAR_HEIGHT  = 1.1    -- Hoehe ueber dem Boden
local GR_CAR_SPEED   = 12     -- Grad pro Sekunde
local GR_CAR_LABEL   = "HAUPTGEWINN"

-- Schild ueber dem Rad. Aus, weil die Schrift im schmalen Format gequetscht
-- wirkt und der Hinweistext darueber liegt.
local GR_SIGN_SHOW   = false
local GR_SIGN_TEXT   = "GLUECKSRAD"
local GR_SIGN_WIDTH  = 3.2    -- Breite in Metern
local GR_SIGN_ABOVE  = 0.75   -- Abstand ueber der Radoberkante

-- Beschriftung. Sie wird in eigene Texturen gemalt und dann gedreht gezeichnet,
-- damit sie radial im Segment sitzt statt quer darueber - dadurch passt mehr
-- Text hinein und die Schrift kann groesser sein.
local GR_LABEL_W     = 300   -- Breite der Schrifttextur
local GR_LABEL_H     = 72    -- Hoehe der Schrifttextur
local GR_LABEL_SCALE = 2.1   -- Schriftgroesse
local GR_LABEL_ANGLE = 90    -- Grunddrehung. 90 = radial, 0 = quer wie vorher
-- Aus: sonst springt die Schrift um 180 Grad, sobald ein Segment die linke
-- Haelfte erreicht. Sie dreht sich jetzt gleichmaessig mit dem Rad mit.
local GR_LABEL_FLIP  = false

-- Klaenge. Alle drei Dateien liegen schon im Ordner sounds und stehen in der
-- meta.xml beim Downloader, werden also bereits an die Clients ausgeliefert.
local GR_SOUND_TICK  = "sounds/click.wav"     -- pro ueberfahrenem Segment
local GR_SOUND_WIN   = "sounds/kaching.mp3"   -- normaler Gewinn
local GR_SOUND_BIG   = "sounds/bell.ogg"      -- Jackpot, Auto, Premium
local GR_SOUND_LOSE  = "sounds/click.wav"     -- Niete, langsamer abgespielt
local GR_LOSE_SPEED  = 0.4    -- unter 1 wird der Ton tiefer und dumpfer
local GR_SOUND_RANGE = 30     -- Hoerweite in Metern

local GR_RT_SIZE    = 1024   -- hohe Aufloesung gegen ausgefranste Kanten
local GR_BULB_COUNT = 16
local GR_BLINK_TIME = 450

-- Das Rad ist ein echtes Objekt: GTA SA bringt das Casino-Gluecksrad aus
-- Las Venturas als "wheel_o_fortune" mit, der zugehoerige Standfuss ist
-- "wheel_table". Unsere Gewinnsegmente werden per Shader auf die Radtextur
-- gelegt, gedreht wird das Element selbst.
-- Aus: das Rad wird komplett selbst gezeichnet und braucht kein Modell.
-- An:  das native Casino-Rad wird als Objekt genutzt. Umschalten mit /radobjekt.
local GR_USE_OBJECT  = false

local GR_MODEL       = 1895   -- wheel_o_fortune, /radmodel <id>
local GR_TABLE_MODEL = 1896   -- wheel_table ( Standfuss ), 0 = keiner
local GR_TABLE_OFFSET = -1.0  -- Hoehe des Standfusses relativ zur Nabe

local GR_SCALE     = 1.0    -- Groesse des Objekts, /radscale <zahl>
local GR_SPIN_AXIS = "y"    -- Achse, um die sich das Rad dreht, /radaxis x|y|z
local GR_BASE_RX   = 0      -- Grundausrichtung des Objekts
local GR_BASE_RY   = 0
local GR_BASE_RZ   = GR_ROTATION

-- Wie die Gewinnscheibe auf das Modell kommt:
--   "overlay" - sie wird als Flaeche direkt vor die Radflaeche gelegt.
--               Braucht kein Wissen ueber das UV-Layout, nur Abstand und
--               Groesse. Das ist der empfohlene Weg.
--   "shader"  - sie wird in die Modelltextur hineingerechnet. Sieht bei
--               richtig eingestelltem UV am saubersten aus, muss dafuer aber
--               mit /raduv eingemessen werden.
local GR_FACE_MODE   = "overlay"
local GR_FACE_OFFSET = 0.0    -- Abstand der Scheibe vor der Radflaeche
local GR_FACE_RADIUS = GR_RADIUS   -- Radius der Scheibe in Metern, /radface

-- Welche Textur des Modells ueberschrieben wird. "*" trifft alle - dann wird
-- auch der Rahmen des Modells uebermalt. Mit /radtexlist siehst du die echten
-- Texturnamen, mit /radtex <name> setzt du gezielt eine davon.
local GR_TEXTURE = "*"

-- Wo die Gewinnscheibe innerhalb der Modelltextur sitzt. Das UV-Layout des
-- Originalmodells ist von aussen nicht sichtbar, deshalb sind Mittelpunkt,
-- Radius und Drehung frei einstellbar - im Spiel mit /raduv und /raduvrot,
-- zur Kontrolle /raduvgrid.
local GR_UV_CX  = 0.5    -- Mittelpunkt X, 0..1 der Texturbreite
local GR_UV_CY  = 0.5    -- Mittelpunkt Y, 0..1 der Texturhoehe
local GR_UV_R   = 0.48   -- Radius, Anteil der Texturbreite
local GR_UV_ROT = 0      -- Grunddrehung der Scheibe in Grad

local GR_BACKGROUND = { 16, 18, 24 }   -- Fuellfarbe ausserhalb der Scheibe
local GR_SHOW_GRID  = false            -- Ausrichtungshilfe einblenden

-- Optionales fertiges Radbild. Liegt hier ein Dateiname, wird das Bild statt
-- der gezeichneten Segmente verwendet. Es muss quadratisch sein, das Rad muss
-- die Flaeche ausfuellen und der Hintergrund transparent sein ( PNG ).
-- Die Datei zusaetzlich in der meta.xml als <file> eintragen.
local GR_WHEEL_IMAGE = "fun/gluecksrad/rad.png"

-- Sollen die Betraege trotz Bild darueber geschrieben werden? Bei einem Bild
-- mit eigenen Aufschriften auf false setzen - dann muss die Segmentzahl des
-- Bildes aber zur Gewinntabelle passen.
-- Aus, weil die Beschriftung im Overlay-Modus ohnehin pro Bild aufgesetzt
-- wird - sonst stuende sie doppelt da, einmal davon mitgedreht.
local GR_IMAGE_LABELS = false

-- Gezeichneter Goldrahmen mit Blinklampen, Zeiger und Standfuss. Ohne Modell
-- werden alle drei gebraucht - nutzt man das native Objekt, bringt es sie
-- selbst mit und man schaltet sie mit /raddeko ab.
local GR_DECO_RIM    = true
local GR_DECO_MARKER = true
-- Der gezeichnete Standfuss liegt je nach Blickseite vor dem Rad statt
-- dahinter und verdeckt es dann. Standardmaessig aus, mit /raddeko fuss an.
local GR_DECO_STAND  = false

-- Reihenfolge muss identisch zur Servertabelle sein.
-- Reihenfolge und Anzahl muessen exakt zur Servertabelle passen, sonst zeigt
-- das Rad etwas anderes an, als tatsaechlich ausgezahlt wird.
-- "farbe" ist optional und uebersteuert die Standardfarbe des Segments.
-- "klang" steuert nur den Ton am Ende der Drehung:
-- nichts = normaler Gewinn, "niete" = Fehlschlag, "gross" = Hauptgewinn.
local grSegments = {
	{ label = "500" },
	{ label = "7 Tage Premium", farbe = { 120, 90, 200 }, klang = "gross" },
	{ label = "NIETE", farbe = { 70, 74, 84 }, klang = "niete" },
	{ label = "5 Benzin" },
	{ label = "1.000" },
	{ label = "10 Zigaretten" },
	{ label = "2.500" },
	{ label = "Geschenk" },
	{ label = "1.000 Chips" },
	{ label = "5.000" },
	{ label = "1 Ticket", farbe = { 190, 70, 150 } },
	{ label = "10.000" },
	{ label = "500 Coins", farbe = { 60, 170, 190 } },
	{ label = "JACKPOT", farbe = { 214, 170, 30 }, klang = "gross" },
	{ label = "AUTO", farbe = { 220, 40, 60 }, klang = "gross" },
}

-- Kraeftige Jahrmarkt-Farben, jeweils als Paar aus Grund- und Glanzton.
local GR_COLORS = {
	{ {  38, 122, 196 }, {  62, 158, 235 } },
	{ { 214,  48,  49 }, { 245,  86,  86 } },
	{ { 240, 190,  40 }, { 255, 216,  92 } },
	{ {  46, 150,  84 }, {  76, 190, 116 } },
	{ { 224, 122,  30 }, { 250, 158,  66 } },
	{ { 134,  70, 178 }, { 168, 106, 214 } },
}

local GR_GOLD_DARK  = { 148, 104, 22 }
local GR_GOLD_LIGHT = { 252, 214, 104 }

local rtWheel   = nil   -- Segmentscheibe, unrotiert
local rtFrame   = nil   -- im Overlay-Modus die pro Frame gedrehte Fassung
local rtRim     = { nil, nil }   -- statischer Rahmen, zwei Blinkphasen
local rtMarker  = nil   -- Zeiger
local rtStand   = nil   -- Standfuss

local grWheelImage = nil   -- optionales fertiges Radbild
local grCar      = nil   -- ausgestelltes Fahrzeug
local grCarAngle = 0
local grCarLastTick = nil
local rtPodium   = nil   -- Bodenscheibe unter dem Fahrzeug
local rtSign     = nil   -- Schild ueber dem Rad
local rtLabels   = {}    -- je Segment eine fertige Schrifttextur

local grObject  = nil   -- das eigentliche Radobjekt
local grTable   = nil   -- Standfuss
local grShader  = nil

local grAngle      = 0
local grSpinning   = false
local grSpinStart  = 0
local grSpinFrom   = 0
local grSpinDelta  = 0
local grSpinIndex  = nil   -- Ergebnis der laufenden Drehung, fuer den Abschlusston
local grLastTickStep = nil -- letztes ueberfahrenes Segment, fuer das Ticken

local grCooldown   = 0
local grCooldownAt = 0
local grTickets    = 0
local grTicketPrice = 0
local grTicketsLeft  = -1   -- -1 = unbegrenzt
local grTicketsPerPeriod = 0
local grPeriodReset = 0   -- Sekunden bis zum naechsten Zeitraum

local grInRange    = false
local grMenuOpen   = false
local grButtons    = {}
local grBound      = false

local faceX = math.cos ( math.rad ( GR_ROTATION ) )
local faceY = math.sin ( math.rad ( GR_ROTATION ) )

---------------------------------------------------------------------
-- Zeichenhilfen
---------------------------------------------------------------------

-- Gefuellte Kreisflaeche aus radialen Linien. Der Schrittwinkel wird aus dem
-- Radius abgeleitet, damit auch grosse Kreise keine Luecken bekommen.
local function drawDisc ( cx, cy, radius, color )
	local step = math.min ( 0.5, 28 / math.max ( radius, 1 ) )
	local a = 0
	while a < 360 do
		local rad = math.rad ( a )
		dxDrawLine ( cx, cy, cx + math.sin ( rad ) * radius, cy - math.cos ( rad ) * radius, color, 2 )
		a = a + step
	end
end

local function drawRing ( cx, cy, radius, width, color )
	local step = math.min ( 0.6, 40 / math.max ( radius, 1 ) )
	local a = 0
	while a < 360 do
		local r1, r2 = math.rad ( a ), math.rad ( a + step * 1.6 )
		dxDrawLine ( cx + math.sin ( r1 ) * radius, cy - math.cos ( r1 ) * radius,
					 cx + math.sin ( r2 ) * radius, cy - math.cos ( r2 ) * radius, color, width )
		a = a + step
	end
end

local function drawSegment ( cx, cy, radius, startAngle, endAngle, color )
	local step = math.min ( 0.3, 20 / math.max ( radius, 1 ) )
	local a = startAngle
	while a <= endAngle do
		local rad = math.rad ( a )
		dxDrawLine ( cx, cy, cx + math.sin ( rad ) * radius, cy - math.cos ( rad ) * radius, color, 2 )
		a = a + step
	end
end

-- Gefuellter fuenfzackiger Stern. Der Rand wird aus zehn Eckpunkten gebildet
-- und die Flaeche vom Mittelpunkt aus mit Linien zu diesem Rand gefuellt.
local function drawStar ( cx, cy, outer, inner, color, rotation )
	rotation = rotation or 0

	local points = {}
	for k = 0, 9 do
		local radius = ( k % 2 == 0 ) and outer or inner
		local rad = math.rad ( rotation + k * 36 )
		points[k + 1] = { cx + math.sin ( rad ) * radius, cy - math.cos ( rad ) * radius }
	end

	for k = 1, 10 do
		local a = points[k]
		local b = points[( k % 10 ) + 1]

		local steps = math.max ( 6, math.floor ( outer ) )
		for s = 0, steps do
			local t = s / steps
			dxDrawLine ( cx, cy, a[1] + ( b[1] - a[1] ) * t, a[2] + ( b[2] - a[2] ) * t, color, 2 )
		end
	end
end

-- Schrift mit umlaufender Kontur. Ein einzelner Schlagschatten reicht nicht:
-- auf hellen Segmenten verschwindet der Text sonst im Untergrund.
local function shadedText ( text, x, y, scale, color )
	local outline = tocolor ( 0, 0, 0, 235 )
	local offset = math.max ( 2, math.floor ( scale * 2 ) )

	for dx = -1, 1 do
		for dy = -1, 1 do
			if dx ~= 0 or dy ~= 0 then
				dxDrawText ( text, x - 90 + dx * offset, y - 22 + dy * offset, x + 90 + dx * offset, y + 22 + dy * offset,
							 outline, scale, "default-bold", "center", "center", false, false, false, false )
			end
		end
	end

	dxDrawText ( text, x - 90, y - 22, x + 90, y + 22, color, scale, "default-bold", "center", "center", false, false, false, false )
end

---------------------------------------------------------------------
-- Texturen
---------------------------------------------------------------------

local function getSegmentLabel ( index )
	return grSegments[index].label or "?"
end

local function buildWheelTexture ()
	if not rtWheel then
		return
	end

	local cx = GR_UV_CX * GR_RT_SIZE
	local cy = GR_UV_CY * GR_RT_SIZE
	local radius = GR_UV_R * GR_RT_SIZE
	local count = #grSegments
	local step = 360 / count

	dxSetRenderTarget ( rtWheel, true )

	-- Nur im Shader-Modus wird die Flaeche gefuellt, damit keine Reste der
	-- Modelltextur durchscheinen. Im Overlay-Modus muss ausserhalb der Scheibe
	-- alles durchsichtig bleiben - sonst steht ein dunkles Rechteck im Bild.
	if GR_FACE_MODE == "shader" then
		dxDrawRectangle ( 0, 0, GR_RT_SIZE, GR_RT_SIZE, tocolor ( GR_BACKGROUND[1], GR_BACKGROUND[2], GR_BACKGROUND[3], 255 ) )
	end

	-- Fertiges Radbild statt gezeichneter Segmente.
	if grWheelImage then
		dxDrawImage ( cx - radius, cy - radius, radius * 2, radius * 2, grWheelImage,
					  GR_UV_ROT, 0, 0, tocolor ( 255, 255, 255, 255 ) )

		if GR_IMAGE_LABELS then
			for i = 1, count do
				local rad = math.rad ( GR_UV_ROT + ( i - 1 ) * step + step / 2 )
				local tx = cx + math.sin ( rad ) * ( radius * 0.66 )
				local ty = cy - math.cos ( rad ) * ( radius * 0.66 )

				shadedText ( getSegmentLabel ( i ), tx, ty, 2.1, tocolor ( 255, 255, 255, 255 ) )
			end
		end

		if GR_SHOW_GRID then
			drawRing ( cx, cy, radius, 5, tocolor ( 0, 255, 255, 220 ) )
		end

		dxSetRenderTarget ()
		return
	end

	for i = 1, count do
		local palette = GR_COLORS[( ( i - 1 ) % #GR_COLORS ) + 1]
		local base, shine = palette[1], palette[2]

		-- Jackpot und Niete bekommen eine eigene, wiedererkennbare Farbe.
		if grSegments[i].farbe then
			base = grSegments[i].farbe
			shine = { math.min ( 255, base[1] + 40 ), math.min ( 255, base[2] + 40 ), math.min ( 255, base[3] + 40 ) }
		end

		local startAngle = GR_UV_ROT + ( i - 1 ) * step

		drawSegment ( cx, cy, radius, startAngle, startAngle + step, tocolor ( base[1], base[2], base[3], 255 ) )

		-- Weicher Glanz zur Segmentmitte hin. Der Streifen war vorher zu schmal
		-- und zu kraeftig - er sah aus wie ein eigenes, zweites Segment.
		for s = 1, 6 do
			local spread = step * 0.5 * ( s / 6 )
			drawSegment ( cx, cy, radius * 0.97, startAngle + step * 0.5 - spread, startAngle + step * 0.5 + spread,
						  tocolor ( shine[1], shine[2], shine[3], 12 ) )
		end
	end

	-- Trennstege zwischen den Segmenten
	for i = 1, count do
		local rad = math.rad ( GR_UV_ROT + ( i - 1 ) * step )
		dxDrawLine ( cx, cy, cx + math.sin ( rad ) * radius, cy - math.cos ( rad ) * radius,
					 tocolor ( 255, 255, 255, 230 ), 5 )
	end

	-- Abdunklung nach aussen als weicher Verlauf
	for i = 0, 14 do
		drawRing ( cx, cy, radius - i, 3, tocolor ( 0, 0, 0, 10 + i * 3 ) )
	end

	-- Beschriftung nur im Shader-Modus mit einbacken. Im Overlay-Modus wird sie
	-- pro Bild separat aufgesetzt, damit sie beim Drehen aufrecht bleibt -
	-- dxDrawText kann Text nicht rotieren, eine mitgedrehte Schrift stuende
	-- sonst je nach Endstellung auf dem Kopf.
	if GR_FACE_MODE == "shader" then
		for i = 1, count do
			local rad = math.rad ( GR_UV_ROT + ( i - 1 ) * step + step / 2 )
			local tx = cx + math.sin ( rad ) * ( radius * 0.66 )
			local ty = cy - math.cos ( rad ) * ( radius * 0.66 )

			shadedText ( getSegmentLabel ( i ), tx, ty, 1.6, tocolor ( 255, 255, 255, 255 ) )
		end
	end

	-- Nabe: Goldrand, heller Kern, darin ein goldener Stern
	drawDisc ( cx, cy, radius * 0.15, tocolor ( GR_GOLD_DARK[1], GR_GOLD_DARK[2], GR_GOLD_DARK[3], 255 ) )
	drawDisc ( cx, cy, radius * 0.13, tocolor ( 252, 250, 244, 255 ) )
	drawStar ( cx, cy, radius * 0.11, radius * 0.045,
			   tocolor ( GR_GOLD_DARK[1], GR_GOLD_DARK[2], GR_GOLD_DARK[3], 255 ), 0 )
	drawStar ( cx, cy, radius * 0.095, radius * 0.038,
			   tocolor ( GR_GOLD_LIGHT[1], GR_GOLD_LIGHT[2], GR_GOLD_LIGHT[3], 255 ), 0 )

	-- Ausrichtungshilfe: zeigt Texturrand, Mitte und Scheibenkante an.
	if GR_SHOW_GRID then
		dxDrawLine ( 0, cy, GR_RT_SIZE, cy, tocolor ( 255, 0, 255, 200 ), 3 )
		dxDrawLine ( cx, 0, cx, GR_RT_SIZE, tocolor ( 255, 0, 255, 200 ), 3 )
		drawRing ( cx, cy, radius, 5, tocolor ( 0, 255, 255, 220 ) )
		dxDrawLine ( 2, 2, GR_RT_SIZE - 2, 2, tocolor ( 255, 255, 0, 220 ), 5 )
		dxDrawLine ( 2, GR_RT_SIZE - 2, GR_RT_SIZE - 2, GR_RT_SIZE - 2, tocolor ( 255, 255, 0, 220 ), 5 )
		dxDrawLine ( 2, 2, 2, GR_RT_SIZE - 2, tocolor ( 255, 255, 0, 220 ), 5 )
		dxDrawLine ( GR_RT_SIZE - 2, 2, GR_RT_SIZE - 2, GR_RT_SIZE - 2, tocolor ( 255, 255, 0, 220 ), 5 )
	end

	dxSetRenderTarget ()
end

-- Der Rahmen dreht sich nicht mit, deshalb liegt er in einer eigenen Textur.
-- Zwei Phasen erlauben blinkende Lampen ohne Neuzeichnen pro Frame.
local function buildRimTexture ( phase )
	local target = rtRim[phase]
	if not target then
		return
	end

	local center = GR_RT_SIZE / 2
	local radius = center - 40

	dxSetRenderTarget ( target, true )

	drawRing ( center, center, radius + 16, 34, tocolor ( GR_GOLD_DARK[1], GR_GOLD_DARK[2], GR_GOLD_DARK[3], 255 ) )
	drawRing ( center, center, radius + 12, 14, tocolor ( GR_GOLD_LIGHT[1], GR_GOLD_LIGHT[2], GR_GOLD_LIGHT[3], 255 ) )
	drawRing ( center, center, radius + 26, 6, tocolor ( 70, 46, 10, 220 ) )

	for i = 1, GR_BULB_COUNT do
		local rad = math.rad ( ( i - 1 ) * ( 360 / GR_BULB_COUNT ) )
		local bx = center + math.sin ( rad ) * ( radius + 16 )
		local by = center - math.cos ( rad ) * ( radius + 16 )

		local lit = ( ( i % 2 ) == ( phase % 2 ) )

		if lit then
			drawDisc ( bx, by, 22, tocolor ( 255, 235, 170, 45 ) )
			drawDisc ( bx, by, 14, tocolor ( 255, 246, 210, 120 ) )
			drawDisc ( bx, by, 9, tocolor ( 255, 255, 245, 255 ) )
		else
			drawDisc ( bx, by, 9, tocolor ( 168, 150, 108, 220 ) )
			drawDisc ( bx, by, 5, tocolor ( 210, 198, 160, 220 ) )
		end
	end

	dxSetRenderTarget ()
end

local function buildMarkerTexture ()
	if not rtMarker then
		return
	end

	dxSetRenderTarget ( rtMarker, true )

	-- Nach unten zeigender Zeiger mit Goldrand
	for y = 0, 127 do
		local half = 60 - ( y * 0.46 )
		if half > 0 then
			dxDrawLine ( 64 - half, y, 64 + half, y, tocolor ( GR_GOLD_DARK[1], GR_GOLD_DARK[2], GR_GOLD_DARK[3], 255 ), 2 )
			if half > 8 then
				dxDrawLine ( 64 - half + 6, y, 64 + half - 6, y, tocolor ( 232, 232, 236, 255 ), 2 )
			end
		end
	end

	dxSetRenderTarget ()
end

local function buildStandTexture ()
	if not rtStand then
		return
	end

	dxSetRenderTarget ( rtStand, true )

	-- Zwei nach unten auseinanderlaufende Beine plus Bodenbalken
	dxDrawLine ( 256, 20, 96, 470, tocolor ( 92, 62, 34, 255 ), 46 )
	dxDrawLine ( 256, 20, 416, 470, tocolor ( 92, 62, 34, 255 ), 46 )
	dxDrawLine ( 256, 22, 104, 466, tocolor ( 126, 88, 50, 255 ), 18 )
	dxDrawLine ( 256, 22, 408, 466, tocolor ( 126, 88, 50, 255 ), 18 )
	dxDrawLine ( 70, 486, 442, 486, tocolor ( 78, 52, 28, 255 ), 40 )
	dxDrawLine ( 70, 478, 442, 478, tocolor ( 116, 80, 46, 255 ), 12 )

	drawDisc ( 256, 24, 40, tocolor ( GR_GOLD_DARK[1], GR_GOLD_DARK[2], GR_GOLD_DARK[3], 255 ) )

	dxSetRenderTarget ()
end

-- Eine Schrifttextur je Segment. Sie werden einmalig erzeugt und danach nur
-- noch gedreht gezeichnet.
local function buildLabelTextures ()
	for i = 1, #grSegments do
		if not isElement ( rtLabels[i] ) then
			rtLabels[i] = dxCreateRenderTarget ( GR_LABEL_W, GR_LABEL_H, true )
		end

		if rtLabels[i] then
			dxSetRenderTarget ( rtLabels[i], true )
			shadedText ( getSegmentLabel ( i ), GR_LABEL_W / 2, GR_LABEL_H / 2,
						 GR_LABEL_SCALE, tocolor ( 255, 255, 255, 255 ) )
			dxSetRenderTarget ()
		end
	end
end

-- Schild ueber dem Rad.
local function buildSignTexture ()
	if not rtSign then
		return
	end

	dxSetRenderTarget ( rtSign, true )

	dxDrawRectangle ( 0, 0, 512, 160, tocolor ( GR_GOLD_DARK[1], GR_GOLD_DARK[2], GR_GOLD_DARK[3], 255 ) )
	dxDrawRectangle ( 8, 8, 496, 144, tocolor ( 24, 26, 34, 250 ) )
	dxDrawRectangle ( 8, 8, 496, 4, tocolor ( GR_GOLD_LIGHT[1], GR_GOLD_LIGHT[2], GR_GOLD_LIGHT[3], 255 ) )
	dxDrawRectangle ( 8, 148, 496, 4, tocolor ( GR_GOLD_LIGHT[1], GR_GOLD_LIGHT[2], GR_GOLD_LIGHT[3], 255 ) )

	-- Kleine Lampen wie am Rahmen des Rades
	for i = 0, 9 do
		local bx = 34 + i * 50
		drawDisc ( bx, 22, 9, tocolor ( 255, 246, 210, 200 ) )
		drawDisc ( bx, 138, 9, tocolor ( 255, 246, 210, 200 ) )
	end

	dxDrawText ( GR_SIGN_TEXT, 0, 30, 512, 130, tocolor ( GR_GOLD_LIGHT[1], GR_GOLD_LIGHT[2], GR_GOLD_LIGHT[3], 255 ),
				 2.6, "default-bold", "center", "center", false, false, false, false )

	dxSetRenderTarget ()
end

-- Leuchtende Bodenscheibe, auf der das Fahrzeug steht.
local function buildPodiumTexture ()
	if not rtPodium then
		return
	end

	dxSetRenderTarget ( rtPodium, true )

	drawDisc ( 256, 256, 250, tocolor ( GR_GOLD_DARK[1], GR_GOLD_DARK[2], GR_GOLD_DARK[3], 220 ) )
	drawDisc ( 256, 256, 232, tocolor ( 30, 32, 40, 235 ) )
	drawRing ( 256, 256, 200, 10, tocolor ( GR_GOLD_LIGHT[1], GR_GOLD_LIGHT[2], GR_GOLD_LIGHT[3], 200 ) )
	drawStar ( 256, 256, 70, 28, tocolor ( GR_GOLD_LIGHT[1], GR_GOLD_LIGHT[2], GR_GOLD_LIGHT[3], 120 ), 0 )

	dxSetRenderTarget ()
end

-- Standort des Podests. Fest eingemessen, unabhaengig vom Rad - so laesst
-- sich das Rad spaeter verschieben, ohne dass die Ausstellung mitwandert.
local function getCarPosition ()
	return GR_CAR_POS[1], GR_CAR_POS[2], GR_CAR_POS[3]
end

local function destroyPrizeCar ()
	if isElement ( grCar ) then
		destroyElement ( grCar )
	end
	grCar = nil
end

local function createPrizeCar ()
	destroyPrizeCar ()

	if not GR_CAR_MODEL or GR_CAR_MODEL <= 0 then
		return
	end

	local x, y, groundZ = getCarPosition ()

	grCar = createVehicle ( GR_CAR_MODEL, x, y, groundZ + GR_CAR_HEIGHT )
	if not grCar then
		outputDebugString ( "[Gluecksrad] Ausstellungsfahrzeug "..GR_CAR_MODEL.." konnte nicht erstellt werden.", 1 )
		return
	end

	-- Reine Deko: eingefroren und ohne Kollision.
	-- Achtung: setVehicleDamageProof, setVehicleLocked und
	-- setVehicleEngineState gibt es clientseitig nicht - der Aufruf wuerde das
	-- ganze Skript abbrechen. Bei einem rein clientseitigen Fahrzeug braucht
	-- es sie ohnehin nicht, weil niemand einsteigen oder darauf schiessen kann.
	setElementFrozen ( grCar, true )
	setElementCollisionsEnabled ( grCar, false )
end

local function createTextures ()
	rtWheel   = dxCreateRenderTarget ( GR_RT_SIZE, GR_RT_SIZE, true )
	rtFrame   = dxCreateRenderTarget ( GR_RT_SIZE, GR_RT_SIZE, true )
	rtRim[1]  = dxCreateRenderTarget ( GR_RT_SIZE, GR_RT_SIZE, true )
	rtRim[2]  = dxCreateRenderTarget ( GR_RT_SIZE, GR_RT_SIZE, true )
	rtMarker  = dxCreateRenderTarget ( 128, 128, true )
	rtStand   = dxCreateRenderTarget ( 512, 512, true )
	rtPodium  = dxCreateRenderTarget ( 512, 512, true )
	rtSign    = dxCreateRenderTarget ( 512, 160, true )

	if not rtWheel or not rtFrame or not rtRim[1] or not rtRim[2] or not rtMarker or not rtStand then
		outputDebugString ( "[Gluecksrad] Render-Targets konnten nicht erstellt werden.", 1 )
		return false
	end

	return true
end

---------------------------------------------------------------------
-- Radobjekt
---------------------------------------------------------------------

local function applyWheelRotation ()
	-- Im Overlay-Modus dreht sich die vorgelegte Scheibe, nicht das Modell.
	if GR_FACE_MODE == "overlay" or not isElement ( grObject ) then
		return
	end

	local rx, ry, rz = GR_BASE_RX, GR_BASE_RY, GR_BASE_RZ

	if GR_SPIN_AXIS == "x" then
		rx = rx + grAngle
	elseif GR_SPIN_AXIS == "z" then
		rz = rz + grAngle
	else
		ry = ry + grAngle
	end

	setElementRotation ( grObject, rx % 360, ry % 360, rz % 360 )
end

local function destroyWheelObject ()
	if isElement ( grShader ) then
		destroyElement ( grShader )
	end
	grShader = nil

	if isElement ( grObject ) then
		destroyElement ( grObject )
	end
	grObject = nil

	if isElement ( grTable ) then
		destroyElement ( grTable )
	end
	grTable = nil
end

local function createWheelObject ()
	destroyWheelObject ()

	-- Ohne Modell besteht das Rad ausschliesslich aus gezeichneten Ebenen.
	if not GR_USE_OBJECT then
		return true
	end

	grObject = createObject ( GR_MODEL, GR_X, GR_Y, GR_Z, GR_BASE_RX, GR_BASE_RY, GR_BASE_RZ, true )
	if not grObject then
		outputDebugString ( "[Gluecksrad] Radobjekt konnte nicht erstellt werden.", 1 )
		return false
	end

	setObjectScale ( grObject, GR_SCALE )
	setElementCollisionsEnabled ( grObject, false )

	if GR_TABLE_MODEL and GR_TABLE_MODEL > 0 then
		grTable = createObject ( GR_TABLE_MODEL, GR_X, GR_Y, GR_Z + GR_TABLE_OFFSET, 0, 0, GR_BASE_RZ, true )
		if grTable then
			setObjectScale ( grTable, GR_SCALE )
		end
	end

	-- Nur im Shader-Modus wird die Modelltextur angefasst. Im Overlay-Modus
	-- bleibt das Modell unveraendert und die Scheibe wird davorgelegt.
	if GR_FACE_MODE == "shader" then
		-- Der Shader tauscht nur die Textur dieses einen Objekts aus, nicht die
		-- aller Objekte mit demselben Modell.
		grShader = dxCreateShader ( "fun/gluecksrad/gluecksrad.fx", 0, 0, false, "object" )
		if grShader then
			dxSetShaderValue ( grShader, "gTexture", rtWheel )
			engineApplyShaderToWorldTexture ( grShader, GR_TEXTURE, grObject )
		else
			outputDebugString ( "[Gluecksrad] Shader konnte nicht erstellt werden - Rad bleibt untexturiert.", 2 )
		end
	end

	applyWheelRotation ()
	return true
end

local function loadWheelImage ()
	if isElement ( grWheelImage ) then
		destroyElement ( grWheelImage )
	end
	grWheelImage = nil

	if not GR_WHEEL_IMAGE or GR_WHEEL_IMAGE == "" then
		return
	end

	if not fileExists ( GR_WHEEL_IMAGE ) then
		outputDebugString ( "[Gluecksrad] Radbild "..GR_WHEEL_IMAGE.." nicht gefunden - zeichne die Segmente selbst.", 2 )
		return
	end

	grWheelImage = dxCreateTexture ( GR_WHEEL_IMAGE, "argb", true, "clamp" )
	if not grWheelImage then
		outputDebugString ( "[Gluecksrad] Radbild "..GR_WHEEL_IMAGE.." konnte nicht geladen werden.", 1 )
	end
end

local function buildAllTextures ()
	loadWheelImage ()
	buildWheelTexture ()
	buildRimTexture ( 1 )
	buildRimTexture ( 2 )
	buildMarkerTexture ()
	buildStandTexture ()
	buildPodiumTexture ()
	buildSignTexture ()
	buildLabelTextures ()
end

---------------------------------------------------------------------
-- Menue
---------------------------------------------------------------------

-- Restzeiten passend zur Groessenordnung ausgeben. Muss zur gleichnamigen
-- Funktion im Server passen, damit Chat und Anzeige dasselbe sagen.
local function formatDuration ( seconds )
	if seconds >= 86400 then
		local tage = math.ceil ( seconds / 86400 )
		return ( tage == 1 ) and "einem Tag" or ( tage.." Tagen" )
	end

	if seconds >= 3600 then
		local stunden = math.ceil ( seconds / 3600 )
		return ( stunden == 1 ) and "einer Stunde" or ( stunden.." Stunden" )
	end

	if seconds >= 60 then
		local minuten = math.ceil ( seconds / 60 )
		return ( minuten == 1 ) and "einer Minute" or ( minuten.." Minuten" )
	end

	local sekunden = math.max ( 1, math.ceil ( seconds ) )
	return ( sekunden == 1 ) and "einer Sekunde" or ( sekunden.." Sekunden" )
end

local function getCooldownRemaining ()
	local remaining = grCooldown - ( getTickCount () - grCooldownAt ) / 1000
	if remaining <= 0 then
		return 0
	end
	return remaining
end

local function closeMenu ()
	if not grMenuOpen then
		return
	end

	grMenuOpen = false
	grButtons = {}

	showCursor ( false )
	setElementClicked ( false )
end

local function openMenu ()
	if grMenuOpen then
		return
	end

	grMenuOpen = true
	showCursor ( true )
	setElementClicked ( true )

	triggerServerEvent ( "requestGluecksradStatus", lp )
end

local function drawMenu ()
	local width, height = 430, 282
	local x = screenwidth / 2 - width / 2
	local y = screenheight / 2 - height / 2

	dxDrawRectangle ( x, y, width, height, tocolor ( 18, 20, 26, 235 ) )
	dxDrawRectangle ( x, y, width, 42, tocolor ( GR_GOLD_DARK[1], GR_GOLD_DARK[2], GR_GOLD_DARK[3], 245 ) )
	dxDrawRectangle ( x, y + 42, width, 2, tocolor ( GR_GOLD_LIGHT[1], GR_GOLD_LIGHT[2], GR_GOLD_LIGHT[3], 255 ) )

	dxDrawText ( "Gluecksrad - Ticketverkauf", x, y, x + width, y + 42, tocolor ( 255, 255, 255, 255 ), 1.3, "default-bold", "center", "center" )

	dxDrawText ( "Deine Tickets: "..grTickets, x, y + 56, x + width, y + 78, tocolor ( 250, 214, 104, 255 ), 1.1, "default-bold", "center", "center" )
	dxDrawText ( "Preis pro Ticket: "..formNumberToMoneyString ( grTicketPrice ), x, y + 80, x + width, y + 100, tocolor ( 220, 220, 220, 255 ), 1.0, "default", "center", "center" )

	-- Cooldown- und Kontingent-Hinweis standen vorher beide im selben Rechteck
	-- (y+100..y+120) und ueberlagerten sich zu unlesbarem Buchstabensalat,
	-- sobald beides gleichzeitig zutraf. Jetzt zwei getrennte Zeilen.
	local cooldown = getCooldownRemaining ()
	if cooldown > 0 then
		dxDrawText ( "Wieder drehen in "..formatDuration ( cooldown ), x, y + 100, x + width, y + 118, tocolor ( 235, 120, 120, 255 ), 1.0, "default", "center", "center" )
	end

	grButtons = {}

	local buttonWidth = width - 60
	local buttonX = x + 30
	if grTicketsLeft >= 0 then
		local info = "Kaufbar: "..grTicketsLeft.." / "..grTicketsPerPeriod.." Tickets"
		if grTicketsLeft == 0 and grPeriodReset > 0 then
			info = info.."   -   neue in "..formatDuration ( grPeriodReset )
		end

		dxDrawText ( info, x, y + 118, x + width, y + 136,
					 grTicketsLeft > 0 and tocolor ( 220, 220, 220, 255 ) or tocolor ( 235, 120, 120, 255 ),
					 1.0, "default", "center", "center" )
	end

	-- Gedreht wird ausschliesslich ueber das Ticket im Inventar. Dieses Menue
	-- ist reiner Ticketverkauf.
	local canBuy = ( grTicketsLeft ~= 0 )

	local entries = {
		{ text = "1 Ticket kaufen", action = "buy1", enabled = canBuy },
		{ text = "Alle "..math.max ( grTicketsLeft, 1 ).." kaufen", action = "buyall",
		  enabled = ( canBuy and grTicketsLeft > 1 ) },
		{ text = "Schliessen", action = "close", enabled = true },
	}

	local cursorX, cursorY = 0, 0
	if isCursorShowing () then
		local relX, relY = getCursorPosition ()
		cursorX, cursorY = relX * screenwidth, relY * screenheight
	end

	for i = 1, #entries do
		local entry = entries[i]
		local buttonY = y + 140 + ( i - 1 ) * 34
		local hovered = cursorX >= buttonX and cursorX <= buttonX + buttonWidth and cursorY >= buttonY and cursorY <= buttonY + 30

		local color
		if not entry.enabled then
			color = tocolor ( 60, 62, 70, 235 )
		elseif hovered then
			color = tocolor ( GR_GOLD_LIGHT[1], GR_GOLD_LIGHT[2], GR_GOLD_LIGHT[3], 245 )
		else
			color = tocolor ( 44, 48, 58, 240 )
		end

		dxDrawRectangle ( buttonX, buttonY, buttonWidth, 30, color )
		dxDrawText ( entry.text, buttonX, buttonY, buttonX + buttonWidth, buttonY + 30,
					 ( hovered and entry.enabled ) and tocolor ( 20, 20, 20, 255 ) or tocolor ( 235, 235, 235, 255 ),
					 1.0, "default-bold", "center", "center" )

		grButtons[i] = { x = buttonX, y = buttonY, w = buttonWidth, h = 30, action = entry.action, enabled = entry.enabled }
	end
end

local function onMenuClick ( button, state )
	if button ~= "left" or state ~= "down" or not grMenuOpen then
		return
	end

	local relX, relY = getCursorPosition ()
	if not relX then
		return
	end

	local cursorX, cursorY = relX * screenwidth, relY * screenheight

	for i = 1, #grButtons do
		local entry = grButtons[i]
		if cursorX >= entry.x and cursorX <= entry.x + entry.w and cursorY >= entry.y and cursorY <= entry.y + entry.h then
			if not entry.enabled then
				return
			end

			if entry.action == "buy1" then
				triggerServerEvent ( "requestGluecksradTicket", lp, 1 )
			elseif entry.action == "buyall" then
				triggerServerEvent ( "requestGluecksradTicket", lp, grTicketsLeft )
			elseif entry.action == "close" then
				closeMenu ()
			end

			return
		end
	end
end

---------------------------------------------------------------------
-- Weltdarstellung
---------------------------------------------------------------------

local function drawHint ()
	local screenX, screenY = getScreenFromWorldPosition ( GR_X, GR_Y, GR_Z + GR_RADIUS + 0.45, 0.2 )
	if not screenX then
		return
	end

	local text
	if grSpinning then
		text = "Das Rad dreht sich..."
	elseif getCooldownRemaining () > 0 then
		text = "Wieder drehen in "..formatDuration ( getCooldownRemaining () )
	elseif grTickets > 0 then
		text = "Ticket im Inventar benutzen  -  du hast "..grTickets
	elseif grTicketsLeft == 0 then
		-- Wochenlimit erreicht: "Druecke E, um zu kaufen" waere hier irrefuehrend,
		-- der Kauf-Button im Menue ist in diesem Fall ohnehin ausgegraut.
		text = "Keine Tickets mehr diese Woche"..
			   ( grPeriodReset > 0 and ( "  -  neue in "..formatDuration ( grPeriodReset ) ) or "" )
	else
		text = "Druecke E, um ein Ticket zu kaufen"
	end

	for dx = -1, 1 do
		for dy = -1, 1 do
			if dx ~= 0 or dy ~= 0 then
				dxDrawText ( text, screenX + dx * 2, screenY + dy * 2, screenX + dx * 2, screenY + dy * 2,
							 tocolor ( 0, 0, 0, 230 ), 1.15, "default-bold", "center", "center" )
			end
		end
	end

	dxDrawText ( text, screenX, screenY, screenX, screenY, tocolor ( 255, 255, 255, 255 ), 1.15, "default-bold", "center", "center" )
end

-- Dreht das ausgestellte Fahrzeug und zeichnet Podest und Schild darunter.
local function drawPrizeCar ()
	if not isElement ( grCar ) then
		return
	end

	local x, y, groundZ = getCarPosition ()

	-- Zeitspanne seit dem letzten Bild. Sie wird gedeckelt, weil das Zeichnen
	-- ausgesetzt wird, solange der Spieler weit weg ist - ohne Deckel wuerde
	-- das Fahrzeug bei der Rueckkehr um den ganzen Zeitraum weiterspringen.
	local jetzt = getTickCount ()
	local delta = math.min ( jetzt - ( grCarLastTick or jetzt ), 100 )
	grCarLastTick = jetzt

	grCarAngle = ( grCarAngle + GR_CAR_SPEED * delta / 1000 ) % 360

	-- Nur die Drehung aendert sich, die Position steht fest. Sie wird einmal
	-- beim Erzeugen gesetzt statt in jedem Bild.
	setElementRotation ( grCar, 0, 0, grCarAngle )

	if rtPodium then
		dxDrawMaterialLine3D ( x - 2.6, y, groundZ + 0.05, x + 2.6, y, groundZ + 0.05,
							   rtPodium, 5.2, tocolor ( 255, 255, 255, 255 ), x, y, groundZ + 10 )
	end

	local screenX, screenY = getScreenFromWorldPosition ( x, y, groundZ + GR_CAR_HEIGHT + 2.2, 0.2 )
	if not screenX then
		return
	end

	local name = getVehicleNameFromModel ( GR_CAR_MODEL ) or "Fahrzeug"

	for dx = -1, 1 do
		for dy = -1, 1 do
			if dx ~= 0 or dy ~= 0 then
				dxDrawText ( GR_CAR_LABEL, screenX + dx * 2, screenY + dy * 2 - 18, screenX + dx * 2, screenY + dy * 2 - 18,
							 tocolor ( 0, 0, 0, 230 ), 1.3, "default-bold", "center", "center" )
				dxDrawText ( name, screenX + dx * 2, screenY + dy * 2 + 4, screenX + dx * 2, screenY + dy * 2 + 4,
							 tocolor ( 0, 0, 0, 230 ), 1.1, "default-bold", "center", "center" )
			end
		end
	end

	dxDrawText ( GR_CAR_LABEL, screenX, screenY - 18, screenX, screenY - 18,
				 tocolor ( GR_GOLD_LIGHT[1], GR_GOLD_LIGHT[2], GR_GOLD_LIGHT[3], 255 ), 1.3, "default-bold", "center", "center" )
	dxDrawText ( name, screenX, screenY + 4, screenX, screenY + 4,
				 tocolor ( 255, 255, 255, 255 ), 1.1, "default-bold", "center", "center" )
end

---------------------------------------------------------------------
-- Klaenge
---------------------------------------------------------------------

-- Alles wird am Rad selbst abgespielt statt flach im Kopf des Spielers.
-- Dadurch wird es mit der Entfernung leiser und man hoert, wo es herkommt.
local function playWheelSound ( pfad, speed, volume )
	if not pfad or pfad == "" then
		return
	end

	local sound = playSound3D ( pfad, GR_X, GR_Y, GR_Z )
	if not sound then
		return
	end

	setSoundMaxDistance ( sound, GR_SOUND_RANGE )

	if speed then
		setSoundSpeed ( sound, speed )
	end
	if volume then
		setSoundVolume ( sound, volume )
	end

	return sound
end

-- Die Ebenen des Rades werden entlang der Blickrichtung leicht versetzt, damit
-- sie nicht miteinander um dieselbe Tiefe kaempfen ( Z-Fighting ).
-- Steht ausserhalb von renderWheel: dort wuerde in jedem Bild eine neue
-- Funktion angelegt, die der Speicherbereiniger gleich wieder einsammeln muss.
local function layer ( offset )
	return GR_X + faceX * offset, GR_Y + faceY * offset
end

local function renderWheel ()
	if not rtWheel then
		return
	end

	local px, py, pz = getElementPosition ( localPlayer )
	local distance = getDistanceBetweenPoints3D ( px, py, pz, GR_X, GR_Y, GR_Z )

	grInRange = distance <= GR_RANGE

	if grMenuOpen and not grInRange then
		closeMenu ()
	end

	if distance > GR_DRAW_RANGE then
		return
	end

	if grSpinning then
		local elapsed = getTickCount () - grSpinStart
		local roh

		if elapsed >= GR_SPIN_DURATION then
			roh = grSpinFrom + grSpinDelta
			grAngle = roh % 360
			grSpinning = false
		else
			local t = elapsed / GR_SPIN_DURATION
			local eased = 1 - ( 1 - t ) ^ 3
			roh = grSpinFrom + grSpinDelta * eased
			grAngle = roh % 360
		end

		-- Ticken: fuer jedes Segment, das seit dem letzten Bild am Zeiger
		-- vorbeigelaufen ist, ein Klick. Gerechnet wird auf dem ungekuerzten
		-- Winkel, damit der Uebergang von 359 auf 0 Grad nicht stoert.
		local segStep = 360 / #grSegments
		local stufe = math.floor ( roh / segStep )

		if grLastTickStep and stufe > grLastTickStep then
			-- Bei hohem Tempo werden mehrere Segmente pro Bild ueberfahren.
			-- Dann trotzdem nur ein Klick, sonst ueberlagern sich die Toene.
			playWheelSound ( GR_SOUND_TICK, 1, 0.5 )
		end
		grLastTickStep = stufe

		-- Abschlusston, sobald das Rad steht.
		if not grSpinning then
			local segment = grSegments[grSpinIndex]
			local klang = segment and segment.klang

			if klang == "niete" then
				playWheelSound ( GR_SOUND_LOSE, GR_LOSE_SPEED, 1 )
			elseif klang == "gross" then
				playWheelSound ( GR_SOUND_BIG, 1, 1 )
				setTimer ( playWheelSound, 450, 1, GR_SOUND_WIN, 1, 1 )
			else
				playWheelSound ( GR_SOUND_WIN, 1, 1 )
			end
		end
	end

	-- Im Shader-Modus dreht sich das Objekt selbst.
	applyWheelRotation ()


	-- Overlay-Modus: die gedrehte Scheibe liegt vor der Radflaeche des Modells.
	if GR_FACE_MODE == "overlay" then
		dxSetRenderTarget ( rtFrame, true )
		dxDrawImage ( 0, 0, GR_RT_SIZE, GR_RT_SIZE, rtWheel, grAngle, 0, 0, tocolor ( 255, 255, 255, 255 ) )

		-- Die Beschriftung wandert mit ihrem Segment mit und wird dabei
		-- mitgedreht, damit sie radial im Keil sitzt.
		local cx = GR_UV_CX * GR_RT_SIZE
		local cy = GR_UV_CY * GR_RT_SIZE
		local labelRadius = GR_UV_R * GR_RT_SIZE * 0.66
		local segStep = 360 / #grSegments

		for i = 1, #grSegments do
			if isElement ( rtLabels[i] ) then
				local winkel = ( GR_UV_ROT + ( i - 1 ) * segStep + segStep / 2 + grAngle ) % 360
				local rad = math.rad ( winkel )

				local tx = cx + math.sin ( rad ) * labelRadius
				local ty = cy - math.cos ( rad ) * labelRadius

				-- Auf der linken Radhaelfte stuende die radiale Schrift sonst
				-- auf dem Kopf, deshalb dort um 180 Grad gedreht.
				local drehung = winkel + GR_LABEL_ANGLE
				if GR_LABEL_FLIP and winkel > 180 then
					drehung = drehung + 180
				end

				dxDrawImage ( tx - GR_LABEL_W / 2, ty - GR_LABEL_H / 2, GR_LABEL_W, GR_LABEL_H,
							  rtLabels[i], drehung, 0, 0, tocolor ( 255, 255, 255, 255 ) )
			end
		end

		dxSetRenderTarget ()

		local fx, fy = layer ( GR_FACE_OFFSET )
		dxDrawMaterialLine3D ( fx, fy, GR_Z + GR_FACE_RADIUS, fx, fy, GR_Z - GR_FACE_RADIUS,
							   rtFrame, GR_FACE_RADIUS * 2, tocolor ( 255, 255, 255, 255 ), fx + faceX, fy + faceY, GR_Z )
	end

	if GR_DECO_STAND then
		local standX, standY = layer ( -0.06 )
		dxDrawMaterialLine3D ( standX, standY, GR_Z + 0.1, standX, standY, GR_Z - GR_STAND_HEIGHT,
							   rtStand, GR_RADIUS * 1.5, tocolor ( 255, 255, 255, 255 ), standX + faceX, standY + faceY, GR_Z )
	end

	if GR_DECO_RIM then
		local rimPhase = ( math.floor ( getTickCount () / GR_BLINK_TIME ) % 2 ) + 1
		local rimX, rimY = layer ( 0.04 )
		dxDrawMaterialLine3D ( rimX, rimY, GR_Z + GR_RADIUS, rimX, rimY, GR_Z - GR_RADIUS,
							   rtRim[rimPhase], GR_RADIUS * 2, tocolor ( 255, 255, 255, 255 ), rimX + faceX, rimY + faceY, GR_Z )
	end

	if GR_DECO_MARKER then
		local markerX, markerY = layer ( 0.08 )
		-- Die Zeigerspitze ragt in den Rahmen hinein, der Rest sitzt darueber.
		local markerTop = GR_Z + GR_RADIUS * 1.32
		local markerBottom = GR_Z + GR_RADIUS * 0.98

		dxDrawMaterialLine3D ( markerX, markerY, markerTop, markerX, markerY, markerBottom,
							   rtMarker, ( markerTop - markerBottom ) * 0.75, tocolor ( 255, 255, 255, 255 ),
							   markerX + faceX, markerY + faceY, GR_Z )
	end

	-- Schild ueber dem Rad. Es liegt waagerecht in der Seitenachse und schaut
	-- in dieselbe Richtung wie das Rad, steht also als Tafel darueber.
	if GR_SIGN_SHOW and rtSign then
		local sideX = math.cos ( math.rad ( GR_ROTATION + 90 ) )
		local sideY = math.sin ( math.rad ( GR_ROTATION + 90 ) )
		local signZ = GR_Z + GR_RADIUS + GR_SIGN_ABOVE
		local half = GR_SIGN_WIDTH / 2

		dxDrawMaterialLine3D ( GR_X - sideX * half, GR_Y - sideY * half, signZ,
							   GR_X + sideX * half, GR_Y + sideY * half, signZ,
							   rtSign, GR_SIGN_WIDTH * 160 / 512, tocolor ( 255, 255, 255, 255 ),
							   GR_X + faceX, GR_Y + faceY, signZ )
	end

	drawPrizeCar ()

	if grInRange then
		drawHint ()
	end

	if grMenuOpen then
		drawMenu ()
	end
end

---------------------------------------------------------------------
-- Events
---------------------------------------------------------------------

function startGluecksradSpin ( index )
	index = tonumber ( index )
	if not index or not grSegments[index] then
		return
	end

	closeMenu ()

	local step = 360 / #grSegments
	local center = ( index - 1 ) * step + step / 2

	-- Leichter Versatz innerhalb des Segments, damit das Rad nicht immer
	-- exakt mittig stehen bleibt.
	local jitter = math.random ( -100, 100 ) / 100 * ( step / 2 - 3 )
	local target = ( 360 - ( center + jitter ) ) % 360

	grSpinFrom = grAngle % 360
	grSpinDelta = GR_SPIN_TURNS * 360 + ( ( target - grSpinFrom ) % 360 )
	grSpinStart = getTickCount ()
	grSpinning = true

	-- Fuer den Abschlusston und das Ticken.
	grSpinIndex = index
	grLastTickStep = math.floor ( grSpinFrom / ( 360 / #grSegments ) )
end
addEvent ( "startGluecksradSpin", true )
addEventHandler ( "startGluecksradSpin", getRootElement(), startGluecksradSpin )

function recieveGluecksradStatus ( remaining, tickets, price, kaufbar, proZeitraum, periodReset )
	grCooldown = tonumber ( remaining ) or 0
	grCooldownAt = getTickCount ()
	grTickets = tonumber ( tickets ) or 0
	grTicketPrice = tonumber ( price ) or grTicketPrice
	grTicketsLeft = tonumber ( kaufbar ) or -1
	grTicketsPerPeriod = tonumber ( proZeitraum ) or 0
	grPeriodReset = tonumber ( periodReset ) or 0
end
addEvent ( "recieveGluecksradStatus", true )
addEventHandler ( "recieveGluecksradStatus", getRootElement(), recieveGluecksradStatus )

-- Wochenfahrzeug. Kommt ausschliesslich vom Server, damit die Ausstellung
-- immer das zeigt, was auch tatsaechlich vergeben wird.
addEvent ( "recieveGluecksradCar", true )
addEventHandler ( "recieveGluecksradCar", getRootElement(), function ( modell )
	modell = tonumber ( modell )
	if not modell or modell == GR_CAR_MODEL then
		return
	end

	GR_CAR_MODEL = modell
	createPrizeCar ()
end )

local function onInteract ()
	if grMenuOpen then
		closeMenu ()
		return
	end

	if not grInRange or grSpinning or isPedInVehicle ( localPlayer ) then
		return
	end

	openMenu ()
end

-- Einloesen aus dem Inventar. Das Inventar ruft diesen Befehl auf, wenn man
-- das Ticket benutzt - gedreht wird nur, wenn man auch wirklich am Rad steht.
addCommandHandler ( "gluecksradticket", function ()
	if not grInRange then
		infobox_start_func ( "Du musst am\nGluecksrad stehen,\num ein Ticket\neinzuloesen!", 5000, 200, 200, 0 )
		return
	end

	if grSpinning then
		infobox_start_func ( "Das Rad dreht sich\ngerade noch!", 5000, 200, 200, 0 )
		return
	end

	if isPedInVehicle ( localPlayer ) then
		return
	end

	closeMenu ()
	triggerServerEvent ( "requestGluecksradSpin", lp )
end )

addEventHandler ( "onClientResourceStart", resourceRoot, function ()
	if not createTextures () then
		return
	end

	buildAllTextures ()

	-- Erst die Handler registrieren, dann die Deko erzeugen. Scheitert die
	-- Ausstellung, bleibt das Rad trotzdem sichtbar und bedienbar.
	addEventHandler ( "onClientRender", getRootElement(), renderWheel )
	addEventHandler ( "onClientClick", getRootElement(), onMenuClick )

	bindKey ( "e", "down", onInteract )
	grBound = true

	createWheelObject ()
	createPrizeCar ()

	-- Das Wochenfahrzeug wird hier abgefragt und nicht vom Server von sich aus
	-- geschickt: beim Serverstart ist dieses Skript noch nicht geladen, der
	-- Empfaenger existiert dann noch nicht.
	triggerServerEvent ( "requestGluecksradCar", lp )
	triggerServerEvent ( "requestGluecksradDev", lp )

	triggerServerEvent ( "requestGluecksradStatus", lp )
end )

-- Nach einem Geraetewechsel sind Render-Targets leer und muessen neu befuellt werden.
addEventHandler ( "onClientRestore", getRootElement(), function ( didClear )
	if didClear then
		buildAllTextures ()
	end
end )

addEventHandler ( "onClientResourceStop", resourceRoot, function ()
	closeMenu ()

	removeEventHandler ( "onClientRender", getRootElement(), renderWheel )
	removeEventHandler ( "onClientClick", getRootElement(), onMenuClick )

	if grBound then
		unbindKey ( "e", "down", onInteract )
		grBound = false
	end

	destroyWheelObject ()
	destroyPrizeCar ()

	for _, rt in ipairs ( { rtWheel, rtFrame, rtRim[1], rtRim[2], rtMarker, rtStand, rtPodium, rtSign } ) do
		if isElement ( rt ) then
			destroyElement ( rt )
		end
	end

	for i = 1, #rtLabels do
		if isElement ( rtLabels[i] ) then
			destroyElement ( rtLabels[i] )
		end
	end
	rtLabels = {}
end )

---------------------------------------------------------------------
-- Einmessbefehle
--
-- Nur zum Einrichten gedacht: damit laesst sich im laufenden Spiel finden,
-- welches Modell, welche Groesse und welche Drehachse passen.
--
-- Sie werden erst registriert, wenn der Server den Adminrang bestaetigt hat.
-- Die Entscheidung faellt serverseitig, ein manipulierter Client kann sie
-- sich also nicht selbst erteilen. Alle Befehle wirken ohnehin nur auf die
-- eigene Ansicht und koennen weder Gewinne noch Tickets beeinflussen.
---------------------------------------------------------------------

local grDevCommands = {}

local function devCommand ( name, handler )
	grDevCommands[name] = handler
end

addEvent ( "recieveGluecksradDev", true )
addEventHandler ( "recieveGluecksradDev", getRootElement(), function ()
	for name, handler in pairs ( grDevCommands ) do
		addCommandHandler ( name, handler )
	end

	outputChatBox ( "Gluecksrad: Einmessbefehle freigeschaltet ( /radhier, /radhoch, /radface, /radauto, /radtest ).", 0, 200, 0 )
end )

devCommand ( "radmodel", function ( _, id )
	id = tonumber ( id )
	if not id then
		outputChatBox ( "Benutzung: /radmodel <Modell-ID>   ( aktuell: "..GR_MODEL.." )", 200, 200, 0 )
		return
	end

	GR_MODEL = math.floor ( id )
	if createWheelObject () then
		outputChatBox ( "Gluecksrad: Modell "..GR_MODEL.." gesetzt.", 0, 200, 0 )
	else
		outputChatBox ( "Gluecksrad: Modell "..GR_MODEL.." konnte nicht geladen werden.", 200, 0, 0 )
	end
end )

devCommand ( "radscale", function ( _, value )
	value = tonumber ( value )
	if not value or value <= 0 then
		outputChatBox ( "Benutzung: /radscale <Zahl>   ( aktuell: "..GR_SCALE.." )", 200, 200, 0 )
		return
	end

	GR_SCALE = value
	if isElement ( grObject ) then
		setObjectScale ( grObject, GR_SCALE )
	end
	outputChatBox ( "Gluecksrad: Groesse "..GR_SCALE.." gesetzt.", 0, 200, 0 )
end )

devCommand ( "radaxis", function ( _, axis )
	if axis ~= "x" and axis ~= "y" and axis ~= "z" then
		outputChatBox ( "Benutzung: /radaxis x|y|z   ( aktuell: "..GR_SPIN_AXIS.." )", 200, 200, 0 )
		return
	end

	GR_SPIN_AXIS = axis
	outputChatBox ( "Gluecksrad: Drehachse "..GR_SPIN_AXIS.." gesetzt.", 0, 200, 0 )
end )

-- Stellt das Rad dorthin, wo du gerade stehst, und setzt es auf den Boden.
-- Danach mit /radhoch feinjustieren und die ausgegebenen Werte oben eintragen.
devCommand ( "radhier", function ()
	local px, py, pz = getElementPosition ( localPlayer )
	local ground = getGroundPosition ( px, py, pz + 3 )

	GR_X, GR_Y = px, py

	-- GR_Z ist die Nabe, also die Radmitte. Wie hoch sie ueber dem Boden liegen
	-- muss, haengt davon ab, was unter dem Rad steht: der Tisch des Modells,
	-- der gezeichnete Standfuss, oder nichts - dann reicht der Radradius.
	local groundZ = ( ground and ground > 0 ) and ground or pz

	local height
	if GR_USE_OBJECT then
		height = -GR_TABLE_OFFSET
	elseif GR_DECO_STAND then
		height = GR_STAND_HEIGHT
	else
		height = GR_RADIUS + 0.1
	end

	GR_Z = groundZ + height

	GR_ROTATION = ( getPedRotation ( localPlayer ) + 180 ) % 360
	GR_BASE_RZ = GR_ROTATION
	faceX = math.cos ( math.rad ( GR_ROTATION ) )
	faceY = math.sin ( math.rad ( GR_ROTATION ) )

	createWheelObject ()

	outputChatBox ( "Gluecksrad: gesetzt auf "..string.format ( "%.2f, %.2f, %.2f", GR_X, GR_Y, GR_Z )..
					"   Drehung "..string.format ( "%.1f", GR_ROTATION ), 0, 200, 0 )
	outputChatBox ( "Mit /radhoch <zahl> die Hoehe korrigieren, dann die Werte oben eintragen.", 200, 200, 0 )
end )

devCommand ( "radhoch", function ( _, value )
	value = tonumber ( value )
	if not value then
		outputChatBox ( "Benutzung: /radhoch <zahl>   ( z.B. -0.5 oder 0.25, aktuell Z = "..string.format ( "%.2f", GR_Z ).." )", 200, 200, 0 )
		return
	end

	GR_Z = GR_Z + value
	createWheelObject ()
	outputChatBox ( "Gluecksrad: Hoehe jetzt "..string.format ( "%.2f", GR_Z ), 0, 200, 0 )
end )

devCommand ( "radfuss", function ( _, value )
	value = tonumber ( value )
	if not value then
		outputChatBox ( "Benutzung: /radfuss <zahl>   ( Abstand Nabe zu Fuss, aktuell "..GR_TABLE_OFFSET.." )", 200, 200, 0 )
		return
	end

	GR_TABLE_OFFSET = value
	createWheelObject ()
	outputChatBox ( "Gluecksrad: Fussabstand jetzt "..GR_TABLE_OFFSET, 0, 200, 0 )
end )

devCommand ( "radface", function ( _, offset, radius )
	offset, radius = tonumber ( offset ), tonumber ( radius )
	if not offset or not radius then
		outputChatBox ( "Benutzung: /radface <abstand> <radius>   ( aktuell: "..GR_FACE_OFFSET.." "..GR_FACE_RADIUS.." )", 200, 200, 0 )
		return
	end

	GR_FACE_OFFSET, GR_FACE_RADIUS = offset, radius
	outputChatBox ( "Gluecksrad: Scheibe Abstand "..offset..", Radius "..radius..".", 0, 200, 0 )
end )

devCommand ( "radobjekt", function ()
	GR_USE_OBJECT = not GR_USE_OBJECT

	-- Mit Modell liefert das Objekt Rahmen, Zeiger und Fuss selbst, ohne
	-- Modell muessen sie gezeichnet werden.
	GR_DECO_RIM    = not GR_USE_OBJECT
	GR_DECO_MARKER = not GR_USE_OBJECT
	GR_DECO_STAND  = not GR_USE_OBJECT
	GR_FACE_OFFSET = GR_USE_OBJECT and 0.12 or 0.0
	GR_FACE_RADIUS = GR_USE_OBJECT and 1.55 or GR_RADIUS

	createWheelObject ()
	outputChatBox ( "Gluecksrad: Modellobjekt "..( GR_USE_OBJECT and "an" or "aus" ).." ( gezeichnete Deko "..( GR_USE_OBJECT and "aus" or "an" ).." ).", 0, 200, 0 )
end )

devCommand ( "radmodus", function ( _, mode )
	if mode ~= "overlay" and mode ~= "shader" then
		outputChatBox ( "Benutzung: /radmodus overlay|shader   ( aktuell: "..GR_FACE_MODE.." )", 200, 200, 0 )
		return
	end

	GR_FACE_MODE = mode
	createWheelObject ()
	outputChatBox ( "Gluecksrad: Modus "..GR_FACE_MODE..".", 0, 200, 0 )
end )

devCommand ( "raduv", function ( _, cx, cy, r )
	cx, cy, r = tonumber ( cx ), tonumber ( cy ), tonumber ( r )
	if not cx or not cy or not r then
		outputChatBox ( "Benutzung: /raduv <mitteX> <mitteY> <radius>   ( je 0.0 - 1.0, aktuell: "..GR_UV_CX.." "..GR_UV_CY.." "..GR_UV_R.." )", 200, 200, 0 )
		return
	end

	GR_UV_CX, GR_UV_CY, GR_UV_R = cx, cy, r
	buildWheelTexture ()
	outputChatBox ( "Gluecksrad: Scheibe auf "..cx.." / "..cy..", Radius "..r.." gesetzt.", 0, 200, 0 )
end )

devCommand ( "raduvrot", function ( _, degrees )
	degrees = tonumber ( degrees )
	if not degrees then
		outputChatBox ( "Benutzung: /raduvrot <Grad>   ( aktuell: "..GR_UV_ROT.." )", 200, 200, 0 )
		return
	end

	GR_UV_ROT = degrees % 360
	buildWheelTexture ()
	outputChatBox ( "Gluecksrad: Scheibe um "..GR_UV_ROT.." Grad gedreht.", 0, 200, 0 )
end )

devCommand ( "raduvgrid", function ()
	GR_SHOW_GRID = not GR_SHOW_GRID
	buildWheelTexture ()
	outputChatBox ( "Gluecksrad: Ausrichtungshilfe "..( GR_SHOW_GRID and "an" or "aus" )..".", 0, 200, 0 )
end )

devCommand ( "radtexlist", function ()
	local names = engineGetModelTextureNames ( GR_MODEL )
	if not names or #names == 0 then
		outputChatBox ( "Gluecksrad: keine Texturnamen fuer Modell "..GR_MODEL.." gefunden.", 200, 0, 0 )
		return
	end

	outputChatBox ( "Gluecksrad: Texturen von Modell "..GR_MODEL..":", 200, 200, 0 )
	for i = 1, #names do
		outputChatBox ( "   "..names[i], 220, 220, 220 )
	end
end )

devCommand ( "radtex", function ( _, name )
	if not name or name == "" then
		outputChatBox ( "Benutzung: /radtex <Texturname|*>   ( aktuell: "..GR_TEXTURE.." )", 200, 200, 0 )
		return
	end

	GR_TEXTURE = name
	createWheelObject ()
	outputChatBox ( "Gluecksrad: Textur \""..GR_TEXTURE.."\" gesetzt.", 0, 200, 0 )
end )

devCommand ( "raddeko", function ( _, what )
	if what == "rahmen" then
		GR_DECO_RIM = not GR_DECO_RIM
		outputChatBox ( "Gluecksrad: Rahmen "..( GR_DECO_RIM and "an" or "aus" )..".", 0, 200, 0 )
	elseif what == "zeiger" then
		GR_DECO_MARKER = not GR_DECO_MARKER
		outputChatBox ( "Gluecksrad: Zeiger "..( GR_DECO_MARKER and "an" or "aus" )..".", 0, 200, 0 )
	elseif what == "fuss" then
		GR_DECO_STAND = not GR_DECO_STAND
		outputChatBox ( "Gluecksrad: Standfuss "..( GR_DECO_STAND and "an" or "aus" )..".", 0, 200, 0 )
	else
		outputChatBox ( "Benutzung: /raddeko rahmen|zeiger|fuss", 200, 200, 0 )
	end
end )

devCommand ( "radauto", function ( _, id, height )
	id = tonumber ( id )
	if not id then
		outputChatBox ( "Benutzung: /radauto <Fahrzeug-ID> [Hoehe]   ( aktuell: "..GR_CAR_MODEL..", Hoehe "..GR_CAR_HEIGHT.." )", 200, 200, 0 )
		return
	end

	GR_CAR_MODEL = math.floor ( id )
	GR_CAR_HEIGHT = tonumber ( height ) or GR_CAR_HEIGHT

	createPrizeCar ()
	outputChatBox ( "Gluecksrad: Ausstellung zeigt jetzt "..( getVehicleNameFromModel ( GR_CAR_MODEL ) or GR_CAR_MODEL )..".", 0, 200, 0 )
end )

-- Stellt das Ausstellungsfahrzeug dorthin, wo du gerade stehst.
devCommand ( "radautohier", function ()
	local px, py, pz = getElementPosition ( localPlayer )
	local ground = getGroundPosition ( px, py, pz + 3 )

	GR_CAR_POS = { px, py, ( ground and ground > 0 ) and ground or pz }
	createPrizeCar ()

	outputChatBox ( "Gluecksrad: Ausstellung auf "..string.format ( "%.3f, %.3f, %.3f", GR_CAR_POS[1], GR_CAR_POS[2], GR_CAR_POS[3] ).." gesetzt.", 0, 200, 0 )
end )

devCommand ( "radtest", function ()
	grSpinFrom = grAngle % 360
	grSpinDelta = GR_SPIN_TURNS * 360 + math.random ( 0, 359 )
	grSpinStart = getTickCount ()
	grSpinning = true

	-- Ohne diese beiden liefe die Testdrehung mit dem Ergebnis der letzten
	-- echten Drehung: falscher Abschlusston und ein Fehlklick im ersten Bild.
	grSpinIndex = math.random ( 1, #grSegments )
	grLastTickStep = math.floor ( grSpinFrom / ( 360 / #grSegments ) )
	outputChatBox ( "Gluecksrad: Testdrehung ( ohne Ticket, ohne Gewinn ).", 0, 200, 0 )
end )
