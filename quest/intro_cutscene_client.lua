--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local introSzenen = {
	{ x=-1981.206, y=145.074, z=27.7,    int=0,  dim=0, titel="Bahnhof San Fierro",
	  camStart = { x=-2006.555, y=198.144, z=28.713, lookX=-2006.13, lookY=197.254, lookZ=28.549, roll=0, fov=70 },
	  camEnd   = { x=-2007.362, y=119.285, z=28.505, lookX=-2006.568, lookY=119.884, lookZ=28.4, roll=0, fov=70 },
	  text="Willkommen in San Fierro! Am Bahnhof beginnt deine Reise." },
	{ x=-2044.0,   y=449.744, z=35.2,    int=0,  dim=0, titel="Rathaus",                 text="Das Rathaus - hier erledigst du wichtige Behoerdengaenge." },
	{ x=-1544.442, y=-440.828,z=6.0,     int=0,  dim=0, titel="Flughafen San Fierro",    text="Der Flughafen San Fierro - hier gibt es Flugzeuge und Helikopter." },
	{ x=-1966.118, y=293.971, z=35.5,    int=0,  dim=0, titel="Wang Cars",
	  camStart = { x=-2004.096, y=334.948, z=36.133, lookX=-2003.542, lookY=334.129, lookZ=35.985, roll=0, fov=70 },
	  camEnd   = { x=-1991.773, y=249.016, z=35.992, lookX=-1991.205, lookY=249.835, lookZ=35.914, roll=0, fov=70 },
	  text="Wang Cars - ein Autohaus fuer guenstige Fahrzeuge." },
	{ x=-1649.917, y=1209.813,z=7.25,    int=0,  dim=0, titel="Otto's Autos",
	  camStart = { x=-1621.037, y=1194.923, z=7.929, lookX=-1621.927, lookY=1195.373, lookZ=7.846, roll=0, fov=70 },
	  camEnd   = { x=-1625.623, y=1254.21, z=7.006, lookX=-1626.23, lookY=1253.447, lookZ=7.227, roll=0, fov=70 },
	  text="Otto's Autos - noch ein Autohaus mit grosser Auswahl." },
	{ x=-2185.056, y=2413.141,z=5.2,     int=0,  dim=0, titel="Bayside Boats",           text="Bayside Boats - hier gibt es Boote zu kaufen." },
	{ x=1714.812,  y=1616.190,z=10.1,    int=0,  dim=0, titel="Flughafen Las Venturas",  text="Der Flughafen Las Venturas - weitere Flugzeuge warten hier." },
	{ x=1689.002,  y=1850.704,z=11.2,    int=0,  dim=0, titel="Dollahyde Used Autos",
	  camStart = { x=1716.768, y=1881.34, z=11.169, lookX=1716.233, lookY=1880.499, lookZ=11.249, roll=0, fov=70 },
	  camEnd   = { x=1723.159, y=1940.693, z=11.966, lookX=1723.413, lookY=1941.647, lookZ=11.81, roll=0, fov=70 },
	  text="Dollahyde Used Autos - der Gebrauchtwagenhaendler." },
	{ x=2200.86,   y=1394.32, z=10.9,    int=0,  dim=0, titel="Auto Bahn",
	  camStart = { x=2198.351, y=1351.83, z=11.566, lookX=2198.38, lookY=1352.829, lookZ=11.525, roll=0, fov=70 },
	  camEnd   = { x=2099.719, y=1382.37, z=11.775, lookX=2100.584, lookY=1382.857, lookZ=11.651, roll=0, fov=70 },
	  text="Auto Bahn - ein weiteres Autohaus." },
	{ x=-911.116,  y=2686.191,z=42.8,    int=0,  dim=0, titel="Bonus-Boote",             text="Hier gibt es besondere Bonus-Boote." },
	{ x=-902.849,  y=2681.642,z=42.7,    int=0,  dim=0, titel="Bonus-Fahrzeuge",         text="Und hier besondere Bonus-Fahrzeuge an Land." },
	{ x=1948.675,  y=2068.84, z=11.5,    int=0,  dim=0, titel="Auto Bahn LV",            text="Noch eine Auto Bahn - Fahrzeuge satt." },
	{ x=-2088.97,  y=-2262.41,z=30.3,    int=0,  dim=0, titel="Kleinstadt-Haendler",     text="Der Kleinstadt-Haendler bietet ebenfalls Fahrzeuge an." },
	{ x=-1756.876, y=-116.164, z=6.5,    int=0,  dim=0, titel="Fahrschule",
	  camStart = { x=-1778.29, y=-114.815, z=4.677, lookX=-1777.295, lookY=-114.842, lookZ=4.583, roll=0, fov=70 },
	  camEnd   = { x=-1757.815, y=-188.968, z=4.52, lookX=-1757.732, lookY=-187.977, lookZ=4.416, roll=0, fov=70 },
	  text="Die Fahrschule - hier machst du deinen Fuehrerschein." },
	{ x=-1630.0,   y=680.0,   z=15.0,   int=0,  dim=0, titel="SFPD",
	  camStart = { x=-1610.267, y=731.716, z=13.134, lookX=-1610.038, lookY=730.742, lookZ=13.132, roll=0, fov=70 },
	  camEnd   = { x=-1624.625, y=745.462, z=-4.204, lookX=-1623.65, lookY=745.28, lookZ=-4.329, roll=0, fov=70 },
	  text="Das SFPD - die Polizei von San Fierro." },
	{ x=-691.36,   y=939.67,  z=13.6,   int=0,  dim=0, titel="Mafia",
	  camStart = { x=-719.227, y=969.084, z=13.251, lookX=-718.393, lookY=968.549, lookZ=13.115, roll=0, fov=70 },
	  camEnd   = { x=-717.5, y=911.445, z=13.077, lookX=-716.795, lookY=912.152, lookZ=13.033, roll=0, fov=70 },
	  text="Die Mafia - eine der illegalen Fraktionen." },
	{ x=-2241.789, y=643.901, z=53.0,   int=0,  dim=0, titel="Triaden",
	  camStart = { x=-2260.67, y=644.916, z=50.07, lookX=-2259.676, lookY=644.817, lookZ=50.02, roll=0, fov=70 },
	  camEnd   = { x=-2223.201, y=612.245, z=50.474, lookX=-2222.218, lookY=612.373, lookZ=50.343, roll=0, fov=70 },
	  text="Die Triaden - eine weitere kriminelle Organisation." },
	{ x=-1998.91,  y=-1563.29,z=85.4,   int=0,  dim=0, titel="Terroristen",
	  camStart = { x=-1991.276, y=-1659.219, z=85.362, lookX=-1991.312, lookY=-1658.219, lookZ=85.361, roll=0, fov=70 },
	  camEnd   = { x=-1993.104, y=-1618.027, z=88.847, lookX=-1993.118, lookY=-1617.052, lookZ=88.625, roll=0, fov=70 },
	  text="Die Terroristen - hier ist Vorsicht geboten." },
	{ x=-2520.77,  y=-623.44, z=132.8,  int=0,  dim=0, titel="San News",                text="San News - hier arbeiten die Reporter der Stadt." },
	{ x=-2453.88,  y=503.82,  z=29.7,   int=0,  dim=0, titel="FBI",
	  camStart = { x=-2473.434, y=465.857, z=30.265, lookX=-2472.839, lookY=466.653, lookZ=30.162, roll=0, fov=70 },
	  camEnd   = { x=-2430.969, y=491.553, z=30.858, lookX=-2431.303, lookY=492.49, lookZ=30.759, roll=0, fov=70 },
	  text="Das FBI - die Bundespolizei." },
	{ x=-1321.77,  y=2475.6,  z=90.5,   int=0,  dim=0, titel="Aztecas",                 text="Die Aztecas - eine weitere Strassengang." },
	{ x=-1346.17,  y=492.37,  z=10.9,   int=0,  dim=0, titel="Armee",
	  camStart = { x=-1536.037, y=504.841, z=8.067, lookX=-1535.772, lookY=503.88, lookZ=7.985, roll=0, fov=70 },
	  camEnd   = { x=-1472.851, y=519.306, z=51.878, lookX=-1472.118, lookY=518.837, lookZ=51.386, roll=0, fov=70 },
	  text="Die Armee - das Militaer von San Andreas." },
	{ x=-2186.93,  y=-2322.24,z=30.6,   int=0,  dim=0, titel="Angels of Death",         text="Angels of Death - ein Biker-Club." },
	{ x=-2655.283, y=638.323, z=17.0,   int=0,  dim=0, titel="Sanitaeter",
	  camStart = { x=-2603.963, y=584.21, z=15.478, lookX=-2604.834, lookY=584.686, lookZ=15.357, roll=0, fov=70 },
	  camEnd   = { x=-2696.476, y=573.392, z=26.083, lookX=-2695.964, lookY=574.19, lookZ=25.765, roll=0, fov=70 },
	  text="Die Sanitaeter - hier werden Verletzte behandelt." },
	{ x=-2065.12,  y=-135.93, z=35.3,    int=0,  dim=0, titel="Mechaniker",
	  camStart = { x=-2044.906, y=-62.738, z=36.063, lookX=-2044.888, lookY=-63.733, lookZ=35.964, roll=0, fov=70 },
	  camEnd   = { x=-2033.575, y=-283.989, z=42.725, lookX=-2033.894, lookY=-283.048, lookZ=42.615, roll=0, fov=70 },
	  text="Die Mechaniker - fuer Reparaturen und Tuning." },
	{ x=-2208.02,  y=56.26,   z=35.3,    int=0,  dim=0, titel="Ballas",
	  camStart = { x=-2160.676, y=43.368, z=36.045, lookX=-2161.672, lookY=43.343, lookZ=35.967, roll=0, fov=70 },
	  camEnd   = { x=-2212.541, y=84.451, z=41.784, lookX=-2212.285, lookY=83.528, lookZ=41.497, roll=0, fov=70 },
	  text="Die Ballas - eine bekannte Strassengang." },
	{ x=-2446.27,  y=-86.6,   z=34.2,    int=0,  dim=0, titel="Grove Street Families",
	  camStart = { x=-2508.981, y=-128.61, z=26.38, lookX=-2507.985, lookY=-128.62, lookZ=26.291, roll=0, fov=70 },
	  camEnd   = { x=-2461.068, y=-166.829, z=33.933, lookX=-2461.027, lookY=-165.902, lookZ=33.558, roll=0, fov=70 },
	  text="Die Grove Street Families - eine weitere Gang." },
	{ x=-2143.948, y=1018.377,z=79.852, int=0,  dim=0, titel="Anonymus",
	  camStart = { x=-2141.313, y=1018.256, z=79.847, lookX=-2142.297, lookY=1018.306, lookZ=80.02, roll=0, fov=70 },
	  camEnd   = { x=-2230.147, y=1011.868, z=103.232, lookX=-2229.366, lookY=1011.45, lookZ=102.768, roll=0, fov=70 },
	  text="Anonymus - eine mysterioese Gruppierung." },
	{ x=-1981.206, y=145.074, z=27.7,    int=0,  dim=0, titel="Zurueck am Bahnhof",      stil="orbit", radius=40, hoehe=24, startWinkel=47, text="Das war unsere Tour! Viel Spass - dein Abenteuer beginnt jetzt!" },
}

