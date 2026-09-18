--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Lottosystem - Server                           ||
--\\                                                  //

local LOTTO_MAX_NUMBER     = 12
local LOTTO_PICKS          = 3
local LOTTO_MAX_TICKETS    = 3
local LOTTO_TICKET_PRICE   = 100
local LOTTO_JACKPOT_BASE   = 50000
local LOTTO_JACKPOT_RAISE  = 50000
local LOTTO_JACKPOT_SHARE  = 0.6
local LOTTO_SECOND_PRIZE   = 2500
local LOTTO_SPLIT_JACKPOT  = true
local LOTTO_DRAW_HOUR      = 20
local LOTTO_DRAW_MINUTE    = 0

-- Berechnet die deutsche Uhrzeit UNABHAENGIG von der Systemzeitzone des
-- Servers. Grund: getRealTime() liest die Windows-Systemzeit des Rechners,
-- auf dem der MTA-Server laeuft - bei manchen gemieteten Gameservern (z.B.
-- ohne eigenen Root-/RDP-Zugriff auf die Zeitzone) laeuft diese auf UTC statt
-- deutscher Zeit. Die Ziehung feuerte dadurch 1-2 Stunden zu spaet (deutsche
-- Zeit) bzw. zu frueh. os.time()/os.date("!*t") liefern dagegen IMMER echtes
-- UTC, egal wie die Systemzeitzone eingestellt ist - darauf wird hier von
-- Hand die deutsche Sommer-/Winterzeit-Regel angewendet. WICHTIG: bewusst
-- kein os.time(Tabelle) verwendet - das interpretiert die Felder als LOKALE
-- Zeit ueber die C-Bibliothek und waere damit wieder von der Systemzeitzone
-- abhaengig, genau das Problem, das hier umgangen werden soll.
local function tageSeitEpoche ( jahr, monat, tag )
	local y = monat <= 2 and jahr - 1 or jahr
	local era = math.floor ( ( y >= 0 and y or y - 399 ) / 400 )
	local yoe = y - era * 400
	local mp = monat > 2 and monat - 3 or monat + 9
	local doy = math.floor ( ( 153 * mp + 2 ) / 5 ) + tag - 1
	local doe = yoe * 365 + math.floor ( yoe / 4 ) - math.floor ( yoe / 100 ) + doy
	return era * 146097 + doe - 719468
end

local function letzterSonntagUTC ( jahr, monat )
	-- Nur fuer Maerz/Oktober gebraucht, beide haben 31 Tage.
	local tage = tageSeitEpoche ( jahr, monat, 31 )
	local wochentag = ( tage + 4 ) % 7 -- 1970-01-01 war ein Donnerstag; 0 = Sonntag
	return ( tage - wochentag ) * 86400
end

local function istDeutscheSommerzeit ( utcSekunden )
	local jahr = os.date ( "!*t", utcSekunden ).year
	local start = letzterSonntagUTC ( jahr, 3 ) + 3600  -- 01:00 UTC
	local ende  = letzterSonntagUTC ( jahr, 10 ) + 3600
	return utcSekunden >= start and utcSekunden < ende
end

function getDeutscheZeit ()
	local jetztUTC = os.time ()
	local offset = istDeutscheSommerzeit ( jetztUTC ) and 2 or 1
	return os.date ( "!*t", jetztUTC + offset * 3600 )
end

lottoJackpotPath = "vio_stored_files/lotto/jackpot.ice"
lottoJackpot = LOTTO_JACKPOT_BASE
lottoLastDraw = nil
lottoDrawInProgress = false

local lottoPurchaseLock = {}
local drawTimer = nil
local lastDrawDay = nil

