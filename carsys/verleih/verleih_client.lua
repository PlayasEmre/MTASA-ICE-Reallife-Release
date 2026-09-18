--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Fahrzeugverleih - Client                       ||
--\\                                                  //

-- Muss zum Standort im Server passen. Uebernommen vom alten Rollerverleih
-- am Bahnhof San Fierro.
local VL_STATION = { -1982.475, 168.459, 27.6875 }

-- Bilderordner und erlaubte Namensmuster. %d wird durch die Modell-ID
-- ersetzt. Es wird das erste Muster genommen, zu dem eine Datei existiert -
-- so ist es egal, ob die Bilder "Vehicle_462.jpg" oder "462.png" heissen.
-- Liegt gar keins vor, zeigt die Kachel nur den Namen.
-- Neue Bilder zusaetzlich in der meta.xml beim Downloader eintragen.
local VL_BILDPFAD = "images/verleih/"
local VL_BILDNAMEN = { "Vehicle_%d.jpg", "Vehicle_%d.png", "%d.png", "%d.jpg" }

local function findeBild ( modell )
	for i = 1, #VL_BILDNAMEN do
		local pfad = VL_BILDPFAD..string.format ( VL_BILDNAMEN[i], modell )
		if fileExists ( pfad ) then
			return pfad
		end
	end
	return nil
end

-- Muss Reihenfolge und Inhalt von verleihCars im Server entsprechen,
-- sonst mietet der Spieler etwas anderes, als im Fenster steht.
local verleihCars = {
	{ modell = 481, name = "BMX",            preis = 10 },
	{ modell = 462, name = "Faggio",         preis = 30 },
	{ modell = 496, name = "Blista Compact", preis = 200 },
	{ modell = 521, name = "FCR-900",        preis = 250 },
	{ modell = 549, name = "Tampa",          preis = 300 },
}

local verleihPickup = createPickup ( VL_STATION[1], VL_STATION[2], VL_STATION[3], 3, 1239, 1000 )
local verleihBlip   = createBlip ( VL_STATION[1], VL_STATION[2], VL_STATION[3], 55, 2, 255, 255, 255, 255, 0, 200 )

local Verleih = { Window = {}, Button = {}, Label = {}, Image = {} }

function closeVerleihWindow ()
	if not Verleih.Window[1] then
		return
	end

	if isElement ( Verleih.Window[1] ) then
		destroyElement ( Verleih.Window[1] )
	end

	Verleih.Window[1] = nil
	Verleih.Button = {}
	Verleih.Label = {}
	Verleih.Image = {}

	showCursor ( false )
	setElementClicked ( false )
end