local SZENEN_DAUER_MIN = 4500
local SZENEN_DAUER_MAX = 11000
local SZENEN_DAUER_GRUND = 1800
local SZENEN_DAUER_PRO_ZEICHEN = 85
local BLENDE_DAUER = 320

local ORBIT_RADIUS = 40
local ORBIT_HOEHE = 22
local ORBIT_WINKEL_PRO_MS = 0.010

local ZOOM_START = 1.30
local ZOOM_ENDE = 0.85
local HOEHE_START = 1.35
local HOEHE_ENDE = 0.80
local BLICK_HOEHE = 3

local KAMERA_STILE = { "orbit", "anflug", "flug", "kran" }

local FOV_START = 78
local FOV_ENDE = 62
local ROLL_MAX = 1.8
local BLICK_DRIFT = 2.5
local BLICK_REICHWEITE = 60

TTS_ANBIETER = "google"
TTS_STIMME = "Hans"
TTS_TONHOEHE = -6

introCutsceneAktiv = false

local introIndex = 0
local introTimer = nil
local introStartTick = 0
local introSzenenDauer = SZENEN_DAUER_MIN
local introIntBackup, introDimBackup = 0, 0
local introMusik = nil
local introTTS = nil
local introIstRegistrierung = false
local introSkipTasteWarUnten = false
local introCursorTimer = nil

