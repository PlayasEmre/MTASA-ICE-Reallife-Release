--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

local seaPaint = createMarker ( -1583.24, 156.23, -1, "cylinder", 10, 255, 0, 0, 150,false,root)
local airPaint = createMarker ( 404.25, 2454.38, 15.25, "cylinder", 10, 255, 0, 0, 150,false, root )
createBlip ( 404.25, 2454.38, 0, 63, 1.5, 255, 0, 0, 255, 0, 200 )
createBlip ( -1583.24, 156.23, 0, 63, 1.5, 255, 0, 0, 255, 0, 200 )

addEventHandler ( "onClientMarkerHit", seaPaint,
	function ( player, dim )
		if dim and player == lp then
			if getPedOccupiedVehicleSeat ( lp ) == 0 then
				local id = getElementModel ( getPedOccupiedVehicle ( lp ) )
				if motorboats[id] or raftboats[id] then
					showColorSelection ()
				end
			end
		end
	end
)

addEventHandler ( "onClientMarkerHit", airPaint,
	function ( player, dim )
		if dim and player == lp then
			if getPedOccupiedVehicleSeat ( lp ) == 0 then
				local id = getElementModel ( getPedOccupiedVehicle ( lp ) )
				if planea[id] or planeb[id] or helicopters[id] then
					local x, y, z = getElementPosition ( lp )
					if z <= 25 then
						showColorSelection ()
					end
				end
			end
		end
	end
)

colorSelectionImage = nil
colorSelected = nil
local curSelectedColor
local vColorOld = {}
local vColorNew = {}
local idTable = {}
idTable["Farbe A"] = 1
idTable["Farbe B"] = 2
idTable["Farbe C"] = 3
idTable["Farbe D"] = 4
local vehicleColorSelectionWindow = nil

-- Kompakte, reduzierte Farbpalette: nur die ersten 4 von 7 Zeilen des
-- Original-Farbrasters (80 statt 127 Farben) werden per UV-Crop angezeigt.
local PALETTE_COLS = 20
local PALETTE_ROWS = 4
local PALETTE_TOTAL_ROWS = 7
local CELL_SIZE = 20
local MAX_COLOR_ID = PALETTE_COLS * PALETTE_ROWS - 1

local WIN_W, WIN_H = 530, 170
local IMG_X, IMG_Y = 10, 26
local IMG_W, IMG_H = PALETTE_COLS * CELL_SIZE, PALETTE_ROWS * CELL_SIZE
local RIGHT_X = IMG_X + IMG_W + 10
local RIGHT_W = WIN_W - RIGHT_X - 10
local RADIO_H = 18
local BTN_H = 24

