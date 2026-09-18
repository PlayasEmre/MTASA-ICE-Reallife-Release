--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Muss global bleiben: events/halloween_client.lua ruft die Funktion auf.
function dxDrawTextOnElement ( TheElement, text, height, distance, R, G, B, alpha, size, font, ... )
	local x, y, z = getElementPosition ( TheElement )
	local x2, y2, z2 = getCameraMatrix ()
	distance = distance or 20
	height = height or 1

	local distanceBetweenPoints = getDistanceBetweenPoints3D ( x, y, z, x2, y2, z2 )
	if distanceBetweenPoints >= distance then return end
	if not isLineOfSightClear ( x, y, z+2, x2, y2, z2, ... ) then return end

	local sx, sy = getScreenFromWorldPosition ( x, y, z+height )
	if not sx or not sy then return end

	dxDrawText ( text, sx+2, sy+2, sx, sy, tocolor ( R or 255, G or 255, B or 255, alpha or 255 ), ( size or 1 ) - ( distanceBetweenPoints / distance ), font or "arial", "center", "center" )
end


local randomPed = createPed ( 295, -1980.8861083984, 168.37161254883, 27.713445663452, 90 )
setElementFrozen ( randomPed, true )
addEventHandler ( "onClientPedDamage", randomPed, cancelEvent )

PlayasEmre = createPed ( 295, -1998, 210.5, 29.3, 262.003 )
text1 = "PlayasEmre [Entwickler] sagt Gib mir dein Sozialgeld"
setTimer ( setPedAnimation, 500, 1, PlayasEmre, "gangs", "dealer_deal", -1, true, true, false )
setElementFrozen ( PlayasEmre, true )
addEventHandler ( "onClientPedDamage", PlayasEmre, cancelEvent )


local FARBE_WEISS = tocolor ( 255, 255, 255, 255 )

-- Die Ortsschilder werden nur in der normalen Welt gezeigt. Die Pruefung lief
-- vorher in JEDEM einzelnen Textblock erneut - jetzt einmal pro Frame.
local function inAussenwelt ()
	return getElementDimension ( localPlayer ) < 1 and getElementInterior ( localPlayer ) < 1
end


addEventHandler ( "onClientRender", root, function ()
	if not inAussenwelt () then return end

	dxDrawTextOnElement ( randomPed, "Herzlich Willkommen beim Fahrzeugverleih!", 1, 20, 255, 255, 255, 255, 1.5, "sans" )
	dxDrawTextOnElement ( PlayasEmre, tostring ( text1 ), 1, 20, 255, 0, 0, 255, 1.5, "sans" )

	local px, py, pz = getElementPosition ( localPlayer )
	local zx, zy, zz = -1993.5234375, 212.18547058105, 29.282543182373
	if getDistanceBetweenPoints3D ( px, py, pz, zx, zy, zz ) >= 10 then return end
	if not isLineOfSightClear ( px, py, pz, zx, zy, zz, true, true, true, true, true ) then return end

	local sx, sy = getScreenFromWorldPosition ( zx, zy, zz )
	if not sx or not sy then return end

	sx = sx - 20
	dxDrawText ( "#3562C9Herzlich #35C962Willkommen #F7AB26auf #8347ECICE-Reallife #EC479F- viel Spaß!", sx+1, sy+1, sx, sy, FARBE_WEISS, 1.5, "sans", "center", "center", false, false, false, true )
end )