local screenW, screenH = guiGetScreenSize ()
local BALKEN_HOEHE = screenH * 0.11
local SKALA = screenW / 1920

addEventHandler ( "onClientRestore", root, function ()
	screenW, screenH = guiGetScreenSize ()
	BALKEN_HOEHE = screenH * 0.11
	SKALA = screenW / 1920
end )

local function urlEncode ( str )
	str = str:gsub ( "([^%w %-%_%.%~])", function ( c ) return string.format ( "%%%02X", string.byte ( c ) ) end )
	return str:gsub ( " ", "+" )
end

local function introStopTTS ()
	if isElement ( introTTS ) then
		destroyElement ( introTTS )
	end
	introTTS = nil
end

local function introPlayTTS ( text )
	introStopTTS ()
	if not text or #text < 1 then return end

	if #text > 250 then
		local schnitt = text:sub ( 1, 250 ):match ( "^.*%s" )
		text = schnitt or text:sub ( 1, 250 )
	end

	local url
	if TTS_ANBIETER == "streamelements" then
		url = "https://api.streamelements.com/kappa/v2/speech?voice="..TTS_STIMME.."&text="..urlEncode ( text )
	else
		url = "http://translate.google.com/translate_tts?ie=UTF-8&tl=de&client=tw-ob&q="..urlEncode ( text )
	end

	introTTS = playSound ( url )
	if not introTTS then
		outputDebugString ( "[Intro-TTS] playSound hat nichts zurueckgegeben: "..url, 1 )
		return
	end

	addEventHandler ( "onClientSoundStream", introTTS, function ( erfolg )
		if erfolg and TTS_TONHOEHE ~= 0 and isElement ( source ) then
			local sampleRate, tempo, pitch, reversed = getSoundProperties ( source )
			if sampleRate then
				setSoundProperties ( source, sampleRate, tempo, pitch + TTS_TONHOEHE, reversed )
			end
		end
	end, false )