local function loadLottoState ()
	if not fileExists ( lottoJackpotPath ) then
		outputDebugString ( "[Lotto] jackpot.ice nicht gefunden - starte mit Basis-Jackpot.", 2 )
		return
	end

	local file = fileOpen ( lottoJackpotPath, true )
	if not file then
		outputDebugString ( "[Lotto] jackpot.ice konnte nicht geoeffnet werden - starte mit Basis-Jackpot.", 1 )
		return
	end

	local content = fileRead ( file, fileGetSize ( file ) ) or ""
	fileClose ( file )

	local jackpotPart, drawPart = content:match ( "^([^|]*)|?(.*)$" )

	local jackpot = tonumber ( jackpotPart )
	if not jackpot or jackpot < LOTTO_JACKPOT_BASE then
		outputDebugString ( "[Lotto] jackpot.ice enthaelt keinen gueltigen Wert - starte mit Basis-Jackpot.", 2 )
	else
		lottoJackpot = math.floor ( jackpot )
	end

	if drawPart and drawPart ~= "" then
		lottoLastDraw = drawPart
	end
end

local function saveLottoState ()
	if fileExists ( lottoJackpotPath ) then
		fileDelete ( lottoJackpotPath )
	end

	local file = fileCreate ( lottoJackpotPath )
	if not file then
		outputDebugString ( "[Lotto] jackpot.ice konnte nicht geschrieben werden!", 1 )
		return false
	end

	fileWrite ( file, tostring ( lottoJackpot ).."|"..tostring ( lottoLastDraw or "" ) )
	fileClose ( file )
	return true
end

loadLottoState ()

local function getPlayerTicketCount ( uid )
	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "id", "lotto", "UID", uid )
	if not result then
		return false
	end
	return #result
end

