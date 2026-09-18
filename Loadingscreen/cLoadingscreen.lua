--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Ladebildschirm - Client                        ||
--\\                                                  //

local sx, sy = guiGetScreenSize ()

-- Alles ist in einem 1920x1080-Raster entworfen und wird auf die tatsaechliche
-- Aufloesung umgerechnet. Vorher standen ueberall feste Pixelwerte - auf jedem
-- anderen Bildschirm sass damit nichts an seinem Platz.
local RX = sx / 1920
local RY = sy / 1080

local function X ( wert ) return wert * RX end
local function Y ( wert ) return wert * RY end

-- Laenger als die urspruenglichen 3 Sekunden, damit die Hinweise wirklich
-- lesbar sind. Laenger als etwa 6 Sekunden sollte es nicht werden - der
-- Bildschirm ueberdeckt einen Teleport, und niemand wartet gern.
local LADEZEIT = 5500

-- Der Bildschirm ueberdeckt einen Teleport ( Marker ). Deshalb faehrt er
-- schnell hoch und wieder herunter - laenger wuerde sich zaeh anfuehlen.
local EINBLENDEN = 350    -- Millisekunden
local AUSBLENDEN = 500

local ZOOM       = 0.06   -- so viel waechst das Hintergrundbild insgesamt
local TIPP_TAKT  = 2200   -- Millisekunden je Tipp, reicht zum Lesen eines Satzes

-- Feste Akzentfarbe statt einer zufaelligen. Der frueher pro Ladevorgang
-- gewuerfelte Farbwert traf regelmaessig Toene, die auf dem Hintergrundbild
-- kaum zu sehen waren.
-- Olivgruen/Gold - klassische GTA:SA-Menue-Optik statt dem alten Tuerkis.
local AKZENT     = { 201, 162, 39 }
local AKZENT_DKL = { 120, 95, 20 }

local loadingScreenShown = false
local start   = nil
local bild    = 1
local nummer  = 1
local sound   = nil

local Loading = {
	[1] = Tables.servername.."-Reallife wird regelmaessig weiterentwickelt.",
	[2] = "Neu bei uns: die Fahrschule. Mach deinen Fuehrerschein und fahr legal.",
	[3] = "Wir haben eine Tactic Arena - schau mal vorbei.",
	[4] = "Das Grafik-Panel oeffnest du jederzeit mit der F6-Taste.",
	[5] = "Am Bahnhof San Fierro kannst du guenstig Fahrzeuge mieten.",
	[6] = "Schnall dich an - mit J. Ohne Gurt fliegst du bei einem Unfall aus dem Wagen.",
}

---------------------------------------------------------------------
-- Zeichnen
---------------------------------------------------------------------

local function fortschritt ()
	if not start then
		return 0
	end
	return math.max ( 0, math.min ( 1, ( getTickCount () - start ) / LADEZEIT ) )
end

-- Deckkraft des gesamten Bildschirms: schnell auf, am Ende wieder weg.
-- Dadurch schneidet der Teleport nicht mehr hart ins Bild.
local function deckkraft ()
	if not start then
		return 0
	end

	local vergangen = getTickCount () - start

	if vergangen < EINBLENDEN then
		return vergangen / EINBLENDEN
	end

	local rest = LADEZEIT - vergangen
	if rest < AUSBLENDEN then
		return math.max ( 0, rest / AUSBLENDEN )
	end

	return 1
end