end

local function blickRichtung ( m )
	local dx, dy, dz = m.lookX - m.x, m.lookY - m.y, m.lookZ - m.z
	local laenge = math.sqrt ( dx * dx + dy * dy + dz * dz )
	if laenge < 0.0001 then
		return 1, 0, 0
	end
	return dx / laenge, dy / laenge, dz / laenge
end

function introKameraMischen ( s, e, a )
	local w = a * a * ( 3 - 2 * a )

	local cx = s.x + ( e.x - s.x ) * w
	local cy = s.y + ( e.y - s.y ) * w
	local cz = s.z + ( e.z - s.z ) * w

	local sx, sy, sz = blickRichtung ( s )
	local ex, ey, ez = blickRichtung ( e )

	local dx = sx + ( ex - sx ) * w
	local dy = sy + ( ey - sy ) * w
	local dz = sz + ( ez - sz ) * w

	local laenge = math.sqrt ( dx * dx + dy * dy + dz * dz )
	if laenge < 0.0001 then
		dx, dy, dz, laenge = ex, ey, ez, 1
	end

	local reichweite = BLICK_REICHWEITE
	local lx = cx + ( dx / laenge ) * reichweite
	local ly = cy + ( dy / laenge ) * reichweite
	local lz = cz + ( dz / laenge ) * reichweite

	local roll = ( s.roll or 0 ) + ( ( e.roll or 0 ) - ( s.roll or 0 ) ) * w
	local fov = ( s.fov or 70 ) + ( ( e.fov or 70 ) - ( s.fov or 70 ) ) * w

	return cx, cy, cz, lx, ly, lz, roll, fov
end

function introSzenenAnzahl ()
	return #introSzenen
end

function introSzeneHolen ( i )
	return introSzenen[i]
end