local function payOut ( uid, amount, reason )
	local name = playerUIDName[uid]
	local moneyString = formNumberToMoneyString ( amount )

	local player = name and getPlayerFromName ( name )
	if player and MtxGetElementData ( player, "loggedin" ) == 1 then
		MtxSetElementData ( player, "bankmoney", MtxGetElementData ( player, "bankmoney" ) + amount )
		outputChatBox ( "Lotto: "..reason.." - du gewinnst "..moneyString.."!", player, 0, 200, 0 )
		outputChatBox ( "Das Geld liegt auf deinem Konto - viel Spass!", player, 0, 200, 0 )
		return true
	end

	local result = dbQueryCoro ( "SELECT ?? FROM ?? WHERE ??=?", "Bankgeld", "userdata", "UID", uid )
	if not result or not result[1] then
		outputDebugString ( "[Lotto] Bankgeld fuer UID "..tostring ( uid ).." nicht gefunden - Auszahlung uebersprungen.", 1 )
		return false
	end

	local money = tonumber ( result[1]["Bankgeld"] ) or 0
	dbExec ( handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Bankgeld", money + amount, "UID", uid )

	if name then
		offlinemsg ( "Lotto: "..reason.." - du gewinnst "..moneyString.."! Das Geld ist auf deinem Konto.", "Lotto", name )
	end
	return true
end

function drawLottoWinners ()
	if lottoDrawInProgress then
		return
	end
	lottoDrawInProgress = true

	local pool = {}
	for i = 1, LOTTO_MAX_NUMBER do
		pool[i] = i
	end

	local numbers = {}
	for i = 1, LOTTO_PICKS do
		local pick = math.random ( i, #pool )
		pool[i], pool[pick] = pool[pick], pool[i]
		numbers[i] = pool[i]
	end

	numbers = sortArray ( numbers )

	local l1, l2, l3 = numbers[1], numbers[2], numbers[3]

	outputChatBox ( "Die Lottozahlen:", getRootElement(), 0, 125, 0 )

	setTimer ( outputChatBox, 50, 1, tostring ( l1 ), getRootElement(), 200, 0, 0 )
	setTimer ( outputChatBox, 100, 1, tostring ( l2 ), getRootElement(), 200, 0, 0 )
	setTimer ( outputChatBox, 150, 1, tostring ( l3 ), getRootElement(), 200, 0, 0 )

	setTimer ( function ()
		runAsync ( getLottoWinners, l1, l2, l3 )
	end, 200, 1 )
end

function getLottoWinners ( l1, l2, l3 )
	local drawn = { [l1] = true, [l2] = true, [l3] = true }

	local tickets = dbQueryCoro ( "SELECT ??, ??, ??, ??, ?? FROM ??", "id", "UID", "z1", "z2", "z3", "lotto" )
	if not tickets then
		outputDebugString ( "[Lotto] Scheine konnten nicht geladen werden - Ziehung abgebrochen.", 1 )
		lottoDrawInProgress = false
		return
	end

	local jackpotWinners = {}
	local secondWinners = {}
	local drawnTicketIds = {}

	for i = 1, #tickets do
		local uid = tonumber ( tickets[i]["UID"] )
		local id = tonumber ( tickets[i]["id"] )

		if id then
			drawnTicketIds[#drawnTicketIds + 1] = id
		end

		if uid then
			local hits = 0
			for _, column in ipairs ( { "z1", "z2", "z3" } ) do
				if drawn[tonumber ( tickets[i][column] )] then
					hits = hits + 1
				end
			end

			if hits == LOTTO_PICKS then
				jackpotWinners[#jackpotWinners + 1] = uid
			elseif hits == LOTTO_PICKS - 1 then
				secondWinners[#secondWinners + 1] = uid
			end
		end
	end

	lottoLastDraw = l1.." - "..l2.." - "..l3

	if #jackpotWinners > 0 then
		local payout = LOTTO_SPLIT_JACKPOT and math.floor ( lottoJackpot / #jackpotWinners ) or lottoJackpot
		local payoutString = formNumberToMoneyString ( payout )

		for i = 1, #jackpotWinners do
			local uid = jackpotWinners[i]
			outputChatBox ( tostring ( playerUIDName[uid] or "Unbekannt" ).." hat den Jackpot geknackt und gewinnt: "..payoutString, root, 200, 200, 0 )
			payOut ( uid, payout, "3 Richtige" )
		end

		lottoJackpot = LOTTO_JACKPOT_BASE
	else
		lottoJackpot = lottoJackpot + LOTTO_JACKPOT_RAISE
		outputChatBox ( "Der Jackpot wurde nicht geknackt - damit steigt er auf "..formNumberToMoneyString ( lottoJackpot ).."!", root, 125, 0, 0 )
	end

	for i = 1, #secondWinners do
		payOut ( secondWinners[i], LOTTO_SECOND_PRIZE, "2 Richtige" )
	end

	if #secondWinners > 0 then
		outputChatBox ( #secondWinners.."x 2 Richtige - je "..formNumberToMoneyString ( LOTTO_SECOND_PRIZE )..".", root, 200, 200, 0 )
	end

	saveLottoState ()

	if #drawnTicketIds > 0 then
		dbExec ( handler, "DELETE FROM lotto WHERE id IN ("..table.concat ( drawnTicketIds, "," )..")" )
	end

	lottoDrawInProgress = false

	triggerClientEvent ( getRootElement(), "recieveLottoJackpot", getRootElement(), lottoJackpot, 0, lottoLastDraw )
end

local function checkLottoDrawTime ()
	local time = getDeutscheZeit ()
	local today = time.year.."-"..time.month.."-"..time.day

	if time.hour == LOTTO_DRAW_HOUR and time.min == LOTTO_DRAW_MINUTE and lastDrawDay ~= today then
		lastDrawDay = today
		drawLottoWinners ()
	end
end

addEventHandler ( "onResourceStart", resourceRoot, function ()
	drawTimer = setTimer ( checkLottoDrawTime, 60000, 0 )
	checkLottoDrawTime ()
end )

addEventHandler ( "onResourceStop", resourceRoot, function ()
	if isTimer ( drawTimer ) then
		killTimer ( drawTimer )
	end
	saveLottoState ()
end )

function lotto ( player )
	if MtxGetElementData ( player, "loggedin" ) == 1 and string.upper ( getPlayerName ( player ) ) == string.upper ( "Emre" ) then
		drawLottoWinners ()
	end
end
addCommandHandler ( "lotto", lotto )

function requestLottoJackpot ( player )
	if not isElement ( player ) then
		return
	end

	local uid = playerUID[getPlayerName ( player )]
	local tickets = uid and getPlayerTicketCount ( uid ) or 0

	if not isElement ( player ) then
		return
	end

	triggerClientEvent ( player, "recieveLottoJackpot", player, lottoJackpot, tickets or 0, lottoLastDraw )
end
addEvent ( "requestLottoJackpot", true )
addEventHandler ( "requestLottoJackpot", getRootElement(), function ()
	local player = client
	runAsync ( requestLottoJackpot, player )
end )

function recieveClientLotto ( player, l1, l2, l3 )
	if not isElement ( player ) or MtxGetElementData ( player, "loggedin" ) ~= 1 then
		return
	end

	local uid = playerUID[getPlayerName ( player )]
	if not uid then
		return
	end

	l1, l2, l3 = tonumber ( l1 ), tonumber ( l2 ), tonumber ( l3 )
	if not l1 or not l2 or not l3 then
		return
	end

	l1 = math.abs ( math.floor ( l1 ) )
	l2 = math.abs ( math.floor ( l2 ) )
	l3 = math.abs ( math.floor ( l3 ) )

	if l1 < 1 or l2 < 1 or l3 < 1 or l1 > LOTTO_MAX_NUMBER or l2 > LOTTO_MAX_NUMBER or l3 > LOTTO_MAX_NUMBER then
		return
	end

	if l1 == l2 or l1 == l3 or l2 == l3 then
		return
	end

	if lottoPurchaseLock[player] then
		return
	end

	if lottoDrawInProgress then
		infobox ( player, "Die Ziehung laeuft\ngerade - versuch es\ngleich noch einmal!", 5000, 200, 200, 0 )
		return
	end

	if MtxGetElementData ( player, "money" ) < LOTTO_TICKET_PRICE then
		infobox ( player, "Du hast nicht\ngenug Geld, um\neinen Lottoschein\nzu kaufen!", 5000, 125, 0, 0 )
		return
	end

	lottoPurchaseLock[player] = true

	local tickets = getPlayerTicketCount ( uid )

	if not isElement ( player ) then
		lottoPurchaseLock[player] = nil
		return
	end

	if tickets == false then
		lottoPurchaseLock[player] = nil
		infobox ( player, "Der Lottoschein\nkonnte nicht gekauft\nwerden - versuch\nes erneut!", 5000, 125, 0, 0 )
		return
	end

	if tickets >= LOTTO_MAX_TICKETS then
		lottoPurchaseLock[player] = nil
		infobox ( player, "Du kannst maximal\n"..LOTTO_MAX_TICKETS.." Scheine ausfuellen!", 5000, 125, 0, 0 )
		return
	end

	if lottoDrawInProgress then
		lottoPurchaseLock[player] = nil
		infobox ( player, "Die Ziehung laeuft\ngerade - versuch es\ngleich noch einmal!", 5000, 200, 200, 0 )
		return
	end

	local money = MtxGetElementData ( player, "money" )
	if money < LOTTO_TICKET_PRICE then
		lottoPurchaseLock[player] = nil
		infobox ( player, "Du hast nicht\ngenug Geld, um\neinen Lottoschein\nzu kaufen!", 5000, 125, 0, 0 )
		return
	end

	local numbers = sortArray ( { [1] = l1, [2] = l2, [3] = l3 } )

	MtxSetElementData ( player, "money", money - LOTTO_TICKET_PRICE )

	dbExec ( handler, "INSERT INTO ?? (??,??,??,??) VALUES (?,?,?,?)", "lotto", "UID", "z1", "z2", "z3", uid, numbers[1], numbers[2], numbers[3] )

	lottoJackpot = lottoJackpot + math.floor ( LOTTO_TICKET_PRICE * LOTTO_JACKPOT_SHARE )
	saveLottoState ()

	lottoPurchaseLock[player] = nil

	infobox ( player, "Du hast ein Los\nerworben - die Ziehung\nfindet jeden Tag\num "..string.format ( "%02d:%02d", LOTTO_DRAW_HOUR, LOTTO_DRAW_MINUTE ).." statt!", 5000, 0, 125, 0 )

	triggerClientEvent ( player, "recieveLottoJackpot", player, lottoJackpot, tickets + 1, lottoLastDraw )
end
addEvent ( "recieveClientLotto", true )
addEventHandler ( "recieveClientLotto", getRootElement(), function ( l1, l2, l3 )
	local player = client
	runAsync ( recieveClientLotto, player, l1, l2, l3 )
end )

addEventHandler ( "onPlayerQuit", getRootElement(), function ()
	lottoPurchaseLock[source] = nil
end )