function createVerleihWindow ()
	if isElement ( Verleih.Window[1] ) then
		return
	end

	-- Raster: drei Kacheln je Reihe.
	local spalten  = 3
	local abstand  = 12
	-- Die Bilder sind 204 x 125 Pixel. Das Bildfeld haelt dasselbe
	-- Seitenverhaeltnis, sonst werden die Fahrzeuge gestaucht.
	local kachelB  = 200
	local bildH    = math.floor ( ( kachelB - 16 ) * 125 / 204 )
	local kachelH  = bildH + 60

	local reihen = math.ceil ( #verleihCars / spalten )
	local breite = 2 * abstand + spalten * kachelB + ( spalten - 1 ) * abstand
	local hoehe  = 2 * abstand + reihen * kachelH + ( reihen - 1 ) * abstand + 14

	Verleih.Window[1] = dgsCreateWindow ( screenwidth/2 - breite/2, screenheight/2 - hoehe/2, breite, hoehe,
										  "Fahrzeugverleih", false )
	dgsWindowSetCloseButtonEnabled ( Verleih.Window[1], false )
	dgsSetAlpha ( Verleih.Window[1], 1 )
	dgsWindowSetMovable ( Verleih.Window[1], false )
	dgsWindowSetSizable ( Verleih.Window[1], false )

	-- Eigenes Kreuz oben rechts, wie beim alten Rollerverleih.
	Verleih.Button["zu"] = dgsCreateButton ( breite - 30, -25, 30, 25, "×", false, Verleih.Window[1],
											 _, _, _, _, _, _,
											 nil, nil, nil, true )
	dgsSetProperty ( Verleih.Button["zu"], "textSize", { 1.6, 1.6 } )

	addEventHandler ( "onDgsMouseClick", Verleih.Button["zu"], function ( btn, state )
		if btn == "left" and state == "up" then
			closeVerleihWindow ()
		end
	end, false )

	for i = 1, #verleihCars do
		local eintrag = verleihCars[i]
		local spalte = ( i - 1 ) % spalten
		local reihe  = math.floor ( ( i - 1 ) / spalten )

		local kx = abstand + spalte * ( kachelB + abstand )
		local ky = abstand + reihe * ( kachelH + abstand )

		-- Die ganze Kachel ist der Knopf: anklicken mietet das Fahrzeug.
		local kachel = dgsCreateButton ( kx, ky, kachelB, kachelH, "", false, Verleih.Window[1],
										 _, _, _, _, _, _,
										 nil, nil, nil, true )
		Verleih.Button[i] = kachel

		local pfad = findeBild ( eintrag.modell )

		if pfad then
			Verleih.Image[i] = dgsCreateImage ( 8, 8, kachelB - 16, bildH, pfad, false, kachel )
			dgsSetAlpha ( Verleih.Image[i], 1 )
		else
			Verleih.Image[i] = dgsCreateLabel ( 8, 8, kachelB - 16, bildH, "Kein Bild\n( Vehicle_"..eintrag.modell..".jpg )", false, kachel )
			dgsSetAlpha ( Verleih.Image[i], 1 )
			dgsLabelSetColor ( Verleih.Image[i], 130, 136, 150 )
			dgsLabelSetHorizontalAlign ( Verleih.Image[i], "center", true )
			dgsLabelSetVerticalAlign ( Verleih.Image[i], "center" )
		end

		local name = dgsCreateLabel ( 6, bildH + 12, kachelB - 12, 20, eintrag.name, false, kachel )
		dgsSetAlpha ( name, 1 )
		dgsLabelSetColor ( name, 255, 255, 255 )
		dgsLabelSetHorizontalAlign ( name, "center", false )
		dgsSetFont ( name, "default-bold" )

		local preis = dgsCreateLabel ( 6, bildH + 32, kachelB - 12, 20, formNumberToMoneyString ( eintrag.preis ), false, kachel )
		dgsSetAlpha ( preis, 1 )
		dgsLabelSetColor ( preis, 0, 220, 0 )
		dgsLabelSetHorizontalAlign ( preis, "center", false )

		-- Bild und Beschriftung liegen ueber der Kachel. Waeren sie fuer die
		-- Maus erreichbar, fingen sie die Klicks ab und zeigten dabei eigene
		-- Markierungen. Abgeschaltet reagiert nur noch die Kachel darunter.
		for _, teil in ipairs ( { Verleih.Image[i], name, preis } ) do
			if isElement ( teil ) then
				dgsSetEnabled ( teil, false )
			end
		end

		addEventHandler ( "onDgsMouseClick", kachel, function ( btn, state )
			if btn == "left" and state == "up" then
				closeVerleihWindow ()
				triggerServerEvent ( "requestVerleih", lp, i )
			end
		end, false )
	end

	showCursor ( true )
	setElementClicked ( true )
end

addEventHandler ( "onClientPickupHit", verleihPickup, function ( hit, dim )
	if hit ~= localPlayer or not dim then
		return
	end

	-- Wie beim alten Rollerverleih: nicht oeffnen, solange ein anderes
	-- Fenster den Mauszeiger belegt oder der Spieler im Fahrzeug sitzt.
	if getElementData ( localPlayer, "ElementClicked" ) == true then
		return
	end

	if isPedInVehicle ( localPlayer ) then
		return
	end

	createVerleihWindow ()
end )

addEventHandler ( "onClientResourceStop", resourceRoot, closeVerleihWindow )