function introSzenenDauerFuer ( text )
	local dauer = SZENEN_DAUER_GRUND + ( #( text or "" ) * SZENEN_DAUER_PRO_ZEICHEN )
	if dauer < SZENEN_DAUER_MIN then dauer = SZENEN_DAUER_MIN end
	if dauer > SZENEN_DAUER_MAX then dauer = SZENEN_DAUER_MAX end
	return dauer
end

function introFortschritt ()
	if not introCutsceneAktiv or introIndex < 1 then
		return 0
	end
	local vergangen = getTickCount () - introStartTick
	local anteil = vergangen / introSzenenDauer
	if anteil < 0 then anteil = 0 end
	if anteil > 1 then anteil = 1 end
	return ( introIndex - 1 + anteil ) / #introSzenen
end

local function weich ( t )
	return t * t * ( 3 - 2 * t )
end

function introKameraBlick ( szene, anteil, vergangen )
	local w = weich ( anteil )
	local richtung = ( introIndex % 2 == 0 ) and -1 or 1
	local stil = szene.stil or KAMERA_STILE[ ( ( introIndex - 1 ) % #KAMERA_STILE ) + 1 ]

	local drift = math.rad ( vergangen * 0.018 )
	local lookX = szene.x + math.cos ( drift ) * BLICK_DRIFT
	local lookY = szene.y + math.sin ( drift ) * BLICK_DRIFT
	local lookZ = szene.z + BLICK_HOEHE

	local fovStart, fovEnde = FOV_START, FOV_ENDE
	if stil == "anflug" then
		fovStart, fovEnde = 82, 58
	elseif stil == "kran" then
		fovStart, fovEnde = 70, 66
	elseif stil == "flug" then
		fovStart, fovEnde = 74, 64
	end

	local fov = fovStart - ( fovStart - fovEnde ) * w
	local roll = richtung * ROLL_MAX * math.sin ( anteil * math.pi )

	return lookX, lookY, lookZ, roll, fov
end

function introKameraPosition ( szene, anteil, vergangen )
	local w = weich ( anteil )
	local grundRadius = szene.radius or ORBIT_RADIUS
	local grundHoehe = szene.hoehe or ORBIT_HOEHE
	local startWinkel = math.rad ( szene.startWinkel or ( introIndex * 47 ) )
	local richtung = ( introIndex % 2 == 0 ) and -1 or 1
	local stil = szene.stil or KAMERA_STILE[ ( ( introIndex - 1 ) % #KAMERA_STILE ) + 1 ]

	if stil == "anflug" then
		local radius = grundRadius * ( 2.30 - 1.55 * w )
		local hoehe = grundHoehe * ( 1.15 - 0.35 * w )
		local winkel = startWinkel + richtung * math.rad ( vergangen * ORBIT_WINKEL_PRO_MS * 0.25 )
		return szene.x + math.cos ( winkel ) * radius,
		       szene.y + math.sin ( winkel ) * radius,
		       szene.z + hoehe

	elseif stil == "kran" then
		local radius = grundRadius * ( 1.05 - 0.20 * w )
		local hoehe = grundHoehe * ( 2.30 - 1.65 * w )
		local winkel = startWinkel + richtung * math.rad ( vergangen * ORBIT_WINKEL_PRO_MS * 0.45 )
		return szene.x + math.cos ( winkel ) * radius,
		       szene.y + math.sin ( winkel ) * radius,
		       szene.z + hoehe

	elseif stil == "flug" then
		local a1 = startWinkel
		local a2 = startWinkel + richtung * math.rad ( 85 )
		local r1, r2 = grundRadius * 1.35, grundRadius * 1.00
		local h1, h2 = grundHoehe * 1.30, grundHoehe * 0.85

		local x1, y1, z1 = szene.x + math.cos ( a1 ) * r1, szene.y + math.sin ( a1 ) * r1, szene.z + h1
		local x2, y2, z2 = szene.x + math.cos ( a2 ) * r2, szene.y + math.sin ( a2 ) * r2, szene.z + h2

		return x1 + ( x2 - x1 ) * w,
		       y1 + ( y2 - y1 ) * w,
		       z1 + ( z2 - z1 ) * w
	end

	local radius = grundRadius * ( ZOOM_START - ( ZOOM_START - ZOOM_ENDE ) * w )
	local hoehe = grundHoehe * ( HOEHE_START - ( HOEHE_START - HOEHE_ENDE ) * w )
	local winkel = startWinkel + richtung * math.rad ( vergangen * ORBIT_WINKEL_PRO_MS )

	return szene.x + math.cos ( winkel ) * radius,
	       szene.y + math.sin ( winkel ) * radius,
	       szene.z + hoehe
end

local function introRenderFrame ()
	if not introCutsceneAktiv then return end

	if getKeyState ( "n" ) then
		if not introSkipTasteWarUnten then
			introSkipTasteWarUnten = true
			introBeenden ()
			return
		end
	else
		introSkipTasteWarUnten = false
	end

	if isCursorShowing () then
		showCursor ( false )
	end

	local szene = introSzenen[introIndex]
	if not szene then return end

	if szene.camFixed then
		local c = szene.camFixed
		setCameraMatrix ( c.x, c.y, c.z, c.lookX, c.lookY, c.lookZ, c.roll or 0, c.fov or 70 )
		return
	end

	if szene.camStart and szene.camEnd then
		local a = ( getTickCount () - introStartTick ) / introSzenenDauer
		if a < 0 then a = 0 end
		if a > 1 then a = 1 end

		local cx, cy, cz, lx, ly, lz, roll, fov = introKameraMischen ( szene.camStart, szene.camEnd, a )
		setCameraMatrix ( cx, cy, cz, lx, ly, lz, roll, fov )
		return
	end

	local vergangen = getTickCount () - introStartTick
	local anteil = vergangen / introSzenenDauer
	if anteil < 0 then anteil = 0 end
	if anteil > 1 then anteil = 1 end

	local camX, camY, camZ = introKameraPosition ( szene, anteil, vergangen )
	local lookX, lookY, lookZ, roll, fov = introKameraBlick ( szene, anteil, vergangen )

	setCameraMatrix ( camX, camY, camZ, lookX, lookY, lookZ, roll, fov )
end

local function introRenderUntertitel ()
	if not introCutsceneAktiv then return end

	if isCursorShowing () then
		showCursor ( false )
	end

	local szene = introSzenen[introIndex]
	if not szene then return end

	dxDrawRectangle ( 0, 0, screenW, BALKEN_HOEHE, tocolor ( 0, 0, 0, 235 ) )
	dxDrawRectangle ( 0, screenH - BALKEN_HOEHE, screenW, BALKEN_HOEHE, tocolor ( 0, 0, 0, 235 ) )

	local fortschritt = introFortschritt ()
	local leisteY = BALKEN_HOEHE - 4 * SKALA
	dxDrawRectangle ( 0, leisteY, screenW, 4 * SKALA, tocolor ( 60, 60, 60, 200 ) )
	dxDrawRectangle ( 0, leisteY, screenW * fortschritt, 4 * SKALA, tocolor ( 0, 170, 255, 235 ) )

	if szene.titel then
		dxDrawText ( szene.titel, screenW * 0.1, screenH - BALKEN_HOEHE * 1.35, screenW * 0.9, screenH - BALKEN_HOEHE,
			tocolor ( 0, 190, 255, 255 ), 1.05 * SKALA, "default-bold", "center", "bottom", false, false )
	end

	dxDrawText ( szene.text, screenW * 0.1, screenH - BALKEN_HOEHE, screenW * 0.9, screenH - BALKEN_HOEHE * 0.35,
		tocolor ( 255, 255, 255, 255 ), 1.15 * SKALA, "default-bold", "center", "center", false, true )

	dxDrawText ( "Einfuehrung "..introIndex.."/"..#introSzenen, screenW * 0.03, 0, screenW * 0.97, BALKEN_HOEHE * 0.6,
		tocolor ( 200, 200, 200, 255 ), 0.9 * SKALA, "default-bold", "left", "center", false, true )

	dxDrawText ( "Taste [N] zum Ueberspringen", screenW * 0.03, 0, screenW * 0.97, BALKEN_HOEHE * 0.6,
		tocolor ( 200, 200, 200, 255 ), 0.9 * SKALA, "default-bold", "right", "center", false, true )
end

local function introWechsleSzene ( i )
	introIndex = i
	local szene = introSzenen[i]
	if not szene then
		return
	end

	introStartTick = getTickCount ()
	introSzenenDauer = introSzenenDauerFuer ( szene.text )

	setElementInterior ( localPlayer, szene.int )
	setElementDimension ( localPlayer, szene.dim )
	introPlayTTS ( szene.text )
	fadeCamera ( true, 0.4 )

	if introTimer and isTimer ( introTimer ) then killTimer ( introTimer ) end
	if i >= #introSzenen then
		introTimer = setTimer ( introBeenden, introSzenenDauer, 1 )
	else
		introTimer = setTimer ( introZeigeSzene, introSzenenDauer, 1, i + 1 )
	end
end

function introZeigeSzene ( i )
	fadeCamera ( false, 0.3 )
	if introTimer and isTimer ( introTimer ) then killTimer ( introTimer ) end
	introTimer = setTimer ( introWechsleSzene, BLENDE_DAUER, 1, i )
end

function introBeenden ()
	if not introCutsceneAktiv then return end
	introCutsceneAktiv = false
	tutorial = false

	if introIstRegistrierung then
		triggerServerEvent ( "introCutsceneFinished", localPlayer )
	end
	introIstRegistrierung = false

	fadeCamera ( true, 0.5 )

	if introTimer and isTimer ( introTimer ) then
		killTimer ( introTimer )
		introTimer = nil
	end

	if isTimer ( introCursorTimer ) then
		killTimer ( introCursorTimer )
		introCursorTimer = nil
	end

	guiSetInputEnabled ( false )

	removeEventHandler ( "onClientRender", root, introRenderFrame )
	removeEventHandler ( "onClientHUDRender", root, introRenderUntertitel )
	guiSetInputMode ( "allow_binds" )

	if isElement ( introMusik ) then
		destroyElement ( introMusik )
		introMusik = nil
	end

	introStopTTS ()

	setElementInterior ( localPlayer, introIntBackup )
	setElementDimension ( localPlayer, introDimBackup )
	setCameraTarget ( localPlayer )
	setPlayerHudComponentVisible ( "radar", true )
	showChat ( true )
	showCursor ( false )
	toggleAllControls ( true )
end

function introStarten ( vonRegistrierung )
	if introCutsceneAktiv then return end
	introCutsceneAktiv = true
	tutorial = true
	introIstRegistrierung = ( vonRegistrierung ~= false )

	introIntBackup = getElementInterior ( localPlayer )
	introDimBackup = getElementDimension ( localPlayer )

	setPlayerHudComponentVisible ( "radar", false )
	showChat ( false )
	showCursor ( false )
	guiSetInputEnabled ( false )
	setElementClicked ( false )
	toggleAllControls ( false )
	guiSetInputMode ( "no_binds" )

	introSkipTasteWarUnten = getKeyState ( "n" )

	if isTimer ( introCursorTimer ) then
		killTimer ( introCursorTimer )
	end
	introCursorTimer = setTimer ( function ()
		if introCutsceneAktiv then
			if isCursorShowing () then
				showCursor ( false )
			end
			setElementClicked ( false )
			guiSetInputEnabled ( false )
		end
	end, 250, 40 )

	introMusik = playSound ( "register_login/Loginmusic.mp3", true )
	if introMusik then
		setSoundVolume ( introMusik, 0.3 )
	end

	addEventHandler ( "onClientRender", root, introRenderFrame )
	addEventHandler ( "onClientHUDRender", root, introRenderUntertitel )

	introZeigeSzene ( 1 )
end
addEvent ( "startIntroCutscene", true )
addEventHandler ( "startIntroCutscene", root, function () introStarten ( true ) end )

addEvent ( "introCutsceneAbort", true )
addEventHandler ( "introCutsceneAbort", root, function ()
	if introCutsceneAktiv then
		introIstRegistrierung = false
		introBeenden ()
	else
		tutorial = false
		guiSetInputMode ( "allow_binds" )
		fadeCamera ( true, 0.5 )
		setCameraTarget ( localPlayer )
		showChat ( true )
		toggleAllControls ( true )
	end
end )

addEventHandler ( "onClientResourceStop", resourceRoot, function ()
	if introCutsceneAktiv then
		introIstRegistrierung = false
		introBeenden ()
	end
end )