function showColorSelection ()

	if isElement ( vehicleColorSelectionWindow ) then
		return
	end

	local veh = getPedOccupiedVehicle ( lp )
	if veh then
		vColorOld[1], vColorOld[2], vColorOld[3], vColorOld[4] = getVehicleColor ( veh )
		vColorNew[1], vColorNew[2], vColorNew[3], vColorNew[4] = vColorOld[1], vColorOld[2], vColorOld[3], vColorOld[4]
		vehicleColorSelectionWindow = dgsCreateWindow ( screenwidth / 2 - WIN_W / 2, screenheight / 2 - WIN_H / 2, WIN_W, WIN_H, "Farbauswahl", false, nil, nil, nil, nil, nil, tocolor(16,29,61,255), nil, true )
		dgsBringToFront ( vehicleColorSelectionWindow )
		guiSetInputMode ( "no_binds_when_editing" )
		showCursor ( true )
		setElementClicked ( true )
		dgsWindowSetMovable ( vehicleColorSelectionWindow, false )
		dgsWindowSetSizable ( vehicleColorSelectionWindow, false )
		addEventHandler ( "onDgsWindowClose", vehicleColorSelectionWindow,
			function ()
				guiSetInputMode ( "allow_binds" )
				showCursor ( false )
				setElementClicked ( false )
				vehicleColorSelectionWindow = nil
			end,
		false )

		colorSelectionImage = vehicleColorSelectionWindow

		local imgPath = ":"..getResourceName(getThisResource()).."/images/colors/carcolors.png"
		colorSwatches = {}
		for row = 0, PALETTE_ROWS - 1 do
			for col = 0, PALETTE_COLS - 1 do
				local id = row * PALETTE_COLS + col
				local swatch = dgsCreateImage ( IMG_X + col * CELL_SIZE, IMG_Y + row * CELL_SIZE, CELL_SIZE, CELL_SIZE, imgPath, false, vehicleColorSelectionWindow )
				dgsImageSetUVPosition ( swatch, col / PALETTE_COLS, row / PALETTE_TOTAL_ROWS, true )
				dgsImageSetUVSize ( swatch, 1 / PALETTE_COLS, 1 / PALETTE_TOTAL_ROWS, true )
				colorSwatches[id] = swatch

				addEventHandler ( "onDgsMouseClickUp", swatch,
					function ( button )
						if button ~= "left" then return end
						vColorNew[curSelectedColor] = id
						setVehicleColor ( getPedOccupiedVehicle ( lp ), vColorNew[1], vColorNew[2], vColorNew[3], vColorNew[4] )
						showCarColorSelection ( col, row )
					end,
				false )
			end
		end

		local x, y = calcVehColorSelection ( vColorOld[1] )
		showCarColorSelection ( x, y )

		gRadio["vehColorSelectionColor1"] = dgsCreateRadioButton ( RIGHT_X, IMG_Y + RADIO_H * 0, RIGHT_W, RADIO_H, "Farbe A", false, vehicleColorSelectionWindow )
		gRadio["vehColorSelectionColor2"] = dgsCreateRadioButton ( RIGHT_X, IMG_Y + RADIO_H * 1, RIGHT_W, RADIO_H, "Farbe B", false, vehicleColorSelectionWindow )
		gRadio["vehColorSelectionColor3"] = dgsCreateRadioButton ( RIGHT_X, IMG_Y + RADIO_H * 2, RIGHT_W, RADIO_H, "Farbe C", false, vehicleColorSelectionWindow )
		gRadio["vehColorSelectionColor4"] = dgsCreateRadioButton ( RIGHT_X, IMG_Y + RADIO_H * 3, RIGHT_W, RADIO_H, "Farbe D", false, vehicleColorSelectionWindow )

		local buttonsY = IMG_Y + RADIO_H * 4 + 10
		gButton["vehColorSelectionClose"] = dgsCreateButton ( RIGHT_X, buttonsY, RIGHT_W, BTN_H, "Schliessen", false, vehicleColorSelectionWindow, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255) )
		gButton["vehColorSelectionAccept"] = dgsCreateButton ( RIGHT_X, buttonsY + BTN_H + 6, RIGHT_W, BTN_H, "Lackieren", false, vehicleColorSelectionWindow, _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255) )

		addEventHandler ( "onDgsMouseClickUp", gButton["vehColorSelectionClose"],
			function ( button )
				if button ~= "left" then return end
				destroyElement ( vehicleColorSelectionWindow )
				vehicleColorSelectionWindow = nil
				guiSetInputMode ( "allow_binds" )
				showCursor ( false )
				setElementClicked ( false )
				setVehicleColor ( getPedOccupiedVehicle ( lp ), vColorOld[1], vColorOld[2], vColorOld[3], vColorOld[4] )
			end,
		false )
		addEventHandler ( "onDgsMouseClickUp", gButton["vehColorSelectionAccept"],
			function ( button )
				if button ~= "left" then return end
				vColorOld[1], vColorOld[2], vColorOld[3], vColorOld[4] = vColorNew[1], vColorNew[2], vColorNew[3], vColorNew[4]
				setVehicleColor ( getPedOccupiedVehicle ( lp ), vColorOld[1], vColorOld[2], vColorOld[3], vColorOld[4] )
				local color = "|"..vColorOld[1].."|"..vColorOld[2].."|"..vColorOld[3].."|"..vColorOld[4].."|"
				setElementData ( getPedOccupiedVehicle ( lp ), "color", color )
			end,
		false )

		dgsRadioButtonSetSelected ( gRadio["vehColorSelectionColor1"], true )
		curSelectedColor = 1

		for i = 1, 4 do
			dgsSetFont ( gRadio["vehColorSelectionColor"..i], "default-bold" )

			addEventHandler ( "onDgsMouseClickUp", gRadio["vehColorSelectionColor"..i],
				function ( button )
					if button ~= "left" then return end
					local id = idTable[dgsGetText ( source )]

					local x, y = calcVehColorSelection ( vColorNew[id] )
					showCarColorSelection ( x, y )

					curSelectedColor = id
				end,
			false )
		end

	end
end

function showCarColorSelection ( x, y )

	if isElement ( colorSelected ) then
		destroyElement ( colorSelected )
	end
	local px = IMG_X + x * CELL_SIZE
	local py = IMG_Y + y * CELL_SIZE
	colorSelected = dgsCreateImage ( px, py, CELL_SIZE, CELL_SIZE, ":"..getResourceName(getThisResource()).."/images/colors/selection.png", false, colorSelectionImage )
end

function cselect ()

	showColorSelection ()
end

function calcVehColorSelection ( color )

	color = tonumber ( color ) or 0
	if color > MAX_COLOR_ID then
		color = 0
	end
	local y = math.floor ( color / PALETTE_COLS )
	local x = color % PALETTE_COLS
	return x, y
end