function drawBlendingScreen ()
	local a = deckkraft ()
	local p = fortschritt ()

	local function alpha ( wert )
		return math.floor ( wert * a )
	end

	-- Hintergrundbild formatfuellend, dazu ein langsamer Zoom. Ein stehendes
	-- Standbild wirkt bei einer Ueberblendung schnell starr.
	-- Vorher war es fest auf 1920x1274 gezeichnet und damit auf fast jedem
	-- Bildschirm verzerrt oder beschnitten.
	local wachstum = 1 + ZOOM * p
	local bb, bh = sx * wachstum, sy * wachstum

	dxDrawImage ( ( sx - bb ) / 2, ( sy - bh ) / 2, bb, bh,
				  "Loadingscreen/"..bild..".jpg", 0, 0, 0, tocolor ( 255, 255, 255, alpha ( 255 ) ) )

	-- Abdunklung von unten, damit die Schrift ueberall lesbar bleibt.
	dxDrawRectangle ( 0, sy * 0.55, sx, sy * 0.45, tocolor ( 0, 0, 0, alpha ( 120 ) ) )

	-- Die Musik geht mit dem Bild aus, statt abgeschnitten zu werden.
	if isElement ( sound ) then
		setSoundVolume ( sound, 0.6 * a )
	end

	-- Servername gross in der Mitte, in "pricedown" - der eingebauten
	-- GTA-Logoschrift von MTA (kein eigenes Font-Asset noetig).
	dxDrawText ( Tables.servername:upper().." SAN ANDREAS", 0, Y ( 280 ), sx, Y ( 400 ),
				 tocolor ( 245, 240, 225, alpha ( 255 ) ), 3.4 * RY, "pricedown", "center", "center", false, false, false )

	dxDrawText ( "Deine Welt wird geladen", 0, Y ( 400 ), sx, Y ( 440 ),
				 tocolor ( AKZENT[1], AKZENT[2], AKZENT[3], alpha ( 255 ) ), 1.2 * RY, "default-bold", "center", "center", false, false, false )

	-- Hinweiskasten im GTA:SA-Menuestil: dunkles Panel mit dickem Gold-Rand
	-- links statt einer duennen Linie oben.
	local kx, ky = X ( 460 ), Y ( 620 )
	local kb, kh = X ( 1000 ), Y ( 130 )

	local tippNr = ( ( nummer - 1 + math.floor ( ( getTickCount () - start ) / TIPP_TAKT ) ) % #Loading ) + 1

	dxDrawRectangle ( kx, ky, kb, kh, tocolor ( 12, 14, 9, alpha ( 190 ) ) )
	dxDrawRectangle ( kx, ky, X ( 6 ), kh, tocolor ( AKZENT[1], AKZENT[2], AKZENT[3], alpha ( 235 ) ) )

	dxDrawText ( "WUSSTEST DU SCHON", kx + X ( 28 ), ky + Y ( 16 ), kx + kb, ky + Y ( 40 ),
				 tocolor ( AKZENT[1], AKZENT[2], AKZENT[3], alpha ( 255 ) ), 0.9 * RY, "default-bold", "left", "center", false, false, false )

	dxDrawText ( tostring ( Loading[tippNr] ), kx + X ( 28 ), ky + Y ( 48 ), kx + kb - X ( 30 ), ky + kh - Y ( 14 ),
				 tocolor ( 225, 220, 200, alpha ( 255 ) ), 1.15 * RY, "default", "left", "center", false, true, false )

	-- Fortschrittsbalken mit dem vorhandenen Drehsymbol daneben.
	local bx, by = X ( 460 ), Y ( 880 )
	local bb, bh = X ( 1000 ), Y ( 10 )

	dxDrawRectangle ( bx, by, bb, bh, tocolor ( 255, 255, 255, alpha ( 40 ) ) )
	dxDrawRectangle ( bx, by, bb * p, bh, tocolor ( AKZENT[1], AKZENT[2], AKZENT[3], alpha ( 235 ) ) )

	local dreh = ( getTickCount () / 4 ) % 360
	dxDrawImage ( bx + bb + X ( 20 ), by - Y ( 16 ), X ( 42 ), Y ( 42 ),
				  "Loadingscreen/Loading.png", dreh, 0, 0, tocolor ( 255, 255, 255, alpha ( 220 ) ) )

	dxDrawText ( math.floor ( p * 100 ).." %", bx, by + Y ( 16 ), bx + bb, by + Y ( 44 ),
				 tocolor ( 200, 205, 215, alpha ( 255 ) ), 1.0 * RY, "default-bold", "center", "center", false, false, false )
end

---------------------------------------------------------------------
-- Ein- und Ausblenden
---------------------------------------------------------------------

function blendOutLoadingScreen_func ()
	if not loadingScreenShown then
		return
	end

	loadingScreenShown = false

	-- Der Handler wird IMMER entfernt. Vorher hing das an der Bedingung
	-- "und der Sound existiert" - liess sich die Musik nicht abspielen,
	-- blieb der Ladebildschirm dauerhaft stehen.
	removeEventHandler ( "onClientRender", getRootElement(), drawBlendingScreen )
	showChat ( true )

	if isElement ( sound ) then
		destroyElement ( sound )
	end
	sound = nil
end

function blendLoadingScreen_func ()
	if loadingScreenShown then
		return
	end

	loadingScreenShown = true
	showChat ( false )
	showCursor ( false )

	start  = getTickCount ()
	bild   = math.random ( 1, 2 )
	nummer = math.random ( 1, #Loading )

	addEventHandler ( "onClientRender", getRootElement(), drawBlendingScreen )

	sound = playSound ( "Loadingscreen/song.mp3", false )
	if sound then
		setSoundVolume ( sound, 0.6 )
	end

	setTimer ( blendOutLoadingScreen_func, LADEZEIT, 1 )
end
addEvent ( "blendLoadingScreen", true )
addEventHandler ( "blendLoadingScreen", getRootElement(), blendLoadingScreen_func )

-- Sicherheitsnetz: Wird die Ressource beendet, waehrend der Ladebildschirm
-- laeuft, bliebe sonst ein Render-Handler und ein Sound zurueck.
addEventHandler ( "onClientResourceStop", resourceRoot, blendOutLoadingScreen_func )
