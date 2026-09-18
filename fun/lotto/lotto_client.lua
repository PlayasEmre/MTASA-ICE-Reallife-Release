--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Lottosystem - Client (DGS)                     ||
--\\                                                  //

local LOTTO_MAX_NUMBER   = 12
local LOTTO_PICKS        = 3
local LOTTO_COLUMNS      = 4
local LOTTO_TICKET_PRICE = 100
local LOTTO_MAX_TICKETS  = 3
local LOTTO_DRAW_HOUR    = 20
local LOTTO_DRAW_MINUTE  = 0

local COLOR_SELECTED     = tocolor ( 0, 150, 0, 220 )
local COLOR_SELECTED_HOV = tocolor ( 0, 185, 0, 220 )

local lottoPickup = createPickup ( -1981.1984863281, 151.7520904541, 27.6875, 3, 1239, 1000 )

local numberButtons = {}
local selectedNumbers = {}
local selectedCount = 0
local defaultButtonColor = nil
local countdownTimer = nil

local lottoJackpot = nil
local lottoTicketsUsed = 0
local lottoLastDraw = nil

local function getSecondsUntilDraw ()
	local time = getRealTime ()
	local nowSeconds = time.hour * 3600 + time.minute * 60 + time.second
	local drawSeconds = LOTTO_DRAW_HOUR * 3600 + LOTTO_DRAW_MINUTE * 60

	local diff = drawSeconds - nowSeconds
	if diff <= 0 then
		diff = diff + 86400
	end

	return diff
end

local function formatCountdown ( seconds )
	return string.format ( "%02d:%02d:%02d", math.floor ( seconds / 3600 ), math.floor ( seconds % 3600 / 60 ), seconds % 60 )
end

local function updateInfoLabels ()
	if not gLabel["lottoJackpot"] then
		return
	end

	dgsSetText ( gLabel["lottoJackpot"], "Jackpot: "..( lottoJackpot and formNumberToMoneyString ( lottoJackpot ) or "wird geladen..." ) )
	dgsSetText ( gLabel["lottoCountdown"], "Naechste Ziehung in: "..formatCountdown ( getSecondsUntilDraw () ) )
	dgsSetText ( gLabel["lottoLastDraw"], "Letzte Ziehung: "..( lottoLastDraw or "noch keine" ) )
	dgsSetText ( gLabel["lottoTickets"], "Preis: "..LOTTO_TICKET_PRICE.." "..Tables.waehrung.."   -   deine Scheine: "..lottoTicketsUsed.."/"..LOTTO_MAX_TICKETS )
end

local function updateButtonColor ( nr )
	local button = numberButtons[nr]
	if not isElement ( button ) then
		return
	end

	if selectedNumbers[nr] then
		dgsSetProperty ( button, "color", { COLOR_SELECTED, COLOR_SELECTED_HOV, COLOR_SELECTED } )
	elseif defaultButtonColor then
		dgsSetProperty ( button, "color", defaultButtonColor )
	end
end

local function clearSelection ()
	for nr = 1, LOTTO_MAX_NUMBER do
		if selectedNumbers[nr] then
			selectedNumbers[nr] = nil
			updateButtonColor ( nr )
		end
	end
	selectedCount = 0
end

function closeLottoWindow ()
	if not gWindow["lotto"] then
		return
	end

	if isTimer ( countdownTimer ) then
		killTimer ( countdownTimer )
	end
	countdownTimer = nil

	if isElement ( gWindow["lotto"] ) then
		destroyElement ( gWindow["lotto"] )
	end

	gWindow["lotto"] = nil
	gLabel["lottoJackpot"] = nil
	gLabel["lottoCountdown"] = nil
	gLabel["lottoLastDraw"] = nil
	gLabel["lottoTickets"] = nil
	numberButtons = {}
	selectedNumbers = {}
	selectedCount = 0

	showCursor ( false )
	setElementClicked ( false )
end

local function toggleNumber ( nr )
	if selectedNumbers[nr] then
		selectedNumbers[nr] = nil
		selectedCount = selectedCount - 1
	elseif selectedCount < LOTTO_PICKS then
		selectedNumbers[nr] = true
		selectedCount = selectedCount + 1
	else
		infobox_start_func ( "Du hast bereits\n"..LOTTO_PICKS.." Kreuze gesetzt.", 5000, 200, 200, 0 )
		return
	end

	updateButtonColor ( nr )
