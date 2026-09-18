--//                                                  \\
--||   Project: MTA - German ICE Reallife Gamemode    ||
--||   Developers: PlayasEmre                         ||
--||   Version: 5.0                                   ||
--\\                                                  //

-- Neu gestaltetes Handy-Panel im Smartphone-Look: ein Home-Screen mit
-- App-Kacheln statt der alten, sehr kleinen Einzelfenster. Funktionen/
-- Server-Events sind unveraendert (callSomeone, SMS, handychange).

local HANDY_W, HANDY_H = 260, 400

-- Kleine Helfer fuer das Kartenlayout, gleiches Muster wie im Rest des
-- Projekts (z.B. Geldautomat): dunkles Panel mit duennem blauem Rahmen.
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

local function hideAllHandyWindows()
	if gWindow["handybg"] then dgsSetVisible(gWindow["handybg"], false) end
	if gWindow["anrufen"] then dgsSetVisible(gWindow["anrufen"], false) end
	if gWindow["sms"] then dgsSetVisible(gWindow["sms"], false) end
end

function handyanrufen()
	showCursor(true)
	hideAllHandyWindows()
	-- Solange man ins Nummernfeld tippt, sollen Tasten-Binds (z.B. "i" fuers
	-- Inventar) nicht ausgeloest werden.
	dgsSetInputMode("no_binds_when_editing")

	if gWindow["anrufen"] then
		dgsSetVisible(gWindow["anrufen"], true)
		dgsBringToFront(gWindow["anrufen"])
	else
		gWindow["anrufen"] = dgsCreateWindow(screenwidth/2-HANDY_W/2, screenheight/2-HANDY_H/2, HANDY_W, HANDY_H, "Anrufen", false)
		dgsBringToFront(gWindow["anrufen"])
		dgsWindowSetCloseButtonEnabled(gWindow["anrufen"], false)
		dgsSetAlpha(gWindow["anrufen"], 1)
		dgsWindowSetMovable(gWindow["anrufen"], false)
		dgsWindowSetSizable(gWindow["anrufen"], false)

		local sect = createSection(10, 40, HANDY_W - 20, 90, gWindow["anrufen"])
		createHeader("RUFNUMMER", 14, 12, 200, sect)
		gEdit["callnr"] = dgsCreateEdit(14, 32, HANDY_W - 48, 34, "", false, sect)

		gButton["callbtn"] = dgsCreateButton(10, 144, HANDY_W - 20, 40, "Anrufen", false, gWindow["anrufen"], nil, nil, nil, nil, nil, nil, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["callback"] = dgsCreateButton(10, 196, HANDY_W - 20, 40, "Zurueck", false, gWindow["anrufen"])

		addEventHandler("onDgsMouseClickUp", gButton["callbtn"],
			function (button)
				if button == "left" then
					if dgsGetText(gEdit["callnr"]) ~= "" and tonumber(dgsGetText(gEdit["callnr"])) then
						triggerServerEvent("callSomeone", localPlayer, localPlayer, dgsGetText(gEdit["callnr"]))
						SelfCancelBtn()
					end
				end
			end, false)

		addEventHandler("onDgsMouseClickUp", gButton["callback"],
			function (button)
				if button == "left" then
					showHandy()
				end
			end, false)
	end
end

function handysmsschreiben(number)
	showCursor(true)
	hideAllHandyWindows()
	-- Solange man ins Nummern-/Textfeld tippt, sollen Tasten-Binds nicht
	-- ausgeloest werden.
	dgsSetInputMode("no_binds_when_editing")

	if gWindow["sms"] then
		dgsSetVisible(gWindow["sms"], true)
		dgsBringToFront(gWindow["sms"])
	else
		gWindow["sms"] = dgsCreateWindow(screenwidth/2-HANDY_W/2, screenheight/2-HANDY_H/2, HANDY_W, HANDY_H, "SMS schreiben", false)
		dgsBringToFront(gWindow["sms"])
		dgsWindowSetCloseButtonEnabled(gWindow["sms"], false)
		dgsSetAlpha(gWindow["sms"], 1)
		dgsWindowSetMovable(gWindow["sms"], false)
		dgsWindowSetSizable(gWindow["sms"], false)

		local sect = createSection(10, 40, HANDY_W - 20, 220, gWindow["sms"])
		createHeader("NUMMER", 14, 12, 200, sect)
		gEdit["smsnr"] = dgsCreateEdit(14, 32, HANDY_W - 48, 30, "", false, sect)

		createHeader("TEXT", 14, 74, 200, sect)
		gMemo["smstext"] = dgsCreateMemo(14, 94, HANDY_W - 48, 116, "", false, sect)

		gButton["sendsms"] = dgsCreateButton(10, 272, HANDY_W - 20, 40, "Senden", false, gWindow["sms"], nil, nil, nil, nil, nil, nil, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
		gButton["smsback"] = dgsCreateButton(10, 318, HANDY_W - 20, 40, "Zurueck", false, gWindow["sms"])

		addEventHandler("onDgsMouseClick", gButton["sendsms"], function (button, state)
			if button == "left" and state == "down" then
				if dgsGetText(gEdit["smsnr"]) ~= "" and tonumber(dgsGetText(gEdit["smsnr"])) then
					if dgsGetText(gMemo["smstext"]) ~= "" then
						local sendnr = tonumber(dgsGetText(gEdit["smsnr"]))
						local sendtext = dgsGetText(gMemo["smstext"])
						triggerServerEvent("SMS", localPlayer, localPlayer, sendnr, sendtext)
					end
				end
			end
		end, false)

		addEventHandler("onDgsMouseClickUp", gButton["smsback"],
			function (button)
				if button == "left" then
					showHandy()
				end
			end, false)
	end
	dgsSetText(gEdit["smsnr"], number)
	-- Direkt ins Textfeld springen, damit man sofort lostippen kann, ohne
	-- vorher erst reinklicken zu muessen.
	dgsFocus(gMemo["smstext"])
end

function showHandy()
	showCursor(true)
	dgsSetInputEnabled(false)
	dgsSetInputMode("no_binds_when_editing")
	hideAllHandyWindows()

	if gWindow["handybg"] then
		dgsSetVisible(gWindow["handybg"], true)
		dgsBringToFront(gWindow["handybg"])
	else
		gWindow["handybg"] = dgsCreateWindow(screenwidth/2-HANDY_W/2, screenheight/2-HANDY_H/2, HANDY_W, HANDY_H, "Handy", false)
		dgsBringToFront(gWindow["handybg"])
		dgsWindowSetCloseButtonEnabled(gWindow["handybg"], false)
		dgsSetAlpha(gWindow["handybg"], 1)
		dgsWindowSetMovable(gWindow["handybg"], false)
		dgsWindowSetSizable(gWindow["handybg"], false)

		local sect = createSection(10, 40, HANDY_W - 20, 60, gWindow["handybg"])
		createHeader("EIGENE NUMMER", 14, 12, 200, sect)
		gLabel["eignummer"] = dgsCreateLabel(14, 32, HANDY_W - 48, 20, tostring(getElementData(localPlayer, "telenr")), false, sect)
		dgsLabelSetColor(gLabel["eignummer"], 235, 242, 250)
		dgsSetFont(gLabel["eignummer"], "default-bold")

		-- App-Kacheln: 2 Spalten, gleichmaessig verteilt.
		local tileW, tileH, gap = (HANDY_W - 30) / 2, 64, 10
		local gridY = 112

		local function tile(col, row, text, primary)
			local x = 10 + col * (tileW + gap)
			local y = gridY + row * (tileH + gap)
			if primary then
				return dgsCreateButton(x, y, tileW, tileH, text, false, gWindow["handybg"], nil, nil, nil, nil, nil, nil, tocolor(46,110,255,255), tocolor(123,163,255,255), tocolor(24,74,199,255))
			end
			return dgsCreateButton(x, y, tileW, tileH, text, false, gWindow["handybg"])
		end

		gButton["callfunc"] = tile(0, 0, "Anrufen", true)
		gButton["smsfunc"] = tile(1, 0, "SMS", true)
		gButton["telefonbuch"] = tile(0, 1, "Telefon-\nbuch", false)
		gButton["servicefunc"] = tile(1, 1, "Service", false)

		gButton["handyonoff"] = dgsCreateButton(10, gridY + 2 * (tileH + gap), HANDY_W - 20, 40, "Ausschalten", false, gWindow["handybg"])

		addEventHandler("onDgsMouseClickUp", gButton["telefonbuch"],
			function (button)
				if button == "left" then
					outputChatBox("Bitte /number [Name] benutzen!", 200, 200, 0)
				end
			end, false)

		addEventHandler("onDgsMouseClickUp", gButton["handyonoff"],
			function (button)
				if button == "left" then
					triggerServerEvent("handychange", localPlayer, localPlayer)
				end
			end, false)

		addEventHandler("onDgsMouseClickUp", gButton["smsfunc"],
			function (button)
				if button == "left" then
					handysmsschreiben("")
				end
			end, false)

		addEventHandler("onDgsMouseClickUp", gButton["callfunc"],
			function (button)
				if button == "left" then
					handyanrufen()
				end
			end, false)

		addEventHandler("onDgsMouseClickUp", gButton["servicefunc"],
			function (button)
				if button == "left" then
					outputChatBox("Notfall: 110, Sanitäter: 112, Mechaniker: 300, Guthaben: *100#", 200, 200, 0)
				end
			end, false)
	end
end
addCommandHandler("handy", showHandy)
