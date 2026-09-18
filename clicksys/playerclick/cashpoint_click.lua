--//                                                 \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                 //

gGridList = {}
gLabel = {}

local clientStatements = {}

-- Kleine Helfer fuer das Kartenlayout: ein dunkles Panel mit duennem
-- blauem Strich als Rahmen, als Ersatz fuer "abgerundete Karten" (DGS kann
-- keine echten border-radius-Formen ohne fertige PNG-Assets zeichnen).
local function createSection(x, y, w, h, parent)
	local bg = dgsCreateImage(x, y, w, h, ":"..getResourceName(getThisResource()).."/images/colors/c_black.jpg", false, parent, tocolor(24, 38, 54, 255))
	local borderImg = ":"..getResourceName(getThisResource()).."/images/colors/c_lblue.jpg"
	local borderCol = tocolor(46,110,255,255)
	dgsCreateImage(0, 0, w, 1, borderImg, false, bg, borderCol)
	dgsCreateImage(0, h - 1, w, 1, borderImg, false, bg, borderCol)
	dgsCreateImage(0, 0, 1, h, borderImg, false, bg, borderCol)
	dgsCreateImage(w - 1, 0, 1, h, borderImg, false, bg, borderCol)
	return bg
end

local function createHeader(text, x, y, w, parent)
	local label = dgsCreateLabel(x, y, w, 16, text, false, parent)
	dgsLabelSetColor(label, 100, 181, 246)
	dgsLabelSetVerticalAlign(label, "top")
	dgsLabelSetHorizontalAlign(label, "left", false)
	dgsSetFont(label, "default-bold")
	return label
end