end

local function quickTipp ()
	clearSelection ()

	local pool = {}
	for i = 1, LOTTO_MAX_NUMBER do
		pool[i] = i
	end

	for i = 1, LOTTO_PICKS do
		local pick = math.random ( i, #pool )
		pool[i], pool[pick] = pool[pick], pool[i]

		selectedNumbers[pool[i]] = true
		selectedCount = selectedCount + 1
		updateButtonColor ( pool[i] )
	end
end

local function submitLotto ()
	if selectedCount ~= LOTTO_PICKS then
		infobox_start_func ( "Du musst genau\n"..LOTTO_PICKS.." Kreuze setzen.", 5000, 125, 0, 0 )
		return
	end

	local picks = {}
	for nr = 1, LOTTO_MAX_NUMBER do
		if selectedNumbers[nr] then
			picks[#picks + 1] = nr
		end
	end

	if #picks ~= LOTTO_PICKS then
		return
	end

	closeLottoWindow ()

	triggerServerEvent ( "recieveClientLotto", lp, picks[1], picks[2], picks[3] )
end

function createLottoWindow ()
	if isElement ( gWindow["lotto"] ) then
		return
	end

	local windowW, windowH = 420, 380

	gWindow["lotto"] = dgsCreateWindow ( screenwidth/2-windowW/2, screenheight/2-windowH/2, windowW, windowH, "Lotto - 3 aus 12", false )
	dgsWindowSetCloseButtonEnabled ( gWindow["lotto"], false )
	dgsSetAlpha ( gWindow["lotto"], 1 )
	dgsWindowSetMovable ( gWindow["lotto"], false )
	dgsWindowSetSizable ( gWindow["lotto"], false )

	numberButtons = {}
	selectedNumbers = {}
	selectedCount = 0

	local btnW, btnH, gap = 85, 45, 10
	local gridX = ( windowW - ( LOTTO_COLUMNS * btnW + ( LOTTO_COLUMNS - 1 ) * gap ) ) / 2
	local gridY = 12

	for nr = 1, LOTTO_MAX_NUMBER do
		local col = ( nr - 1 ) % LOTTO_COLUMNS
		local row = math.floor ( ( nr - 1 ) / LOTTO_COLUMNS )

		numberButtons[nr] = dgsCreateButton ( gridX + col * ( btnW + gap ), gridY + row * ( btnH + gap ), btnW, btnH, tostring ( nr ), false, gWindow["lotto"] )
		dgsSetAlpha ( numberButtons[nr], 1 )
		dgsSetFont ( numberButtons[nr], "default-bold" )

		if not defaultButtonColor then
			local color = dgsGetProperty ( numberButtons[nr], "color" )
			if type ( color ) == "table" then
				defaultButtonColor = { color[1], color[2], color[3] }
			end
		end

		addEventHandler ( "onDgsMouseClick", numberButtons[nr],
			function ( button, state )
				if button == "left" and state == "down" then
					toggleNumber ( nr )
				end
			end
		, false )
	end

	local infoY = gridY + 3 * ( btnH + gap ) + 8

	gLabel["lottoJackpot"] = dgsCreateLabel ( 15, infoY, windowW - 30, 18, "", false, gWindow["lotto"] )
	dgsSetAlpha ( gLabel["lottoJackpot"], 1 )
	dgsLabelSetColor ( gLabel["lottoJackpot"], 200, 200, 000 )
	dgsLabelSetVerticalAlign ( gLabel["lottoJackpot"], "top" )
	dgsLabelSetHorizontalAlign ( gLabel["lottoJackpot"], "center", false )
	dgsSetFont ( gLabel["lottoJackpot"], "default-bold" )

	gLabel["lottoCountdown"] = dgsCreateLabel ( 15, infoY + 22, windowW - 30, 16, "", false, gWindow["lotto"] )
	dgsSetAlpha ( gLabel["lottoCountdown"], 1 )
	dgsLabelSetColor ( gLabel["lottoCountdown"], 255, 255, 255 )
	dgsLabelSetVerticalAlign ( gLabel["lottoCountdown"], "top" )
	dgsLabelSetHorizontalAlign ( gLabel["lottoCountdown"], "center", false )
	dgsSetFont ( gLabel["lottoCountdown"], "default" )

	gLabel["lottoLastDraw"] = dgsCreateLabel ( 15, infoY + 40, windowW - 30, 16, "", false, gWindow["lotto"] )
	dgsSetAlpha ( gLabel["lottoLastDraw"], 1 )
	dgsLabelSetColor ( gLabel["lottoLastDraw"], 000, 200, 000 )
	dgsLabelSetVerticalAlign ( gLabel["lottoLastDraw"], "top" )
	dgsLabelSetHorizontalAlign ( gLabel["lottoLastDraw"], "center", false )
	dgsSetFont ( gLabel["lottoLastDraw"], "default" )

	gLabel["lottoTickets"] = dgsCreateLabel ( 15, infoY + 58, windowW - 30, 16, "", false, gWindow["lotto"] )
	dgsSetAlpha ( gLabel["lottoTickets"], 1 )
	dgsLabelSetColor ( gLabel["lottoTickets"], 255, 255, 255 )
	dgsLabelSetVerticalAlign ( gLabel["lottoTickets"], "top" )
	dgsLabelSetHorizontalAlign ( gLabel["lottoTickets"], "center", false )
	dgsSetFont ( gLabel["lottoTickets"], "default" )

	local rowY = windowH - 82
	local wideW = 120

	gButton["lottoQuickTipp"] = dgsCreateButton ( 15, rowY, wideW, 38, "Quicktipp", false, gWindow["lotto"] )
	dgsSetAlpha ( gButton["lottoQuickTipp"], 1 )

	gButton["lottoFillOut"] = dgsCreateButton ( 15 + wideW + 15, rowY, wideW, 38, "Ausfuellen", false, gWindow["lotto"],
		nil, nil, nil, nil, nil, nil, tocolor ( 63, 160, 224, 255 ), tocolor ( 100, 190, 240, 255 ), tocolor ( 44, 120, 170, 255 ) )
	dgsSetAlpha ( gButton["lottoFillOut"], 1 )

	gButton["lottoClose"] = dgsCreateButton ( 15 + 2 * ( wideW + 15 ), rowY, wideW, 38, "Schliessen", false, gWindow["lotto"] )
	dgsSetAlpha ( gButton["lottoClose"], 1 )

	addEventHandler ( "onDgsMouseClick", gButton["lottoQuickTipp"],
		function ( button, state )
			if button == "left" and state == "down" then
				quickTipp ()
			end
		end
	, false )

	addEventHandler ( "onDgsMouseClick", gButton["lottoFillOut"],
		function ( button, state )
			if button == "left" and state == "down" then
				submitLotto ()
			end
		end
	, false )

	addEventHandler ( "onDgsMouseClick", gButton["lottoClose"],
		function ( button, state )
			if button == "left" and state == "down" then
				closeLottoWindow ()
			end
		end
	, false )

	addEventHandler ( "onDgsWindowClose", gWindow["lotto"],
		function ()
			closeLottoWindow ()
		end
	, false )

	updateInfoLabels ()
	countdownTimer = setTimer ( updateInfoLabels, 1000, 0 )

	showCursor ( true )
	setElementClicked ( true )

	triggerServerEvent ( "requestLottoJackpot", lp )
end

addEventHandler ( "onClientPickupHit", lottoPickup,
	function ( hit, dim )
		if hit == localPlayer and dim and not isPedInVehicle ( localPlayer ) then
			createLottoWindow ()
		end
	end
)

function recieveLottoJackpot ( jackpot, ticketsUsed, lastDraw )
	lottoJackpot = jackpot
	lottoTicketsUsed = tonumber ( ticketsUsed ) or 0
	lottoLastDraw = lastDraw

	updateInfoLabels ()
end
addEvent ( "recieveLottoJackpot", true )
addEventHandler ( "recieveLottoJackpot", getRootElement(), recieveLottoJackpot )

addEventHandler ( "onClientResourceStop", resourceRoot,
	function ()
		closeLottoWindow ()
	end
)