-- Alle Ortsschilder als Datentabelle statt 17 fast identischer Codebloecke.
-- Vorher holte jeder Block erneut getElementPosition ( localPlayer ) - also
-- 17 Aufrufe pro Frame - und rief zusaetzlich guiGetScreenSize() auf, dessen
-- Ergebnis nirgends verwendet wurde.
-- losZ: bei den ersten drei Schildern lief der Sichtcheck schon immer auf einer
-- anderen Hoehe als die Bildschirmposition. Das bleibt bewusst so.
local ortsSchilder = {
	{ x = -2044.0001220703,  y = 449.74362182617,  z = 35.172294616699 + 0.50,  losZ = 35.172294616699,
	  text = "#47C1EEHerzlich willkommen #6DEC6Dim Rathaus! #6DEC6DHier haben Sie die Möglichkeit, verschiedene Unterlagen zu erwerben" },

	{ x = -1605.759765625,   y = 710.7041015625,   z = 13.8671875 + 0.50,       losZ = 13.8671875,
	  text = "#3748E2Willkommen #FF0000im #2B00FFSFPD" },

	{ x = -1883.3000488281,  y = 865.40002441406,  z = 34.200000762939 + 1.4,   losZ = 34.200000762939,
	  text = "#2B00FFWillkommen #F7FF00im #B137DEKleidung #37DE74Shop" },

	{ x = -1808.3822021484,  y = 945.3701171875,   z = 23.848808288574 + 1.4,
	  text = "#A7D055Willkommen #5586D0im Pizzaladen" },

	{ x = -1695.052734375,   y = 951.609375,       z = 24.890625 + 0.50,
	  text = "#55D0D0Willkommen im #A7D055Kleidung #BAC067Shop CJ" },

	{ x = -1649.9169921875,  y = 1209.8126220703,  z = 7.25 + 0.50,
	  text = "#37DE74Willkommen #38ADDFim #38DF86Otto's #DF9738Autohaus" },

	{ x = -1966.1179199219,  y = 293.97113037109,  z = 35.46875 + 0.50,
	  text = "#38DF6AWillkommen #DF9738im #DF9738Wang Cars #BAC067Autohaus" },

	{ x = -1721.3131103516,  y = 1359.7663574219,  z = 6.1736726760864 + 1.4,
	  text = "#38DF6AWillkommen #DF9738im #BAC067Pizzaladen" },

	{ x = -2442.6064453125,  y = 753.44964599609,  z = 34.136966705322 + 1.4,
	  text = "#38DF6AWillkommen #DF9738im #BAC067Supermarkt" },

	{ x = -2625.8752441406,  y = 209.44961547852,  z = 3.5589985847473 + 1.4,
	  text = "#38DF6AWillkommen #DF9738im #BAC067Waffenladen" },

	{ x = -2491.9677734375,  y = -38.8525390625,   z = 25.765625 + 0.50,
	  text = "#38DF6AWillkommen #DF9738im #BAC067Kleidung #BAC067Shop CJ" },

	{ x = -2028.6102294922,  y = -106.0006942749,  z = 35.167686462402 + 0.70,
	  text = "#C067B7Willkommen #DF9738beim #38DF6AAbschlepphof #C067B7Hier kannst #C067B4du #BAC067dein #6797C0Fahrzeug #DF9738freikaufen" },

	{ x = -1980.7,           y = 143.7,            z = 27.3 + 1.5,
	  text = "Geldautomat #6797C0einzahlen #FFFFFFund #C067B4abheben" },

	{ x = -2037,             y = 451.60001,        z = 34.8 + 1.5,
	  text = "Geldautomat #6797C0einzahlen #FFFFFFund #C067B4abheben" },

	{ x = -2226.8,           y = 252.1,            z = 35.3 + 1.5,
	  text = "#47C1EEWillkommen #6DEC6Dim #6DEC6DDeathmatch Arena" },

	{ x = -1981.1984863281,  y = 151.7520904541,   z = 27.6875 + 0.5,
	  text = "#47C1EEWillkommen #6DEC6Dim #6DEC6DLotto Versuch dein Glück" },

	{ x = -1981.2669677734,  y = 153.42135620117,  z = 27.6875 + 0.5,
	  text = "#47C1EEWillkommen #6DEC6Dim #6DEC6DLevelShop #47C1EEViele Belohnungen warten auf dich" },
}
for i = 1, #ortsSchilder do
	local s = ortsSchilder[i]
	s.losZ = s.losZ or s.z
end

-- getElementByID durchsucht den Elementbaum. Die beiden NPCs werden gemerkt und
-- nur dann neu gesucht, wenn der gemerkte Verweis nicht mehr gueltig ist.
local halloweenNPC = nil
local zombieNPC = nil

-- isLineOfSightClear ist die teuerste Operation hier ( Kollisionsabfrage
-- gegen die Welt ). Vorher lief sie fuer alle 17 Schilder in JEDEM Frame
-- ( 60x/Sek. ), auch wenn sich der Spieler kaum bewegt hat. Distanz-/LOS-
-- Check laeuft jetzt nur noch alle 150ms neu, gezeichnet wird weiterhin
-- jeden Frame aus dem zuletzt ermittelten Ergebnis ( dxDrawText selbst ist
-- billig ), damit es optisch keinen Unterschied macht.
local SCHILDER_PRUEF_INTERVALL = 150
local letzteSchilderPruefung = 0
local sichtbareSchilder = {}

addEventHandler ( "onClientRender", root, function ()
	if inAussenwelt () then
		local jetzt = getTickCount ()
		if jetzt - letzteSchilderPruefung >= SCHILDER_PRUEF_INTERVALL then
			letzteSchilderPruefung = jetzt
			sichtbareSchilder = {}
			local px, py, pz = getElementPosition ( localPlayer )
			for i = 1, #ortsSchilder do
				local s = ortsSchilder[i]
				if getDistanceBetweenPoints3D ( px, py, pz, s.x, s.y, s.z ) < 10
				   and isLineOfSightClear ( px, py, pz, s.x, s.y, s.losZ, true, true, true, true, true ) then
					sichtbareSchilder[#sichtbareSchilder+1] = s
				end
			end
		end

		for i = 1, #sichtbareSchilder do
			local s = sichtbareSchilder[i]
			local sx, sy = getScreenFromWorldPosition ( s.x, s.y, s.z )
			if sx and sy then
				dxDrawText ( s.text, sx+1, sy+1, sx, sy, FARBE_WEISS, 1.5, "sans", "center", "center", false, false, false, true )
			end
		end
	else
		sichtbareSchilder = {}
	end

	if event and event.isHalloween then
		if not isElement ( halloweenNPC ) then
			halloweenNPC = getElementByID ( "halloweenHaendler" )
		end
		if halloweenNPC then
			dxDrawTextOnElement ( halloweenNPC, "Halloween-Stand\nKuerbisse gegen Belohnungen", 1.1, 20, 255, 140, 0, 255, 1.3, "sans" )
		end
	end

	if not isElement ( zombieNPC ) then
		zombieNPC = getElementByID ( "zombieNachtWaechter" )
	end
	if zombieNPC then
		dxDrawTextOnElement ( zombieNPC, "Zombie-Nacht\nSofortiger Start - Minigun, 5 Wellen", 1.1, 20, 200, 0, 0, 255, 1.3, "sans" )
	end
end )