function showCashPoint_func ()
	showCursor(true)
	if gWindow["cashPoint"] then
		dgsSetVisible(gWindow["cashPoint"], true)
		dgsBringToFront(gWindow["cashPoint"])
		dgsSetInputMode("no_binds_when_editing")
	else
		dgsSetInputMode("no_binds_when_editing")
		local winW = 400
		local tabPanelY = 20
		local tabPanelH = 275
		local closeY = tabPanelY + tabPanelH
		local winH = closeY + 55 + 20

		-- Fenster insgesamt etwas hoeher auf dem Bildschirm statt exakt
		-- mittig - auf Wunsch weiter nach oben versetzt.
		local winY = (screenheight - winH) / 2 - 40

		gWindow["cashPoint"] = dgsCreateWindow(screenwidth/2-winW/2, winY, winW, winH, "Geldautomat", false)
		dgsBringToFront(gWindow["cashPoint"])
		dgsWindowSetSizable ( gWindow["cashPoint"], false )
		dgsWindowSetMovable ( gWindow["cashPoint"], false )
		dgsWindowSetCloseButtonEnabled(gWindow["cashPoint"], false)
		dgsSetAlpha(gWindow["cashPoint"], 1)

		gButton["cashPointClose"] = dgsCreateButton(20, closeY, winW-40, 35, "Schließen", false, gWindow["cashPoint"])
		addEventHandler("onDgsMouseClickUp", gButton["cashPointClose"],
			function (button)
				if button == "left" then
					dgsSetVisible(gWindow["cashPoint"], false)
					setElementClicked(false)
					showCursor(false)
					dgsSetInputMode("allow_binds")
				end
			end,
		false)

		gTabPanel["cashPoint"] = dgsCreateTabPanel(20, tabPanelY, winW-40, tabPanelH, false, gWindow["cashPoint"])

		-- Der Schliessen-Button unten sitzt an einer festen Stelle im Fenster,
		-- aber "Ueberweisung"/"Kontoauszug" haben eigenen Inhalt bis fast
		-- dorthin und ueberschneiden sich sonst mit ihm - er wird deshalb nur
		-- auf "Ein/Auszahlen" angezeigt.
		addEventHandler("onDgsTabPanelTabSelect", gTabPanel["cashPoint"],
			function (newIndex, oldIndex, newTab, oldTab)
				dgsSetVisible(gButton["cashPointClose"], newTab == gTab["cashPointPayOut"])
			end,
		false)

		----------------------------------------------------------------
		-- Tab 1: Ein/Auszahlen
		----------------------------------------------------------------
		gTab["cashPointPayOut"] = dgsCreateTab("Ein/Auszahlen", gTabPanel["cashPoint"])

		local sect1 = createSection(8, 10, 334, 92, gTab["cashPointPayOut"])
		createHeader("BETRAG EINGEBEN", 16, 12, 200, sect1)
		gEdit["cashPointPayAmount"] = dgsCreateEdit(16, 34, 250, 34, "0", false, sect1, tocolor(235,242,250,255), _, _, _, tocolor(34,52,72,255))
		gLabel[2] = dgsCreateLabel(272, 42, 20, 20, "€", false, sect1)
		dgsLabelSetColor(gLabel[2], 100, 181, 246)
		dgsSetFont(gLabel[2], "default-bold")

		gButton["cashPointPayIn"] = dgsCreateButton(8, 112, 161, 44, "Einzahlen", false, gTab["cashPointPayOut"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["cashPointPayOut"] = dgsCreateButton(181, 112, 161, 44, "Auszahlen", false, gTab["cashPointPayOut"])

		addEventHandler("onDgsMouseClickUp", gButton["cashPointPayIn"],
			function (button)
				if button == "left" then
					local amount = tonumber(dgsGetText(gEdit["cashPointPayAmount"]))
					if not amount or amount <= 0 then
						outputChatBox("Bitte eine gueltige Zahl eingeben!", 200, 0, 0)
						return
					end
					triggerServerEvent("cashPointPayIn", lp, amount)
					setTimer(function() triggerServerEvent("requestRecentStatements", localPlayer) end, 2000, 1)
				end
			end,
		false)
		addEventHandler("onDgsMouseClickUp", gButton["cashPointPayOut"],
			function (button)
				if button == "left" then
					local amount = tonumber(dgsGetText(gEdit["cashPointPayAmount"]))
					if not amount or amount <= 0 then
						outputChatBox("Bitte eine gueltige Zahl eingeben!", 200, 0, 0)
						return
					end
					triggerServerEvent("cashPointPayOut", lp, amount)
					setTimer(function() triggerServerEvent("requestRecentStatements", localPlayer) end, 2000, 1)
				end
			end,
		false)

		----------------------------------------------------------------
		-- Tab 2: Ueberweisung
		----------------------------------------------------------------
		gTab["cashPointTransfer"] = dgsCreateTab("Ueberweisung", gTabPanel["cashPoint"])

		-- Eine einzige durchgehende Karte statt drei einzelner Boxen mit
		-- Luecken dazwischen - dazwischen nur duenne Trennlinien, damit der
		-- Rahmen als GANZES immer geschlossen/durchgehend wirkt.
		local formH = 210
		local sectForm = createSection(8, 8, 334, formH, gTab["cashPointTransfer"])
		local divider = ":"..getResourceName(getThisResource()).."/images/colors/c_lblue.jpg"
		local dividerCol = tocolor(100, 181, 246, 120)

		createHeader("EMPFAENGER", 16, 12, 200, sectForm)
		gEdit["cashPointTransferTo"] = dgsCreateEdit(16, 30, 302, 24, "Name", false, sectForm, tocolor(235,242,250,255), _, _, _, tocolor(34,52,72,255))

		dgsCreateImage(16, 68, 302, 1, divider, false, sectForm, dividerCol)

		createHeader("BETRAG", 16, 78, 200, sectForm)
		gEdit["cashPointTransferAmount"] = dgsCreateEdit(16, 96, 264, 24, "0", false, sectForm, tocolor(235,242,250,255), _, _, _, tocolor(34,52,72,255))
		gLabel[6] = dgsCreateLabel(288, 100, 20, 20, "€", false, sectForm)
		dgsLabelSetColor(gLabel[6], 100, 181, 246)
		dgsSetFont(gLabel[6], "default-bold")

		dgsCreateImage(16, 134, 302, 1, divider, false, sectForm, dividerCol)

		createHeader("VERWENDUNGSZWECK", 16, 144, 200, sectForm)
		gMemo["cashPointTransferReason"] = dgsCreateMemo(16, 162, 302, 40, "Grund", false, sectForm)

		gButton["cashPointTransferSend"] = dgsCreateButton(8, 8 + formH + 10, 334, 40, "Senden", false, gTab["cashPointTransfer"], _, _, _, _, _, _, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		addEventHandler("onDgsMouseClickUp", gButton["cashPointTransferSend"],
			function (button)
				if button == "left" then
					local amount = tonumber(dgsGetText(gEdit["cashPointTransferAmount"]))
					local target = dgsGetText(gEdit["cashPointTransferTo"])
					local reason = dgsGetText(gMemo["cashPointTransferReason"])
					if not amount or amount <= 0 then
						outputChatBox("Bitte eine gueltige Zahl eingeben!", 200, 0, 0)
						return
					end
					if not target or #target == 0 then
						outputChatBox("Bitte einen gueltigen Namen eingeben!", 200, 0, 0)
						return
					end
					triggerServerEvent("cashPointTransfer", lp, amount, target, false, reason)
					setTimer(function() triggerServerEvent("requestRecentStatements", localPlayer) end, 2000, 1)
				end
			end,
		false)

		gTab["cashPointPrint"] = dgsCreateTab("Kontoauszug", gTabPanel["cashPoint"])
		createStatementTab()
	end

	triggerServerEvent("requestRecentStatements", localPlayer)
end
addEvent("showCashPoint", true)
addEventHandler("showCashPoint", getRootElement(), showCashPoint_func)


function createStatementTab()
	-- Die eigenen "Grund/Betrag/Sonstiges"-Labels wurden entfernt: die
	-- GridList zeichnet ihre Spaltennamen bereits selbst, das stand vorher
	-- doppelt untereinander.
	local sect = createSection(8, 8, 334, 250, gTab["cashPointPrint"])
	createHeader("KONTOAUSZUG", 16, 10, 200, sect)

	local dgsLabel = dgsCreateLabel(210, 10, 116, 16, getDateAsOneString(), false, sect)
	dgsLabelSetColor(dgsLabel, 160, 180, 195)
	dgsLabelSetHorizontalAlign(dgsLabel, "right", false)

	gGridList["statementEntries"] = dgsCreateGridList(16, 32, 302, 172, false, sect)
	dgsGridListAddColumn(gGridList["statementEntries"], "Grund", 0.4)
	dgsGridListAddColumn(gGridList["statementEntries"], "Betrag", 0.25)
	dgsGridListAddColumn(gGridList["statementEntries"], "Sonstiges", 0.35)

	dgsCreateImage(16, 214, 302, 1, ":"..getResourceName(getThisResource()).."/images/colors/c_lblue.jpg", false, sect)

	local dgsLabel = dgsCreateLabel(16, 224, 69, 17, "Gesamt", false, sect)
	dgsLabelSetColor(dgsLabel, 100, 181, 246)
	dgsSetFont(dgsLabel, "default-bold")

	gLabel["cashPointTotal"] = dgsCreateLabel(150, 224, 168, 17, "", false, sect)
	dgsLabelSetColor(gLabel["cashPointTotal"], 235, 242, 250)
	dgsLabelSetHorizontalAlign(gLabel["cashPointTotal"], "right", false)
end


addEvent("receiveRecentStatements", true)
addEventHandler("receiveRecentStatements", root, function(statements)
	clientStatements = statements
	refreshStatementLabels()
end)


function refreshStatementLabels ()
	dgsGridListClear(gGridList["statementEntries"])

	for _, entry in ipairs(clientStatements) do
		local row = dgsGridListAddRow(gGridList["statementEntries"])
		dgsGridListSetItemText(gGridList["statementEntries"], row, 1, entry.grund)
		dgsGridListSetItemText(gGridList["statementEntries"], row, 2, entry.betrag .. " €")
		dgsGridListSetItemText(gGridList["statementEntries"], row, 3, entry.sonstiges)
	end

	local money = vioClientGetElementData("bankmoney")

	if not money or type(money) == "boolean" then
		money = 0
	end

	money = tonumber(money) or 0

	local sign = ""
	if money > 0 then
		sign = "+"
	end

	dgsSetText(gLabel["cashPointTotal"], sign .. money .. " " .. (Tables and Tables.waehrung or "€"))
end


function getDateAsOneString ()
	local time = getRealTime()
	local day = time.monthday
	local month = time.month + 1
	local year = time.year + 1900
	local hour = time.hour
	local minute = time.minute

	local formattedDay = (day < 10) and "0" .. day or day
	local formattedMonth = (month < 10) and "0" .. month or month
	local formattedHour = (hour < 10) and "0" .. hour or hour
	local formattedMinute = (minute < 10) and "0" .. minute or minute

	return formattedDay .. "." .. formattedMonth .. "." .. year .. ", " .. formattedHour .. ":" .. formattedMinute
end
