--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--\\                                                  //

-- Achievement-Benachrichtigung: dezente Karte oben rechts statt Vollbild-
-- Overlay, damit das Spiel waehrend des Einblendens weiter sichtbar/spielbar
-- bleibt. Gleiten von rechts rein, kurz stehen, ausblenden.

local sw, sh = guiGetScreenSize ()
local ICON = ":"..getResourceName ( getThisResource () ).."/images/pokal.bmp"

local KARTE_BREITE  = 340
local KARTE_HOEHE   = 78
-- Unten mittig statt oben rechts: rechts oben liegt das HUD ( anzeigen/hud.lua,
-- bis y 279 ), rechts ab y 300 stapeln die Infoboxen, unten rechts der Tacho.
-- Unten links ist das Radar. Die Mitte unten bleibt in allen Faellen frei.
local KARTE_ABSTAND_UNTEN = 170
local EINBLEND_MS   = 300
local STEHEN_MS     = 4500
local AUSBLEND_MS   = 500
local GESAMT_MS     = EINBLEND_MS + STEHEN_MS + AUSBLEND_MS

local aktiveMeldung = nil -- { text = "...", start = tick }

local function easeOutQuad ( t )
	return 1 - ( 1 - t ) * ( 1 - t )
end

local function renderAchievment ()
	if not aktiveMeldung then return end
	if getElementData ( lp, "ElementClicked" ) then return end

	local vergangen = getTickCount () - aktiveMeldung.start
	if vergangen >= GESAMT_MS then
		aktiveMeldung = nil
		return
	end

	-- Alpha-/Gleit-Verlauf: einblenden -> stehen -> ausblenden.
	-- Die Karte gleitet von unten hoch, passend zur neuen Position.
	local alpha, versatz
	if vergangen < EINBLEND_MS then
		local t = easeOutQuad ( vergangen / EINBLEND_MS )
		alpha = t
		versatz = ( 1 - t ) * ( KARTE_HOEHE + 40 )
	elseif vergangen < EINBLEND_MS + STEHEN_MS then
		alpha = 1
		versatz = 0
	else
		local t = ( vergangen - EINBLEND_MS - STEHEN_MS ) / AUSBLEND_MS
		alpha = 1 - t
		versatz = 0
	end

	local kx = math.floor ( ( sw - KARTE_BREITE ) / 2 )
	local ky = math.floor ( sh - KARTE_ABSTAND_UNTEN - KARTE_HOEHE + versatz )

	local a = math.floor ( alpha * 255 )
	dxDrawRectangle ( kx, ky, KARTE_BREITE, KARTE_HOEHE, tocolor ( 15, 15, 20, math.floor ( alpha * 210 ) ) )
	dxDrawRectangle ( kx, ky, 5, KARTE_HOEHE, tocolor ( 0, 200, 90, a ) )

	dxDrawImage ( kx + 16, ky + ( KARTE_HOEHE - 46 ) / 2, 46, 46, ICON, 0, 0, 0, tocolor ( 255, 255, 255, a ) )

	dxDrawText ( "ACHIEVEMENT FREIGESCHALTET", kx + 72, ky + 14, kx + KARTE_BREITE - 12, ky + 30,
		tocolor ( 0, 200, 90, a ), 0.8, "default-bold", "left", "top", false, false, false, false, false )
	dxDrawText ( aktiveMeldung.text, kx + 72, ky + 32, kx + KARTE_BREITE - 12, ky + 68,
		tocolor ( 255, 255, 255, a ), 1.1, "default-bold", "left", "top", false, false, true, false, false )
end
addEventHandler ( "onClientRender", root, renderAchievment )

addEvent ( "showAchievmentBox", true )
addEventHandler ( "showAchievmentBox", root, function ( text )
	if getElementData ( lp, "ElementClicked" ) then
		outputChatBox ( "Achievement erreicht: "..text.." - Du bekommst $.", 255, 255, 255, true )
		return
	end

	achievsound_func ()
	aktiveMeldung = { text = text, start = getTickCount () }
end )
